import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.folderlistmodel 2.12

UIActionDialogForm {
  id: root
  
  //-------Signals and Handlers--------------
   
  // Emit properties when they have been set 
  signal applyProps(var props)

  // Handle Apply button clicked
  onApplied : {
    if (validProps()) {
      generateDescription();
      root.applyProps(actionProps);
      close();
    } else {
      console.log(errorString)
    }
  }
  
  // Handle Cancel button clicked
  onRejected : {
    close();
  }
  Component.onDestruction : {
    console.log("Destroying action dialog");
  }

  //----------------------Functions-----------------------

  //-----------------------------------------
  // Adds a combo box to the dialog window
  // Args : label = string to be displayed describing property
  //        linkedProp = dialog property to link combo box to
  //        modelData = ListModel or FolderListModel data to populate combo box
  //        customArgs = Additional properties to customize combo box (See UIComboBoxForm)
  function addComboBox(label, linkedProp, modelData, customArgs){
    var comboComponent = Qt.createComponent("UIComboBox.qml");
    if ( comboComponent.status != Component.Ready){
      if (comboComponent.status == Component.Error){
	      console.log("Error : " + comboComponent.errorString() );
	      return;
      }
      console.log("Error : UIcomboBox component not ready");
    } else {
      var combo = comboComponent.createObject(root.contentItem);
      combo.objectName = label
      combo.label.text = label
      combo.comboBox.textRole = modelData.role
      switch (modelData.type) {
        case 'ListModel' :
          let listModel = Qt.createQmlObject("import QtQuick.Controls 2.12; import QtQuick 2.12; ListModel {}", combo.comboBox, 'ListModelErrorString')
          for (let i = 0; i < modelData.elements.length; ++i){
            let element = { [modelData.role] : modelData.elements[i] }
            listModel.append(element)
          }
          combo.comboBox.model = listModel
        break;
        case 'FolderModel' :
          let folderModel = Qt.createQmlObject("import Qt.labs.folderlistmodel 2.12; FolderListModel {}", combo.comboBox, 'FolderModelErrorString')
          folderModel.nameFilters = ['*.xml']
          folderModel.folder = modelData.elements
          folderModel.showDirs = false
          combo.comboBox.model = folderModel
        break;
        default :
          console.log('Bad model definition')
      }
      combo.comboBox.currentIndex = -1 //By trial and error found that this must be added after model
      if (Object.keys(customArgs).length > 0){
        parseCustomArgs(customArgs, combo)
      }
      combo.comboUpdate.connect(function(value) { root.updateProperty(value, linkedProp) } )
      root.onReset.connect(combo.resetCombo)
    }
    return combo
  }

  //-----------------------------------------
  // Adds a spin box to the dialog window
  // Args : label = string to be displayed describing property
  //        linkedProp = dialog property to link spin box to  
  //        customArgs = Additional properties to customize spin box (See UISpinBoxForm)
  function addSpinBox(label, linkedProp, customArgs){
    var spinComponent = Qt.createComponent("UISpinBox.qml");
	  if ( spinComponent.status != Component.Ready){
		  if (spinComponent.status == Component.Error){
			  console.log("Error : " + spinComponent.errorString() );
			  return;
		  }
	    console.log("Error : UIspinBox component not ready");
	  } else {
		  var spin = spinComponent.createObject(root.contentItem);
      spin.objectName = label
      spin.label.text = label
      if (Object.keys(customArgs).length > 0){
        parseCustomArgs(customArgs, spin)
      }
      if (spin.displayEnum.length > 0 && spin.unitScale){
        console.log("Cannot set spin box to display enum and display scaled values simultaneously")
        return;
      }
      if (spin.displayEnum.length > 0){
        spin.spinBox.increase()   //This is terribly hacky, but spin box will not update display text to reflect use of enum unless the value changes.  So increase here, then decrease to force box to refresh text
        spin.spinBox.valueFromText = function (text) { return spin.valueFromEnum(spin.spinBox.text) }
        spin.spinBox.textFromValue = function (value) { return spin.valueToEnum(spin.spinBox.value) }
        spin.spinBox.textFromValue(0)
        spin.spinBox.decrease()
      }
      if (spin.spinBox != 1) {
        spin.spinBox.valueFromText = function(text) { return spin.valueFromDecimal(spin.spinBox.text) }
        spin.spinBox.textFromValue = function(text) { return spin.valueToDecimal(spin.spinBox.value) }
      }
      spin.spinUpdate.connect(function(value) {root.updateProperty(value, linkedProp)})
      root.onReset.connect(spin.resetSpinBox)
      return spin
	  }
  }

  //-----------------------------------------
  // Adds a text field to the dialog window
  // Args : label = string to be displayed as place holder text
  //        linkedProp = dialog property to link field input to  
  //        customArgs = Additional properties to customize field (See UITextForm)
  function addTextField(label, linkedProp, customArgs){
    var fieldComponent = Qt.createComponent("UITextField.qml");
	  if ( fieldComponent.status != Component.Ready){
		  if (fieldComponent.status == Component.Error){
			  console.log("Error : " + fieldComponent.errorString() );
			  return;
		  }
	    console.log("Error : UIfieldBox component not ready");
	  } else {
		  var field = fieldComponent.createObject(root.contentItem);
      field.objectName = label
      field.textField.placeholderText = label
      if (Object.keys(customArgs).length > 0){
        parseCustomArgs(customArgs, field)
      }
      field.textField.focus = true
      field.textFieldUpdate.connect(function (value) { root.updateProperty(value, linkedProp)})
      root.onReset.connect(field.resetTextField)
      return field
    }
  }

  //-----------------------------------------
  // Adds a group of radio buttons to the dialog window
  // Args : label = string to be displayed as place holder text
  //        linkedProp = dialog property to link field input to 
  //        buttonEnum = array of names for buttons that should be grouped
  //        customArgs = Additional properties to customize field (See UITextForm)
  function addRadioButton(label, linkedProp, buttonEnum, customArgs){
    var radioComponent = Qt.createComponent("UIRadioButton.qml");
	  if ( radioComponent.status != Component.Ready){
		  if (radioComponent.status == Component.Error){
			  console.log("Error : " + radioComponent.errorString() );
			  return;
		  }
	    console.log("Error : UIRadioButton component not ready");
	  } else {
		  var radio = radioComponent.createObject(root.contentItem);
      radio.label.text = label
      radio.buttonModel = buttonEnum
      if (Object.keys(customArgs).length > 0){
        parseCustomArgs(customArgs, radio)
      }
      radio.radioGroupUpdate.connect(function (value) { root.updateProperty(value, linkedProp) } )
      root.onReset.connect(radio.resetRadioGroup)
      return radio
    }
  }

  //-----------------------------------------
  // Populate the ActionDialog actionProps object
  // Must be called on Dialog before adding components (these are the properties that components will link to)
  // Args : newProps = JS object holding property key : value pairs
  function initializeProperties(newProps){
    actionProps = newProps
    root.title = actionProps.name + " Editor"
  }

  //-----------------------------------------
  // Writes out properties of dialog for debugging purposes
  function getProperties(){
    for (let prop in actionProps){
      console.log(prop, actionProps[prop])
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
  // Assembles a string describing the action and the input provided by user
  // Displayed next to action switch
  function generateDescription(){
    let description = actionProps.name + ": <br>    "
    let numChildren = root.contentItem.children.length
    for (let child = 0; child < numChildren; ++child){
      if (root.contentItem.children[child].getDescription){   //Check if child has getDescription defined
        description += root.contentItem.children[child].getDescription()      //Execute getDescription
        if (child != numChildren-1){
          description += "<br>    "
        }
      }
    }
    Object.assign(actionProps, {description: description})
  }

  //-----------------------------------------
  // Sets custom arguments on dialog component
  // args : customArgs = JS object holding properties callable from component function
  //        item = the component to which custom args are assigned
  function parseCustomArgs(customArgs, item){
    for (let key in customArgs){
      if (item.hasOwnProperty(key)){
        item[key] = customArgs[key]
      }
    }
  }

  //-----------------------------------------
  // Loops over all components added to dialog contentItem and calls their respective isValid methods
  // Returns false if any property has not been assigned a valid value
  function validProps(){
    let valid = true
    errorString = "" //Reset error string
    for (let child in root.contentItem.children){
      if (root.contentItem.children[child].isValid){    //Check if child item has isValid function defined
        if (!root.contentItem.children[child].isValid()){ //Execute isValid function
          valid = false
          errorString += root.contentItem.children[child].objectName + " is invalid\n";
        }
      }
    }
    return valid
  }
   
}


/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
