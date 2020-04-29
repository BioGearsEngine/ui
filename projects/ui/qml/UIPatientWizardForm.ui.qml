import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12

Page {
  id : patientWizard
  anchors.fill : parent
  property alias doubleValidator : doubleValidator
  property alias fractionValidator : fractionValidator
  property alias neg1To1Validator : neg1To1Validator
  property alias patientDataModel : patientDataModel 
  property alias patientGridView : patientGridView

  GridView {
    id: patientGridView
    clip : true
    model : patientDataModel
    anchors.fill : parent
    cellHeight : parent.height / 10
    cellWidth : parent.width / 2
    ScrollIndicator.vertical: ScrollIndicator { }

    delegate : UIUnitScalarEntry {
      prefWidth : patientGridView.cellWidth * 0.9
      prefHeight : patientGridView.cellHeight * 0.95
      label : root.displayFormat(model.name)
      unit : model.unit
      type : model.type
      hintText : model.hint
      entryValidator : root.assignValidator(model.type)
      onInputAccepted : {
        root.patientData[model.name] = input
        if (model.name === "Name" && root.editMode && !nameWarningFlagged){
          root.nameChanged()
          nameWarningFlagged = true
        }
      }
      Component.onCompleted : {
        //Binds the "valid" role of each element with the validInput property of the entry, with the exception of 
        //"Name" and "Gender".  Since they are required inputs, we need to make sure they are filled.
        if (model.name === "Name"){
          model.valid = Qt.binding(function() {return (entry.userInput[0]!= null && entry.userInput[0].length > 0)})
        } else if (model.name === "Gender"){
          model.valid = Qt.binding(function() {return (entry.userInput[0]!= null && entry.userInput[0]!=-1) } )
        } else { 
          model.valid = Qt.binding(function() {return entry.validInput}) 
        }
        //Connect load function of wizard (called when opening an existing patient) to individual entries
        root.onLoadConfiguration.connect(function (patient) { setEntry (patient[model.name]) } )
        //Connect wizard reset button to entry reset functions
        root.onResetConfiguration.connect(function () { if ( root.editMode ) { setEntry(root.resetData[model.name]); } else { reset(); } } )
      }
    }
  }

  DoubleValidator {
    id : doubleValidator
    bottom : 0
  }
  DoubleValidator {
    id : fractionValidator
    bottom : 0
    top : 1.0
    decimals : 3
  }
  DoubleValidator {
    id : neg1To1Validator
    bottom : -1.0
    top : 1.0
    decimals : 3
  }

  ListModel {
    id : patientDataModel
    ListElement {name : "Name"; unit: ""; type : "string"; hint : "*Required"; valid : true}
    ListElement {name : "Gender"; unit : "gender"; type : "enum"; hint : "Select option (*Required)"; valid : true}
    ListElement {name : "Age";  unit : "time"; type : "double"; hint : "Enter value & select unit"; valid : true }
    ListElement {name : "Weight";  unit : "mass"; type : "double"; hint : "Enter value & select unit"; valid : true}
    ListElement {name : "Height";  unit : "length"; type : "double"; hint : "Enter value & select unit"; valid : true}
    ListElement {name : "BodyFatFraction";  unit : ""; type : "0To1"; hint : "Enter value in range [0,1]"; valid : true}
    ListElement {name : "BloodVolumeBaseline";  unit : "volume"; type : "double"; hint : "Enter value & select unit"; valid : true}
    ListElement {name : "BloodType";  unit : "bloodType"; type : "enum"; hint : "Select option"; valid : true}
    ListElement {name : "DiastolicArterialPressureBaseline";  unit : "pressure"; type : "double"; hint : "Enter value & select unit"; valid : true}
    ListElement {name : "SystolicArterialPressureBaseline";  unit : "pressure"; type : "double"; hint : "Enter value & select unit"; valid : true}
    ListElement {name : "HeartRateMinimum";  unit : "frequency"; type : "double"; hint : "Enter value & select unit"; valid : true}
    ListElement {name : "HeartRateMaximum";  unit : "frequency"; type : "double"; hint : "Enter value & select unit"; valid : true}
    ListElement {name : "RespirationRateBaseline";  unit : "frequency"; type : "double"; hint : "Enter value & select unit"; valid : true}
    ListElement {name : "AlveoliSurfaceArea"; unit : "area"; type : "double"; hint : "Enter value & select unit"; valid : true}
    ListElement {name : "RightLungRatio"; unit : ""; type : "0To1"; hint : "Enter value in range [0,1]"; valid : true}
    ListElement {name : "FunctionalResidualCapacity"; unit : "volume"; type : "double"; hint : "Enter value & select unit"; valid : true}
    ListElement {name : "ResidualVolume"; unit : "volume"; type : "double"; hint : "Enter value & select unit"; valid : true}
    ListElement {name : "TotalLungCapacity"; unit : "volume"; type : "double"; hint : "Enter value & select unit"; valid : true}
    ListElement {name : "SkinSurfaceArea"; unit : "area"; type : "double"; hint : "Enter value & select unit"; valid : true}
    ListElement {name : "MaxWorkRate"; unit : "power"; type : "double"; hint : "Enter value & select unit"; valid : true }
    ListElement {name : "PainSusceptibility"; unit : ""; type : "-1To1"; hint : "Enter value in range [-1,1]"; valid : true}
    ListElement {name : "Hyperhidrosis"; unit : ""; type : "-1To1"; hint : "Enter value in range [-1,1]"; valid : true}
  }
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 