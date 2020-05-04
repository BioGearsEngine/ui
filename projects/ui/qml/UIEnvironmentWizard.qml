import QtQuick 2.12
import QtQuick.Window 2.12


UIEnvironmentWizardForm {
	id: root

	signal validConfiguration (string type, var data)
	signal invalidConfiguration(string errorStr)
	signal resetConfiguration()
	signal loadConfiguration()
	signal nameEdited()

	property var environmentData : ({})		//String and unit scalar entries
	property var ambientGasData : ({})		//Substance entries for gases in environment
	property var aerosolData : ({})				//Substance entries for aerosols in environment
	property var resetEnvironmentData : ({})  //Store data loaded in "edit" mode so that during reset we can revert to data in file
	property var resetAmbientGasData : ({})		//Store ambient gas data loaded in "edit" mode on load so that we can revert to data in file
	property var resetAerosolData : ({})			//Store ambient aerosols loaded in "edi" mode on load so that we can revert to data in file
	property bool editMode : false
	property bool nameWarningFlagged : false

	onLoadConfiguration : {
	}

	onResetConfiguration : {
	}

	function getGasList() {
		for (let sub in root.ambientGasData){
			console.log(sub + " : " + root.ambientGasData[sub])
		}
	}

	function checkConfiguration(){
	}

	function mergeEnvironmentData(environment){
		//Set name and then remove from map (so that we can loop over all components)
		/*
		let subNames = Object.keys(environment)				//Getting array directly instead of for (let key in environment) because "key" is then the index, not the sub name, which we need
		for (let i = 0; i < subNames.length; ++i){
			let sub = subNames[i]
			let componentEntry = {[sub] : environment[sub]}				//Putting [] around sub in first item tells JS to use the value of sub, not the string "sub"
			Object.assign(environmentList, componentEntry)
		}
		resetData = Object.assign({}, environmentList)	//Copy data to resetData ( can't do = because this does copy by reference
		*/
		root.loadConfiguration()
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
		} else {
			return null
		}
	}

}
