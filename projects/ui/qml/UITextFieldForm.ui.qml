import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

TextField {
  id: root

  property real elementRatio : 0.5    //Element ratio used to adjust relative sizes of label and box. Default is to split available space evenly
  property int colSpan : 1
  property int rowSpan : 1
  property bool editing : false

  Layout.fillWidth : true
  font.pointSize : 12
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
