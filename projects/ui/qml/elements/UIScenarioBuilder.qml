import QtQuick 2.12
import QtQuick.Window 2.12
import QtQml.Models 2.12
import com.biogearsengine.ui.scenario 1.0
import Qt.labs.folderlistmodel 2.12

UIScenarioBuilderForm {
	id: root

	signal validScenario (string type, var data)
	signal invalidScenario(string errorStr)
	signal clearScenario()
  signal scenarioLoaded()
  property bool editingAction : false

	onClosing : {
    clearScenario();
    close.accepted = true
	}

  /***Reset action editor and data request editor***/
  onClearScenario: {
    editingAction = false;
    builderModel.unsetConnections();
    builderModel.clear();
    builderModel.scenarioLength_s = 0.0;
    builderModel.scenarioLengthOverride_s = 0.0;
    activeRequestsModel.requestQueue.length = 0;
    activeRequestsModel.subRequestQueue.length = 0
    activeRequestsModel.clear();
    root.bgRequests.resetData();
    scenarioInput = ""
    scenarioName = ""
  }
  /***Called from MenuArea when Load Scenario option is selected.  Inputs events, requests, and sampling are received from scenarioFileLoaded signal
      emitted by Scenario::edit_scenario function***/
  function loadScenario(events, requests, sampling){
    scenarioLoaded(); //emit this first to force request menu to respond to data request model changes and open all the sub-menus that we need
    requestView.forceLayout();  //this may not be necessary but I really want to make sure that request menu is finished before proceeding
    eventModel = events;   
    activeRequestsModel.requestQueue = requests;
    root.scenarioName = events.get_timeline_name();
    root.scenarioInput = events.get_patient_name();
    root.isPatientFile = !events.get_patient_name().includes('@');   //engine state files have '@', patient files do not
    let sampleSplit = sampling.split(';');
    root.samplingFrequency = (Number(sampleSplit[0]).toFixed(0)).toString() + ";" + sampleSplit[1] ;   //Qml inteprets an int as "0.0000", so we need to get it to a number and trim it
    builderModel.loadActions();
    activeRequestsModel.loadRequests();
    
  }
	/***Helper function to format camel case text for display***/
  function displayFormat (role) {
		let formatted = role.replace(/([a-z])([A-Z])([a-z])/g, '$1 $2$3')     //Formats BloodVolume as "Blood Volume", but formats pH as "pH"
		return formatted
	}
  /***Helper function to convert length of time to clock time for display purposes***/
	function seconds_to_clock_time(time_s) {
    var v_seconds = time_s % 60;
    var v_minutes = Math.floor(time_s / 60) % 60;
    var v_hours   = Math.floor(time_s / 3600);

    v_seconds = (v_seconds<10) ? "0%1".arg(v_seconds) : "%1".arg(v_seconds);
    v_minutes = (v_minutes<10) ? "0%1".arg(v_minutes) : "%1".arg(v_minutes);
    v_hours = (v_hours < 10) ? "0%1".arg(v_hours) : "%1".arg(v_hours);

    return "%1:%2:%3".arg(v_hours).arg(v_minutes).arg(v_seconds);
  }
  /***Helper function to convert clock time displayed on timeline components to length in seconds for comparison purposes***/
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
  /***Save all scenario data.  Triggered when Save button is clicked.  Make sure that we are not currently editing action and that data requests are
      valid before calling create_scenario function in Scenario.cpp.  If successful, close window.***/
  function saveScenario(){
    //If we are still editing an action, then do not trigger Save
    if (root.editingAction){
      warningMessage.text = "Action editing in process";
      warningMessage.open();
      return;
    }
    //Make sure that data requests are valid before saving.
    if (activeRequestsModel.setRequestQueue()){
      builderModel.setActionQueue()
      let prefix = isPatientFile ? "" : "./states/";
      eventModel.set_timeline_name(root.scenarioName);
      eventModel.set_patient_name(prefix + root.scenarioInput + ".xml");
      let accepted = bg_scenario.create_scenario(eventModel, activeRequestsModel.requestQueue, root.samplingFrequency);
      //If save was successful, we can close window.  If not, return and keep window open
      if (accepted){
        root.close();
      } else {
        return;
      }
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
    ListElement { name : "Patient Assessment"; section : "Write Data"; property var makeAction : function(props) { return builderModel.add_patient_assessment_builder(scenario)}}
    ListElement { name : "Serialize State"; section : "Write Data"; property var makeAction : function(props) { return builderModel.add_serialize_state_builder(scenario)}}
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
    /***Add a data request to the active request view.  This function can be called by checking the box associated with the request in the request menu
        or by loading a request from a scenario file***/
    function addRequest(path, unitClass, unit = "", precision = "", sub = "", quantity = ""){
      let splitPath = path.split(';');
      var v_requestForm = Qt.createComponent("UIDataRequest.qml");
      let requestRoot = splitPath.shift();    //removes first element in split path array and assigns to request type
      let requestLeaf = splitPath.pop();        //removes last element in split path array and assign to request name
      let requestBranches = splitPath;        //whatever is left over (maybe nothing) when we remove root and leaf
      if ( v_requestForm.status == Component.Ready)  {
        var v_request = v_requestForm.createObject(null, {  "pathId" : path, "requestRoot" : requestRoot, "requestBranches" : requestBranches, "unitClass" : unitClass,
                                                            "unitValue" : unit, "precisionValue" : precision, "substanceValue" : sub, "quantityValue" : quantity,
                                                            "requestLeaf" : requestLeaf, "scrollWidth" : requestView.scrollWidth
                                                          });
        let itemAdded = false;
        activeRequestsModel.append(v_request);
        //The forceLayout step below slows things down a tad, but it is crucial when loading a scenario that could potentially have dozens of requests. 
        //Otherwise, view will queue requests to add in batch, but there's no pinpointing exactly when this happens and it will cause problems when 
        //loading the substance quantity requests later (view detects multiple items trying to access the same index)
        activeRequestView.forceLayout(); 
        return(v_request);
      } else {
        if (v_requestForm.status == Component.Error){
          console.log("Error : " + v_requestForm.errorString() );
        }
        console.log("Error : Data request component not ready");
        return null
      }
    }
    /***Load data requests from Scenario file.  Substance quantity data requests (which occupy sub-menus inside Request List View) are cached to be 
        loaded later (once other active requests have been processed).  Request Queue was set in root.loadExisting function.  Loop over requests and
        decode request strings to get information about request type, unit, and precision.  Call addRequest function with this data to add request
        to active request list***/
    function loadRequests(){
      for (let i = 0; i < requestQueue.length; ++i){
        let req = requestQueue[i];
        if (req.indexOf('|') == -1){
          requestQueue.splice(i,1) //remove invalid requests from queue
          --i;    //step loop back 1 iteration because the array was resized
          continue;   //valid request found by data tree will be formatted "PathString|ScalarType|Unit;Precision;Substance(opt)}
        }
        if (req.includes("SUBSTANCEQ")){
          subRequestQueue.push(requestQueue.splice(i,1)[0]);    //splice returns an array (of size 1 in this case), so we need to grab element 0 from the result and append the string to subRequest
          --i;   //step loop back 1 iteration because the array was resized
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
          if (scalarType==""){
            unitInput = "unitless"    //If request has not unit, it won't get assigned a UNIT flag.  If we can't find a scalarType, then assign unit input to "unitless"
          }
          addRequest(pathId, scalarType, unitInput, precisionInput, subInput, quantityInput)
        }
      }
      loadSubRequests()
    }
    /***Substance Quantity data requests (in Compartment menu) need to be loaded from Scenario file separately because they inhabit sub-menus that are 
        distinct from request menu stood up based off data from DataRequestTree.  These requests cannot be loaded at the same time as the other data
        requests because the active request list view detects multiple sources changing its indexing (which causes an error).  This function therefore
        is not called until all other data requests have been loaded (confirmed by checking the list view count == number of non-sub quantity requests)***/
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
    /***Remove a request from the active data request list***/
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
    /***When Save button clicked, check that all the data requests have required input.  If all are valid, return true and data request list will be 
        passed to Scenario.cpp.  If false, return to scenario window and show a message to user that one of the requests is invalid***/
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
    actionSwitchView : scenarioView
    property double scenarioLength_s : 0     //Time at which the scenario ends
    property double scenarioLengthOverride_s : 0 //User provided value
    /***Creates a new action with blank input fields and a time component***/
    function createAction(actionElement){
      if (root.editingAction){
        return;   //Make sure any actions added have been fully set up before adding new actions
      }
      var newAction = actionElement.makeAction(bg_scenario)
      newAction.viewLoader.state = "expandedBuilder";
      builderModel.insert(0, newAction); //Adding every new action to the top initially for editing
      let v_timeGap = root.timeGapComponent.createObject(null);
      builderModel.insert(1, v_timeGap);
      setConnections(newAction, v_timeGap)
      newAction.editing(newAction.modelIndex);
      actionSwitchView.currentIndex = 0; //New action gets focus
    }
    /***Creates a new action based on input from a scenario file and a time component with the duration of the action***/
    function loadAction(buildFunc) {
      let loadedAction = buildFunc()
      loadedAction.viewLoader.state = "collapsedBuilder"
      builderModel.insert(0, loadedAction);
      let v_timeGap = root.timeGapComponent.createObject(null);
      builderModel.insert(1, v_timeGap);
      setConnections(loadedAction, v_timeGap)
      loadedAction.buildSet(loadedAction) 
    }
    /***Set signal connections and property bindings on action that has just been added to model.  Width must be bound because so that action re-centers
        itself correctly when the size of the window changes***/
    function setConnections(action, timeGap){
      action.width = Qt.binding(function() { return scenarioView.width - scenarioView.scrollWidth})
      action.currentSelection = Qt.binding(function() { return actionSwitchView.currentIndex == action.ObjectModel.index} );  //When true, action will have highlighted boundary (see ActionForm.ui)
      action.modelIndex = Qt.binding(function() { return action.ObjectModel.index} )  //Allow each action to track its position in the model (used when emitting selected and editing signals)
      timeGap.index = Qt.binding(function() { return builderModel.count - timeGap.ObjectModel.index -1 }) //E.g. count = 4, timeGap model index = 2 --> timeGap prop index = 1 (first time gap)
      action.selected.connect(setCurrentIndex);   //When action is selected, update the current index of the view
      action.editing.connect(setEditingView);     //When editing an action, adjust view settings (like fade)
      action.buildSet.connect(builderModel.setViewIndex); //When an action has had its input set, determine its relative place in model view
      action.remove.connect(removeAction);    //When "remove" option clicked in action pop-up menu, remove it from model
    }
    /***Signals and property bindings must be disconnected/unset before removing the action from the model.  Otherwise, items might persist because another
        element is holding on to the connection.  Loop over all elements in model: Even indexed items are action blocks and odd indexed items are time gap
        components.  "Disconnect" function removes signal connections, and explicitly setting properties that were bound by Qt.binding function removes the 
        binding.  This function is called just prior to clearing model when window is closing***/
    function unsetConnections(){
      for (let i = 0; i < builderModel.count; ++i){
        let element = builderModel.get(i);
        if (i % 2 == 0){
          element.selected.disconnect(setCurrentIndex);
          element.buildSet.disconnect(setViewIndex);
          element.editing.disconnect(setEditingView);
          element.remove.disconnect(removeAction)
          element.width = 0;
          element.currentSelection = false;
          element.modelIndex = -1;
        } else {
          element.index = -1;
        }
      }
    }
    /***This function is called when loading actions from a scenario file.  The eventModel will be set based on scenario input (see root.LoadExisting).
        Loop over all actions in event model and call the appropriate build action according to the event type***/
    function loadActions(){
      for (let i = 0; i < eventModel.get_event_count(); ++i){
        let event = eventModel.get_event(i);
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
            builderModel.loadAction(function() {return add_infection_builder(bg_scenario, event.Params, event.StartTime);});
            break;
          case EventModel.SubstanceAdministration : 
            if (event.SubType === EventModel.SubstanceCompoundInfusion){
              //Sub compound infusion has distinct build function
              builderModel.loadAction(function() {return add_compound_infusion_builder(bg_scenario, event.Params, event.StartTime);});
            } else if (event.SubType === EventModel.Transfusion){
              //Transfusion has distinct build function
              builderModel.loadAction(function() {return add_transfusion_builder(bg_scenario, event.Params, event.StartTime);});
            } else if (event.SubType === EventModel.SubstanceInfusion) {
              //Infusion has a duration value to set
              builderModel.loadAction(function() {return add_drug_administration_builder(bg_scenario, event.SubType, event.Params, event.StartTime, event.Duration);});
            } else {
              //Else include bolus and oral dose, which do not need a duration set
              builderModel.loadAction(function() {return add_drug_administration_builder(bg_scenario, event.SubType, event.Params, event.StartTime);});
            }
            break;
          case EventModel.PainStimulus :
            builderModel.loadAction(function() {return add_pain_stimulus_builder(bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.PatientAssessmentRequest :
            builderModel.loadAction(function() {return add_patient_assessment_builder(bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.SerializeState : 
            builderModel.loadAction(function() {return add_serialize_state_builder(bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.TensionPneumothorax :
            builderModel.loadAction(function() {return add_tension_pneumothorax_builder(bg_scenario, event.Params, event.StartTime, event.Duration);});
            break;
          case EventModel.Tourniquet :
            builderModel.loadAction(function() {return add_tourniquet_builder(bg_scenario, event.Params, event.StartTime, event.Duration);});
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
      refreshScenarioLength()
    }
    /***Remove an action from the build model.  This function can be called by "Remove" button in window or from pop-up menu activated by right-clicking
        on action***/
    function removeAction(){
      if (scenarioView.currentIndex !== -1){
        builderModel.remove(scenarioView.currentIndex, 2);   //Remove two items to get time block associated with action
        builderModel.updateTimeComponents();
        builderModel.refreshScenarioLength();
        scenarioView.currentIndex = -1;
        builderModel.adjustFade("OFF", -1);
        root.editingAction = false;
      }
    }
    /***Sync model view index with the index of the currently selected object***/
    function setCurrentIndex(ind){
      actionSwitchView.currentIndex = ind;
    }
    /***When we are editing an action, adjust the opacity of other elements in model view and lock other elements from editing unti this one has been
        finished***/
    function setEditingView(ind){
      builderModel.adjustFade("ON", ind);
      root.editingAction = true;
    }
    /***Turn fade on/off depending on whether an action is currently being edited or not***/
    function adjustFade(state, index){
      if (state == "ON"){
        for (let i = 0; i < builderModel.count; ++i){
          if (i != index){
            builderModel.get(i).opacity = 0.25;
          }
        }
        actionSwitchView.headerItem.opacity = 0.25;
        actionSwitchView.footerItem.opacity = 0.25;
      } else {
        for (let i = 0; i < builderModel.count; ++i){
         builderModel.get(i).opacity = 1.0;
        }
        actionSwitchView.headerItem.opacity = 1.0;
        actionSwitchView.footerItem.opacity = 1.0;
      }
    }
    /***When an action has been fully defined and set, it must be placed in chronological order in the model view.  This function searches across
        model elements, comparing start times, until it reaches the appropriate location for the action being set***/
    function setViewIndex(action){
      root.editingAction = false;   //this function called when build is set, so we are done editing
      //When we edit an action (in particular it's start time) we need to make sure that we percolate it up/down to the right location in the view area
      let newIndex = 0;
      adjustFade("OFF", 0);
      let actionIndex = action.ObjectModel.index;  //where the action currently resides in the view
      let startIndex = actionIndex == 0 ? 2 : 0; //If object is at index 0, then it has just been created. There is a time block (not visible) and the end sim block below it, so the first action to compare this action to is at index 2.  If this action has already been placed in list, then the first action for comparison is at index 0 
      let actionTime = action.actionStartTime_s;   //the time the action is to be applied
      if (builderModel.count > 2){
        //<=2 means there is only one action so far (this action and it's companion time block)  
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
      scenarioView.currentIndex = -1;
    }
    /***When Save button is clicked, we add actions in view to the event model (defined in C++) so that we can access actions in Scenario.cpp
        and create Scenario file***/
    function setActionQueue(){
      //Add actions to event model.  They are in reverse chronological order, so count backwards (seems more efficient than trying to put in front and forcing array to shift elements on every addition)
      //Very bottom item (count-1) is the time to first action, so we start at index (count - 2) and add every other item to skip over time gaps (can't add them as AdvanceTime
      //actions yet because we do not know where "Deactivate" functions go yet)
      eventModel.clear_events();    //empty event model, we will reconstruct queue from scratch based on what is inside the scenario builder
      for (let i = builderModel.count-2; i >= 0; i-=2){
        let action = builderModel.get(i);
        eventModel.add_event(action.actionType, action.actionClass, action.actionSubClass, action.buildParams, action.actionStartTime_s, action.actionDuration_s);
      }
      //Push back last advance time action -- set its "start time" to scenario length so that it will be guaranteed to be at end of sorted queue (calculate duration in Scenario.cpp after "deactivate" actions are accounted for)
      eventModel.add_event("Advance Time", EventModel.AdvanceTime, -1, "", builderModel.scenarioLength_s, 0.0);
    }
    /***When an action has been moved in the model view, the components showing the time between actions must be updated. Loop over odd-indexed items 
        (which are the time components) and adjust the time based on the difference between the start times of adjacent actions***/
    function updateTimeComponents(){
      for (let i = 1; i < builderModel.count; i+=2){
        //time blocks are always the odd indexed objects in model (skipping 0 because that is where first action is)
        if (i == builderModel.count-1){
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
    /***When an action has been edited, the length of the scenario must be updated.  Compare the new scenario length against override set by user (done
        by clicking "Extend Scenario" arrow in Scenario Length component***/
    function refreshScenarioLength(){
      let newScenarioLength_s = 0
      for (let i = 0; i < builderModel.count; i+=2){
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
      if (builderModel.count > 0){
        finalActionStart = builderModel.get(0).actionStartTime_s;
      }
      actionSwitchView.headerItem.finalAdvanceTime_s = scenarioLength_s - finalActionStart;
    }
  }
}
