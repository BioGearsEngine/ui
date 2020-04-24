import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

Rectangle {
  id: scalarEntry
  //Properties -- used to customize look and functionality of component
  property real prefWidth : parent.width
  property real prefHeight : scalarEntry.implicitHeight
  property string entry : "Default"
  property string unit : ""
  property string type : ""
  property string hintText : ""
  property DoubleValidator entryValidator : null
  property bool editing : entryField.activeFocus || entryUnit.activeFocus
  //Property aliases
  property alias entryLabel : entryLabel
  property alias entryField : entryField
  property alias entryUnit : entryUnit
  //Initial view settings
  height : prefHeight
  width : prefWidth
  color : "transparent"
  border.width : 2
  state : "standard"

  states : [ 
      State {
        name : "standard"; when : root.validEntry() && !root.editing
        PropertyChanges {target : scalarEntry; border.color : "black"}
      }
      ,State {
        name : "editing"; when : root.editing
        PropertyChanges {target : scalarEntry; border.color : "teal"}
      }
      ,State {
        name : "invalid"; when : !root.validEntry() && !root.editing
        PropertyChanges {target : scalarEntry; border.color : "red"}
      }
    ]
  
  GridLayout {
    id : entryGrid
    columns : 2
    rows : 2
    Layout.fillWidth : true
    Layout.fillHeight : true
    columnSpacing : 5
    rowSpacing : 5

    Label {
      id: entryLabel
      Layout.preferredWidth : prefWidth * 0.7 - entryGrid.rowSpacing / 2
      Layout.preferredHeight : prefHeight * 0.3 - entryGrid.columnSpacing/ 2
      text : scalarEntry.entry
      color : "black"
      font.pointSize : 8
      horizontalAlignment : Text.AlignLeft
      leftPadding : 5
      topPadding : 5
    }
    Label {
      Layout.preferredWidth : prefWidth * 0.3 - entryGrid.rowSpacing / 2
      Layout.preferredHeight : prefHeight * 0.3 - entryGrid.columnSpacing / 2
      text : "Unit"
      color : "black"
      font.pointSize : 8
      horizontalAlignment : Text.AlignHCenter
      rightPadding : 10
      topPadding : 5
    }
    TextField {
      id : entryField
      Layout.preferredWidth : prefWidth * 0.7 - entryGrid.rowSpacing / 2
      Layout.preferredHeight : prefHeight * 0.7 - entryGrid.columnSpacing / 2
      leftPadding : 10
      topPadding : 0
      bottomPadding : 0
      placeholderText: root.hintText
      readOnly : root.type === "enum"
      font.pointSize : 9
      horizontalAlignment : Text.AlignLeft
      validator : scalarEntry.entryValidator
      background : Rectangle {
        anchors.fill : parent
        color : "transparent"
        border.width : 0
      }
    }
    ComboBox {
      id : entryUnit
      Layout.preferredWidth : prefWidth * 0.25
      Layout.preferredHeight : prefHeight * 0.7 - entryGrid.columnSpacing / 2
      Layout.alignment: Qt.AlignHCenter
      model : scalarEntry.units[unit]
      flat : true
      font.pointSize : 7
      currentIndex : -1
      contentItem : Text {
        text : entryUnit.displayText
        font : entryUnit.font
        verticalAlignment : Text.AlignVCenter
        horizontalAlignment : Text.AlignHCenter
      }
      indicator : Canvas {
        id : comboCanvas
        x : 0
        y : 0
        width : 10
        height : entryUnit.height
        contextType : "2d"
        Connections {
            target: entryUnit
            onPressedChanged: comboCanvas.requestPaint()
        }
        onPaint: {
            context.reset();
            context.moveTo(0, height / 2);
            context.lineTo(width, height / 2);
            context.lineTo(width / 2, 2 * height / 3);
            context.closePath();
            context.fillStyle = "black";
            context.fill();
        }
      }
    }
  }

  property var units : ({'mass' : ['lb', 'kg', 'g', 'mg','ug'],
                         'length' : ['in', 'ft', 'm', 'cm','mm','um'],
                         'volume' : ['L','mL','uL'],
                         'gender' : ['M', 'F'],
                         'bloodType' : ['A+','A-','B+','B-','AB+','AB-','O+','O-'],
                         'frequency' : ['1/s', '1/min', 'Hz', '1/hr'],
                         'density' : ['g/mL','kg/m^3'],
                         'time' : ['yr', 'hr','min','s'],
                         'pressure' : ['mmHg', 'cmH2O'],
                         'area' : ['cm^2', 'm^2'],
                         'power': ['W','kcal/s','kcal/min','kcal/hr','BTU/hr']})

}


/*##^## Designer {
    D{i:0;height:25;width:200}
}
 ##^##*/
