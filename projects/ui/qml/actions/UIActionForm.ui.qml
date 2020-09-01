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

  signal activate()
  signal deactivate()
  signal remove( string uuid )
  signal adjust( var list)
  signal selected()     //notifies action model in scenario builder that this action has been clicked on (for highlighting/moving purposes)
  signal buildSet(var action)

  property Scenario scenario
  property string buildParams : ""
  property bool queued : false        //Has the action been added to the scenario queue yet in build mode?
  property string actionType : "UnSet"
  property int actionClass : -1
  property int actionSubClass : -1
  property string uuid : ""
  property bool active : false
  property bool collapsed : true
  property bool builderMode : false
  property bool currentSelection : false
  property double actionStartTime_s : 0.0        //Time at which this action will be applied (in Scenario Builder)
  property double actionDuration_s : 0.0          //Length of time over which action will be applied
  property Loader viewLoader : loader
  property alias timeEntry : timeEntry


  property string fullName  : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>] <br> Intensity = %3".arg(actionType).arg("Identifier").arg("Value")
  property string shortName : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>]".arg(actionType).arg("Identifier")

  //This state controls whether the highlighting of the rectangle containing this action.  It is used in scenario builder to help users move actions up/down
  // queue and select action for removal.
  //state : viewLoader.status==Loader.Ready ? viewLoader.item.state : "" 
  states : [
     State {
        name: "expandedViewUnselected"; when : (builderMode && !currentSelection && !collapsed)
        PropertyChanges { target : root; border.color : "black"; border.width : 1}
      }
      ,State {
        name: "expandedViewSelected"; when : (builderMode && currentSelection && !collapsed)
        PropertyChanges { target : root; border.color : "green"; border.width : 2}
      }
      ,State {
        name : "noBorder"; when : (builderMode && collapsed)
        PropertyChanges { target : root; border.width : 0}
      }
  ]

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
        font.pointSize : 8
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
              selected()
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
        height : 20

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
        PropertyChanges { target : buildSummaryWrapper; border.color : "black"}
      }
      ,State {
        name: "collapsedViewSelected"; when : (root.builderMode && root.currentSelection && root.collapsed)
        PropertyChanges { target : buildSummaryWrapper; border.color : "green"}
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
  onActiveChanged : {
    if ( active) {
      root.activate()
    } else {
      root.deactivate();
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
        selected()
      }

      onDoubleClicked: { // Double Clicking Window
        if ( mouse.button === Qt.LeftButton ){
          if (builderMode){
            if ( loader.state === "collapsedBuilder") {
              loader.state = "expandedBuilder"
            } else {
              //Not allowing double click to expand right now -- use "Set Action" button instead so that we can check that action is defined in build mode
              //loader.state = "collapsed"
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
          text : "Remove"
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
    id : timeEntry
    RowLayout {
      signal timeUpdated (int seconds, int minutes, int hours)
      signal clear ()
      signal reload (int totalTime_s) 
      property int seconds : 0
      property int minutes : 0
      property int hours : 0
      property string entryName : ""
      onHoursChanged : {
        if (hours !== Number.fromLocaleString(hoursField.text)){
          hoursField.text = Number(hours).toLocaleString()
        }
        timeUpdated(seconds, minutes, hours)
      }
      onMinutesChanged : {
        if (minutes !== Number.fromLocaleString(minutesField.text)){
          minutesField.text = Number(minutes).toLocaleString()
        }
        timeUpdated(seconds, minutes, hours)
      }
      onSecondsChanged : {
        if (seconds !== Number.fromLocaleString(secondsField.text)){
          secondsField.text = Number(seconds).toLocaleString()
        }
        timeUpdated(seconds, minutes, hours)
      }
      onClear : {
        hoursField.clear()
        minutesField.clear()
        secondsField.clear()
        seconds = 0
        minutes = 0
        hours = 0
      }
      onReload : {
        hours = Math.floor(totalTime_s / 3600)
        minutes = Math.floor((totalTime_s - hours * 3600) / 60)
        seconds = totalTime_s - hours * 3600 - minutes * 60
      }

      Label {
        Layout.alignment : Qt.AlignCenter
        verticalAlignment : Text.AlignVCenter
        text : entryName
        font.pixelSize : 15
        Layout.fillHeight : true
      }
      TextField {
        id : hoursField
        placeholderText : "0"
        Layout.preferredWidth : 25
        Layout.fillHeight : true
        Layout.preferredHeight : implicitHeight
        topPadding : 16
        font.pixelSize : 15
        Layout.alignment : Qt.AlignRight | Qt.AlignBottom
        verticalAlignment : TextInput.AlignBottom
        horizontalAlignment : TextInput.AlignHCenter
        validator : IntValidator {
          bottom : 0
        }
        onTextEdited : {
          if (text===""){
              parent.hours = 0
          } else if(acceptableInput){
              parent.hours = Number.fromLocaleString(text)
          }
        }
      }
      Label {
        text : "H"
        font.pixelSize : 15
        Layout.alignment : Qt.AlignLeft | Qt.AlignCenter
        rightPadding : 10
      }
      TextField {
        id : minutesField
        placeholderText : "0"
        Layout.preferredWidth : 25
        Layout.fillHeight : true
        Layout.preferredHeight : implicitHeight
        topPadding : 16
        font.pixelSize : 15
        Layout.alignment : Qt.AlignRight | Qt.AlignBottom
        verticalAlignment : TextInput.AlignBottom
        horizontalAlignment : TextInput.AlignHCenter
        validator : IntValidator {
          bottom : 0
        }
        onTextEdited : {
          if (text ===""){
              parent.minutes = 0
          } else if (acceptableInput){
            let minutesInput = Number.fromLocaleString(text)
            if (minutesInput > 60){
              let hoursToAdd = Math.floor(minutesInput / 60)
              minutesInput = minutesInput % 60
              parent.hours += hoursToAdd
              text = Number(minutesInput).toLocaleString()
            }
            parent.minutes = minutesInput
          }
        }
      }
      Label {
        text : "M"
        font.pixelSize : 15
        Layout.alignment : Qt.AlignLeft
        rightPadding : 10
      }
      TextField {
        id : secondsField
        placeholderText : "0"
        Layout.preferredWidth : 25
        Layout.fillHeight : true
        Layout.preferredHeight : implicitHeight
        font.pixelSize : 15
        topPadding : 16
        Layout.alignment : Qt.AlignRight | Qt.AlignBottom
        verticalAlignment : TextInput.AlignBottom
        horizontalAlignment : TextInput.AlignHCenter
        validator : IntValidator {
          bottom : 0
        }
        onTextEdited : {
          if (text === ""){
              parent.seconds = 0
          } else if (acceptableInput){
            let secondsInput = Number.fromLocaleString(text)
            if (secondsInput > 60){
              let minutesToAdd = Math.floor(secondsInput / 60)
              secondsInput = secondsInput % 60
              parent.minutes += minutesToAdd
              text = Number(secondsInput).toLocaleString()
            }
            parent.seconds = secondsInput
          }
        }
      }
      Label {
        text : "S"
        font.pixelSize : 15
        Layout.alignment : Qt.AlignLeft
      }
    }
  }
}