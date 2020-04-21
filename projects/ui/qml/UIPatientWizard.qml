import QtQuick 2.12
import QtQuick.Window 2.12


UIPatientWizardForm {
	id: root

	signal saveConfiguration ()
	signal patientReady (var patient)

	property var patientData : ({})

	onSaveConfiguration : {
		root.patientReady(patientData)
	}

	function displayFormat (role) {
		let formatted = role.replace(/([a-z])([A-Z])/g, '$1 $2')
		return formatted
	}

	Component.onCompleted : {
		for (let i = 0; i < patientDataModel.count; ++i){
			let dataObject = {[patientDataModel.get(i).name] : [null, null]}
			Object.assign(patientData, dataObject)
		}
	}

	Component.onDestruction : {
		console.log('Bye wizard')
	}

}
