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

  property double severity : 0.0
  property int type : -1
  property string type_str : (root.type == -1) ? "" : (root.type == 0) ? "Difuse" : ( root.type == 1) ? "Left Focal" : "Right Focal"
  
  property bool validBuildConfig : (severity > 0.0 && type > -1 && actionDuration_s > 0.0)

  actionType : "Traumatic Brain Injury"
  actionClass : EventModel.BrainInjury
  fullName  : "<b>%1</b><br> Type = %2<br> Severity = %3".arg(actionType).arg(type_str).arg(severity)
  shortName : "[<font color=\"lightsteelblue\"> %2</font>] <b>%1</b>".arg(actionType).arg(type_str)

  //Builder mode data -- data passed to scenario builder
  buildParams : "Severity=" + severity + ";Type=" + type + ";"
  //Interactive mode -- apply action immediately while running
  onActivate:   { scenario.create_traumatic_brain_injury_action(severity, type)  }
  onDeactivate: { scenario.create_traumatic_brain_injury_action(0, type)  }

  controlsDetails : Component  {
    GridLayout {
      id: grid
      columns : 4
      rows    : 4
      width : root.width -5
      anchors.centerIn : parent      
      Label {
        font.pointSize : 12
        Layout.columnSpan : 4
        font.bold : true
        Layout.fillWidth : true
        Layout.leftMargin : 5
		color : "#34495e"
        text : "%1".arg(actionType)
      }
      //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Severity"
        font.pointSize : 10
      }      
      Slider {
        id: stimulus      
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1
        stepSize : 0.05
        value : root.severity
		background: Rectangle {
			x: stimulus.leftPadding
			y: stimulus.topPadding + stimulus.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: stimulus.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: stimulus.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: stimulus.leftPadding + stimulus.visualPosition * (stimulus.availableWidth - width)
			y: stimulus.topPadding + stimulus.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: stimulus.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
        onMoved : {
          root.rate = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
		color : "#34495e"
        text : "%1".arg(root.severity )
        font.pointSize : 10
      }
    
      // Column 3
      Rectangle {
        id: toggle      
        Layout.row : 2
        Layout.column : 2
        Layout.columnSpan : 2
        Layout.fillWidth : true
        implicitHeight : 30  
        Layout.maximumWidth : grid.width / 4
		Layout.bottomMargin : 5
		radius : pill.width * 0.6
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
			radius : pill.width * 0.6
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
  }// End Details Component
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
        root.severity = 0
        typeRadioGroup.radioGroup.checkState = Qt.Unchecked
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
        text : "%1".arg(actionType) + "[%1]".arg(root.compartment)
      }    
      //Row 2
      RowLayout {
        id : severityWrapper
        Layout.maximumWidth : grid.width / 3
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 1
        Layout.column : 0
        Label {
          id : severityLabel
          leftPadding : 5
          text : "Severity"
          font.pixelSize : 18
        }
        Slider {
          id: severitySlider
          Layout.fillWidth : true
          from : 0
          to : 1
          stepSize : 0.05
          value : root.severity
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
			x: severitySlider.leftPadding
			y: severitySlider.topPadding + severitySlider.availableHeight / 2 - height / 2
			implicitWidth: 200
			implicitHeight: 4
			width: severitySlider.availableWidth
			height: implicitHeight
			radius: 2
			color: "#1abc9c"
			Rectangle {
				width: severitySlider.visualPosition * parent.width
				height: parent.height
				color: "#16a085"
				radius: 2
			}
		}
		handle: Rectangle {
			x: severitySlider.leftPadding + severitySlider.visualPosition * (severitySlider.availableWidth - width)
			y: severitySlider.topPadding + severitySlider.availableHeight / 2 - height / 2
			implicitWidth: 16
			implicitHeight: 16
			radius: 8
			color: severitySlider.pressed ? "#8e44ad" : "#16a085"
			//border.color: "#8e44ad"
		}
          onMoved : {
            root.severity = value
          }
        }
        Label {
          text : "%1".arg(root.severity)
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
      UIRadioButtonForm {
        id : typeRadioGroup
        Layout.row : 2
        Layout.column : 0
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.alignment : Qt.AlignVCenter
        Layout.preferredWidth : grid.width / 3
        Layout.preferredHeight : 75
        elementRatio : 0.4
        radioGroup.checkedButton : type == -1 ? null : radioGroup.buttons[type]
        label.text : "Type"
        label.font.pointSize : 13
        label.horizontalAlignment : Text.AlignLeft
        label.padding : 5
        buttonModel : ['Diffuse', 'Left Focal', 'Right Focal']
        radioGroup.onClicked : {
          type = button.buttonIndex
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
          height : parent.height * 0.6
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
          height : parent.height * 0.6
          width : parent.width / 2
          onClicked : {
            grid.clear()
          }
        }
      }
    }
  } //end builder details component
}