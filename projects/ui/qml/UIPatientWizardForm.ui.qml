import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12

GridView {
  id: patientWizard
  clip : true
  model : patientDataModel
  anchors.fill : parent
  cellHeight : parent.height / 10
  cellWidth : parent.width / 2
  delegate : UIUnitScalarEntry {
    prefWidth : cellWidth * 0.9
    prefHeight : cellHeight * 0.95
    labelFieldRatio : 0.7
    entry : model.name
    unit : model.unit
    textEntry : model.textEntry
  }

  ListModel {
    id : patientDataModel
    ListElement {name : "Name"; section : "General"; textEntry : true}
    ListElement {name : "Gender"; section : "General"; unit : "gender"; textEntry : false}
    ListElement {name : "Age"; section : "General"; unit : "time"; textEntry : true }
    ListElement {name : "Weight"; section : "General"; unit : "mass"; textEntry : true}
    ListElement {name : "Height"; section : "General"; unit : "length"; textEntry : true}
    ListElement {name : "Body Density"; section : "General"; unit : "density"; textEntry : true}
    ListElement {name : "Body Fat Fraction"; section : "General"; unit : "fraction"; textEntry : true}
    ListElement {name : "Lean Body Mass"; section : "General"; unit : "mass"; textEntry : true}
    ListElement {name : "Muscle Mass"; section : "General"; unit : "mass"; textEntry : true}
    ListElement {name : "Blood Volume"; section : "Cardiovascular"; unit : "volume"; textEntry : true}
    ListElement {name : "Blood Type"; section : "Cardiovascular"; unit : "bloodType"; textEntry : false}
    ListElement {name : "Diastolic Pressure"; section : "Cardiovasular"; unit : "pressure"; textEntry : true}
    ListElement {name : "Systolic Pressure"; section : "Cardiovasular"; unit : "pressure"; textEntry : true}
    ListElement {name : "Heart Rate Minimum"; section : "Cardiovasular"; unit : "frequency"; textEntry : true}
    ListElement {name : "Heart Rate Maximum"; section : "Cardiovasular"; unit : "frequency"; textEntry : true}
    ListElement {name : "Respiration Rate"; section : "Respiratory"; unit : "frequency"; textEntry : true}
    ListElement {name : "Tidal Volume"; section : "Respiratory"; unit : "volume"; textEntry : true}
  }

}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 