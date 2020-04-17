import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12

GridView {
  id: patientWizard
  clip : true
  model : patientDataModel //32
  anchors.fill : parent
  cellHeight : parent.height / 10
  cellWidth : parent.width / 2
  delegate : Row {
    width : cellWidth
    Label {
      width : parent.width / 2
      text : name
      font.pointSize : 8
      verticalAlignment : Text.AlignBottom
      horizontalAlignment : Text.AlignLeft
      padding : 5
    }
    TextField {
      placeholderText: "Data"
      width : parent.width / 4
      font.pointSize : 8
      verticalAlignment : Text.AlignVCenter
      horizontalAlignment : Text.AlignHCenter
    }
    ComboBox {
      width : parent.width / 4
      model : patientWizard.units[patientDataModel.get(index).unit]
      font.pointSize : 6
    }
  }

  ListModel {
    id : patientDataModel
    ListElement {name : "Name"; section : "General"}
    ListElement {name : "Gender"; section : "General"; unit : "gender"}
    ListElement {name : "Age"; section : "General"; unit : "time" }
    ListElement {name : "Weight"; section : "General"; unit : "mass"}
    ListElement {name : "Height"; section : "General"; unit : "length"}
    ListElement {name : "Body Density"; section : "General"; unit : "density"}
    ListElement {name : "Body Fat Fraction"; section : "General"; unit : "fraction"}
    ListElement {name : "Lean Body Mass"; section : "General"; unit : "mass"}
    ListElement {name : "Muscle Mass"; section : "General"; unit : "mass"}
    ListElement {name : "Blood Volume"; section : "Cardiovascular"; unit : "volume"}
    ListElement {name : "Blood Type"; section : "Cardiovascular"; unit : "bloodType"}
    ListElement {name : "Blood Volume Baseline"; section : "Cardiovascular"; unit : "volume"}
    ListElement {name : "Diastolic Arterial Pressure"; section : "Cardiovasular"; unit : "pressure"}
    ListElement {name : "Systolic Arterial Pressure"; section : "Cardiovasular"; unit : "pressure"}
    ListElement {name : "Heart Rate Minimum"; section : "Cardiovasular"; unit : "frequency"}
    ListElement {name : "Heart Rate Maximum"; section : "Cardiovasular"; unit : "frequency"}
    ListElement {name : "Respiration Rate"; section : "Respiratory"; unit : "frequency"}
    ListElement {name : "Tidal Volume"; section : "Respiratory"; unit : "volume"}
  }

  property var units : ({'mass' : ['cm', 'kg'],
                         'length' : ['in', 'm'],
                         'volume' : ['L','mL','uL'],
                         'gender' : ['F', 'M'],
                         'bloodType' : ['A+','A-','B+','B-','AB+','AB-','O+','O-'],
                         'frequency' : ['1/s', '1/min'],
                         'density' : ['g/mL','kg/m^3'],
                         'time' : ['yr', 'hr','min','s'],
                         'pressure' : ['mmHg', 'cmH2O']})
}
/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 