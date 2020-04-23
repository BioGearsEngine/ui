<<<<<<< HEAD
import QtQuick 2.4
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

ControlsForm {
  id: root
  signal restartClicked()
  signal pauseClicked(bool paused)
  signal playClicked()
  signal speedToggled(int speed)
  signal stateLoadedFromMenu()

  signal patientMetricsChanged(PatientMetrics metrics )
  signal patientStateChanged(PatientState patientState )
  // signal patientConditionsChanged(PatientConditions conditions )
  signal patientPhysiologyChanged(PhysiologyModel model)
  signal patientStateLoad()
  signal simulationTimeAdvance(double time)

  signal activeSubstanceAdded(Substance sub)
  signal substanceDataChanged(real time, var subData)

  signal openActionDrawer()

  property PhysiologyModel bgData
  property Scenario scenario : biogears_scenario
  property ObjectModel actionModel : actionSwitchModel
  patientBox.scenario : biogears_scenario
  
  onStateLoadedFromMenu : {
    patientBox.updateDisplayText()
  }

  Scenario {
    id: biogears_scenario

    onPatientMetricsChanged: {
        root.respiratoryRate.value       = metrics.RespiratoryRate
        root.heartRate.value             = metrics.HeartRate 
        root.core_temp_c.value           = metrics.CoreTemp + "c"
        root.oxygenSaturation.value      = metrics.OxygenSaturation
        root.systolicBloodPressure.value = metrics.SystolicBloodPressure
        root.dystolicBloodPressure.value = metrics.DiastolicBloodPressure
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

    onPhysiologyChanged:  {
      bgData = model
      root.patientPhysiologyChanged(model)
      root.restartClicked();
      patientBox.checkDisplayText(scenario.patient_name());
    }  
                
    onStateLoad: {
      root.restartClicked()
    }

    onTimeAdvance: {
        var seconds = SimulationTime_s % 60
        var minutes = Math.floor(SimulationTime_s / 60) % 60
        var hours   = Math.floor(SimulationTime_s / 3600)

        seconds = (seconds<10) ? "0%1".arg(seconds) : "%1".arg(seconds)
        minutes = (minutes<10) ? "0%1".arg(minutes) : "%1".arg(minutes)

        playback.simulationTime = "%1:%2:%3".arg(hours).arg(minutes).arg(seconds)
        root.simulationTimeAdvance(SimulationTime_s)
    }
                
    onSubstanceDataChanged : {
      root.substanceDataChanged(time, subData);
    }

    onActiveSubstanceAdded : {
      root.activeSubstanceAdded(sub);
    }

    onRunningToggled : {
      patientBox.enabled = !biogears_scenario.isRunning || biogears_scenario.isPaused
      if( isRunning){
          playback.simButton.state = "Simulating";
      } else {
          playback.simButton.state = "Stopped";
      }
    }
    onPausedToggled : {
      patientBox.enabled = !biogears_scenario.isRunning || biogears_scenario.isPaused
      if( biogears_scenario.isRunning) {
        root.pauseClicked(isPaused)
        if( isPaused ){
            playback.simButton.state = "Paused";
        } else {
            playback.simButton.state = "Simulating";
        }
      }
    }
    onThrottledToggled : {
      if ( isThrottled ){
          playback.speedButton.state = "realtime";
      } else {
          playback.speedButton.state = "max";
      }
    }
  }

  ObjectModel {
    id : actionSwitchModel
    function addSwitch(actionData, onFunc, offFunc) {
      var actionComponent = Qt.createComponent("UIActionSwitch.qml");
	    if ( actionComponent.status != Component.Ready){
		    if (actionComponent.status == Component.Error){
			    console.log("Error : " + actionComponent.errorString() );
			    return;
		    }
	      console.log("Error : Action switch component not ready");
	    } else {
		    var actionSwitch = actionComponent.createObject(actionSwitchView,{ "nameLong" : actionData, "namePretty" : actionData.split(":")[0], "width" : actionSwitchView.width, "height" : 50});
        actionSwitch.toggleActionOn.connect(onFunc);
        if (offFunc){
          actionSwitch.toggleActionOff.connect(offFunc);
        } else {
          actionSwitch.supportDeactivate = false
        }
		    actionSwitchModel.append(actionSwitch);
	    }
    }
  }

  playback.onRestartClicked: {
    playback.simulationTime = "%1:%2:%3".arg("0").arg("00").arg("00")
    patientBox.loadState();
    root.restartClicked()
  } 
  playback.onPauseClicked: {
    biogears_scenario.pause_play()
  }
  playback.onPlayClicked: {
    biogears_scenario.run()
    root.playClicked()
  }
  playback.onRateToggleClicked: {
    if (biogears_scenario.isThrottled) {
      biogears_scenario.speed_toggle(2)
      root.speedToggled(2)
    } else {
      biogears_scenario.speed_toggle(1)
      root.speedToggled(1)
    }
  } 
  openDrawerButton.onPressed : {
    root.openActionDrawer();
  }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:600;width:300}
}
 ##^##*/
