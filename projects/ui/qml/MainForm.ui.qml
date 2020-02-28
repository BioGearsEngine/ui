import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

import com.biogearsengine.ui.scenario 1.0

GridLayout {
    id: root
    columns: 2
    rows: 2

    rowSpacing:0
    columnSpacing:5
    
    property alias scenario : controls.scenario
    property alias controls : controls
    property alias actionModel : controls.actionModel
    property alias graphArea: graphArea
    property alias consoleArea : consoleArea
    property alias actionDrawer : actionDrawer

    ActionDrawer {
        id: actionDrawer
        scenario : root.scenario
        controls : root.controls
        actionModel : root.actionModel
    }
    Controls {
        id: controls
        Layout.fillWidth: false
        Layout.alignment: Qt.AlignTop
        Layout.fillHeight: false
        Layout.rowSpan : 2

        onPatientMetricsChanged : {
          graphArea.metricUpdates(metrics)
        }
        onPatientConditionsChanged : {
          graphArea.conditionUpdates(conditions)
        }
        onPatientStateChanged : {
          graphArea.stateUpdates(state)
        }
        onSubstanceDataChanged : {
          graphArea.substanceDataUpdates(time, subData)
        }
        onActiveSubstanceAdded : {
          graphArea.newActiveSubstance(sub)
        }
    }

    GraphArea {
        id: graphArea
        
        Layout.preferredHeight:root.height * (3./4.);
        Layout.fillWidth: true
        Layout.fillHeight: false
        Layout.margins:0
    }
    LuaConsole {
        id:consoleArea
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
