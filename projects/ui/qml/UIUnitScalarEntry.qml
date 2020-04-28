import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3

UIUnitScalarEntryForm {
  id: root

  signal nameUpdated (string name)
  signal inputAccepted (var input)
 
  function setEntry( fromInput ){
    root.entry.setFromExisting(fromInput)
  }

  function reset(){
    root.entry.reset()
  }

}




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
