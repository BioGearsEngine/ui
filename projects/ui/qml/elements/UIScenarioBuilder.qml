import QtQuick 2.12
import QtQuick.Window 2.12
import QtQml.Models 2.12
import com.biogearsengine.ui.scenario 1.0

UIScenarioBuilderForm {
	id: root

	signal validScenario (string type, var data)
	signal invalidScenario(string errorStr)
	signal resetScenario()
	signal loadScenario()

	onClosing : {
		clear();
	}

	function launch(){
		root.showNormal();
	}
	function clear(){
		builderModel.clear();
	}
	
  //List model elements can't assign javascript objects to properties, but JS objects are what get passed to ActionModel functions.  Get around this 
  //by assigning each action a "genProps" function that returns the initial properties we want, which we can then pass along to their respective "makeAction" function
  //This also lets us assign differently named properties to each action (if we did nested ListElements, ListModel expects each subelement to get the same properties defined)
	actionModel : ListModel {
    ListElement { name : "Consume Meal"; section : "Patient Actions"; property var makeAction : function (props, scenario) {return builderModel.add_consume_meal_builder(props, scenario)}; property var genProps : function() {return {"carbs_g" : 0.0, "fat_g" : 0.0, "protein_g" : 0.0, "calcium_mg" : 0.0, "sodium_mg" : 0.0, "water_mL" : 0.0} } }
    ListElement { name : "Cycling"; section : "Exercise"; property var makeAction : function (props, scenario) {return builderModel.add_exercise_builder(props, scenario)}; property var genProps : function() {return {"type" : "Cycling", "cadence" : 0.0, "power" : 0.0, "weight" : 0.0} } }
    ListElement { name : "Running"; section : "Exercise"; property var makeAction : function (props, scenario) {return builderModel.add_exercise_builder(props, scenario)}; property var genProps : function() {return {"type" : "Running", "velocity" : 0.0, "incline" : 0.0, "weight" : 0.0} } }
    ListElement { name : "Strength Training"; section : "Exercise"; property var makeAction : function (props, scenario) {return builderModel.add_exercise_builder(props, scenario)}; property var genProps : function() {return {"type" : "Strength", "weight" : 0.0, "repetitions" : 0.0} } }
    ListElement { name : "Other Exercise"; section : "Exercise"; property var makeAction : function (props, scenario) {return builderModel.add_exercise_builder(props, scenario)}; property var genProps : function() {return {"type" : "Generic", "intensity" : 0.0, "power" : 0.0} } }
    ListElement { name : "Acute Respiratory Distress"; section : "Acute Injuries"; property var makeAction : function(props, scenario) { return builderModel.add_single_range_builder("UIAcuteRespiratoryDistress.qml", props, scenario)}; property var genProps : function () {return {"spinnerValue" : 0.0} } }
    ListElement { name : "Acute Stress"; section : "Acute Injuries"; property var makeAction : function(props, scenario) {return builderModel.add_single_range_builder("UIAcuteStress.qml", props, scenario)}; property var genProps : function() { return {"spinnerValue" : 0} } }
    ListElement { name : "Airway Obstruction"; section : "Acute Injuries"; property var makeAction : function(props, scenario) {return builderModel.add_single_range_builder("UIAirwayObstruction.qml", props, scenario)}; property var genProps : function() { return {"spinnerValue" : 0} } }
    ListElement { name : "Apnea"; section : "Acute Injuries"; property var makeAction : function(props, scenario) {return builderModel.add_single_range_builder("UIApnea.qml", props, scenario)}; property var genProps : function() { return {"spinnerValue" : 0} } }
    ListElement { name : "Asthma Attack"; section : "Acute Injuries"; property var makeAction : function(props, scenario) {return builderModel.add_single_range_builder("UIAsthmaAttack.qml", props, scenario)}; property var genProps : function() { return {"spinnerValue" : 0} } }
    ListElement { name : "Bronchoconstriction"; section : "Acute Injuries"; property var makeAction : function(props, scenario) {return builderModel.add_single_range_builder("UIBronchoconstriction.qml", props, scenario)}; property var genProps : function() { return {"spinnerValue" : 0} } }
    ListElement { name : "Burn"; section : "Acute Injuries"; property var makeAction : function(props, scenario) {return builderModel.add_single_range_builder("UIBurnWound.qml", props, scenario)}; property var genProps : function() { return {"spinnerValue" : 0} } }
    ListElement { name : "Cardiac Arrest"; section : "Acute Injuries"; property var makeAction : function(scenario) {return builderModel.add_binary_builder("UICardiacArrest.qml", scenario)}}
    ListElement { name : "Hemorrhage"; section : "Acute Injuries"; property var makeAction : function(props, scenario) {return builderModel.add_hemorrhage_builder(props, scenario)}; property var genProps : function () {return {"rate" : 0, "compartment" : ""} } }
    ListElement { name : "Infection"; section : "Acute Injuries"; property var makeAction : function(props, scenario) {return builderModel.add_infection_builder(props, scenario)}; property var genProps : function () { return {"mic" : 0.0, "severity" : 0, "location" : ""} } }
    ListElement { name : "Pain Stimulus"; section : "Acute Injuries"; property var makeAction : function(props, scenario) {return builderModel.add_pain_stimulus_builder(props, scenario)}; property var genProps : function () { return { "intensity" : 0.0, "location" :""} } }
    ListElement { name : "Tension Pneumothorax"; section : "Acute Injuries"; property var makeAction : function(props, scenario) {return builderModel.add_tension_pneumothorax_builder(props, scenario)}; property var genProps : function () {return {"severity" : 0.0, "type" : -1, "side" : -1} } }
    ListElement { name : "Traumatic Brain Injury"; section : "Acute Injuries"; property var makeAction : function(props, scenario) {return builderModel.add_traumatic_brain_injury_builder(props, scenario)}; property var genProps : function () { return {"severity" : 0, "type": -1} } }
    ListElement { name : "Drug-Bolus"; section : "Administer Substances"; property var makeAction : function(props, scenario) {return builderModel.add_drug_administration_builder(props, scenario)}; property var genProps : function() { return {"adminRoute" : "Bolus", "dose" : 0.0, "concentration" : 0.0} } }
    ListElement { name : "Drug-Infusion"; section : "Administer Substances"; property var makeAction : function(props, scenario) {return builderModel.add_drug_administration_builder(props, scenario)}; property var genProps : function() { return {"adminRoute" : "Infusion", "rate" : 0.0, "concentration" : 0.0} }}
    ListElement { name : "Drug-Oral"; section : "Administer Substances"; property var makeAction : function(props, scenario) {return builderModel.add_drug_administration_builder(props, scenario)}; property var genProps : function() { return {"adminRoute" : "Oral", "dose" : 0.0} }}
    ListElement { name : "Fluids-Infusion"; section : "Administer Substances"; property var makeAction : function(props, scenario) { return builderModel.add_compound_infusion_builder(props, scenario) }; property var genProps : function() { return {"rate" : 0.0, "volume" : 0.0 } }}
    ListElement { name : "Transfusion"; section : "Administer Substances"; property var makeAction : function(props, scenario) {return builderModel.add_transfusion_builder(props,scenario)}; property var genProps : function() {return {"rate" : 0.0, "volume" : 0.0} } }
    ListElement { name : "Needle Decompression"; section : "Interventions"; property var makeAction : function(scenario) {return builderModel.add_binary_builder("UINeedleDecompression.qml", scenario)}}
    ListElement { name : "Tourniquet"; section : "Interventions"; property var makeAction : function(props, scenario) { return builderModel.add_tourniquet_builder(props, scenario) }; property var genProps : function () {return {"compartment" : "", "tState" : -1} } }
    ListElement { name : "Inhaler"; section : "Interventions"}
    ListElement { name : "Anesthesia Machine"; section : "Interventions"; property var makeAction : function(props, scenario) { return builderModel.add_anesthesia_machine_builder(props, scenario)}; property var genProps : function() { return {"connection" : "", "primaryGas" : "", "o2Source" : "", "ieRatio" : 0.5, "inletFlow_L_Per_min" : 5.0, "pMax_cmH2O" : 10.0, "peep_cmH2O" : 1.0, "respirationRate_Per_min" : 12.0, "reliefPressure_cmH2O" : 50.0, "o2Fraction" : 0.25, "bottle1_mL" : 0.0, "bottle2_mL" : 0.0, "leftChamberSub" : "", "leftChamberFraction" : 0.0, "rightChamberSub" : "", "rightChamberFraction" : 0.0 } }}
  }

  builderModel : ActionModel {
    id : builderActionModel
    actionSwitchView : scenarioView
    property var actionQueue : []     //sorted in order
    function createAction(actionElement){
      if (actionElement.genProps){
        let actionProps = actionElement.genProps()
        var newAction = actionElement.makeAction(actionProps, bg_scenario)
      } else {
        var newAction = actionElement.makeAction(bg_scenario)
      }
      newAction.viewLoader.state = "expandedBuilder"
      builderActionModel.insert(0, newAction) //Adding every new action to the top initially for editing
      newAction.state = Qt.binding(function() { return actionSwitchView.currentIndex === newAction.ObjectModel.index ? 'selected' : 'unselected'} )
      newAction.selected.connect(function() {actionSwitchView.currentIndex = newAction.ObjectModel.index})
      newAction.buildSet.connect(builderActionModel.setViewIndex)
    }
    function setViewIndex(action){
      //When we edit an action (in particular it's start time) we need to make sure that we percolate it up/down to the right location in the view area
      if (builderActionModel.count === 1){ 
        return; //this is the only action in the view
      }
      let actionIndex = action.ObjectModel.index;  //where the action currently resides in the view
      let actionTime = action.actionStartTime_s;   //the time the action is to be applied
      let newIndex = 0;   //Where we will put the action to make sure we are ordered by time
      for (let i = 0; i < builderActionModel.count; ++i){
        if (i == actionIndex){
          continue; //Don't compare against itself
        }
        if (actionTime > builderActionModel.get(i).actionStartTime_s){
          //Action occurs after action(i), so it should be placed before it, (newIndex = i-1 at this point)
          break;
        }
        ++newIndex;   //Action occurs before action(i), keep moving down the list
      }
      if (newIndex!=actionIndex){
        builderActionModel.move(actionIndex, newIndex, 1);
      }
    }
    function setActionQueue(){
      //Add actions to queue.  They are in reverse chronological order, so count backwards (seems more efficient than trying to put in front and forcing array to shift elements on every addition)
      for (let i = builderActionModel.count-1; i >= 0; --i){
        //builderActionModel.actionQueue.push(builderActionModel.get(i).buildActionData);
        let action = builderActionModel.get(i)
        eventModel.add_event(action.actionType, action.actionClass, action.actionSubClass, action.buildParams, action.actionStartTime_s, action.actionDuration_s)
      }
      bg_scenario.create_scenario(eventModel);
    }
  }

  eventModel : EventModel {
    id : eventModel
  }

}
