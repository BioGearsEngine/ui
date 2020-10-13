import QtQuick 2.4
import com.biogearsengine.ui.scenario 1.0

MenuAreaForm {
  id : root
  signal newDataRequestModel(DataRequestModel requestTree)
  signal loadScenarioToBuilder(EventModel events, var requests, string sampling)

  onNewDataRequestModel : {
    root.scenarioBuilder.bgRequests = requestTree
  }
  onLoadScenarioToBuilder : {
    scenarioBuilder.loadScenario(events, requests, sampling)
  }

  function parseToolsSelection (dataType, mode){
    var biogearsTypes = {
      PATIENT : 'Patient',
      ENVIRONMENT : 'Environment',
      SUBSTANCE : 'Substance',
      COMPOUND : 'Compound',
      NUTRITION : 'Nutrition',
      ECG : 'ECG'
    }
    switch (dataType){
      case biogearsTypes.PATIENT :
        if (mode === "Export"){
          scenario.export_patient()
        } else {
          wizardDialog.launchPatient(mode)
        }
        break;
      case biogearsTypes.ENVIRONMENT :
        if (mode === "Export"){
          scenario.export_environment()
        } else {
          wizardDialog.launchEnvironment(mode)
        }
        break;
      case biogearsTypes.SUBSTANCE : 
        wizardDialog.launchSubstance(mode)
        break;
      case biogearsTypes.COMPOUND :
        wizardDialog.launchCompound(mode)
        break;
      case biogearsTypes.NUTRITION : 
        wizardDialog.launchNutrition(mode)
        break;
      case biogearsTypes.ECG : 
        wizardDialog.launchECG(mode)
        break;
    }
  }
}
