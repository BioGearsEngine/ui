import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12


Dialog {
  id: wizardDialog
  //Base properties
  modal : true
  title : "Wizard"
  closePolicy : Popup.NoAutoClose
  //Header
  header : Rectangle {
    id : headerBackground
    width : parent.width
    height : parent.height * 0.075
    color: "#1A5276"
    border.color: "white"
    border.width : 5
    Text {
      id: headerContent
      anchors.fill : parent
      text: wizardDialog.title
		  font.pointSize : 12
      leftPadding : 10
      color: "white"
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
    }
  }
  //Add standard buttons to footer
  footer : DialogButtonBox {
    standardButtons : Dialog.Save | Dialog.Reset | Dialog.Cancel
  }
    //Main content
  contentItem : Rectangle {
    id : mainContent
    color : "transparent"
		anchors.left : parent.left;
		anchors.right : parent.right;
    anchors.top : header.bottom
    anchors.bottom : footer.top
  }
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 