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

  actionType : "Cardiac Arrest"
  fullName  : "<b>%1</b>".arg(actionType)
  shortName : "<b>%1</b>".arg(actionType)

  details : Component {
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
        Layout.fillWidth : true
      }
      Rectangle {
        id: toggle
        width  : 40
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
  } // End Summary dETAILS

  onActivate:   { scenario.create_cardiac_arrest_action(1)  }
  onDeactivate: { scenario.create_cardiac_arrest_action(0)  }
}