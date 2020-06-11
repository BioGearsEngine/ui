import QtQuick 2.12
import QtQuick.Window 2.12


UINutritionWizardForm {
	id: root

	signal validConfiguration (string type, var data)
	signal invalidConfiguration(string errorStr)
	signal resetConfiguration()
	signal loadConfiguration()
	signal nameEdited ()

	property var nutritionData : ({})
	property var resetData : ({})  //This will be empty strings when "new Nutrition", but when "edit Nutrition" it will be file as when first loaded
	property bool editMode : false
	property bool nameWarningFlagged : false

	Component.onCompleted : {
		for (let i = 0; i < nutritionDataModel.count; ++i){
			let dataObject = {[nutritionDataModel.get(i).name] : [null, null]}
			Object.assign(nutritionData, dataObject)
		}
		nutritionGridView.forceLayout()	//Make sure that all fields are drawn so that when we load data from file there are complete view items to map them to
	}

	function checkConfiguration(){
		let validConfiguration = true
		let errorStr = "*"
		for (let i = 0; i < nutritionDataModel.count; ++i){
			let validEntry = nutritionDataModel.get(i).valid
			if (!validEntry){
				validConfiguration = false
				let invalidField = nutritionDataModel.get(i).name
				if (invalidField === "Name"){
					errorStr += invalidField + " is a required field.\n*"
				} else {
					errorStr += root.displayFormat(invalidField) + " requires both value and unit (or neither to use engine defaults)\n*";
				}
			}
		}
		if (validConfiguration){
			root.validConfiguration('Nutrition', nutritionData)  //'nutrition' flag tells Wizard manager which type of data to save
		} else {
			if (errorStr.charAt(errorStr.length-1)==='*'){
				errorStr = errorStr.slice(0, errorStr.length-1)
			}
			root.invalidConfiguration(errorStr)
		}
	}

	function mergeNutritionData(nutrition){
		for (let prop in nutrition){
			nutritionData[prop] = nutrition[prop]
		}
		resetData = Object.assign({}, nutritionData)	//Copy data to resetData ( can't do = because this does copy by reference)
		root.loadConfiguration(nutritionData)
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
}
