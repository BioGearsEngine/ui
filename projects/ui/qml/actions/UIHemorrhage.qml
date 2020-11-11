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

  property double rate : 0.0
  property string compartment : ""
  property bool validBuildConfig : (rate > 0.0 && compartment !=="" && actionDuration_s > 0.0)
  
  actionType : "Hemorrhage"
  actionClass : EventModel.Hemorrhage
  fullName  : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>] <br> Rate = %3ml/min".arg(actionType).arg(compartment).arg(rate)
  shortName : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>] <font color=\"lightsteelblue\">%3ml/min</font>".arg(actionType).arg(compartment).arg(rate)
  //Builder mode data -- data passed to scenario builder
  buildParams : "InitialRate=" + rate + ",mL/min;Compartment=" + compartment + ";"
  //Interactive mode -- apply action immediately while running
  onActivate:   { scenario.create_hemorrhage_action(compartment, rate)  }
  onDeactivate: { scenario.create_hemorrhage_action(compartment, 0)  }

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
        Layout.fillWidth : true
        font.bold : true
        Layout.leftMargin : 5
		color : "#34495e"
        text : "%1 [%2]".arg(actionType).arg(root.compartment)
      }
      //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
		Layout.leftMargin : 5
		color : "#34495e"
        text : "Rate"
        font.pointSize : 10
      }      
      Slider {
        id: stimulus      
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 10
        stepSize : 1
        value : root.rate
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
        text : "%1 ml/min".arg(root.rate )
        font.pointSize : 10
      }
    
      // Column 3
      Rectangle {
        id: toggle      
        Layout.row : 2
        Layout.column : 2
        Layout.columnSpan : 2
        Layout.fillWidth : true
        Layout.preferredHeight : 30
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
        compartmentCombo.item.currentIndex = -1
        root.compartment = ""
        root.rate = 0
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
        id : rateWrapper
        Layout.maximumWidth : grid.width / 3
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 1
        Layout.column : 0
        Label {
          id : rateLabel
          leftPadding : 5
          text : "Rate"
          font.pixelSize : 18
        }
        Slider {
          id: rateSlider
          Layout.fillWidth : true
          from : 0
          to : 500
          stepSize : 10
          value : root.rate
          Layout.alignment : Qt.AlignLeft
		  background: Rectangle {
				x: rateSlider.leftPadding
				y: rateSlider.topPadding + rateSlider.availableHeight / 2 - height / 2
				implicitWidth: 200
				implicitHeight: 4
				width: rateSlider.availableWidth
				height: implicitHeight
				radius: 2
				color: "#1abc9c"
				Rectangle {
					width: rateSlider.visualPosition * parent.width
					height: parent.height
					color: "#16a085"
					radius: 2
				}
			}
			handle: Rectangle {
				x: rateSlider.leftPadding + rateSlider.visualPosition * (rateSlider.availableWidth - width)
				y: rateSlider.topPadding + rateSlider.availableHeight / 2 - height / 2
				implicitWidth: 16
				implicitHeight: 16
				radius: 8
				color: rateSlider.pressed ? "#8e44ad" : "#16a085"
				//border.color: "#8e44ad"
			}
          onMoved : {
            root.rate = value
          }
        }
        Label {
          text : "%1 mL/min".arg(root.rate)
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
        Layout.maximumWidth : grid.width / 3
        Layout.fillHeight : true
        spacing : 15
        Label {
          id : compartmentLabel
          leftPadding : 5
          text : "Compartment"
          font.pixelSize : 18
        }
        Loader {
          id : compartmentCombo
          sourceComponent : comboInput
          property var _combo_model : ['Aorta', 'Large Intestine','Left Arm', 'Left Leg', 'Muscle', 'Right Arm', 'Right Leg', 'Skin', 'Small Intestine', 'Spleen', 'Vena Cava']
          property var _initial_value : root.compartment
          Layout.fillWidth : true
          Layout.maximumWidth : grid.width / 3 - 1.2 * compartmentLabel.width - parent.spacing
        }
        Connections {
          target : compartmentCombo.item
          onActivated : {
            root.compartment = target.textAt(target.currentIndex)
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