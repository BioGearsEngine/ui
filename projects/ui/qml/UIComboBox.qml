import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.folderlistmodel 2.12

UIComboBoxForm {
    id: root

    property string description
    signal comboUpdate(string currentSelection)
    signal resetCombo()

    comboBox.onActivated : {
      if (comboBox.model instanceof ListModel){
        comboUpdate(comboBox.model.get(comboBox.currentIndex)[comboBox.textRole])
      } else if (comboBox.model instanceof FolderListModel) {
        comboUpdate(comboBox.model.get(comboBox.currentIndex, comboBox.textRole));
      }
    }

    onResetCombo : {
      comboBox.currentIndex = -1
      comboUpdate("")
    }

    function getDescription(){
      if (comboBox.model instanceof ListModel){
        return label.text + " = " + comboBox.model.get(comboBox.currentIndex)[comboBox.textRole]
      } else if (comboBox.model instanceof FolderListModel){
        return label.text + " = " + comboBox.model.get(comboBox.currentIndex, comboBox.textRole)
      } else {
        return ''
      }
    }

}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
