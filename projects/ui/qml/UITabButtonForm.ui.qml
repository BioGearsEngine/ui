import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3

TabButton {
    id: root

    text: qsTr("Unset")

    contentItem: Text {
        text: root.text
        font: root.font
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




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
