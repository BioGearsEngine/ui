import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3

import "./data" as Requests

Page {
    id: root
    property alias bloodChemistry: bloodChemistry
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
        currentIndex:1
        clip:true 
        UIPlotSeries {
            id: bloodChemistry
            period: 4
            amplitude: 2
            timerOn: false
            Requests.BloodChemistry {
                id : bloodChemistryRequests
            }
        }
        UIPlotSeries {
            id: cardiovascular
            period: 2
            amplitude: 4
            timerOn: false
            Requests.Cardiovascular {
                id : cardiovascularRequests
            }
        }
        UIPlotSeries {
            id: drugs
            period: 2
            amplitude: 4
            timerOn: false
            Requests.Drugs {
                id : drugRequests
            }
        }
        UIPlotSeries {
            id: endocrine
            period: 10
            amplitude: 6
            timerOn: false
            Requests.Endocrine {
                id : endocrineRequests
            }
        }
        UIPlotSeries {
            id: energy
            period: 10
            amplitude: 6
            timerOn: false
            Requests.Energy {
                id : energyRequests
            }
        }
        UIPlotSeries {
            id: gastrointestinal
            period: 10
            amplitude: 6
            timerOn: false
            Requests.Gastrointestinal {
                id : gastrointestinalRequests
            }
        }
        UIPlotSeries {
            id: hepatic
            
            period: 10
            amplitude: 6
            timerOn: false
            Requests.Hepatic {
                id : hepaticRequests
            }
        }
        UIPlotSeries {
            id: nervous
            period: 10
            amplitude: 6
            timerOn: false
            Requests.Nervous {
                id : nervousRequests
            }
        }
        UIPlotSeries {
            id: renal
            period: 10
            amplitude: 6
            timerOn: false
            Requests.Renal {
                id : renalRequests
            }
        }
        UIPlotSeries {
            id: respiratory
            period: 10
            amplitude: 6
            timerOn: false
            Requests.Respiratory {
                id : respiratoryRequests
            }
        }
        UIPlotSeries {
            id: tissue
            period: 10
            amplitude: 6
            timerOn: false
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
