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
  property string fileName : ""

  property bool validBuildConfig : fileName !==""

  actionType : "Serialize State"
  actionClass : EventModel.SerializeState
  fullName  : "<b>%1</b>".arg(actionType)
  shortName : "<b>%1</b>".arg(actionType)

  //Builder mode data -- data passed to scenario builder
  buildParams : "Filename=" + fileName + ";"
  //Interactive mode -- not defining interactive mode for serialize currently (we already have 'Save State' for interactive

  builderDetails : Component {
    id : builderDetails
    GridLayout {
      id: grid
      columns : 3
      rows : 3
      width : root.width -5
      anchors.centerIn : parent
      signal clear()
      onClear : {
        startTimeLoader.item.clear()
      }
      Label {
        id : actionLabel
        Layout.row : 0
        Layout.column : 0
        Layout.columnSpan : 3
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
      RowLayout {
        id : nameWrapper
        Layout.maximumWidth : grid.width / 3
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 1
        Layout.column : 0
        Label {
          id: nameLabel
          font.pixelSize : 18
          bottomPadding : 8
          text : "File Name: "
          Layout.alignment : Qt.AlignRight
          leftPadding : 5
        }
        TextField {
          id : nameField
          placeholderText : "Name"
          text : root.fileName
          Layout.fillWidth : true
          font.pixelSize : 18
          Layout.alignment : Qt.AlignHCenter
          horizontalAlignment : TextInput.AlignHCenter
          onTextEdited : {
            root.fileName = text
          }
        }
      }
      Loader {
        id : startTimeLoader
        sourceComponent : timeEntry
        onLoaded : {
          item.entryName = "Start Time"
          Layout.row = 1
          Layout.column = 1
          Layout.alignment = Qt.AlignHCenter
          Layout.fillWidth = true
          Layout.fillHeight = true
          Layout.maximumWidth = grid.width / 5
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
      Rectangle {
        //placeholder for spacing
        color : "transparent"
        Layout.row : 1
        Layout.column : 2
        Layout.preferredHeight : nameWrapper.height   //recs need preferred dimension explicity stated (not sure why fill width/height not enough to accomplish this)
        Layout.fillWidth : true
        Layout.maximumWidth : grid.width / 3
        Layout.fillHeight : true
      }
      //Row 3
      Rectangle {
        //placeholder for spacing
        color : "transparent"
        Layout.row : 2
        Layout.column : 0
        Layout.preferredHeight : nameWrapper.height   //recs need preferred dimension explicity stated (not sure why fill width/height not enough to accomplish this)
        Layout.fillWidth : true
        Layout.maximumWidth : grid.width / 3
        Layout.fillHeight : true
      }
      Rectangle {
        Layout.row : 2
        Layout.column : 1
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.preferredHeight : 50
        Layout.maximumWidth : grid.width / 3
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
        Layout.column : 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.preferredHeight : 50
        Layout.maximumWidth : grid.width / 3
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