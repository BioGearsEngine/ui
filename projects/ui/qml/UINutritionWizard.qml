import QtQuick 2.12
import QtQuick.Window 2.12


UINutritionWizardForm {
	id: root

	signal dataReady (string type, var data)
	signal nutritionChanged (string name)
	signal resetConfiguration()
	signal loadConfiguration(var patient)

	property var nutritionData : ({})
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
		let validName = false
		if (nutritionData["Name"][0]!=null && nutritionData["Name"][0].length > 0){
			validName = true
		}
		if (validName){
			root.dataReady('Nutrition', nutritionData)
		}
		else {
			invalidNutritionWarning.open()
		}
	}

	function mergeNutritionData(nutrition){
		for (let prop in nutrition){
			nutritionData[prop] = nutrition[prop]
		}
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
