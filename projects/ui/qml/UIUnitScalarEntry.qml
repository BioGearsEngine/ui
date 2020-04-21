import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3

UIUnitScalarEntryForm {
  id: root

  signal entryUpdated (var value, string unit)
 
  entryField.onEditingFinished : {
    if (validEntry()){
      root.entryUpdated(entryField.text, entryUnit.currentText)
    }
  }
  entryUnit.onActivated : {
    if (validEntry()){
      root.entryUpdated(entryField.text, entryUnit.currentText)
    }
  }

  function validEntry(){
    let valid = true
    if (entryUnit.currentIndex == -1 && entryUnit.count > 0){
      valid = false
    }
    if (entryField.text.length == 0){
      valid = false
    }
    return valid
  }

}




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
