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
  property real prefWidth : parent.width
  property var displayEnum : []                   //Text to display insted of values, if desired (e.g. 'Mild', 'Moderate', 'Severe' instead of 0, 1, 2)
  property int spinScale : 1                      //SpinBox does not support float step-sizes.  This property scales all spinBox display values so that they are in the range [spin.from/spinScale, spin.to/spinScale] 
  property int spinMax : 1
  property int spinStep : 1
  property int colSpan : 1
  property int rowSpan : 1
  property bool required : true
  property bool available : true
  property var resetValue : null
  spacing : 10
  //Property aliases -- used to access sub-components outside of form file
  property alias label: name
  property alias spinBox : spinBox
  
  //States
  state : "available" //Initial state is available
  states : [
    State {
      //When the field is available for input it is fully opaque and enabled
      name : "available" ; when : root.available
      PropertyChanges {target : name; opacity : 1.0; enabled : true}
      PropertyChanges {target : spinBox; opacity : 1.0; enabled : true}
     },
    State {
      //When the field is unavailble for editing, turn down opacity ("ghost" out) and disable so that it cannot accept input
      name : "unavailable"; when : !root.avaialble
      PropertyChanges {target : name; opacity : 0.5; enabled : false}
      PropertyChanges {target : spinBox; opacity : 0.5; enabled : false}
    }
    ]

  Label {
    id: name
    Layout.fillHeight : true
    text: "Unset"
    horizontalAlignment : Text.AlignLeft
    verticalAlignment : Text.AlignVCenter
    font.pixelSize : 18
    font.bold: false
  }

  SpinBox {
    id: spinBox
    Layout.maximumWidth : root.prefWidth * (1.0 - elementRatio)
    Layout.alignment : Qt.AlignRight
    Layout.fillWidth : true
    implicitHeight : 40
    font.pixelSize : 18
    padding : 0
    editable : true
    value : 0   //Default start at 0 (can override)
    from : 0    //Default minimum of 0 (can override)
    to : spinMax
    stepSize : spinStep
    validator : DoubleValidator {
      bottom : spinBox.from
      top : spinBox.to
    }
    contentItem : TextInput {
      id : spinInput
      anchors.verticalCenter : spinBox.verticalCenter
      text : spinBox.textFromValue(spinBox.value)
      readOnly : !spinBox.editable
      topPadding : 5
      font.pixelSize : 18
      verticalAlignment : TextInput.AlignVCenter
      horizontalAlignment : TextInput.AlignHCenter
      validator : spinBox.validator
      inputMethodHints: Qt.ImhFormattedNumbersOnly
      onEditingFinished : {
        spinBox.value = spinBox.valueFromText(spinInput.text, spinBox.locale)
      }
    }
    down.indicator: Rectangle {
      x: 0
      height: spinBox.height
      width : spinBox.height
      color: "#2980b9"
      border.color: "#2980b9"
      Text {
        text: "-"
        font.pixelSize: 20
        color: "white"
        anchors.fill: parent
        fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
    up.indicator: Rectangle {
      x: spinBox.width - width
      height: spinBox.height
      width : spinBox.height
      color: "#2980b9"
      border.color: "#2980b9"
      Text {
        text: "+"
        font.pixelSize: 20
        color: "white"
        anchors.fill: parent
        fontSizeMode: Text.Fit
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
    background: Rectangle {
      implicitWidth: 140
      border.color: "#2980b9"
    }
  }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
