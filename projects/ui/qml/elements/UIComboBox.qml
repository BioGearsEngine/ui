import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.folderlistmodel 2.12

UIComboBoxForm {
  id: root
  //----------Signals and Handlers------------------

  // Emit new value to dialog window when new entry selected from menu
  signal comboUpdate(string currentSelection)

  //Emit when dialog window Reset is detected
  signal resetCombo()

  // Handle new entry seleted from menu (according to model type) and emit comboUpdate
  comboBox.onActivated : {
    if (comboBox.model instanceof ListModel){
      comboUpdate(comboBox.model.get(comboBox.currentIndex)[comboBox.textRole])
    } else if (comboBox.model instanceof FolderListModel) {
      comboUpdate(comboBox.model.get(comboBox.currentIndex, comboBox.textRole));
    }
  }

  // Handle reset signal by clearing box
  onResetCombo : {
    comboBox.currentIndex = -1
    comboUpdate("")
  }

  //---------Functions----------------------------

  //----------------------------------------------
  //Generates description of property for dialog window description assembly
  function getDescription(){
    if (comboBox.model instanceof ListModel){
      return label.text + " = " + comboBox.model.get(comboBox.currentIndex)[comboBox.textRole]
    } else if (comboBox.model instanceof FolderListModel){
      return label.text + " = " + comboBox.model.get(comboBox.currentIndex, comboBox.textRole)
    } else {
      return ''
    }
  }
  //----------------------------------------------
  //A combo box property is valid if the index is not equal to -1 (meaning nothing displayed in box)
  function isValid(){
    return comboBox.currentIndex != -1
  }

}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
