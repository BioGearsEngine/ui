import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3

Rectangle {
    id: root
    property string text : "unasigned"

    Layout.fillWidth: true
    Layout.fillHeight: true

    Rectangle {
        anchors.fill : parent
        id:backgroundRect
        color: "steelblue"
        border.color: "steelblue"
        opacity: enabled ? 1.0 : 0.3

        Text {
        id:content
        anchors.centerIn : parent
        text: root.text
        font: Qt.application.font
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        opacity: enabled ? 1.0 : 0.3
        elide: Text.ElideRight
    }
    }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
