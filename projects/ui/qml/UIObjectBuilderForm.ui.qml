import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12


Dialog {
  id: patientDialog
  //Properties -- used to customize the functionality / look of the dialog window
  property int numRows : 1
  property int numColumns : 2
  property int colSpace : 5
  property int rowSpace : 5
  //Base properties
  modal : true
  title : "Patient Creator"
  closePolicy : Popup.NoAutoClose
  //Header
  header : Rectangle {
    id : headerBackground
    width : parent.width
    height : parent.height * 0.05
    color: "#1A5276"
    border.color: "#1A5276"
    Text {
      id:content
      anchors.fill : parent
      text: patientDialog.title
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
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 