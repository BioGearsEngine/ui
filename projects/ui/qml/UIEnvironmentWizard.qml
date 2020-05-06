import QtQuick 2.12
import QtQuick.Window 2.12


UIEnvironmentWizardForm {
	id: root

	signal validConfiguration (string type, var data)
	signal invalidConfiguration(string errorStr)
	signal resetConfiguration()
	signal loadConfiguration(var environmentData)
	signal nameEdited()

	property var environmentData : ({})		//String and unit scalar entries (including ambient gases)
	property var aerosolData : ({})				//Substance entries for aerosols in environment
	property var resetEnvironmentData : ({})  //Store data loaded in "edit" mode so that during reset we can revert to data in file
	property var resetAerosolData : ({})			//Store ambient aerosols loaded in "edit" mode on load so that we can revert to data in file
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
		environmentGridView.forceLayout()	//Make sure that all fields are drawn so that when we load data from file there are complete view items to map them to
		ambientGasGridView.forceLayout()	//Make sure that all fields are drawn so that when we load data from file there are complete view items to map them to
	}

	onLoadConfiguration : {
		//Environment and Ambient Gas Grid view elements are already connected to this signal, but we need to set up any aerosols
		for (let aerosol in aerosolData){
			let newAerosol = {name: aerosol, unit: "concentration", type: "double", hint: "", valid: true}
      aerosolListModel.append(newAerosol)
		}
	}

	onResetConfiguration : {
		//Environment and Ambient Gas Grid view elements are already connected to this signal, but we need to set up any aerosols
		//If we are in edit mode, it's easier to wipe all the aerosol data and reset it using values cached during merge
		if (root.editMode) {
			let numNewElements = aerosolListModel.count - Object.keys(resetAerosolData).length		//How many elements were added in addition to the data from the file?
			aerosolListModel.clear()  //Clear out list model
			for (let key in aerosolData){  //Clear out data list -- would be nice if there were a "clear" function for JS arrays
				delete aerosolData[key]
			}
			//Copy contents of reset data to data list
			aerosolData = Object.assign({}, resetAerosolData);
			//Repopulate list model
			for (let aerosol in aerosolData){
				console.log(aerosol)
				let newAerosol = {name: aerosol, unit: "concentration", type: "double", hint: "", valid: true}
				aerosolListModel.append(newAerosol)
			}
			//Make blank fields corresponding to any entries added after loading data
			for (let i = 0; i < numNewElements; ++i){
				let newAerosol = {name: "", unit: "concentration", type: "double", hint: "", valid: true}
				aerosolListModel.append(newAerosol)
			}
		}
	}

	function checkConfiguration(){
		let validConfiguration = true
		let errorStr = "*"
		//Check environment base data
		for (let i = 0; i < environmentDataModel.count; ++i){
			let validEntry = environmentDataModel.get(i).valid
			if (!validEntry){
				validConfiguration = false
				let invalidField = environmentDataModel.get(i).name
				if (invalidField === "Name"){
					errorStr += invalidField + " is a required field.\n*"
				} else {
					errorStr += root.displayFormat(invalidField) + " requires all fields to be set (or none to use engine defaults)\n*";
				}
			}
		}
		//Check ambient gas data, including whether or not the fractions sum to 1
		for (let i = 0; i < ambientGasListModel.count; ++i){
			let validEntry = ambientGasListModel.get(i).valid
			console.log(validEntry)
			if (!validEntry){
				validConfiguration = false
				let invalidField = ambientGasListModel.get(i).name
				errorStr += root.displayFormat(invalidField) + " must be a value in range [0, 1] (or blank if not applicable)\n*";
			}
		}
		if (!root.verifyGasFractions()){
			validConfiguration = false
			errorStr += "Ambient gas fractions must sum to 1.0\n*"
			root.invalidConfiguration(errorStr)
		}
		//Check aerosol list
		for (let i = 0; i < aerosolListModel.count; ++i){
				let validEntry = aerosolListModel.get(i).valid
				if (!validEntry){
					validConfiguration = false
					let invalidField = aerosolListModel.get(i).name
					errorStr += invalidField + " requires all fields (or none if not applicable)\n"
					root.invalidConfiguration(errorStr)
				}
			}
		if (validConfiguration){
			Object.assign(environmentData, aerosolData)								//Append aerosol data to environment data to export one map
			root.validConfiguration('Environment', environmentData)  //'Environment' flag tells Wizard manager which type of data to save
		}
		else {
			if (errorStr.charAt(errorStr.length-1)==='*'){
				errorStr = errorStr.slice(0, errorStr.length-1)
			}
			root.invalidConfiguration(errorStr)
		}
	}

	function mergeEnvironmentData(environment){
		for (let prop in environment){
			if (prop.includes('Aerosol-')){
				let aerosolName = prop.split('-')[1]		//Result of split should be [Aerosol, SubName]
				console.log(aerosolName)
				let aerosolEntry = {[aerosolName] : environment[prop]}				//Putting [] around sub in first item tells JS to use the value of sub, not the string "sub"
				Object.assign(aerosolData, aerosolEntry)
			} else {
				environmentData[prop] = environment[prop]
			}
		}
		resetEnvironmentData = Object.assign({}, environmentData)	//Copy data to resetData ( can't do = because this does copy by reference)
		resetAerosolData = Object.assign({}, aerosolData)
		root.loadConfiguration(environmentData)
	}

	function verifyGasFractions(){
		let o2Str = environmentData["Oxygen"][0];
		let co2Str = environmentData["CarbonDioxide"][0]
		let n2Str = environmentData["Nitrogen"][0]
		let coStr = environmentData["CarbonMonoxide"][0]
		let o2 = (o2Str === "" || o2Str === null) ? 0 : parseFloat(o2Str)
		let co2 = (co2Str === "" || co2Str === null) ? 0 : parseFloat(co2Str)
		let n2 = (n2Str === "" || n2Str === null) ? 0 : parseFloat(n2Str)
		let co = (coStr === "" || coStr === null) ? 0 : parseFloat(coStr)
		let fractionSum = o2 + co2 + n2 + co
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
