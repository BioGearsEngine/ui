import QtQuick 2.12
import QtQuick.Window 2.12


UIPatientWizardForm {
	id: root

	signal dataReady (string type, var patient)
	signal patientChanged ()
	signal resetConfiguration()
	signal loadConfiguration(var patient)

	property var patientData : ({})
	property var resetData : ({})  //This will be empty strings when "new Patient", but when "edit patient" it will be file as when first loaded
	property bool editMode : false
	property var invalidEntries: ({})
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
		let validConfiguration = true
		for (let i = 0; i < patientDataModel.count; ++i){
			let validEntry = patientDataModel.get(i).valid
			if (!validEntry){
				validConfiguration = false
				let invalidField = patientDataModel.get(i).name
				if (invalidField === "Name" || invalidField === "Gender"){
					invalidPatientWarning.warningText = invalidField + " is a required field."
				} else {
					invalidPatientWarning.warningText = root.displayFormat(invalidField) + " requires both a value and a unit to be set (leave both blank to use engine defaults)";
				}
				invalidPatientWarning.open()
				break;
			}
		}
		if (validConfiguration){
			root.dataReady('Patient', patientData)  //'Patient' flag tells Wizard manager which type of data to save
		}
	}

	function mergePatientData(patient){
		for (let prop in patient){
			patientData[prop] = patient[prop]
		}
		resetData = Object.assign({}, patientData)	//Copy data to resetData ( can't do = because this does copy by reference)
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
