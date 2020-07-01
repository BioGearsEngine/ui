import QtQuick 2.4
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

  ObjectModel {
    id : actionSwitchModel
    property ListView actionSwitchView

    property Item notification :     Component {
      id : notifierComponet
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
         notifierComponet.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(v_action.actionType), z : 200, dim: false})
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
        notifierComponet.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(v_action.actionType), z : 200, dim: false})
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
        notifierComponet.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(v_painStimulus.actionType), z : 200, dim: false})
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
        notifierComponet.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(v_action.actionType), z : 200, dim: false})
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
        notifierComponet.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
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
        notifierComponet.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
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
        notifierComponet.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
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
        notifierComponet.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
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
        notifierComponet.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
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
        notifierComponet.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
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
        notifierComponet.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
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
        notifierComponet.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function add_consume_meal(props) {
      var compartment = Qt.createComponent("UIConsumeMeal.qml");
      if ( compartment.status == Component.Ready)  {

        var action = compartment.createObject(actionSwitchView,{ "name" : props.name, 
                                                                 "carbs_g" : props.carbs, "fat_g" : props.fat,
                                                                 "protien_g" : props.protien,  "sodium_g" : props.sodium,  
                                                                 "water_ml" : props.water,  "calcium_g" : props.calcium,  
                                                                 "rate" : props.rate,
                                                                 "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
        notifierComponet.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
    function prompt_user_of_unsupported_action(props) {
      notifierComponet.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 is current Unsupported".arg(props.name), "header" : "Unsupported Action".arg(props.name), z : 200, dim: false})
    }
    function add_exercise_action(props) {
      var compartment = Qt.createComponent("UIExercise.qml");
      if ( compartment.status == Component.Ready)  {
        var action = compartment.createObject(actionSwitchView,{ "type" : props.type, "weight" : props.weight,
                                                                 "property_1" : props.field_1, "property_2" : props.field_3,  
                                                                 "width" : actionSwitchView.width,  "Layout.fillWidth" : true,
                                                               })
        action.scenario = biogears_scenario
        action.uuid = uuidv4()
        action.remove.connect(removeAction)

        actionSwitchModel.append(action)
        notifierComponet.createObject(parent.parent, { "visible" : true,  "anchors.centerIn" : parent.parent, "message" : "%1 Added".arg(action.actionType), z : 200, dim: false})
      } else {
        if (compartment.status == Component.Error){
          console.log("Error : " + compartment.errorString() );
          return;
        }
        console.log("Error : Action switch component not ready");
      }
    }
  }