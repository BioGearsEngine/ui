import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12

import com.biogearsengine.ui.scenario 1.0
ApplicationWindow {
    visible: true

    width: 1280
    height: 768

    MainForm {
        anchors.fill : parent

        Component.onCompleted : {
            console.log("Completed"+scenario.patient_name())
            //var metrics = scenario.get_pysiology_metrics()
            //var state = scenario.get_physiology_state()
            var conditions = scenario.get_pysiology_conditions()
            console.log(state.alive)
        }
    }

    Scenario {
        id : scenario
    }
}


/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
