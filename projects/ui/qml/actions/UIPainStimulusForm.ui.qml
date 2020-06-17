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
  signal adjust( var list)

  property double intensity : 0.0
  property string location : "LeftArm"
  property bool enabled : false
  property bool collapsed : true

  property string fullName  : "<b>Pain Stimulus</b> [<font color=\"lightsteelblue\"> %1</font>] \nIntensity = %2".arg(location).arg(intensity)
  property string shortName : "<b>Pain Stimulus</b> [<font color=\"lightsteelblue\"> %1</font>] @ %2".arg(location).arg(intensity)

  Loader {
    id : loader

    Component {
      id : details
      Rectangle {
        height : 200
        width : root.width

        color : "red"
        border.color : "yellow"
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
              acceptedButtons : Qt.RightButton
          }
          ToolTip {
            id : actionTip
            parent : actionLabel
            x : 0
            y : parent.height + 5
            visible : labelMouseArea.pressed
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
      propagateComposedEvents : true

      onDoubleClicked: { // Double Clicking Window
        console.log("Double Clicked")
        if ( mouse.button === Qt.LeftButton ){
          console.log("Left Double Clicked")
          if ( loader.state === "collapsed") {
            console.log("Expanding")
            loader.state = "expanded"
          } else {
            console.log("Collapsing")
            loader.state = "collapsed"
          }
        } else {
          mouse.accepted = false
        }
      }
    }
  }
}