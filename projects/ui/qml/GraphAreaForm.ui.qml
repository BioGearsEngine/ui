import QtQuick 2.4
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

Item {
    property alias backgroundColor: controls.color
    width: 400
    height: 400

    Rectangle {
        id: controls
        anchors.fill: parent

        Button {
            text: "press"
        }

        Text {
            anchors.centerIn: parent
            id: element
            x: 196
            y: 26
            text: qsTr("Graph Area")
            font.pixelSize: 12
        }
    }
}




/*##^## Designer {
    D{i:1;anchors_height:200;anchors_width:200;anchors_x:109;anchors_y:119}
}
 ##^##*/
