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
  
  signal activate()
  signal deactivate()
  signal adjust( var list)

  height : grid.height
  GridLayout {
    id: grid
    columns : 4
    rows    : 4
    width : parent.width -5
    anchors.centerIn : parent

    Label {
      font.pixelSize : 10
      font.bold : true
      color : "blue"
      text : "Pain Stimulus"
    }

    Label {
      font.pixelSize : 10
      font.bold : false
      color : "steelblue"
      text : "[Left Arm]"
      Layout.alignment : Qt.AlignHCenter
    }
    //Column 2
    Label {
      Layout.row : 1
      Layout.column : 0
      text : "Intensity"
    }

    Slider {
      id: stimulus

      Layout.fillWidth : true
      Layout.columnSpan : 2
      from : 0
      to : 1
      stepSize : 0.01
      value : .5
    }
    Label {
      text : "%1".arg(stimulus.value)
    }

    // Column 3
    Rectangle {
      id: toggle

      property bool checked: false
 
      Layout.row : 2
      Layout.column : 2
      Layout.columnSpan : 2
      Layout.fillWidth : true
      Layout.preferredHeight : 30

      color:        checked? 'green': 'red' // background
      opacity:      enabled  &&  !sliderMouseArea.pressed? 1: 0.3 // disabled/pressed state

      Text {
        text:  toggle.checked?    'On': 'Off'
        color: toggle.checked? 'white': 'white'
        x:    (toggle.checked? 0: pill.width) + (parent.width - pill.width - width) / 2
        font.pixelSize: 0.5 * toggle.height
        anchors.verticalCenter: parent.verticalCenter
      }
      Rectangle { // pill
          id: pill
        
          x: toggle.checked? toggle.width - pill.width: 0 // binding must not be broken with imperative x = ...
          width: parent.width * .5; 
          height: parent.height // square
          border.width: parent.border.width

      }
      MouseArea {
        id: sliderMouseArea
        anchors.fill: parent
      
        drag {
            target:   pill
            axis:     Drag.XAxis
            maximumX: toggle.width - pill.width
            minimumX: 0
        }
      
        onReleased: { // releasing at the end of drag
          if( toggle.checked) {
              if(pill.x < toggle.width - pill.width) {
                toggle.checked = false // right to left
                pill.x  = 0
              } else {
                pill.x  = toggle.width - pill.width
              }
          } else {
              if(pill.x > toggle.width * 0.5 - pill.width * 0.5){
                toggle.checked = true // left  to right
                pill.x = toggle.width - pill.width
            } else {
                pill.x = 0
            }
          }
        }
        onClicked: {
          toggle.checked = !toggle.checked 
          if ( toggle.checked ){
            pill.x = toggle.width - pill.width
          } else {
            pill.x = 0
          }
        }// emit
      }
    }
  }
  MouseArea {
    id: ssctionMouseArea
    anchors.fill: parent
    z: sliderMouseArea.z - 1
    acceptedButtons:  Qt.LeftButton | Qt.RightButton
    propagateComposedEvents : true

    onClicked: {
      console.log("Outer On Clicked")
      if (mouse.button === Qt.RightButton){
        contextMenu.popup()
      } else {
        mouse.accepted = false
      }
    }
    onDoubleClicked: { // Double Clicking Window
    console.log("Outer On Double Clicked")
      if ( mouse.button === Qt.LeftButton ){
        console.log ("Double Clicked!")
        if ( root.state === "Collapsed") {
          root.state = "Expanded"
        } else {
          root.state = "Collapsed"
        }
      } else {
        mouse.accepted = false
      }
    }
    Menu {
      id: contextMenu
      MenuItem {
        text : "Config"
      }

      MenuItem {
        text : "Remove"
      }
    }
  }
}
