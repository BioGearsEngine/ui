import QtQuick 2.12
import QtQuick.Window 2.12


UICompoundWizardForm {
	id: root

	signal validConfiguration (string type, var data)
	signal invalidConfiguration(string errorStr)
	signal resetConfiguration()
	signal loadConfiguration(var patient)

	property string name : ""			//Store name separate from list of compounds (easier to loop through compounds in Scenario.cpp)
	property var compoundList : ({})
	property var resetData : ({})  //This will be empty strings when "new Compound", but when "edit Compound" it will be file as when first loaded
	property bool editMode : false
	property bool nameWarningFlagged : false

	Component.onDestruction : {
		console.log('Bye wizard')
	}
	
	function checkConfiguration(){
		let validConfiguration = true
		/*for (let i = 0; i < compoundDataModel.count; ++i){
			let validEntry = compoundDataModel.get(i).valid
			if (!validEntry){
				validConfiguration = false
				let errorStr = ""
				let invalidField = compoundDataModel.get(i).name
				if (invalidField === "Name"){
					errorStr = invalidField + " is a required field."
				} else {
					errorStr = root.displayFormat(invalidField) + " requires both a value and a unit to be set (leave both blank to use engine defaults)";
				}
				root.invalidConfiguration(errorStr)
				break;
			}
		}
		if (validConfiguration){
			root.validConfiguration('compound', compoundData)  //'compound' flag tells Wizard manager which type of data to save
		}*/
	}

	function mergeCompoundData(compound){
		/*for (let prop in compound){
			compoundData[prop] = compound[prop]
		}
		resetData = Object.assign({}, compoundData)	//Copy data to resetData ( can't do = because this does copy by reference)
		root.loadConfiguration(compoundData)*/
	}

	function displayFormat (role) {
		let formatted = role.replace(/([a-z])([A-Z])/g, '$1 $2')
		return formatted
	}

	function assignValidator (type) {
		if (type === "double"){
			return doubleValidator
		} else {
			return null
		}
	}

	function setCompoundEntry(prop){
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
