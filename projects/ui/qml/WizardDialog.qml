import QtQuick 2.12
import QtQuick.Window 2.12
import com.biogearsengine.ui.scenario 1.0


WizardDialogForm {
	id: root

	onAboutToShow : {
		let patientComponent = Qt.createComponent("UIPatientWizard.qml");
	  if ( patientComponent.status != Component.Ready){
		  if (patientComponent.status == Component.Error){
			  console.log("Error : " + patientComponent.errorString() );
			  return;
		  }
	    console.log("Error : Action dialog component not ready");
	  } else {
		  var patientWizard = patientComponent.createObject(root.contentItem, {'width' : root.contentItem.width, 'height' : root.contentItem.height, 'name' : 'PatientWizard'});
			root.title = 'Patient Wizard'
			root.onAccepted.connect(patientWizard.saveConfiguration)
			root.onHelpRequested.connect(patientWizard.showHelp)
			root.onReset.connect(patientWizard.resetConfiguration)
			patientWizard.onPatientReady.connect(root.savePatient)
			root.onRejected.connect(patientWizard.destroy)
		}
	}

	function savePatient (patient){
		scenario.new_patient(patient)
		//for (let p in patient){
		//	console.log(p + ": " + patient[p])
    //}

	}

	onRejected : {
		console.log("Rejecting...")
	}
}
