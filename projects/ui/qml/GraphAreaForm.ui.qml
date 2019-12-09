import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3

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

    header: SwipeView {
        id: headerBar
        contentHeight: 40
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
    
    SwipeView {
        id: plots
        anchors.fill: parent
        currentIndex:0
        clip:true 
        UIPlotSeries {
            id: bloodChemistrySeries
            property alias requests : bloodChemistryRequests
            Requests.BloodChemistry {
                id : bloodChemistryRequests
            }
        }
        UIPlotSeries {
            id: cardiovascular
            Requests.Cardiovascular {
                id : cardiovascularRequests
            }
        }
        UIPlotSeries {
            id: drugs
            Requests.Drugs {
                id : drugRequests
            }
        }
        UIPlotSeries {
            id: endocrine
            Requests.Endocrine {
                id : endocrineRequests
            }
        }
        UIPlotSeries {
            id: energy
            Requests.Energy {
                id : energyRequests
            }
        }
        UIPlotSeries {
            id: gastrointestinal
            Requests.Gastrointestinal {
                id : gastrointestinalRequests
            }
        }
        UIPlotSeries {
            id: hepatic
            
            Requests.Hepatic {
                id : hepaticRequests
            }
        }
        UIPlotSeries {
            id: nervous
            Requests.Nervous {
                id : nervousRequests
            }
        }
        UIPlotSeries {
            id: renal
            Requests.Renal {
                id : renalRequests
            }
        }
        UIPlotSeries {
            id: respiratory
            Requests.Respiratory {
                id : respiratoryRequests
            }
        }
        UIPlotSeries {
            id: tissue
            Requests.Tissue {
                id : tissueRequests
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
