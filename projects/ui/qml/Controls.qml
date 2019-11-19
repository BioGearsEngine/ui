import QtQuick 2.4

import com.biogearsengine.ui.scenario 1.0
ControlsForm {
    id: root
    signal pauseClicked()
    signal playClicked()
    signal stopClicked()

    property alias running : advanceTimer.running
    property Scenario scenario :biogears_scenario

    patientBox.scenario : biogears_scenario
    Scenario {
        id: biogears_scenario
        onPatientMetricsChanged: {
                root.respritoryRate.value       = metrics.RespritoryRate
                root.heartRate.value            = metrics.HeartRate 
                root.core_temp_c.value          = metrics.CoreTemp + "c"
                root.oxygenSaturation.value     = metrics.OxygenSaturation
                root.systolicBloodPressure.value= metrics.SystolicBloodPressure
                root.dystolicBloodPressure.value= metrics.DiastolicBloodPressure
        }
        onPatientStateChanged: {
                root.age_yr.value    = patientState.Age
                root.gender.value    = patientState.Gender
                root.height_cm.value = patientState.Height + " cm"
                root.weight_kg.value = patientState.Weight + " kg"
                root.condition.value = patientState.ExerciseState
                root.bodySufaceArea.value       = patientState.BodySurfaceArea
                root.bodyMassIndex.value        = patientState.BodyMassIndex
                root.fat_pct.value              = patientState.BodyFat
        }
        onPatientConditionsChanged:{
        }
    }
    playback.onPauseClicked: {
        root.pauseClicked()
        console.log("Pausing BioGears")
        root.running = false
    }
    playback.onPlayClicked: {
        root.playClicked()
        root.running = true
        console.log("Starting BioGears")
    }
    playback.onStopClicked: {
        root.stopClicked()
        console.log("Stoping BioGears")
    }
    Timer {
      id: advanceTimer
      interval: 100; running: false; repeat: true
      onTriggered: biogears_scenario.step()
    }
}


























































/*##^## Designer {
    D{i:0;autoSize:true;height:600;width:300}
}
 ##^##*/
