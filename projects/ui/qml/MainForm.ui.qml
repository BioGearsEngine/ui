import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

import com.biogearsengine.ui.scenario 1.0

GridLayout {
    id: root
    columns: 2
    rows: 2

    property alias scenario : controls.scenario
    property alias controls : controls
    property alias graphArea: graphArea
    property alias consoleArea : consoleArea

    Controls {
        id: controls
        Layout.fillWidth: false
        Layout.alignment: Qt.AlignTop
        Layout.fillHeight: false
    }

    GraphArea {
        id: graphArea
        Layout.fillHeight: true
        Layout.fillWidth: true
    }
    TextArea {
        id:consoleArea
        Layout.columnSpan: 2
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: 200
    }

}

/*##^## Designer {
    D{i:0;autoSize:true;height:720;width:1280}
}
 ##^##*/
