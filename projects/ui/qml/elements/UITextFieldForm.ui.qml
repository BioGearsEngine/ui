import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

Item {
  id: root
  //Properties -- used to customize look / functionality of component
  property real prefWidth : parent.width
  property real prefHeight : root.implicitHeight
  property int textSize : 8
  property int colSpan : 1
  property int rowSpan : 1
  property bool available : true
  property bool validateDouble : true
  property bool required : true
  property real maxValue : Infinity
  property var resetValue : null
  //Property aliases -- used to access text field sub-properties outside of form file
  property alias textField : textField
  //Layout options
  Layout.preferredWidth : prefWidth
  Layout.preferredHeight : prefHeight
  Layout.columnSpan : colSpan
  Layout.rowSpan : rowSpan
  Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter

  //States
  states : [
    State {
      //When the field is available for input but not currently being edited, set background border to grey
      name : "available-unfocused" ; when : root.available && !textField.activeFocus
      PropertyChanges {target : backgroundRect; border.color : "grey"; border.width : 2; opacity : 1.0; enabled : true}
      PropertyChanges {target : textField; opacity : 1.0; enabled : true}
     },
    State {
      //When the field is available for input and being currently edited, set background to green
      name : "available-focused"; when : root.available && textField.activeFocus
      PropertyChanges {target : backgroundRect; border.color : "green"; border.width : 3; opacity : 1.0; enabled : true}
      PropertyChanges {target : textField; opacity : 1.0; enabled : true}
    },
    State {
      //When the field is unavailble for editing, turn off visibility and remove background border
      name : "unavailable"; when : !root.avaialble
      PropertyChanges {target : backgroundRect; opacity : 0.35; enabled : false}
      PropertyChanges {target : textField; opacity : 0.35; enabled : false}
    }
    ]

  DoubleValidator {
    id : doubleValidator
    bottom : 0.0
    top : root.maxValue
    decimals : 3
  }

  TextField {
    id:textField
    //Text field height is dictated by implicit height of text.  If you try to set it using height properties, the text will not respect
    // the boundaries and will appear out of place w/ respect to other alignment settings.  If you need a smaller text field, then you
    // need to set the text size smaller (or allow more space in widget for the field).
    anchors.left : parent.left
    anchors.right : parent.right
    font.pointSize : root.textSize
    verticalAlignment : Text.AlignVCenter
    horizontalAlignment : Text.AlignHCenter
    validator : validateDouble ? doubleValidator : null
    background : Rectangle {
      id : backgroundRect
      border.width : 1
      anchors.fill : parent
      color : "transparent"
    }
  }
}




/*##^## Designer {
    D{i:0;height:25;width:200}
}
 ##^##*/