=======
import QtQuick 2.4
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

ControlsForm {
  id: root
  signal restartClicked()
  signal pauseClicked(bool paused)
  signal playClicked()
  signal speedToggled(int speed)

  signal patientMetricsChanged(PatientMetrics metrics )
  signal patientStateChanged(PatientState patientState )
  signal patientConditionsChanged(PatientConditions conditions )
  signal activeSubstanceAdded(Substance sub)
  signal substanceDataChanged(real time, var subData)

  signal openActionDrawer()

  property Scenario scenario : biogears_scenario
  property ObjectModel actionModel : actionSwitchModel
  //patientBox.scenario : biogears_scenario
    

  Scenario {
    id: biogears_scenario
    onPatientMetricsChanged: {
      if(metrics){
        root.respiratoryRate.value        = metrics.RespiratoryRate
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

    onSubstanceDataChanged : {
      root.substanceDataChanged(time, subData);
    }

    onActiveSubstanceAdded : {
      root.activeSubstanceAdded(sub);
    }

    onStateChanged : {
      root.restartClicked();
    }
    onRunningToggled : {
      //patientBox.enabled = !biogears_scenario.isRunning || biogears_scenario.isPaused
      if( isRunning){
          playback.simButton.state = "Simulating";
      } else {
          playback.simButton.state = "Stopped";
      }
    }
    onPausedToggled : {
      //patientBox.enabled = !biogears_scenario.isRunning || biogears_scenario.isPaused
      if( biogears_scenario.isRunning) {
        root.pauseClicked(isPaused)
        if( isPaused ){
            playback.simButton.state = "Paused";
        } else {
            playback.simButton.state = "Simulating";
        }
      }
    }
    onThrottledToggled : {
      if ( isThrottled ){
          playback.speedButton.state = "realtime";
      } else {
          playback.speedButton.state = "max";
      }
    }
  }

  ObjectModel {
    id : actionSwitchModel
    function addSwitch(actionData, onFunc, offFunc) {
      var actionComponent = Qt.createComponent("UIActionSwitch.qml");
      if ( actionComponent.status != Component.Ready){
        if (actionComponent.status == Component.Error){
          console.log("Error : " + actionComponent.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      } else {
        var actionSwitch = actionComponent.createObject(actionSwitchView,{ "nameLong" : actionData, "namePretty" : actionData.split(":")[0], "width" : actionSwitchView.width, "height" : 50});
        actionSwitch.toggleActionOn.connect(onFunc);
        if (offFunc){
          actionSwitch.toggleActionOff.connect(offFunc);
        } else {
          actionSwitch.supportDeactivate = false
        }
        actionSwitchModel.append(actionSwitch);
      }
    }
  }

  playback.onRestartClicked: {
    playback.simulationTime = "%1:%2:%3".arg("0").arg("00").arg("00")
    //patientBox.loadState();
    root.restartClicked()
  } 
  playback.onPauseClicked: {
    biogears_scenario.pause_play()
  }
  playback.onPlayClicked: {
    biogears_scenario.run()
    root.playClicked()
  }
  playback.onRateToggleClicked: {
    if (biogears_scenario.isThrottled) {
      biogears_scenario.speed_toggle(2)
      root.speedToggled(2)
    } else {
      biogears_scenario.speed_toggle(1)
      root.speedToggled(1)
    }
  } 
  openDrawerButton.onPressed : {
    root.openActionDrawer();
  }

}

/*##^## Designer {
    D{i:0;autoSize:true;height:600;width:300}
}
 ##^##*/
>>>>>>> Nested menu patient selection
