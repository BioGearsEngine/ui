import QtQuick 2.12
import QtQuick.Window 2.12


UISubstanceWizardForm {
	id: root

	signal validConfiguration (string type, var data)
	signal invalidConfiguration(string errorStr)
	signal resetConfiguration()
	signal loadConfiguration(var environmentData)
	signal nameEdited()

	property var substanceData : ({})		//Object holding all substance-related data (key maps to one of the tab objects)
	property var physicalData : ({})		//Object holding all info from the "physical" tab
	property var clearanceData : ({})		//Object holding all info from "clearance" tab
	property var pkData : ({"physicochemical" : ({}), "tissueKinetics" : ({}) })					//Object holding all info from "pharmacokinetics" tab
	property var pdData : ({})					//Object holding all info from "pharmacodynamics" tab
	property var resetData : ({})  //Store data loaded in "edit" mode so that during reset we can revert to data in file
	property bool editMode : false
	property bool nameWarningFlagged : false

	function debugObjects(obj) {
		for (let prop in obj){
			console.log("\t" + prop + " : " + obj[prop])
			if (Object.keys(obj[prop]).length > 0){
				for (let subProp in obj[prop]){
					console.log("\t\t" + subProp + " : " + obj[prop][subProp])
				}
			}
		}
	}

	onLoadConfiguration : {
	}

	onResetConfiguration : {
	}

	function checkConfiguration(){
		let validConfiguration = true
		let errorStr = "*"
		//Check for required fields.
		if (physicalData.Name[0] === null){
			validConfiguration = false
			errorStr += "Name is a required field\n*"
		}
		if (physicalData.State[0] === null){
			validConfiguraration = false
			errorStr += "State is a required field\n*"
		}
		//Loop over all elements to make sure that they do not have incomplete input (e.g. value with no unit)
		for (let i = 0; i < substanceListModel.count; ++i){
			let substanceElement = substanceListModel.get(i)
			if (!substanceElement.valid){
				errorStr += substanceElement.name + " is not valid.\n*"
				validConfiguration = false
			}
		}
		//Verify data from each tab.  Each "verify" function returns a pair [bool valid, string msg].
		//Thus, if first element is false, the configuration is invalid and we append msg to our error message
		//Physical tab does not require extra verification because all fields accept Name and State (handled above)
		//are optional.
		let clearanceVerify = verifyClearanceData()
		if(!clearanceVerify[0]){
			validConfiguration = false
			errorStr += clearanceVerify[1]
		}
		let pkVerify = verifyPkData()
		if (!pkVerify[0]){
			validConfiguration = false
			errorStr += pkVerify[1]
		}
		let pdVerify = verifyPdData()
		if (!pdVerify[0]){
			validConfiguration = false
			errorStr += pdVerify[1]
		}
		//If everything looks good, add data from each tab to a single substanceData object to pass to scenario.create_substance()
		if (validConfiguration){
			Object.assign(substanceData, {"Physical" : physicalData})
			Object.assign(substanceData, {"Clearance" : clearanceData})
			//Send data from whichever PK option is currently active
			if (pkStackLayout.currentIndex == 0){
				Object.assign(substanceData, {"Physicochemicals" : pkData.physicochemical})
			} else {
				Object.assign(substanceData, {"TissueKinetics" : pkData.tissueKinetics})
			}
			Object.assign(substanceData, {"Pharmacodynamics" : pdData})
			root.validConfiguration('Substance', substanceData)  //'Substance' flag tells Wizard manager which type of data to save
		}
		else {
			if (errorStr.charAt(errorStr.length-1)==='*'){
				errorStr = errorStr.slice(0, errorStr.length-1)
			}
			root.invalidConfiguration(errorStr)
		}
	}

	function verifyClearanceData(){
		let valid = true
		let errorStr = ""
		//Clearance is all or nothing.  If Regulation is specified, then all Regulation fields must be given as well
		if (!checkAllOrNothingData( clearanceData )){
			valid = false
			errorStr += "Clearance: \n\t All fields are required to set up substance clearance (or none to indicate no data).\n"
		}
	}

	function verifyPkData() {
		let valid = true
		let errorStr = ""
		let pkEntry = ({})
		//First determine which input method we are using (physicochemical data or tissue kinetics)
		if (pkStackLayout.currentIndex===0){
			if (!checkAllOrNothingData(pkData.physicochemical)){
				valid = false
				errorStr += "Pharmacokinetics: \n\t All fields are required to set up substance physicochemical data (or none to indicate no PK).\n"
			}
		} else {
			if (!checkAllOrNothingData(pkData.tissueKinetics)){
				valid = false
				errorStr += "Pharmacokinetics: \n\t All fields are required to set up substance partition coefficients data (or none to indicate no PK).\n"
			}
		}
		let report = valid ? "" : errorStr
		return [valid, report]
	}

	function verifyPdData() {
		let requiredCount = 0
		let numModifiers = 0
		let errorStr = ""
		let valid = true
		for (let key in pdData){
			if (key === "EC50" || key === "ShapeParameter"){
				if (pdData[key][0]!==null){
					++requiredCount
				}
			} else {
				if (pdData[key][0]!==null){
					++numModifiers
				}
			}	
		}
		//There are two required PD fields.  If we have both, then input is valid (any modifiers
		// not specified will be assigned 0).  If we have no required fields, then we are valid if there are 
		// no modifiers (meaning substance has no PD, which is fine), but invalid if we try to give modifiers
		// (incomplete PD type).  Any other configuration is invalid.
		if (requiredCount === 1){
			//Only one of two required inputs given
			valid = false
			errorStr += "Both EC50 and Shape Parameter must be defined to set up substance PD.\n"
		} else {
			if (requiredCount === 0 && numModifiers > 0){
				//Optional fields given but not required
				valid = false
				errorStr += "Both EC50 and Shape Parameter must be defined to set up substance PD.\n"
			}
		}
		let report = valid ? "" : "Pharmacodynamics : \n\t" + errorStr
		return [valid, report]
	}

	function checkAllOrNothingData( data ) {
		let fieldsDefined = false
		for (let key in data){
			if (data[key][0]===null && fieldsDefined){
				return false	//invalid data because at least 1 field is empty while another is defined
			} else {	
				if (data[key][0]!==null && !fieldsDefined){
					fieldsDefined = true
				}
			}
		}
		return true	//if we made it through the loop then either all fields are defined or all fields are empty
	}


	function mergeSubstanceData(substance){

	}

	function resetEntry(entry){
		if ( root.editMode && resetData[model.name][0]!=null) { 
			entry.setEntry(resetData[entry.model.name]); 
		} else { 
			entry.reset(); 
		}	
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

	function updateDelegateItems(items){
		while (items.count > 0){
			let item = items.get(0)
			if (item.model.dynamic){
				items.setGroups(0, 1, ["dynamic"])
			} else {
				items.setGroups(0, 1, [item.model.group, "persistedItems"])
			}
		}
	}

	function setDelegateFilter(mainTab, subIndex){
		let filter = ""
		switch(mainTab){
			case 0 : 
				filter = "physical"
				break;
			case 1 : 
				filter = "clearance"
				break;
			case 2 : 
				if (subIndex == 0) {
					filter = "pkPhysicochemical"
				} else {
					filter = "pkTissueKinetics"
				}
				break;
			case 3 : 
				filter = "pharmacodynamics"
				break;
			}
			return filter
		}
}
