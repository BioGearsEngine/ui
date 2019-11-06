import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.3

Page {
    id: root

    header: TabBar {
        id: graphTabBar
        contentHeight: 40
        font.pointSize: 12
        TabButton {
            id: vitalsButton
            text: qsTr("Vitals")

            contentItem: Text {
                text: vitalsButton.text
                font: vitalsButton.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                opacity: enabled ? 1.0 : 0.3
            }
            background: Rectangle {
                color: "steelblue"
                border.color: "steelblue"
                opacity: enabled ? 1 : 0.3
            }
        }
        TabButton {
            id: cvButton
            text: qsTr("Cardiovascular")

            contentItem: Text {
                text: cvButton.text
                font: cvButton.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                opacity: enabled ? 1.0 : 0.3
            }
            background: Rectangle {
                color: "steelblue"
                border.color: "steelblue"
                opacity: enabled ? 1.0 : 0.3
            }
        }
        TabButton {
            id: respButton
            text: "Respiratory"

            contentItem: Text {
                text: respButton.text
                font: respButton.font
                color: "white"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                opacity: enabled ? 1.0 : 0.3
            }
            background: Rectangle {
                color: "steelblue"
                border.color: "steelblue"
                opacity: enabled ? 1.0 : 0.3
            }
        }
        currentIndex: 0
    }

    StackLayout {
        id: graphStackLayout
        anchors.fill: parent
        currentIndex: graphTabBar.currentIndex
        UIPlotSeries {
            id: graph1
			period : 4
			amplitude : 2
			timerOn : false
			
        }

        UIPlotSeries {
            id: graph2
			period : 2
			amplitude : 4
			timerOn : false
        }

        UIPlotSeries {
            id: graph3
			period : 10
			amplitude: 6
			timerOn : false
        }
    }

	function start() {
		graph1.timerOn = true
		graph2.timerOn = true
		graph3.timerOn = true
	}

	function pause() {
		graph1.timerOn = false
		graph2.timerOn = false
		graph3.timerOn = false
	}

	function stop() {
		graph1.clear()
		graph2.clear()
		graph3.clear()
	}
}



/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
