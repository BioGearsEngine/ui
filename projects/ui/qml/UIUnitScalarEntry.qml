import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3

UIUnitScalarEntryForm {
  id: root

  signal inputAccepted (var input)

  function setEntry( fromInput ){
    //Trim decimals down to hundredths place. This is necessary when loading from an existing file, since
    // QML interprets the QVariant [input, unit] as [number, string] when parsing a double.  When setting based off 
    // values from the editor, we get strings from the text field.  Thus, we check if the input is typeof number
    // before trimming.
    if (fromInput[0]!=null && typeof fromInput[0]=="number"){
      let decimals = root.entryValidator ? root.entryValidator.decimals : 2
      let formattedValue = fromInput[0].toFixed(decimals)
      fromInput[0] = formattedValue
      if(fromInput[0] ==="Infinity"){
        //We only support "inf" values for transport maximum in renal dynamics.  Validator doesn't like the inifinity string
        // so we just set to a really high number.
        console.log('inf')
        fromInput[0] = 1e10
      }
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
