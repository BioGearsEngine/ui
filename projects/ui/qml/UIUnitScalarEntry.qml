import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3

UIUnitScalarEntryForm {
  id: root

  signal entryUpdated (var value, string unit)

  entryField.onEditingFinished : {
    root.entryUpdated (entryField.text, entryUnit.currentText)
  }
  entryUnit.onActivated : {
    let currentUnit = ""
    if (entryUnit.currentIndex != -1) {
      currentUnit = entryUnit.currentText
    }
    root.entryUpdated(entryField.text, currentUnit)
  }

}




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
