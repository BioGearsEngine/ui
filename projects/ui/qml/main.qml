import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

import com.biogearsengine.ui.scenario 1.0

ApplicationWindow {
    id: root
    visible: true

    width: 1280
    height: 768

    MainForm {
        anchors.fill : parent
        scenario : scenario
        Component.onCompleted : {
            console.log ("Starting Biogears with %1".arg(scenario.patient_name()))
        }
    }

    Scenario {
        id : scenario
    }
}



