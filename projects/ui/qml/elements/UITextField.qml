import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3

UITextFieldForm {
  id: root
  
  //------Signals and Handlers---------------

  //Emit when dialog Reset signal is detected
  signal resetTextField()

  //Emit new text to dialog window when field is updated
  signal textFieldUpdate(string inputText)

  // Handle reset signal by clearing text from field
  onResetTextField : {
    if (resetValue === null){
      textField.clear();
    } else {
      textField.text = resetValue
    }
  }

  // Handle newly edited text by calling update signal and passing new value
  // By default, this signal is only called if the input is acceptable to validator
  textField.onEditingFinished : {
    root.textFieldUpdate(textField.text)
  }

  // Handle text that has been edited but not valid (outside of range set by validator)
  // By constantly clearing invalid text, the user will not be able to enter "bad" data
  textField.onTextEdited : {
    if (!textField.acceptableInput){
      textField.clear()
    }
  }

  //---------Functions----------------------------

  function changeState(newState){
    root.state = newState
    if (newState == "nonEditable"){
      textField.clear()
    }
  }

  //----------------------------------------------
  //Generates description of property for dialog window description assembly
  function getDescription(){
    return textField.placeholderText + " = " + textField.text
  }

  //----------------------------------------------
  //A text field property is valid if text in an *editable* field is not empty (as determined by length of text) 
  function isValid() {
    if (root.available){
      return root.required ? !(textField.text.length===0) : true
    }
    return !available
  }


}




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
