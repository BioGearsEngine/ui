import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3

UIUnitScalarEntryForm {
  id: root

  signal entryUpdated (var value, string unit)
  signal nameUpdated (string name)
 
  entryField.onEditingFinished : {
    if (validEntry()){
      root.entryUpdated(entryField.text, entryUnit.currentText)
    }
  }
  entryUnit.onActivated : {
    if (validEntry()){
      let unitReturn = entryUnit.currentText
      if (root.type === "enum"){
        unitReturn = entryUnit.currentIndex
        console.log(entryUnit.currentIndex)
      }
      console.log(unitReturn)
      root.entryUpdated(entryField.text, unitReturn)
    }
  }

  function validEntry(){
    let valid = true
    if (entryField.text.length == 0 && entryUnit.currentIndex > -1){
      //We selected a unit but haven't entered a value -- only return false if text field is writable
      valid = !root.writable
    }
    if (entryField.text.length > 0){
      if (!entryField.acceptableInput){
        //We entered a value that did not satisfy the validator (if it exists)
        valid = false
      }
      if (entryUnit.count > 0 && entryUnit.currentIndex == -1){
        //We entered a value but selected no unit (only if there are units to choose from)
        valid = false
      }
    }
    return valid
  }

  function setEntry(value, unit){
    entryField.text = value
    if (entryUnit.count > 0){
      if (type === "enum"){
        entryUnit.currentIndex = unit
      } else {
        let index = entryUnit.find(unit)
        entryUnit.currentIndex = index
      }
    }
  }

  function resetEntry(){
    entryField.clear()
    entryUnit.currentIndex = -1
  }

}




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
