import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12

Page {
  id : nutritionWizard
  anchors.fill : parent
  property alias doubleValidator : doubleValidator
  property alias nutritionDataModel : nutritionDataModel 
  property alias nutritionGridView : nutritionGridView

  GridView {
    id: nutritionGridView
    clip : true
    model : nutritionDataModel
    anchors.fill : parent
    cellHeight : parent.height / 10
    cellWidth : parent.width / 2
    ScrollIndicator.vertical: ScrollIndicator { }

    delegate : Item {
      //Wrapping scalar entry in an item helps us center the rectangle inside the gridview cell.  If we tried to
      // anchor in center without this, every delegate instance would center itself in the middle of the view (not
      // the middle of the individual cell)
      id: delegateWrapper
      width : nutritionGridView.cellWidth
      height : nutritionGridView.cellHeight
      UIUnitScalarEntry {
        anchors.centerIn : parent
        prefWidth : nutritionGridView.cellWidth * 0.9
        prefHeight : nutritionGridView.cellHeight * 0.95
        label : root.displayFormat(model.name)
        unit : model.unit
        type : model.type
        hintText : model.hint
        entryValidator : root.assignValidator(model.type)
        onInputAccepted : {
          root.nutritionData[model.name] = input
          if (model.name === "Name" && root.editMode && !nameWarningFlagged){
            root.nameEdited()
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
          //Connect load function of wizard (called when opening an existing nutrition file) to individual entries
          root.onLoadConfiguration.connect(function (nutrition) { setEntry (nutrition[model.name]) } )
          //Connect wizard reset button to entry reset functions -- if we are editing an existing nutrition file, then restore
          //the loaded value on reset.  If loaded file had no data for this field (null check), or if we are not in edit mode, then full reset
          root.onResetConfiguration.connect(function () { if ( root.editMode && resetData[model.name][0]!=null) { setEntry(root.resetData[model.name]); } else { reset(); } } )
        }
      }
    }
  }

  DoubleValidator {
    id : doubleValidator
    bottom : 0
  }

  ListModel {
    id : nutritionDataModel
    ListElement {name : "Name"; unit: ""; type : "string"; hint : "*Required"; valid : true}
    ListElement {name : "Carbohydrate"; unit : "mass"; type : "double"; hint : "Mass of carbs to ingest"; valid : true}
    ListElement {name : "CarbohydrateDigestionRate";  unit : "massRate"; type : "double"; hint : "Carb absorption rate in GI"; valid : true }
    ListElement {name : "Protein"; unit : "mass"; type : "double"; hint : "Mass of protein to ingest"; valid : true}
    ListElement {name : "ProteinDigestionRate";  unit : "massRate"; type : "double"; hint : "Protein absorption rate in GI"; valid : true }
    ListElement {name : "Fat"; unit : "mass"; type : "double"; hint : "Mass of fat to ingest"; valid : true}
    ListElement {name : "FatDigestionRate";  unit : "massRate"; type : "double"; hint : "Fat absorption rate in GI"; valid : true }
    ListElement {name : "Calcium";  unit : "mass"; type : "double"; hint : "Amount of calcium to ingest"; valid : true}
    ListElement {name : "Sodium";  unit : "mass"; type : "double"; hint : "Amount of protein to ingest"; valid : true}
    ListElement {name : "Water";  unit : "volume"; type : "double"; hint : "Amount of water to ingest"; valid : true}
  }
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 