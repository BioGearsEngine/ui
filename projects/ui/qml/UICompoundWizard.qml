import QtQuick 2.12
import QtQuick.Window 2.12


UICompoundWizardForm {
	id: root

	signal validConfiguration (string type, var data)
	signal invalidConfiguration(string errorStr)
	signal resetConfiguration()
	signal loadConfiguration()
	signal nameEdited()

	property string compoundName : ""			//Store name separate from list of compounds
	property var compoundList : ({})
	property var resetData : ({})  //This will be empty strings when "new Compound", but when "edit Compound" it will be file as when first loaded
	property string resetName : ""	//Holds the compound name in "Edit" mode in case we revert changes.  Store separtely from component data because it makes it easier to operate by looping over components
	property bool editMode : false
	property bool nameWarningFlagged : false

	onLoadConfiguration : {
		//Component fields do not exist yet when loading compound from file, so we have to add them to ListModel as we encounter them
		for (let sub in compoundList){
			let newComponent = {name: sub, unit: "concentration", type: "double", hint: "", valid: true}
      compoundDataModel.append(newComponent)
		}
	}

	onResetConfiguration : {
		//If we are in edit mode, it's easier to wipe all the data and reset it from the merge info than to adjust on an 
		// element by element basis
		if (root.editMode) {
			let numNewElements = compoundDataModel.count - Object.keys(root.resetData).length		//How many elements were added in addition to the data from the file?
			console.log(numNewElements)
			compoundDataModel.clear()  //Clear out list model
			for (let key in compoundList){  //Clear out data list -- would be nice if there were a "clear" function for JS arrays
				delete compoundList[key]
			}
			//Copy contents of reset data to data list
			compoundList = Object.assign({}, resetData);
			//Repopulate list model
			for (let sub in root.compoundList){
				console.log(sub)
				let newComponent = {name: sub, unit: "concentration", type: "double", hint: "", valid: true}
				compoundDataModel.append(newComponent)
			}
			//Make blank fields corresponding to any entries added after loading data
			for (let i = 0; i < numNewElements; ++i){
				let newComponent = {name: "", unit: "concentration", type: "double", hint: "", valid: true}
				compoundDataModel.append(newComponent)
			}
		}
	}

	function checkConfiguration(){
		let validConfiguration = true
		if (root.compoundName === ""){
			validConfiguration = false
			let errorStr = "Compound name is a required field"
			root.invalidConfiguration(errorStr)
		} else {
			for (let i = 0; i < compoundDataModel.count; ++i){
				let validEntry = compoundDataModel.get(i).valid
				if (!validEntry){
					validConfiguration = false
					let errorStr = "Each component requires a substance name, concentration, and unit"
					root.invalidConfiguration(errorStr)
					break;
				}
			}
		}
		if (validConfiguration){
			let nameData = {"Name" : root.compoundName}
			Object.assign(compoundList, nameData);	//Need to bundle up "name" with component list because WizardDialog::SaveData expects one object
			root.validConfiguration('Compound', compoundList)  //'Compound' flag tells Wizard manager which type of data to save
		}
	}

	function mergeCompoundData(compound){
		//Set name and then remove from map (so that we can loop over all components)
		root.compoundName = compound["Name"][0]
		root.resetName = root.compoundName		//Store loaded name in case we revert
		delete compound["Name"]
		let subNames = Object.keys(compound)				//Getting array directly instead of for (let key in compound) because "key" is then the index, not the sub name, which we need
		for (let i = 0; i < subNames.length; ++i){
			let sub = subNames[i]
			let componentEntry = {[sub] : compound[sub]}				//Putting [] around sub in first item tells JS to use the value of sub, not the string "sub"
			Object.assign(compoundList, componentEntry)
		}
		resetData = Object.assign({}, compoundList)	//Copy data to resetData ( can't do = because this does copy by reference
		
		root.loadConfiguration()
	}

}
