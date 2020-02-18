import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

Item {
  id: root

  property real prefWidth : parent.width
  property real prefHeight : root.implicitHeight
  property int colSpan : 1
  property int rowSpan : 1
  property bool editable : true
  property alias textField : textField

  states : [
    State { 
      name : "unfocused" ; when : root.editable && !textField.activeFocus
      PropertyChanges {target : backgroundRect; border.color : "grey"; border.width : 1}
      PropertyChanges {target : textField; visible : true}
     },
    State {
      name : "focused"; when : root.editable && textField.activeFocus
      PropertyChanges {target : backgroundRect; border.color : "green"; border.width : 3}
      PropertyChanges {target : textField; visible : true}
    },
    State {
      name : "nonEditable"; when : !root.editable
      PropertyChanges {target : backgroundRect; border.width : 0}
      PropertyChanges {target : textField; visible : false}
    }
    ]


  Layout.preferredWidth : prefWidth
  Layout.preferredHeight : prefHeight
  Layout.columnSpan : colSpan
  Layout.rowSpan : rowSpan

  TextField {
    id:textField
    anchors.fill : parent
    font.pointSize : 11
    verticalAlignment : Text.AlignBottom
    horizontalAlignment : Text.AlignHCenter
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
