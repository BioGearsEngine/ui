import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

RowLayout {
    id: root
    property alias name: name.text
    property alias value: value.text
    Label {
        id: name
        text: "Unset"
        font.pointSize: 8
        font.weight: Font.DemiBold
        font.bold: true
    }

    TextInput {
        id: value
        text: qsTr("Placeholder Text")
        font.weight: Font.Medium
        font.pixelSize: 10
    }
}




/*##^## Designer {
    D{i:0;height:25;width:200}
}
 ##^##*/
