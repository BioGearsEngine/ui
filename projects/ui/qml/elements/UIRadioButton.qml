import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.folderlistmodel 2.12

UIRadioButtonForm {
  id: root
  //--------Signals and Handlers-------------------

 //Emit when new radio selection is made
  signal radioGroupUpdate (int value)

  //Emit when dialog Reset signal is detected
  signal resetRadioGroup()

  //Handle radio button clicked and emit radioUpdate with index of button (use index because we mostly use these buttons for passing to C++ based enums, which are int based)
  radioGroup.onClicked : {
    radioGroupUpdate(button.buttonIndex)
  }
  
  //Handle reset signal by unchecking all radio buttons in group
  onResetRadioGroup : {
    radioGroup.checkState = Qt.Unchecked
  }
  
  //---------Functions----------------------------

 //----------------------------------------------
 //Generates description of property for dialog window description assembly
  function getDescription(){
    return label.text + " = " + buttonModel[radioGroup.checkedButton.buttonIndex]
  }

 //----------------------------------------------
 //A radio group property is valid if a button is checked (Qt.Unchecked state means no button is checked)
  function isValid(){
    return radioGroup.checkState != Qt.Unchecked
  }
 
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
