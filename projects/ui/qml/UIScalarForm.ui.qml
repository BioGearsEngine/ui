import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3

Rectangle {
    property alias value: value.text
    property alias name: name.text
    Layout.margins: 5
    Layout.preferredWidth: 50
    Layout.preferredHeight: 75
    Text {
        id: value
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        text: "22"
        font.pointSize: 20
    }
    Label {
        id: name
        text: "Age:"
        font.pointSize: 10

        anchors.top: value.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }
}
