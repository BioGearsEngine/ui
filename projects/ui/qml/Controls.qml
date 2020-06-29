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

  ActionModel {
    id : actionSwitchModel

    function add_binary_action(componentType) {
        var v_severityForm = Qt.createComponent(componentType);
        if ( v_severityForm.status == Component.Ready)  {
          var v_action = v_severityForm.createObject(actionSwitchView,{ "width" : actionSwitchView.width,  "Layout.fillWidth" : true,})
          v_action.scenario = biogears_scenario
          v_action.uuid = uuidv4()
          v_action.remove.connect(removeAction)
          actionSwitchModel.append(v_action)
        } else {
          if (v_severityForm.status == Component.Error){
            console.log("Error : " + v_severityForm.errorString() );
            return;
          }
          console.log("Error : Action switch component not ready");
        }
    }
    function add_single_range_action(componentType, props) {
      var v_severityForm = Qt.createComponent(componentType);
      if ( v_severityForm.status == Component.Ready)  {
        var v_action = v_severityForm.createObject(actionSwitchView,{ "nameLong" : props.description, "namePretty" : props.description.split(":")[0],
                                                                      "severity" : props.spinnerValue,
                                                                      "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                                              })
        v_action.scenario = biogears_scenario
        v_action.uuid = uuidv4()
        v_action.remove.connect(removeAction)

        actionSwitchModel.append(v_action)
      } else {
        if (v_severityForm.status == Component.Error){
          console.log("Error : " + v_severityForm.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function add_pain_stimulus_action(props) {
      var v_painStimulusForm = Qt.createComponent("UIPainStimulus.qml");
      if ( v_painStimulusForm.status == Component.Ready)  {
        var v_painStimulus = v_painStimulusForm.createObject(actionSwitchView,{ "nameLong" : props.description, "namePretty" : props.description.split(":")[0],
                                                                                "location" : props.location, "intensity" : props.painScore,
                                                                                "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                                              })
        v_painStimulus.scenario = biogears_scenario
        v_painStimulus.uuid = uuidv4()
        v_painStimulus.remove.connect(removeAction)

        actionSwitchModel.append(v_painStimulus)
      } else {
        if (v_painStimulusForm.status == Component.Error){
          console.log("Error : " + v_painStimulusForm.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function add_infection_action(props) {
      var v_actionComponent = Qt.createComponent("UIInfection.qml");
      if ( v_actionComponent.status == Component.Ready)  {
        var v_action = v_actionComponent.createObject(actionSwitchView,{  "location" : props.location, "mic" : props.mic, "severity" : props.severity,
                                                                          "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                                        })
        v_action.scenario = biogears_scenario
        v_action.uuid = uuidv4()
        v_action.remove.connect(removeAction)

        actionSwitchModel.append(v_action)
      } else {
        if (v_actionComponent.status == Component.Error){
          console.log("Error : " + v_actionComponent.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function add_hemorrhage_action(props) {
      var compartment = Qt.createComponent("UIHemorrhage.qml");
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{ "nameLong" : props.description, "namePretty" : props.description.split(":")[0],
                                                                                "compartment" : props.location, "rate" : props.rate,
                                                                                "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                                              })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function add_tension_pneumothorax_action(props) {
      var compartment = Qt.createComponent("UITensionPneumothorax.qml");
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{ "severity" : props.severity, "side" : props.side, "type" : props.type,
                                                                 "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function add_tramatic_brain_injury_action(props) {
      var compartment = Qt.createComponent("UITraumaticBrainInjury.qml");
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{ "type" : props.type, "severity" : props.severity,
                                                                  "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function add_needle_decompression_action(props) {
      var compartment = Qt.createComponent("UINeedleDecompression.qml");
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{ "side" : props.side,
                                                                  "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function add_tourniquet_action(props) {
      var compartment = Qt.createComponent("UITourniquet.qml");
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{ "compartment" : props.location,  "state" : props.level,
                                                                  "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function add_transfusion_action(props) {
      var compartment = Qt.createComponent("UITransfusion.qml");
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{ "rate" : props.rate,  "volume" : props.bagVolume,   "blood_type" : props.type,
                                                                  "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function add_compound_infusion_action(props) {
      var compartment = Qt.createComponent("UICompoundInfusion.qml");
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{ "rate" : props.rate,  "volume" : props.bagVolume,   "compound" : props.compound,
                                                                  "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function add_drug_administration_action(props) {
      var compartment = Qt.createComponent("UIDrugAdministration.qml");
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{ "adminRoute" : props.adminRoute, "drug" : props.substance,
                                                                 "dose" : props.dose,  "concentration" : props.concentration,   "rate" : props.rate,
                                                                 "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }

    function add_consume_meal_action(props){
      var compartment = Qt.createComponent("UIConsumeMeal.qml");
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{ "name" : props.mealName, "carbohydrate_mass" : props.carbohydrate, "water_volume" : props.water,
                                                                 "fat_mass" : props.fat,  "proten_mass" : props.protein, "calcium_mass" : props.calcium,
                                                                 "sodium_mass" : props.sodium, "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }

    //     //----------------------------------------------------------------------------------------
    // /// Helper function for setup_SubstanceActions
    // /// Takes props set by user and identifies correct Biogears action to call according to admin route
    // function apply_drugAction(props){
    //     let route = props.adminRoute
    //     let substance = props.substance
    //     let dose = props.dose
    //     let concentration = props.concentration
    //     let rate = props.rate
    //     let routeDisplay = route.split('-')[0] + ":"         //Shows "Bolus" in "Bolus-Intravenous"
    //     let routeDetail = route.split('-')[1]                //Shows "Intravenous" in "Bolus-Intravenous"
    //     let description = substance + " " + routeDisplay     //Overriding description for substances
    //     switch (route) {
    //         case 'Bolus-Intraarterial' :
    //             //Intraarterial is CDM::enumBolusAdministration::0
    //             description += "\n    Route = " + routeDetail  + "\n    Dose (mL) = " + dose + "\n    Concentration (ug/mL) = " + concentration
    //             actionModel.addSwitch(description, 
    //                                                         function () { scenario.create_substance_bolus_action(substance, 0, dose, concentration) } 
    //                                                         );
    //             break;
    //         case 'Bolus-Intramuscular' :
    //             description += "\n    Route = " + routeDetail  + "Dose (mL) = " + dose + "\n   Concentration (ug/mL) = " + concentration
    //             //Intramuscular is CDM::enumBolusAdministration::1
    //             actionModel.addSwitch(description, 
    //                                                         function () { scenario.create_substance_bolus_action(substance, 1, dose, concentration) } 
    //                                                         );
    //             break;
    //         case 'Bolus-Intravenous' :
    //             description += "\n    Route = " + routeDetail  + "\n    Dose (mL) = " + dose + "\n    Concentration (ug/mL) = " + concentration
    //             //Intravenous is CDM::enumBolusAdministration::2
    //             actionModel.addSwitch(description, 
    //                                                         function () { scenario.create_substance_bolus_action(substance, 2, dose, concentration) } 
    //                                                         );
    //             break;
    //         case 'Infusion-Intravenous' :
    //             description += "\n    Route = " + routeDetail  + "\n    Concentration (ug/mL) = " + concentration + "\n    Rate (mL/min) = " + rate
    //             actionModel.addSwitch(description, 
    //                                                         function () { scenario.create_substance_infusion_action(substance, concentration, rate)}, 
    //                                                         function () { scenario.create_substance_infusion_action(substance, 0.0, 0.0) }
    //                                                         );
    //             break;
    //         case 'Oral':
    //             description += "\n    Dose (mg) = " + dose
    //             //Oral (GI) is CDM::enumOralAdministration::1
    //             actionModel.addSwitch(description, 
    //                                                         function () { scenario.create_substance_oral_action(substance, 0, dose) } 
    //                                                         );
    //             break;
    //         case 'Transmucosal':
    //             description += "\n    Dose (mg) = " + dose
    //             //Transcmucosal is CDM::enumOralAdministration::0
    //             actionModel.addSwitch(description, 
    //                                                         function () { scenario.create_substance_oral_action(substance, 1, dose) } 
    //                                                         );
    //             close();
    //             break;
    //     }
    // }

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

