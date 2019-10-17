import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3

ColumnLayout {
    property alias value: value.text
    property alias name: name.text

    Layout.preferredHeight: implicitHeight
    Layout.preferredWidth: implicitWidth
    Text {
        id: value
        Layout.alignment: Qt.AlignCenter
        text: "22"
        font.pointSize: 20
    }
    Label {
        id: name
        text: "Age:"
        font.pointSize: 10
        Layout.alignment: Qt.AlignHCenter
    }
}




/*##^## Designer {
    D{i:0;height:54;width:30}
}
 ##^##*/
