import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

Rectangle {
  id: root
  color: "transparent"
  border.color: "black"
  height : viewLoader.item.height
  radius : builderMode ? 10 : 0
 
  signal activate()
  signal deactivate()
  signal remove( string uuid )
  signal adjust( var list)
  signal selected(int index)     //notifies action model in scenario builder that this action has been clicked on (for highlighting/moving purposes)
  signal editing(int index)      //notifies action model that this action is being edited so that other actions in scenario window fade in opacity
  signal buildSet(var action)    //notifies action model in scenario builer that this action has all parameters set

  property Scenario scenario
  property string buildParams : ""
  property string actionType : "UnSet"
  property int actionClass : -1
  property int actionSubClass : -1
  property string uuid : ""
  property bool active : false
  property bool collapsed : true
  property bool builderMode : false
  property bool autoRun : false             //If true, action will turn on/off action according to start time, duration, and current sim time
  property bool currentSelection : false
  property int modelIndex : -1
  property double actionStartTime_s : 0.0        //Time at which this action will be applied (in Scenario Builder)
  property double actionDuration_s : 0.0          //Length of time over which action will be applied
  property Loader viewLoader : loader
  property alias timeEntry : timeEntry
  property alias comboInput : comboInput


  property string fullName  : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>] <br> Intensity = %3".arg(actionType).arg("Identifier").arg("Value")
  property string shortName : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>]".arg(actionType).arg("Identifier")

  ListView.onAdd : { 
    //If auto run mode, connect the checkActionStatus function to the sim time changed signal
    // emitted by attached ListView property
    if (autoRun){
      ListView.view.simTimeChanged.connect(checkActionStatus)
    }
  }
  ListView.onRemove : {
    if (autoRun){
      ListView.view.simTimeChanged.disconnect(root.checkActionStatus)
    }
  }

  //This state controls whether the highlighting of the rectangle containing this action.  It is used in scenario builder to help users move actions up/down
  // queue and select action for removal.
  states : [
     State {
        name: "expandedViewUnselected"; when : (builderMode && !currentSelection && !collapsed)
        PropertyChanges { target : root; border.color : "black"; border.width : 1}
      }
      ,State {
        name: "expandedViewSelected"; when : (builderMode && currentSelection && !collapsed)
        PropertyChanges { target : root; border.color : "#4CAF50"; border.width : 3}
      }
      ,State {
        name : "noBorder"; when : (builderMode && collapsed)
        PropertyChanges { target : root; border.width : 0}
      }
  ]

  onActiveChanged : {
    if ( active) {
      root.activate()
    } else {
      root.deactivate();
    }
  }
  function checkActionStatus(value){
    //simTime variable emitted by ControlsForm:ActionSwitchView during auto run mode
    let simTime = ListView.view.simTime
    if (!active && simTime > actionStartTime_s && simTime < actionStartTime_s + actionDuration_s){
      active = true;
    }
    if (active && simTime > actionStartTime_s + actionDuration_s){
      active = false;
    }
  }

  property Component controlsDetails
  property Component builderDetails
  property Component controlsSummary : Component {
    RowLayout {
      id : actionRow
      spacing : 5
      height : childrenRect.height
      width : root.width
      Label {
        id : actionLabel
        width : parent.width * 3/4 - actionRow.spacing / 2
        color : '#1A5276'
        text : root.shortName
        elide : Text.ElideRight
        font.pointSize : 9
        font.bold : true
        horizontalAlignment  : Text.AlignLeft
        leftPadding : 5
        verticalAlignment : Text.AlignVCenter
        background : Rectangle {
            id : labelBackground
            anchors.fill : parent
            color : 'transparent'
            border.color : 'grey'
            border.width : 0
        }
        MouseArea {
            id : labelMouseArea
            anchors.fill : parent
            hoverEnabled : true
            propagateComposedEvents :true
            Timer {
              id : infoTimer
              interval: 500; running: false; repeat: false
              onTriggered:  actionTip.visible  = true
            }
            onClicked : {
              selected(modelIndex)
            }
            onEntered: {
              infoTimer.start()
              actionTip.visible  = false
            }
            onPositionChanged : {
              infoTimer.restart()
              actionTip.visible  = false
            }
            onExited : {
              infoTimer.stop()
              actionTip.visible  = false
            }
        }
        ToolTip {
          id : actionTip
          parent : actionLabel
          x : 0
          y : parent.height + 5
          visible : false
          text : root.fullName
          contentItem : Text {
            text : actionTip.text
            color : '#1A5276'
            font.pointSize : 10
          }
          background : Rectangle {
            color : "white"
            border.color : "black"
          }
        }
      }
      Rectangle {
        Layout.fillWidth : true
      }
      Rectangle {
        id: toggle
        width  : 40
        height : actionLabel.height + 10
        border.color : "blue"
        color:        root.active? 'green': 'red' // background
        opacity:      active  &&  !mouseArea.pressed? 1: 0.3 // disabled/pressed state

        Text {
          text:  root.active?    'On': 'Off'
          color:  'white'
          horizontalAlignment : Text.AlignHCenter
          anchors.centerIn : parent
          font.pixelSize: 0.5 * toggle.height

        }
        MouseArea {
          id: mouseArea
          anchors.fill: parent
          onClicked: {
            root.active = !root.active
          }// emit
        }
      }
    }
  } // End Summary Component

  property Component builderSummary : Component {
    Rectangle {
      id : buildSummaryWrapper
      width : root.width / 3
      border.width : 2
      height : 40
      radius : 15
      states : [
      State {
        name: "collapsedViewUnselected"; when : (root.builderMode && !root.currentSelection && root.collapsed)
        PropertyChanges { target : buildSummaryWrapper; border.color : "black"; border.width : 2}
      }
      ,State {
        name: "collapsedViewSelected"; when : (root.builderMode && root.currentSelection && root.collapsed)
        PropertyChanges { target : buildSummaryWrapper; border.color : "#4CAF50"; border.width : 3}
      }
    ]
      Label {
        id : buildSummaryLabel
        height : buildSummaryWrapper.height
        width : buildSummaryWrapper.width
        horizontalAlignment : Text.AlignHCenter
        verticalAlignment : Text.AlignVCenter
        text : root.shortName
        font.pixelSize : 18
        background : Rectangle {
          id : labelBackground
          width : parent.width
          height : buildSummaryWrapper.height
          color : "transparent"
        }
      }
    }
  }

  Loader {
    id : loader

    sourceComponent : controlsSummary
    state  : "collapsedControls"
    states : [
      State {
        name: "expandedControls"
        PropertyChanges { target : loader; sourceComponent: controlsDetails}
        PropertyChanges { target : root; collapsed : false}
      }
      ,State {
        name : "expandedBuilder"
        PropertyChanges {target : loader; sourceComponent : builderDetails}
        PropertyChanges { target : root; collapsed : false}
      }
      ,State {
        name: "collapsedControls"
        PropertyChanges { target : loader; sourceComponent: controlsSummary}
        PropertyChanges { target : root; collapsed : true}
      }
      ,State {
        name: "collapsedBuilder"
        PropertyChanges { target : loader; sourceComponent : builderSummary}
        PropertyChanges { target : root; collapsed : true}
        AnchorChanges { target : loader; anchors.horizontalCenter : root.horizontalCenter}
      }
      ,State {
        name: "unset"
        PropertyChanges {target : loader; sourceComponent : undefined}
      }
    ]

    MouseArea {
      id: actionMouseArea
      anchors.fill: parent
      z: -1
      acceptedButtons:  Qt.LeftButton | Qt.RightButton
      
      onClicked : {
        if ( mouse.button == Qt.RightButton) {
          contextMenu.popup()
        }
        selected(root.modelIndex)
      }

      onDoubleClicked: { // Double Clicking Window
        if ( mouse.button === Qt.LeftButton ){
          if (builderMode){
            if ( loader.state === "collapsedBuilder") {
              loader.state = "expandedBuilder"
              root.editing(root.modelIndex)
            }
          } else {
            if ( loader.state === "collapsedControls") {
              loader.state = "expandedControls"
            } else {
              loader.state = "collapsedControls"
            }
          }
        } else {
          mouse.accepted = false
        }
      }

      Menu {
        id : contextMenu
        MenuItem {
          visible : !builderMode
          height : builderMode ? 0 : removeItem.height
          text : (loader.state === "collapsedControls")? "Configure" : "Collapse"
          onTriggered: {
            //Only using this in controls instance (not in builder mode)
            if (!builderMode) {
              if ( loader.state === "collapsedControls") {
                loader.state = "expandedControls"
              } else {
                loader.state = "collapsedControls"
              }
            }
          }
        }
        MenuItem {
          id : removeItem
          text : "Remove"
          font.pointSize : root.builderMode ? 10 : 6
          onTriggered: {
            if (root.active){
              root.deactivate()
            }
            root.remove( root.uuid )
          }
        }
      }
    }
  }
  Component {
    id : comboInput
    ComboBox {
      id : comboBox
      property var initialValue : _initial_value
      currentIndex : setCurrentIndex()
      bottomInset : 5
      topInset : 5
      model : _combo_model
      flat : false
      contentItem : Text {
        width : comboBox.width
        height : comboBox.height
        text : comboBox.displayText
        font.pixelSize : 18
        verticalAlignment : Text.AlignVCenter
        horizontalAlignment : Text.AlignHCenter
      }
      delegate : ItemDelegate {
        width : comboBox.popup.width
        contentItem : Text {
          width : parent.width
          text : modelData
          font.pixelSize : 18
          verticalAlignment : Text.AlignVCenter
          horizontalAlignment : Text.AlignHCenter
          }
        background : Rectangle {
          anchors.fill : parent
          color : "transparent"
          border.color : "#4CAF50"
          border.width : comboBox.highlightedIndex === index ? 2 : 0
        }
      }
      popup : Popup {
        y : comboBox.height
        x : 0
        padding : 0
        width : comboBox.width - comboBox.indicator.width
        implicitHeight : contentItem.implicitHeight
        contentItem : ListView {
          clip : true
          implicitHeight : contentHeight
          model : comboBox.popup.visible ? comboBox.delegateModel : null
          currentIndex : comboBox.highlightedIndex
        }
      }
      background : Rectangle {
        id : comboBackground
        //Height and width of this rectangle established by Layout preferred dimensions assigned in Loader
        implicitHeight : 40
        border.color : "black"
        border.width : 1
      }
      function setCurrentIndex(){
        for (let i = 0; i < model.length; ++i){
          if (model[i]===_initial_value){
            return i;
          }
        }
        return -1;
      }
    }
  }


  Component {
    id : timeEntry
    RowLayout {
      id : timeInput
      signal timeUpdated (int totalTime_s)
      signal clear ()
      signal reload (int totalTime_s)
      property string entryName : ""
      property int time_s : 0
      onClear : {
        //timeField.text = "00:00:00"
        time_s = 0
      }
      onReload : {
        timeField.text = seconds_to_clock_time(totalTime_s)
        time_s = totalTime_s
      }
      Label {
        Layout.alignment : Qt.AlignCenter
        verticalAlignment : Text.AlignVCenter
        text : entryName + ":  "
        font.pixelSize : 18
        Layout.fillHeight : true
      }
      TextInput {
        id : timeField
        property int lastPosition : -1
        text : seconds_to_clock_time(timeInput.time_s)
        overwriteMode : true
        maximumLength : 8
        font.pixelSize : 18
        anchors.bottomMargin : 2
        cursorDelegate : Rectangle {
          visible : parent.cursorVisible
          width :  parent.cursorRectangle.width
          color : "blue"
          opacity : 0.3
        }
        Rectangle {
          width : parent.width
          height : 2
          anchors.bottom : parent.bottom
          color : parent.activeFocus ? "blue" : "black"
        }
        Keys.onPressed : {
          //Prevent user from deleting time--only allow overwriting
          if (event.key == Qt.Key_Backspace || event.key == Qt.Key_Delete || event.key == Qt.Key_Space){
            event.accepted = true   //accepting swallows the key event and keeps it local to this Keys block, meaning it won't get propagated up to text input
          } else {
            event.accepted = false
          }
        }
        onCursorPositionChanged : {
          if (text[cursorPosition] == ':'){
            if (cursorPosition > timeField.lastPosition){
              //Moving left
              ++cursorPosition;
            }
            else {
              //Moving right
              --cursorPosition
            }
          }
          lastPosition = cursorPosition
        }
        onTextEdited : {
          time_s = clock_time_to_seconds(text)
          timeInput.timeUpdated(time_s)
        }
        function seconds_to_clock_time(time_s) {
          var v_seconds = time_s % 60
          var v_minutes = Math.floor(time_s / 60) % 60
          var v_hours   = Math.floor(time_s / 3600)

          v_seconds = (v_seconds<10) ? "0%1".arg(v_seconds) : "%1".arg(v_seconds)
          v_minutes = (v_minutes<10) ? "0%1".arg(v_minutes) : "%1".arg(v_minutes)
          v_hours = (v_hours < 10) ? "0%1".arg(v_hours) : "%1".arg(v_hours)

          return "%1:%2:%3".arg(v_hours).arg(v_minutes).arg(v_seconds)
        }
        function clock_time_to_seconds(timeString){
          let timeUnits = timeString.split(':');    //splits into [hh, mm, ss]
          try {
            let hours = Number.fromLocaleString(timeUnits[0])
            let minutes = Number.fromLocaleString(timeUnits[1])
            let seconds = Number.fromLocaleString(timeUnits[2])
            if (hours < 0.0 || minutes < 0.0 || seconds < 0.0){
              throw "Negative time"
            }
            return 3600 * hours + 60 * minutes + seconds;
          } catch (err){
            return null
          }
        }
      }
    }
  }
}