import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.folderlistmodel 2.12

UIComboBoxForm {
    id: root

    property string description
    signal comboUpdate(string currentSelection)
    signal resetCombo()

    comboBox.onActivated : {
      comboUpdate(comboBox.model.get(comboBox.currentIndex).name)
    }

    onResetCombo : {
      comboBox.currentIndex = -1
      comboUpdate("")
    }

    function getDescription(){
      return label.text + " = " + comboBox.model.get(comboBox.currentIndex).name
    }

}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
