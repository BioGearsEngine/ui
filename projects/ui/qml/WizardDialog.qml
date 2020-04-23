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
			activeWizard.onPatientReady.connect(root.savePatient)
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
	function launchNutrient(mode) {
		console.log(mode)
	}
	function launchECG(mode){
		console.log(mode)
	}

	function savePatient (patient){
		scenario.create_patient(patient)
		root.accept()
	}

	onRejected : {
		for (let p in activeWizard){
			console.log(p + " : " + activeWizard[p])
		}
		root.saveButton.onClicked.disconnect(activeWizard.checkConfiguration)
		root.onHelpRequested.disconnect(activeWizard.showHelp)
		root.onReset.disconnect(activeWizard.resetConfiguration)
		activeWizard.onPatientReady.disconnect(root.savePatient)
		activeWizard.destroy()
		activeWizard = null
		console.log("Rejecting...")
		for (let p in activeWizard){
			console.log(p + " : " + activeWizard[p])
		}
	}
}
