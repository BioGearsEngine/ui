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

    delegate : Item {
      //Wrapping scalar entry in an item helps us center the rectangle inside the gridview cell.  If we tried to
      // anchor in center without this, every delegate instance would center itself in the middle of the view (not
      // the middle of the individual cell)
      id: delegateWrapper
      width : patientGridView.cellWidth
      height : patientGridView.cellHeight
      UIUnitScalarEntry {
        anchors.centerIn : parent
        prefWidth : patientGridView.cellWidth * 0.9
        prefHeight : patientGridView.cellHeight * 0.95
        label : root.displayFormat(model.name)
        unit : model.unit
        type : model.type
        hintText : model.hint
        entryValidator : root.assignValidator(model.type)
        function resetComponent(){
          if (root.editMode && resetData[model.name][0]!=null){
            setEntry(resetData[model.name])
            patientData[model.name] = resetData[model.name]
          } else {
            reset()
            patientData[model.name] = [null, null]
          }
        }
        function loadComponentData(){
          setEntry(patientData[model.name])
        }
        onInputAccepted : {
          root.patientData[model.name] = input
          if (model.name === "Name" && root.editMode && !nameWarningFlagged){
            root.nameEdited()
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
          root.onLoadConfiguration.connect(loadComponentData)
          //Connect wizard reset button to entry reset functions -- if we are editing an existing patient, then restore
          //the loaded value on reset.  If loaded file had no data for this field (null check), or if we are not in edit mode, then full reset
          root.onResetConfiguration.connect(resetComponent)
        }
      }
    }
  }

  DoubleValidator {
    id : doubleValidator
    bottom : 0
    decimals : 2
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
 