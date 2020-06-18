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

  height : loader.height

  signal activate()
  signal deactivate()
  signal remove()
  signal adjust( var list)

  property double intensity : 0.0
  property string actionType : "Pain Stimulus"
  property string location : "LeftArm"
  property bool enabled : false
  property bool collapsed : true

  property string fullName  : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>] <br> Intensity = %3".arg(actionType).arg(location).arg(intensity)
  property string shortName : "<b>%1</b> [<font color=\"lightsteelblue\"> %2</font>] <font color=\"lightsteelblue\">%3</font>".arg(actionType).arg(location).arg(intensity)

  Loader {
    id : loader

    onEnabledChanged : {
      if ( enabled) {
        root.activate()
      } else {
        root.deactivate();
      }
    }
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
          to : 1
          stepSize : 0.01
          value : root.intensity

          onMoved : {
            root.intensity = value
            if ( root.enabled )
               root.enabled = false;
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
      
          color:        root.enabled? 'green': 'red' // background
          opacity:      enabled  &&  !mouseArea.pressed? 1: 0.3 // disabled/pressed state
      
          Text {
            text:  root.enabled?    'On': 'Off'
            color: root.enabled? 'white': 'white'
            x:    (root.enabled? 0: pill.width) + (parent.width - pill.width - width) / 2
            font.pixelSize: 0.5 * toggle.height
            anchors.verticalCenter: parent.verticalCenter
          }
          Rectangle { // pill
              id: pill
      
              x: root.enabled? toggle.width - pill.width: 0 // binding must not be broken with imperative x = ...
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
      
              onReleased: { // releasing at the end of drag
                if( root.enabled) {
                   if(pill.x < toggle.width - pill.width) {
                      root.enabled = false // right to left
                      pill.x  = 0
                    } else {
                      pill.x  = toggle.width - pill.width
                    }
                } else {
                    if(pill.x > toggle.width * 0.5 - pill.width * 0.5){
                      root.enabled = true // left  to right
                      pill.x = toggle.width - pill.width
                  } else {
                      pill.x = 0
                  }
                }
              }
              onClicked: {
                root.enabled = !root.enabled
                if ( root.enabled ){
                  pill.x = toggle.width - pill.width
                } else {
                  pill.x = 0
                }
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
          color:        root.enabled? 'green': 'red' // background
          opacity:      enabled  &&  !mouseArea.pressed? 1: 0.3 // disabled/pressed state

          Text {
            text:  root.enabled?    'On': 'Off'
            color:  'white'
            horizontalAlignment : Text.AlignHCenter
            anchors.centerIn : parent
            font.pixelSize: 0.5 * toggle.height

          }
          MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
              root.enabled = !root.enabled
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
           onTriggered: root.remove()
        }
      }
    }
  }
}