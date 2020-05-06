import QtQuick 2.12
import QtQuick.Window 2.12


UIPatientWizardForm {
	id: root

	signal validConfiguration (string type, var data)
	signal invalidConfiguration(string errorStr)
	signal resetConfiguration()
	signal loadConfiguration(var patient)
	signal nameEdited ()

	property var patientData : ({})
	property var resetData : ({})  //This will be empty strings when "new Patient", but when "edit patient" it will be file as when first loaded
	property bool editMode : false
	property var invalidEntries: ({})
	property bool nameWarningFlagged : false

	Component.onCompleted : {
		for (let i = 0; i < patientDataModel.count; ++i){
			let dataObject = {[patientDataModel.get(i).name] : [null, null]}
			Object.assign(patientData, dataObject)
		}
		patientGridView.forceLayout()	//Make sure that all fields are drawn so that when we load data from file there are complete view items to map them to
	}

	function checkConfiguration(){
		let validConfiguration = true
		let errorStr = "*"
		for (let i = 0; i < patientDataModel.count; ++i){
			let validEntry = patientDataModel.get(i).valid
			if (!validEntry){
				validConfiguration = false
				let invalidField = patientDataModel.get(i).name
				if (invalidField === "Name" || invalidField === "Gender"){
					errorStr += invalidField + " is a required field.\n*"
				} else {
					errorStr += root.displayFormat(invalidField) + " requires both value and unit (or neither to use engine defaults)\n*";
				}
			}
		}
		if (validConfiguration){
			root.validConfiguration('Patient', patientData)  //'Patient' flag tells Wizard manager which type of data to save
		} else {
			if (errorStr.charAt(errorStr.length-1)==='*'){
				errorStr = errorStr.slice(0, errorStr.length-1)
			}
			root.invalidConfiguration(errorStr)
		}
	}

	function mergePatientData(patient){
		for (let prop in patient){
			patientData[prop] = patient[prop]
		}
		resetData = Object.assign({}, patientData)	//Copy data to resetData ( can't do = because this does copy by reference)
		loadConfiguration(patientData)
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
}
