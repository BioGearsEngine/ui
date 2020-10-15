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
	property real cachedPkaTwo : -1		//Second PkA field can have visibility toggled and be removed from pkData.  Cache when removing so that we can re-add it to data if made visible again
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
		//When resetting, we need to check if we loaded a zwitterion.  If we did, then secondary pka will be present in reset data and we need to make
		// sure that this field is visible (possible it could have been hidden while editing).
		if (resetData.hasOwnProperty("pkPhysicochemical-SecondaryPKA")){
			checkZwitterion(4)
		} else {
			checkZwitterion(0)
		}
	}

	//--When "save" clicked, this function checks whether all required data has been provided.  If so, it return a map of data to be parsed in Scenario.cpp
	// If not valid config, it logs a warning to dialog.
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

	//--Function to check clearance specific data
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

	//--Function to check PK specific data
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

	//--Function to check PD specific data
	function verifyPdData() {
		let hasShapeParam = false
		let numModifiers = 0
		let errorStr = ""
		let valid = true
		for (let key in pdData){
			if ( key === "ShapeParameter"){
				if (pdData[key][0]!==null){
					hasShapeParam = true
				}
			} else {
				//User must specify an Max Effect and EC50 for a modifier for it to be valid.  While traversing keys, identify those
				//corresponding to MaxEffect.  Search for their counterpart EC50 entries and check that both entries (or none) are given.
				//This excludes AntibacterialEffect (no "MaxEffect" string) intentionally, because it does not require and EC50
				if (key.includes("MaxEffect")){
					let modName = key.split("MaxEffect")[0]
					let ec50Key = modName+"EC50"
					if (pdData[key][0]!==null && pdData[ec50Key][0]===null){
						errorString += "Pharmacodynamics: \n\t " + modName + " cannot set Max Effect without EC50.\n*"
						valid = false
					} else if (pdData[key][0]===null && pdData[ec50Key][0]!==null){
						errorString += "Pharmacodynamics: \n\t " + modName + " cannot set EC50 without Max Effect.\n*"
						valid = false
					} else if (pdData[key][0]!==null && pdData[ec50Key][0]!==null) {
						++numModifiers //Only increment modifiers if data is there
					}
				}
			}	
		}

		//There is one required PD field (ShapeParameter).  If we have it, then input is valid (any modifiers
		// not specified will be assigned 0).  If we do not have shape parameter, then we are valid if there are 
		// no modifiers (meaning substance has no PD, which is fine), but invalid if we try to give modifiers
		// (incomplete PD type).  Any other configuration is invalid.
		if (!hasShapeParam && numModifiers > 0){
			//Optional fields given but not shape parameter
			valid = false
			errorString += "Pharmacodynamics: \n\tShape Parameter must be defined to set up substance PD.\n*"
		}
		return [valid, hasShapeParam]
	}

	//--Helper function that determines validity of all or nothing data (like Clearance, PK Physiochemicals, Tissue Kinetics, etc)
	// Returns a pair [bool valid, bool fieldDefined] because a valid config could have all (fieldDefined = true) or no fields (fieldsDefined = false) set
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

	//--This function parcels out data loaded from an existing substance xml file to the appropriate data objects.
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

	//--Formats data field name for viewing in wizard
	function displayFormat (role) {
		let formatted = role.replace(/([a-z])([A-Z])/g, '$1 $2')
		return formatted
	}

	//--Set the validator on each delegate depending on the type of data that the field holds
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

	//--This function responds to model elements (in SubstanceListModel) being added to the substance delegate model.  By default, new model elements
	// are placed in the "items" group.  When the items group changes, we sort the new items into the appropraite bins ("physical", "clearance", etc) so
	// that they will appear in the appropriate view.  Please note that the only time we directly add elements to "items" is when the editor is opened
	// (all list elements are already present in SubstanceListModel--we don't add new ones, just control their visibilty).  Changing this functionality by
	// adding list elements dynamically could have unintended consequences, as this function will be triggered and we may unintentionally hide items that
	// are not initially visible (currently just SecondaryPKA).  
	function updateDelegateItems(items){
		while (items.count > 0){
			//The "setGroups" function pops the object from the front of "items" and adds it to the listed groups.  Thus, we keep moving the first element
			//in the items group until there are no more items left.
			let item = items.get(0)
			items.setGroups(0, 1, [item.model.group, "persistedItems"])
			//We remove SecondaryPKA from PkPhysicochemical group so that it is not initially visible.  Changing ionic state to "Zwitterion" will
			// cause it to be re-added to this group and become visible.  SecondaryPKA will still always be in persistedItems group, meaning that
			// any data written to it will be saved even if the field is hidden again.
			if (item.model.name === 'SecondaryPKA'){
				item.inPkPhysicochemical = false
			}
		}
	}

	//--Update the filter currently in use by the Substance Delegate Model.  The filter changes as we tab to a different view.  The pharmacokinetics
	// tab has two possible views, but they are exclusive (can't view both simultaneously), so we call whichever one is currently in view.
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

	//--Zwitterions require a second PkA (for calculating percent ionized in GI if given orally).  This function moves the PKA Two field out of and into the
	// pkPhysicochemical delegate model group.  When in the group, it is automatically added to the pk gridview by way of the pkPhysicochemical part of the
	// substance delegate package.  Because PKA Two also belongs to the persistedItems group, its state will be saved even if it leaves the view.
	function checkZwitterion(state){
		let pkaTwo = substanceDelegateModel.persistedItems.get(21)	//Second pka is 22nd item in the substance list model (which persistedItems group mirrors)
		if (state === 4){																						//Zwitterions have index 4 in the list of possible states
			pkaTwo.inPkPhysicochemical = true													//Setting this property moves pkaTwo item in to pkPhysicochemical group
			//If we didn't load a substance (i.e. not edit mode), but have a cached value for pka 2, then we must have activated it, entered data, and then removed it
			// Upon reactivation, load the cached data into the pkData object so that its available when saving.
			if (cachedPkaTwo !== -1 ){
				pkData.physicochemical.SecondaryPKA[0] = cachedPkaTwo
				cachedPkaTwo = -1
			}
		} else if (pkaTwo.inPkPhysicochemical){										//If ionic state is anything else and pka 2 is active, we need to remove it.
			if (pkData.physicochemical.SecondaryPKA[0]!==null) {
				//Cache any data that was stored in the pka 2 field before removing it.
				cachedPkaTwo = pkData.physicochemical.SecondaryPKA[0]
			}
			pkaTwo.inPkPhysicochemical = false
			delete pkData.physicochemical.SecondaryPKA
		}
	}
}
