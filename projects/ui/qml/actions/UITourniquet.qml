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

  property string compartment : ""
  property int tState : -1
  property string state_str : (root.tState == -1) ? "" : (root.tState == 0) ? "Applied" : ( root.tState == 1) ? "Misapplied" : "None"
  property string state_str_formated : (root.state == 0) ? "[<font color=\"green\">%2</font>]".arg(root.state_str) : 
                                       (root.state == 1) ? "[<font color=\"red\">%2</font>]".arg(root.state_str) : ""
  property bool validBuildConfig : (tState !== -1 && compartment !=="" )

  actionType : "Tourniquet"
  actionClass : EventModel.Tourniquet
  fullName  : "<b>%1</b><br> Location = %2<br> State = %3".arg(actionType).arg(compartment).arg(state_str)
  shortName : "[<font color=\"lightsteelblue\"> %2</font>] <b>%1</b> %3".arg(actionType).arg(compartment).arg((root.active) ? state_str_formated.arg(state_str) : "")

  //Builder mode data -- data passed to scenario builder
  buildParams : "Compartment=" + compartment + ";TourniquetLevel=" + tState + ";"
  //Interactive mode -- apply action immediately while running
  onActivate:   { scenario.create_tourniquet_action(compartment, tState)  }
  onDeactivate: { scenario.create_tourniquet_action(compartment, 2)  }


  controlsDetails : Component  {
    GridLayout {
      id: grid
      columns : 4
      rows    : 3
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
      // Row 3
      Rectangle {
        id: toggle      
        Layout.row : 1
        Layout.column : 2
        Layout.columnSpan : 2
        Layout.fillWidth : true
        Layout.maximumWidth : grid.width / 4
		Layout.bottomMargin : 5
		radius : pill.width * 0.6
        implicitHeight : 30      
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
		  radius : pill.width * 0.6
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
        compartmentCombo.currentIndex = -1
        root.compartment = ""
        root.tState = -1
        stateRadioGroup.radioGroup.checkState = Qt.Unchecked
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
        id : compartmentInput
        Layout.row : 1
        Layout.column : 0
        Layout.fillWidth : true
        Layout.maximumWidth : grid.Width / 3
        Layout.preferredHeight : 40
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
          property var _combo_model : ['Left Arm', 'Left Leg', 'Right Arm', 'Right Leg']
          property var _initial_value : root.compartment
          Layout.fillWidth : true
          Layout.maximumWidth : grid.width / 3 - compartmentLabel.width - parent.spacing
        }
        Connections {
          target : compartmentCombo.item
          onActivated : {
            root.compartment = target.textAt(target.currentIndex)
          }
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
        id : stateRadioGroup
        Layout.row : 2
        Layout.column : 0
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.alignment : Qt.AlignVCenter
        Layout.preferredWidth : grid.width / 5
        Layout.preferredHeight : 75
        elementRatio : 0.4
        radioGroup.checkedButton : setButtonState()
        label.text : "State"
        label.font.pointSize : 13
        label.horizontalAlignment : Text.AlignLeft
        label.padding : 5
        buttonModel : ['Applied', 'Misapplied']
        radioGroup.onClicked : {
          tState = button.buttonIndex
        }
        function setButtonState(){
          //Each time this item goes out of focus, it is destroyed (property of loader).  When we reload it, we want to make sure we incoprorate any data already set (e.g. left or right checked state)
          if (root.tState == -1){
            return null
          } else {
            return radioGroup.buttons[tState]
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