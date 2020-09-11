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
            Repeater { // contentHeight: 40
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
            if (filterMenu.visible) {
              filterMenu.close()
            } else {
              filterMenu.open()
            }
          }
          background : Rectangle {
            color : "transparent"
          }
          Menu {
            id: filterMenu
            x : -50
            y : 50
            spacing: 0
            padding: 0
            margins: 0
            closePolicy : Popup.CloseOnEscape | Popup.CloseOnReleaseOutside
            StackLayout  {
              id: filterMenuView
              currentIndex:plots.currentIndex
              height : children[currentIndex].height +  10
              width :  children[currentIndex].width + 2
        
              Repeater {
                model : physiologyRequestModel
                delegate : ColumnLayout {
                  property int curCategory : index
                  width : childrenRect.width
                  height : childrenRect.height
                  Layout.preferredHeight: childrenRect.height
                  Layout.preferredWidth: childrenRect.width
                  Layout.maximumWidth: childrenRect.width
                  Layout.maximumHeight: childrenRect.height
                  spacing : 1
                  Repeater {
                                          // !
                      // ! Component for Selecting a Data Request.
                      // ! Creates a checkbox which activates a plot when clicked
                      // ! Covers signle and multiplots
                      Component {
                          id : singleItemComponent
                          MenuItem {
                              height : checkbox.height + 2
                              CheckBox {
                                  id : checkbox
                                  checkable : true
                                  checked : _model.data(_item, PhysiologyModel.EnabledRole)
                                  text :    _model.data(_item, PhysiologyModel.RequestRole) 
                                  onClicked : {
                                      if (checked) {
                                          _model.setData(_item, true, PhysiologyModel.EnabledRole)
                                          createPlotView(_category, _model, _item, _title)
                                      } else {
                                          _model.setData(_item, false, PhysiologyModel.EnabledRole)
                                          removePlotView(_category, _item.row, _title)
                                      }
                                  }
                                  Component.onCompleted: {
                                      console.log("Creating %1".arg(_title))
                                      if (checked ) {
                                        createPlotView(_category, _model, _item, _title)
                                      }
                                  }
                              }
                          }
                      }
                     
                      // ! When a item is nested like substances
                      // ! We want to be able to select individual data request
                      // ! Under a nested menu to plot multiple single plots
                      Component {
                          id : categorySelectionComponent
                          Button {
                            id: buttonMenu

                            property var bgData : _model
                            property var entry : _item
                            property int category : _category

                            text : _title
                                    
                            contentItem: Label {
                                text: buttonMenu.text + ">"
                                font: buttonMenu.font
                                font.pixelSize : 10
                                verticalAlignment: Text.AlignVCenter
                            }

                            width :  200 
                            height : buttonMenu.pixelSize
                            anchors.right : parent.right

                            background: Rectangle {
                                anchors.fill : parent
                                border.color: "blue"
                                opacity: 0.3
                                color : buttonMenu.down ? "#555555" : "#111111"
                            }

                            MouseArea {
                              anchors.fill: parent
                              acceptedButtons: Qt.LeftButton | Qt.RightButton

                              onClicked: {
                                  if (mouse.button === Qt.LeftButton)
                                      substanceMenu.open()
                              }

                              Menu {
                                id : substanceMenu
                                x : -implicitWidth
                                y: 0
                                Repeater {
                                  id : componentMenu
                                  model : DelegateModel {
                                    model : _model
                                    rootIndex : _model.index(index, 0)
                                    delegate : Loader {
                                      property int _category : buttonMenu.category
                                      property var _model: buttonMenu.bgData
                                      property var _item:  buttonMenu.bgData.index(index,0,buttonMenu.entry)
                                      property var _title: "%1 - %2".arg(buttonMenu.bgData.data(entry, Qt.DisplayRole))
                                                                    .arg(buttonMenu.bgData.data(_item, Qt.DisplayRole))
                                      sourceComponent : singleItemComponent
                                    }
                                  }
                                }
                              }
                            }
                          }
                      }                                                       
                    model : physiologyRequestModel.category(curCategory)
                    delegate : Loader {
                            property int _category : curCategory
                            property var             _current : model
                            property PhysiologyModel _model : physiologyRequestModel.category(_category)
                            property var             _item  : _model.index(index, 0)
                            property var _title: "%1".arg(_model.data(_item, Qt.DisplayRole))
                            sourceComponent : {
                              if (!model.nested) {
                                  return singleItemComponent
                              } else { 
                                  return categorySelectionComponent
                              }
                            }
                          }
                  }
                }
              }
            }   
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
    }

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
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/

