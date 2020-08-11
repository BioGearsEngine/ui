import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import QtQml.Models 2.12
import com.biogearsengine.ui.scenario 1.0

Window {
  id : scenarioBuilder
  title : "Scenario Builder"
  property alias actionModel : actionListModel
  property alias actionDelegate : actionListDelegate
  property alias actionView : actionListView
  property alias scenarioView : scenarioListView
  property alias builderModel : builderActionModel

  property Scenario bg_scenario

  property var drugData : ({"route" : "bolus", "concentration" : 0.0,"dose" : 0.0})

  GridLayout {
    anchors.fill : parent
    rows : 4
    columns : 2

    Item {
      id : actionLabel
      Layout.row : 0
      Layout.column : 0
      Layout.preferredHeight : parent.height * 0.05
      Layout.preferredWidth : parent.width * 0.2
      Label {
        id : actionLabelText
        anchors.centerIn: parent
        text : "Actions"
        font.pointSize : 16
      }  
    }
    Item {
      id : scenarioLabel
      Layout.row : 0
      Layout.column : 1
      Layout.preferredHeight : parent.height * 0.05
      Layout.preferredWidth : parent.width * 0.8
      Label {
        id : scenarioLabelText
        anchors.centerIn: parent
        text : "Scenario"
        font.pointSize : 16
      }  
    }

    Rectangle {
      Layout.row : 1
      Layout.column : 0
      Layout.preferredHeight : parent.height * 0.75
      Layout.preferredWidth : parent.width * 0.2
      color : "transparent"
      border.color : "grey"
      border.width : 2
      ListView {
        id : actionListView
        property double scrollWidth : actionScroll.width
        anchors.fill : parent
        model : actionModel
        delegate : actionDelegate
        currentIndex : -1
        clip : true
        ScrollBar.vertical : ScrollBar {
          id : actionScroll
          policy : ScrollBar.AlwaysOn
        }
        section {
          property : "section"
          delegate : Rectangle {
            color : "navy"
            width : parent.width - actionListView.scrollWidth
            height : childrenRect.height
            Text {
              anchors.horizontalCenter : parent.horizontalCenter
              text : section
              font.pixelSize : 20
              color : "white"
            }
          }
        }
      }
    }
    Rectangle {
      id : scenario
      color : 'transparent'
      border.color : 'blue'
      Layout.preferredHeight : parent.height * 0.75
      Layout.preferredWidth : parent.width * 0.8
      border.width : 1
      Layout.row : 1
      Layout.column : 1
      ListView {
        id : scenarioListView
        property double scrollWidth : scenarioScroll.width
        anchors.fill : parent
        clip : true
        currentIndex : -1
        spacing : 5
        model : builderModel //scenarioObjectModel
        ScrollBar.vertical : ScrollBar {
          id : scenarioScroll
          policy : ScrollBar.AlwaysOn
        }
      }
    }

    Item {
      id : addButtonArea
      Layout.preferredWidth : parent.width * 0.2
      Layout.preferredHeight : parent.height * 0.075
      Layout.row : 2
      Layout.column : 0
      Button {
        id : addButton
        width : parent.width / 2
        height : parent.height
        anchors.centerIn : parent
        text : "Add"
        onClicked : {
          if (actionView.currentIndex!==-1){
            builderModel.createAction(actionModel.get(actionView.currentIndex))
          }
          actionView.currentIndex = -1
        }
      }
    }

    Item {
      id : scenarioButtonArea
      Layout.preferredWidth : parent.width * 0.8
      Layout.preferredHeight : parent.height * 0.075
      Layout.row : 2
      Layout.column : 1
      RowLayout {
        width : parent.width / 2
        height : parent.height
        anchors.centerIn : parent
        spacing : 5
        Button {
          id : removeButton
          Layout.preferredHeight : parent.height
          Layout.preferredWidth : parent.width / 4
          text : "Remove"
          onClicked : {
            if (scenarioView.currentIndex !== -1){
              scenarioModel.remove(scenarioView.currentIndex, 1)
              scenarioView.currentIndex = -1
            }
          }
        }
      }
    }
    Rectangle {
      id : scenarioButtons
      color : "transparent"
      border.color : "red"
      
    }

    Rectangle {
      id : optionArea
      color : 'transparent'
      border.color : 'green'
      Layout.preferredHeight : parent.height * 0.075
      Layout.preferredWidth : parent.width
      border.width : 1
      Layout.row : 3
      Layout.column : 0
      Layout.columnSpan : 2
      Button {
        id : saveScenario
        text : "Save"
        anchors.centerIn : parent
        height : parent.height
        width : parent.width / 3
        onClicked : {
          builderModel.setActionQueue()
        }
      }
    }
  } 

  //List model elements can't assign javascript objects to properties, but JS objects are what get passed to ActionModel functions.  Get around this 
  //by assigning each action a "genProps" function that returns the initial properties we want, which we can then pass along to their respective "makeAction" function
  //This also lets us assign differently named properties to each action (if we did nested ListElements, ListModel expects each subelement to get the same properties defined)
  ListModel {
    id : actionListModel
    ListElement { name : "Consume Meal"; section : "Patient Actions"; property var makeAction : function (props, scenario) {return builderModel.add_consume_meal_builder(props, scenario)}; property var genProps : function() {return {"carbs_g" : 0.0, "fat_g" : 0.0, "protein_g" : 0.0, "calcium_mg" : 0.0, "sodium_mg" : 0.0, "water_mL" : 0.0} } }
    ListElement { name : "Cycling"; section : "Exercise"; property var makeAction : function (props, scenario) {return builderModel.add_exercise_builder(props, scenario)}; property var genProps : function() {return {"type" : "Cycling", "cadence" : 0.0, "power" : 0.0, "weight" : 0.0} } }
    ListElement { name : "Running"; section : "Exercise"; property var makeAction : function (props, scenario) {return builderModel.add_exercise_builder(props, scenario)}; property var genProps : function() {return {"type" : "Running", "velocity" : 0.0, "incline" : 0.0, "weight" : 0.0} } }
    ListElement { name : "Strenth Training"; section : "Exercise"; property var makeAction : function (props, scenario) {return builderModel.add_exercise_builder(props, scenario)}; property var genProps : function() {return {"type" : "Strength", "weight" : 0.0, "repetitions" : 0.0} } }
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

  Component {
    id : actionListDelegate
    Rectangle {
      id : delegateWrapper
      height : delegateText.height * 1.4
      width : actionView.width - actionView.scrollWidth //aligns with ListView preferred width
      Layout.alignment : Qt.AlignLeft
      color : ListView.isCurrentItem ? "lightskyblue" : "transparent"
      border.color: "lightskyblue"
      border.width : ListView.isCurrentItem ? 2 : 0
      Text {
          id: delegateText
          anchors.verticalCenter : parent.verticalCenter
          leftPadding: 5
          text : name
          font.pointSize : 12
          Layout.alignment : Qt.AlignVCenter
      }
      MouseArea {
        anchors.fill : parent
        onClicked : {
            actionListView.currentIndex = index;
        }
      }
    }
  }

  ActionModel {
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
      console.log(newAction)
    }
    function setViewIndex(action){
      //When we edit an action (in particular it's start time) we need to make sure that we percolate it up/down to the right location in the view area
      if (builderActionModel.count === 1){ 
        return; //this is the only action in the view
      }
      let actionIndex = action.ObjectModel.index;  //where the action currently resides in the view
      let actionTime = action.activateData.time;   //the time the action is to be applied
      let newIndex = 0;   //Where we will put the action to make sure we are ordered by time
      while (actionTime < builderActionModel.get(newIndex + 1).activateData.time){
        ++newIndex;
        if (newIndex===builderActionModel.count-1){
          break;
        }
      }
      builderActionModel.move(actionIndex, newIndex, 1);
    }
    function setActionQueue(){
      //Add actions to queue.  They are in reverse chronological order, so count backwards (seems more efficient than trying to put in front and forcing array to shift elements on every addition)
      for (let i = builderActionModel.count-1; i >= 0; --i){
        builderActionModel.actionQueue.push(builderActionModel.get(i).activateData);
      }
      //Now we need to add any deactivate actions that are present. Loop over model again.  If there is a deactivate action, use binary search to figure out where to place it
      for (let i = 0; i < builderActionModel.count; ++i){
        let entry = builderActionModel.get(i);
        if (entry.deactivateData){
          let dIndex = binarySearch(entry.deactivateData, 0, actionQueue.length); //Not worrying about possibility of < element 0 since any deactivate action would have to happen after first action
          console.log(dIndex)
          builderActionModel.actionQueue.splice(dIndex, 0, entry.deactivateData);   //Splice(i, j, var) adds var at index i and removes j items
        }
      }
      //Test
      for (let i = 0; i < builderActionModel.actionQueue.length; ++i){
        console.log(actionQueue[i].name + " : " + actionQueue[i].time);
      }
    }
    function binarySearch(action, left, right){
      console.log(left, right)
      if (right - left === 1){
        return right    //item is > left and < right, so it will take the index of right
      } else {
        let compIndex = left + Math.floor((right-left)/2);
        let compAction = builderActionModel.actionQueue[compIndex];
        if (action.time < compAction.time){
          return binarySearch(action, left, compIndex);
        } else {
          return binarySearch(action, compIndex, right);
        }
      }  
    }
  }

}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 