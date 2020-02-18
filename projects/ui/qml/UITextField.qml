import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3

UITextFieldForm {
  id: root
    
  signal resetTextField()
  signal textFieldUpdate(string inputText)

  onResetTextField : {
    textField.clear();
  }

  textField.onEditingFinished : {
    root.textFieldUpdate(textField.text)
  }

  function getDescription(){
    return textField.placeholderText + " = " + textField.text
  }

}




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
