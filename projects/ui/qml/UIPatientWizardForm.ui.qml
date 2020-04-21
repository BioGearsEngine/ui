import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12


GridView {
  id: patientWizard
  property alias doubleValidator : doubleValidator
  property alias patientDataModel : patientDataModel 

  clip : true
  model : patientDataModel
  anchors.fill : parent
  cellHeight : parent.height / 10
  cellWidth : parent.width / 2
  
  delegate : UIUnitScalarEntry {
    prefWidth : cellWidth * 0.9
    prefHeight : cellHeight * 0.95
    entry : root.displayFormat(model.name)
    unit : model.unit
    type : model.type
    entryValidator : entry == "Name" ? null : patientWizard.doubleValidator
    onEntryUpdated : {
      root.patientData[model.name] = [value, unit]
      for (let p in patientData){
        console.log(p + ": " + patientData[p])
      }
    }
  }

  DoubleValidator {
    id : doubleValidator
    bottom : 0
    decimals : 2
  }

  ListModel {
    id : patientDataModel
    ListElement {name : "Name"; type : "string"}
    ListElement {name : "Gender"; unit : "gender"; type : "enum"}
    ListElement {name : "Age";  unit : "time"; type : "double" }
    ListElement {name : "Weight";  unit : "mass"; type : "double"}
    ListElement {name : "Height";  unit : "length"; type : "double"}
    ListElement {name : "BodyFatFraction";  unit : "fraction"; type : "double"}
    ListElement {name : "BloodVolumeBaseline";  unit : "volume"; type : "double"}
    ListElement {name : "BloodType";  unit : "bloodType"; type : "enum"}
    ListElement {name : "DiastolicArterialPressureBaseline";  unit : "pressure"; type : "double"}
    ListElement {name : "SystolicArterialPressureBaseline";  unit : "pressure"; type : "double"}
    ListElement {name : "HeartRateMinimum";  unit : "frequency"; type : "double"}
    ListElement {name : "HeartRateMaximum";  unit : "frequency"; type : "double"}
    ListElement {name : "RespirationRateBaseline";  unit : "frequency"; type : "double"}
    ListElement {name : "AlveoliSurfaceArea"; unit : "area"; type : "double"}
    ListElement {name : "RightLungRatio"; unit : "fraction"; type : "double"}
    ListElement {name : "FunctionalResidualCapacity"; unit : "volume"; type : "double"}
    ListElement {name : "ResidualVolume"; unit : "volume"; type : "double"}
    ListElement {name : "TotalLungCapacity"; unit : "volume"; type : "double"}
    ListElement {name : "SkinSurfaceArea"; unit : "area"; type : "double"}
    ListElement {name : "PainSusceptibility"; unit : "-1To1"; type : "double"}
    ListElement {name : "Hyperhidrosis"; unit : "-1To1"; type : "double"}
  }

}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 