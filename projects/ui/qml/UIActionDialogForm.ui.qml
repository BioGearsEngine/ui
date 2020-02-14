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
  property var numRows : 1
  property var numColumns : 1

  width : 500
  height : 250
  modal : true
  closePolicy : Popup.NoAutoClose
  
  footer : DialogButtonBox {
    standardButtons : Dialog.Apply | Dialog.Reset | Dialog.Cancel
  }
  
  contentItem : GridLayout {
    id : contentGrid
		anchors.left : parent.left;
		anchors.right : parent.right;
    rows : numRows
    columns : numColumns
    columnSpacing : 10
    rowSpacing : 10
  }

 
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
