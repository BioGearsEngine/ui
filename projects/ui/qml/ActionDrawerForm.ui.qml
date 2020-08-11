import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12

import com.biogearsengine.ui.scenario 1.0

Drawer {
    property alias applyButton : applyButton
    property alias actionMenuModel : actionMenuModel
    width : parent.width * 0.2
    height : parent.height
    edge : Qt.LeftEdge
    interactive : true
    closePolicy : Popup.NoAutoClose
    position : 0
     dim: false
    ColumnLayout {
        id : drawerColumn
        anchors.fill : parent
            
        Item {
            Layout.fillWidth : true
            Layout.alignment: Qt.AlignTop
            implicitHeight : root.parent.height * 0.8

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
                        color : "#7CB342"
                        width : parent.width
                        height : childrenRect.height
                        Text {
                            anchors.horizontalCenter : parent.horizontalCenter
                            text : section
                            font.pointSize : 14
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
                    color : ListView.isCurrentItem ? "steelblue" : "white"
                    border.color: "black"
                    border.width : ListView.isCurrentItem ? 2 : 0
                    Text {
                        id: delegateText
                        anchors.verticalCenter : parent.verticalCenter
                        leftPadding: 5
                        text : name
                        font.pointSize : 12
                        Layout.alignment : Qt.AlignVCenter
                    }
                    MouseArea {
                        anchors.fill : parent
                        onClicked : {
                            actionListView.currentIndex = index;
                            func(actionMenuModel.get(index))
                        }
                    }
                    Keys.onReturnPressed : {
                        if (root.opened ){
                            actionListView.currentIndex = index;
                            root.addButton(actionMenuModel.get(index))      
                        }
                    }
                }
            }

            ListModel {
                id : actionMenuModel
                ListElement { name : "Exercise"; section : "Patient Actions"; property var func : function(actionItem) {root.setup_exercise(actionItem)}}
                ListElement { name : "Consume Meal"; section : "Patient Actions"; property var func : function(actionItem) {root.setup_consumeMeal(actionItem)}}
                ListElement { name : "Acute Respiratory Distress"; section : "Insults"; property var func : function(actionItem) { root.setup_ards(actionItem)}}
                ListElement { name : "Acute Stress"; section : "Insults"; property var func : function(actionItem) {root.setup_acuteStress(actionItem)}}
                ListElement { name : "Airway Obstruction"; section : "Insults"; property var func : function(actionItem) {root.setup_airwayObstruction(actionItem)}}
                ListElement { name : "Apnea"; section : "Insults"; property var func : function(actionItem) {root.setup_apnea(actionItem)}}
                ListElement { name : "Asthma Attack"; section : "Insults"; property var func : function(actionItem) {root.setup_asthma(actionItem)}}
                ListElement { name : "Bronchoconstriction"; section : "Insults" ; property var func : function(actionItem) {root.setup_bronchoconstriction(actionItem)}}
                ListElement { name : "Burn"; section : "Insults"; property var func : function(actionItem) {root.setup_burn(actionItem)}}
                ListElement { name : "Cardiac Arrest"; section : "Insults"; property var func : function(actionItem) {root.setup_cardiacArrest(actionItem)}}
                ListElement { name : "Hemorrhage"; section : "Insults";  func : function(actionItem) {root.setup_hemorrhage(actionItem)}}
                ListElement { name : "Infection";  section : "Insults"; property var func : function(actionItem) {root.setup_infection(actionItem)}}
                ListElement { name : "Pain Stimulus"; section : "Insults"; property var func : function(actionItem) {root.setup_painStimulus(actionItem)}}
                ListElement { name : "Tension Pneumothorax"; section : "Insults"; property var func : function(actionItem) {root.setup_tensionPneumothorax(actionItem)}}
                ListElement { name : "Traumatic Brain Injury"; section : "Insults"; property var func : function(actionItem) {root.setup_traumaticBrainInjury(actionItem)}}
                ListElement { name : "Administer Drugs"; section : "Interventions"; property var func : function(actionItem) {root.setup_drugActions(actionItem)}}
                ListElement { name : "Administer Fluids"; section : "Interventions"; property var func : function(actionItem) { root.setup_fluidInfusion(actionItem)}}
                ListElement { name : "Needle Decompression"; section : "Interventions"; property var func : function(actionItem) {root.setup_needleDecompression(actionItem)}}
                ListElement { name : "Tourniquet"; section : "Interventions"; property var func : function(actionItem) { root.setup_tourniquet(actionItem)}}
                ListElement { name : "Transfusion"; section : "Interventions"; property var func : function(actionItem) {root.setup_transfusion(actionItem)}}
                ListElement { name : "Inhaler"; section : "Interventions" ; property var func : function(actionItem) {root.setup_inhaler(actionItem)}}
                ListElement { name : "Anesthesia Machine"; section : "Interventions"; property var func : function(actionItem) {root.setup_anesthesia_machine(actionItem)}}
                ListElement { name : "Diabetes (Type 1)"; section : "Conditions"; property var func : function(actionItem) {root.unsupported_action(actionItem)}}
                ListElement { name : "Diabetes (Type 2)"; section : "Conditions"; property var func : function(actionItem) {root.unsupported_action(actionItem)}}
                ListElement { name : "Bronchitis"; section : "Conditions"; property var func : function(actionItem) {root.unsupported_action(actionItem)}}
            }
        }
        Button {
            id: applyButton
            Layout.preferredWidth : 0.5 * root
            Layout.alignment : Qt.AlignTop | Qt.AlignHCenter
            text : "Close"
        }
    }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
