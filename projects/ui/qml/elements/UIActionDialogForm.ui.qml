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
  property string errorString : ""
  property alias dialogLoader: dialogLoader
  property alias dialogItem : dialogLoader.item
  //Base properties
  width : 500
  height : 250
  bottomPadding : 0
  bottomInset : 0
  bottomMargin : 0
  modal : false
  closePolicy : Popup.NoAutoClose
  //Header
  header : Rectangle {
    id : headerBackground
    width : parent.width
    height : 30
    color: "#2980b9"
    border.color: "#2980b9"
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
    UIBioGearsButtonForm {
      text : "Save"
      font.pixelSize : 16
      DialogButtonBox.buttonRole: DialogButtonBox.ApplyRole
      implicitHeight : 30
      implicitWidth : 80
    }
    UIBioGearsButtonForm {
      text : "Reset"
      font.pixelSize : 16
      DialogButtonBox.buttonRole: DialogButtonBox.ResetRole
      implicitHeight : 30
      implicitWidth : 80
    }
    UIBioGearsButtonForm {
      text : "Cancel"
      font.pixelSize : 16
      DialogButtonBox.buttonRole: DialogButtonBox.RejectRole
      implicitHeight : 30
      implicitWidth : 80
    }
  }
  contentItem : Loader {
    id : dialogLoader
    sourceComponent : undefined
    width : root.width
    anchors.top : header.bottom
    anchors.bottom : footer.top
  }  
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
