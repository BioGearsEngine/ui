import QtQuick 2.4
import com.biogearsengine.ui.scenario 1.0

MenuAreaForm {
  id : root

  function parseToolsSelection (dataType, mode){
    var biogearsTypes = {
      PATIENT : 'Patient',
      ENVIRONMENT : 'Environment',
      SUBSTANCE : 'Substance',
      COMPOUND : 'Compound',
      NUTRIENT : 'Nutrient',
      ECG : 'ECG'
    }
    switch (dataType){
      case biogearsTypes.PATIENT :
        //Patient
        if (mode === "Export"){
          scenario.export_patient()
        } else {
          wizardDialog.launchPatient(mode)
        }
        break;
      case biogearsTypes.ENVIRONMENT : 
        //Environment
        wizardDialog.launchEnvironment(mode)
        break;
      case biogearsTypes.SUBSTANCE : 
        //Substance
        wizardDialog.launchSubstance(mode)
        break;
      case biogearsTypes.COMPOUND :
        //Compound
        wizardDialog.launchCompound(mode)
        break;
      case biogearsTypes.NUTRIENT : 
        //Nutrient
        wizardDialog.launchNutrient(mode)
        break;
      case biogearsTypes.ECG : 
        //ECG
        wizardDialog.launchECG(mode)
        break;
    }
  }

  function exportData(type){
    let simTime = Math.ceil(scenario.get_simulation_time())
    let patient = scenario.patient_name().replace(/\s+/g,'')        //Get rid of white space (not common for patient files)
    let enviro = scenario.environment_name().replace(/\s+/g,'')     //Get rid of white space (e.g. "Unknown Environment")
    switch (type) {
      case 0:
        //Export patient
        scenario.export_patient()
        break;
      case 1:
        //Export environment
        let enviroFile =  enviro + "@" + simTime + "s.xml"
        scenario.export_environment(enviroFile)
        break;
      case 2:
        //Substance
        break;
      default :
        //Export state
        let stateFile =  patient + "@" + simTime + "s.xml"
        scenario.export_state(stateFile)
        break;
    }
  }
}
