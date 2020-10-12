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

  actionType : "Inhaler"
  actionClass : EventModel.InhalerConfiguration
  fullName  : "<b>%1</b>".arg(actionType)
  shortName : "<b>%1</b>".arg(actionType)

  //End Action Properties
  property alias delayTimer : delayTimer
  property bool validBuildConfig : true
  onActivate:   { scenario.create_inhaler_action()  }
  onDeactivate: { }

  Timer {
    id : delayTimer
    interval : 20000
    running : false
    repeat : false
    onTriggered : {
      if (root.active){
        root.active = false
      }
    }
  }

  controlsSummary : Component {
    RowLayout {
      id : actionRow
      spacing : 5
      height : childrenRect.height
      width : root.parent.width
      Label {
        id : actionLabel
        Layout.preferredWidth : parent.width * 2/4 - actionRow.spacing / 2
        color : '#1A5276'
        text : root.shortName
        elide : Text.ElideRight
        font.pointSize : builderMode ? 15 : 8
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
      UIBioGearsButtonForm {
        id: toggle
        visible : !builderMode
        Layout.preferredWidth : parent.width * 1/4 - actionRow.spacing 
        Layout.rightMargin : 20
        Layout.preferredHeight : parent.height
        enabled : !root.active
        text : "Apply"
        primary : enabled ? "#4CAF50" : "grey"
        MouseArea {
          id: mouseArea
          anchors.fill: parent
          enabled : !root.active
          onClicked: {
            root.active = true
            root.delayTimer.restart()
          }// emit
        }
      }
    }
  } // End Summary Component
  controlsDetails : Component {
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
      UIBioGearsButtonForm {
        id: toggle
        visible : !builderMode
        Layout.preferredWidth : parent.width * 1/4 - actionRow.spacing 
        Layout.rightMargin : 20
        Layout.preferredHeight : parent.height
        enabled : !root.active
        text : "Apply"
        primary : enabled ? "#4CAF50" : "grey"
        MouseArea {
          id: mouseArea
          anchors.fill: parent
          enabled : !root.active
          onClicked: {
            root.active = true
            root.delayTimer.restart()
          }// emit
        }
      }
    }
  } // End Summary dETAILS
  builderDetails : Component {
    id : builderDetails
    GridLayout {
      id: grid
      columns : 2
      rows : 3 
      width : root.width -5
      anchors.centerIn : parent
      signal clear()
      onClear : {
        startTimeLoader.item.clear()
        durationLoader.item.clear()
      }
      Label {
        id : actionLabel
        Layout.row : 0
        Layout.column : 0
        Layout.columnSpan : 2
        Layout.fillHeight : true
        Layout.fillWidth : true
        Layout.preferredWidth : grid.width * 0.5
        font.pixelSize : 20
        font.bold : true
        color : "blue"
        leftPadding : 5
        text : "%1".arg(actionType)
      }    
      //Row 2
      Loader {
        id : startTimeLoader
        sourceComponent : timeEntry
        onLoaded : {
          item.entryName = "Start Time"
          Layout.row = 1
          Layout.column = 0
          Layout.alignment = Qt.AlignHCenter
          Layout.fillWidth = true
          Layout.fillHeight = true
          Layout.maximumWidth = grid.width / 5
          Layout.preferredHeight = item.height
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
      //Row 3
      Rectangle {
        Layout.row : 2
        Layout.column : 0
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.preferredHeight : 2 * startTimeLoader.item.height
        Layout.maximumWidth : grid.width / 2
        Layout.alignment : Qt.AlignHCenter
        color : "transparent"
        border.width : 0
        Button {
          text : "Set Action"
          opacity : validBuildConfig ? 1 : 0.4
          anchors.centerIn : parent
          height : parent.height
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
        Layout.column : 1
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.preferredHeight : startTimeLoader.item.height
        Layout.maximumWidth : grid.width / 2
        Layout.alignment : Qt.AlignHCenter
        color : "transparent"
        border.width : 0
        Button {
          text : "Clear Fields"
          anchors.centerIn : parent
          height : parent.height
          width : parent.width / 2
          onClicked : {
            grid.clear()
          }
        }
      }
    }
  } //end builder details component

}
