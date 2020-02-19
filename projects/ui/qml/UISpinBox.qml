import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.folderlistmodel 2.12

UISpinBoxForm {
  id: root
  //--------Signals and Handlers-------------------

  //Emit new value to dialog window when spin box value changes
  signal spinUpdate (real value)

  //Emit when dialog Reset signal is detected
  signal resetSpinBox()

  //Handle new spin box value (adjusted for scaling if necesary) and emit spinUpdate
  spinBox.onValueModified : {
    if (unitScale) {
      spinUpdate(spinBox.value / spinBox.to);
    } else {
      spinUpdate(spinBox.value)
    }
  }

  //Handle reset signal by setting spin box value back to 0
  onResetSpinBox : {
    spinBox.value = 0
    spinUpdate(spinBox.value)
  }

  //---------Functions----------------------------

  //----------------------------------------------
  //Generates description of property for dialog window description assembly
  function getDescription(){
    let dispValue = spinBox.value
    if (unitScale){
      dispValue = dispValue / spinBox.to
    }
    if (displayEnum.length > 0){
      dispValue = displayEnum[spinBox.value]
    }
    return label.text + " = " + dispValue
  }

  //----------------------------------------------
  //Generates value stored by spin box according to enum value (text) displayed in editable area
  //This function is assigned to the SpinBox property valueFromText when the displayEnum property is set
  //Ex : If displayEnum is ['Mild', 'Medium', 'Severe'] and current selection is 'Medium', spin box 
  //      will store value = 1
  function valueFromEnum (text) {
    if (displayEnum.length == 0){
      console.log('UISpinBoxForm: You must define displayEnum property')
      return -1;
    } else {
      for (let i = 0; i < displayEnum.length; ++i){
        if (displayEnum[i] == spinBox.text){
          return i
        }
      }
      return spinBox.value
    }
  }

  //----------------------------------------------
  //Generates text to display in editable area according to current stored spin box value
  //This function is assigned to the SpinBox property textFromValue when the displayEnum property is set
  //Ex : If displayEnum is ['Mild', 'Medium', 'Severe'] and stored value = 2, then spin box will display
  //      'Severe'
  function valueToEnum (value){
    if (displayEnum.length == 0){
      console.log('UISpinBoxForm: You must define displayEnum property')
      return -1
    } else {
      return displayEnum[value]
      }
  }

  //----------------------------------------------
  //Generates value stored by spin box when the display text is adjusted to represented a decimal value
  //This function is assigned to the SpinBox property valueFromText when the unitScale property = true
  //The display text is assumed to be scaled by the maximum possible input for the spin box
  //Ex : If spin box displays 0.2 and spin.to = 100, then spin box will store 20
  //Note that the scaled value (spin.value / spin.to) is then passed to spinUpdate
  function valueFromDecimal (text) {
    if (unitScale){
      return Number.fromLocaleString(text) * spinBox.to
    } else {
      console.log('UISpinBoxForm:  You must define unitScale property')
    }
  }

  //----------------------------------------------
  //Generates text to be displayed by spin box so that stored value can be represented as a decimal
  //This function is assigned to the SpinBox property textFrom when the unitScale property = true
  //The display text is assumed to be scaled by the maximum possible input for the spin box
  //Ex : If spin box value = 30 and spin.to = 100, then 0.3 will be displayed.
  //Note that the scaled value (spin.value / spin.to) is then passed to spinUpdate
  function valueToDecimal (value) {
      if (unitScale){
        return Number(value/spinBox.to).toLocaleString('f', 2);  //Defaulting to 2 decimals for now
      } else {
        console.log('UISpinBoxForm:  You must define unitScale property')
      }
  }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
