import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3
import com.biogearsengine.ui.scenario 1.0

Rectangle {
  id: substanceEntry
  //Property aliases
  //Properties -- used to customize look and functionality of component
  property var entry : substanceUnitGrid
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
    columns : 2
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
      Layout.columnSpan : 2
      Layout.preferredHeight : prefHeight * 0.5
      model : componentListModel
      font.pointSize : 9
      contentItem : Text {
        text : substanceInput.currentIndex == -1 ? '-Substance-' : substanceInput.editText
        font : substanceInput.font
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
          font.pointSize: substanceInput.font.pointSize;
          font.italic : modelData==='-Clear-'
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
        x : 0
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
      Component.onCompleted : {
        let components = scenario.get_components()
        for (let i = 0; i < components.length; ++i){
          let element = { "component" : components[i] }
          componentListModel.append(element)
        }
        componentListModel.append({"component" : "-Clear-"})
      }
      onActivated : {
        if (currentText==='-Clear-'){
          currentIndex = -1
        } else if (substanceUnitGrid.validInput){
          root.inputAccepted(substanceUnitGrid.userInput)
        }
      }
    }
    TextField {
      id : scalarInput
      Layout.preferredWidth : prefWidth * 0.6
      Layout.preferredHeight : prefHeight * 0.5
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
      Layout.preferredWidth : prefWidth * 0.3
      Layout.preferredHeight : prefHeight * 0.5
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
      Component.onCompleted : {
        //Add 'Clear' option to combo box that resets it.  Apparently Combobox binding to model is not dynamic(?),
        // or the way I set up the units prop makes it where the binding does not work.  So we push 'Clear' on to option
        // array and then reset the model.  This also requires us to reassert currentIndex = -1.  We could also
        // put 'Clear' at the end of each array in the units prop but I don't like how that looks
        substanceUnitGrid.unitModel.push('-Clear-')
        unitInput.model = substanceUnitGrid.unitModel
        unitInput.currentIndex = -1
      }
      onActivated : {
        if (currentText==='-Clear-'){
          currentIndex = -1
        } else if (substancdUnitGrid.validInput){
          root.inputAccepted(substanceUnitGrid.userInput)
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
                         'concentration': ['g/L', 'g/dL','g/mL', 'mg/L','mg/dL','ug/L'] 
                         })

}


/*##^## Designer {
    D{i:0;height:25;width:200}
}
 ##^##*/
