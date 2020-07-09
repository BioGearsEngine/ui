import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

Rectangle {
  id: substanceEntry
  //Property aliases
  //Properties -- used to customize look and functionality of component
  property var entry : substanceEntryLoader.item
  property real prefWidth : parent.width
  property real prefHeight : substanceEntry.implicitHeight
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
        PropertyChanges {target : substanceEntry; border.color : "black"}
      }
      ,State {
        name : "editing"; when : root.entry.editing
        PropertyChanges {target : substanceEntry; border.color : "teal"}
      }
      ,State {
        name : "invalid"; when : !root.entry.editing && !root.entry.validInput
        PropertyChanges {target : substanceEntry; border.color : "red"}
      }
    ]
  
  Loader {
    id : substanceEntryLoader
    sourceComponent : root.type === "double" ? substanceUnitComponent : substanceFractionComponent
  }

  //The loader will instantiate ONE of the components defined below, depending on the input type (souble or fraction)
  //  Because only one will be in existence at once, we will not have any id collisions.  This also means that we can't
  //  alias out properties of the components to the top level. Instead, declare properties / aliases in each component
  //  with common names (userInput, editing, validInput).  The object created by Loader is stored in the "item" property 
  //  of the loader. We can therefore make valid requests to entryLoader.item.PROPERTY and get the correct prop from 
  //  the component (again, assuming common prop names).

  //The substance unit component is a combo box with a list of valid substance options, a text field for substance data
  //  (like concentration, partial pressure), and a combobox with appropriate unit options.
  Component {
    id : substanceUnitComponent
    GridLayout {
      id : substanceUnitGrid
      property var userInput: [substanceInput.currentText, scalarInput.text, unitInput.currentText]
      property bool editing : substanceInput.activeFocus || scalarInput.activeFocus || unitInput.activeFocus
      property bool validInput : (substanceInput.currentIndex > -1 && scalarInput.text.length > 0 && unitInput.currentIndex > -1)
                                  || (substanceInput.currentIndex == -1 && scalarInput.text.length == 0 && unitInput.currentIndex == -1)
      property var reset : function() {substanceInput.currentIndex = -1; scalarInput.clear(); unitInput.currentIndex = -1}
      property var setFromExisting : function (existing) {  if (existing[0]) {
                                                              substanceInput.currentIndex = substanceInput.find(existing[0])
                                                              scalarInput.text = existing[1];
                                                              unitInput.currentIndex = unitInput.find(existing[2]); } }
      property var unitModel : substanceEntry.units[unit]
      property alias substanceInput : substanceInput
      property alias componentListModel : componentListModel
      property alias scalarInput : scalarInput

      columns : 5
      rows : 2
      Layout.fillWidth : true
      Layout.fillHeight : true
      columnSpacing : 0
      rowSpacing : 0
   
      ComboBox {
        id: substanceInput
        flat : true
        Layout.preferredWidth : prefWidth * 0.8
        Layout.alignment : Qt.AlignHCenter
        Layout.row : 1
        Layout.column : 1
        Layout.columnSpan : 4
        Layout.preferredHeight : prefHeight * 0.5
        model : componentListModel
        font.pointSize : 9
        contentItem : Text {
          text : substanceInput.currentIndex == -1 ? '-Substance-' : substanceInput.editText
          font : substanceInput.font
          verticalAlignment : Text.AlignVCenter
          horizontalAlignment : Text.AlignHCenter
          leftPadding : 5
        }
        delegate : ItemDelegate {
          //Controls the look of text in the combo box menu.  
          contentItem : Text {
            text : modelData
            leftPadding: 0
            verticalAlignment : Text.AlignVCenter;
            horizontalAlignment : Text.AlignHCenter;
            font.pointSize: substanceInput.font.pointSize;
          }
          height : substanceInput.height
          width : substancePopup.width
          highlighted : substanceInput.highlightedIndex === index;
        }
        popup: Popup {
          id : substancePopup
          x: substanceInput.indicator.width
          y: substanceInput.height - 5
          width: substanceInput.width - substancePopup.x
          implicitHeight: contentItem.implicitHeight
          padding: 1
          contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: substanceInput.popup.visible ? substanceInput.delegateModel : null
            currentIndex: substanceInput.highlightedIndex
          }
          background: Rectangle {
            border.color: "grey"
            radius: 2
          }
        }
        indicator : Canvas {
          id : substanceCanvas
          x : 5
          y : 0
          width : 10
          height : substanceInput.height
          contextType : "2d"
          Connections {
            target: substanceInput
            onPressedChanged: substanceCanvas.requestPaint()
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
        ListModel {
        id : componentListModel
        }
        onActivated : {
          if (substanceUnitGrid.validInput){
            root.inputAccepted(substanceUnitGrid.userInput)
          }
        }
      }
      Image {
        id : resetButton
        Layout.row : 1
        Layout.column : 5
        Layout.columnSpan : 1
        source : "icons/reset.png"
        sourceSize.width : 15
        sourceSize.height: 15
        MouseArea {
          id : resetMouseArea
          anchors.fill : parent
          cursorShape : Qt.PointingHandCursor
          acceptedButtons : Qt.LeftButton
          hoverEnabled : true
          onClicked: {
            root.reset()
          }
        }
      }
      TextField {
        id : scalarInput
        Layout.preferredWidth : prefWidth * 0.6
        Layout.preferredHeight : prefHeight * 0.5
        Layout.columnSpan : 3
        Layout.row : 2
        Layout.column : 1
        leftPadding : 10
        topPadding : 0
        bottomPadding : 0
        placeholderText: "Concentration"
        font.pointSize : 9
        horizontalAlignment : Text.AlignHCenter
        validator : substanceEntry.entryValidator
        background : Rectangle {
          anchors.fill : parent
          color : "transparent"
          border.width : 0
        }
        onEditingFinished : {
          if (substanceUnitGrid.validInput){
            root.inputAccepted(substanceUnitGrid.userInput)
          }
        }
      }
      ComboBox {
        id : unitInput
        Layout.preferredWidth : prefWidth * 0.4
        Layout.preferredHeight : prefHeight * 0.5
        Layout.columnSpan : 2
        Layout.row : 2
        Layout.column : 4
        Layout.alignment: Qt.AlignHCenter
        model : substanceUnitGrid.unitModel
        flat : true
        font.pointSize : 9
        currentIndex : -1
        contentItem : Text {
          text : unitInput.currentIndex == -1 ? '-Unit-' : unitInput.displayText
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
          id : unitCanvas
          x : 0
          y : 0
          width : 10
          height : unitInput.height
          contextType : "2d"
          Connections {
            target: unitInput
            onPressedChanged: unitCanvas.requestPaint()
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
        onActivated : {
          if (substanceUnitGrid.validInput){
            root.inputAccepted(substanceUnitGrid.userInput)
          }
        }
      }
    }
  }

  //The substance fraction component is a combo box with a list of valid substance options and a text field for
  //  a fraction.  A validator set with top = 1 ensures that input will be bounded.  A check must be done outside
  //  this function to make sure all fractions defined in a mixture sum to 1
  Component {
    id : substanceFractionComponent
    GridLayout {
      id : substanceFractionGrid
      property var userInput: [substanceInput.currentText, scalarInput.text]
      property bool editing : substanceInput.activeFocus || scalarInput.activeFocus
      property bool validInput : (substanceInput.currentIndex > -1 && scalarInput.text.length > 0)
                                  || (substanceInput.currentIndex == -1 && scalarInput.text.length == 0)
      property var reset : function() {substanceInput.currentIndex = -1; scalarInput.clear()}
      property var setFromExisting : function (existing) {  if (existing[0]) {
                                                              substanceInput.currentIndex = substanceInput.find(existing[0])
                                                              scalarInput.text = existing[1]; } }
      property alias substanceInput : substanceInput
      property alias componentListModel : componentListModel
      property alias scalarInput : scalarInput
      Layout.fillWidth : true
      Layout.fillHeight : true
      rowSpacing : 0
      columnSpacing : 0
      rows : 2
      columns : 2
   
      Image {
        id : resetButton
        Layout.row : 1
        Layout.column : 2
        Layout.alignment : Qt.AlignRight | Qt.AlignTop
        Layout.topMargin : 5
        Layout.rightMargin : 8
        source : "icons/reset.png"
        sourceSize.width : 15
        sourceSize.height: 15
        MouseArea {
          id : resetMouseArea
          anchors.fill : parent
          cursorShape : Qt.PointingHandCursor
          acceptedButtons : Qt.LeftButton
          hoverEnabled : true
          onClicked: {
            root.reset()
          }
        }
      }  

      ComboBox {
        id: substanceInput
        flat : true
        Layout.preferredWidth : prefWidth * 0.6
        Layout.preferredHeight : prefHeight * 0.75
        Layout.alignment : Qt.AlignHCenter | Qt.AlignVCenter
        Layout.row : 2
        Layout.column : 1
        model : componentListModel
        font.pointSize : 9
        contentItem : Text {
          text : substanceInput.currentIndex == -1 ? '-Substance-' : substanceInput.editText
          font : substanceInput.font
          verticalAlignment : Text.AlignVCenter
          horizontalAlignment : Text.AlignHCenter
          leftPadding : 5
        }
        delegate : ItemDelegate {
          //Controls the look of text in the combo box menu.  
          contentItem : Text {
            text : modelData
            leftPadding: 0
            verticalAlignment : Text.AlignVCenter;
            horizontalAlignment : Text.AlignHCenter;
            font.pointSize: substanceInput.font.pointSize;
          }
          height : substanceInput.height
          width : substancePopup.width
          highlighted : substanceInput.highlightedIndex === index;
        }
        popup: Popup {
          id : substancePopup
          x: substanceInput.indicator.width
          y: substanceInput.height - 5
          width: substanceInput.width - substancePopup.x
          implicitHeight: contentItem.implicitHeight
          padding: 1
          contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: substanceInput.popup.visible ? substanceInput.delegateModel : null
            currentIndex: substanceInput.highlightedIndex
          }
          background: Rectangle {
            border.color: "grey"
            radius: 2
          }
        }
        indicator : Canvas {
          id : substanceCanvas
          x : 5
          y : 0
          width : 10
          height : substanceInput.height
          contextType : "2d"
          Connections {
            target: substanceInput
            onPressedChanged: substanceCanvas.requestPaint()
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
        ListModel {
        id : componentListModel
        }
        onActivated : {
          if (substanceFractionGrid.validInput){
            root.inputAccepted(substanceFractionGrid.userInput)
          }
        }
      }
      TextField {
        id : scalarInput
        Layout.preferredWidth : prefWidth * 0.4
        Layout.preferredHeight : prefHeight * 0.75
        Layout.alignment : Qt.AlignVCenter
        Layout.row : 2
        Layout.column : 2
        topPadding : 0
        bottomPadding : 0
        placeholderText: "Fraction"
        font.pointSize : 9
        horizontalAlignment : Text.AlignHCenter
        validator : substanceEntry.entryValidator
        background : Rectangle {
          anchors.fill : parent
          color : "transparent"
          border.width : 0
        }
        onEditingFinished : {
          if (substanceFractionGrid.validInput){
            root.inputAccepted(substanceFractionGrid.userInput)
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
                         'pressure' : ['mmHg','atm','cmH2O'],
                         'area' : ['cm^2', 'm^2'],
                         'power': ['W','kcal/s','kcal/min','kcal/hr','BTU/hr'],
                         'concentration': ['g/L', 'g/dL','g/mL', 'mg/L','mg/dL','ug/L', 'mg/m^3'] 
                         })

}


/*##^## Designer {
    D{i:0;height:25;width:200}
}
 ##^##*/
