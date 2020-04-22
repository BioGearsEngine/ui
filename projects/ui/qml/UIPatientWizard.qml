import QtQuick 2.12
import QtQuick.Window 2.12


UIPatientWizardForm {
	id: root

	signal patientReady (var patient)
	signal resetConfiguration()
	signal saveConfiguration()

	property var patientData : ({})

	onSaveConfiguration : {
		root.patientReady(patientData)
		root.destroy()
	}
	
	function showHelp (){
		helpDialog.open()
	}

	function displayFormat (role) {
		let formatted = role.replace(/([a-z])([A-Z])/g, '$1 $2')
		return formatted
	}

	function assignValidator (type) {
		if (type === "double"){
			console.log('double')
			return doubleValidator
		} else if (type === "0To1"){
			console.log('fraction')
			return fractionValidator
		} else if (type === "-1To1") {
			console.log('-1to1')
			return neg1To1Validator
		} else {
			return null
		}
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
