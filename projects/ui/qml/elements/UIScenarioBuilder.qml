import QtQuick 2.12
import QtQuick.Window 2.12
import QtQml.Models 2.12
import com.biogearsengine.ui.scenario 1.0
import Qt.labs.folderlistmodel 2.12

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
    if (builderModel.count > 2){
		  builderModel.remove(1, builderModel.count -2); //Delete actions, leaving behind initial patient block and scenario length block
    }
    builderModel.scenarioLength_s = 0.0
	}
	function seconds_to_clock_time(time_s) {
    var v_seconds = time_s % 60
    var v_minutes = Math.floor(time_s / 60) % 60
    var v_hours   = Math.floor(time_s / 3600)

    v_seconds = (v_seconds<10) ? "0%1".arg(v_seconds) : "%1".arg(v_seconds)
    v_minutes = (v_minutes<10) ? "0%1".arg(v_minutes) : "%1".arg(v_minutes)
    v_hours = (v_hours < 10) ? "0%1".arg(v_hours) : "%1".arg(v_hours)

    return "%1:%2:%3".arg(v_hours).arg(v_minutes).arg(v_seconds)
  }
  function clock_time_to_seconds(timeString){
    let timeUnits = timeString.split(':');    //splits into [hh, mm, ss]
    try {
      let hours = Number.fromLocaleString(timeUnits[0])
      let minutes = Number.fromLocaleString(timeUnits[1])
      let seconds = Number.fromLocaleString(timeUnits[2])
      if (hours < 0.0 || minutes < 0.0 || seconds < 0.0){
        throw "Negative time"
      }
      return 3600 * hours + 60 * minutes + seconds;
    } catch (err){
      return null
    }
  }
  //List model elements can't assign javascript objects to properties, but JS objects are what get passed to ActionModel functions.  Get around this 
  //by assigning each action a "genProps" function that returns the initial properties we want, which we can then pass along to their respective "makeAction" function
  //This also lets us assign differently named properties to each action (if we did nested ListElements, ListModel expects each subelement to get the same properties defined)
	actionModel : ListModel {
    ListElement { name : "Consume Meal"; section : "Nutrition"; property var makeAction : function (props, scenario) {return builderModel.add_consume_meal_builder(props, scenario)}; property var genProps : function() {return {"carbs_g" : 0.0, "fat_g" : 0.0, "protein_g" : 0.0, "calcium_mg" : 0.0, "sodium_mg" : 0.0, "water_mL" : 0.0} } }
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
    ListElement { name : "Infection"; section : "Acute Injuries"; property var makeAction : function(props, scenario) {return builderModel.add_infection_builder(props, scenario)}; property var genProps : function () { return {"mic" : 0.0, "severity" : -1, "location" : ""} } }
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
    id : builderModel
    actionSwitchView : scenarioView
    property double scenarioLength_s : 0     //Time at which the scenario ends
    property double scenarioLengthOverride_s : 0 //User provided value
    property alias scenarioEndItem : scenarioEnd.item
    property alias initialPatientItem : initialPatient.item
    //The scenario end component and initial patient component are in the model at startup
    Loader {
      id : scenarioEnd
      objectName : "scenarioEnd"
      sourceComponent : root.timeEndComponent
      onLoaded : {
        item.scenarioLength_s = Qt.binding(function () { return builderModel.scenarioLength_s })
      }
    }
    Loader {
      id : initialPatient
      sourceComponent : root.timeStartComponent
    }
    function createAction(actionElement){
      if (actionElement.genProps){
        let actionProps = actionElement.genProps()
        var newAction = actionElement.makeAction(actionProps, bg_scenario)
      } else {
        var newAction = actionElement.makeAction(bg_scenario)
      }
      newAction.viewLoader.state = "expandedBuilder"
      builderModel.insert(0, newAction) //Adding every new action to the top initially for editing
      let v_timeGap = root.timeGapComponent.createObject(builderModel.actionSwitchView)
      builderModel.insert(1, v_timeGap)
      newAction.currentSelection = Qt.binding(function() { return actionSwitchView.currentIndex === newAction.ObjectModel.index} )
      newAction.selected.connect(function() {actionSwitchView.currentIndex = newAction.ObjectModel.index})
      newAction.buildSet.connect(builderModel.setViewIndex)
      actionSwitchView.currentIndex = 0 //New action gets focus
    }
    function setViewIndex(action){
      //When we edit an action (in particular it's start time) we need to make sure that we percolate it up/down to the right location in the view area
      let newIndex = 1
      let actionIndex = action.ObjectModel.index;  //where the action currently resides in the view
      let startIndex = actionIndex == 0 ? 3 : 1  //If object is at index 0, then it has just been created. There is a time block (not visible) and the end sim block below it, so the first action to compare this action to is at index 3.  If this action has already been placed in list, then the end sim block occupies index 0 and the first action for comparison is at index 1 
      let actionTime = action.actionStartTime_s;   //the time the action is to be applied
      if (builderModel.count > 4){
        //<=4 means there is only one action so far (objects in model are initial patient, action time gap, action, and simulation length)  
        for (let i = startIndex; i < builderModel.count-1; i+=2){
          if (i == actionIndex){
            continue; //Don't compare against itself
          }
          if (actionTime > builderModel.get(i).actionStartTime_s){
            //This action occurs after action(i), so it should be placed before it, (newIndex = i-2 at this point)
            break;
          }
          newIndex+=2;   //This action occurs before action(i), keep moving down the list
        }
      }
      if (newIndex!=actionIndex){
        builderModel.move(actionIndex, newIndex, 2);    //2 indicates we are moving two objects -- both the action and its time block
      }
      updateTimeComponents();
      refreshScenarioLength();
    }
    function setActionQueue(){
      //Add actions to event model.  They are in reverse chronological order, so count backwards (seems more efficient than trying to put in front and forcing array to shift elements on every addition)
      //Very bottom item (count-1) is the initial patient, next lowest item (count -2) is time to first action, so we start at index (count - 3) and add every other item to skip over time gaps (can't add them as AdvanceTime
      //actions yet because we do not know where "Deactivate" functions go yet)
      for (let i = builderModel.count-3; i >= 0; i-=2){
        let action = builderModel.get(i)
        eventModel.add_event(action.actionType, action.actionClass, action.actionSubClass, action.buildParams, action.actionStartTime_s, action.actionDuration_s)
      }
      //Push back last advance time action -- set its "start time" to scenario length so that it will be guaranteed to be at end of sorted queue (calculate duration in Scenario.cpp after "deactivate" actions are accounted for)
      eventModel.add_event("Advance Time", EventModel.AdvanceTime, -1, "", builderModel.scenarioLength_s, 0.0)
    }
    function updateTimeComponents(){
      for (let i = 2; i < builderModel.count; i+=2){
        //time blocks are always the even indexed objects in model (skippint 0, 1, 2 because that is where sim length and action are 
        if (i == builderModel.count-2){
          //bottom time block, so it's time is just whatever start time the action above it has
          builderModel.get(i).blockTime_s = builderModel.get(i-1).actionStartTime_s
        } else {
          //intermediate time block, set value to the difference in start time between action below (earlier) and above (later)
          let belowActionStart = builderModel.get(i+1).actionStartTime_s
          let aboveActionStart = builderModel.get(i-1).actionStartTime_s
          builderModel.get(i).blockTime_s = aboveActionStart - belowActionStart
        }
      }
    }
    function refreshScenarioLength(){
      let newScenarioLength_s = 0
      for (let i = 1; i < builderModel.count-1; i+=2){
        let actionStart = builderModel.get(i).actionStartTime_s
        let actionDuration = builderModel.get(i).actionDuration_s
        if (actionStart + actionDuration > newScenarioLength_s){
          newScenarioLength_s = actionStart + actionDuration
        }
      }
      if (newScenarioLength_s > scenarioLengthOverride_s){
        scenarioLength_s = newScenarioLength_s
      } else {
        scenarioLength_s = scenarioLengthOverride_s
      }
      //Update final advance time (only if there is an action there, which happens when count > 2 (start and final block always there)
      let finalActionStart = 0
      if (builderModel.count > 2){
        finalActionStart = builderModel.get(1).actionStartTime_s
      }
      scenarioEnd.item.finalAdvanceTime_s = scenarioLength_s - finalActionStart
    }
  }
  
  eventModel : EventModel {
    id : eventModel
  }

  patientModel : FolderListModel {
    id : patientFolderModel
    nameFilters : ["*.xml"]
    folder : "file:patients"
    showDirs : false
  }

  stateModel : FolderListModel {
    id : stateFolderModel
    nameFilters : ["*.xml"]
    folder : "file:states"
    showDirs : false
  }

  dataRequestModel : ListModel {
    id : dataRequestModel
    ListElement {
      requestName : "Compartment";
      collapsed : true
      hasGrandchildren : true
      _children_ : [
        ListElement {
          requestName : "Gas"
          collapsed : true
          hasGrandchildren : false
          _children_ : [
            ListElement {
              requestName : "G1"
            },
            ListElement {
              requestName : "G2"
            }
          ]
        },
        ListElement {
          requestName : "Liquid"
          collapsed : true
          hasGrandchildren : false
          _children_ : [
            ListElement {
              requestName : "L1"
            },
            ListElement {
              requestName : "L2"
            }
          ]
        },
        ListElement {
          requestName : "Thermal"
          collapsed : true
          hasGrandchildren : false
          _children_ : [
            ListElement {
              requestName : "Th1"
            },
            ListElement {
              requestName : "Th2"
            }
          ]
        },
        ListElement {
          requestName : "Tissue"
          collapsed : true
          hasGrandChildren : false
          _children_ : [
            ListElement {
              requestName : "Tis1"
            },
            ListElement {
              requestName : "Tis2"
            }
          ]
        }
      ]
    }
    ListElement {
      requestName : "Patient"; 
      collapsed : true
      hasChildren : false
    }
    ListElement {
      requestName : "Physiology";
      collapsed : true
      hasChildren : false
    }
    ListElement {
      requestName : "Substance";
      collapsed : true
      hasChildren : false
    }
  }
}
