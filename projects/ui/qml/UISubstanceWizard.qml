import QtQuick 2.12
import QtQuick.Window 2.12


UISubstanceWizardForm {
	id: root

	signal validConfiguration (string type, var data)
	signal invalidConfiguration(string errorStr)
	signal resetConfiguration()
	signal loadConfiguration()
	signal nameEdited()

	property var substanceData : ({})		//Object holding all substance-related data (key maps to one of the tab objects)
	property var physicalData : ({})		//Object holding all info from the "physical" tab
	property var clearanceData : ({"systemic" : ({}), "regulation" : ({}), "dynamicsChoice" : "" })		//Object holding all info from "clearance" tab
	property var pkData : ({"physicochemical" : ({}), "tissueKinetics" : ({}) })					//Object holding all info from "pharmacokinetics" tab
	property var pdData : ({})					//Object holding all info from "pharmacodynamics" tab
	property var resetData : ({})  //Store data loaded in "edit" mode so that during reset we can revert to data in file
	property bool editMode : false
	property bool nameWarningFlagged : false
	property string errorString : "*"

	function debugObjects(obj) {
		for (let prop in obj){
			console.log("\t" + prop + " : " + obj[prop])
		}
	}

	Component.onCompleted : {
		//Normally, only the active page in a stack layout is fully loaded when parent component is created.
		//This means that only the items in the grid view of the current stack layout index will get set up at first,
		//and the remainder will be created as the user tabs over to the them.  This is not ideal behavior when it
		//comes to loading an existing substance on component initialization, becuase the majority of the data fields
		//will not be setup and will not be able to receive data.  We solve this by iterating across all of the pages
		//in the stack layout and again across each state in a given page.  Each page's states are set up to update
		//the active view.  We then get the currently active grid view of a page and use the GridView.forceLayout()
		//function to force it to create all of its delegate items.  We then return the pages state to its initial
		//value and, when completely finished, reset the layout index to 0 (first tab).
		while (substanceStackLayout.currentIndex < substanceStackLayout.count){
			let currentTab = substanceStackLayout.children[substanceStackLayout.currentIndex]
			for (let i = 0; i < currentTab.states.length; ++i){
				currentTab.state = currentTab.states[i].name
				currentTab.dataView.forceLayout()
			}
			currentTab.state = currentTab.states[0].name
			substanceStackLayout.currentIndex = substanceStackLayout.currentIndex + 1
		}
		substanceStackLayout.currentIndex = 0
	}

	onResetConfiguration : {
		if (resetData.hasOwnProperty("pkPhysicochemical-SecondaryPKA")){
			checkZwitterion(4)
		} else {
			checkZwitterion(0)
		}
	}

	function checkConfiguration(){
		let validConfiguration = true
		//Check for required fields.
		if (physicalData.Name[0] === null){
			validConfiguration = false
			errorString += "Name is a required field\n*"
		}
		if (physicalData.State[0] === null){
			validConfiguration = false
			errorString += "State is a required field\n*"
		}
		//Loop over all elements to make sure that they do not have incomplete input (e.g. value with no unit)
		for (let i = 0; i < substanceListModel.count; ++i){
			let substanceElement = substanceListModel.get(i)
			if (!substanceElement.valid){
				errorString += substanceElement.name + " is not valid.\n*"
				validConfiguration = false
			}
		}
		//Verify data from each tab.  Each "verify" function returns a pair [bool valid, bool dataPresent].
		//Thus, if first element is false, the configuration is invalid.  We use the dataPresent element if
		//the full configuration is valid to determine if we should append this group's data to the substance map or not.
		//Physical tab does not require extra verification because all fields accept Name and State (handled above)
		//are optional.
		let clearanceVerify = verifyClearanceData()
		if(!clearanceVerify[0]){
			validConfiguration = false
		}
		let pkVerify = verifyPkData()
		if (!pkVerify[0]){
			validConfiguration = false
		}
		let pdVerify = verifyPdData()
		if (!pdVerify[0]){
			validConfiguration = false
		}

		//Final check:  Make sure that if PK and Clearance are defined they don't specify different fractions unbount in plasma
		if ((pkStackLayout.currentIndex===0 && pkVerify[1]) && clearanceVerify[1]){
			//Clearance verify function checks the two possible clearance fractions unbounds against each other, so 
			//we can compare PK fraction unbound to just one of the clearance fraction unbounds, depending on the renal
			//dynamics choice.
			if (renalOptions.checkedButton.choice === "clearance"){
				if (pkData.physicochemical.FractionUnboundInPlasma[0]!==clearanceData.systemic.FractionUnboundInPlasma[0]){
					validConfiguration = false
					errorString += "Pharmacokinetics and Clearance must specify same value for fraction unbound in plasma\n*"
				}
			} else {
				if (pkData.physicochemical.FractionUnboundInPlasma[0]!==clearanceData.regulation.FractionUnboundInPlasma[0]){
					validConfiguration = false
					errorString += "Pharmacokinetics and Clearance must specify same value for fraction unbound in plasma\n*"
				}
			}
		}

		//If everything looks good, add data from each tab to a single substanceData object to pass to scenario.create_substance()
		if (validConfiguration){
			Object.assign(substanceData, {"Physical" : physicalData})
			//Only pass clearance data if dataPresent.
			if (clearanceVerify[1]){
				clearanceData.dynamicsChoice = renalOptions.checkedButton.choice
				//Remove "regulation" data if not needed (easier to process downstream)
				if (clearanceData.dynamicsChoice === 'clearance'){
					for (let key in clearanceData.regulation){
						delete clearanceData.regulation[key]
					}
					delete clearanceData.regulation
				}
				//Remove "systemic" data if not needed (happens when we choose "regulation" dynamics and any entry of "systemic" is empty
				if (clearanceData.dynamicsChoice === 'regulation' && clearanceData.systemic.IntrinsicClearance[0]===null){
					for (let key in clearanceData.systemic){
						delete clearanceData.systemic[key]
					}
					delete clearanceData.systemic
				}
				Object.assign(substanceData, {"Clearance" : clearanceData})
			}
			//Send data from whichever PK option is currently active
			if (pkStackLayout.currentIndex === 0 && pkVerify[1]){
				Object.assign(substanceData, {"Physicochemicals" : pkData.physicochemical})
			} else if (pkStackLayout.currentIndex === 1 && pkVerify[1]) {
				Object.assign(substanceData, {"TissueKinetics" : pkData.tissueKinetics})
			}
			if (pdVerify[1]){
				Object.assign(substanceData, {"Pharmacodynamics" : pdData})
			}
			root.validConfiguration('Substance', substanceData)  //'Substance' flag tells Wizard manager which type of data to save
		}
		else {
			if (errorString.charAt(errorString.length-1)==='*'){
				errorString = errorString.slice(0, errorString.length-1)
			}
			root.invalidConfiguration(errorString)
			errorString = "*" //Reset error string for future warnings (if needed)
		}
	}

	function verifyClearanceData(){
		let valid = true
		let dataPresent = true
		//Clearance has two groups of data (Systemic & Regulation).  Each one is all or nothing
		let systemicDataCheck = checkAllOrNothingData( clearanceData.systemic )
		let regulationDataCheck = checkAllOrNothingData( clearanceData.regulation )
		if (!systemicDataCheck[0]){
			valid = false
			errorString += "Systemic Clearance: \n\t All fields are required to set up systemic clearance (or none to indicate no data).\n*"
		} else {
			if (renalOptions.checkedButton.choice === "regulation"){
				//If we select renal regulation, then we need to provide all data
				if (!(regulationDataCheck[0] && regulationDataCheck[1])){
					valid = false
					errorString += "Renal Dynamics: \n\t If using Renal Regulation Options, all fields are required\n*"
				} else {
						//Regulation data is good, but we need to make sure that, if both sections are filled in, we didn't put
						//in different fraction unbound values
						if (systemicDataCheck[1]){
							if (clearanceData.systemic.FractionUnboundInPlasma[0] !== clearanceData.regulation.FractionUnboundInPlasma[0]){
								valid = false
								errorString += "Clearance:  Fraction unbound in plasma values must be consistent\n*"
							}
						}
					}
				}
			}
		dataPresent = systemicDataCheck[1] || (regulationDataCheck[1] && renalOptions.checkedButton.choice === 'regulation')
		return [valid, dataPresent]
	}

	function verifyPkData() {
		let valid = true
		let dataPresent = true
		let pkEntry = ({})
		//First determine which input method we are using (physicochemical data or tissue kinetics)
		if (pkStackLayout.currentIndex===0){
			let checkData = checkAllOrNothingData(pkData.physicochemical)
			if (!checkData[0]){
				valid = false
				errorString += "Pharmacokinetics: \n\t All fields are required to set up substance physicochemical data (or none to indicate no PK).\n*"
			} else {
				dataPresent = checkData[1]
			}
		} else {
			let checkData = checkAllOrNothingData(pkData.tissueKinetics)
			if (!checkData[0]){
				valid = false
				errorString += "Pharmacokinetics: \n\t All fields are required to set up substance partition coefficients data (or none to indicate no PK).\n*"
			} else {
				dataPresent = checkData[1]
			}
		}

		return [valid, dataPresent]
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
			errorString += "Pharmacodynamics: \n\tBoth EC50 and Shape Parameter must be defined to set up substance PD.\n*"
		} else {
			if (requiredCount === 0 && numModifiers > 0){
				//Optional fields given but not required
				valid = false
				errorString += "Pharmacodynamics: \n\tBoth EC50 and Shape Parameter must be defined to set up substance PD.\n*"
			}
		}
		return [valid, requiredCount + numModifiers > 0]
	}

	function checkAllOrNothingData( data ) {
		let fieldsDefined = false
		let valid = true
		for (let key in data){
			if (data[key][0]===null && fieldsDefined){
				valid = false
				return [valid, fieldsDefined]	    //invalid data because at least 1 field is empty while another is defined
			} else {	
				if (data[key][0]!==null && !fieldsDefined){
					fieldsDefined = true
				}
			}
		}
		//If we made it through the loop then either all fields are defined or all fields are empty (valid either way)
		//Pass fieldDefined bool so that we know whether data object is empty of not (if empty, don't need to add to substanceData)
		return [valid, fieldsDefined]	
	}

	//This function parcels out data loaded from an existing substance xml file to the appropriate data objects.
	//The loadConfiguration signal notifies each data field to set its value to these new values.  It also appends
	//each loaded value to the "resetData" object, which is a cache to fall back on when we reset.  The group name
	//(e.g. clearance_systemic) is tacked on to the property name in the reset data object to prevent confusion between
	//props that can appear in more than one tab (fraction unbound in plasma is the serial offender here).
	function mergeSubstanceData(substance){
		for (let prop in substance){
			switch (prop) {
				case "Clearance" :
					let clearance = substance["Clearance"]
					if (clearance.hasOwnProperty("systemic")){
						for (let sysProp in clearance["systemic"]){
							clearanceData.systemic[sysProp] = clearance["systemic"][sysProp]
							Object.assign(resetData, {["clearance_systemic-" + sysProp] : clearance["systemic"][sysProp]}) 
						}
					}
					if (clearance.hasOwnProperty("regulation")){
						substanceStackLayout.children[1].state = "clearanceAndRegulation"
						renalOptions.manualButtonSet("regulation")
						for (let regProp in clearance["regulation"]){
							clearanceData.regulation[regProp] = clearance["regulation"][regProp]
							Object.assign(resetData, {["clearance_regulation-" + regProp] : clearance["regulation"][regProp]}) 
						}
					}
					clearanceData.dynamicsChoice = clearance.dynamicsChoice
					break;
				case "Physicochemicals" :
					let physChem = substance["Physicochemicals"]
					substanceStackLayout.children[2].state = "physchem"				//Make sure the correct PK input option is displayed
					for (let physProp in physChem){
						if( physProp==="SecondaryPKA"){
								substanceStackLayout.currentIndex = 2				//This makes Physicochemial the "active" tab and causes delegate filter to be set to "pkPhysicochemical" 
								checkZwitterion(4)													//Zwitterion has index 4 in list of ionic states
								substanceStackLayout.children[2].dataView.forceLayout()		//Get the grid view of the physicochemical page and force it to respond to addition of zwitterion field
								substanceStackLayout.currentIndex = 0				//Reset stack layout to be on first tab
							}
						pkData.physicochemical[physProp] = physChem[physProp]
						Object.assign(resetData, {["pkPhysicochemical-"+physProp] : physChem[physProp]})
					}
					break;
				case "TissueKinetics" :
					let tisKinetics = substance["TissueKinetics"]
					substanceStackLayout.children[2].state = "partition"				//Make sure the correct PK input option is displayed
					for (let tisProp in tisKinetics){
						pkData.tissueKinetics[tisProp] = tisKinetics[tisProp]
						Object.assign(resetData, {["pkTissueKinetics-" + tisProp] : tisKinetics[tisProp]}) 
					}
					break;
				case "Pharmacodynamics" :
					let pd = substance["Pharmacodynamics"]
					for (let pdProp in pd){
						pdData[pdProp] = pd[pdProp]
						Object.assign(resetData, {["pharmacodynamics-" + pdProp] : pd[pdProp]}) 
					}
					break;
				default :
					physicalData[prop] = substance[prop]
					Object.assign(resetData, {["physical-" + prop] : substance[prop]}) 
			}
		}
		loadConfiguration()
	}

	function resetEntry(entry, prop){
		if ( editMode && resetData.hasOwnProperty(prop)) {
			entry.setEntry(resetData[prop]); 
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
			items.setGroups(0, 1, [item.model.group, "persistedItems"])
			if (item.model.name === 'SecondaryPKA'){
				item.inPkPhysicochemical = false
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

	function checkZwitterion(state){
	//Zwitterion has index = 4 in list of ionic states
		let pkaTwo = substanceDelegateModel.persistedItems.get(21)
		if (state === 4){
			pkaTwo.inPkPhysicochemical = true
			if (!editMode && resetData.hasOwnProperty("pkPhysicochemical-SecondaryPKA")){
				pkData.physicochemical.SecondaryPKA = resetData["pkPhysicochemical-SecondaryPKA"]
				delete resetData["pkPhysicochemical-SecondaryPKA"]
			}
		} else if (pkaTwo.inPkPhysicochemical){
			if (!editMode) {
				Object.assign(resetData, {"pkPhysicochemical-SecondaryPKA" : pkData.physicochemical.SecondaryPKA})
			}
			pkaTwo.inPkPhysicochemical = false
			delete pkData.physicochemical.SecondaryPKA
		}
	}
}
