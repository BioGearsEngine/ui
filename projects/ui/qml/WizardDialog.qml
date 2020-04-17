import QtQuick 2.12
import QtQuick.Window 2.12


WizardDialogForm {
	id: root

	onAboutToShow : {
		console.log('About to show')
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
			root.onRejected.connect(patientWizard.destroy)
		}
	}

	onRejected : {
		console.log("Rejecting...")
	}
}
