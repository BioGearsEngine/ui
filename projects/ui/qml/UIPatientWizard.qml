import QtQuick 2.12
import QtQuick.Window 2.12


UIPatientWizardForm {
	id: root

	signal patientReady (var patient)
	signal patientChanged (string name)
	signal resetConfiguration()
	signal loadConfiguration(var patient)

	property var patientData : ({})
	property bool editMode : false
	property bool patientWarningFlagged : false

	Component.onCompleted : {
		for (let i = 0; i < patientDataModel.count; ++i){
			let dataObject = {[patientDataModel.get(i).name] : [null, null]}
			Object.assign(patientData, dataObject)
		}
	}

	Component.onDestruction : {
		console.log('Bye wizard')
	}
	
	onPatientChanged : {
		if (editMode && !patientWarningFlagged){
			patientChangeWarning.open()
			patientWarningFlagged = true
		}
	}

	function checkConfiguration(){
		let validName = false
		let validGender = false
		if (patientData["Name"][0]!=null && patientData["Name"][0].length > 0){
			validName = true
		}
		if (patientData["Gender"][0]!= null && patientData["Gender"][0]!=-1){
			validGender = true
		}
		if (validName && validGender){
			root.patientReady(patientData)
		}
		else {
			invalidPatientWarning.open()
		}
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



}
