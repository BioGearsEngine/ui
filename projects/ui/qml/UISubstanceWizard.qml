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

	Component.onCompleted : {
		//Delegate models have a pre-defined group called "items" that all objects are added to by default
		// Objects must manually be added to the other groups we have defined in SubstanceDelegateModel
		// The addGroups(a, b, otherGroup) function copies b objects starting at index a of the calling group to
		// otherGroup (seems like this should be called "addToGroups"?).  Note that each object will then belong
		// to two groups: items and the new group (e.g. "clearance").  This is desirable behavior because it helps 
		// us maintain a "master" list in items.  (There is another function called setGroups that appears to remove
		// objects from one group and place them in another--which is not what we want).  We also add all objects to the 
		// "persistent items" group (another built-in delegate model group).  This passes ownership of the objects to the 
		// delegate model, which maintains their existence even when the view containing the object goes out of focus (normal
		// behavior for views is to destroy their objects when view goes out of focus, then re-make them when focus is regained).
		// In practice, this means that if we write data in the "Physical" tab, then click over to the PK tab, the "physical"
		// data will still be saved and re-displayed when we move back to the "Physical" tab.  
		
		//To initialize, loop over all items (will be 1:1 match with substance list model), and assign them to delegate
		// model groups according to their "group" role if "active" role is true.  Most list model elements are active,
		// but some of the renal clearance options are not. Each object in a DelegateModel is automaticall assigned "inGroup" 
		// bool properties that return whether an object is in a given group or not.  In SubstanceDelegateModel, each object 
		// will have the following props: inItems (default), inPhysical, inClearance, inPKPhysicochemical, inPkTissueKinetics, 
		// inPharmacodynamics.  Use these props to loop over all objects in sort them into the correct data bin.  We will use 
		// these bins to track user input and eventually report it to Scenario.create_substance  

		let delegateItems = substanceDelegateModel.items
		while (delegateItems.count > 0){
			let item = delegateItems.get(0)
			if (item.model.active){
				delegateItems.setGroups(0, 1, [item.model.group, "persistedItems"])
			} else {
				delegateItems.setGroups(0, 1, ["persistedItems"])
			}
			let dataObject = {[item.model.name] : [null, null]}
			if (item.inPhysical){
				Object.assign(physicalData, dataObject)
				continue
			}
			if (item.inClearance){
				Object.assign(clearanceData, dataObject)
				continue
			}
			if (item.inPkPhysicochemical){
				Object.assign(pkData.physicochemical, dataObject)
				continue
			}
			if (item.inPkTissueKinetics){
				Object.assign(pkData.tissueKinetics, dataObject)
				continue
			}
			if (item.inPharmacodynamics){
				Object.assign(pdData, dataObject)
			}
		}
	}

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

	substanceListModel.onDataChanged : {
		let dataIndex = topLeft.row
		let group = substanceListModel.get(dataIndex).group
		let active = substanceListModel.get(dataIndex).active
    if (active){
			substanceDelegateModel.persistedItems.addGroups(dataIndex, 1, [group, "items"])
		} else {
			substanceDelegateModel.persistedItems.removeGroups(dataIndex, 1, [group, "items"])
		}
	}

	function checkConfiguration(){
		let validConfiguration = true
		let errorStr = "*"
		for (let i = 0; i < substanceListModel.count; ++i){
			let substanceElement = substanceListModel.get(i)
			if (!substanceElement.valid){
				errorStr += substanceElement.name + " is not valid.\n*"
				validConfiguration = false
			}
		}
		let clearanceVerify = verifyClearanceData()
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
		if (validConfiguration){
			Object.assign(substanceData, {"Physical" : physicalData})
			Object.assign(substanceData, {"Clearance" : clearanceData})
			if (pkStackLayout.currentIndex == 0){
				Object.assign(substanceData, {"Physicochemicals" : pkData.physicochemical})
			} else {
				Object.assign(substanceData, {"TissueKinetics" : pkData.tissueKinetics})
			}
			Object.assign(substanceData, {"Pharmacodynamics" : pdData})
			//root.validConfiguration('Substance', substanceData)  //'Substance' flag tells Wizard manager which type of data to save
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
		let fieldsDefined = false
		if (!checkAllOrNothingData( clearanceData )){
			valid = false
			errorStr += "Clearance: \n\t All fields are required to set up substance clearance (or none to indicate no data).\n"
		}
		if ('Regulation' in clearanceData){
			if(!checkAllOrNothingData ( clearanceData.Regulation)){
				valid = false
				errorStr += "Clearance: \n\t If using advanced regulation, all additional fields must be specified.\n"
			}
		}
		console.log(valid, errorStr)
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
		//There are two required fields.  If we have both, then input is valid (any modifiers
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
			console.log(key + " : " + data[key][0])
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
