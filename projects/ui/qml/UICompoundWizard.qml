import QtQuick 2.12
import QtQuick.Window 2.12


UICompoundWizardForm {
	id: root

	signal validConfiguration (string type, var data)
	signal invalidConfiguration(string errorStr)
	signal resetConfiguration()
	signal loadConfiguration(var patient)
	signal nameEdited()

	property string compoundName : ""			//Store name separate from list of compounds
	property var compoundList : ({})
	property var resetData : ({})  //This will be empty strings when "new Compound", but when "edit Compound" it will be file as when first loaded
	property bool editMode : false
	property bool nameWarningFlagged : false

	Component.onDestruction : {
		console.log('Bye wizard')
	}
	
	function getCompoundList() {
		for (let sub in root.compoundList){
			console.log(sub + " : " + root.compoundList[sub])
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
		/*for (let prop in compound){
			compoundData[prop] = compound[prop]
		}
		resetData = Object.assign({}, compoundData)	//Copy data to resetData ( can't do = because this does copy by reference)
		root.loadConfiguration(compoundData)*/
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
