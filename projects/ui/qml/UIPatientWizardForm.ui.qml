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
    entry : model.name
    unit : model.unit
    textEntry : model.textEntry
    entryValidator : entry == "Name" ? null : patientWizard.doubleValidator
    onEntryUpdated : {
      model.currentValue = value
      model.currentUnit = unit
      console.log(model.currentValue, model.currentUnit)
    }
  }

  DoubleValidator {
    id : doubleValidator
    bottom : 0
    decimals : 2
  }


  ListModel {
    id : patientDataModel
    ListElement {name : "Name"; textEntry : true; currentValue : ""; currentUnit : ""}
    ListElement {name : "Gender"; unit : "gender"; textEntry : false; currentValue : ""; currentUnit : ""}
    ListElement {name : "Age";  unit : "time"; textEntry : true; currentValue : ""; currentUnit : "" }
    ListElement {name : "Weight";  unit : "mass"; textEntry : true; currentValue : ""; currentUnit : ""}
    ListElement {name : "Height";  unit : "length"; textEntry : true; currentValue : ""; currentUnit : ""}
    ListElement {name : "Body Density";  unit : "density"; textEntry : true; currentValue : ""; currentUnit : ""}
    ListElement {name : "Body Fat Fraction";  unit : "fraction"; textEntry : true; currentValue : ""; currentUnit : ""}
    ListElement {name : "Lean Body Mass";  unit : "mass"; textEntry : true; currentValue : ""; currentUnit : ""}
    ListElement {name : "Muscle Mass";  unit : "mass"; textEntry : true; currentValue : ""; currentUnit : ""}
    ListElement {name : "Blood Volume";  unit : "volume"; textEntry : true; currentValue : ""; currentUnit : ""}
    ListElement {name : "Blood Type";  unit : "bloodType"; textEntry : false; currentValue : ""; currentUnit : ""}
    ListElement {name : "Diastolic Pressure";  unit : "pressure"; textEntry : true; currentValue : ""; currentUnit : ""}
    ListElement {name : "Systolic Pressure";  unit : "pressure"; textEntry : true; currentValue : ""; currentUnit : ""}
    ListElement {name : "Heart Rate Minimum";  unit : "frequency"; textEntry : true; currentValue : ""; currentUnit : ""}
    ListElement {name : "Heart Rate Maximum";  unit : "frequency"; textEntry : true; currentValue : ""; currentUnit : ""}
    ListElement {name : "Respiration Rate";  unit : "frequency"; textEntry : true; currentValue : ""; currentUnit : ""}
    ListElement {name : "Tidal Volume"; unit : "volume"; textEntry : true; currentValue : ""; currentUnit : ""}
  }

}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 