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


  property double volume : 0
  property double rate : 0
  property string blood_type : ""
  
  actionType : "Transfusion"
  fullName  : "<b>%1</b><br> Volume = %2<br> Rate = %3".arg(actionType).arg(volume).arg(rate)
  shortName : "[<font color=\"lightsteelblue\"> %2</font>] <b>%1</b>".arg(actionType).arg(blood_type)

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
        text : "[%1]".arg(root.blood_type)
        Layout.alignment : Qt.AlignHCenter
      }
      //Column 2
      Label {
        Layout.row : 1
        Layout.column : 0
        text : "Volume"
      }      
      Slider {
        id: bagVolume      
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1
        stepSize : 0.05
        value : root.volume

        onMoved : {
          root.volume = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : "%1ml".arg(root.volume )
      }
      //Column 3
      Label {
        Layout.row : 2
        Layout.column : 0
        text : "Flow Rate"
      }      
      Slider {
        id: flowRate
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1
        stepSize : 0.05
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
      // Column 4
      Rectangle {
        id: toggle      
        Layout.row : 3
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

  onActivate:   { scenario.create_blood_transfusion_action(blood_type, volume, rate)  }
  onDeactivate: { scenario.create_blood_transfusion_action(blood_type, 0, 0)  }
}