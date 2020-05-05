import QtQuick 2.12
import QtQuick.Window 2.12


UIEnvironmentWizardForm {
	id: root

	signal validConfiguration (string type, var data)
	signal invalidConfiguration(string errorStr)
	signal resetConfiguration()
	signal loadConfiguration()
	signal nameEdited()

	property var environmentData : ({})		//String and unit scalar entries (including ambient gases)
	property var aerosolData : ({})				//Substance entries for aerosols in environment
	property var resetEnvironmentData : ({})  //Store data loaded in "edit" mode so that during reset we can revert to data in file
	property var resetAerosolData : ({})			//Store ambient aerosols loaded in "edi" mode on load so that we can revert to data in file
	property bool editMode : false
	property bool nameWarningFlagged : false

	Component.onCompleted : {
		//Stand up object with keys corresponding to all properties (aerosol tracked separately until data processed)
		for (let i = 0; i < environmentDataModel.count; ++i){
			let dataObject = {[environmentDataModel.get(i).name] : [null, null]}
			Object.assign(environmentData, dataObject)
		}
		for (let i = 0; i < ambientGasListModel.count; ++i){
			let dataObject = {[ambientGasListModel.get(i).name] : [null, null]}
			Object.assign(environmentData, dataObject)
		}
	}

	onLoadConfiguration : {
	}

	onResetConfiguration : {
	}

	function getGasList() {
		for (let sub in root.aerosolData){
			console.log(sub + " : " + root.aerosolData[sub])
		}
	}

	function checkConfiguration(){
		let validConfiguration = true
		//Check environment data (includes ambient gases)
		for (let i = 0; i < environmentDataModel.count; ++i){
			let validEntry = environmentDataModel.get(i).valid
			if (!validEntry){
				validConfiguration = false
				let errorStr = ""
				let invalidField = environmentDataModel.get(i).name
				if (invalidField === "Name"){
					errorStr = invalidField + " is a required field."
				} else {
					errorStr = root.displayFormat(invalidField) + " requires all fields to be set (or none to use engine defaults)";
				}
				root.invalidConfiguration(errorStr)
				break;
			}
		}
		//Check gas fractions
		if (!root.verifyGasFractions()){
			validConfiguration = false
			let errorStr = "Ambient gas fractions must sum to 1.0"
			root.invalidConfiguration(errorStr)
		}
		//Check aerosol list
		for (let i = 0; i < aerosolListModel.count; ++i){
				let validEntry = aerosolListModel.get(i).valid
				if (!validEntry){
					validConfiguration = false
					let errorStr = "Each component requires a substance name, concentration, and unit"
					root.invalidConfiguration(errorStr)
					break;
				}
			}
		if (validConfiguration){
			Object.assign(environmentData, aerosolData)								//Append aerosol data to environment data to export one map
			root.validConfiguration('Environment', environmentData)  //'Environment' flag tells Wizard manager which type of data to save
		}
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

	function verifyGasFractions(){
		let o2Str = environmentData["Oxygen"][0];
		let co2Str = environmentData["CarbonDioxide"][0]
		let n2Str = environmentData["Nitrogen"][0]
		let coStr = environmentData["CarbonMonoxide"][0]
		console.log(coStr)
		let o2 = (o2Str === "" || o2Str === null) ? 0 : parseFloat(o2Str)
		let co2 = (co2Str === "" || co2Str === null) ? 0 : parseFloat(co2Str)
		let n2 = (n2Str === "" || n2Str === null) ? 0 : parseFloat(n2Str)
		let co = (coStr === "" || coStr === null) ? 0 : parseFloat(coStr)
		let fractionSum = o2 + co2 + n2 + co
		console.log(o2, co2, n2, co, fractionSum)
		return fractionSum === 1.0
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
