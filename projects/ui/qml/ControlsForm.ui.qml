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

            GridLayout {
                Layout.preferredWidth: parent.width
                Layout.fillWidth: true
                layoutDirection: GridLayout.LeftToRight
                columns: 5
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
                Rectangle {
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredHeight: 50
                    Layout.preferredWidth: 50
                    color: 'blue'
                }
            }

            GridLayout {
                Layout.preferredWidth: parent.width
                Layout.fillWidth: true
                layoutDirection: GridLayout.LeftToRight
                columns: 2
                rows: 10
                TextArea {
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: 200
                    Layout.fillHeight: true
                    Layout.rowSpan: 4
                    Layout.column: 1
                    Layout.row: 1

                    color: 'blue'
                }

                TextArea {
                    Layout.alignment: Qt.AlignCenter
                    Layout.preferredWidth: 200
                    Layout.fillHeight: true
                    color: 'blue'
                    Layout.rowSpan: 5
                    Layout.column: 1
                    Layout.row: 5
                }
                Rectangle {
                    color: 'steelblue'
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 15
                    Layout.column: 2
                    Layout.row: 1
                }
                Rectangle {
                    color: 'steelblue'
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 15
                    Layout.column: 2
                    Layout.row: 2
                }
                Rectangle {
                    color: 'steelblue'
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 15
                    Layout.column: 2
                    Layout.row: 3
                }
                Rectangle {
                    color: 'steelblue'
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 15
                    Layout.column: 2
                    Layout.row: 4
                }
                Rectangle {
                    color: 'steelblue'
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 15
                    Layout.column: 2
                    Layout.row: 5
                }
                Rectangle {
                    color: 'steelblue'
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 15
                    Layout.column: 2
                    Layout.row: 6
                }
                Rectangle {
                    color: 'transparent'
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 15 * 5
                    Layout.column: 2
                    Layout.row: 7
                    Layout.rowSpan: 3
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
    D{i:0;autoSize:true;height:800;width:800}
}
 ##^##*/
