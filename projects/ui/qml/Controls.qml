import QtQuick 2.4
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

ControlsForm {
    id: root
    signal restartClicked()
    signal pauseClicked()
    signal playClicked()
    signal speedToggled(int speed)

    signal patientMetricsChanged(PatientMetrics metrics )
    signal patientStateChanged(PatientState patientState )
    signal patientConditionsChanged(PatientConditions conditions )
    signal actionMessageUpdate(string name, bool hoverStatus, string status, var coor)
    signal actionStatusUpdate(string name, string status);
    signal drawerOpenClosed()

    property bool running : false
    property bool paused : false
    property int speed  :1
    property Scenario scenario : biogears_scenario
    property ObjectModel actionModel : actionButtonModel
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
                

                var seconds = metrics.SimulationTime % 60
                var minutes = Math.floor(metrics.SimulationTime / 60) % 60
                var hours   = Math.floor(metrics.SimulationTime / 3600)

                seconds = (seconds<60) ? "0%1".arg(seconds) : "%1".arg(seconds)
                minutes = (minutes<60) ? "0%1".arg(minutes) : "%1".arg(minutes)

                playback.simulationTime = "%1:%2:%3".arg(hours).arg(minutes).arg(seconds)
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

    ObjectModel {
            id : actionButtonModel
            function addButton(menuElement) {
                var actionComponent = Qt.createComponent("UIActionButton.qml");
				if ( actionComponent.status != Component.Ready){
					if (actionComponent.status == Component.Error){
						console.log("Error : " + actionComponent.errorString() );
						return;
					}
					console.log("Error : Chart component not ready");
				} else {
					var actionObject = actionComponent.createObject(actionButtonView,{ "name" : menuElement.name, "width" : actionButtonView.cellWidth, "height" : actionButtonView.cellHeight });
					actionObject.actionClicked.connect(menuElement.func);
                    actionObject.actionHoverToggle.connect(actionMessageUpdate);
                    actionObject.actionActiveToggle.connect(actionStatusUpdate);
					actionButtonModel.append(actionObject);
				}
            }
     }

    playback.onRestartClicked: {
            console.log("Restarting BioGears")
            biogears_scenario.restart()
            root.stopClicked()
        } 
    playback.onPauseClicked: {
        console.log("Pausing BioGears")
        if(root.running)
        {
            root.paused = biogears_scenario.pause_play()
            patientBox.enabled = root.paused
        }
        root.pauseClicked()
    }
    playback.onPlayClicked: {
        console.log("Starting BioGears")
        biogears_scenario.run()
        root.running = true;
        root.playClicked()
         patientBox.enabled = !running
    }
    playback.onRateToggleClicked: {
        console.log("Setting BioGears run rate to %1".arg(speed))
        biogears_scenario.speed_toggle(speed)
        root.speedToggled(speed)
        root.speed = speed
    } 
    drawerToggle.onPressed : {
        root.drawerOpenClosed();
    }

    onActionMessageUpdate : {
        actionMessage.actionText = name + "\nStatus : " + status
        if (hoverStatus){
            actionMessage.x = coor.x
            actionMessage.y = coor.y
        }
        root.actionMessage.visible = hoverStatus
    }

    onActionStatusUpdate : {
        actionMessage.actionText = name + "\nStatus : " + status
    }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:600;width:300}
}
 ##^##*/
