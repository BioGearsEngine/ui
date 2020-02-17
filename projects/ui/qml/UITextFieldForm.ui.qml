import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

TextField {
  id: root

  property real maxWidth : parent.width
  property int colSpan : 1
  property int rowSpan : 1
  property bool editing : false

  Layout.maximumWidth : maxWidth
  Layout.fillWidth : true
  Layout.columnSpan : colSpan
  Layout.rowSpan : rowSpan
  font.pointSize : 11
  verticalAlignment : Text.AlignBottom
  horizontalAlignment : Text.AlignHCenter

  background : Rectangle {
    anchors.fill : parent
    color : 'transparent'
    border.color : editing ? 'green' : 'grey'
    border.width : editing ? 3 : 1


  }
}




/*##^## Designer {
    D{i:0;height:25;width:200}
}
 ##^##*/
