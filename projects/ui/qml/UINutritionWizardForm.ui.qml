import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12

Page {
  id : nutritionWizard
  anchors.fill : parent
  property alias doubleValidator : doubleValidator
  property alias nutritionDataModel : nutritionDataModel 
  property alias helpDialog : helpDialog
  property alias nutritionChangeWarning : nutritionChangeWarning
  property alias invalidNutritionWarning : invalidNutritionWarning
  property alias nutritionGridView : nutritionGridView

  GridView {
    id: nutritionGridView
    clip : true
    model : nutritionDataModel
    anchors.fill : parent
    cellHeight : parent.height / 10
    cellWidth : parent.width / 2
    ScrollIndicator.vertical: ScrollIndicator { }

    delegate : UIUnitScalarEntry {
      prefWidth : nutritionGridView.cellWidth * 0.9
      prefHeight : nutritionGridView.cellHeight * 0.95
      label : root.displayFormat(model.name)
      unit : model.unit
      type : model.type
      hintText : model.hint
      entryValidator : root.assignValidator(model.type)
      onInputAccepted : {
        root.nutritionData[model.name] = input
        if (model.name === "Name"){
          root.nutritionChanged()
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
        //Connect wizard reset button to entry reset functions
        root.onResetConfiguration.connect(function () { if ( root.editMode ) { setEntry(root.resetData[model.name]); } else { reset(); } } )
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

  Dialog {
    id : helpDialog
    modal : true
    closePolicy : Popup.NoAutoClose
    width : parent.width / 2
    height : parent.height / 3
    anchors.centerIn : parent
    header : Rectangle {
      id : helpHeader
      width : parent.width
      height : parent.height * 0.1
      color: "#1A5276"
      Text {
        id: helpHeaderText
        anchors.fill : parent
        text: "nutrition Setup Help"
		    font.pointSize : 10
        leftPadding : 10
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
    footer : DialogButtonBox {
      id : helpFooter
      Button {
        text : "Ok"
        DialogButtonBox.buttonRole : DialogButtonBox.AcceptRole
      }
    }
    contentItem : Rectangle {
      id : helpMainContent
      color : "transparent"
		  anchors.left : parent.left;
		  anchors.right : parent.right;
      anchors.top : helpHeader.bottom
      anchors.bottom : helpFooter.top
      Text {
        id : helpText
        anchors.fill : parent
        wrapMode : Text.WordWrap
        text : "--Nutrition name is required field.  All other fields are optional and will be set to 0 if not defined."
      }
    }
  }

  Dialog {
    id : nutritionChangeWarning
    modal : true
    closePolicy : Popup.NoAutoClose
    width : parent.width / 2
    height : parent.height / 4
    anchors.centerIn : parent
    header : Rectangle {
      id : nutritionChangeHeader
      width : parent.width
      height : parent.height * 0.15
      color: "#1A5276"
      Text {
        id: nutritionChangeHeaderText
        anchors.fill : parent
        text: "Warning"
		    font.pointSize : 10
        leftPadding : 10
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
    footer : DialogButtonBox {
      id : nutritionChangeFooter
      Button {
        text : "Ok"
        DialogButtonBox.buttonRole : DialogButtonBox.AcceptRole
      }
    }
    contentItem : Rectangle {
      id : nutritionChangeMainContent
      color : "transparent"
		  anchors.left : parent.left;
		  anchors.right : parent.right;
      anchors.top : nutritionChangeHeader.bottom
      anchors.bottom : nutritionChangeFooter.top
      Text {
        id : nutritionChangeText
        anchors.fill : parent
        wrapMode : Text.WordWrap
        text : "Changing the Nutrition name will change the file name under which data will be saved." 
      }
    }
    onAccepted : {
      close();
    }
  }

  Dialog {
    id : invalidNutritionWarning
    modal : true
    closePolicy : Popup.NoAutoClose
    width : parent.width / 2
    height : parent.height / 6
    anchors.centerIn : parent
    property string warningText : ""
    header : Rectangle {
      id : invalidNutritionHeader
      width : parent.width
      height : parent.height * 0.2
      color: "#1A5276"
      Text {
        id: invalidNutritionHeaderText
        anchors.fill : parent
        text: "Warning: Invalid configuration"
		    font.pointSize : 10
        leftPadding : 10
        color: "white"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
    footer : DialogButtonBox {
      id : invalidNutritionFooter
      Button {
        text : "Ok"
        DialogButtonBox.buttonRole : DialogButtonBox.AcceptRole
      }
    }
    contentItem : Rectangle {
      id : invalidNutritionMainContent
      color : "transparent"
		  anchors.left : parent.left;
		  anchors.right : parent.right;
      anchors.top : invalidNutritionHeader.bottom
      anchors.bottom : invalidNutritionFooter.top
      Text {
        id : invalidNutritionText
        anchors.fill : parent
        wrapMode : Text.WordWrap
        text : invalidNutritionWarning.warningText 
      }
    }
    onAccepted : {
      close();
    }
  }
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 