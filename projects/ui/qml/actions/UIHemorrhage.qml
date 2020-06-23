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
  property string compartment : "LeftArm"
  
  actionType : "Hemorrhage"
  fullName  : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>] <br> Rate = %3ml/min".arg(actionType).arg(compartment).arg(rate)
  shortName : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>] <font color=\"lightsteelblue\">%3ml/min</font>".arg(actionType).arg(compartment).arg(rate)

  details : Component  {
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
        text : "[%1]".arg(root.compartment)
        Layout.alignment : Qt.AlignHCenter
      }
      //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
        text : "Rate"
      }      
      Slider {
        id: stimulus      
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 10
        stepSize : 1
        value : root.rate

        onMoved : {
          root.rate = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : "%1ml/min".arg(root.rate )
      }
    
      // Column 3
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
  }// End Details Component

  onActivate:   { scenario.create_hemorrhage_action(compartment, rate)  }
  onDeactivate: { scenario.create_hemorrhage_action(compartment, 0)  }
}