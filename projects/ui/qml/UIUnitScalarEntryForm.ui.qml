import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

RowLayout {
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

  //Layout options
  Layout.preferredWidth : prefWidth
  Layout.preferredHeight : prefHeight

  state : "standard"

  states : [ 
      State {
        name : "standard"; when : root.validEntry() && !root.editing
        PropertyChanges {target : labelRectangle; border.color : "black"}
      }
      ,State {
        name : "editing"; when : root.editing
        PropertyChanges {target : labelRectangle; border.color : "teal"}
      }
      ,State {
        name : "invalid"; when : !root.validEntry() && !root.editing
        PropertyChanges {target : labelRectangle; border.color : "red"}
      }
    ]
  
  Rectangle {
    id : labelRectangle
    Layout.maximumWidth : scalarEntry.prefWidth * 0.75
    Layout.preferredWidth : scalarEntry.prefWidth * 0.75
    Layout.maximumHeight : scalarEntry.prefHeight
    Layout.fillHeight : true
    color : "transparent"
    border.width : 2

    Column {
      anchors.fill : parent
      spacing : 10
      Label {
        id: entryLabel
        width : parent.width
        height : (parent.height - parent.spacing) * 0.3
        text : scalarEntry.entry
        color : "black"
        font.pointSize : 7
        horizontalAlignment : Text.AlignLeft
        padding : 5
      }
      TextField {
        id : entryField
        width : parent.width
        height : (parent.height - parent.spacing) * 0.7
        Layout.alignment: Qt.AlignBottom
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
    }
  }

  ComboBox {
    id : entryUnit
    Layout.maximumWidth : scalarEntry.prefWidth * 0.25
    Layout.maximumHeight : scalarEntry.prefHeight
    Layout.fillWidth : true
    Layout.fillHeight : true
    Layout.alignment: Qt.AlignBottom
    model : scalarEntry.units[unit]
    font.pointSize : 6
    currentIndex : -1
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
