import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Extras 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import QtCharts 2.3
import QtQml.Models 2.2

import com.biogearsengine.ui.scenario 1.0
Page {
  id: root
  z : 0 // Explicitly setting this to lowest level so that messages displayed in Controls view will not get hidden behind plots
  property bool initialized : false
  property PhysiologyModel physiologyRequestModel
  property alias energyMetabolismSeries : energyMetabolismSeries
  property alias renalOverviewSeries : renalOverviewSeries 
  property alias vitalsGridView : vitalsGridView
  property alias cardiopulmonaryGridView : cardiopulmonaryGridView
  property alias bloodChemistryGridView : bloodChemistryGridView
  property alias energyMetabolismGridView : energyMetabolismSeries.energyMetabolismGridView
  property alias renalFluidBalanceGridView : renalFluidBalanceGridView
  property alias renalOverviewGridView : renalOverviewSeries.renalOverviewGridView
  property alias substanceGridView : substanceGridView
  property alias customGridView : customGridView
  property alias energyTimer : energyMetabolismSeries.energyTimer
  property alias renalTimer : renalOverviewSeries.renalTimer
  property alias tenHzPlotTimer : tenHzPlotTimer
  property alias fiveHzPlotTimer : fiveHzPlotTimer
  property alias oneHzPlotTimer : oneHzPlotTimer
  property alias everyFiveSecondsPlotTimer : everyFiveSecondsPlotTimer
  property alias everyTenSecondsPlotTimer : everyTenSecondsPlotTimer   
  signal urinalysisRequest()

  property Component simpleMenuComponent : simpleMenuComponent
  property Component nestedMenuComponent : nestedMenuComponent

  state : "realTime"

  // The states defined for GraphArea relate to the timers that trigger plot updates. During "RealTime", the slower timer triggers plot updates every 1 s (1 Hz),
  // while faster timer triggers every 0.1 s (10 Hz).  At maximum run rate, these refresh rates are multipled by factor of 5 (5 Hz for slow timer, 50 Hz for
  // fast timer) to keep up with BioGears metrics update rate.  By default, all plots are assigned to slower timer (see GraphArea.qml).  Only plots that
  // absolutely require a faster sampling rate for resolution (like Respiratory PV Curve) should connect plot to faster timer.
  states : [
    State {
      name : "realTime"
      PropertyChanges {
        target : tenHzPlotTimer;
        interval : 100
      }
      PropertyChanges {
        target : oneHzPlotTimer;
        interval : 1000
      }
    },
    State {
      name : "max"
      PropertyChanges {
        target : tenHzPlotTimer;
        interval : 20
      }
      PropertyChanges {
        target : oneHzPlotTimer;
        interval : 200
      }
    }
  ]
  header : RowLayout {
    id : headerBar
    Layout.fillWidth : true
    Layout.fillHeight : true
    Button {
      id : previous
      text : "Prev"
      display : AbstractButton.IconOnly
      icon.source : "qrc:/icons/prev.png"
      icon.name : "terminate"
      icon.color : "transparent"
      background : Rectangle {
        color : "transparent"
      }
      onClicked : {
        if (plots.currentIndex == 0) {
          plots.currentIndex = plots.count - 1;
        } else {
          plots.currentIndex = plots.currentIndex - 1
        }
        if (filterMenu.visible) { // This overrides the "CloseOnReleaseOutside" policy so that menu stays open when switching to new view panel
          filterMenu.open()
        }
      }
    }
    SwipeView {
      id : systemSwipeView
      clip : true
      Layout.fillWidth : true
      Layout.preferredWidth : 200
      Layout.preferredHeight : 40
      Repeater { 
        // contentHeight: 40
        Layout.fillWidth : true
        Layout.preferredWidth : 200
        Layout.preferredHeight : 40
        // font.pointSize: 12
        model : physiologyRequestModel
        delegate : UITabButtonForm {
          text : name
        }
      }
      currentIndex : plots.currentIndex
      onCurrentIndexChanged : {
        if (plots.currentIndex != currentIndex) {
          plots.currentIndex = currentIndex;
        }
      }
    }
    Button {
      id : filterMenuButton
      text : "Filter Menu"
      display : AbstractButton.IconOnly
      icon.source : "qrc:/icons/menu.png"
      icon.name : "terminate"
      icon.color : "transparent"
      onClicked : {
        let menuObject = menuInstantiator.objectAt(plots.currentIndex)
        if (menuObject.visible){
          menuObject.close()
        } else {
          menuObject.open()
        }
      }
      background : Rectangle {
        color : "transparent"
      }
      Instantiator {
        id : menuInstantiator
        model : PhysiologyModel.TOTAL_CATEGORIES
        delegate : Menu {
          visible : false
          x : -200
          y : 50
          Repeater {
            id : menuRepeater
            model : physiologyRequestModel.category(index)
            property int category : index
            function refreshSubstances() {
              
            }
            Component.onCompleted : {
              root.newActiveSubstances.connect(refreshSubstances)
            }
            delegate : Loader {
              id : menuLoader
              sourceComponent : {
                if (!model.nested){
                  return simpleMenuComponent
                } else if (menuRepeater.category == PhysiologyModel.SUBSTANCES){
                  if (model.usable){
                    return nestedMenuComponent
                  } else {
                    return null
                  }
                } else {
                  return nestedMenuComponent
                }
              }
              property Instantiator _parentMenu : menuInstantiator
              property int _category : menuRepeater.category
              property PhysiologyModel _model : physiologyRequestModel.category(_category)
              property var _item : _model.index(index, 0)
              property var _title: "%1".arg(_model.data(_item, Qt.DisplayRole))
              onLoaded : {
                if (_category == PhysiologyModel.SUBSTANCES){
                  //root.newActiveSubstances.connect(item.clearObjects)
                  //item.objectsCleared.connect(menuRepeater.refreshSubstances)
                }
              }
            }
          }
        }
        onObjectAdded : {object.parent = filterMenuButton}
        onObjectRemoved : {console.log('Removed menu--not desirable')}
      }
    }
    Button {
      id : next
      text : "Next"
      display : AbstractButton.IconOnly
      icon.source : "qrc:/icons/next.png"
      icon.name : "terminate"
      icon.color : "transparent"
      onClicked : {
        if (plots.currentIndex == plots.count - 1) {
          plots.currentIndex = 0;
        } else {
          plots.currentIndex = plots.currentIndex + 1
        }
        if (filterMenu.visible) { // This overrides the "CloseOnReleaseOutside" policy so that menu stays open when switching to new view panel
          filterMenu.open()
        }
      }
      background : Rectangle {
        color : "transparent"
      }
    }
  }//end header

    SwipeView {
        id : plots
        anchors.fill : parent
        currentIndex : 0
        clip : true
        Item {
            id : vitalsSeries
            Layout.fillWidth : true
            Layout.fillHeight : true
            Rectangle {
                id : vitalsBackground
                anchors.fill : parent
                color : "#7CB342"
            }
            GridView {
                id : vitalsGridView
                anchors.fill : parent
                clip : true
                cellWidth : parent.width / 2
                cellHeight : parent.height / 2
                model : vitalsModel
                ScrollBar.vertical : ScrollBar {
                    parent : vitalsGridView.parent
                    anchors.top : vitalsGridView.top
                    anchors.right : vitalsGridView.right
                    anchors.bottom : vitalsGridView.bottom
                }
            }
        }
        Item {
            id : cardiopulmonarySeries
            Layout.fillWidth : true
            Layout.fillHeight : true
            Rectangle {
                id : cardiovascularBackground
                anchors.fill : parent
                color : "#7CB342"
            }
            GridView {
                id : cardiopulmonaryGridView
                anchors.fill : parent
                clip : true
                cellWidth : plots.width / 2
                cellHeight : plots.height / 2
                model : cardiopulmonaryModel
                ScrollBar.vertical : ScrollBar {
                    parent : cardiopulmonaryGridView.parent
                    anchors.top : cardiopulmonaryGridView.top
                    anchors.right : cardiopulmonaryGridView.right
                    anchors.bottom : cardiopulmonaryGridView.bottom
                }
            }
        }
        Item {
            id : bloodChemistrySeries
            Layout.fillWidth : true
            Layout.fillHeight : true
            Rectangle {
                id : bloodChemistryBackground
                anchors.fill : parent
                color : "#7CB342"
            }
            GridView {
                id : bloodChemistryGridView
                anchors.fill : parent
                clip : true
                cellWidth : plots.width / 2
                cellHeight : plots.height / 2
                model : bloodChemistryModel
                ScrollBar.vertical : ScrollBar {
                    parent : bloodChemistryGridView.parent
                    anchors.top : bloodChemistryGridView.top
                    anchors.right : bloodChemistryGridView.right
                    anchors.bottom : bloodChemistryGridView.bottom
                }
            }
        }
        EnergyPanel {
            id : energyMetabolismSeries
            Layout.fillWidth : true
            Layout.fillHeight : true
            
        }
        Item {
            id : renalFluidBalanceSeries
            Layout.fillWidth : true
            Layout.fillHeight : true

            Rectangle {
                id : renalFluidBalanceBackground
                anchors.fill : parent
                color : "#7CB342"
            }
            GridView {
                id : renalFluidBalanceGridView
                anchors.fill : parent
                clip : true
                cellWidth : plots.width / 2
                cellHeight : plots.height / 2
                model : renalFluidBalanceModel
                ScrollBar.vertical : ScrollBar {
                    parent : renalFluidBalanceGridView.parent
                    anchors.top : renalFluidBalanceGridView.top
                    anchors.right : renalFluidBalanceGridView.right
                    anchors.bottom : renalFluidBalanceGridView.bottom
                }
            }
        }
        RenalPanel {
            id : renalOverviewSeries
            Layout.fillWidth : true
            Layout.fillHeight : true
            
            onUrinalysisRequest: {
              root.urinalysisRequest();
            }
        }
        Item {
            id : substanceSeries
            Layout.fillWidth : true
            Layout.fillHeight : true
            Rectangle {
                id : substanceBackground
                anchors.fill : parent
                color : "#7CB342"
            }
            GridView {
                id : substanceGridView
                anchors.fill : parent
                clip : true
                cellWidth : plots.width / 2
                cellHeight : plots.height / 2
                model : substanceModel
                ScrollBar.vertical : ScrollBar {
                    parent : substanceGridView.parent
                    anchors.top : substanceGridView.top
                    anchors.right : substanceGridView.right
                    anchors.bottom : substanceGridView.bottom
                }
            }
        }
        Item {
            id : customSeries
            Layout.fillWidth : true
            Layout.fillHeight : true
            Rectangle {
                id : customBackground
                anchors.fill : parent
                color : "#7CB342"
            }
            GridView {
                id : customGridView
                anchors.fill : parent
                clip : true
                cellWidth : plots.width / 2
                cellHeight : plots.height / 2
                model : customModel
                ScrollBar.vertical : ScrollBar {
                    parent : customGridView.parent
                    anchors.top : customGridView.top
                    anchors.right : customGridView.right
                    anchors.bottom : customGridView.bottom
                }
            }
        }
    }
    
    PageIndicator {
        id : indicator

        count : plots.count
        currentIndex : plots.currentIndex

        anchors.bottom : plots.bottom
        anchors.horizontalCenter : plots.horizontalCenter
    }

    Timer {
        id : tenHzPlotTimer
        interval : 100
        running : false
        repeat : true
        triggeredOnStart : true
    }

    Timer {
        id : fiveHzPlotTimer
        interval : 200
        running : false
        repeat : true
        triggeredOnStart : true
    }

    Timer {
        id : oneHzPlotTimer
        interval : 1000
        running : false
        repeat : true
        triggeredOnStart : true
    }

    Timer {
        id : everyFiveSecondsPlotTimer
        interval : 5000
        running : false
        repeat : true
        triggeredOnStart : true
    }

    Timer {
        id : everyTenSecondsPlotTimer
        interval : 10000
        running : false
        repeat : true
        triggeredOnStart : true
    }
    //Component used by Menu Instantiator to set up bottom-level menu items
    Component {
      id : simpleMenuComponent
      MenuItem {
        property var item : _item
        property var category : _category
        property var model : _model
        property var title : _title
        height : checkbox.height + 2
        CheckBox {
          id : checkbox
          checkable : true
          checked : model.data(item, PhysiologyModel.EnabledRole)
          text : model.data(item, PhysiologyModel.RequestRole)
          onClicked : {
            if (checked){
              model.setData(item, true, PhysiologyModel.EnabledRole)
              createPlotView(category, model, item, title)
            } else {
              model.setData(item, false, PhysiologyModel.EnabledRole)
              removePlotView(category, item.row, title)
            }
          }
        }
      }
    }
    //Component used by Menu Instantiator to set up nested sub-menus (calls to simpleMenuComponent to make bottome level items)
    Component {
      id : nestedMenuComponent
      Instantiator {
        id : nestedMenuItem
        property Instantiator parentMenu : _parentMenu
        property var bgData : _model
        property var entry : _item
        property var category : _category
        signal objectsCleared()
        function clearObjects() {
          active = false;
          //objectsCleared();
        }
        onCountChanged : {
          if (count == 0){
            console.log('done clearing')
            objectsCleared();
          }
        }
        function setObjects() {
          active = true;
        }
        delegate : Menu {
          id : subMenu
          title : _model.data(_item, PhysiologyModel.RequestRole)
          Repeater {
            id : subMenuRepeater
            model : DelegateModel {
              model : bgData
              rootIndex : entry
              delegate : Loader {
                property var _category : category
                property var _model : nestedMenuItem.bgData
                property var _item : nestedMenuItem.bgData.index(index, 0, entry) //{ let temp = nestedMenuItem.bgData.index(index, 0, entry); console.log(_model.data(temp, PhysiologyModel.RequestRole)); return temp}
                property var _title : "%1 - %2".arg(nestedMenuItem.bgData.data(entry, Qt.DisplayRole))
                                                .arg(nestedMenuItem.bgData.data(_item, Qt.DisplayRole))
                sourceComponent : simpleMenuComponent
              }
            }
          }
        }
        onObjectAdded : {
          console.log('Adding ' + object.title, index)
          parentMenu.objectAt(PhysiologyModel.SUBSTANCES).addMenu(object)
                  
        }
        onObjectRemoved : {
          console.log('Removing ' + object.title)
          parentMenu.objectAt(PhysiologyModel.SUBSTANCES).removeMenu(object)
        }
      }
    }
  }

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/

