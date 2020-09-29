import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

import com.biogearsengine.ui.scenario 1.0
import QtQuick.Window 2.12

GridLayout {
    id: root
    columns: 2
    rows: 3
    rowSpacing:0
    columnSpacing:0
    property alias scenario : controls.scenario
    property alias menuArea : menuArea
    property alias controls : controls
    property alias actionModel : controls.actionModel
    property alias graphArea: graphArea
    property alias consoleArea : consoleArea
    property alias actionDrawer : actionDrawer

    MenuArea {
      id: menuArea
      Layout.row : 0
      Layout.column : 0
      Layout.preferredWidth : root.width * (1/4) - root.columnSpacing / 2;
    }

    ActionDrawer {
      id: actionDrawer
      scenario : root.scenario
      controls : root.controls
      actionModel : root.actionModel
    }
    Controls {
      id: controls
      Layout.row : 1
      Layout.column : 0
      Layout.fillWidth: true
      Layout.maximumWidth : root.width * (1/4) - root.columnSpacing / 2;
      Layout.fillHeight: true
      Layout.rowSpan : 2
    }

    GraphArea {
      id: graphArea
      Layout.row : 0
      Layout.column : 1
      Layout.rowSpan : 2
      Layout.fillWidth: true
      Layout.maximumWidth : root.width * (3/4) - root.columnSpacing / 2;
      Layout.fillHeight: false
      Layout.preferredHeight:root.height * (3./4.)-10;
      Layout.margins:0
    }
    LuaConsole {
      id:consoleArea
      Layout.row : 2
      Layout.column : 1
      Layout.fillWidth: true
      Layout.fillHeight: true
      Layout.preferredHeight : root.height * (1./4.) - 10;
      Layout.margins:0
      Layout.alignment : Qt.AlignTop
      feeds : root.scenario.feeds

    }

}

/*##^## Designer {
    D{i:0;autoSize:true;height:720;width:1280}
}
 ##^##*/
