import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3

Rectangle {
  id: root
  property string text : "unasigned"
  color : "transparent"
  Layout.fillWidth: true
  Layout.fillHeight: true
  Text {
    id:content
    width : parent.width
    height : parent.height
    text: root.text
		font.pointSize : 20
    color: "white"
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    opacity: enabled ? 1.0 : 0.3
    elide: Text.ElideRight
  }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
