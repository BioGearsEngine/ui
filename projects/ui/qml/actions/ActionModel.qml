import QtQuick 2.4
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

  ObjectModel {
    id : actionSwitchModel
    property ListView actionSwitchView
    property double simulationTime : 0.0

    property var notification :     Component {
      id : notifierComponent
      Rectangle {
        id: notifierRect
        property string message 
        property string header : "New Action" 
        height : 100
        width :  body.width + 50
        color : "lightslategrey"
        opacity: 1.0
        visible: false;
        radius : 5
        Rectangle {
          color : "white"
          anchors.left : parent.left
          anchors.right : parent.right
          height : title.height
          Text {
            id: title
            text : header
            font.bold: true
            font.pixelSize : 15
          }
        }
        Text {
          id : body
          text : message
          anchors.centerIn : parent
          font.pixelSize : 25
        }
        Timer {
          id: opacityTimer
          interval: 250; running: true; repeat: true
          onTriggered: {
            parent.opacity = parent.opacity - .1
            if ( parent.opacity < 0.1 ) {
              parent.destroy()
            }
          }
        }
      }
    }

    function loadAutoEvents(events){
      for (let i = 0; i < events.get_event_count(); ++i){
        let event = events.get_event(i);
        switch (event.Type){
          case EventModel.AcuteRespiratoryDistress :
            setupAutoEvent(function() {return add_single_range_builder("UIAcuteRespiratoryDistress.qml", scenario, event.Params, event.StartTime, event.Duration); } );     
            break;
          case EventModel.AcuteStress : 
            setupAutoEvent(function() {return add_single_range_builder("UIAcuteStress.qml", biogears_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.AirwayObstruction : 
            setupAutoEvent(function() {return add_single_range_builder("UIAirwayObstruction.qml", biogears_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.AnesthesiaMachineConfiguration : 
            setupAutoEvent(function() {return add_anesthesia_machine_builder(biogears_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.Apnea : 
            setupAutoEvent(function() {return add_single_range_builder("UIApnea.qml", biogears_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.AsthmaAttack : 
            setupAutoEvent(function() {return add_single_range_builder("UIAsthmaAttack.qml", biogears_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.BrainInjury : 
            setupAutoEvent(function() {return add_traumatic_brain_injury_builder(biogears_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.Bronchoconstriction :
            setupAutoEvent(function() {return add_single_range_builder("UIBronchoconstriction.qml", biogears_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.BurnWound :
            setupAutoEvent(function() {return add_single_range_builder("UIBurnWound.qml", biogears_scenario, event.Params, event.StartTime);});
            break;
          case EventModel.CardiacArrest :
            setupAutoEvent(function() {return add_binary_builder("UICardiacArrest.qml", biogears_scenario, event.StartTime, event.Duration)})
          case EventModel.ConsumeNutrients :
            setupAutoEvent(function() {return add_consume_meal_builder(biogears_scenario, event.Params, event.StartTime);});
            break;
		  case EventModel.EnvironmentChange : 
            setupAutoEvent(function() {return add_environment_builder(biogears_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.Exercise :
            setupAutoEvent(function() {return add_exercise_builder(biogears_scenario, event.SubType, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.Hemorrhage :
            setupAutoEvent(function() {return add_hemorrhage_builder(biogears_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.Infection :
            setupAutoEvent(function() {return add_infection_builder(biogears_scenario, event.Params, event.StartTime);});
            break;
          case EventModel.InhalerConfiguration : 
            setupAutoEvent(function() {return add_binary_builder("UIInhaler.qml", biogears_scenario, event.StartTime)})
            break;
          case EventModel.SubstanceAdministration : 
            if (event.SubType === EventModel.SubstanceCompoundInfusion){
              //Sub compound infusion has distinct build function
              setupAutoEvent(function() {return add_compound_infusion_builder(biogears_scenario, event.Params, event.StartTime);});
            } else if (event.SubType === EventModel.Transfusion){
              //Transfusion has distinct build function
              setupAutoEvent(function() {return add_transfusion_builder(biogears_scenario, event.Params, event.StartTime);});
            } else if (event.SubType === EventModel.SubstanceInfusion) {
              //Infusion has a duration value to set
              setupAutoEvent(function() {return add_drug_administration_builder(biogears_scenario, event.SubType, event.Params, event.StartTime, event.Duration);});
            } else {
              //Else include bolus and oral dose, which do not need a duration set
              setupAutoEvent(function() {return add_drug_administration_builder(biogears_scenario, event.SubType, event.Params, event.StartTime);});
            }
            break;
          case EventModel.PainStimulus :
            setupAutoEvent(function() {return add_pain_stimulus_builder(biogears_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.PatientAssessmentRequest :
            setupAutoEvent(function() {return add_patient_assessment_builder(biogears_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.SerializeState : 
            setupAutoEvent(function() {return add_serialize_state_builder(biogears_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.TensionPneumothorax :
            setupAutoEvent(function() {return add_tension_pneumothorax_builder(biogears_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.Tourniquet :
            setupAutoEvent(function() {return add_tourniquet_builder(biogears_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.AdvanceTime :
          default : 
            console.log(event.TypeName + " not added to scenario")
        }
      } 
    }

    function setupAutoEvent(makeActionFunc){
      let newAction = makeActionFunc()
      newAction.builderMode = false;
      newAction.autoRun = true;
      newAction.width = Qt.binding(function() { return actionSwitchView.width })
      newAction.viewLoader.state = "collapsedControls"
      newAction.uuid = uuidv4()
      newAction.remove.connect(removeAction)
      actionSwitchModel.append(newAction)
    }

    function add_binary_action(componentType) {
        var v_severityForm = Qt.createComponent(componentType);
        if ( v_severityForm.status == Component.Ready)  {
          var v_action = v_severityForm.createObject(actionSwitchView,{ "width" : actionSwitchView.width,  "Layout.fillWidth" : true,})
          v_action.scenario = biogears_scenario
          v_action.uuid = uuidv4()
          v_action.remove.connect(removeAction)
          actionSwitchModel.append(v_action)
         notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(v_action.actionType), z : 200, dim: false})
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
        var v_action = v_severityForm.createObject(actionSwitchView,{ "severity" : props.spinnerValue,
                                                                      "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                                      })
        v_action.scenario = biogears_scenario
        v_action.uuid = uuidv4()
        v_action.remove.connect(removeAction)

        actionSwitchModel.append(v_action)
        notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(v_action.actionType), z : 200, dim: false})
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
        var v_painStimulus = v_painStimulusForm.createObject(actionSwitchView,{ "location" : props.location, "intensity" : props.painScore,
                                                                                "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                                              })
        v_painStimulus.scenario = biogears_scenario
        v_painStimulus.uuid = uuidv4()
        v_painStimulus.remove.connect(removeAction)

        actionSwitchModel.append(v_painStimulus)
        notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(v_painStimulus.actionType), z : 200, dim: false})
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
        notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(v_action.actionType), z : 200, dim: false})
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
        var action = compartment.createObject(actionSwitchView,{  "compartment" : props.location, "rate" : props.rate,
                                                                  "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                                })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
        notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
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
        notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
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
        notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
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
        notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
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
        notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
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
        var action = compartment.createObject(actionSwitchView,{ "rate" : props.rate,  "volume" : props.bagVolume,   "blood_type" : props.compound,
                                                                  "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
        notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
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
        notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
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
      let type = -1;
      let route = "";
      if (props.adminRoute.includes("Bolus")){
        type = EventModel.SubstanceBolus;
        route = props.adminRoute.split("-")[1];
      } else if (props.adminRoute.includes("Infusion")){
        type = EventModel.SubstanceInfusion;
        route = "Infusion";
      } else {
        type = EventModel.SubstanceOralDose
        if (props.route == "Gastrointestinal"){
          route = "Gastrointestinal";
        } else {
          route = "Transmucosal";
        }
      }
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{ "adminRoute" : route, "drug" : props.substance, "actionSubClass" : type,
                                                                 "dose" : props.dose,  "concentration" : props.concentration,   "rate" : props.rate,
                                                                 "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
        notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function add_consume_meal_action(props) {
      var compartment = Qt.createComponent("UIConsumeMeal.qml");
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{ "name" : props.mealName,
                                                                 "carbs_g" : props.carbohydrate, "fat_g" : props.fat,
                                                                 "protein_g" : props.protein,  "sodium_mg" : props.sodium,  
                                                                 "water_mL" : props.water,  "calcium_mg" : props.calcium,  
                                                                 "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
        notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function add_anesthesia_machine_action(props) {
      var compartment = Qt.createComponent("UIAnesthesiaMachine.qml");
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{  "description" : props.description, "connection" : props.connection, "primaryGas" : props.primaryGas, "o2Source" : props.o2Source,
                                                                  "leftChamberSub" : props.leftSub[0], "rightChamberSub" : props.rightSub[0], "inletFlow_L_Per_min" : props.inletFlow,
                                                                  "ieRatio" : props.ieRatio, "pMax_cmH2O" : props.pMax, "peep_cmH2O" : props.peep, "respirationRate_Per_min" : props.respirationRate,
                                                                  "reliefPressure_cmH2O" : props.reliefPressure, "o2Fraction" : props.o2Frac, "leftChamberFraction" : props.leftSub[1],
                                                                  "rightChamberFraction" : props.rightSub[1], "bottle1_mL" : props.bottle1,"bottle2_mL" : props.bottle2,
                                                                  "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
        notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
	
	function add_environment_action(props) {
      var compartment = Qt.createComponent("UIUpdateEnvironment.qml");
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{  "description" : props.description, "surroundingType" : props.surroundingType, "airDensity_kg_Per_m3" : props.airDensity,
                                                                  "airVelocity_m_Per_s" : props.airVelocity, "ambientTemperature_C" : props.ambientTemperature,
                                                                  "atmpshpericPressure_Pa" : props.atmPressure, "clothingResistance_clo" : props.cloResistance, "emissivity" : props.emissivity, "meanRadiantTemperature_C" : props.meanRadiantTemperature,
                                                                  "relativeHumidity" : props.relativeHumidity, "respirationAmbientTemperature_C" : props.respirationAmbientTemperature,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
        notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    
    function prompt_user_of_unsupported_action(props) {
      notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 is current Unsupported".arg(props.name), "header" : "Unsupported Action".arg(props.name), z : 200, dim: false})
    }
    function add_exercise_action(props) {
      var compartment = Qt.createComponent("UIExercise.qml");
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{ "type" : props.exerciseType, "weight" : props.weightPack,
                                                                 "property_1" : props.field_1, "property_2" : props.field_2,  
                                                                 "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
        notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }

    //Actions that support scenario builder
    function add_single_range_builder(componentType, scenario, props = "", startTime = 0, duration = 0) {
      let severity = 0.0;
      if (props!==""){
        //Only 1 arg (e.g. Severity=0.0)--split at =
        severity = parseFloat(props.split("=")[1]);
      }
      var v_severityForm = Qt.createComponent(componentType);
      if ( v_severityForm.status == Component.Ready)  {
        var v_action = v_severityForm.createObject(actionSwitchView,{ "severity" : severity, "actionStartTime_s" : startTime, "actionDuration_s" : duration,"scenario" : scenario,
                                                          "builderMode" : true
                                                          });
        return v_action;
      } else {
        if (v_severityForm.status == Component.Error){
          console.log("Error : " + v_severityForm.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function add_binary_builder(componentType, scenario, startTime = 0, duration = 0) {
        var v_binaryForm = Qt.createComponent(componentType, scenario);
        if ( v_binaryForm.status == Component.Ready)  {
          var v_action = v_binaryForm.createObject(actionSwitchView,{ "scenario" : scenario, "actionStartTime_s" : startTime, "actionDuration_s" : duration, "width" : actionSwitchView.width - actionSwitchView.scrollWidth, "builderMode" : true})
          return v_action;
        } else {
          if (v_binaryForm.status == Component.Error){
            console.log("Error : " + v_binaryForm.errorString() );
            return;
          }
          console.log("Error : Action switch component not ready");
        }
    }
    function add_pain_stimulus_builder(scenario, props = "", startTime = 0, duration = 0) {
      let location = "";
      let painScore = 0.0;
      if (props!==""){
        let params = props.split(";");
        for (let i = 0; i < params.length; ++i){
          let param = params[i].split("=");
          if (param[0]==="Severity"){
            painScore = parseFloat(param[1]);
          } else if (param[0] === "Location"){
            location = param[1].replace(/([a-z])([A-Z])([a-z])/g, '$1 $2$3');    //formats "LeftLeg" as "Left Leg" but leaves "pH" as "pH"
          }
        }
      }
      var v_painStimulusForm = Qt.createComponent("UIPainStimulus.qml");
      if ( v_painStimulusForm.status == Component.Ready)  {
        var v_painStimulus = v_painStimulusForm.createObject(actionSwitchView,{ "location" : location, "intensity" : painScore, "scenario" : scenario,
                                                                                "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                                "width" : actionSwitchView.width - actionSwitchView.scrollWidth,
                                                                                "builderMode" : true
                                                                              });
        return v_painStimulus;
      } else {
        if (v_painStimulusForm.status == Component.Error){
          console.log("Error : " + v_painStimulusForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }
    function add_hemorrhage_builder(scenario, props = "", startTime = 0, duration = 0) {
      let compartment = "";
      let rate = 0.0;
      if (props!==""){
        let params = props.split(";");
        for (let i = 0; i < params.length; ++i){
          let param = params[i].split("=");
          if (param[0]==="InitialRate"){
            rate = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "Compartment"){
            compartment = param[1];
          }
        }
      }
      var v_hemorrhageForm = Qt.createComponent("UIHemorrhage.qml");
      if ( v_hemorrhageForm.status == Component.Ready)  {
        var v_hemorrhage = v_hemorrhageForm.createObject(actionSwitchView,{ "compartment" : compartment, "rate" : rate, "scenario" : scenario,
                                                                            "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                            "width" : actionSwitchView.width-actionSwitchView.scrollWidth,
                                                                            "builderMode" : true
                                                                              });
        return v_hemorrhage;
      } else {
        if (v_hemorrhageForm.status == Component.Error){
          console.log("Error : " + v_hemorrhageForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }
    function add_tension_pneumothorax_builder(scenario, props = "", startTime = 0, duration = 0) {
      let severity = 0.0;
      let type = -1
      let side = -1
      if (props!==""){
        let params = props.split(";");
        for (let i = 0; i < params.length; ++i){
          let param = params[i].split("=");
          if (param[0]==="Severity"){
            severity = parseFloat(param[1]);
          } else if (param[0] === "Side"){
            side = param[1]=="Left" ? 0 : 1;
          } else if (param[0] === "Type") {
            type = param[1]=="Open" ? 0 : 1
          }
        }
      }
      var v_pneumothoraxForm = Qt.createComponent("UITensionPneumothorax.qml");
      if ( v_pneumothoraxForm.status == Component.Ready)  {
        var v_pneumothorax = v_pneumothoraxForm.createObject(actionSwitchView,{ "severity" : severity, "type" : type, "side" : side, "scenario" : scenario,
                                                                                "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,
                                                                                "builderMode" : true
                                                                              });
        return v_pneumothorax;
      } else {
        if (v_pneumothoraxForm.status == Component.Error){
          console.log("Error : " + v_pneumothoraxForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }

    function add_traumatic_brain_injury_builder(scenario, props = "", startTime = 0, duration = 0) {
      let severity = 0.0;
      let type = -1;
      if (props!==""){
        let params = props.split(";");
        for (let i = 0; i < params.length; ++i){
          let param = params[i].split("=");
          if (param[0]==="Severity"){
            severity = parseFloat(param[1]);
          } else if (param[0] === "Type") {
            type = parseInt(param[1]);
          }
        }
      }
      var v_brainInjuryForm = Qt.createComponent("UITraumaticBrainInjury.qml");
      if ( v_brainInjuryForm.status == Component.Ready)  {
        var v_brainInjury = v_brainInjuryForm.createObject(actionSwitchView,{ "severity" : severity, "type" : type, "scenario" : scenario,
                                                                              "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                              "width" : actionSwitchView.width-actionSwitchView.scrollWidth,
                                                                              "builderMode" : true
                                                                              });
        return v_brainInjury;
      } else {
        if (v_brainInjuryForm.status == Component.Error){
          console.log("Error : " + v_brainInjuryForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }

    function add_tourniquet_builder(scenario, props = "", startTime = 0, duration = 0) {
      let compartment = "";
      let tState = -1;
      if (props!==""){
        let params = props.split(";");
        for (let i = 0; i < params.length; ++i){
          let param = params[i].split("=");
          if (param[0]==="tState"){
            tState = parseInt(param[1]);
          } else if (param[1] === "Compartment") {
            compartment = param[1];
          }
        }
      }
      var v_tourniquetForm = Qt.createComponent("UITourniquet.qml");
      if ( v_tourniquetForm.status == Component.Ready)  {
        var v_tourniquet = v_tourniquetForm.createObject(actionSwitchView,{ "compartment" : compartment, "tState" : tState, "scenario" : scenario,
                                                                            "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                            "width" : actionSwitchView.width-actionSwitchView.scrollWidth,
                                                                            "builderMode" : true
                                                                              });
        return v_tourniquet;
      } else {
        if (v_tourniquetForm.status == Component.Error){
          console.log("Error : " + v_tourniquetForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }

    function add_infection_builder(scenario, props = "", startTime = 0, duration = 0) {
      let severity = -1;
      let location = "";
      let mic = 0.0;
      if (props!==""){
        let params = props.split(";")
        for (let i = 0; i < params.length; ++i){
          let param = params[i].split("=");
          if (param[0]==="Severity"){
            severity = param[1] == "Mild" ? 1 : param[1]=="Moderate" ? 2 : 3;
          } else if (param[0] === "MinimumInhibitoryConcentration") {
            mic = parseFloat(param[1].split(',')[0])
          } else if (param[0] === "Location"){
            location = param[1].replace(/([a-z])([A-Z])([a-z])/g, '$1 $2$3') ;   //formats "LeftLeg" as "Left Leg" but leaves "pH" as "pH"
          }
        }
      }
      var v_infectionForm = Qt.createComponent("UIInfection.qml");
      if ( v_infectionForm.status == Component.Ready)  {
        var v_infection = v_infectionForm.createObject(actionSwitchView,{ "mic" : mic, "severity" : severity, "location" : location, "scenario" : scenario,
                                                                          "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                          "width" : actionSwitchView.width-actionSwitchView.scrollWidth,
                                                                          "builderMode" : true
                                                                          });
        return v_infection;
      } else {
        if (v_infectionForm.status == Component.Error){
          console.log("Error : " + v_infectionForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }

    function add_consume_meal_builder(scenario, props = "", startTime = 0, duration = 0) {
      let mealName = "";
      let carbohydrate = 0.0;
      let fat = 0.0;
      let protein = 0.0;
      let sodium = 0.0;
      let water = 0.0;
      let calcium = 0.0;
      if (props!==""){
        let params = props.split(";")
        for (let i = 0; i < params.length; ++i){
          let param = params[i].split("=")
          if (param[0]==="Carbohydrate"){
            carbohydrate = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "Fat"){
            fat = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "Protein"){
            protein = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "Sodium"){
            sodium = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "Water"){
            water = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "Calcium"){
            calcium = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "Name") {
            mealName = param[1];
          }
        }
      }
      var v_mealForm = Qt.createComponent("UIConsumeMeal.qml");
      if ( v_mealForm.status == Component.Ready)  {
        var v_meal = v_mealForm.createObject(actionSwitchView,{ "name" : mealName, "scenario" : scenario, 
                                                                "carbs_g" : carbohydrate, "fat_g" : fat,
                                                                "protein_g" : protein,  "sodium_mg" : sodium,  
                                                                "water_ml" : water,  "calcium_mg" : calcium, 
                                                                "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,
                                                                "builderMode" : true
                                                                })
        return v_meal
      } else {
        if (v_mealForm.status == Component.Error){
          console.log("Error : " + v_mealForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }
    function add_drug_administration_builder(scenario, type, props = "", startTime = 0, duration = 0) {
      let adminRoute = "";
      let rate = 0.0;
      let concentration = 0.0;
      let dose = 0.0;
      let drug = "";
      if (props!==""){
        let params = props.split(";")
        for (let i = 0; i < params.length; ++i){
          let param = params[i].split("=")
          if (param[0]==="Dose"){
            dose = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "Rate"){
            rate = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "Concentration"){
            concentration = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "Substance"){
            drug = param[1];
          } else if (param[0] === "AdminRoute") {
            adminRoute = param[1];
          }
        }
      }
      var v_drugActionForm = Qt.createComponent("UIDrugAdministration.qml");
      if ( v_drugActionForm.status == Component.Ready)  {
        var v_drugAction = v_drugActionForm.createObject(actionSwitchView,{ "scenario" : scenario, "actionSubClass" : type, "adminRoute" : adminRoute, "drug" : drug, 
                                                                "rate" : rate, "concentration" : concentration, "dose" : dose,
                                                                "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,
                                                                "builderMode" : true
                                                                });
        return v_drugAction;
      } else {
        if (v_drugActionForm.status == Component.Error){
          console.log("Error : " + v_drugActionForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }
    function add_compound_infusion_builder(scenario, props = "", startTime = 0, duration = 0) {
      let rate = 0.0;
      let volume = 0.0;
      let compound = "";
      if (props!==""){
        let params = props.split(";");
        for (let i = 0; i < params.length; ++i){
          let param = params[i].split("=");
          if (param[0]==="Rate"){
            rate = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "BagVolume") {
            volume = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "SubstanceCompound") {
            compound = param[1];
          }
        }
      }
      var v_compoundActionForm = Qt.createComponent("UICompoundInfusion.qml");
      if ( v_compoundActionForm.status == Component.Ready)  {
        var v_compoundAction = v_compoundActionForm.createObject(actionSwitchView,{ "scenario" : scenario, "compound" : compound,
                                                                "rate" : rate, "volume" : volume,
                                                                "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,
                                                                "builderMode" : true
                                                                });
        return v_compoundAction;
      } else {
        if (v_compoundActionForm.status == Component.Error){
          console.log("Error : " + v_compoundActionForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }
    function add_transfusion_builder(scenario, props = "", startTime = 0, duration = 0) {
      let rate = 0.0;
      let volume = 0.0;
      let compound = "";
      if (props!==""){
        let params = props.split(";");
        for (let i = 0; i < params.length; ++i){
          let param = params[i].split("=");
          if (param[0]==="Rate"){
            rate = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "BagVolume") {
            volume = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "SubstanceCompound") {
            compound = param[1];
          }
        }
      }
      var v_transfusionActionForm = Qt.createComponent("UITransfusion.qml");
      if ( v_transfusionActionForm.status == Component.Ready)  {
        var v_transfusionAction = v_transfusionActionForm.createObject(actionSwitchView,{ "scenario" : scenario, "blood_type" : compound,
                                                                "rate" : rate, "volume" : volume,
                                                                "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,
                                                                "builderMode" : true
                                                                });
        return v_transfusionAction;
      } else {
        if (v_transfusionActionForm.status == Component.Error){
          console.log("Error : " + v_transfusionActionForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }
    function add_anesthesia_machine_builder(scenario, props = "", startTime = 0, duration = 0){
      var v_machineForm = Qt.createComponent("UIAnesthesiaMachine.qml");
      let connection = "";
      let primaryGas = "";
      let o2Source = "";
      let leftChamberSub = "";
      let rightChamberSub = "";
      let inletFlow_L_Per_min = 5.0;
      let ieRatio = 0.5;
      let pMax_cmH2O = 10.0;
      let peep_cmH2O = 1.0;
      let respirationRate_Per_min = 12.0;
      let reliefPressure_cmH2O = 50.0;
      let o2Frac = 0.25;
      let leftChamberFraction = 0.0;
      let rightChamberFraction = 0.0;
      let bottle1_mL = 0.0;
      let bottle2_mL = 0.0;
      if (props!==""){
        let params = props.split(";")
        for (let i = 0; i < params.length; ++i){
          let param = params[i].split("=")
          if (param[0]==="Connection"){
            connection = param[1]
          } else if (param[0] === "PrimaryGas"){
            primaryGas = param[1]
          } else if (param[0] === "OxygenSource"){
            o2Source = param[1]
          } else if (param[0] === "LeftChamber-Substance"){
            leftChamberSub = param[1]
          } else if (param[0] === "RightChamber-Substance"){
            rightChamberSub = param[1]
          } else if (param[0] === "InletFlow"){
            inletFlow_L_Per_min = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "InspiratoryExpiratoryRatio"){
            ieRatio = parseFloat(param[1]);
          } else if (param[0] === "VentilatorPressure"){
            pMax_cmH2O = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "PositiveEndExpiredPressure"){
            peep_cmH2O = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "RespiratoryRate"){
            respirationRate_Per_min = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "ReliefValvePressure"){
            reliefPressure_cmH2O = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "OxygenFraction"){
            o2Frac = parseFloat(param[1]);
          } else if (param[0] === "LeftChamber-SubstanceFraction"){
            leftChamberFraction = parseFloat(param[1]);
          } else if (param[0] === "RightChamber-SubstanceFraction"){
            rightChamberFraction = parseFloat(param[1]);
          } else if (param[0] === "OxygenBottleOne-Volume"){
            bottle1_mL = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "OxygenBottleTwo-Volume"){
            bottle2_mL = parseFloat(param[1].split(',')[0]);
          } else if (param[0] === "Calcium"){
            calcium = parseFloat(param[1].split(',')[0]);
          }
        }
      }
      if ( v_machineForm.status == Component.Ready)  {
        var v_machineAction = v_machineForm.createObject(actionSwitchView,{ "scenario" : scenario, "connection" : connection, "primaryGas" : primaryGas, "o2Source" : o2Source,
                                                                  "leftChamberSub" : leftChamberSub, "rightChamberSub" : rightChamberSub, "inletFlow_L_Per_min" : inletFlow_L_Per_min,
                                                                  "ieRatio" : ieRatio, "pMax_cmH2O" : pMax_cmH2O, "peep_cmH2O" : peep_cmH2O, "respirationRate_Per_min" : respirationRate_Per_min,
                                                                  "reliefPressure_cmH2O" : reliefPressure_cmH2O, "o2Fraction" : o2Frac, "leftChamberFraction" : leftChamberFraction,
                                                                  "rightChamberFraction" : rightChamberFraction, "bottle1_mL" : bottle1_mL,"bottle2_mL" : bottle2_mL,
                                                                  "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                  "width" : actionSwitchView.width - actionSwitchView.scrollWidth, "builderMode" : true
                                                               });

        return v_machineAction;
      } else {
        if (v_machineForm.status == Component.Error){
          console.log("Error : " + v_machineForm.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
	
	function add_environment_builder(scenario, props = "", startTime = 0, duration = 0){
      var v_machineForm = Qt.createComponent("UIUpdateEnvironment.qml");
      let surroundingType = "";
      let airDensity_kg_Per_m3 = 0.0;
      let airVelocity_m_Per_s = 0.0;
      let ambientTemperature_C = 0.0;
      let atmpshpericPressure_Pa = 0.0;
      let clothingResistance_clo = 0.0;
      let emissivity = 0.0;
      let meanRadiantTemperature_C = 0.0;
      let relativeHumidity = 0.0;
      let respirationAmbientTemperature_C = 0.0;
      if (props!==""){
        let params = props.split(";")
        for (let i = 0; i < params.length; ++i){
          let param = params[i].split("=")
          if (param[0]==="SurroundingType"){
            surroundingType = param[1]
          } else if (param[0] === "AirDensity"){
            airDensity_kg_Per_m3 = param[1]
          } else if (param[0] === "AirVelocity"){
            airVelocity_m_Per_s = param[1]
          } else if (param[0] === "AmbientTemperature"){
            ambientTemperature_C = param[1]
          } else if (param[0] === "AtmosphericPressure"){
            atmpshpericPressure_Pa = param[1]
          } else if (param[0] === "ClothingResistance"){
            clothingResistance_clo = param[1]
          } else if (param[0] === "Emissivity"){
            emissivity = param[1];
		  } else if (param[0] === "MeanRadiantTemperature"){
            meanRadiantTemperature_C = param[1]
          } else if (param[0] === "RelativeHumidity"){
            relativeHumidity = param[1]
          } else if (param[0] === "RespirationAmbientTemperature"){
            respirationAmbientTemperature_C = param[1];
          }
        }
      }
      if ( v_machineForm.status == Component.Ready)  {
        var v_machineAction = v_machineForm.createObject(actionSwitchView,{ "scenario" : scenario, "surroundingType" : surroundingType, "airDensity_kg_Per_m3" : airDensity_kg_Per_m3, "airVelocity_m_Per_s" : airVelocity_m_Per_s,
                                                                  "ambientTemperature_C" : ambientTemperature_C, "atmpshpericPressure_Pa" : atmpshpericPressure_Pa, "clothingResistance_clo" : clothingResistance_clo,
                                                                  "emissivity" : emissivity, "meanRadiantTemperature_C" : meanRadiantTemperature_C, "relativeHumidity" : relativeHumidity, "respirationAmbientTemperature_C" : respirationAmbientTemperature_C,
                                                                  "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                  "width" : actionSwitchView.width - actionSwitchView.scrollWidth, "builderMode" : true
                                                               });

        return v_machineAction;
      } else {
        if (v_machineForm.status == Component.Error){
          console.log("Error : " + v_machineForm.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }

    function add_exercise_builder(scenario, type, props = "", startTime = 0, duration = 0) {
      var v_exerciseActionForm = Qt.createComponent("UIExercise.qml");
      if ( v_exerciseActionForm.status == Component.Ready)  {
        if (type===EventModel.CyclingExercise){
          let cadence = 0.0;
          let power = 0.0;
          let weight = 0.0;
          let params = props.split(";");
          if (props!==""){
            let params = props.split(";")
            for (let i = 0; i < params.length; ++i){
              let param = params[i].split("=")
              if (param[0]==="Cadence"){
                cadence = parseInt(param[1])
              } else if (param[0] === "Power") {
                power = parseFloat(param[1].split(',')[0]);
              } else if (param[0] === "AddedWeight"){
                weight = parseFloat(param[1].split(',')[0]);
              }
            }
          }
          var v_exerciseAction = v_exerciseActionForm.createObject(actionSwitchView,{ "scenario" : scenario, "type" : "Cycling", 
                                                                "property_1" : cadence, "property_2" : power, "weight" : props.weight,
                                                                "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,
                                                                "builderMode" : true
                                                                })
        } else if (type===EventModel.RunningExercise){
          let velocity = 0.0;
          let incline = 0.0;
          let weight = 0.0;
          if (props!==""){
            let params = props.split(";")
            for (let i = 0; i < params.length; ++i){
              let param = params[i].split("=")
              if (param[0]==="Incline"){
                incline = parseInt(param[1])
              } else if (param[0] === "Speed") {
                velocity = parseFloat(param[1].split(',')[0]);
              } else if (param[0] === "AddedWeight"){
                weight = parseFloat(param[1].split(',')[0]);
              }
            }
          }
          var v_exerciseAction = v_exerciseActionForm.createObject(actionSwitchView,{ "scenario" : scenario, "type" : "Running", 
                                                                "property_1" : velocity, "property_2" : incline, "weight" : props.weight,
                                                                "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,
                                                                "builderMode" : true
                                                                })
        } else if (type===EventModel.StrengthExercise){
          let repetitions = 0.0;
          let weight = 0.0;
          if (props!==""){
            let params = props.split(";")
            for (let i = 0; i < params.length; ++i){
              let param = params[i].split("=")
              if (param[0]==="Repetitions"){
                repetitions = parseInt(param[1])
              } else if (param[0] === "Weight") {
                weight = parseFloat(param[1].split(',')[0]);
              }
            }
          }
          var v_exerciseAction = v_exerciseActionForm.createObject(actionSwitchView,{ "scenario" : scenario, "type" : "Strength", 
                                                                "property_2" : repetitions, "weight" : weight,
                                                                "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,
                                                                "builderMode" : true
                                                                })
        } else if (type == EventModel.GenericExercise) {
          let intensity = 0.0;
          let power = 0.0;
          let subType = -1
          if (props!==""){
            let params = props.split(";")
            for (let i = 0; i < params.length; ++i){
              let param = params[i].split("=")
              if (param[0]==="Intensity"){
                intensity = parseFloat(param[1].split(',')[0]);
                subType = 0
              } else if (param[0] === "DesiredWorkRate") {
                power = parseFloat(param[1].split(',')[0]);
                subType = 1
              }
            }
          }
          var v_exerciseAction = v_exerciseActionForm.createObject(actionSwitchView,{ "scenario" : scenario, "type" : "Generic", 
                                                                "property_1" : intensity, "property_2" : power, "genericSubType" : subType,
                                                                "actionStartTime_s" : startTime, "actionDuration_s" : duration,
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,
                                                                "builderMode" : true
                                                                })
        }
        return v_exerciseAction;
      } else {
        if (v_exerciseActionForm.status == Component.Error){
          console.log("Error : " + v_exerciseActionForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }
    function add_serialize_state_builder(scenario, props = "", startTime = 0, duration = 0) {
      let fileName = ""
      if (props!=""){
        let params = props.split(';')
        for (let i = 0; i < params.length; ++i){
          let param = params[i].split('=')
          if (param[0]=="Filename"){
            let temp1 = param[1].replace("./states/", "");
            let temp2 = temp1.replace(".xml","")
            fileName = temp2
          }
        }
      }
      var v_serializeForm = Qt.createComponent("UISerialize.qml");
      if ( v_serializeForm.status == Component.Ready)  {
        var v_serialize = v_serializeForm.createObject(actionSwitchView,{ "fileName" : fileName, "scenario" : scenario, "actionStartTime_s" : startTime, 
                                                                          "actionDuration_s" : duration, "width" : actionSwitchView.width-actionSwitchView.scrollWidth,
                                                                          "builderMode" : true
                                                                        });
        return v_serialize;
      } else {
        if (v_serializeForm.status == Component.Error){
          console.log("Error : " + v_serializeForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }
    function add_patient_assessment_builder(scenario, props = "", startTime = 0, duration = 0) {
      let type_str = ""
      if (props != ""){
        type_str = props.split("=")[1].replace(/([a-z])([A-Z])([a-z])/g, '$1 $2$3');
      }
      var v_serializeForm = Qt.createComponent("UIPatientAssessment.qml");
      if ( v_serializeForm.status == Component.Ready)  {
        var v_serialize = v_serializeForm.createObject(actionSwitchView,{ "type_str" : type_str, "scenario" : scenario, "actionStartTime_s" : startTime, 
                                                                          "actionDuration_s" : duration, "width" : actionSwitchView.width-actionSwitchView.scrollWidth,
                                                                            "builderMode" : true
                                                                        });
        return v_serialize;
      } else {
        if (v_serializeForm.status == Component.Error){
          console.log("Error : " + v_serializeForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }
  }