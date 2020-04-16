import QtQuick 2.4
import com.biogearsengine.ui.scenario 1.0

MenuAreaForm {
  id : root
  signal stateLoadedFromMenu()

  saveAsDialog.onAccepted : {
    if (saveAsDialog.fileUrl){
      scenario.save_state(saveAsDialog.fileUrl)
    } else {
      console.log('Error: File dialog did not return a path')
    }
  }
  
  openDialog.onAccepted : {
    if (openDialog.fileUrl) {
      scenario.restart(openDialog.fileUrl)
      root.stateLoadedFromMenu()
    } else {
      console.log('Error: File dialog did not return a path');
    }
  }

  function exportData(type){
    let simTime = Math.ceil(scenario.get_simulation_time())
    let patient = scenario.patient_name().replace(/\s+/g,'')        //Get rid of white space (not common for patient files)
    let enviro = scenario.environment_name().replace(/\s+/g,'')     //Get rid of white space (e.g. "Unknown Environment")
    switch (type) {
      case 0:
        //Export state
        let stateFile =  patient + "@" + simTime + "s.xml"
        scenario.export_state(stateFile)
        break;
      case 1:
        //Export patient
        let patientFile =  patient + "@" + simTime + "s.xml"
        scenario.export_patient(patientFile)
        break;
      case 2:
        //Export environment
        let enviroFile =  enviro + "@" + simTime + "s.xml"
        scenario.export_environment(enviroFile)
        break;
    }
  }

}
