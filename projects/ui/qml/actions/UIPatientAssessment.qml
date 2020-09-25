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

  property string type_str : ""
  property int type : {
    switch(type_str){
      case "PulmonaryFunctionTest":
        return 0;
      case "CompleteBloodCount":
        return 1;
      case "MetabolicPanel":
        return 2;
      case "SOFA":
        return 3;
      case "Urinalysis":
        return 4;
      default : 
        return -1;
    }
  }

  property bool validBuildConfig : type > -1

  actionType : "Patient Assessment"
  actionClass : EventModel.PatientAssessmentRequest
  fullName  : "<b>%1</b>(%2)".arg(actionType).arg(type_str)
  shortName : "<b>%2</b>".arg(type_str)

  //Builder mode data -- data passed to scenario builder
  buildParams : "Type=" + type + ";"
  //Interactive mode -- TODO add assessments to runtime actions if we think necessary

  
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
        requestCombo.item.currentIndex = -1
        root.type_str = "";
        root.type = -1;
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
        id : requestWrapper
        Layout.maximumWidth : grid.width / 3
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.row : 1
        Layout.column : 0
        Label {
          id: requestLabel
          font.pixelSize : 18
          text : "Type"
          leftPadding : 5
        }      
        Loader {
          id : requestCombo
          sourceComponent : comboInput
          property var _combo_model : ['Pulmonary Function Test', 'Complete Blood Count', 'Metabolic Panel', 'SOFA', 'Urinalysis'] //Same order that requests appear in Patient Assessment Enum in schema
          property var _initial_value : root.type_str
          Layout.fillWidth : true
          Layout.maximumWidth : grid.width / 3 - 1.2 * requestLabel.width - parent.spacing
        }
        Connections {
          target : requestCombo.item
          onActivated : {
            root.type = target.currentIndex
            root.type_str = target.textAt(target.currentIndex)
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
        Layout.preferredHeight : requestWrapper.height   //recs need preferred dimension explicity stated (not sure why fill width/height not enough to accomplish this)
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
        Layout.preferredHeight : requestWrapper.height   //recs need preferred dimension explicity stated (not sure why fill width/height not enough to accomplish this)
        Layout.fillWidth : true
        Layout.maximumWidth : grid.width / 3
        Layout.fillHeight : true
      }
      Rectangle {
        Layout.row : 2
        Layout.column : 1
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.preferredHeight : requestWrapper.height
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
        Layout.preferredHeight : requestWrapper.height
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