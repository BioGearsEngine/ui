import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12

Rectangle {
    id: page

    Layout.fillHeight: true
    Layout.fillWidth: true

    color: 'steelblue'

    RowLayout {
        anchors.fill: parent
        Controls {
            id: controls
            width: parent.width / 3.0

            Layout.fillHeight: true
            Layout.preferredWidth: 300

            backgroundColor: 'yellow'
        }

        GraphArea {
            id: graphArea

            Layout.fillHeight: true
            Layout.fillWidth: true

            backgroundColor: 'red'
        }
    }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:720;width:1280}
}
 ##^##*/
