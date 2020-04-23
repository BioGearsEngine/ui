import QtQuick 2.12
import QtQuick.Window 2.12
import com.biogearsengine.ui.scenario 1.0


WizardDialogForm {
	id: root

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
		  var patientWizard = patientComponent.createObject(root.contentItem, {'width' : root.contentItem.width, 'height' : root.contentItem.height, 'name' : 'PatientWizard'});
			if (mode === "Edit"){
				patientWizard.mergePatientData(scenario.edit_patient())
				patientWizard.editMode = true
			}
			//Connect standard dialog buttons to patient functions
			root.saveButton.onClicked.connect(patientWizard.checkConfiguration)
			root.onHelpRequested.connect(patientWizard.showHelp)
			root.onReset.connect(patientWizard.resetConfiguration)
			root.onRejected.connect(patientWizard.destroy)
			//Notify dialog that patient is ready
			patientWizard.onPatientReady.connect(root.savePatient)
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
		console.log("Rejecting...")
	}
}
