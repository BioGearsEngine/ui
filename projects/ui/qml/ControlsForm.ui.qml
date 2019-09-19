import QtQuick 2.12
import QtQuick.Controls.Material 2.12

Item {
    property alias backgroundColor: rectangle.color

    Material.theme: Material.Light
    Material.accent: Material.LightBlue

    Rectangle {
        id: rectangle
        anchors.fill: parent

        color: "White"

        Text {
            anchors.centerIn: parent
            id: element
            x: 301
            y: 47
            text: qsTr("Controls")
            font.pixelSize: 12
        }
    }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
