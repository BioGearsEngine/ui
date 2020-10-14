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
  property PhysiologyModel physiologyRequestModel
  property Component requestMenuComponent : requestMenuComponent
  property Component requestMenuItemComponent : requestMenuItemComponent
  property alias energyMetabolismSeries : energyMetabolismSeries
  property alias renalSeries : renalSeries 
  property alias vitalsGridView : vitalsGridView
  property alias cardiovascularGridView : cardiovascularGridView
  property alias bloodChemistryGridView : bloodChemistryGridView
  property alias energyMetabolismGridView : energyMetabolismSeries.energyMetabolismGridView
  property alias respiratoryGridView : respiratoryGridView
  property alias renalGridView : renalSeries.renalGridView
  property alias substanceGridView : substanceGridView
  property alias customGridView : customGridView
  property alias energyTimer : energyMetabolismSeries.energyTimer
  property alias renalTimer : renalSeries.renalTimer
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
  header : Rectangle {
    id : headerBar
    width : parent.width
    border.width : 0
    height : 40
    color : "#2980b9"
    Rectangle {
      id : previous
      color : "transparent"
      height : parent.height
      width : 40
      anchors.left : parent.left
      Image {
        anchors.centerIn : parent
        source : "icons/prev_transparent.png"
        width : parent.width * 0.8
        fillMode : Image.PreserveAspectFit
        MouseArea {
          anchors.fill : parent
          cursorShape : Qt.PointingHandCursor
          onClicked : {
            if (plots.currentIndex == 0) {
              plots.currentIndex = plots.count - 1;
            } else {
              plots.currentIndex = plots.currentIndex - 1
            }
          }
        }
      }
    }
    SwipeView {
      id : systemSwipeView
      clip : true
      anchors.left : previous.right
      anchors.right : next.right
      height : parent.height
      Repeater {
        anchors.fill : parent
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
    Rectangle {
      id : next
      color : "transparent"
      height : parent.height
      width : 40
      anchors.right : filterMenuButton.left
      anchors.rightMargin : 15
      Image {
        anchors.centerIn : parent
        source : "icons/next_transparent.png"
        width : parent.width * 0.8
        fillMode : Image.PreserveAspectFit
        MouseArea {
          anchors.fill : parent
          cursorShape : Qt.PointingHandCursor
          onClicked : {
            if (plots.currentIndex == plots.count - 1) {
              plots.currentIndex = 0;
            } else {
              plots.currentIndex = plots.currentIndex + 1
            }
          }
        }
      }
    }
    Rectangle {
      id : filterMenuButton
      color : "transparent"
      height : parent.height
      width : 40
      anchors.right : parent.right
      Image {
        anchors.centerIn : parent
        source : "icons/menu_transparent.png"
        sourceSize.width : parent.width
        sourceSize.height : parent.height * 0.8
        MouseArea {
          anchors.fill : parent
          cursorShape : Qt.PointingHandCursor
          onClicked : {
            let menuObject = menuInstantiator.objectAt(plots.currentIndex).item
            if (menuObject.visible){          
              menuObject.close()        
            } else {          
              menuObject.open()        
            }      
          }
        }
      }
      Instantiator {
        id : menuInstantiator
        model : DelegateModel {
          id : menuModel
          model : physiologyRequestModel
          //root index defaults to top level
          delegate : Loader  {
            id : menuLoader
            x : -50
            y : 50
            property var _model_data : root.physiologyRequestModel
            property var _node_index : menuModel.modelIndex(index)
            property int _category : index
            property string _info : ""
            property int _level : 0
            sourceComponent : requestMenuComponent
          }
        }
        onObjectAdded : {
          object.parent = filterMenuButton
          if (index == PhysiologyModel.SUBSTANCES){
            root.newActiveSubstance.connect(object.item.activateObject)
          }
        }
        onObjectRemoved : {console.log('Removed menu--not desirable behavior')}
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
        color : "#ecf0f1"
      }
      GridView {
        id : vitalsGridView
        anchors.fill : parent
         anchors.bottomMargin : 20
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
      id : cardiovascularSeries
      Layout.fillWidth : true
      Layout.fillHeight : true
      Rectangle {
        id : cardiovascularBackground
        anchors.fill : parent
        color : "#ecf0f1"
      }
      GridView {
          id : cardiovascularGridView
          anchors.fill : parent
          clip : true
          cellWidth : plots.width / 2
          cellHeight : plots.height / 2
          model : cardiovascularModel
          ScrollBar.vertical : ScrollBar {
            parent : cardiovascularGridView.parent
            anchors.top : cardiovascularGridView.top
            anchors.right : cardiovascularGridView.right
            anchors.bottom : cardiovascularGridView.bottom
          }
      }
    }
    Item {
      id : respiratorySeries
      Layout.fillWidth : true
      Layout.fillHeight : true
      Rectangle {
        id : respiratoryBackground
        anchors.fill : parent
        color : "#ecf0f1"
      }
      GridView {
        id : respiratoryGridView
        anchors.fill : parent
        clip : true
        cellWidth : plots.width / 2
        cellHeight : plots.height / 2
        model : respiratoryModel
        ScrollBar.vertical : ScrollBar {
          parent : respiratoryGridView.parent
          anchors.top : respiratoryGridView.top
          anchors.right : respiratoryGridView.right
          anchors.bottom : respiratoryGridView.bottom
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
        color : "#ecf0f1"
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
    RenalPanel {
      id : renalSeries
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
        color : "#ecf0f1"
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
        color : "#ecf0f1"
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
    id : requestMenuComponent
    Menu {
      id : requestMenu
      property var modelData : _model_data
      property var nodeIndex : _node_index
      property var category : _category
      property string info : _info
      property int level : _level
      property bool menuItem : false
      title : level > 0 ? modelData.data(nodeIndex, PhysiologyModel.DisplayRole) : ""   //Don't display a title for top level (e.g. "Vitals", "cardiovascular", ...)
      function activateObject(objectIndex){
        //This function is currently only connected to a signal in the Substances menu (see MenuInstantiator)
        requestInstantiator.activateObject(objectIndex)
      }
      Instantiator {
        id : requestInstantiator
        signal objectActivated(var object, string role)
        model : DelegateModel {
          id : requestDelegate
          model : requestMenu.modelData
          rootIndex : requestMenu.nodeIndex
          delegate : Loader {
            id : menuLoader
            property var _model_data : requestMenu.modelData
            property var _node_index : requestDelegate.modelIndex(index)
            property var _category : requestMenu.category
            property var _level : requestMenu.level + 1
            property string _info : requestMenu.info + _model_data.data(_node_index, PhysiologyModel.DisplayRole) + " - "
            sourceComponent : {
              if (_model_data.data(_node_index, PhysiologyModel.NestedRole)){
                return requestMenuComponent
              } else {
                return requestMenuItemComponent
              }
            }
          }
        }
        onObjectAdded : {
          if (object._model_data.data(object._node_index, PhysiologyModel.UsableRole)){
            //Only add the object to the menu if its usable role is true.  This signal will only be emitted when patient state is changed, because the instantiator only adds 
            // objects when the model changes (PhysiologyModel constant for a given patient state). Note that this means that Instantiator owns all objects that *could* be added 
            // to menu over scenario lifetime, but only objects explicity added to menu will be displayed.  Thus, to add sub-menus / menu items during runtime, we will use the custom 
            // "objectActivated" signal.  
            if (object.item.menuItem){
              requestMenu.addItem(object.item)
              root.onNewPhysiologyModel.connect(object.item.toggleEnabled)
            } else {
              requestMenu.addMenu(object.item)
            }   
          }  
        }
        onObjectActivated : {
          //Insert subMenu into parent menu alphabetically
          let insertIndex = 0
          while (insertIndex < requestMenu.count && requestMenu.menuAt(insertIndex).title < role){
            ++insertIndex;
          }
          requestMenu.insertMenu(insertIndex, object.item)
        }
        onObjectRemoved : {
          if (object.item.menuItem){
            requestMenu.removeItem(object.item)
          } else {
            object.item.releaseObjects()
            requestMenu.removeItem(object.item)
          }
        }
        function activateObject(subIndex){
          for (let i = 0; i < count; ++i){
            //Search across all the objects in the Substance instantiator (only called when we are in the Substances menu)
            //We compare the name role of the indicated QModelIndex (subIndex) -- which has just had it's "usable" role changed to TRUE -- 
            // to each of the instantiated objects. When we find it, we emit "objectActivated" signal so that instantiator knows to insert
            // the menu associated with this substance into the Substance menu. We will need to implement a tree-search algorithm if we have
            // other menus with nested roles who's usable role can change from false to true
            let object = objectAt(i)
            let objectRole = modelData.data(object.item.nodeIndex, PhysiologyModel.DisplayRole)
            let compRole = modelData.data(subIndex, PhysiologyModel.DisplayRole)
            if (compRole == objectRole){
              objectActivated(object, objectRole)
              break;
            }
          }
        }
      }
    }
  }
  //Component used by Menu Instantiator to set up nested sub-menus (calls to simpleMenuComponent to make bottome level items)
  Component {
    id : requestMenuItemComponent
    MenuItem {
      id : requestMenuItem
      height : checkbox.height + 2
      property var modelData : _model_data
      property var item : _node_index
      property int category : _category
      property int level : _level
      property string info : _info
      property string title : info.slice(0,-3)    //chops the trailing " - " sequence off the info string
      property bool menuItem : true
      property PhysiologyModel bgModel : modelData.category(_category)
      function toggleEnabled() {
        if (checkbox.checked != modelData.data(item, PhysiologyModel.EnabledRole)){
          checkbox.checked = modelData.data(item, PhysiologyModel.EnabledRole)
          if (checkbox.checked){
            createPlotView(category, bgModel, item, title)
          } else {
            removePlotView(category, item.row, title)
          }
        }
      }
      CheckBox {
        id : checkbox
        checkable : true
        checked : false     //Menu items that need to be initialized to checked = true handled by connection between newPhysiologyModel and toggleEnabled()
        text : modelData.data(item, PhysiologyModel.DisplayRole)
        onClicked : {
          if (checked){
            modelData.setData(item, true, PhysiologyModel.EnabledRole)
            createPlotView(category, bgModel, item, title)
          } else {
            modelData.setData(item, false, PhysiologyModel.EnabledRole)
            removePlotView(category, item.row, title)
          }
        }
      }
    }
  }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/

