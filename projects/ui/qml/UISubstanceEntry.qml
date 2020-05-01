import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3

UISubstanceEntryForm {
  id: root

  signal inputAccepted (var input)
  signal substanceUpdateRejected(string previousName) //Emitted if we try to set a component that already exists
 
  onSubstanceUpdateRejected : {
    root.substanceInput.currentIndex = root.substanceInput.find(previousName)
  }

  function setEntry( fromInput ){
    //Trim decimals down to hundredths place. This is necessary when loading from an existing file, since
    // QML interprets the QVariant [input, unit] as [number, string] when parsing a double.  When setting based off 
    // values from the editor, we get strings from the text field.  Thus, we check if the input is typeof number
    // before trimming.
    if (fromInput[0]!=null && typeof fromInput[1]=="number"){
      let formattedValue = fromInput[1].toFixed(2)
      fromInput[0] = formattedValue
    }
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
