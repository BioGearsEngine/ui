import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

/*
Brief:  A label and spinbox (dropdown menu) laid out in a row for use in action editor dialog boxes
*/

Dialog {
  id: dialogForm
  
  property var actionProps : ({})
  property int numComponents : 0
  property alias contentColumn : contentColumn

  width : 500
  height : 250
  modal : true
  closePolicy : Popup.NoAutoClose
  
  footer : DialogButtonBox {
    standardButtons : Dialog.Apply | Dialog.Reset | Dialog.Cancel
  }
  
  contentItem : Column {
    id : contentColumn
    spacing : 5;
		anchors.left : parent.left;
		anchors.right : parent.right;
  }

 
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
