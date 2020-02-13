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

  function addComponent(compType, label, linkedProp, model, customArgs){
    switch (compType) {
      case 'UIComboBox' :
        var comboComponent = Qt.createComponent("UIComboBox.qml");
	      if ( comboComponent.status != Component.Ready){
		      if (comboComponent.status == Component.Error){
			      console.log("Error : " + comboComponent.errorString() );
			      return;
		      }
	        console.log("Error : UIcomboBox component not ready");
	      } else {
		      var combo = comboComponent.createObject(contentColumn, {"width" : contentColumn.width * 0.9, "elementRatio" : 0.5});
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
          combo.comboUpdate.connect(function(value) { root.updateProperty(value, linkedProp) } )
          root.onReset.connect(combo.resetCombo)
        }
      break;
      case 'UISpinBox' :
        var spinComponent = Qt.createComponent("UISpinBox.qml");
	      if ( spinComponent.status != Component.Ready){
		      if (spinComponent.status == Component.Error){
			      console.log("Error : " + spinComponent.errorString() );
			      return;
		      }
	        console.log("Error : UISpinBox component not ready");
	      } else {
		      var spin = spinComponent.createObject(contentColumn, {"width" : contentColumn.width * 0.9, "elementRatio" : 0.5});
          spin.label.text = label
          spin.spinBox.to = 500
          spin.spinBox.stepSize = 10
          spin.spinUpdate.connect(function(value) {root.updateProperty(value, linkedProp)})
          root.onReset.connect(spin.resetSpinBox)
	      }
      break;
      default :
        console.log('Default case')
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
   
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
