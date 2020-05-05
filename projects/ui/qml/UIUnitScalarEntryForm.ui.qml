import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

Rectangle {
  id: scalarEntry
  //Property aliases
  //Properties -- used to customize look and functionality of component
  property var entry : entryLoader.item
  property real prefWidth : parent.width
  property real prefHeight : scalarEntry.implicitHeight
  property string label : "Default"
  property string unit : ""
  property string type : ""
  property string hintText : ""
  property DoubleValidator entryValidator : null
  
  //Initial view settings
  height : prefHeight
  width : prefWidth
  color : "transparent"
  border.width : 2
  state : "standard"

  states : [ 
      State {
        name : "standard"; when : !root.entry.editing && root.entry.validInput
        PropertyChanges {target : scalarEntry; border.color : "black"}
      }
      ,State {
        name : "editing"; when : root.entry.editing
        PropertyChanges {target : scalarEntry; border.color : "teal"}
      }
      ,State {
        name : "invalid"; when : !root.entry.editing && !root.entry.validInput
        PropertyChanges {target : scalarEntry; border.color : "red"}
      }
    ]
  
  Loader {
    id : entryLoader
    sourceComponent : root.type === "double" ? scalarWithUnitComponent : (root.type === "enum" ? enumComponent : scalarStringComponent)
  }

  //The loader will instantiate ONE of the components defined below, depending on the input type (scalar w/ unit,
  //  scalar/string, or enum).  Because only one will be in existence at once, we will not have any id collisions (e.g 
  //  multiple "id : scalarEntry" declarations).  This also means that we can't alias out properties of the components.
  //  Instead, declare properties in each component with common names (userInput, editing, validInput).  The object 
  //  created by Loader is stored in the "item" property of the loader. We can therefore make valid requests to
  //  entryLoader.item.PROPERTY and get the correct prop from the component (again, assuming common prop names).

  //The enum component is a label with a combo box that holds available options.  It is applicable to fields like
  // Gender and Blood Type
  Component {
    id : enumComponent
    ColumnLayout {
      id : enumColumn
      property var userInput: [enumInput.currentIndex]
      property bool editing : enumInput.activeFocus
      property bool validInput : true   //Input will always be valid (even if no option is chosen, most data is optional).  Exception is Gender, but we handle this in PatientWizard
      property var reset : function() {enumInput.currentIndex = -1}
      property var setFromExisting : function (existing) { if(existing[0] != null) {enumInput.currentIndex = existing[0]} }
      property var enumModel : scalarEntry.units[unit]
      Layout.fillWidth : true
      Layout.fillHeight : true
      spacing : 5
      Label {
        id: enumLabel
        Layout.fillWidth : true
        Layout.preferredHeight : prefHeight * 0.3 - enumColumn.spacing / 2
        text : scalarEntry.label
        color : "black"
        font.pointSize : 8
        horizontalAlignment : Text.AlignLeft
        leftPadding : 5
        topPadding : 5
      }
      ComboBox {
        id : enumInput
        Layout.preferredWidth : prefWidth * 0.5
        Layout.preferredHeight : prefHeight * 0.7 - enumColumn.spacing / 2
        Layout.alignment: Qt.AlignHCenter
        model : enumModel
        flat : true
        font.pointSize : 9
        currentIndex : -1
        contentItem : Text {
          text : enumInput.displayText
          font : enumInput.font
          verticalAlignment : Text.AlignVCenter
          horizontalAlignment : Text.AlignHCenter
          leftPadding : enumInput.indicator.width
        }
        delegate : ItemDelegate {
          //Controls the look of text in the combo box menu.  
          contentItem : Text {
            text : modelData
            verticalAlignment : Text.AlignVCenter;
            horizontalAlignment : Text.AlignHCenter;
            leftPadding : 0
            font.pointSize: 8;
            font.italic : modelData==='-Clear-'
          }
          height : enumInput.height
          width : enumPopup.width
          highlighted : enumInput.highlightedIndex === index;
        }
        popup: Popup {
          id : enumPopup
          x: 2 * enumInput.indicator.width
          y: enumInput.height - 5
          width: enumInput.width - enumPopup.x
          implicitHeight: contentItem.implicitHeight
          padding: 1
          contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: enumInput.popup.visible ? enumInput.delegateModel : null
            currentIndex: enumInput.highlightedIndex
          }
          background: Rectangle {
            border.color: "grey"
            radius: 2
          }
        }
        indicator : Canvas {
          id : comboCanvas
          x : 5
          y : 0
          width : 10
          height : enumInput.height
          contextType : "2d"
          Connections {
              target: enumInput
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
        Component.onCompleted : {
          //Add 'Clear' option to combo box that resets it.  Apparently Combobox binding to model is not dynamic(?),
          // or the way I set up the units prop makes it where the binding does not work.  So we push 'Clear' on to option
          // array and then reset the model.  This also requires us to reassert currentIndex = -1.  We could also
          // put 'Clear' at the end of each array in the units prop but I don't like how that looks
          enumModel.push('-Clear-')
          enumInput.model = enumModel
          enumInput.currentIndex = -1
        }
        onActivated : {
          if (currentText==='-Clear-'){
            enumColumn.reset()
          } else if (validInput){
            root.inputAccepted(userInput)
          }
        }
      }
    }
  }
  //The scalarString component is a label with a simple text field.  It can accept either a string or a double (no
  //  difference to text field, all that matters is that a unit isn't required).  If a double is requested, the 
  //  validator will make sure that only numeric input is accepted.
  Component {
    id : scalarStringComponent
    ColumnLayout {
      id : scalarStringColumn
      property var userInput: [scalarInput.text]
      property bool editing : scalarInput.activeFocus
      property bool validInput : scalarInput.acceptableInput || scalarInput.text.length == 0
      property var reset : function() {scalarInput.clear()}
      property var setFromExisting : function (existing) { if (existing[0]) {scalarInput.text = existing[0]; } }
      Layout.fillWidth : true
      Layout.fillHeight : true
      spacing : 5
   
      Label {
        id: scalarLabel
        Layout.fillWidth : true
        Layout.preferredHeight : prefHeight * 0.3 - scalarStringColumn.spacing / 2
        text : scalarEntry.label
        color : "black"
        font.pointSize : 8
        horizontalAlignment : Text.AlignLeft
        leftPadding : 5
        topPadding : 5
      }
      TextField {
        id : scalarInput
        Layout.fillWidth : true
        Layout.preferredHeight : prefHeight * 0.7 - scalarStringColumn.spacing / 2
        leftPadding : 20
        topPadding : 0
        bottomPadding : 0
        placeholderText: root.hintText
        font.pointSize : 9
        horizontalAlignment : Text.AlignLeft
        validator : scalarEntry.entryValidator
        background : Rectangle {
          anchors.fill : parent
          color : "transparent"
          border.width : 0
        }
        onEditingFinished : {
          if (validInput){
            root.inputAccepted(userInput)
          }
        }
      }
    }
  }
  //The scalarWithUnit component is a label with a text field and combo box.
  Component {
    id : scalarWithUnitComponent
    GridLayout {
      id : scalarUnitGrid
      property var userInput: [scalarInput.text, unitInput.currentText]
      property bool editing : scalarInput.activeFocus || unitInput.activeFocus
      property bool validInput : (scalarInput.text.length > 0 && unitInput.currentIndex > -1)
                                  || (scalarInput.text.length == 0 && unitInput.currentIndex == -1)
      property var reset : function() {scalarInput.clear(); unitInput.currentIndex = -1}
      property var setFromExisting : function (existing) {  if (existing[0]) { scalarInput.text = existing[0];
                                                            unitInput.currentIndex = unitInput.find(existing[1]); } }
      property var unitModel : scalarEntry.units[unit]
      columns : 2
      rows : 2
      Layout.fillWidth : true
      Layout.fillHeight : true
      columnSpacing : 5
      rowSpacing : 5
   
      Label {
        id: scalarLabel
        Layout.preferredWidth : prefWidth * 0.7 - scalarUnitGrid.rowSpacing / 2
        Layout.preferredHeight : prefHeight * 0.3 - scalarUnitGrid.columnSpacing/ 2
        text : scalarEntry.label
        color : "black"
        font.pointSize : 8
        horizontalAlignment : Text.AlignLeft
        leftPadding : 5
        topPadding : 5
      }
      Label {
        id: unitLabel
        Layout.preferredWidth : prefWidth * 0.3 - scalarUnitGrid.rowSpacing / 2
        Layout.preferredHeight : prefHeight * 0.3 - scalarUnitGrid.columnSpacing / 2
        text : "Unit"
        color : "black"
        font.pointSize : 8
        horizontalAlignment : Text.AlignHCenter
        rightPadding : 10
        topPadding : 5
      }
      TextField {
        id : scalarInput
        Layout.preferredWidth : prefWidth * 0.7 - scalarUnitGrid.rowSpacing / 2
        Layout.preferredHeight : prefHeight * 0.7 - scalarUnitGrid.columnSpacing / 2
        leftPadding : 10
        topPadding : 0
        bottomPadding : 0
        placeholderText: root.hintText
        font.pointSize : 9
        horizontalAlignment : Text.AlignLeft
        validator : scalarEntry.entryValidator
        background : Rectangle {
          anchors.fill : parent
          color : "transparent"
          border.width : 0
        }
        onEditingFinished : {
          if (validInput){
            root.inputAccepted(userInput)
          }
        }
      }
      ComboBox {
        id : unitInput
        Layout.preferredWidth : prefWidth * 0.25
        Layout.preferredHeight : prefHeight * 0.7 - scalarUnitGrid.columnSpacing / 2
        Layout.alignment: Qt.AlignHCenter
        model : unitModel
        flat : true
        font.pointSize : 7
        currentIndex : -1
        contentItem : Text {
          text : unitInput.displayText
          font : unitInput.font
          verticalAlignment : Text.AlignVCenter
          horizontalAlignment : Text.AlignHCenter
        }
        delegate : ItemDelegate {
          //Controls the look of text in the combo box menu.  
          contentItem : Text {
            text : modelData
            leftPadding: 0
            verticalAlignment : Text.AlignVCenter;
            horizontalAlignment : Text.AlignHCenter;
            font.pointSize: unitInput.font.pointSize;
            font.italic : modelData==='-Clear-'
          }
          height : unitInput.height
          width : unitPopup.width
          highlighted : unitInput.highlightedIndex === index;
        }
        popup: Popup {
          id : unitPopup
          x: unitInput.indicator.width
          y: unitInput.height - 5
          width: unitInput.width - unitPopup.x
          implicitHeight: contentItem.implicitHeight
          padding: 1
          contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: unitInput.popup.visible ? unitInput.delegateModel : null
            currentIndex: unitInput.highlightedIndex
          }
          background: Rectangle {
            border.color: "grey"
            radius: 2
          }
        }
        indicator : Canvas {
          id : comboCanvas
          x : 0
          y : 0
          width : 10
          height : unitInput.height
          contextType : "2d"
          Connections {
              target: unitInput
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
        Component.onCompleted : {
          //Add 'Clear' option to combo box that resets it.  Apparently Combobox binding to model is not dynamic(?),
          // or the way I set up the units prop makes it where the binding does not work.  So we push 'Clear' on to option
          // array and then reset the model.  This also requires us to reassert currentIndex = -1.  We could also
          // put 'Clear' at the end of each array in the units prop but I don't like how that looks
          unitModel.push('-Clear-')
          unitInput.model = unitModel
          unitInput.currentIndex = -1
        }
        onActivated : {
          if (currentText==='-Clear-'){
            scalarUnitGrid.reset()
          } else if (validInput){
            root.inputAccepted(userInput)
          }
        }
      }
    }
  }


  property var units : ({'mass' : ['lb', 'kg', 'g', 'mg','ug'],
                         'massRate' : ['kg/s','g/s','g/min','g/day','mg/s','mg/min','ug/s','ug/min'],
                         'length' : ['in', 'ft', 'm', 'cm','mm','um'],
                         'volume' : ['L','mL','uL'],
                         'gender' : ['Male', 'Female'],
                         'bloodType' : ['A+','A-','B+','B-','AB+','AB-','O+','O-'],
                         'frequency' : ['1/s', '1/min', 'Hz', '1/hr'],
                         'density' : ['g/mL','kg/m^3'],
                         'time' : ['yr', 'hr','min','s'],
                         'pressure' : ['mmHg', 'cmH2O'],
                         'area' : ['cm^2', 'm^2'],
                         'power': ['W','kcal/s','kcal/min','kcal/hr','BTU/hr'],
                         'concentration': ['g/L', 'g/dL','g/mL', 'mg/L','mg/dL','ug/L'],
                         'medium' : ['Air', 'Water'],
                         'temperature' : ['C','F', 'K'],
                         'velocity' : ['m/s','cm/s','ft/s','ft/min'],
                         'clothing' : ['clo','rsi']
                         })

}


/*##^## Designer {
    D{i:0;height:25;width:200}
}
 ##^##*/
