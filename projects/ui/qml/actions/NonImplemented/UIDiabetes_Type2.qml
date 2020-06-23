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
  height : loader.item.height

  signal activate()
  signal deactivate()
  signal remove( string uuid )
  signal adjust( var list)

  property double intensity : 0.0
  property string actionType : "Pain Stimulus"
  property string location : "LeftArm"
  property string uuid : ""
  property bool active : false
  property bool collapsed : true

  property string fullName  : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>] <br> Intensity = %3".arg(actionType).arg(location).arg(intensity)
  property string shortName : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>] <font color=\"lightsteelblue\">%3</font>".arg(actionType).arg(location).arg(intensity)

  onActiveChanged : {
    if ( active) {
      console.log ("active")
      root.activate()
    } else {
      root.deactivate();
      console.log ("inactive")
    }
  }

  Loader {
    id : loader

     
    Component {
      id : details

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
          to : 10
          stepSize : 1
          value : root.intensity

          onMoved : {
            root.intensity = value
            if ( root.active )
               root.active = false;
          }
        }
        Label {
          text : "%1".arg(root.intensity)
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

    }
    Component {
      id : summary
      RowLayout {
        id : actionRow
        spacing : 5
        height : childrenRect.height
        width : root.width
        Label {
          id : actionLabel
          width : parent.width * 3/4 - actionRow.spacing / 2
          color : '#1A5276'
          text : root.shortName
          elide : Text.ElideRight
          font.pointSize : 8
          font.bold : true
          horizontalAlignment  : Text.AlignLeft
          leftPadding : 5
          verticalAlignment : Text.AlignVCenter
          background : Rectangle {
              id : labelBackground
              anchors.fill : parent
              color : 'transparent'
              border.color : 'grey'
              border.width : 0
          }
          MouseArea {
              id : labelMouseArea
              anchors.fill : parent
              hoverEnabled : true
              propagateComposedEvents :true
              Timer {
                id : infoTimer
                interval: 500; running: false; repeat: false
                onTriggered:  actionTip.visible  = true
              }

              onEntered: {
                infoTimer.start()
                actionTip.visible  = false
              }
              onPositionChanged : {
                infoTimer.restart()
                actionTip.visible  = false
              }
              onExited : {
                infoTimer.stop()
                actionTip.visible  = false
              }
          }
          ToolTip {
            id : actionTip
            parent : actionLabel
            x : 0
            y : parent.height + 5
            visible : false
            text : root.fullName
            contentItem : Text {
              text : actionTip.text
              color : '#1A5276'
              font.pointSize : 10
            }
            background : Rectangle {
              color : "white"
              border.color : "black"
            }
          }
        }
        Rectangle {
          id: toggle
          Layout.fillWidth : true
          height : 20
          border.color : "blue"
          color:        root.active? 'green': 'red' // background
          opacity:      active  &&  !mouseArea.pressed? 1: 0.3 // disabled/pressed state

          Text {
            text:  root.active?    'On': 'Off'
            color:  'white'
            horizontalAlignment : Text.AlignHCenter
            anchors.centerIn : parent
            font.pixelSize: 0.5 * toggle.height

          }
          MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
              root.active = !root.active
            }// emit
          }
        }
      }
    }
    sourceComponent : details
    state  : "expanded"

    states : [
      State {
        name: "expanded"
        PropertyChanges { target : loader; sourceComponent: details}
      }

      ,State {
        name: "collapsed"
        PropertyChanges { target : loader; sourceComponent: summary}
      }
    ]

    MouseArea {
      id: actionMouseArea
      anchors.fill: parent
      z: -1
      acceptedButtons:  Qt.LeftButton | Qt.RightButton
      
      onClicked : {
        if ( mouse.button == Qt.RightButton) {
          contextMenu.popup()
        }
      }

      onDoubleClicked: { // Double Clicking Window
        if ( mouse.button === Qt.LeftButton ){
          if ( loader.state === "collapsed") {
            loader.state = "expanded"
          } else {
            loader.state = "collapsed"
          }
        } else {
          mouse.accepted = false
        }
      }

      Menu {
        id : contextMenu
        MenuItem {
          text : (loader.state === "collapsed")? "Configure" : "Collapse"
           onTriggered: {
             if ( loader.state === "collapsed"){
               loader.state = "expanded"
             } else {
               loader.state = "collapsed"
             }

           }
        }
        MenuItem {
          text : "Remove"
           onTriggered: {
            root.deactivate()
            root.remove( root.uuid )
           }
        }
      }
    }
  }
  Component.onCompleted : {
    console.log(width,height)
  }
}