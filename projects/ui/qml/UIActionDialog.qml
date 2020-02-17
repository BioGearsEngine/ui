import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.folderlistmodel 2.12

UIActionDialogForm {
  id: root

  signal applyProps(var props)

  onApplied : {
    if (validProps()) {
      generateDescription();
      root.applyProps(actionProps);
      close();
    } else {
      console.log('Invalid configuration : Check that all values are defined and non-zero')
    }
  }

  onRejected : {
    close();
  }

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
  }

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
      spin.label.text = label
      if (Object.keys(customArgs).length > 0){
        parseCustomArgs(customArgs, spin)
      }
      if (spin.displayEnum.length > 0){
        spin.spinBox.increase()   //This is terribly hacky, but spin box will not update display text to reflect use of enum unless the value changes.  So increase here, then decrease to force box to refresh text
        spin.spinBox.valueFromText = function (text) { return spin.valueFromEnum(spin.spinBox.text) }
        spin.spinBox.textFromValue = function (value) { return spin.valueToEnum(spin.spinBox.value) }
        spin.spinBox.textFromValue(0)
        spin.spinBox.decrease()
      }
      if (spin.unitScale) {
        spin.spinBox.valueFromText = function(text) { return spin.valueFromDecimal(spin.spinBox.text) }
        spin.spinBox.textFromValue = function(text) { return spin.valueToDecimal(spin.spinBox.value) }
      }
      spin.spinUpdate.connect(function(value) {root.updateProperty(value, linkedProp)})
      root.onReset.connect(spin.resetSpinBox)
	  }
  }

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
      field.placeholderText = label
      if (Object.keys(customArgs).length > 0){
        parseCustomArgs(customArgs, field)
      }
    }
  }




  function initializeProperties(newProps){
    actionProps = newProps
    root.title = actionProps.name + " Editor"
  }

  function getProperties(){
    for (let prop in actionProps){
      console.log(prop, actionProps[prop])
    }
  }

  function updateProperty(value, prop) {
    actionProps[prop] = value
  }

  function generateDescription(){
    let description = actionProps.name + ": "
    let numChildren = root.contentItem.children.length
    for (let child = 0; child < numChildren; ++child){
      description += root.contentItem.children[child].getDescription()
      if (child != numChildren-1){
        description += "; "
      }
    }
    console.log(description)
    Object.assign(actionProps, {description: description})
  }

  function parseCustomArgs(customArgs, item){
    for (let key in customArgs){
      if (item.hasOwnProperty(key)){
        console.log(key, customArgs[key])
        item[key] = customArgs[key]
      }
    }
  }

  function validProps(){
    for (let key in actionProps){
      if (key=='name' || key == 'description'){
        continue;
      } else {
        let prop = actionProps[key]
        if (prop === 0 || prop ===''){
          return false;
        }
      }
    }
    return true
  }
   
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
