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

  property string type : ""
  property double  weight : 0.0
  property double  property_1 : 0.0
  property double  property_2 : 0.0

  

  actionType : "Exercise"
  fullName  :  "<b>%1 %2</b><br>".arg(type).arg(actionType)

  shortName : "<font color=\"lightsteelblue\"> %2</font> <b>%1</b>".arg(actionType).arg(type)

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
        text : {
          if ( type == "Generic") {
            return "Work Rate"
          } else if ( type == "Cycling") {
            return "Cadence"
          } else if ( type == "Running" ) {
            return "Velocity"
          } else {
            return "Weight"
          }
        }
        visible : dosage.concentration
      }      
      Slider {
        id: property_1
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 100
        stepSize : 1
        value : root.paramater_1
        onMoved : {
          root.property_1 = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : {
          if ( type == "Generic") {
            return "%1 W".arg(root.property_1)
          } else if ( type == "Cycling") {
            return "%1 Hz".arg(root.property_1)
          } else if ( type == "Running" ) {
            return "%1 m/s".arg(root.property_1)
          } else {
            return "%1 kg".arg(root.property_1)
          }
        }
        visible : dosage.concentration
      }
      //Column 3
      Label {
        Layout.row : 2
        Layout.column : 0
        text : {
          if ( type == "Generic") {
            return "Intensity"
          } else if ( type == "Cycling") {
            return "Power Cycle"
          } else if ( type == "Running" ) {
            return "Incline"
          } else {
            return "Repitition"
          }
        }
        visible : flowRate.property_2
      }      
      Slider {
        id: concentration
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 100
        stepSize : 1
        value : root.property_2
        onMoved : {
          root.concentration = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : {
           if ( type == "Generic") {
            return "%1".arg(property_2)
          } else if ( type == "Cycling") {
            return "%1 W".arg(root.property_2)
          } else if ( type == "Running" ) {
            return "%1 %".arg(root.property_2)
          } else {
            return "%1".arg(property_2)
          }
        }
        visible : flowRate.concentration
      }
    //Column 4
      Label {
        Layout.row : 3
        Layout.column : 0
        text : "Weight"
        visible : ( type == "Running" || type == "Cycling") ? true : false
      }      
      Slider {
        id: flowRate
        Layout.fillWidth : true
        Layout.columnSpan : 2
        from : 0
        to : 1000
        stepSize : 1
        value : root.rate
        visible : ( type == "Running" || type == "Cycling") ? true : false
        onMoved : {
          root.rate = value
          if ( root.active )
              root.active = false;
        }
      }
      Label {
        text : "%1 kg".arg(weight)
        visible : ( type == "Running" || type == "Cycling") ? true : false
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
    let type = 0
    if ( type == "Generic") {
      type = 0
    } else if ( type == "Cycling") {
      type = 1
    } else if ( type == "Running" ) {
      type = 2
    } else {
      type = 3
    }
    scenario.create_exercise_action(type, weight, intensity, workRate) 
  }
  onDeactivate: { 
      scenario.create_exercise_action(0, 0, 0, 0) 

  }
}