import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.folderlistmodel 2.12

UIActionDialogForm {
  id: root

  signal applyProps(var props)

  onApplied : {
    generateDescription();
    root.applyProps(actionProps);
    close();
  }

  onRejected : {
    close();
  }

  function addComboBox(label, linkedProp, model, customArgs){
    var comboComponent = Qt.createComponent("UIComboBox.qml");
    if ( comboComponent.status != Component.Ready){
      if (comboComponent.status == Component.Error){
	      console.log("Error : " + comboComponent.errorString() );
	      return;
      }
      console.log("Error : UIcomboBox component not ready");
    } else {
      var combo = comboComponent.createObject(contentColumn, {"width" : contentColumn.width});
      let key = Object.keys(model)[0]
      combo.label.text = label
      combo.comboBox.textRole = key
      let comboModel = Qt.createQmlObject("import QtQuick.Controls 2.12; import QtQuick 2.12; ListModel {}", combo.comboBox, 'ErrorString')
      for (let i = 0; i < model[key].length; ++i){
        let element = {[key] : model[key][i]}
        comboModel.append(element)
      }
      combo.comboBox.model = comboModel
      combo.comboBox.currentIndex = -1 //By trial and error found that this must be added after model
      if (customArgs.length > 0){
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
	    console.log("Error : UISpinBox component not ready");
	  } else {
		  var spin = spinComponent.createObject(contentColumn, {"width" : contentColumn.width});
      spin.label.text = label
      if (customArgs.length > 0){
        parseCustomArgs(customArgs, spin)
      }
      if (spin.displayEnum.length > 0){
        spin.spinBox.increase()   //This is terribly hacky, but spin box will not update display text to reflect use of enum unless the value changes.  So increase here, then decrease to force box to refresh text
        spin.spinBox.valueFromText = function (text) { return spin.valueFromEnum(spin.spinBox.text) }
        spin.spinBox.textFromValue = function (value) { return spin.valueToEnum(spin.spinBox.value) }
        spin.spinBox.textFromValue(0)
        spin.spinBox.decrease()
      }
      spin.spinUpdate.connect(function(value) {root.updateProperty(value, linkedProp)})
      root.onReset.connect(spin.resetSpinBox)
	  }
  }

  function initializeProperties(newProps){
    for (let i = 0; i < newProps.length; ++i){
      Object.assign(actionProps,newProps[i]);
    }
    root.title = actionProps.name + " Editor"
  }

  function getProperties(){
    for (let prop in actionProps){
      console.log(prop, actionProps[prop])
    }
  }

  function updateProperty(value, prop) {
    actionProps[prop] = value
    console.log(prop, actionProps[prop])
  }

  function generateDescription(){
    let description = actionProps.name + ": "
    let numChildren = root.contentItem.children.length
    console.log(numChildren)
    for (let child = 0; child < numChildren; ++child){
      description += root.contentItem.children[child].getDescription()
      if (child != numChildren-1){
        description += "; "
      }
    }
    Object.assign(actionProps, {description: description})
  }

  function parseCustomArgs(customArgs, item){
    for (let i = 0; i < customArgs.length; ++i){
      let argKey = Object.keys(customArgs[i])[0]
      if (item.hasOwnProperty(argKey)){
        item[argKey] = customArgs[i][argKey]
      }
    }
  }
   
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
