import QtQuick 2.12
import QtQuick.Controls 2.12
import com.biogearsengine.ui.scenario 1.0

PatientMenuForm {
  id: root

  function loadState(fileName){
    biogears_scenario.restart(fileName)
  }

  function updateText(fileName){
    console.log(fileName)
    var split_prop = fileName.split("@")
    if (split_prop.length > 1){
      patientText.text = "Patient: " + split_prop[0] + "@" + split_prop[1].split(".")[0]
    } else {
      patientText.text = "Patient: " + split_prop[0].split(".")[0]
    }
  }

  function buildPatientMenu(){
    patientMenuListModel.clear()
    var list = biogears_scenario.get_nested_patient_state_list();
    for (var i = 0; i < list.length;++i) {
      var split_files = list[i].split(",")
      var patient_name = split_files.shift()
      var split_objects = []
      for (var k = 0;k < split_files.length;++k) {
        split_objects.push({"propName" : split_files[k]})
      }
      var menu_entry = {"patientName" : patient_name, "props" : split_objects}
      patientMenuListModel.append(menu_entry)
    }
  }

  Component.onCompleted: {
    root.loadState("DefaultMale@0s.xml")
    patientText.text = "Patient: DefaultMale@0s"
    root.buildPatientMenu()
    
  }
}
