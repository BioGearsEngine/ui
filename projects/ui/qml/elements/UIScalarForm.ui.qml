import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.5
import QtQuick.Controls.Material 2.3

ColumnLayout {
  property alias value: value.text
  property alias name: name.text

  implicitHeight : (value.implicitHeight + name.implicitHeight) * 1.2  //Text and laber have implicit height based on font size.  Define natural column size as 20% above combined height to give cushion 
  Text {
    id: value
    Layout.alignment: Qt.AlignHCenter
    horizontalAlignment : Text.AlignHCenter
    text: "22"
    font.pixelSize: 20
  }
  Label {
    id: name
    text: "Age:"
    font.pixelSize: 14
    Layout.alignment: Qt.AlignHCenter
    horizontalAlignment : Text.AlignHCenter
  }
}




/*##^## Designer {
    D{i:0;height:54;width:30}
}
 ##^##*/
