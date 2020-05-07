import QtQuick 2.12
import QtQuick.Window 2.12


UISubstanceWizardForm {
	id: root

	signal validConfiguration (string type, var data)
	signal invalidConfiguration(string errorStr)
	signal resetConfiguration()
	signal loadConfiguration(var environmentData)
	signal nameEdited()

	property var substanceData : ({})		//String and unit scalar entries (including ambient gases)nvironment
	property var resetData : ({})  //Store data loaded in "edit" mode so that during reset we can revert to data in file
	property bool editMode : false
	property bool nameWarningFlagged : false

	Component.onCompleted : {
		//Stand up object with keys corresponding to all properties (aerosol tracked separately until data processed)
		for (let i = 0; i < substanceListModel.count; ++i){
			let dataObject = {[substanceListModel.get(i).name] : [null, null]}
			Object.assign(substanceData, dataObject)
		}
		//Force layout functions here
	}

	onLoadConfiguration : {
	}

	onResetConfiguration : {
	}

	function checkConfiguration(){
		let validConfiguration = true
		let errorStr = "*"
		if (validConfiguration){
			root.validConfiguration('Substance', substanceData)  //'Substance' flag tells Wizard manager which type of data to save
		}
		else {
			if (errorStr.charAt(errorStr.length-1)==='*'){
				errorStr = errorStr.slice(0, errorStr.length-1)
			}
			root.invalidConfiguration(errorStr)
		}
	}

	function mergeSubstanceData(substance){

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
		} else if (type === "-1To1"){
			return neg1To1Validator
		} else {
			return null
		}
	}

	function setDelegateFilter(currentTab){
		let filter = ""
		switch(currentTab){
			case 0 : 
				filter = "physical"
				break;
			case 1 : 
				filter = "clearance"
				break;
			case 2 : 
				filter = "pharmacokinetics"
				break;
			case 3 : 
				filter = "pharmacodynamics"
				break;
			}
			return filter
		}

}
