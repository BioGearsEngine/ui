import QtQuick 2.12
import QtQuick.Controls 2.5
import Qt.labs.folderlistmodel 2.12

UISpinBoxForm {
    id: root

    function valueFromEnum (text) {
      if (displayEnum.length == 0){
        console.log('UISpinBoxForm: You must define displayEnum property')
        return -1;
      } else {
        for (var i = 0; i < displayEnum.length; ++i){
          if (displayEnum[i] == spinBox.text){
            return i
          }
        }
        return spinBox.value
      }
    }
    function valueToEnum (value){
      if (displayEnum.length == 0){
        console.log('UISpinBoxForm: You must define displayEnum property')
        return -1
      } else {
        return displayEnum[value]
       }
    }

    function valueFromDecimal (text) {
      if (unitScale){
        return Number.fromLocaleString(text) * spinBox.to
      } else {
        console.log('UISpinBoxForm:  You must define unitScale property')
      }
    }

    function valueToDecimal (value) {
        if (unitScale){
          return Number(value/spinBox.to).toLocaleString('f', 2);  //Defaulting to 2 decimals for now
        } else {
          console.log('UISpinBoxForm:  You must define unitScale property')
        }
    }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
