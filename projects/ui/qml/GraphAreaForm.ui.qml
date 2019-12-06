import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3

Page {
    id: root
    property alias graph1: graph1
    property alias graph2: graph2
    property alias graph3: graph3
    header: TabBar {
        id: graphTabBar
        contentHeight: 40
        font.pointSize: 12
        UITabButtonForm {
            id: vitalsButton
            text: qsTr("Vitals")
        }
        UITabButtonForm {
            id: cvButton
            text: qsTr("Cardiovascular")
        }
        UITabButtonForm {
            id: respButton
            text: qsTr("Respiratory")
        }
        currentIndex: 0
    }

    StackLayout {
        id: graphStackLayout
        anchors.fill: parent
        currentIndex: graphTabBar.currentIndex
        UIPlotSeries {
            id: graph1
            period: 4
            amplitude: 2
            timerOn: false
        }
        UIPlotSeries {
            id: graph2
            period: 2
            amplitude: 4
            timerOn: false
        }
        UIPlotSeries {
            id: graph3
            period: 10
            amplitude: 6
            timerOn: false
        }
    }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
