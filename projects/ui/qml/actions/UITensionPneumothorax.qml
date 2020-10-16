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
  property int  side : -1
  property int  type : -1

  property string side_str : (root.side == -1) ? "" : (root.side == 0 ) ? "Left" : "Right"
  property string type_str : (root.type == -1) ? "" : (root.type == 0 ) ? "Open" : "Closed"
  property bool validBuildConfig : (severity > 0.0 && type !== -1 && side !== -1 && actionStartTime_s > 0.0)

  actionType : "Tension Pneumothorax"
  actionClass : EventModel.TensionPneumothorax
  fullName  : "<b>%1</b><br> Side = %2<br> Type = %3<br> Severity = %4".arg(actionType).arg(side_str).arg(type_str).arg(severity)
  shortName : "[<font color=\"lightsteelblue\">%2</font>]<b>%1</b> <font color=\"lightsteelblue\">%3</font>".arg(actionType).arg(side_str).arg(type_str)

  //Builder mode data -- data passed to scenario builder
  buildParams : "Severity=" + severity + ";Type=" + type + ";Side=" + side + ";"
  //Interactive mode -- apply action immediately while running
  onActivate:   { scenario.create_tension_pneumothorax_action(severity, type, side)  }
  onDeactivate: { scenario.create_tension_pneumothorax_action(0, type, side)  }

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
        color : "blue"
        text : "%1".arg(actionType)
      }      
      //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
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

        onMoved : {
          root.severity = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
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
  }// End Details Component
  builderDetails : Component {
    id : builderDetails
    GridLayout {
      id: grid
      columns : 4
      rows : 3 
      width : root.width -5
      anchors.centerIn : parent
      signal clear()
      onClear : {
        root.severity = 0
        typeRadioGroup.radioGroup.checkState = Qt.Unchecked
        sideRadioGroup.radioGroup.checkState = Qt.Unchecked
        startTimeLoader.item.clear()
        durationLoader.item.clear()
      }
      Label {
        id : actionLabel
        Layout.row : 0
        Layout.column : 0
        Layout.columnSpan : 4
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
        Layout.columnSpan : 2
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
          item.entryName = "StartTime"
          Layout.row = 1
          Layout.column = 2
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
          Layout.column = 3
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
        Layout.preferredWidth : grid.width / 5
        Layout.preferredHeight : 75
        elementRatio : 0.4
        radioGroup.checkedButton : setButtonState()
        label.text : "Type"
        label.horizontalAlignment : Text.AlignLeft
        label.padding : 5
        buttonModel : ['Open', 'Closed']
        radioGroup.onClicked : {
          type = button.buttonIndex
        }
        function setButtonState(){
          //Each time this item goes out of focus, it is destroyed (property of loader).  When we reload it, we want to make sure we incoprorate any data already set (e.g. left or right checked state)
          if (root.type == -1){
            return null
          } else {
            return radioGroup.buttons[type]
          }
        }
      }
      UIRadioButtonForm {
        id : sideRadioGroup
        Layout.row : 2
        Layout.column : 1
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.alignment : Qt.AlignVCenter
        Layout.preferredWidth : grid.width / 5
        Layout.preferredHeight : 75
        elementRatio : 0.4
        radioGroup.checkedButton : setButtonState()
        label.text : "Side"
        label.horizontalAlignment : Text.AlignLeft
        label.padding : 5
        buttonModel : ['Left', 'Right']
        radioGroup.onClicked : {
          side = button.buttonIndex
        }
        function setButtonState(){
          //Each time this item goes out of focus, it is destroyed (property of loader).  When we reload it, we want to make sure we incoprorate any data already set (e.g. left or right checked state)
          if (root.side == -1){
            return null
          } else {
            return radioGroup.buttons[side]
          }
        }
      }
      Rectangle {
        Layout.row : 2
        Layout.column : 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 4
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
        Layout.column : 3
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.maximumWidth : grid.width / 4
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