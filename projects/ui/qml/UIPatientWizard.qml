import QtQuick 2.12
import QtQuick.Window 2.12


UIPatientWizardForm {
	id: root

	signal patientReady (var patient)
	signal resetConfiguration()
	signal saveConfiguration()
	signal loadConfiguration(var patient)

	property var patientData : ({})

	onSaveConfiguration : {
		root.patientReady(patientData)
		root.destroy()
	}
	
	function mergePatientData(patient){
		for (let prop in patient){
			patientData[prop] = patient[prop]
		}
		root.loadConfiguration(patientData)
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
			return doubleValidator
		} else if (type === "0To1"){
			return fractionValidator
		} else if (type === "-1To1") {
			return neg1To1Validator
		} else {
			return null
		}
	}

	function setPatientEntry(prop){
		let value = ''
		let unit = ''
		if (prop[0]!=null){
			value = prop[0]
		}
		if(prop[1]!=null){
			unit = prop[1]
		}
		return [value, unit]
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
