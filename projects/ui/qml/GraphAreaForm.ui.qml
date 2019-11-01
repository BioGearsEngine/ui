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

        UIGraph {
            id: graph1
            eatVal: 20.0
            eatColor: "green"
            notEatColor: "yellow"
        }

        UIGraph {
            id: graph2
            eatVal: 5.0
            eatColor: "red"
            notEatColor: "blue"
        }

        UIGraph {
            id: graph3
            eatVal: 60
            eatColor: "purple"
            notEatColor: "teal"
        }
    }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
