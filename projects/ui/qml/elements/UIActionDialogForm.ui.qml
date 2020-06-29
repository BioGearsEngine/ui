import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

/*
Brief:  Defines a blank dialog window containing a 1 x 1 grid and standard buttons for customization of action editor dialog
*/

Dialog {
  id: dialogForm
  //Properties -- used to customize the functionality / look of the dialog window
  property var actionProps : ({})
  property int numRows : 1
  property int numColumns : 1
  property int colSpace: 0
  property int rowSpace : 0
  //Base properties
  width : 500
  height : 250
  modal : true
  closePolicy : Popup.NoAutoClose
  //Header
  header : Rectangle {
    id : headerBackground
    width : parent.width
    height : 50
    color: "#1A5276"
    border.color: "#1A5276"
    Text {
      id:content
      anchors.fill : parent
      text: dialogForm.title
		  font.pointSize : 12
      leftPadding : 10
      color: "white"
      horizontalAlignment: Text.AlignLeft
      verticalAlignment: Text.AlignVCenter
    }
  }
  //Add standard buttons to footer
  footer : DialogButtonBox {
    standardButtons : Dialog.Apply | Dialog.Reset | Dialog.Cancel
  }
  //Main content
  contentItem : GridLayout {
    id : contentGrid
		anchors.left : parent.left;
		anchors.right : parent.right;
    anchors.top : header.bottom
    anchors.bottom : footer.top
    rows : numRows
    columns : numColumns
    columnSpacing : colSpace
    rowSpacing : rowSpace
  }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
