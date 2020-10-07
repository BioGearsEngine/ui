import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

/*
Brief:  A label and spinbox laid out in a row for use in action editor dialog boxes
*/

RowLayout {
  id: root
  //Properties -- used to customize look / functionality of component
  property real elementRatio : 0.5                //Element ratio used to adjust relative sizes of label and box. Default is to split available space evenly
  property var buttonModel : []
  //Property aliases -- used to access sub-components outside of form file
  property alias label: name
  property alias buttonView : buttonView
  property alias radioGroup : radioGroup
  spacing : 10

  Label {
    id: name
    text: "Unset"
    horizontalAlignment : Text.AlignHCenter
    verticalAlignment : Text.AlignVCenter
    font.pixelSize : 18
    font.bold: false
  }

  ButtonGroup {
    id: radioGroup
    exclusive : true
  }

  ListView {
    id : buttonView
    implicitHeight : contentHeight
    Layout.maximumWidth : root.prefWidth * (1.0 - elementRatio)
    Layout.fillWidth : true
    Layout.alignment : Qt.AlignVCenter | Qt.AlignRight
    orientation : ListView.Vertical
    model : buttonModel
    delegate : RadioDelegate {
      id : radioDelegate
      ButtonGroup.group : radioGroup
      text : modelData
      height : 1.1 * buttonText.implicitHeight
      width : buttonView.width
      property int buttonIndex : index
      contentItem : Text {
        id : buttonText
        text : radioDelegate.text
        font.pixelSize : label.font.pixelSize
        x : delegateIndicator.width
        leftPadding : 10
        horizontalAlignment : Text.AlignLeft
        verticalAlignment : Text.AlignVCenter
      }
      indicator : Rectangle {
        id : delegateIndicator
        implicitWidth : 20
        implicitHeight : 20
        radius : 25
        x : 0
        y : radioDelegate.height / 2 - height / 2
        color : "transparent"
        border.color : "#2980b9"
        border.width : 2
        Rectangle {
          id : checkedDisplay
          width : 0.5 * parent.width
          height : 0.5 * parent.height
          radius : 25
          color : "#2980b9"
          anchors.centerIn : parent
          visible : radioDelegate.checked
        }
      }
      background : Rectangle {
        id : delegateBackground
        height : radioDelegate.height
        width : radioDelegate.width
        color : "transparent"
        border.color : "black"
        border.width : 0  //Set this to non-zero to visualize button locations
      }
    }
  }


}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
