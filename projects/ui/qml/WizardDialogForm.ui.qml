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
    height : parent.height * 0.05
    color: "#1A5276"
    border.color: "#1A5276"
    Text {
      id:content
      anchors.fill : parent
      text: wizardDialog.title
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
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 