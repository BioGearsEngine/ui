import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12

Page {
  id : compoundWizard
  anchors.fill : parent
  property alias doubleValidator : doubleValidator
  property alias compoundDataModel : compoundDataModel 
  property alias compoundGridView : compoundGridView
  property alias addComponent : addComponentButton

  GridView {
    id: compoundGridView
    clip : true
    model : compoundDataModel
    anchors.top : parent.top
    anchors.left : parent.left
    anchors.right : parent.right
    anchors.bottom : addComponentButton.top
    
   // anchors.fill : parent
    cellHeight : parent.height / 10
    cellWidth : parent.width / 2
    ScrollIndicator.vertical: ScrollIndicator { }

    delegate : UIUnitScalarEntry {
      prefWidth : compoundGridView.cellWidth * 0.9
      prefHeight : compoundGridView.cellHeight * 0.95
      //label : root.displayFormat(model.name)
      unit : model.unit
      type : model.type
      hintText : model.hint
      //entryValidator : root.assignValidator(model.type)
      onInputAccepted : {
        root.compoundData[model.name] = input
        if (model.name === "Name" && root.editMode && !nameWarningFlagged){
          root.nameChanged()
          nameWarningFlagged = true
        }
      }
      Component.onCompleted : {
        //Binds the "valid" role of each element with the validInput property of the entry, with the exception of 
        //"Name".  Since Name is a required input, we need to make sure it is filled.
        if (model.name === "Name"){
          model.valid = Qt.binding(function() {return (entry.userInput[0]!= null && entry.userInput[0].length > 0)})
        } else { 
          model.valid = Qt.binding(function() {return entry.validInput}) 
        }
        //Connect load function of wizard (called when opening an existing compound file) to individual entries
        root.onLoadConfiguration.connect(function (compound) { setEntry (compound[model.name]) } )
        //Connect wizard reset button to entry reset functions
        root.onResetConfiguration.connect(function () { if ( root.editMode ) { setEntry(root.resetData[model.name]); } else { reset(); } } )
      }
    }
  }

  Button {
    id : addComponentButton
    width : parent.width / 4
    height : 60
    text : "Add Component"
    anchors.bottom : parent.bottom
    onClicked : {
      let newComponent = {name: "Component", unit: "concentration", type: "double", hint: "", valid: true}
      compoundDataModel.append(newComponent)
    }
  }

  DoubleValidator {
    id : doubleValidator
    bottom : 0
  }

  ListModel {
    id : compoundDataModel
    ListElement {name : "Name"; unit: ""; type : "string"; hint : "*Required"; valid : true}
  }
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 