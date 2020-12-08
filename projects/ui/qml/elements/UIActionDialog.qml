import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import Qt.labs.folderlistmodel 2.12
import com.biogearsengine.ui.scenario 1.0

UIActionDialogForm {
  id: root

  // Writes out properties of dialog for debugging purposes
  function getProperties(props){
    for (let prop in props){
      console.log(prop, props[prop])
    }
  }

  //-----------------------------------------
  // Assigns a new value to prop based on signal from dialog component
  // args : value = the new value (passed from component update signal)
  //        prop = the property in actionProps to update
  function updateProperty(value, prop) {
    actionProps[prop] = value
  }

  //-----------------------------------------
  // Loops over all components added to dialog contentItem and calls their respective isValid methods
  // Returns false if any property has not been assigned a valid value
  function validProps(){
    let valid = true
    errorString = "" //Reset error string
    for (let child in dialogItem.children){
      if (dialogItem.children[child].isValid){    //Check if child item has isValid function defined
        if (!dialogItem.children[child].isValid()){ //Execute isValid function
          valid = false
          errorString += dialogItem.children[child].objectName + " is invalid\n";
        }
      }
    }
    return valid
  }
   
   //-----------------------------------------
  function setContent(actionName){
    root.title = actionName
    switch (actionName){
      case "Anesthesia Machine" :
        root.height = 450
        root.width = 750
        dialogLoader.sourceComponent = anesthesiaComponent
        return;
      case "Acute Respiratory Distress" : 
      case "Acute Stress" :
      case "Airway Obstruction" :
      case "Apnea" :
      case "Asthma Attack" :
      case "Bronchoconstriction" :
        root.height = 150
        root.width = 500
        dialogLoader.sourceComponent = singleRangeComponent;
        dialogItem.labelText = "Severity"
        return;
      case "Burn" :
        root.height = 150
        root.width = 500
        dialogLoader.sourceComponent = singleRangeComponent;
        dialogItem.labelText = "TBSA"
        return;
      case "Consume Meal" :
        root.height = 300
        root.width = 600
        dialogLoader.sourceComponent = consumeMealComponent
        return;
      case "Cycling" : 
        root.height = 250
        root.width = 500
        dialogLoader.sourceComponent = cycleRunComponent;
        dialogItem.cycling = true
        return;
      case "Drug-Bolus" :
        root.height = 300;
        root.width = 600
        dialogLoader.sourceComponent = drugBolusComponent;
        return;
      case "Drug-Infusion" :
        root.height = 300;
        root.width = 600
        dialogLoader.sourceComponent = drugInfusionComponent;
        return;
      case "Drug-Oral" :
        root.height = 300;
        root.width = 600
        dialogLoader.sourceComponent = drugOralComponent;
        return;
	  case "Environment" :
        root.height = 450
        root.width = 750
        dialogLoader.sourceComponent = environmentComponent
        return;
      case "Fluids-Infusion" :
        root.height = 300;
        root.width = 600
        dialogLoader.sourceComponent = fluidInfusionComponent;
        dialogItem.transfusion = false;
        return;
      case "Hemorrhage" :
        root.height = 250
        root.width = 500
        dialogLoader.sourceComponent = hemorrhageComponent;
        return;
      case "Infection" :
        root.height = 250
        root.width = 500
        dialogLoader.sourceComponent = infectionComponent;
        return;
      case "Needle Decompression" :
        root.height = 150
        root.width = 500
        dialogLoader.sourceComponent = needleComponent;
        return;
      case "Other Exercise" :
        root.height = 250
        root.width = 600
        dialogLoader.sourceComponent = genericExerciseComponent;
        return;
      case "Pain Stimulus" :
        root.height = 250
        root.width = 500
        dialogLoader.sourceComponent = painComponent;
        return;
      case "Running" : 
        root.height = 250
        root.width = 500
        dialogLoader.sourceComponent = cycleRunComponent;
        dialogItem.cycling = false
        return;
      case "Strength Training" :
        root.height = 200
        root.width = 500
        dialogLoader.sourceComponent = strengthComponent
        return;
      case "Tension Pneumothorax" :
        root.height = 250
        root.width = 500
        dialogLoader.sourceComponent = pneumothoraxComponent
        return;
      case "Tourniquet" :
        root.height = 250
        root.width = 500
        dialogLoader.sourceComponent = tourniquetComponent
        return;
      case "Transfusion" :
        root.height = 300;
        root.width = 600
        dialogLoader.sourceComponent = fluidInfusionComponent;
        dialogItem.transfusion = true;
        return;
      case "Traumatic Brain Injury" :
        root.height = 200
        root.width = 500
        dialogLoader.sourceComponent = tbiComponent
        return;
      default : 
        dialogLoader.sourceComponent = undefined;
        return;
    }
  }

  Component {
    id : anesthesiaComponent
    GridLayout {
      id : anesthesiaAction
      rows : 8
      columns : 2
      columnSpacing : 20
      rowSpacing : 5
      property var props : ({connection : '', primaryGas : '', inletFlow : 5, pMax : 10, peep : 1, ieRatio : 0.5, o2Frac : 0.25, o2Source : '', respirationRate : 12, reliefPressure : 100, bottle1 : 0, bottle2 : 0, leftSub : [], rightSub : []})
      UIComboBox {
        id : connectionCombo
        objectName  : "connection"
        Layout.row : 0
        Layout.column : 0 
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "Connection"
        comboBox.model : ["Mask", "Tube"]
        onComboUpdate : {
          anesthesiaAction.props.connection = currentSelection
        }
      }
      UIComboBox {
        id : primaryGasCombo
        objectName  : "gas"
        Layout.row : 0
        Layout.column : 1
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "Primary Gas"
        comboBox.model : ["Nitrogen", "Air"]
        onComboUpdate : {
          anesthesiaAction.props.primaryGas = currentSelection
        }
      }
      UISpinBox {
        id : inletFlowSpin
        objectName : "inletFlow"
        Layout.row : 1
        Layout.column : 0
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "Inlet Flow (L/min)"
        spinBox.value : anesthesiaAction.props.inletFlow
        spinMax : 150
        spinStep : 5
        spinScale : 10 // Max of 15.0 with steps of 0.5
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          anesthesiaAction.props.inletFlow = value;
        }
      }
      UISpinBox {
        id : ieRatioSpin
        objectName : "ieRatio"
        Layout.row : 1
        Layout.column : 1
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillWidth : true
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "IE Ratio"
        spinBox.value : anesthesiaAction.props.ieRatio
        spinMax : 200
        spinStep : 5
        spinScale : 100 // Max of 2.00 with steps of 0.05
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          anesthesiaAction.props.ieRatio = value;
        }
      }
      UISpinBox {
        id : maxPressureSpin
        objectName : "maxPressure"
        Layout.row : 2
        Layout.column : 0
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "Max Pressure (cmH2O)"
        spinBox.value : anesthesiaAction.props.pMax
        spinMax : 200
        spinStep : 5
        spinScale : 10 // Max of 20 with steps of 0.5
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          anesthesiaAction.props.pMax = value;
        }
      }
      UISpinBox {
        id : peepSpin
        objectName : "peep"
        Layout.row : 2
        Layout.column : 1
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "PEEP (cmH2O)"
        spinBox.value : anesthesiaAction.props.peep
        spinMax : 50
        spinStep : 5
        spinScale : 10 // Max of 5.00 with steps of 0.5
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          anesthesiaAction.props.peep = value;
        }
      }
      UISpinBox {
        id : rrSpin
        objectName : "respirationRate"
        Layout.row : 3
        Layout.column : 0
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "Respiration Rate (1/min)"
        spinBox.value : anesthesiaAction.props.respirationRate
        spinMax : 200
        spinStep : 5
        spinScale : 10 // Max of 20 with steps of 0.5
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          anesthesiaAction.props.respirationRate = value;
        }
      }
      UISpinBox {
        id : reliefSpin
        objectName : "reliefPressure"
        Layout.row : 3
        Layout.column : 1
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "Relief Pressure (cmH2O)"
        spinBox.value : anesthesiaAction.props.reliefPressure
        spinMax : 150
        spinStep : 10
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          anesthesiaAction.props.reliefPressure = value;
        }
      }
      UISpinBox {
        id : o2FractionSpin
        objectName : "o2Fraction"
        Layout.row : 4
        Layout.column : 0
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "O2 Fraction"
        spinBox.value : anesthesiaAction.props.o2Frac
        spinMax : 100
        spinStep : 5
        spinScale : 100   //Max of 1.00 with steps of 0.05
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          anesthesiaAction.props.o2Frac = value;
        }
      }
      UIComboBox {
        id : o2SourceCombo
        objectName  : "gas"
        Layout.row : 4
        Layout.column : 1
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "O2 Source"
        comboBox.model : ["Wall", "Bottle One", "Bottle Two"]
        onComboUpdate : {
          anesthesiaAction.props.o2Source = currentSelection
          if (currentSelection === "Wall"){
            bottle1Spin.available = false;
            bottle1Spin.required = false;
            bottle2Spin.available = false;
            bottle2Spin.required = false;
          } else if (currentSelection === "Bottle One"){
            bottle1Spin.available = true;
            bottle1Spin.required = true;
            bottle2Spin.available = false;
            bottle2Spin.required = false;
          } else {
            bottle1Spin.available = false;
            bottle1Spin.required = false;
            bottle2Spin.available = true;
            bottle2Spin.required = true;
          }
        }
      }
      UISpinBox {
        id : bottle1Spin
        objectName : "bottle1"
        Layout.row : 5
        Layout.column : 0
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "O2 Bottle 1 (mL)"
        required : false
        available : false
        spinMax : 5000
        spinStep : 100
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          anesthesiaAction.props.bottle1 = value;
        }
      }
      UISpinBox {
        id : bottle2Spin
        objectName : "bottle2"
        Layout.row : 5
        Layout.column : 1
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "O2 Bottle 2 (mL)"
        required : false
        available : false
        spinMax : 5000
        spinStep : 100
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          anesthesiaAction.props.bottle2 = value;
        }
      }
      RowLayout {
        id : leftSub
        Layout.row : 6
        Layout.column : 0
        Layout.fillWidth : true
        Layout.columnSpan : 2
        Layout.preferredHeight : 60
        Layout.maximumWidth : parent.width
        property alias subEntry : leftSubEntry
        function isValid() { return subEntry.entry.validInput; }
        Label {
          id : leftSubLabel
          text : "Left Chamber Substance"
          verticalAlignment : Text.AlignVCenter
          Layout.alignment : Qt.AlignBottom
          leftPadding : 5
          font.pixelSize : 18
          padding : 0
        }
        Rectangle {
          color : "transparent"
          Layout.fillWidth : true
          Layout.maximumWidth : parent.width - leftSubLabel.width
          Layout.fillHeight : true
          UISubstanceEntry {
            id : leftSubEntry
            prefWidth : parent.width * 0.9
            prefHeight : parent.height * 0.9
            anchors.centerIn : parent
            type : "fraction"
            border.width : 0
            onInputAccepted : {
              props.leftSub = input
            }
            Component.onCompleted : {
              //Set up components for drop down
              let components = scenario.get_volatile_drugs()
              for (let i = 0; i < components.length; ++i){
                entry.componentListModel.append({"component" : components[i]})
              }
              //Update entry text (need to let it load first since entry is bound to item property of loader in UISubstanceEntry)
              entry.substanceInput.font.pointSize = 11
              entry.scalarInput.font.pointSize = 11
            }
          }
        }
      }
      RowLayout {
        id : rightSub
        Layout.row : 7
        Layout.column : 0
        Layout.columnSpan : 2
        Layout.fillWidth : true
        Layout.fillHeight : true
        Layout.preferredHeight : 60
        Layout.maximumWidth : parent.width
        property alias subEntry : rightSubEntry
        function isValid() { return subEntry.entry.validInput; }
        Label {
          id : rightSubLabel
          text : "Right Chamber Substance"
          leftPadding : 5
          font.pixelSize : 18
          verticalAlignment : Text.AlignVCenter
          Layout.alignment : Qt.AlignBottom
          padding : 0
        }
        Rectangle {
          color : "transparent"
          Layout.fillWidth : true
          Layout.maximumWidth : parent.width - rightSubLabel.width
          Layout.fillHeight : true
          UISubstanceEntry {
            id : rightSubEntry
            prefWidth : parent.width * 0.9
            prefHeight : parent.height * 0.9
            anchors.centerIn : parent
            type : "fraction"
            border.width : 0
            onInputAccepted : {
              props.rightSub = input
            }
            Component.onCompleted : {
              let components = scenario.get_volatile_drugs()
              for (let i = 0; i < components.length; ++i){
                entry.componentListModel.append({"component" : components[i]})
              }
              entry.substanceInput.font.pointSize = 11
              entry.scalarInput.font.pointSize = 11
            }
          }
        }
      }
      Connections {
        target : root
        onReset : {
          connectionCombo.resetCombo()
          primaryGasCombo.resetCombo()
          inletFlowSpin.resetSpin()
          ieRatioSpin.resetSpin()
          maxPressureSpin.resetSpin()
          peepSpin.resetSpin()
          rrSpin.resetSpin()
          reliefSpin.resetSpin()
          o2FractionSpin.resetSpin()
          o2SourceCombo.resetCombo()      
          bottle1Spin.resetSpin()
          bottle2Spin.resetSpin()
          routeRadio.resetRadio()
          doseText.resetText()
          concentrationText.resetText()
        }
      }
    }
  }
  Component {
    id : consumeMealComponent
    GridLayout {
      id : consumeMealAction
      rows : 4
      columns : 2
      columnSpacing : 10
      rowSpacing : 10
      property var props : ({fileName : '', mealName : '', carbohydrate : 0, fat : 0, protein : 0, calcium : 0, sodium : 0, water : 0})
      UIComboBox {
        id : fileCombo
        Layout.row : 0
        Layout.column : 0
        Layout.columnSpan : 2
        required : false
        objectName  : "nutritionFile"
        Layout.fillHeight : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.preferredWidth : parent.width
        Layout.preferredHeight : parent.height / parent.rows - 3 * parent.rowSpacing / parent.rows 
        label.text : "Load Nutrition from file (optional)"
        comboBox.model : scenario.get_nutrition()
        onComboUpdate : {
          let l_children = dialogItem.children      //content children of dialog are all the components we created
          let l_nutritionInfo = scenario.load_nutrition_for_meal(currentSelection)
          for (let child in l_children){
            //Only look for text fields (they have the data we need to overwrite).  Perform search by determing if child has textField prop
			      if (l_children[child].textField){
              let l_searchKey = l_children[child].textField.placeholderText.split(" ")[0]
              l_children[child].textField.text = l_nutritionInfo[l_searchKey]
              l_children[child].textFieldUpdate(l_nutritionInfo[l_searchKey])  //Force update to properties object to make sure we are tracking data
            }
          }
        }
      }
      UITextField {
        id : carbText
        objectName : "carbs"
        textField.placeholderText : "Carbohydrates (g)"
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.row : 1
        Layout.column : 0
        Layout.preferredWidth : parent.width / parent.columns - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / parent.rows - 3 * parent.rowSpacing / parent.rows 
        required : false
        onTextFieldUpdate : {
          consumeMealAction.props.carbohydrate = inputText
        }
      }
      UITextField {
        id : proteinText
        objectName : "protein"
        textField.placeholderText : "Protein (g)"
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.row : 1
        Layout.column : 1
        Layout.preferredWidth : parent.width / parent.columns - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / parent.rows - 3 * parent.rowSpacing / parent.rows 
        required : false
        onTextFieldUpdate : {
          consumeMealAction.props.protein = inputText
        }
      }
      UITextField {
        id : fatText
        objectName : "fat"
        textField.placeholderText : "Fat (g)"
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.row : 2
        Layout.column : 0
        Layout.preferredWidth : parent.width / parent.columns - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / parent.rows - 3 * parent.rowSpacing / parent.rows 
        required : false
        onTextFieldUpdate : {
          consumeMealAction.props.fat = inputText
        }
      }
      UITextField {
        id : waterText
        objectName : "water"
        textField.placeholderText : "Water (mL)"
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.row : 2
        Layout.column : 1
        Layout.preferredWidth : parent.width / parent.columns - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / parent.rows - 3 * parent.rowSpacing / parent.rows 
        required : false
        onTextFieldUpdate : {
          consumeMealAction.props.water = inputText
        }
      }
      UITextField {
        id : sodiumText
        objectName : "sodium"
        textField.placeholderText : "Sodium (mg)"
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.row : 3
        Layout.column : 0
        Layout.preferredWidth : parent.width / parent.columns - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / parent.rows - 3 * parent.rowSpacing / parent.rows 
        required : false
        onTextFieldUpdate : {
          consumeMealAction.props.sodium = inputText
        }
      }
      UITextField {
        id : calciumText
        objectName : "calcium"
        textField.placeholderText : "Calcium (mg)"
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.row : 3
        Layout.column : 1
        Layout.preferredWidth : parent.width / parent.columns - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / parent.rows - 3 * parent.rowSpacing / parent.rows 
        required : false
        onTextFieldUpdate : {
          consumeMealAction.props.calcium = inputText
        }
      }
      Connections {
        target : root
        onReset : {
          fileCombo.resetCombo()
          carbText.resetText()
          proteinText.resetText()
          fatText.resetText()
          waterText.resetText()
          sodiumText.resetText()
          calciumText.resetText()
        }
      }
    }
  }
  Component {
    id : cycleRunComponent
    ColumnLayout {
      id : cycleRunAction
      property bool cycling : true
      property string exType : cycling ? "Cycling" : "Running"
      property var props : ({exerciseType : cycleRunAction.exType, field_1 : 0, field_2 : 0, weightPack : 0})
      UISpinBox {
        id : field1Spin
        objectName : "field1"
        label.text : parent.cycling ? "Cadence (1/min)" : "Velocity (m/s)"
        Layout.preferredWidth : parent.width
        spinMax : parent.cycling ? 100 : 1200
        spinStep : parent.cycling ? 5 : 25
        spinScale : parent.cycling ? 1 : 100    //Spin box only accepts ints -- spin scale scales display and output value to doubles, so "Velocity" has max = 12.0 with steps 0.25
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          cycleRunAction.props.field_1 = value
        }
      }
      UISpinBox {
        id : field2Spin
        objectName : "field2"
        Layout.preferredWidth : parent.width
        label.text : parent.cycling ? "Power (W)" : "Incline (%)"
        spinMax : parent.cycling ? 300 : 1000
        spinStep : parent.cycling ? 10 : 25
        spinScale : parent.cycling ? 1 : 10 //Spin box only accepts ints -- spin scale scales display and output value to doubles, so "Incline" has max = 100 with steps 2.5
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          if (parent.cycling){
            cycleRunAction.props.field_2 = value;
          } else {
            cycleRunAction.props.field_2 = value / 100.0;
          }
        }
      }
      UISpinBox {
        id : weightSpin
        objectName : "weight"
        label.text : "Weight Pack (kg)"
        Layout.preferredWidth : parent.width
        required : false
        spinMax : 500
        spinStep : 25
        spinScale : 10        //Go up to 50.0 in increments of 2.5
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          cycleRunAction.props.weightPack = value
        }
      }
      Connections {
        target : root
        onReset : {
          field1Spin.resetSpin()
          field2Spin.resetSpin()
          weightSpin.resetSpin()
        }
      }
    }
  }
  Component {
    id : drugBolusComponent
    GridLayout {
      id : drugBolusAction
      rows : 2
      columns : 2
      columnSpacing : 25
      rowSpacing : 10
      property var props : ({adminRoute : '', substance : '', dose: 0, concentration : 0})
      UIComboBox {
        id : drugCombo
        Layout.row : 0
        Layout.column : 0
        objectName  : "substance"
        Layout.fillHeight : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.preferredWidth : parent.width / 2 - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / 2 - parent.rowSpacing / 2 
        label.text : "Drug"
        comboBox.model : scenario.get_drugs()
        onComboUpdate : {
          drugBolusAction.props.substance = currentSelection
        }
      }
      UIRadioButton{
        id : routeRadio
        Layout.row : 0
        Layout.column : 1
        Layout.preferredWidth : parent.width / 2 - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / 2 - parent.rowSpacing / 2 
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        spacing : 50
        objectName  : "route"
        label.text : "Route"
        buttonModel : ['Intraarterial', 'Intramuscular', 'Intravenous']
        onRadioGroupUpdate : {
          switch (value){
            case 0 :
              drugBolusAction.props.adminRoute = "Bolus-Intraarterial"
              break;
            case 1 :
              drugBolusAction.props.adminRoute = "Bolus-Intramuscular"
              break;
            case 2 :
              drugBolusAction.props.adminRoute = "Bolus-Intravenous"
              break;
          }
        }
      }
      UITextField {
        id : doseText
        objectName : "dose"
        textField.placeholderText : "Dose (mL)"
        Layout.row : 1
        Layout.column : 0
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.preferredWidth : parent.width / 2 - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / 2 - parent.rowSpacing / 2 
        onTextFieldUpdate : {
          drugBolusAction.props.dose = inputText
        }
      }
      UITextField {
        id : concentrationText
        objectName : "concentration"
        textField.placeholderText : "Concentration (ug/mL)"
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.row : 1
        Layout.column : 1
        Layout.preferredWidth : parent.width / 2 - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / 2 - parent.rowSpacing / 2 
        onTextFieldUpdate : {
          drugBolusAction.props.concentration = inputText
        }
      }
      Connections {
        target : root
        onReset : {
          drugCombo.resetCombo()
          routeRadio.resetRadio()
          doseText.resetText()
          concentrationText.resetText()
        }
      }
    }
  }
  Component {
    id : drugInfusionComponent
    GridLayout {
      id : drugInfusionAction
      rows : 2
      columns : 2
      columnSpacing : 25
      rowSpacing : 10
      property var props : ({adminRoute : 'Infusion-Intravenous', substance : '', rate: 0, concentration : 0})
      UIComboBox {
        id : drugCombo
        Layout.row : 0
        Layout.column : 0
        objectName  : "substance"
        Layout.fillHeight : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.preferredWidth : parent.width / 2 - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / 2 - parent.rowSpacing / 2 
        label.text : "Drug"
        comboBox.model : scenario.get_drugs()
        onComboUpdate : {
          drugInfusionAction.props.substance = currentSelection
        }
      }
      Rectangle {
        id : filler
        Layout.row : 0
        Layout.column : 1
        Layout.preferredWidth : parent.width / 2 - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / 2 - parent.rowSpacing / 2 
        color : "transparent"
      }
      UITextField {
        id : concentrationText
        objectName : "concentration"
        textField.placeholderText : "Concentration (ug/mL)"
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.row : 1
        Layout.column : 0
        Layout.preferredWidth : parent.width / 2 - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / 2 - parent.rowSpacing / 2 
        onTextFieldUpdate : {
          drugInfusionAction.props.concentration = inputText
        }
      }
      UITextField {
        id : rateText
        objectName : "rate"
        textField.placeholderText : "Rate (mL/min)"
        Layout.row : 1
        Layout.column : 1
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.preferredWidth : parent.width / 2 - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / 2 - parent.rowSpacing / 2 
        onTextFieldUpdate : {
          drugInfusionAction.props.rate = inputText
        }
      }   
      Connections {
        target : root
        onReset : {
          drugCombo.resetCombo()
          rateText.resetText()
          concentrationText.resetText()
        }
      }
    }
  }
  Component {
    id : drugOralComponent
    GridLayout {
      id : drugOralAction
      rows : 2
      columns : 2
      columnSpacing : 25
      rowSpacing : 10
      property var props : ({adminRoute : '', substance : '', dose: 0})
      UIComboBox {
        id : drugCombo
        Layout.row : 0
        Layout.column : 0
        objectName  : "substance"
        Layout.fillHeight : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.preferredWidth : parent.width / 2 - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / 2 - parent.rowSpacing / 2 
        label.text : "Drug"
        comboBox.model : scenario.get_drugs()
        onComboUpdate : {
          drugOralAction.props.substance = currentSelection
        }
      }
      UIRadioButton{
        id : routeRadio
        Layout.row : 0
        Layout.column : 1
        Layout.preferredWidth : parent.width / 2 - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / 2 - parent.rowSpacing / 2 
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        spacing : 50
        objectName  : "route"
        label.text : "Route"
        buttonModel : ['Gastrointestinal', 'Transmucosal']
        onRadioGroupUpdate : {
          if (value == 0){
            drugOralAction.props.adminRoute = "Gastrointestinal";
          } else {
            drugOralAction.props.adminRoute = "Transmucosal";
          }
        }
      }
      UITextField {
        id : doseText
        objectName : "dose"
        textField.placeholderText : "Dose (mg)"
        Layout.row : 1
        Layout.column : 0
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.preferredWidth : parent.width / 2 - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / 2 - parent.rowSpacing / 2 
        onTextFieldUpdate : {
          drugOralAction.props.dose = inputText
        }
      }
      Rectangle {
        id : filler
        Layout.row : 1
        Layout.column : 1
        Layout.preferredWidth : parent.width / 2 - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / 2 - parent.rowSpacing / 2 
        color : "transparent"
      }
      Connections {
        target : root
        onReset : {
          drugCombo.resetCombo()
          routeRadio.resetRadio()
          doseText.resetText()
        }
      }
    }
  }
  
  Component {
    id : environmentComponent
    GridLayout {
      id : environmentAction
      rows : 8
      columns : 2
      columnSpacing : 20
      rowSpacing : 5
      property var props : ({surroundingType : '', airDensity : 0, airVelocity : 0, ambientTemp : 0, atmPressure : 100000, cloResist : 0, emissivity : 0, meanRadiantTemp : 0, relativeHumidity : 0, respirationAmbientTemperature : 0})
      UIComboBox {
        id : surroundingTypeCombo
        objectName  : "surroundingType"
        Layout.row : 0
        Layout.column : 0 
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "Surrounding Type"
        comboBox.model : ["Air", "Water"]
        onComboUpdate : {
          environmentAction.props.surroundingType = currentSelection
        }
      }
      UISpinBox {
        id : airDensitySpin
        objectName : "airDensity"
        Layout.row : 1
        Layout.column : 0
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "Air Density (kg/m3)"
		required : false
        spinBox.value : environmentAction.props.airDensity
        spinMax : 30
        spinStep : 1
        spinScale : 10 // Max of 3.0 with steps of 0.1
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          environmentAction.props.airDensity = value;
        }
      }
      UISpinBox {
        id : airVelocitySpin
        objectName : "airVelocity"
        Layout.row : 1
        Layout.column : 1
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillWidth : true
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "Air Velocity (m/s)"
		required : false
        spinBox.value : environmentAction.props.airVelocity
        spinMax : 600
        spinStep : 10
        spinScale : 10 // Max of 60.00 with steps of 1
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          environmentAction.props.airVelocity = value;
        }
      }
      UISpinBox {
        id : ambientTempSpin
        objectName : "ambientTemp"
        Layout.row : 2
        Layout.column : 0
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "Ambient Temp. (C)"
		required : false
        spinBox.value : environmentAction.props.ambientTemp
        spinMax : 450
        spinStep : 5
        spinScale : 10 // Max of 45 with steps of 0.5
		spinBox.from : -150 // Min of -15
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          environmentAction.props.ambientTemp = value;
        }
      }
      UISpinBox {
        id : atmPressureSpin
        objectName : "atmPressure"
        Layout.row : 2
        Layout.column : 1
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "Atm. Pressure (Pa)"
		required : false
        spinBox.value : environmentAction.props.atmPressure
        spinMax : 150000
        spinStep : 10000
        spinScale : 1 // Max of 100k with steps of 10k
		spinBox.from : 10000 // Min of 10k
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          environmentAction.props.atmPressure = value;
        }
      }
      UISpinBox {
        id : cloResistSpin
        objectName : "cloResist"
        Layout.row : 3
        Layout.column : 0
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "Clothing Resistance (clo)"
		required : false
        spinBox.value : environmentAction.props.cloResist
        spinMax : 200
        spinStep : 5
        spinScale : 100 // Max of 2 with steps of 0.05
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          environmentAction.props.cloResist = value;
        }
      }
      UISpinBox {
        id : emissivitySpin
        objectName : "emissivity"
        Layout.row : 3
        Layout.column : 1
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "Emissivity"
		required : false
        spinBox.value : environmentAction.props.emissivity
        spinMax : 100
        spinStep : 5
		spinScale : 100 // Max of 1 with steps of 0.05
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          environmentAction.props.emissivity = value;
        }
      }
      UISpinBox {
        id : meanRadiantTempSpin
        objectName : "meanRadiantTemp"
        Layout.row : 4
        Layout.column : 0
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "Mean Radiant Temp. (C)"
		required : false
        spinBox.value : environmentAction.props.meanRadiantTemp
        spinMax : 450
        spinStep : 5
        spinScale : 10 // Max of 45 with steps of 0.5
		spinBox.from : -150 // Min of -15
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          environmentAction.props.meanRadiantTemp = value;
        }
      }
	  UISpinBox {
        id : relativeHumiditySpin
        objectName : "relativeHumidity"
        Layout.row : 4
        Layout.column : 1
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width / 2 - 20
        label.text : "Relative Humidity"
		required : false
        spinBox.value : environmentAction.props.relativeHumidity
        spinMax : 100
        spinStep : 5
        spinScale : 100   //Max of 1.00 with steps of 0.05
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          environmentAction.props.relativeHumidity = value;
        }
      }
      UISpinBox {
        id : respirationAmbientTemperatureSpin
        objectName : "respirationAmbientTemperature"
        Layout.row : 5
        Layout.column : 0
		Layout.columnSpan : 2
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.maximumWidth : parent.width - 20
        label.text : "Respiration Ambient Temp. (C)"
		required : false
        spinBox.value : environmentAction.props.respirationAmbientTemperature
        spinMax : 450
        spinStep : 5
        spinScale : 10 // Max of 45 with steps of 0.5
		spinBox.from : -150 // Min of -15
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          environmentAction.props.respirationAmbientTemperature = value;
        }
      }
      
      Connections {
        target : root
        onReset : {
          surroundingTypeCombo.resetCombo()
          airDensitySpin.resetSpin()
          airVelocitySpin.resetSpin()
          ambientTempSpin.resetSpin()
          atmPressureSpin.resetSpin()
          cloResistSpin.resetSpin()
          emissivitySpin.resetSpin()
          meanRadiantTempSpin.resetSpin()
          relativeHumiditySpin.resetSpin()
          respirationAmbientTemperatureSpin.resetSpin()
        }
      }
    }
  }
  
  Component {
    id : fluidInfusionComponent
    GridLayout {
      id : fluidInfusionAction
      rows : 2
      columns : 2
      columnSpacing : 25
      rowSpacing : 10
      property bool transfusion : false
      property var props : ({compound : '', bagVolume : 0, concentration : 0})
      UIComboBox {
        id : sourceCombo
        Layout.row : 0
        Layout.column : 0
        Layout.columnSpan : 2
        objectName  : "source"
        Layout.fillHeight : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillWidth : false
        Layout.preferredWidth : parent.width * 0.75
        Layout.preferredHeight : parent.height / 2 - parent.rowSpacing / 2
        elementRatio : 0.3
        label.text : parent.transfusion ? "Blood Type" : "Compound"
        comboBox.model : parent.transfusion ? scenario.get_transfusion_products() : scenario.get_compounds()
        onComboUpdate : {
          fluidInfusionAction.props.compound = currentSelection
        }
      }
      UITextField {
        id : volumeText
        objectName : "volume"
        textField.placeholderText : "Bag Volume (mL)"
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.row : 1
        Layout.column : 0
        Layout.preferredWidth : parent.width / 2 - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / 2 - parent.rowSpacing / 2 
        onTextFieldUpdate : {
          fluidInfusionAction.props.bagVolume = inputText
        }
      }
      UITextField {
        id : rateText
        objectName : "rate"
        textField.placeholderText : "Rate (mL/min)"
        Layout.row : 1
        Layout.column : 1
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.preferredWidth : parent.width / 2 - parent.columnSpacing / 2
        Layout.preferredHeight : parent.height / 2 - parent.rowSpacing / 2 
        onTextFieldUpdate : {
          fluidInfusionAction.props.rate = inputText
        }
      }   
      Connections {
        target : root
        onReset : {
          sourceCombo.resetCombo()
          volumeText.resetText()
          rateText.resetText()
        }
      }
    }
  }
  Component {
    id : genericExerciseComponent
    GridLayout {
      id : genericExerciseAction
      rows : 2
      columns : 2
      property var props : ({exerciseType : "Generic", field_1 : 0.0, field_2 : 0.0, weightPack : 0.0})
      UIRadioButton{
        id : typeRadio
        Layout.row : 0
        Layout.column : 0
        Layout.rowSpan : 2
        Layout.preferredWidth : 2 * parent.width / 5 - parent.columnSpacing / 2
        Layout.alignment : Qt.AlignHCenter
        objectName  : "type"
        label.text : "Input Type"
        buttonModel : ['Intensity', 'Work']
        onRadioGroupUpdate : {
          if (value == 0){
            //Intensity-based
            intensitySpin.available = true;
            intensitySpin.required = true;
            workSpin.available = false;
            workSpin.required = false;
            workSpin.resetSpin();   //Set work to 0 if intensity based    
          } else {
            //Work-based
            intensitySpin.available = false;
            intensitySpin.required = false;
            intensitySpin.resetSpin();  //Set intensity to 0 if work-based
            workSpin.available = true;
            workSpin.required = true;
          }
        }
      }
      UISpinBox {
        id : intensitySpin
        objectName : "intensity"
        label.text : "Intensity"
        available : false
        required : true    //Set work/intensity to required initially so that you can't proceed without choosing one.  Type button will decide which one is actually required
        Layout.preferredWidth : 3 * parent.width / 5 - parent.columnSpacing / 2
        Layout.row : 0
        Layout.column : 1
        spinMax : 100
        spinStep : 5
        spinScale : 100
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          genericExerciseAction.props.field_1 = value
        }
      }
      UISpinBox {
        id : workSpin
        objectName : "work"
        label.text : "Work (W)"
        available : false
        required : true     //Set work/intensity to required initially so that you can't proceed without choosing one.  Type button will decide which one is actually required
        Layout.preferredWidth : 3 * parent.width / 5 - parent.columnSpacing / 2
        Layout.row : 1
        Layout.column : 1
        spinMax : 1600
        spinStep : 50
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          genericExerciseAction.props.field_2 = value
        }
      }
      Connections {
        target : root
        onReset : {
          typeRadio.resetRadio();
          intensitySpin.resetSpin();
          intensitySpin.available = false;
          intensitySpin.required = true;
          workSpin.resetSpin();
          workSpin.available = false;
          workSpin.required = true;
        }
      }
    }
  }
  Component {
    id : hemorrhageComponent
    ColumnLayout {
      id : hemorrhageAction
      width : root.width
      property var props : ({location : '', rate: 0})
      UISpinBox {
        id : hemorrhageSpin
        objectName : "bleedingRate"
        label.text : "Bleeding Rate (mL/min)"
        Layout.preferredWidth : parent.width
        spinMax : 1000
        spinStep : 10
        onSpinUpdate : {
          hemorrhageAction.props.rate = value
        }
      }
      UIComboBox {
        id : hemorrhageCombo
        objectName  : "location"
        label.text : "Location"
        comboBox.model : ['Aorta', 'Left Arm', 'Left Leg', 'Right Arm', 'Right Leg']
        onComboUpdate : {
          hemorrhageAction.props.location = currentSelection
        }
      }
      Connections {
        target : root
        onReset : {
          hemorrhageSpin.resetSpin()
          hemorrhageCombo.resetCombo()
        }
      }
    }
  }
  Component {
    id : infectionComponent
    ColumnLayout {
      id : infectionAction
      property var props : ({location : '', severity : 0, mic : 0})
      UISpinBox {
        id : severitySpin
        objectName : "severity"
        label.text : "Severity"
        Layout.preferredWidth : parent.width
        spinMax : 3
        spinStep : 1
        displayEnum : ['','Mild','Moderate','Severe']
        spinBox.editable : false
        spinBox.valueFromText : function (text) { return valueFromEnum(text) }
        spinBox.textFromValue : function (value) { return valueToEnum(spinBox.value) }
        onSpinUpdate : {
          infectionAction.props.severity = value
        }
      }
      UISpinBox {
        id : micSpin
        objectName : "mic"
        label.text : "MIC (mg/L)"
        Layout.preferredWidth : parent.width
        spinMax : 500
        spinStep : 10
        onSpinUpdate : {
          infectionAction.props.mic = value
        }
      }
      UIComboBox {
        id : infectionCombo
        objectName  : "location"
        label.text : "Location"
        comboBox.model : ['Gut', 'Left Arm', 'Left Leg', 'Right Arm', 'Right Leg', 'Skin']
        onComboUpdate : {
          infectionAction.props.location = currentSelection
        }
      }
      Connections {
        target : root
        onReset : {
          severitySpin.resetSpin()
          micSpin.resetSpin()
          infectionCombo.resetCombo()
        }
      }
    }
  }
  Component {
    id : needleComponent
    ColumnLayout {
      id : needleAction
      width : parent.width
      property var props : ({side : 0})
      UIRadioButton{
        id : sideRadio
        Layout.fillWidth : true
        Layout.preferredWidth : parent.width
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        spacing : 50
        objectName  : "side"
        label.text : "Side"
        buttonModel : ['Left', 'Right']
        onRadioGroupUpdate : {
          needleAction.props.side = value
        }
      }
      Connections {
        target : root
        onReset : {
          needleRadio.resetRadio();
        }
      }
    }
  }
  Component {
    id : painComponent
    ColumnLayout {
      id : painAction
      property var props : ({location : '', painScore: 0})
      UISpinBox {
        id : painSpin
        objectName : "painScore"
        label.text : "Visual Analog Score"
        Layout.preferredWidth : parent.width
        spinMax : 10
        spinStep : 1
        onSpinUpdate : {
          painAction.props.painScore = value
        }
      }
      UIComboBox {
        id : painCombo
        objectName  : "location"
        label.text : "Location"
        comboBox.model : ['Abdomen', 'Chest','Head', 'Left Arm','Left Leg','Right Arm','Right Leg']
        onComboUpdate : {
          painAction.props.location = currentSelection
        }
      }
      Connections {
        target : root
        onReset : {
          painSpin.resetSpin()
          painCombo.resetCombo()
        }
      }
    }
  }
  Component {
    id : pneumothoraxComponent
    GridLayout {
      id : pneumothoraxAction
      rows : 2
      columns : 2
      property var props : ({severity: 0, type : 0, side : 0})
      UIRadioButton{
        id : typeRadio
        Layout.topMargin : 10
        Layout.row : 0
        Layout.column : 0
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        spacing : 50
        objectName  : "type"
        label.text : "Type"
        buttonModel : ['Open', 'Closed']
        onRadioGroupUpdate : {
          pneumothoraxAction.props.type = value
        }
      }
      UIRadioButton{
        id : sideRadio
        Layout.topMargin : 10
        Layout.row : 0
        Layout.column : 1
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        spacing : 50
        objectName  : "side"
        label.text : "Side"
        buttonModel : ['Left', 'Right']
        onRadioGroupUpdate : {
          pneumothoraxAction.props.side = value
        }
      }
      UISpinBox {
        id : severitySpin
        objectName : "severity"
        label.text : "Severity"
        Layout.preferredWidth : parent.width
        label.horizontalAlignment : Text.AlignHCenter
        Layout.row : 1
        Layout.column : 0
        Layout.columnSpan : 2
        spinMax : 100
        spinStep : 5
        spinScale : 100
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          pneumothoraxAction.props.severity = value
        }
      }
      Connections {
        target : root
        onReset : {
          typeRadio.resetRadio();
          sideRadio.resetRadio();
          severitySpin.resetSpin();
        }
      }
    }
  }
  Component {
    id : singleRangeComponent
    ColumnLayout {
      id : singleRangeAction
      property var props : ({spinnerValue : 0})
      property string labelText : "Severity"
      UISpinBox {
        id : severitySpin
        objectName : "severity"
        label.text : parent.labelText
        Layout.preferredWidth : parent.width
        spinMax : 100
        spinStep : 5
        spinScale : 100
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          singleRangeAction.props.spinnerValue = value
        }
      }
      Connections {
        target : root
        onReset : {
          severitySpin.resetSpin()
        }
      }
    }
  }
  Component {
    id : strengthComponent
    ColumnLayout {
      id : strengthAction
      property bool cycling : true
      property var props : ({exerciseType : "Strength", field_1 : 0, field_2 : 0, weightPack : 0})     //Note that weight does not edit "field_1" prop -- set so that all exercise actions can use same function
      UISpinBox {
        id : weightSpin
        objectName : "weight"
        label.text : "Weight (kg)"
        Layout.preferredWidth : parent.width
        spinMax : 2000
        spinStep : 50
        spinScale : 10    //Go up to 200 kg in increments of 5
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          strengthAction.props.field_1 = value
        }
      }
      UISpinBox {
        id : repsSpin
        objectName : "reps"
        Layout.preferredWidth : parent.width
        label.text : "Repetitions"
        spinMax : 100
        spinStep : 1
        onSpinUpdate : {
          strengthAction.props.field_2 = value;
        }
      }
      Connections {
        target : root
        onReset : {
          repsSpin.resetSpin()
          weightSpin.resetSpin()
        }
      }
    }
  }
  Component {
    id : tourniquetComponent
    ColumnLayout {
      id : tourniquetAction
      property var props : ({location : '', level : 0})
      UIComboBox {
        id : tourniquetCombo
        objectName  : "location"
        label.text : "Location"
        comboBox.model : ['Left Arm', 'Left Leg', 'Right Arm', 'Right Leg']
        onComboUpdate : {
          tourniquetAction.props.location = currentSelection
        }
      }
      UIRadioButton {
        id : tourniquetRadio
        objectName : "level"
        label.text : "Application Level"
        Layout.fillWidth : true
        Layout.alignment : Qt.AlignHCenter
        spacing : 150
        buttonModel : ['Applied', 'Misapplied']
        onRadioGroupUpdate : {
          tourniquetAction.props.level = value
        }
      }
      Connections {
        target : root
        onReset : {
          tourniquetCombo.resetCombo()
          tournqiuetRadio.resetRadio()
        }
      }
    }
  }
  Component {
    id : tbiComponent
    RowLayout {
      id : tbiAction
      property var props : ({severity: 0, type : 0})
      UIRadioButton{
        id : typeRadio
        Layout.row : 0
        Layout.column : 0
        Layout.preferredWidth : parent.width / 2 - spacing
        Layout.alignment : Qt.AlignHCenter
        objectName  : "type"
        label.text : "Type"
        buttonModel : ['Diffuse', 'Left Focal', 'Right Focal']
        onRadioGroupUpdate : {
          tbiAction.props.type = value
        }
      }
      UISpinBox {
        id : severitySpin
        objectName : "severity"
        label.text : "Severity"
        Layout.preferredWidth : parent.width / 2 - spacing
        label.horizontalAlignment : Text.AlignHCenter
        Layout.row : 1
        Layout.column : 0
        Layout.columnSpan : 2
        spinMax : 100
        spinStep : 5
        spinScale : 100
        spinBox.valueFromText : function(text, locale) { return valueFromDecimal(text, locale) }
        spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value) }
        onSpinUpdate : {
          tbiAction.props.severity = value
        }
      }
      Connections {
        target : root
        onReset : {
          typeRadio.resetRadio();
          severitySpin.resetSpin();
        }
      }
    }
  }
}


/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
