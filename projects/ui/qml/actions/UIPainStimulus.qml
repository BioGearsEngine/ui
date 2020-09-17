import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

UIActionForm {
  id: root
  color: "transparent"
  border.color: "black"

  property double intensity : 0.0
  property string location : ""
  property bool validBuildConfig : (intensity > 0.0 && location !=="" && actionStartTime_s > 0.0)
  
  actionType : "Pain Stimulus"
  actionClass : EventModel.PainStimulus
  fullName  : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>] <br> Intensity = %3".arg(actionType).arg(location).arg(intensity)
  shortName : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>] <font color=\"lightsteelblue\">%3</font>".arg(actionType).arg(location).arg(intensity)

  //Builder mode data -- data passed to scenario builder
  buildParams : "Severity=" + intensity + ";Location=" + location + ";"
  //Interactive mode -- apply action immediately while running
  onActivate:   { scenario.create_pain_stimulus_action(intensity/10.0,location)  }
  onDeactivate: { scenario.create_pain_stimulus_action(0,location)  }

  controlsDetails : Component  {
    GridLayout {
      id: grid
      columns : 4
      rows    : 4
      width : root.width -5
      anchors.centerIn : parent      
      Label {
        font.pixelSize : 10
        font.bold : true
        color : "blue"
        text : "%1".arg(actionType)
      }      
      Label {
        font.pixelSize : 10
        font.bold : false
        color : "steelblue"
        text : "[%1]".arg(root.location)
        Layout.alignment : Qt.AlignCenter
      }
      //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
        text : "Intensity"
        font.pixelSize : 8
      }      
      Slider {
        id: stimulus   
        Layout.fillWidth : true
        from : 0
        to : 10
        stepSize : 1
        value : root.intensity
        Layout.alignment : Qt.AlignLeft
        Layout.columnSpan : 2
        onMoved : {
          root.intensity = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : "%1".arg(root.intensity)
        font.pixelSize : 8
      }
      //Row 3
      Rectangle {
        id: toggle
        Layout.row : 2
        Layout.column : 2
        Layout.columnSpan : 2
        Layout.fillWidth : true
        Layout.preferredHeight : 30      
        color:        root.active? 'green': 'red' // background
        opacity:      active  &&  !mouseArea.pressed? 1: 0.3 // disabled/pressed state      
        Text {
          text:  root.active?    'On': 'Off'
          color: root.active? 'white': 'white'
          horizontalAlignment : Text.AlignHCenter
          width : pill.width
          x:    root.active ? 0: pill.width
          font.pixelSize: 0.5 * toggle.height
          anchors.verticalCenter: parent.verticalCenter
        }
        Rectangle { // pill
          id: pill
          x: root.active ? pill.width: 0 // binding must not be broken with imperative x = ...
          width: parent.width * .5;
          height: parent.height // square
          border.width: parent.border.width
    
        }
        MouseArea {
          id: mouseArea
          anchors.fill: parent
          drag {
              target:   pill
              axis:     Drag.XAxis
              maximumX: toggle.width - pill.width
              minimumX: 0
          }
          onReleased: { // Did we drag the button far enough.
            if( root.active) {
                if(pill.x < toggle.width - pill.width) {
                  root.active = false // right to left
                }
            } else {
                if(pill.x > toggle.width * 0.5 - pill.width * 0.5){
                  root.active = true // left  to right
              } 
            }
          }
          onClicked: {
            root.active = !root.active
          }// emit
        }
      }
    }
  }// End Controls Details Component

  builderDetails : Component {
    id : builderDetails
    GridLayout {
      id: grid
      columns : 3
      rows : 3 
      width : root.width -5
      anchors.centerIn : parent
      signal clear()
      onClear : {
        locationCombo.currentIndex = -1
        root.location = ""
        root.intensity = 0
        startTimeLoader.item.clear()
        durationLoader.item.clear()
      }
      Label {
        id : actionLabel
        Layout.row : 0
        Layout.column : 0
        Layout.columnSpan : 3
        Layout.fillHeight : true
        Layout.fillWidth : true
        Layout.preferredWidth : grid.width * 0.5
        font.pixelSize : 20
        font.bold : true
        color : "blue"
        leftPadding : 5
        text : "%1".arg(actionType) + "[%1]".arg(root.location)
      }    
      //Row 2
      RowLayout {
        id : intensityWrapper
        Layout.maximumWidth : grid.width / 3
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 1
        Layout.column : 0
        Label {
          id : intensityLabel
          leftPadding : 5
          text : "Intensity"
          font.pixelSize : 18
        }
        Slider {
          id: stimulus
          from : 0
          to : 10
          stepSize : 1
          value : root.intensity
          Layout.alignment : Qt.AlignLeft
          onMoved : {
            root.intensity = value
          }
        }
        Label {
          text : "%1".arg(root.intensity)
          font.pixelSize : 18
          Layout.alignment : Qt.AlignLeft
        }
      }
      Loader {
        id : startTimeLoader
        sourceComponent : timeEntry
        onLoaded : {
          item.entryName = "Start Time"
          Layout.row = 1
          Layout.column = 1
          Layout.alignment = Qt.AlignHCenter
          Layout.fillWidth = true
          Layout.fillHeight = true
          Layout.maximumWidth = grid.width / 5
          if (actionStartTime_s > 0.0){
            item.reload(actionStartTime_s)
          }
        }
      }
      Connections {
        target : startTimeLoader.item
        onTimeUpdated : {
          root.actionStartTime_s = totalTime_s
        }
      }
      Loader {
        id : durationLoader
        sourceComponent : timeEntry
        onLoaded : {
          item.entryName = "Duration"
          Layout.row = 1
          Layout.column = 2
          Layout.alignment = Qt.AlignHCenter
          Layout.fillWidth = true
          Layout.fillHeight = true
          Layout.maximumWidth = grid.width / 5
          if (actionDuration_s > 0.0){
            item.reload(actionDuration_s)
          }
        }
      }
      Connections {
        target : durationLoader.item
        onTimeUpdated : {
          root.actionDuration_s = totalTime_s
        }
      }
      //Row 3
      RowLayout {
        Layout.row : 2
        Layout.column : 0
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 3
        Layout.fillHeight : true
        spacing : 15
        Label {
          id : locationLabel
          leftPadding : 5
          text : "Location"
          font.pixelSize : 18
        }      
        Loader {
          id : locationCombo
          sourceComponent : comboInput
          property var _combo_model : ['Abdomen', 'Chest','Head', 'Left Arm','Left Leg','Right Arm','Right Leg']
          property var _initial_value : root.location
          Layout.fillWidth : true
          Layout.maximumWidth : grid.width / 3 - 1.2 * locationLabel.width - parent.spacing
        }
        Connections {
          target : locationCombo.item
          onActivated : {
            root.location = target.textAt(target.currentIndex)
          }
        }
      }
      Rectangle {
        Layout.row : 2
        Layout.column : 1
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3
        color : "transparent"
        border.width : 0
        Button {
          text : "Set Action"
          opacity : validBuildConfig ? 1 : 0.4
          anchors.centerIn : parent
          height : parent.height
          width : parent.width / 2
          onClicked : {
            if (validBuildConfig){
              viewLoader.state = "collapsedBuilder"
              root.buildSet(root)
            }
          }
        }
      }
      Rectangle {
        Layout.row : 2
        Layout.column : 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 3
        color : "transparent"
        border.width : 0
        Button {
          text : "Clear Fields"
          anchors.centerIn : parent
          height : parent.height
          width : parent.width / 2
          onClicked : {
            grid.clear()
          }
        }
      }
    }
  } //end builder details component
}