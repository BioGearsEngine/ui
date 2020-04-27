import QtQuick 2.12
import QtQuick.Controls 2.12
import com.biogearsengine.ui.scenario 1.0

PatientMenuForm {
  id: root
  
  function newState(baseName, fileName){
    //If base name is in List Model, add file name to sub menu
    let existingGroup = false;
    for (let index = 0; index < patientMenuListModel.count; ++index){
      let patient = patientMenuListModel.get(index).patientName
      if (baseName.includes(patient)){
        //Found the right patient, now add file to sub menu
        let patientSubMenu = patientMenuListModel.get(index).props
        patientSubMenu.append({"propName" : fileName})
        existingGroup = true
        break;
      }
    }
    if(!existingGroup){
      let subMenu = {"propName" : fileName};
      let newGroup = {"patientName" : baseName, "props" : subMenu}
      patientMenuListModel.append(newGroup)
    }
  }

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

  Component.onCompleted: {
    patientMenu.loadState("DefaultMale@0s.xml")
    patientText.text = "Patient: DefaultMale@0s"
    var list = biogears_scenario.get_nested_patient_state_list();
    var nlist = []
    for (var i = 0;i < list.length;++i) {
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
}
