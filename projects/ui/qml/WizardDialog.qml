import QtQuick 2.12
import QtQuick.Window 2.12
import com.biogearsengine.ui.scenario 1.0


WizardDialogForm {
	id: root

	property var activeWizard;

	function launchPatient(mode){
		root.title = 'Patient Wizard'
		let patientComponent = Qt.createComponent("UIPatientWizard.qml");
		if ( patientComponent.status != Component.Ready){
		  if (patientComponent.status == Component.Error){
			  console.log("Error : " + patientComponent.errorString() );
			  return;
		  }
	    console.log("Error : Action dialog component not ready");
	  } else {
		  activeWizard = patientComponent.createObject(root.contentItem, {'width' : root.contentItem.width, 'height' : root.contentItem.height, 'name' : 'activeWizard'});
			if (mode === "Edit"){
				let patient = scenario.edit_patient()
				if (Object.keys(patient).length == 0){
					//We get an empty patient object if the user closed file explorer without selecting a patient
					activeWizard.destroy()
					return;
				} else {
					activeWizard.mergePatientData(patient)
					activeWizard.editMode = true
				}
			}
			//Connect standard dialog buttons to patient functions
			root.saveButton.onClicked.connect(activeWizard.checkConfiguration)
			root.onHelpRequested.connect(activeWizard.showHelp)
			root.onReset.connect(activeWizard.resetConfiguration)
			//Notify dialog that patient is ready
			activeWizard.onDataReady.connect(root.saveData)
			root.open()
		}
	}
	function launchEnvironment(mode){
		console.log(mode)
	}
	function launchSubstance(mode) {
		console.log(mode)
	}
	function launchCompound(mode) {
		console.log(mode)
	}
	function launchNutrition(mode) {
		root.title = 'Nutrition Wizard'
		let nutritionComponent = Qt.createComponent("UINutritionWizard.qml");
		if ( nutritionComponent.status != Component.Ready){
		  if (nutritionComponent.status == Component.Error){
			  console.log("Error : " + nutritionComponent.errorString() );
			  return;
		  }
	    console.log("Error : Action dialog component not ready");
	  } else {
		  activeWizard = nutritionComponent.createObject(root.contentItem, {'width' : root.contentItem.width, 'height' : root.contentItem.height, 'name' : 'activeWizard'});
			if (mode === "Edit"){
				let nutrition = scenario.edit_nutrition()
				if (Object.keys(nutrition).length == 0){
					//We get an empty nutrition object if the user closed file explorer without selecting a nutrition
					activeWizard.destroy()
					return;
				} else {
					activeWizard.mergeNutritionData(nutrition)
					activeWizard.editMode = true
				}
			}
			//Connect standard dialog buttons to nutrition functions
			root.saveButton.onClicked.connect(activeWizard.checkConfiguration)
			root.onHelpRequested.connect(activeWizard.showHelp)
			root.onReset.connect(activeWizard.resetConfiguration)
			//Notify dialog that nutrition is ready
			activeWizard.onDataReady.connect(root.saveData)
			root.open()
		}
	}
	function launchECG(mode){
		console.log(mode)
	}

	function saveData(type, dataMap){
		switch (type) {
			case 'Patient' : 
				scenario.create_patient(dataMap)
				break;
			case 'Nutrition':
				scenario.create_nutrition(dataMap)
				break;
			}
		root.accept()
	}

	function clearWizard(){
		root.saveButton.onClicked.disconnect(activeWizard.checkConfiguration)
		root.onHelpRequested.disconnect(activeWizard.showHelp)
		root.onReset.disconnect(activeWizard.resetConfiguration)
		activeWizard.onDataReady.disconnect(root.saveData)
		activeWizard.destroy()
		activeWizard = null
	}

	onAccepted : {
		root.clearWizard()
	}
	onRejected : {
		root.clearWizard()
	}
}
