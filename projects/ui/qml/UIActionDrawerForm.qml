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
    position : 0

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
                    color : inUse == "true" ? "steelblue" : "white"
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
                            if (model.inUse == "false"){
                                model.inUse ="true";
                                root.addButton(actionMenuModel.get(index))
                            }
                            else {
                                model.inUse = "false"
                                root.removeButton(actionMenuModel.get(index))
                            }
                        }
                    }
                    Keys.onReturnPressed : {
                        if (root.opened ){
                            actionListView.currentIndex = index;
                            if (model.inUse == "false"){
                                model.inUse ="true";
                                root.addButton(actionMenuModel.get(index))
                            }
                            else {
                                model.inUse = "false"
                                root.removeButton(actionMenuModel.get(index))
                            }       
                        }
                    }
                }
            }

            ListModel {
                id : actionMenuModel
                ListElement { name : "Exercise"; inUse : "false"; section : "Patient Actions"; property var func : function(name) {console.log("Support coming for: " + name)}}
                ListElement { name : "Consume Meal"; inUse : "false"; section : "Patient Actions"; property var func : function(name) {console.log("Support coming for: " + name)}}
                ListElement { name : "Hemorrhage"; inUse : "false"; section : "Insults";  func : function() {root.call_hemorrhage()}}
                ListElement { name : "Burn"; inUse : "false"; section : "Insults"; property var func : function(name) {scenario.create_burn_action()}}
                ListElement { name : "Pain Stimulus"; inUse : "false"; section : "Insults"; property var func : function(name) {console.log("Support coming for: " + name)}}
                ListElement { name : "Tension Pneumothorax"; inUse : "false"; section : "Insults"; property var func : function(name) {console.log("Support coming for: " + name)}}
                ListElement { name : "Sepsis"; inUse : "false"; section : "Insults"; property var func : function(name) {scenario.create_infection_action()}}
                ListElement { name : "Asthma Attack"; inUse : "false"; section : "Insults"; property var func : function(name) {scenario.create_asthma_action()}}
                ListElement { name : "Airway Obstruction"; inUse : "false"; section : "Insults"; property var func : function(name) {console.log("Support coming for: " + name)}}
                ListElement { name : "Traumatic Brain Injury"; inUse : "false"; section : "Insults"; property var func : function(name) {console.log("Support coming for: " + name)}}
                ListElement { name : "Bronchoconstriction"; inUse : "false"; section : "Insults" ; property var func : function(name) {console.log("Support coming for: " + name)}}
                ListElement { name : "Acute Stress"; inUse : "false"; section : "Insults"; property var func : function(name) {console.log("Support coming for: " + name)}}
                ListElement { name : "Substance Administration"; inUse : "false"; section : "Interventions"; property var func : function(name) {scenario.create_substance_infusion_action()}}
                ListElement { name : "Needle Decompression"; inUse : "false"; section : "Interventions"; property var func : function(name) {console.log("Support coming for: " + name)}}
                ListElement { name : "Inhaler"; inUse : "false"; section : "Interventions" ; property var func : function(name) {console.log("Support coming for: " + name)}}
                ListElement { name : "Anesthesia Machine"; inUse : "false"; section : "Interventions"; property var func : function(name) {console.log("Support coming for: " + name)}}
                ListElement { name : "Transfusion"; inUse : "false"; section : "Interventions"; property var func : function(name) {console.log("Support coming for: " + name)}}
                ListElement { name : "Diabetes (Type 1)"; inUse : "false"; section : "Conditions"; property var func : function(name) {console.log("Support coming for: " + name)}}
                ListElement { name : "Diabetes (Type 2)"; inUse : "false"; section : "Conditions"; property var func : function(name) {console.log("Support coming for: " + name)}}
                ListElement { name : "Bronchitis"; inUse : "false"; section : "Conditions"; property var func : function(name) {console.log("Support coming for: " + name)}}
            }
        }
        Button {
            id: applyButton
            Layout.preferredWidth : 0.5 * root
            Layout.alignment : Qt.AlignTop | Qt.AlignHCenter
            text : "Apply"
        }
    }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
