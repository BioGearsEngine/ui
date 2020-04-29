import QtQuick 2.12
import QtQuick.Window 2.12


UINutritionWizardForm {
	id: root

	signal dataReady (string type, var data)
	signal nutritionChanged ()
	signal resetConfiguration()
	signal loadConfiguration(var patient)

	property var nutritionData : ({})
	property var resetData : ({})  //This will be empty strings when "new Nutrition", but when "edit Nutrition" it will be file as when first loaded
	property bool editMode : false
	property bool nutritionWarningFlagged : false

	Component.onCompleted : {
		for (let i = 0; i < nutritionDataModel.count; ++i){
			let dataObject = {[nutritionDataModel.get(i).name] : [null, null]}
			Object.assign(nutritionData, dataObject)
		}
	}

	Component.onDestruction : {
		console.log('Bye wizard')
	}
	
	onNutritionChanged : {
		if (editMode && !nutritionWarningFlagged){
			nutritionChangeWarning.open()
			nutritionWarningFlagged = true
		}
	}

	function checkConfiguration(){
		let validConfiguration = true
		for (let i = 0; i < nutritionDataModel.count; ++i){
			let validEntry = nutritionDataModel.get(i).valid
			if (!validEntry){
				validConfiguration = false
				let invalidField = nutritionDataModel.get(i).name
				if (invalidField === "Name"){
					invalidNutritionWarning.warningText = invalidField + " is a required field."
				} else {
					invalidNutritionWarning.warningText = root.displayFormat(invalidField) + " requires both a value and a unit to be set (leave both blank to use engine defaults)";
				}
				invalidNutritionWarning.open()
				break;
			}
		}
		if (validConfiguration){
			root.dataReady('Nutrition', nutritionData)  //'nutrition' flag tells Wizard manager which type of data to save
		}
	}

	function mergeNutritionData(nutrition){
		for (let prop in nutrition){
			nutritionData[prop] = nutrition[prop]
		}
		resetData = Object.assign({}, nutritionData)	//Copy data to resetData ( can't do = because this does copy by reference)
		root.loadConfiguration(nutritionData)
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
		} else {
			return null
		}
	}

	function setNutritionEntry(prop){
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
