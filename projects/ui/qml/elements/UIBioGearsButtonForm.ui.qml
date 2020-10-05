import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

/*
Brief:  A standard button for BioGears interface
*/
Button {
  id : root
  property string primary : "#4CAF50"
  property string secondary : "#339933"
  padding : 0
  background : Rectangle {
    id : background
    anchors.fill : parent
    radius : 5
    color : primary
  }
  contentItem : Text {
    text : root.text
    color : "white"
    font : root.font
    horizontalAlignment : Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
  }
  onPressed : {
    background.color = secondary
  }
  onReleased : {
    background.color = primary
  }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/