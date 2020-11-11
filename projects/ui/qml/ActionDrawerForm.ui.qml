import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12

import com.biogearsengine.ui.scenario 1.0

Drawer {
  id : actionDrawer
  signal actionSelected (int index, real loc, string name)
  property alias applyButton : applyButton
  property alias actionMenuModel : actionMenuModel
  property alias actionDialog : actionDialog
  height : parent.height
  edge : Qt.LeftEdge
  interactive : true
  closePolicy : Popup.NoAutoClose
  position : 0
  dim: true
  modal : true
  ColumnLayout {
    id : drawerColumn
    anchors.fill : parent
    spacing : 10
    Item {
      Layout.fillWidth : true
      Layout.fillHeight : true
      Layout.alignment: Qt.AlignTop
      ListView {
        id : actionListView
        anchors.fill: parent
        clip : true
        model : actionMenuModel
        delegate : actionMenuDelegate
        currentIndex : -1
        focus : true
        section {
          property : "section"
          delegate : Rectangle {
			id : sectionHeader
            color : "#2980b9"
            width : parent.width
            height : childrenRect.height
            Text {
				id : sectionText
              anchors.horizontalCenter : parent.horizontalCenter
              text : section
              font.pixelSize : 22
              color : "white"
            }
			function sectionImage () {
				if (sectionText.text == "Nutrition")
					return "icons/patient.svg"
				if (sectionText.text == "Exercise")
					return "icons/icon-round-question_mark.svg"
				if (sectionText.text == "Insults")
					return "icons/burn.svg"
				if (sectionText.text == "Administer Substances")
					return "icons/icon-round-question_mark.svg"
				if (sectionText.text == "Interventions")
					return "icons/nursing.svg"
				else
					return "icons/icon-round-question_mark.svg"
			}
			Image {
				anchors.right : parent.right
				anchors.rightMargin : 15
				anchors.verticalCenter : parent.verticalCenter
				height : sectionHeader.height * 0.75
				source : sectionImage()
				fillMode : Image.PreserveAspectFit
			}
          }
        }
      }
      Component {
        id : actionMenuDelegate
        Rectangle {
          id : delegateWrapper
          height : delegateText.height * 1.4
          width : root.width
          Layout.alignment : Qt.AlignVCenter
          color : ListView.isCurrentItem ? "#4CAF50" : "white"
          border.color: "#4CAF50"
          border.width : index == actionDialog.boundIndex ? 2 : 0
          Text {
            id: delegateText
            anchors.verticalCenter : parent.verticalCenter
            verticalAlignment : Text.AlignVCenter
            leftPadding: 5
            text : name
            font.pixelSize : 18
            color : delegateWrapper.ListView.isCurrentItem ? "white" : "black"
          }
          Image {
            anchors.right : parent.right
            anchors.rightMargin : 15
            anchors.verticalCenter : parent.verticalCenter
            height : delegateText.height * 0.5
            source : delegateWrapper.ListView.isCurrentItem ? "icons/openIndicatorWhite.png" : "icons/openIndicatorBlue.png"
            fillMode : Image.PreserveAspectFit
          }
          MouseArea {
            anchors.fill : parent
            onClicked : {
              actionListView.currentIndex = index;
              let relativeY = actionListView.currentItem.y - actionListView.contentY
              root.actionSelected(index, relativeY, actionMenuModel.get(index).name)
            }
            onEntered : {
              actionListView.currentIndex = index;
            }
            onExited : {
              actionListView.currentIndex = -1
            }
            hoverEnabled : true
          }
          Keys.onReturnPressed : {
            if (root.opened ){
              actionListView.currentIndex = index;
              //root.addButton(actionMenuModel.get(index))      
            }
          }
        }
      }
      ListModel {
        id : actionMenuModel
        ListElement { name : "Consume Meal"; section : "Nutrition"; property var func : function(props) { actionModel.add_consume_meal_action(props) }}
        ListElement { name : "Cycling"; section : "Exercise"; property var func : function (props) {actionModel.add_exercise_action(props)}}
        ListElement { name : "Running"; section : "Exercise"; property var func : function (props) {actionModel.add_exercise_action(props)}}
        ListElement { name : "Strength Training"; section : "Exercise"; property var func : function (props) {actionModel.add_exercise_action(props)}}
        ListElement { name : "Other Exercise"; section : "Exercise"; property var func : function (props) {actionModel.add_exercise_action(props)}}
        ListElement { name : "Acute Respiratory Distress"; section : "Insults"; property var func : function(props) {actionModel.add_single_range_action("UIAcuteRespiratoryDistress.qml" ,props)}}
        ListElement { name : "Acute Stress"; section : "Insults"; property var func : function(props) {actionModel.add_single_range_action("UIAcuteStress.qml" ,props)}}
        ListElement { name : "Airway Obstruction"; section : "Insults"; property var func : function(props) {actionModel.add_single_range_action("UIAirwayObstruction.qml" ,props)}}
        ListElement { name : "Apnea"; section : "Insults"; property var func : function(props) {actionModel.add_single_range_action("UIApnea.qml" ,props)}}
        ListElement { name : "Asthma Attack"; section : "Insults"; property var func : function(props) {actionModel.add_single_range_action("UIAsthmaAttack.qml" , props)}}
        ListElement { name : "Bronchoconstriction"; section : "Insults" ; property var func : function(props) {actionModel.add_single_range_action("UIBronchoconstriction.qml" ,props)}}
        ListElement { name : "Burn"; section : "Insults"; property var func : function(props) {actionModel.add_single_range_action("UIBurnWound.qml" ,props)}}
        ListElement { name : "Cardiac Arrest"; section : "Insults"; property var func : function() {actionModel.add_binary_action("UICardiacArrest.qml")}}
        ListElement { name : "Hemorrhage"; section : "Insults";  property var func : function(props) {actionModel.add_hemorrhage_action(props)}}
        ListElement { name : "Infection";  section : "Insults"; property var func : function(props) {actionModel.add_infection_action(props)}}
        ListElement { name : "Pain Stimulus"; section : "Insults"; property var func : function(props) {actionModel.add_pain_stimulus_action(props)}}
        ListElement { name : "Tension Pneumothorax"; section : "Insults"; property var func : function(props) {actionModel.add_tension_pneumothorax_action(props)}}
        ListElement { name : "Traumatic Brain Injury"; section : "Insults"; property var func : function(props) {actionModel.add_tramatic_brain_injury_action(props)}}
        ListElement { name : "Drug-Bolus"; section : "Administer Substances"; property var func : function(props) { actionModel.add_drug_administration_action(props) }}
        ListElement { name : "Drug-Infusion"; section : "Administer Substances"; property var func : function(props) { actionModel.add_drug_administration_action(props) }}
        ListElement { name : "Drug-Oral"; section : "Administer Substances"; property var func : function(props) { actionModel.add_drug_administration_action(props) }}
        ListElement { name : "Fluids-Infusion"; section : "Administer Substances"; property var func : function(props) { actionModel.add_compound_infusion_action(props) }}
        ListElement { name : "Transfusion"; section : "Administer Substances"; property var func : function(props){ actionModel.add_transfusion_action(props)}}
        ListElement { name : "Needle Decompression"; section : "Interventions"; property var func : function(props) {actionModel.add_needle_decompression_action(props)}}
        ListElement { name : "Tourniquet"; section : "Interventions"; property var func : function(props) {actionModel.add_tourniquet_action(props)}}
        ListElement { name : "Inhaler"; section : "Interventions" ; property var func : function(actionItem) {actionModel.add_binary_action("UIInhaler.qml")} }
        ListElement { name : "Anesthesia Machine"; section : "Interventions"; property var func : function (props) { actionModel.add_anesthesia_machine_action(props)}}
      }
    }
    UIBioGearsButtonForm {
        id: applyButton
        Layout.alignment : Qt.AlignTop | Qt.AlignHCenter
        implicitHeight : 40
        implicitWidth : 80
        text : "Close"
    }
    UIActionDialog {
      id : actionDialog
      x : actionDrawer.width
      visible : false
      property int boundIndex : -1
      onApplied : {
        if (validProps()) {
          actionMenuModel.get(boundIndex).func(dialogItem.props)
          boundIndex = -1
          close();
        } else {
          console.log(errorString)
        }
      }
      onRejected : {
        dialogLoader.sourceComponent = undefined;
        boundIndex = -1;
        close();
      }
      Connections {
        target : root
        onActionSelected : {
          if (index != actionDialog.boundIndex){
            actionDialog.dialogLoader.sourceComponent = undefined
            actionDialog.setContent(name) //Do this first to make sure height is updated before checking position
            if (loc + actionDialog.height > actionDrawer.height){
              actionDialog.y = actionDrawer.height - actionDialog.height
            } else {
              actionDialog.y = loc;
            }
            actionDialog.boundIndex = index;
            let actionName = actionMenuModel.get(index).name
            if (actionName === "Cardiac Arrest" || actionName === "Inhaler"){
              //No dialog opened for cardiac arrest, just apply action     
              actionMenuModel.get(index).func();
            } else {
              actionDialog.open();
            }
          } else {
            actionDialog.boundIndex = -1;
            actionDialog.close();
          }
        }
      }
    }
  }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
