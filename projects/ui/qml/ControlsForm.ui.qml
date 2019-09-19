import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12

Item {
    property alias backgroundColor: rectangle.color

    Material.theme: Material.Light
    Material.accent: Material.LightBlue

    Rectangle {
        id: rectangle
        anchors.fill: parent

        color: "White"

        ColumnLayout {
            anchors.fill: parent
            spacing: 5
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Label {
                    Layout.fillHeight: true
                    Layout.rightMargin: 5
                    id: element
                    text: qsTr("Controls")
                    font.pixelSize: 12
                }
                TextField {
                    placeholderText: "What Ever"
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Label {
                    Layout.fillHeight: true
                    Layout.rightMargin: 5
                    text: qsTr("Controls")
                    font.pixelSize: 12
                }
                TextField {
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                }
                Label {
                    Layout.fillHeight: true
                    Layout.rightMargin: 5
                    text: qsTr("Controls")
                    font.pixelSize: 12
                }
                TextField {
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                }
                Label {
                    Layout.fillHeight: true
                    Layout.rightMargin: 5

                    text: qsTr("Controls")
                    font.pixelSize: 12
                }
                TextField {
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                Label {
                    Layout.fillHeight: true
                    Layout.rightMargin: 5
                    text: qsTr("Controls")
                    font.pixelSize: 12
                }
                TextField {
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                }
                Label {
                    Layout.fillHeight: true
                    Layout.rightMargin: 5
                    text: qsTr("Controls")
                    font.pixelSize: 12
                }
                TextField {
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                }
                Label {
                    Layout.fillHeight: true
                    Layout.rightMargin: 5

                    text: qsTr("Controls")
                    font.pixelSize: 12
                }
                TextField {
                    text: qsTr("Text Input")
                    font.pixelSize: 12
                }
            }

            GridLayout {
                Layout.preferredWidth: parent.width
                Layout.fillWidth: true
                layoutDirection: GridLayout.LeftToRight
                columns: 2
                Rectangle {
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: 50
                    color: 'blue'
                }
                Rectangle {
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: 50
                    color: 'green'
                }
                Label {
                    text: "Heart Rate"
                }
                Label {
                    text: 'Static Blood Presure'
                }
            }
            GridLayout {
                Layout.preferredWidth: parent.width
                Layout.fillWidth: true
                layoutDirection: GridLayout.LeftToRight
                columns: 2
                Rectangle {
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: 50
                    color: 'blue'
                }
                Rectangle {
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: 50
                    color: 'green'
                }
                Label {
                    text: "Heart Rate"
                }
                Label {
                    text: 'Static Blood Presure'
                }
            }
            GridLayout {
                Layout.preferredWidth: parent.width
                Layout.fillWidth: true
                layoutDirection: GridLayout.LeftToRight
                columns: 2
                Rectangle {
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: 50
                    color: 'blue'
                }
                Rectangle {
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: 50
                    color: 'green'
                }
                Label {
                    text: "Heart Rate"
                }
                Label {
                    text: 'Static Blood Presure'
                }
            }

            Rectangle {
                color: 'steelblue'
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
    }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:500;width:800}
}
 ##^##*/
