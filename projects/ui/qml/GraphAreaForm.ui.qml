import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3
import QtCharts 2.3

import "./data" as Requests

Page {
    id: root
    property alias bloodChemistry: bloodChemistrySeries
    property alias cardiovascular: cardiovascular
    property alias drugs: drugs
    property alias endocrine: endocrine
    property alias energy: energy
    property alias gastrointestinal: gastrointestinal
    property alias hepatic: hepatic
    property alias nervous: nervous
    property alias renal: renal
    property alias respiratory: respiratory
    property alias tissue: tissue

    header:  RowLayout {
        id: headerBar
        Layout.fillWidth : true
        Layout.fillHeight : true
        Button {
            id: previous
            text: "Prev"
            display: AbstractButton.IconOnly
            icon.source: "qrc:/icons/prev.png"
            icon.name: "terminate"
            icon.color: "transparent"
            
            background: Rectangle {
                color:"transparent"
            }
            onClicked: {
                if ( plots.currentIndex == 0 ) {
                    plots.currentIndex = plots.count -1 ;
                } else {
                    plots.currentIndex = plots.currentIndex - 1
                }
            }
        }
        SwipeView {
            contentHeight: 40
            Layout.fillWidth : true
            Layout.preferredWidth : 200
            Layout.preferredHeight : 40
            font.pointSize: 12
            clip:true 
            UITabButtonForm {
                id: bloodChemistryButton
                text: qsTr("BloodChemistry")
            }
            UITabButtonForm {
                id: cardiovascularButton
                text: qsTr("Cardiovascular")
            }
            UITabButtonForm {
                id: drugsButton
                text: qsTr("Drugs")
            }
            UITabButtonForm {
                id: endocrineButton
                text: qsTr("Endocrine")
            }
            UITabButtonForm {
                id: energyButton
                text: qsTr("Energy")
            }
            UITabButtonForm {
                id: gastronintestinalButton
                text: qsTr("Gastrointestinal")
            }
            UITabButtonForm {
                id: hepaticButton
                text: qsTr("Hepatic")
            }
            UITabButtonForm {
                id: nervousButton
                text: qsTr("Nervous")
            }
            UITabButtonForm {
                id: renalButton
                text: qsTr("Renal")
            }
            UITabButtonForm {
                id: respritoryButton
                text: qsTr("Respiratory")
            }
            UITabButtonForm {
                id: tissueButton
                text: qsTr("Tissue")
            }
            currentIndex: plots.currentIndex
        }
        Button {
            id: filterMenuButton
            text: "Filter Menu"
            display: AbstractButton.IconOnly
            icon.source: "qrc:/icons/menu.png"
            icon.name: "terminate"
            icon.color: "transparent"
            onClicked: {}
            background: Rectangle {
                color:"transparent"
            }
            Rectangle {
                id: filterMenu
                anchors.top : filterMenuButton.bottom; anchors.right : filterMenuButton.right
                height: root.height
                width: root.width / 4
                color : Material.color(Material.Grey)
                ColumnLayout {
                    anchors.top : filterMenu.top; anchors.left : filterMenu.left
                    Repeater {
                        model: 10
                        Row {
                            CheckBox {
                                text: qsTr("I'm item") + "%1".arg(index)
                                checked: false
                            
                            }
                        }
                    }
                }

            }
        }
        Button {
            id: next
            text: "Next"
            display: AbstractButton.IconOnly
            icon.source: "qrc:/icons/next.png"
            icon.name: "terminate"
            icon.color: "transparent"
            onClicked: {
                if ( plots.currentIndex == plots.count -1 ) {
                    plots.currentIndex = 0;
                } else {
                    plots.currentIndex = plots.currentIndex + 1
                }
            }
            background: Rectangle {
                color:"transparent"
            }
        }
    }
    
    SwipeView {
        id: plots
        anchors.fill: parent
        currentIndex:0
        clip:true 
        UIPlotSeries {
            id: bloodChemistrySeries
            property Item requests : 
            Requests.BloodChemistry {
                id : bloodChemistryRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: cardiovascular
            property Item requests : 
            Requests.Cardiovascular {
                id : cardiovascularRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: drugs
            property Item requests :
            Requests.Drugs {
                id : drugRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: endocrine
            property Item requests :
            Requests.Endocrine {
                id : endocrineRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: energy
            property Item requests :
            Requests.Energy {
                id : energyRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: gastrointestinal
            property Item requests :
            Requests.Gastrointestinal {
                id : gastrointestinalRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: hepatic
            property Item requests :
            Requests.Hepatic {
                id : hepaticRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: nervous
            property Item requests :
            Requests.Nervous {
                id : nervousRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: renal
            property Item requests :
            Requests.Renal {
                id : renalRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: respiratory
            property Item requests :
            Requests.Respiratory {
                id : respiratoryRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
        UIPlotSeries {
            id: tissue
            property Item requests :
            Requests.Tissue {
                id : tissueRequests
            }
            property ValueAxis axisX : ValueAxis {
                property int tickCount : 0
                titleText : "Simulation Time"
                min: 0
                max : 60
            }
        }
    }
    PageIndicator {
    id: indicator

    count: plots.count
    currentIndex: plots.currentIndex

    anchors.bottom: plots.bottom
    anchors.horizontalCenter: plots.horizontalCenter
}


}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
