import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

RowLayout {
  id: root
  property alias name: name
  property alias value: value
  implicitHeight : name.implictHeight * 2    //Text items have implicit height based on font size.  Make this row twice as big to give some cushion 
  Label {
    id: name
    text: "Unset"
    font.pointSize: 8
    font.weight: Font.DemiBold
    font.bold: true
	//color : "#34495e"
  }

  TextInput {
    id: value
    text: qsTr("Placeholder Text")
    font.weight: Font.Medium
    font.pixelSize: 10
	//color : "#34495e"
  }
}




/*##^## Designer {
    D{i:0;height:25;width:200}
}
 ##^##*/
