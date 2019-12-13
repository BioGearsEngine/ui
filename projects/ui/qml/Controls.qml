import QtQuick 2.4

import com.biogearsengine.ui.scenario 1.0

ControlsForm {
    id: root
    signal pauseClicked()
    signal playClicked()
    signal stopClicked()

    signal patientMetricsChanged(PatientMetrics metrics )
    signal patientStateChanged(PatientState patientState )
    signal patientConditionsChanged(PatientConditions conditions )

    property alias running : advanceTimer.running
    property Scenario scenario : biogears_scenario
    patientBox.scenario : biogears_scenario

    Scenario {
        id: biogears_scenario
        onPatientMetricsChanged: {
            if(metrics){
                root.respritoryRate.value        = metrics.RespritoryRate
                root.heartRate.value             = metrics.HeartRate 
                root.core_temp_c.value           = metrics.CoreTemp + "c"
                root.oxygenSaturation.value      = metrics.OxygenSaturation
                root.systolicBloodPressure.value = metrics.SystolicBloodPressure
                root.dystolicBloodPressure.value = metrics.DiastolicBloodPressure
                root.patientMetricsChanged(metrics)
            }
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
                
                root.patientStateChanged(patientState)
        }
        onPatientConditionsChanged:{
            root.patientConditionsChanged(conditions)
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
    action_1.onPressed:{
        console.log("Hemorrhage Stop") 
        biogears_scenario.create_hemorrhage_action("Left Arm",0.0);
    } 
    action_2.onPressed:{
        console.log("Hemorrhage Mild")
        biogears_scenario.create_hemorrhage_action("Left Arm",5.0);
    } 
    action_3.onPressed:{
        console.log("Hemorrhage Extreme") 
        biogears_scenario.create_hemorrhage_action("Left Arm",100.0);
    } 
    action_4.onPressed:{
        console.log("ASthma Attack") 
    } 
    action_5.onPressed:{
        console.log("Morphine Drip") 
    } 
    action_6.onPressed:{
        console.log("Burn Patient 25%") 
    } 
    action_7.onPressed:{
        console.log("Mild Infection") 
    }
    Timer {
      id: advanceTimer
      interval: 1000; running: false; repeat: true
      onTriggered: biogears_scenario.step()
    }
}


























































/*##^## Designer {
    D{i:0;autoSize:true;height:600;width:300}
}
 ##^##*/
