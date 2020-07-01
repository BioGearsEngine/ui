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

  property double  mix : 0.0
  property double  bottle_1 : 0.0
  property double  bottle_2 : 0.0

  actionType : "Anesthesia Machine"
  fullName  :  "<b>%1</b><br>".arg(actionType)

  shortName : "<font color=\"lightsteelblue\"> %2</font> <b>%1</b>".arg(actionType).arg(mix)

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
        text : "Bottle 1 Volume"
      }      
      Slider {
        id: bottle_1
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 100
        stepSize : 1
        value : root.bottle_1
        onMoved : {
          root.bottle_1 = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : "%1 ml".arg(root.bottle_1)
      }
      //Column 3
      Label {
        Layout.row : 2
        Layout.column : 0
        text : "Bottle 2 Volume"
      }      
      Slider {
        id: concentration
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 100
        stepSize : 1
        value : root.bottle_2
        onMoved : {
          root.bottle_2 = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text :  "%1 ml".arg(bottle_2)
      }
      //Column 4
      Label {
        Layout.row : 3
        Layout.column : 0
        text : "mix"
      
      }      
      Slider {
        id: flowRate
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1
        stepSize : 0.01
        value : root.mix
        onMoved : {
          root.mix = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : "%1 %".arg(mix)
      }
    
      // Column 5
      Rectangle {
        id: toggle      
        Layout.row : 4
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
 
  onActivate:   { 
    scenario.create_anasthesia_machien_action(mix, bottle_1, bottle_2) 
  }
  onDeactivate: { 
    scenario.create_anasthesia_machien_action(.5, 0, 0)   
  }
}