import QtQuick 2.4
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

  ObjectModel {
    id : actionSwitchModel
    property ListView actionSwitchView

    property Item notification :     Component {
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
          interval: 100; running: true; repeat: true
          onTriggered: {
            parent.opacity = parent.opacity - .1
            if ( parent.opacity < 0.1 ) {
              parent.destroy()
            }
          }
        }
      }
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
        var v_action = v_severityForm.createObject(actionSwitchView,{ "nameLong" : props.description, "namePretty" : props.description.split(":")[0],
                                                                      "severity" : props.spinnerValue,
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
        var v_painStimulus = v_painStimulusForm.createObject(actionSwitchView,{ "nameLong" : props.description, "namePretty" : props.description.split(":")[0],
                                                                                "location" : props.location, "intensity" : props.painScore,
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
        var action = compartment.createObject(actionSwitchView,{ "nameLong" : props.description, "namePretty" : props.description.split(":")[0],
                                                                                "compartment" : props.location, "rate" : props.rate,
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
        var action = compartment.createObject(actionSwitchView,{ "rate" : props.rate,  "volume" : props.bagVolume,   "blood_type" : props.type,
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
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{ "adminRoute" : props.adminRoute, "drug" : props.substance,
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
                                                                 "water_ml" : props.water,  "calcium_mg" : props.calcium,  
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
    
    function prompt_user_of_unsupported_action(props) {
      notifierComponent.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 is current Unsupported".arg(props.name), "header" : "Unsupported Action".arg(props.name), z : 200, dim: false})
    }
    function add_exercise_action(props) {
      var compartment = Qt.createComponent("UIExercise.qml");
      if ( compartment.status == Component.Ready)  {
        if (props.exerciseType == "Running") {
			    props.field_3 = props.field_3 / 100.0;
		    }
        var action = compartment.createObject(actionSwitchView,{ "type" : props.exerciseType, "weight" : props.weightPack,
                                                                 "property_1" : props.field_1, "property_2" : props.field_3,  
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
    function add_single_range_builder(componentType, props, scenario) {
      var v_severityForm = Qt.createComponent(componentType);
      if ( v_severityForm.status == Component.Ready)  {
        var v_action = v_severityForm.createObject(actionSwitchView,{ "severity" : props.spinnerValue, "scenario" : scenario,
                                                                      "width" : actionSwitchView.width - actionSwitchView.scrollWidth,  "Layout.fillWidth" : true,
                                                                       "builderMode" : true
                                                                       })
        return v_action
      } else {
        if (v_severityForm.status == Component.Error){
          console.log("Error : " + v_severityForm.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function add_binary_builder(componentType) {
        var v_binaryForm = Qt.createComponent(componentType, scenario);
        if ( v_binaryForm.status == Component.Ready)  {
          var v_action = v_binaryForm.createObject(actionSwitchView,{ "scenario" : scenario, "width" : actionSwitchView.width - actionSwitchView.scrollWidth,  "Layout.fillWidth" : true, "builderMode" : true})
          return v_action;
        } else {
          if (v_binaryForm.status == Component.Error){
            console.log("Error : " + v_binaryForm.errorString() );
            return;
          }
          console.log("Error : Action switch component not ready");
        }
    }
    function add_pain_stimulus_builder(props, scenario) {
      var v_painStimulusForm = Qt.createComponent("UIPainStimulus.qml");
      if ( v_painStimulusForm.status == Component.Ready)  {
        var v_painStimulus = v_painStimulusForm.createObject(actionSwitchView,{ "location" : props.location, "intensity" : props.painScore, "scenario" : scenario,
                                                                                "width" : actionSwitchView.width - actionSwitchView.scrollWidth,  "Layout.fillWidth" : true,
                                                                                "builderMode" : true
                                                                              })
        return v_painStimulus
      } else {
        if (v_painStimulusForm.status == Component.Error){
          console.log("Error : " + v_painStimulusForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }
    function add_hemorrhage_builder(props, scenario) {
      var v_hemorrhageForm = Qt.createComponent("UIHemorrhage.qml");
      if ( v_hemorrhageForm.status == Component.Ready)  {
        var v_hemorrhage = v_hemorrhageForm.createObject(actionSwitchView,{ "compartment" : props.compartment, "rate" : props.rate, "scenario" : scenario,
                                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,  "Layout.fillWidth" : true,
                                                                                "builderMode" : true
                                                                              })
        return v_hemorrhage
      } else {
        if (v_hemorrhageForm.status == Component.Error){
          console.log("Error : " + v_hemorrhageForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }
    function add_tension_pneumothorax_builder(props, scenario) {
      var v_pneumothoraxForm = Qt.createComponent("UITensionPneumothorax.qml");
      if ( v_pneumothoraxForm.status == Component.Ready)  {
        var v_pneumothorax = v_pneumothoraxForm.createObject(actionSwitchView,{ "severity" : props.severity, "type" : props.type, "side" : props.side, "scenario" : scenario,
                                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,  "Layout.fillWidth" : true,
                                                                                "builderMode" : true
                                                                              })
        return v_pneumothorax
      } else {
        if (v_pneumothoraxForm.status == Component.Error){
          console.log("Error : " + v_pneumothoraxForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }

    function add_traumatic_brain_injury_builder(props, scenario) {
      var v_brainInjuryForm = Qt.createComponent("UITraumaticBrainInjury.qml");
      if ( v_brainInjuryForm.status == Component.Ready)  {
        var v_brainInjury = v_brainInjuryForm.createObject(actionSwitchView,{ "severity" : props.severity, "type" : props.type, "scenario" : scenario,
                                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,  "Layout.fillWidth" : true,
                                                                                "builderMode" : true
                                                                              })
        return v_brainInjury
      } else {
        if (v_brainInjuryForm.status == Component.Error){
          console.log("Error : " + v_brainInjuryForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }

    function add_tourniquet_builder(props, scenario) {
      var v_tourniquetForm = Qt.createComponent("UITourniquet.qml");
      if ( v_tourniquetForm.status == Component.Ready)  {
        var v_tourniquet = v_tourniquetForm.createObject(actionSwitchView,{ "compartment" : props.compartment, "tState" : props.tState, "scenario" : scenario,
                                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,  "Layout.fillWidth" : true,
                                                                                "builderMode" : true
                                                                              })
        return v_tourniquet
      } else {
        if (v_tourniquetForm.status == Component.Error){
          console.log("Error : " + v_tourniquetForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }

    function add_infection_builder(props, scenario) {
      var v_infectionForm = Qt.createComponent("UIInfection.qml");
      if ( v_infectionForm.status == Component.Ready)  {
        var v_infection = v_infectionForm.createObject(actionSwitchView,{ "mic" : props.mic, "severity" : props.severity, "location" : props.location, "scenario" : scenario,
                                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,  "Layout.fillWidth" : true,
                                                                                "builderMode" : true
                                                                              })
        return v_infection
      } else {
        if (v_infectionForm.status == Component.Error){
          console.log("Error : " + v_infectionForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }

    function add_consume_meal_builder(props, scenario) {
      var v_mealForm = Qt.createComponent("UIConsumeMeal.qml");
      if ( v_mealForm.status == Component.Ready)  {
        var v_meal = v_mealForm.createObject(actionSwitchView,{ "name" : props.mealName, "scenario" : scenario, 
                                                                "carbs_g" : props.carbohydrate, "fat_g" : props.fat,
                                                                "protein_g" : props.protein,  "sodium_mg" : props.sodium,  
                                                                "water_ml" : props.water,  "calcium_mg" : props.calcium, 
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,  "Layout.fillWidth" : true,
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
    function add_drug_administration_builder(props, scenario) {
      var v_drugActionForm = Qt.createComponent("UIDrugAdministration.qml");
      if ( v_drugActionForm.status == Component.Ready)  {
        var v_drugAction = v_drugActionForm.createObject(actionSwitchView,{ "scenario" : scenario, "adminRoute" : props.adminRoute, 
                                                                "rate" : props.rate, "concentration" : props.concentration,
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,  "Layout.fillWidth" : true,
                                                                "builderMode" : true
                                                                })
        return v_drugAction
      } else {
        if (v_drugActionForm.status == Component.Error){
          console.log("Error : " + v_drugActionForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }
    function add_compound_infusion_builder(props, scenario) {
      var v_compoundActionForm = Qt.createComponent("UICompoundInfusion.qml");
      if ( v_compoundActionForm.status == Component.Ready)  {
        var v_compoundAction = v_compoundActionForm.createObject(actionSwitchView,{ "scenario" : scenario, "compound" : "",
                                                                "rate" : props.rate, "volume" : props.volume,
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,  "Layout.fillWidth" : true,
                                                                "builderMode" : true
                                                                })
        return v_compoundAction
      } else {
        if (v_compoundActionForm.status == Component.Error){
          console.log("Error : " + v_compoundActionForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }
    function add_transfusion_builder(props, scenario) {
      var v_transfusionActionForm = Qt.createComponent("UITransfusion.qml");
      if ( v_transfusionActionForm.status == Component.Ready)  {
        var v_transfusionAction = v_transfusionActionForm.createObject(actionSwitchView,{ "scenario" : scenario, "blood_type" : "",
                                                                "rate" : props.rate, "volume" : props.volume,
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,  "Layout.fillWidth" : true,
                                                                "builderMode" : true
                                                                })
        return v_transfusionAction
      } else {
        if (v_transfusionActionForm.status == Component.Error){
          console.log("Error : " + v_transfusionActionForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }
    function add_anesthesia_machine_builder(props, scenario){
      var v_machineForm = Qt.createComponent("UIAnesthesiaMachine.qml");
      if ( v_machineForm.status == Component.Ready)  {
        var v_machineAction = v_machineForm.createObject(actionSwitchView,{ "scenario" : scenario, "connection" : props.connection, "primaryGas" : props.primaryGas, "o2Source" : props.o2Source,
                                                                  "leftChamberSub" : props.leftChamberSub, "rightChamberSub" : props.rightChamberSub, "inletFlow_L_Per_min" : props.inletFlow_L_Per_min,
                                                                  "ieRatio" : props.ieRatio, "pMax_cmH2O" : props.pMax_cmH2O, "peep_cmH2O" : props.peep_cmH2O, "respirationRate_Per_min" : props.respirationRate_Per_min,
                                                                  "reliefPressure_cmH2O" : props.reliefPressure_cmH2O, "o2Fraction" : props.o2Frac, "leftChamberFraction" : props.leftChamberFraction,
                                                                  "rightChamberFraction" : props.rightChamberFraction, "bottle1_mL" : props.bottle1_mL,"bottle2_mL" : props.bottle2_mL,
                                                                  "width" : actionSwitchView.width - actionSwitchView.scrollWidth,  "Layout.fillWidth" : true, "builderMode" : true
                                                               })

        return v_machineAction
      } else {
        if (v_machineForm.status == Component.Error){
          console.log("Error : " + v_machineForm.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }

    function add_exercise_builder(props, scenario) {
      var v_exerciseActionForm = Qt.createComponent("UIExercise.qml");
      if ( v_exerciseActionForm.status == Component.Ready)  {
        if (props.type==="Cycling"){
          var v_exerciseAction = v_exerciseActionForm.createObject(actionSwitchView,{ "scenario" : scenario, "type" : props.type, 
                                                                "property_1" : props.cadence, "property_2" : props.power, "weight" : props.weight,
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,  "Layout.fillWidth" : true,
                                                                "builderMode" : true
                                                                })
        } else if (props.type==="Running"){
          var v_exerciseAction = v_exerciseActionForm.createObject(actionSwitchView,{ "scenario" : scenario, "type" : props.type, 
                                                                "property_1" : props.velocity, "property_2" : props.incline, "weight" : props.weight,
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,  "Layout.fillWidth" : true,
                                                                "builderMode" : true
                                                                })
        } else if (props.type==="Strength"){
          var v_exerciseAction = v_exerciseActionForm.createObject(actionSwitchView,{ "scenario" : scenario, "type" : props.type, 
                                                                "property_2" : props.repetitions, "weight" : props.weight,
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,  "Layout.fillWidth" : true,
                                                                "builderMode" : true
                                                                })
        } else {
          var v_exerciseAction = v_exerciseActionForm.createObject(actionSwitchView,{ "scenario" : scenario, "type" : props.type, 
                                                                "property_1" : props.intensity, "property_2" : props.power,
                                                                "width" : actionSwitchView.width-actionSwitchView.scrollWidth,  "Layout.fillWidth" : true,
                                                                "builderMode" : true
                                                                })
        }
        return v_exerciseAction
      } else {
        if (v_exerciseActionForm.status == Component.Error){
          console.log("Error : " + v_exerciseActionForm.errorString() );
          return null;
        }
        console.log("Error : Action switch component not ready");
        return null;
      }
    }
  }