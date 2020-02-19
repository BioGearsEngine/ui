import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

Item {
  id: root
  //Properties -- used to customize look / functionality of component
  property real prefWidth : parent.width
  property real prefHeight : root.implicitHeight
  property int colSpan : 1
  property int rowSpan : 1
  property bool editable : true
  //Property aliases -- used to access text field sub-properties outside of form file
  property alias textField : textField
  //Layout options
  Layout.preferredWidth : prefWidth
  Layout.preferredHeight : prefHeight
  Layout.columnSpan : colSpan
  Layout.rowSpan : rowSpan
  //States
  states : [
    State {
      //When the field is available for input but not currently being edited, set background border to grey
      name : "unfocused" ; when : root.editable && !textField.activeFocus
      PropertyChanges {target : backgroundRect; border.color : "grey"; border.width : 1}
      PropertyChanges {target : textField; visible : true}
     },
    State {
      //When the field is available for input and being currently edited, set background to green
      name : "focused"; when : root.editable && textField.activeFocus
      PropertyChanges {target : backgroundRect; border.color : "green"; border.width : 3}
      PropertyChanges {target : textField; visible : true}
    },
    State {
      //When the field is unavailble for editing, turn off visibility and remove background border
      name : "nonEditable"; when : !root.editable
      PropertyChanges {target : backgroundRect; border.width : 0}
      PropertyChanges {target : textField; visible : false}
    }
    ]

  TextField {
    id:textField
    anchors.fill : parent
    font.pointSize : 11
    verticalAlignment : Text.AlignBottom
    horizontalAlignment : Text.AlignHCenter
    validator : DoubleValidator {
      bottom : 0.0
    }
    background : Rectangle {
      id : backgroundRect
      anchors.fill : parent
      color : "transparent"
    }
  }
}




/*##^## Designer {
    D{i:0;height:25;width:200}
}
 ##^##*/
