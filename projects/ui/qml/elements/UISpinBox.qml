import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.folderlistmodel 2.12

UISpinBoxForm {
  id: root
  //--------Signals and Handlers-------------------

  //Emit new value to dialog window when spin box value changes
  signal spinUpdate (real value)

  //Emit when dialog Reset signal is detected
  signal resetSpin()

  //Handle new spin box value (adjusted for scaling if necesary) and emit spinUpdate
  spinBox.onValueModified : {
    spinUpdate(spinBox.value / spinScale)
  }

  //Handle reset signal by setting spin box value back to 0
  onResetSpin : {
    if (resetValue === null){
      spinBox.value = 0
    } else {
      spinBox.value = resetValue
    }
    spinUpdate(spinBox.value)
  }

  //---------Functions----------------------------

  //----------------------------------------------
  //Generates description of property for dialog window description assembly
  function getDescription(){
    let dispValue = spinBox.value / spinScale
    if (displayEnum.length > 0){
      dispValue = displayEnum[spinBox.value]
    }
    return label.text + " = " + dispValue
  }

  //----------------------------------------------
  //A spin box property needs to return a non-zero value for the action to be valid
  function isValid(){
    return root.required ? spinBox.value != 0 : true
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
  function valueFromDecimal (text, locale) {
    return Number.fromLocaleString(locale, text) * spinScale
  }

  //----------------------------------------------
  //Generates text to be displayed by spin box so that stored value can be represented as a decimal
  //This function is assigned to the SpinBox property textFrom when the unitScale property = true
  //The display text is assumed to be scaled by the maximum possible input for the spin box
  //Ex : If spin box value = 30 and spin.to = 100, then 0.3 will be displayed.
  //Note that the scaled value (spin.value / spin.to) is then passed to spinUpdate
  function valueToDecimal (value ) {
    return Number(value/spinScale).toLocaleString('f', 2);  //Defaulting to 2 decimals for now
  }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
