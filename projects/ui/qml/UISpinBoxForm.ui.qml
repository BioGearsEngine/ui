import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

/*
Brief:  A label and spinbox (dropdown menu) laid out in a row for use in action editor dialog boxes
*/

RowLayout {
  id: root
  
  property real elementRatio : 0.5    //Element ratio used to adjust relative sizes of label and box. Default is to split available space evenly
  property alias label: name
  property alias spinBox : spinBox
  property var displayEnum : []     //Text to display insted of values, if desired (e.g. 'Mild', 'Moderate', 'Severe' instead of 0, 1, 2)
  property bool unitScale : false     //SpinBox does not support float step-sizes.  If flagged, this tells SpinBox to divide all values by the maximum spin value so that they are output on 0-1 scale

  Layout.preferredWidth : parent.width

  Label {
    id: name
    Layout.preferredWidth : root.Layout.preferredWidth * elementRatio
    Layout.fillWidth : true
    Layout.fillHeight : true
    text: "Unset"
    font.pointSize: 12
    font.bold: false
  }

  SpinBox {
    id: spinBox
    //valueFromText : function(text) { root.valueFromEnum() }
    //textFromValue : function(value) { return root.valueToEnum(value) }
    Layout.preferredWidth : root.Layout.preferredWidth * (1.0 - elementRatio)
    Layout.fillWidth : true
    Layout.fillHeight : true
    font.pointSize : 12
    editable : true
    value : 0   //Default start at 0 (can override)
    from : 0    //Default minimum of 0 (can override)
    validator : IntValidator {
      bottom : spinBox.from
      top : spinBox.to
    }
  }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
