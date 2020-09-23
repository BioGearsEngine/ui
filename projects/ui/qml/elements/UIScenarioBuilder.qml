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
  signal requestMenuReady()
  signal readyToClose()

	onClosing : {
    for (let i = 0; i < builderModel.count; ++i){
      if (builderModel.get(i).objectName != "scenarioEnd" && builderModel.get(i).objectName != "scenarioStart"){
        builderModel.remove(i,1)
        --i;
      }
      else {
        builderModel.get(i).opacity = 1.0 //Make sure our start component isn't still ghosted out
      }
    }
    //eventModel.clear_events()
    builderModel.scenarioLength_s = 0.0;
    activeRequestsModel.requestQueue.length = 0
    activeRequestsModel.clear();
    root.bgRequests.resetData();     //Sets all collapsed roles to true and check states to 0 for nodes in Data Request Model
    contentLoader.showContent = false
    while (contentLoader.status != Loader.Null){
      close.accepted = false
    }
    close.accepted = true
	}
  onRequestMenuReady : {
    
  }
  function launch(){
    //windowContent.requestView.loadSource = true;   //Request view will load its delegates using updated model information (either from reset or pulled from an existing scenario that we are editing)
    contentLoader.showContent = true
	}

  function loadExisting(events, requests){
    eventModel = events   
    activeRequestsModel.requestQueue = requests
    launch();
  }
	
  function displayFormat (role) {
		let formatted = role.replace(/([a-z])([A-Z])([a-z])/g, '$1 $2$3')     //Formats BloodVolume as "Blood Volume", but formats pH as "pH"
		return formatted
	}
	function seconds_to_clock_time(time_s) {
    var v_seconds = time_s % 60;
    var v_minutes = Math.floor(time_s / 60) % 60;
    var v_hours   = Math.floor(time_s / 3600);

    v_seconds = (v_seconds<10) ? "0%1".arg(v_seconds) : "%1".arg(v_seconds);
    v_minutes = (v_minutes<10) ? "0%1".arg(v_minutes) : "%1".arg(v_minutes);
    v_hours = (v_hours < 10) ? "0%1".arg(v_hours) : "%1".arg(v_hours);

    return "%1:%2:%3".arg(v_hours).arg(v_minutes).arg(v_seconds);
  }
  function clock_time_to_seconds(timeString){
    let timeUnits = timeString.split(':');    //splits into [hh, mm, ss]
    try {
      let hours = Number.fromLocaleString(timeUnits[0]);
      let minutes = Number.fromLocaleString(timeUnits[1]);
      let seconds = Number.fromLocaleString(timeUnits[2]);
      if (hours < 0.0 || minutes < 0.0 || seconds < 0.0){
        throw "Negative time";
      }
      return 3600 * hours + 60 * minutes + seconds;
    } catch (err){
      return null;
    }
  }
  function saveScenario(){
    //If time end component is not at top of model, then we are still editing an action
    if (builderModel.get(0).objectName !== "scenarioEnd"){
      root.warningMessage.text = "Action editing in process";
      root.warningMessage.open();
      return;
    }
    //Make sure that data requests are valid before saving.  If not, request model will trigger warning
    if (activeRequestsModel.setRequestQueue()){
      builderModel.setActionQueue()
      let prefix = isPatientFile ? "" : "./states/";
      let initialParameters = prefix + scenarioInput;
      bg_scenario.create_scenario(root.scenarioName, isPatientFile, initialParameters + ".xml", eventModel, activeRequestsModel.requestQueue);
      root.close();
    }
  }

  //List model elements can't assign javascript objects to properties, but JS objects are what get passed to ActionModel functions.  Get around this 
  //by assigning each action a "genProps" function that returns the initial properties we want, which we can then pass along to their respective "makeAction" function
  //This also lets us assign differently named properties to each action (if we did nested ListElements, ListModel expects each subelement to get the same properties defined)
	actionModel : ListModel {
    ListElement { name : "Consume Meal"; section : "Nutrition"; property var makeAction : function (scenario) {return builderModel.add_consume_meal_builder(scenario)}}
    ListElement { name : "Cycling"; section : "Exercise"; property var makeAction : function (scenario) {return builderModel.add_exercise_builder(scenario, EventModel.CyclingExercise)} }
    ListElement { name : "Running"; section : "Exercise"; property var makeAction : function (scenario) {return builderModel.add_exercise_builder(scenario, EventModel.RunningExercise)} }
    ListElement { name : "Strength Training"; section : "Exercise"; property var makeAction : function (scenario) {return builderModel.add_exercise_builder(scenario, EventModel.StrengthExercise)} }
    ListElement { name : "Other Exercise"; section : "Exercise"; property var makeAction : function (scenario) {return builderModel.add_exercise_builder(scenario, EventModel.GenericExercise)} }
    ListElement { name : "Acute Respiratory Distress"; section : "Acute Injuries"; property var makeAction : function(scenario) { return builderModel.add_single_range_builder("UIAcuteRespiratoryDistress.qml", scenario)}}
    ListElement { name : "Acute Stress"; section : "Acute Injuries"; property var makeAction : function(scenario) {return builderModel.add_single_range_builder("UIAcuteStress.qml", scenario)} }
    ListElement { name : "Airway Obstruction"; section : "Acute Injuries"; property var makeAction : function(scenario) {return builderModel.add_single_range_builder("UIAirwayObstruction.qml", scenario)}}
    ListElement { name : "Apnea"; section : "Acute Injuries"; property var makeAction : function(scenario) {return builderModel.add_single_range_builder("UIApnea.qml", scenario)} }
    ListElement { name : "Asthma Attack"; section : "Acute Injuries"; property var makeAction : function(scenario) {return builderModel.add_single_range_builder("UIAsthmaAttack.qml", scenario)}}
    ListElement { name : "Bronchoconstriction"; section : "Acute Injuries"; property var makeAction : function(scenario) {return builderModel.add_single_range_builder("UIBronchoconstriction.qml", scenario)}}
    ListElement { name : "Burn"; section : "Acute Injuries"; property var makeAction : function(scenario) {return builderModel.add_single_range_builder("UIBurnWound.qml", scenario)} }
    ListElement { name : "Cardiac Arrest"; section : "Acute Injuries"; property var makeAction : function(scenario) {return builderModel.add_binary_builder("UICardiacArrest.qml", scenario)}}
    ListElement { name : "Hemorrhage"; section : "Acute Injuries"; property var makeAction : function(scenario) {return builderModel.add_hemorrhage_builder(scenario)} }
    ListElement { name : "Infection"; section : "Acute Injuries"; property var makeAction : function(scenario) {return builderModel.add_infection_builder(scenario)} }
    ListElement { name : "Pain Stimulus"; section : "Acute Injuries"; property var makeAction : function(scenario) {return builderModel.add_pain_stimulus_builder(scenario)}}
    ListElement { name : "Tension Pneumothorax"; section : "Acute Injuries"; property var makeAction : function(scenario) {return builderModel.add_tension_pneumothorax_builder(scenario)} }
    ListElement { name : "Traumatic Brain Injury"; section : "Acute Injuries"; property var makeAction : function(scenario) {return builderModel.add_traumatic_brain_injury_builder(scenario)} }
    ListElement { name : "Drug-Bolus"; section : "Administer Substances"; property var makeAction : function(scenario) {return builderModel.add_drug_administration_builder(scenario, EventModel.SubstanceBolus)} }
    ListElement { name : "Drug-Infusion"; section : "Administer Substances"; property var makeAction : function(scenario) {return builderModel.add_drug_administration_builder(scenario, EventModel.SubstanceInfusion)}}
    ListElement { name : "Drug-Oral"; section : "Administer Substances"; property var makeAction : function(scenario) {return builderModel.add_drug_administration_builder(scenario, EventModel.SubstanceOralDose)}}
    ListElement { name : "Fluids-Infusion"; section : "Administer Substances"; property var makeAction : function(scenario) { return builderModel.add_compound_infusion_builder(scenario) }}
    ListElement { name : "Transfusion"; section : "Administer Substances"; property var makeAction : function(scenario) {return builderModel.add_transfusion_builder(scenario)}}
    ListElement { name : "Needle Decompression"; section : "Interventions"; property var makeAction : function(scenario) {return builderModel.add_binary_builder("UINeedleDecompression.qml", scenario)}}
    ListElement { name : "Tourniquet"; section : "Interventions"; property var makeAction : function(scenario) { return builderModel.add_tourniquet_builder(scenario) } }
    ListElement { name : "Inhaler"; section : "Interventions"}
    ListElement { name : "Anesthesia Machine"; section : "Interventions"; property var makeAction : function(props) { return builderModel.add_anesthesia_machine_builder(scenario)}}
  }

  eventModel : EventModel {
    //C++ model -- we use the add_event function to append actions from scenario builder to _events vector (used when saving scenario to write to xml in Scenario.cpp)
    // When loading an existing scenario, we assign this model to an existing model derived from the file and stand up all actions from it
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

  activeRequestsModel : ObjectModel {
    id : activeRequestsModel
    signal invalidRequests(string err)
    signal substanceQuantityLoaded(string pathId, string sub, string quantity, string unit, string precision)
    property var requestQueue : []
    property var subRequestQueue : []
    function addRequest(path, unitClass, unit = "", precision = "", sub = "", quantity = ""){
      let splitPath = path.split(';');
      var v_requestForm = Qt.createComponent("UIDataRequest.qml");
      let requestRoot = splitPath.shift();    //removes first element in split path array and assigns to request type
      let requestLeaf = splitPath.pop();        //removes last element in split path array and assign to request name
      let requestBranches = splitPath;        //whatever is left over (maybe nothing) when we remove root and leaf
      if ( v_requestForm.status == Component.Ready)  {
        var v_request = v_requestForm.createObject(null, {  "pathId" : path, "requestRoot" : requestRoot, "requestBranches" : requestBranches, "unitClass" : unitClass,
                                                            "unitValue" : unit, "precisionValue" : precision, "substanceValue" : sub, "quantityValue" : quantity,
                                                            "requestLeaf" : requestLeaf, "scrollWidth" : windowContent.requestView.scrollWidth
                                                          });
        activeRequestsModel.append(v_request);
        return(v_request);
      } else {
        if (v_requestForm.status == Component.Error){
          console.log("Error : " + v_requestForm.errorString() );
        }
        console.log("Error : Data request component not ready");
        return null
      }
    }
    function loadRequests(){
      let subQRequests = []   //need to queue these and proces later because they have their own sub-list models that must be initialized
      for (let i = 0; i < requestQueue.length; ++i){
        let req = requestQueue[i];
        if (req.indexOf('|') == -1){
          requestQueue.splice(i,1)
          --i;
          continue;   //valid request found by data tree will be formatted "PathString|ScalarType|Unit;Precision;Substance(opt)}
        }
        if (req.includes("SUBSTANCEQ")){
          subRequestQueue.push(requestQueue.splice(i,1)[0]);    //splice returns an array (of size 1 in this case), so we need to grab element 0 from the result and append the string to subRequest
          --i;
          continue;
        }
        else {
          let unitInput = ""
          let precisionInput = ""
          let subInput = ""
          let quantityInput = ""
          let reqSplit = req.split('|');
          let pathId = reqSplit[0];       //This is the path through the menu to get to the request:  E.g. Physiology;Cardiovascular;HeartRate
          let scalarType = reqSplit[1];
          let options = reqSplit[2].split(";");   //breaks Unit;Precision;SubstanceQ options to [Unit, Precision, SubstanceQ]
          for (let i = 0; i < options.length; ++i){
            let opt = options[i].split('=');    //split option into [Label, value], e.g. UNIT=mg --> [UNIT, mg]
            if (opt[0] == "UNIT"){
              unitInput = opt[1]
            } else if (opt[0] == "PRECISION"){
              precisionInput = opt[1]
            }
          }
          addRequest(pathId, scalarType, unitInput, precisionInput, subInput, quantityInput)
        }
      }
    }
    function loadSubRequests(){
      for (let i = 0; i < subRequestQueue.length; ++i){
        let req = subRequestQueue[i]
        let unitInput = ""
        let precisionInput = ""
        let subInput = ""
        let quantityInput = ""
        let reqSplit = req.split('|');
        let pathId = reqSplit[0];       //This is the path through the menu to get to the request:  E.g. Physiology;Cardiovascular;HeartRate
        let scalarType = reqSplit[1];
        let options = reqSplit[2].split(";");   //breaks Unit;Precision;SubstanceQ options to [Unit, Precision, SubstanceQ]
        for (let i = 0; i < options.length; ++i){
          let opt = options[i].split('=');    //split option into [Label, value], e.g. UNIT=mg --> [UNIT, mg]
          if (opt[0] == "UNIT"){
            unitInput = opt[1]
          } else if (opt[0] == "PRECISION"){
            precisionInput = opt[1]
          } else if (opt[0] == "SUBSTANCEQ"){
            subInput = opt[1].split(",")[0]   //sub quantity data stored as SUBSTANCE=SubName,Quantity--only compartment data requests can have substance quantity option
            quantityInput = displayFormat(opt[1].split(",")[1])      //format string to have white space to match list model (PartialPressure->Partial Pressure)
          }
        }
        activeRequestsModel.substanceQuantityLoaded(pathId, subInput, quantityInput, unitInput, precisionInput)
      }
      requestQueue.length = 0 //clear queue--all requests will be re-written when we save
      subRequestQueue.length = 0
    }
    function removeRequest(path){
      //Can't bind menu element to index in active request model because menu elements are destroyed when menu section is collapsed, which removes bindings.
      //Instead, search for full path name that traverses tree from root to menu item (guaranteed to be unique)
      for (let i = 0; i < activeRequestsModel.count; ++i){
        let request = activeRequestsModel.get(i);
        if (request.pathId == path){
          activeRequestsModel.remove(i, 1);
          return;
        }
      }
    }
    function setRequestQueue(){
      let errMsg = "Invalid Data Requests:";    //for reporting id's of invalid requests
      activeRequestsModel.requestQueue.length = 0;   //clears any requests we had from previous calls
      let valid = true;
      for (let i = 0; i < activeRequestsModel.count; ++i){
        let request = activeRequestsModel.get(i);
        activeRequestsModel.requestQueue.push(request.formatOutput());
        if (!request.isValid()){
          errMsg += "\n\*  " + request.pathId;
          valid = false;
        }
      }
      if (!valid){
        warningMessage.text = errMsg;
        warningMessage.open();
      }
      return valid;
    }
  }

  builderModel : ActionModel {
    id : builderModel
    property double itemWidth : 0 // set when primary loader loads window content
    property double scenarioLength_s : 0     //Time at which the scenario ends
    property double scenarioLengthOverride_s : 0 //User provided value
    property alias scenarioEndItem : scenarioEnd.item
    property alias initialPatientItem : initialPatient.item
    //The scenario end component and initial patient component are in the model at startup
    Loader {
      id : scenarioEnd
      objectName : "scenarioEnd"
      sourceComponent : contentLoader.status == Loader.Ready ? root.timeEndComponent : undefined
      onLoaded : {
        item.scenarioLength_s = Qt.binding(function () { return builderModel.scenarioLength_s });
      }
    }
    Loader {
      id : initialPatient
      objectName : "scenarioStart"
      sourceComponent : contentLoader.status == Loader.Ready ? root.timeStartComponent : undefined
    }
    function createAction(actionElement){
      if (builderModel.get(0).objectName !== "scenarioEnd"){
        return;   //Make sure any actions added have been fully set up before adding new actions
      }
      console.log(itemWidth)
      var newAction = actionElement.makeAction(bg_scenario)
      newAction.viewLoader.state = "expandedBuilder";
      builderModel.insert(0, newAction); //Adding every new action to the top initially for editing
      let v_timeGap = root.timeGapComponent.createObject(null);
      builderModel.insert(1, v_timeGap);
      setConnections(newAction, v_timeGap)
      newAction.editing();
      actionSwitchView.currentIndex = 0; //New action gets focus
    }
    function loadAction(buildFunc) {
      let loadedAction = buildFunc()
      builderModel.insert(0, loadedAction);
      let v_timeGap = root.timeGapComponent.createObject(null);
      builderModel.insert(1, v_timeGap);
      setConnections(loadedAction, v_timeGap)
      loadedAction.buildSet(loadedAction)
      loadedAction.viewLoader.state = "collapsedBuilder"
    }
    function setConnections(action, timeGap){
      action.width = Qt.binding(function() { return builderModel.itemWidth})
      action.currentSelection = Qt.binding(function() { return actionSwitchView.currentIndex === action.ObjectModel.index} );
      timeGap.index = Qt.binding(function() { return builderModel.count - timeGap.ObjectModel.index -1 }) //E.g. count = 4, timeGap model index = 2 --> timeGap prop index = 1 (first time gap)
      action.selected.connect(function() {actionSwitchView.currentIndex = action.ObjectModel.index});
      action.editing.connect(function () {builderModel.adjustFade("ON", action.ObjectModel.index) } );
      action.buildSet.connect(builderModel.setViewIndex);
      action.remove.connect(removeAction);
    }
    function loadActions(){
      for (let i = 0; i < eventModel.get_event_count(); ++i){
        let event = eventModel.get_event(i);
        var action;
        switch (event.Type){
          case EventModel.AcuteRespiratoryDistress :
            builderModel.loadAction(function() {return add_single_range_builder("UIAcuteRespiratoryDistress.qml", bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.AcuteStress : 
            builderModel.loadAction(function() {return add_single_range_builder("UIAcuteStress.qml", bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.AirwayObstruction : 
            builderModel.loadAction(function() {return add_single_range_builder("UIAirwayObstruction.qml", bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.AnesthesiaMachineConfiguration : 
            builderModel.loadAction(function() {return add_anesthesia_machine_builder(bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.Apnea : 
            builderModel.loadAction(function() {return add_single_range_builder("UIApnea.qml", bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.AsthmaAttack : 
            builderModel.loadAction(function() {return add_single_range_builder("UIAsthmaAttack.qml", bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.BrainInjury : 
            builderModel.loadAction(function() {return add_traumatic_brain_injury_builder(bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.Bronchoconstriction :
            builderModel.loadAction(function() {return add_single_range_builder("UIBronchoconstriction.qml", bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.BurnWound :
            builderModel.loadAction(function() {return add_single_range_builder("UIBurnWound.qml", bg_scenario, event.Params, event.StartTime);});
            break;
          case EventModel.ConsumeNutrients :
            builderModel.loadAction(function() {return add_consume_meal_builder(bg_scenario, event.Params, event.StartTime);});
            break;
          case EventModel.Exercise :
            builderModel.loadAction(function() {return add_exercise_builder(bg_scenario, event.SubType, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.Hemorrhage :
            builderModel.loadAction(function() {return add_hemorrhage_builder(bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.Infection :
            builderModel.loadAction(function() {return add_infection_builder(bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.SubstanceAdministration : 
            if (event.SubType === EventModel.SubstanceCompoundInfusion){
              builderModel.loadAction(function() {return add_compound_infusion_builder(bg_scenario, event.Params, event.StartTime, event.Duration);});
            } else if (event.SubType === EventModel.Transfusion){
              builderModel.loadAction(function() {return add_transfusion_builder(bg_scenario, event.Params, event.StartTime, event.Duration);});
            } else {
              builderModel.loadAction(function() {return add_drug_administration_builder(bg_scenario, event.SubType, event.Params, event.StartTime, event.Duration);});
            }
            break;
          case EventModel.TensionPneumothorax :
            builderModel.loadAction(function() {return add_tension_pneumothorax_builder(bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.Tourniquet :
            builderModel.loadAction(function() {return add_tourniquet_builder(bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.PainStimulus :
            builderModel.loadAction(function() {return add_pain_stimulus_builder(bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.AdvanceTime :
            //We should only get an AdvanceTime action when we are extending out the scenario beyond the duration of the last action, which would be the last action in the queue
            // Check just to make sure
            if (i == eventModel.get_event_count()-1){
              scenarioLengthOverride_s = scenarioLength_s + event.Duration
            }
            break;
          default : 
            console.log(event.TypeName + " not added to scenario")
        }
      }
      updateTimeComponents()  
      refreshScenarioLength()
    }
    function removeAction(){
      if (windowContent.scenarioView.currentIndex !== -1){
        builderModel.remove(windowContent.scenarioView.currentIndex, 2);   //Remove two items to get time block associated with action
        builderModel.updateTimeComponents();
        builderModel.refreshScenarioLength();
        windowContent.scenarioView.currentIndex = -1;
        builderModel.adjustFade("OFF", -1)
      }
    }
    function adjustFade(state, index){
      for (let i = 0; i < builderModel.count; i++){
        if (state == "ON"){
          if (i != index){
            builderModel.get(i).opacity = 0.25;
          }
        } else {
          builderModel.get(i).opacity = 1.0;
        }
      }
    }
    function setViewIndex(action){
      //When we edit an action (in particular it's start time) we need to make sure that we percolate it up/down to the right location in the view area
      let newIndex = 1;
      adjustFade("OFF", 0);
      let actionIndex = action.ObjectModel.index;  //where the action currently resides in the view
      let startIndex = actionIndex == 0 ? 3 : 1; //If object is at index 0, then it has just been created. There is a time block (not visible) and the end sim block below it, so the first action to compare this action to is at index 3.  If this action has already been placed in list, then the end sim block occupies index 0 and the first action for comparison is at index 1 
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
      windowContent.scenarioView.currentIndex = -1;
    }
    function setActionQueue(){
      //Add actions to event model.  They are in reverse chronological order, so count backwards (seems more efficient than trying to put in front and forcing array to shift elements on every addition)
      //Very bottom item (count-1) is the initial patient, next lowest item (count -2) is time to first action, so we start at index (count - 3) and add every other item to skip over time gaps (can't add them as AdvanceTime
      //actions yet because we do not know where "Deactivate" functions go yet)
      eventModel.clear_events();    //empty event model, we will reconstruct queue from scratch based on what is inside the scenario builder
      for (let i = builderModel.count-3; i >= 0; i-=2){
        let action = builderModel.get(i);
        eventModel.add_event(action.actionType, action.actionClass, action.actionSubClass, action.buildParams, action.actionStartTime_s, action.actionDuration_s);
      }
      //Push back last advance time action -- set its "start time" to scenario length so that it will be guaranteed to be at end of sorted queue (calculate duration in Scenario.cpp after "deactivate" actions are accounted for)
      eventModel.add_event("Advance Time", EventModel.AdvanceTime, -1, "", builderModel.scenarioLength_s, 0.0);
    }
    function updateTimeComponents(){
      for (let i = 2; i < builderModel.count; i+=2){
        //time blocks are always the even indexed objects in model (skippint 0, 1, 2 because that is where sim length and action are 
        if (i == builderModel.count-2){
          //bottom time block, so it's time is just whatever start time the action above it has
          builderModel.get(i).blockTime_s = builderModel.get(i-1).actionStartTime_s;
        } else {
          //intermediate time block, set value to the difference in start time between action below (earlier) and above (later)
          let belowActionStart = builderModel.get(i+1).actionStartTime_s;
          let aboveActionStart = builderModel.get(i-1).actionStartTime_s;
          builderModel.get(i).blockTime_s = aboveActionStart - belowActionStart;
        }
      }
    }
    function refreshScenarioLength(){
      let newScenarioLength_s = 0
      for (let i = 1; i < builderModel.count-1; i+=2){
        let actionStart = builderModel.get(i).actionStartTime_s;
        let actionDuration = builderModel.get(i).actionDuration_s;
        if (actionStart + actionDuration > newScenarioLength_s){
          newScenarioLength_s = actionStart + actionDuration;
        }
      }
      if (newScenarioLength_s > scenarioLengthOverride_s){
        scenarioLength_s = newScenarioLength_s;
      } else {
        scenarioLength_s = scenarioLengthOverride_s;
      }
      //Update final advance time (only if there is an action there, which happens when count > 2 (start and final block always there)
      let finalActionStart = 0;
      if (builderModel.count > 2){
        finalActionStart = builderModel.get(1).actionStartTime_s;
      }
      scenarioEnd.item.finalAdvanceTime_s = scenarioLength_s - finalActionStart;
    }
  }
  
  
}
