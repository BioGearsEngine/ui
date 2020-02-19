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
    textField.clear();
  }

  // Handle newly edited text by calling update signal and passing new value
  textField.onEditingFinished : {
    root.textFieldUpdate(textField.text)
  }

  //---------Functions----------------------------

  //----------------------------------------------
  //Generates description of property for dialog window description assembly
  function getDescription(){
    return textField.placeholderText + " = " + textField.text
  }

}




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
