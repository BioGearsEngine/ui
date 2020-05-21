import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12

import QtQuick 2.4
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

ControlsForm {
  id: root
  signal restartClicked(int simulation_time_s)
  signal pauseClicked(bool paused)
  signal playClicked()
  signal speedToggled(int speed)

  signal patientMetricsChanged(PatientMetrics metrics )
  signal patientStateChanged(PatientState patientState )
  // signal patientConditionsChanged(PatientConditions conditions )
  signal patientPhysiologyChanged(PhysiologyModel model)
  signal patientStateLoad()

  signal activeSubstanceAdded(Substance sub)
  signal substanceDataChanged(real time_s, var subData)

  signal openActionDrawer()

  property PhysiologyModel bgData
  property Scenario scenario : biogears_scenario
  property ObjectModel actionModel : actionSwitchModel

  function seconds_to_clock_time(SimulationTime_s) {
        var v_seconds = SimulationTime_s % 60
        var v_minutes = Math.floor(SimulationTime_s / 60) % 60
        var v_hours   = Math.floor(SimulationTime_s / 3600)

        v_seconds = (v_seconds<10) ? "0%1".arg(v_seconds) : "%1".arg(v_seconds)
        v_minutes = (v_minutes<10) ? "0%1".arg(v_minutes) : "%1".arg(v_minutes)

        return "%1:%2:%3".arg(v_hours).arg(v_minutes).arg(v_seconds)
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
      root.restartClicked(scenario.time_s);
    }

    onStateLoad: {
      //Check if the patient base name (format : :"patient@xs") is substring of the text displayed in the patient menu
      // (format : "Patient: patient@xs").  If it is, then we are up to date.  If not, we need to search patient file map 
      // to find the right name and set it as the current text in the patient button.
      if (!patientMenu.patientText.text.includes(stateBaseName)){
        let l_menu = patientMenu.patientMenuListModel
        for (let l_index = 0; l_index < l_menu.count; ++l_index){
          let patient = l_menu.get(l_index).patientName
          if (stateBaseName.includes(patient)){
            //Found the right patient, now search for the specific file associated with patient state
            let l_patientSubMenu = l_menu.get(l_index).props
            for (let l_subIndex = 0; l_subIndex < l_patientSubMenu.count; ++l_subIndex){
              let l_patientFile = l_patientSubMenu.get(l_subIndex).propName
              if (l_patientFile.includes(stateBaseName)){
                patientMenu.patientText.text = "Patient: " + stateBaseName
                break;
              }
            }
            break;
          }
        }
      }
      root.restartClicked(scenario.get_simulation_time)
    }

    onNewStateAdded : {
      patientMenu.buildPatientMenu()
    }

    onTimeAdvance: {
      playback.simulationTime = seconds_to_clock_time(time_s)
    }

    onSubstanceDataChanged : {
      root.substanceDataChanged(time_s, subData);
    }

    onActiveSubstanceAdded : {
      root.activeSubstanceAdded(sub);
    }

    onRunningToggled : {
      if( isRunning){
          playback.simButton.state = "Simulating";
      } else {
          playback.simButton.state = "Stopped";
      }
    }
    onPausedToggled : {
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
      var v_actionComponent = Qt.createComponent("UIActionSwitch.qml");
	    if ( v_actionComponent.status != Component.Ready){
		    if (v_actionComponent.status == Component.Error){
			    console.log("Error : " + v_actionComponent.errorString() );
			    return;
		    }
	      console.log("Error : Action switch component not ready");
	    } else {
		    var v_actionSwitch = v_actionComponent.createObject(actionSwitchView,{ "nameLong" : actionData, "namePretty" : actionData.split(":")[0], "width" : actionSwitchView.width, "height" : 50});
        v_actionSwitch.toggleActionOn.connect(onFunc);
        if (offFunc){
          v_actionSwitch.toggleActionOff.connect(offFunc);
        } else {
          v_actionSwitch.supportDeactivate = false
        }
		    actionSwitchModel.append(v_actionSwitch);
	    }
    }
  }

  playback.onRestartClicked: {
    patientMenu.loadState(patientMenu.patientText.text.split(" ")[1]+".xml");
    let l_simulation_time_s = scenario.time_s
    playback.simulationTime = seconds_to_clock_time(l_simulation_time_s)
    root.restartClicked(l_simulation_time_s)
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

