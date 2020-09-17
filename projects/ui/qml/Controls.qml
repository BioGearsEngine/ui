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

  signal dataRequestModelChanged(DataRequestModel requestTree)
  signal patientMetricsChanged(PatientMetrics metrics )
  signal patientStateChanged(PatientState patientState )
  signal patientPhysiologyChanged(PhysiologyModel model)
  signal patientStateLoad()
  signal scenarioFileLoaded(EventModel events, var requests)
  signal newActiveSubstance(var subIndex)
  signal substanceDataChanged(real time_s, var subData)
  signal openActionDrawer()

  property PhysiologyModel bgData
  property Urinalysis urinalysisData
  property DataRequestModel bgRequests
  property Scenario scenario : biogears_scenario
  property ObjectModel actionModel : actionSwitchModel
  
  function requestUrinalysis() {
	  root.scenario.request_urinalysis();
  }

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
    onDataRequestModelChanged : {
      bgRequests = requestTree
      root.dataRequestModelChanged(bgRequests)
    }
    onScenarioFileLoaded : {
      root.scenarioFileLoaded(events, requests)
    }
    onPatientMetricsChanged: {
        root.respiratoryRate.value.text       = metrics.RespiratoryRate
        root.heartRate.value.text             = metrics.HeartRate 
        root.core_temp_c.value.text           = metrics.CoreTemp + "c"
        root.oxygenSaturation.value.text      = metrics.OxygenSaturation
        root.systolicBloodPressure.value.text = metrics.SystolicBloodPressure
        root.dystolicBloodPressure.value.text = metrics.DiastolicBloodPressure
    }
    onPatientStateChanged: {
      root.age_yr.value.text    = patientState.Age
      root.gender.value.text    = patientState.Gender
      root.height_cm.value.text = patientState.Height + " cm"
      root.weight_kg.value.text = patientState.Weight + " kg"
      root.condition.value.text = patientState.ExerciseState
      root.bodySufaceArea.value.text       = patientState.BodySurfaceArea
      root.bodyMassIndex.value.text        = patientState.BodyMassIndex
      root.fat_pct.value.text              = patientState.BodyFat

      root.patientStateChanged(patientState)
    }	
    onUrinalysis_completed: {
	    root.urinalysisData = urinalysis
    }
    onPhysiologyChanged:  {
      bgData = model
      root.patientPhysiologyChanged(model)
      root.restartClicked(scenario.time_s);
    }
    onSubstanceActivated : {
      root.newActiveSubstance(subIndex)
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
        if ( isPaused ){
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
  ActionModel {
    id : actionSwitchModel
    actionSwitchView : root.actionSwitchView
    
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
  function uuidv4() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }
  function removeAction( uuid) {
    console.log(uuid)
    for ( let i = 0; i < actionSwitchModel.count; ++i){
      console.log (actionSwitchModel, actionSwitchModel.get(i), actionSwitchModel.get(i).uuid)
      if (actionSwitchModel.get(i).uuid === uuid){
        actionSwitchModel.remove(i)
      }
    }
  }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:600;width:300}
}
 ##^##*/

