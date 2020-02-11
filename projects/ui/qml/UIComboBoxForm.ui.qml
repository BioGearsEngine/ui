import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

RowLayout {
  id: root

  property alias label: name
  property alias comboBox: value
  property real elementRatio : 0.5
  property string splitToken
  Layout.preferredWidth : parent.width

  Label {
    id: name
    Layout.preferredWidth : root.Layout.preferredWidth * elementRatio
    Layout.fillWidth : true
    Layout.fillHeight : true
    text: "Unset"
    font.pointSize: 10
    font.weight: Font.DemiBold
    font.bold: false
  }

  ComboBox {
    id: value
    Layout.preferredWidth : root.Layout.preferredWidth * (1.0 - elementRatio)
    Layout.fillWidth : true
    Layout.fillHeight : true
    font.weight: Font.Medium
    font.pointSize: 10
    editable: true

    contentItem : Text {
      text : value.displayText
      font : value.font
      verticalAlignment : Text.AlignVCenter;
      horizontalAlignment : Text.AlignHCenter;
    }
    delegate : ItemDelegate {
      width : parent.width;
      contentItem : Text {
        text : splitToken ? model.fileName.toString().split(splitToken)[0] : model.name
        verticalAlignment : Text.AlignVCenter;
        horizontalAlignment : Text.AlignHCenter;
        font: value.font;
      }
      height : value.height
      highlighted : value.highlightedIndex === index;
    }
  }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
