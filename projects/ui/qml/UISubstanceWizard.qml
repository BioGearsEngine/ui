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
		// objects from one group and place them in another--which is not what we want).
		// If we ever add/remove cdm elements to substance, we will need to hardcode the new index ranges here unless
		// we figure out a way to track that info automatically.
		let delegateItems = substanceDelegateModel.items
		delegateItems.addGroups(0, 9, "physical")
    delegateItems.addGroups(9, 6, "clearance")
    delegateItems.addGroups(15, 8, "pkPhysicochemical")
    delegateItems.addGroups(23, 13, "pkTissueKinetics")
    delegateItems.addGroups(36, 18, "pharmacodynamics")
    delegateItems.addGroups(0, delegateItems.count-1, "persistedItems")

		//Each object in a DelegateModel is assigned "inGroup" bool properties that return whether an object is
		// in a given group or not.  In SubstanceDelegateModel, each object will have the following props: inItems (default),
		// inPhysical, inClearance, inPKPhysicochemical, inPkTissueKinetics, inPharmacodynamics.  Use these props
		// to loop over all objects in sort them into the correct data bin.  We will use these bins to track user
		// input and eventually report it to Scenario.create_substance
		for (let i = 0; i < delegateItems.count; ++i){
			let item = delegateItems.get(i)
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
		//Force layout functions here
	}

	function debugObjects(obj) {
		for (let prop in obj){
			console.log("\t" + prop + " : " + obj[prop])
		}
	}

	onLoadConfiguration : {
	}

	onResetConfiguration : {
	}

	function checkConfiguration(){
		let validConfiguration = true
		let errorStr = "*"
		if (validConfiguration){
			root.validConfiguration('Substance', substanceData)  //'Substance' flag tells Wizard manager which type of data to save
		}
		else {
			if (errorStr.charAt(errorStr.length-1)==='*'){
				errorStr = errorStr.slice(0, errorStr.length-1)
			}
			root.invalidConfiguration(errorStr)
		}
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
