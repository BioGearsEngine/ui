import QtQuick 2.12
import QtQuick.Window 2.12
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

ActionDrawerForm {
	id: root
	signal toggleState()
	
	property Scenario scenario
	property Controls controls
	property ObjectModel actionModel

	function addSwitch(name, onFunc, offFunc){
		actionModel.addSwitch(name, onFunc, offFunc)
	}

	onToggleState:{
		if (!root.opened){
			root.open();
		} else {
			root.close();
		}
	}
	applyButton.onClicked: {
		if (root.opened){
			root.close();
		}
	}

	//--------------Action-specific wrapper functions-------------------------------//
	//Hemorrhage
	function setup_hemorrhage(actionItem){
		var dialogComponent = Qt.createComponent("UIActionDialog.qml");
	  if ( dialogComponent.status != Component.Ready){
		  if (dialogComponent.status == Component.Error){
			  console.log("Error : " + dialogComponent.errorString() );
			  return;
		  }
	    console.log("Error : Action dialog component not ready");
	  } else {
		  var hemDialog = dialogComponent.createObject(root.parent, {'numRows' : 2, 'numColumns' : 1});
			let itemHeight = hemDialog.contentItem.height / 3
			hemDialog.initializeProperties({name : 'Hemorrhage', location : '', rate: 0});
			let rateSpinProps = {prefHeight : itemHeight, elementRatio : 0.6, spinMax : 1000, spinStep : 10}
			hemDialog.addSpinBox('Bleeding Rate (mL/min)', 'rate', rateSpinProps)
			let locationModelData = { type : 'ListModel', role : 'name', elements : ['Aorta', 'LeftArm', 'LeftLeg', 'RightArm', 'RightLeg']}
			hemDialog.addComboBox('Location', 'location', locationModelData, {prefHeight : itemHeight})
			hemDialog.applyProps.connect( function(props) { actionModel.addSwitch(  props.description,
																																							function () {scenario.create_hemorrhage_action(props.location, props.rate) },
																																							function () {scenario.create_hemorrhage_action(props.location, 0.0) }
																																							)
																										}
																	)
      hemDialog.open()
	  }
	}

	//Infection (very similar to hemorrage--1 extra arg--could look into making widget that both can use)
	function setup_infection(actionItem){
		var dialogComponent = Qt.createComponent("UIActionDialog.qml");
		if ( dialogComponent.status != Component.Ready){
			if (dialogComponent.status == Component.Error){
				console.log("Error : " + dialogComponent.errorString() );
				return;
			}
			console.log("Error : Action dialog component not ready");
		} else {
			var infectionDialog = dialogComponent.createObject(root.parent, {'numRows' : 3, 'numColumns' : 1});




			let itemHeight = infectionDialog.contentItem.height / 4
			infectionDialog.initializeProperties({name : 'Infection', location : '', severity : 0, mic : 0})
			let micSpinProps = {prefHeight : itemHeight, elementRatio : 0.6, spinMax : 500, spinStep : 10}
			infectionDialog.addSpinBox('Min. Inhibitory Concentration (mg/L)', 'mic', micSpinProps)
			let severitySpinProps = {prefHeight : itemHeight, elementRatio : 0.6, spinMax : 3, displayEnum : ['','Mild','Moderate','Severe']}
			infectionDialog.addSpinBox('Severity', 'severity', severitySpinProps)
			let locationListData = { type : 'ListModel', role : 'name', elements : ['Gut', 'LeftArm', 'LeftLeg', 'RightArm', 'RightLeg']}
			let locationProps = {prefHeight : itemHeight, elementRatio : 0.6}
			infectionDialog.addComboBox('Location', 'location', locationListData, locationProps)
			infectionDialog.applyProps.connect( function(props) { actionModel.addSwitch(  props.description,
																																										function () {scenario.create_infection_action(props.location, props.severity, props.mic) },
																																								)
																													}
																				)
			infectionDialog.open()
		}
	}

	function setup_burn(actionItem){
		var dialogComponent = Qt.createComponent("UIActionDialog.qml");
		if ( dialogComponent.status != Component.Ready){
			if (dialogComponent.status == Component.Error){
				console.log("Error : " + dialogComponent.errorString() );
				return;
			}
			console.log("Error : Action dialog component not ready");
		} else {
			var burnDialog = dialogComponent.createObject(root.parent);
			let itemHeight = burnDialog.contentItem.height / 4
			burnDialog.initializeProperties({name : actionItem.name, severity : 0})
			let burnArgs = {prefHeight : itemHeight, elementRatio : 0.6, unitScale : true, spinMax : 100, spinStep : 5}
			burnDialog.addSpinBox('Fraction Body Surface Area', 'severity', burnArgs)
			burnDialog.applyProps.connect( function(props)	{ actionModel.addSwitch	(	props.description, 
																																								function () { scenario.create_burn_action(props.severity) },
																																							)
																											}
																	)
			burnDialog.open()
		}
	}

	function setup_asthma(actionItem){
		let label = 'Severity'
		let func = function(sev) { scenario.create_asthma_action(sev) }
		let customArgs = {elementRatio : 0.5, unitScale : true, spinMax : 100, spinStep : 5}
		setup_severityAction(actionItem.name, label, func, customArgs)
	}


	//Generic form for actions that take single severity input (asthma, burn, airway obstruction, etc.)
	function setup_severityAction(name, label, func, customArgs){
		var dialogComponent = Qt.createComponent("UIActionDialog.qml");
		if ( dialogComponent.status != Component.Ready){
			if (dialogComponent.status == Component.Error){
				console.log("Error : " + dialogComponent.errorString() );
				return;
			}
			console.log("Error : Action dialog component not ready");
		} else {
			var severityDialog = dialogComponent.createObject(root.parent);
			let itemHeight = severityDialog.contentItem.height / 4
			Object.assign(customArgs, {prefHeight : itemHeight})
			severityDialog.initializeProperties({name : name, severity : 0})
			severityDialog.addSpinBox(label, 'severity', customArgs)
			severityDialog.applyProps.connect( function (props) {	actionModel.addSwitch(	props.description,
																																										function () { func (props.severity) },
																																										function () { func (0.0) }
																																									)
																													}
																				)
			severityDialog.open()
		}
	}

	function setup_SubstanceActions(actionItem){
		var dialogComponent = Qt.createComponent("UIActionDialog.qml");
		if ( dialogComponent.status != Component.Ready){
			if (dialogComponent.status == Component.Error){
				console.log("Error : " + dialogComponent.errorString() );
				return;
			}
			console.log("Error : Action dialog component not ready");
		} else {
			var substanceDialog = dialogComponent.createObject(root.parent, {'width' : 800, 'numRows' : 2, 'numColumns' : 6 } );
			let itemHeight = substanceDialog.contentItem.height / 3
			let itemWidth1 = substanceDialog.contentItem.width / 2
			let itemWidth2 = substanceDialog.contentItem.width / 3
			substanceDialog.initializeProperties({name : actionItem.name, adminRoute : '', substance : '', dose : "0", concentration : "0", rate : "0"})
			let adminListData = { type : 'ListModel', role : 'route', elements : ['Bolus-Intraarterial', 'Bolus-Intramuscular', 'Bolus-Intravenous', 'Infusion-Intravenous','Oral','Transmucosal']}
			let adminComboProps = {prefHeight : itemHeight, prefWidth : itemWidth1, elementRatio : 0.4, colSpan : 3}
			let adminCombo = substanceDialog.addComboBox('Admin. Route', 'adminRoute', adminListData, adminComboProps)
			let subFolderData = {type : 'FolderModel', role : 'fileBaseName', elements : 'file:substances'}
			let subComboProps = {prefHeight : itemHeight, prefWidth : itemWidth1, elementRatio : 0.4, colSpan : 3}
			let subCombo = substanceDialog.addComboBox('Substance', 'substance', subFolderData, subComboProps)
			let doseField = substanceDialog.addTextField('Dose (ml)', 'dose', {prefHeight : itemHeight, prefWidth : itemWidth2, editable : false, colSpan : 2})
			let concentrationField = substanceDialog.addTextField('Concentration (ug/mL)', 'concentration', {prefHeight : itemHeight, prefWidth : itemWidth2, editable : false, colSpan : 2})
			let rateField = substanceDialog.addTextField('Rate (mL/min)', 'rate', { prefHeight : itemHeight, prefWidth : itemWidth2, editable : false, colSpan : 2})
			substanceDialog.applyProps.connect(root.apply_SubstanceAction)
			adminCombo.comboUpdate.connect(function (value) { root.manage_substanceOptions(value, doseField, concentrationField, rateField)} )
			substanceDialog.open();
		}
	}

	function manage_substanceOptions(value, doseField, concentrationField, rateField) {
		switch(value) {
			case 'Bolus-Intraarterial' :
			case 'Bolus-Intramuscular' :
			case 'Bolus-Intravenous' :
				doseField.textField.placeholderText = 'Dose (mL)'
				doseField.editable = true
				concentrationField.editable = true
				rateField.editable = false
				break;
			case 'Infusion-Intravenous' :
				doseField.editable = false
				concentrationField.editable = true
				rateField.editable = true
				break;
			case 'Oral':
			case 'Transmucosal':
				doseField.textField.placeholderText = 'Dose (mg)'
				doseField.editable = true
				concentrationField.editable = false
				rateField.editable = false
				break;	
			default :
				doseField.editable = false
				concentrationField.editable = false
				rateField.editable = false
		}
	}

	function apply_SubstanceAction(props){
		let route = props.adminRoute
		let substance = props.substance
		let dose = props.dose
		let concentration = props.concentration
		let rate = props.rate
		let routeDescription = route.split('-')[0] + " (" + route.split('-')[1] + ") : "
		let description = substance + " " + routeDescription		//Overriding description for substances
		switch (route) {
			case 'Bolus-Intraarterial' :
				if (dose == 0.0 || concentration == 0.0){
					console.log('Bolus action requires a dose and concentration')
				}
				else {
					//Intraarterial is CDM::enumBolusAdministration::0
					description += "Dose (mL) = " + dose + "; Concentration (ug/mL) = " + concentration
					console.log('Here')
					actionModel.addSwitch(description, 
																function () { scenario.create_substance_bolus_action(substance, 0, dose, concentration) } 
																);
					close();
				}
				break;
			case 'Bolus-Intramuscular' :
				description += "Dose (mL) = " + dose + "; Concentration (ug/mL) = " + concentration
				if (dose == 0.0 || concentration == 0.0){
					console.log('Bolus action requires a dose and concentration')
				}
				else {
					//Intramuscular is CDM::enumBolusAdministration::1
					actionModel.addSwitch(description, 
																function () { scenario.create_substance_bolus_action(substance, 1, dose, concentration) } 
																);
					close();
				}
				break;
			case 'Bolus-Intravenous' :
				description += "Dose (mL) = " + dose + "; Concentration (ug/mL) = " + concentration
				if (dose == 0.0 || concentration == 0.0){
					console.log('Bolus action requires a dose and concentration')
				}
				else {
					//Intravenous is CDM::enumBolusAdministration::2
					actionModel.addSwitch(description, 
																function () { scenario.create_substance_bolus_action(substance, 2, dose, concentration) } 
																);
					close();
				}
				break;
			case 'Infusion-Intravenous' :
				description += 'Concentration (ug/mL) = ' + concentration + '; Rate (mL/min) = ' + rate
				if (concentration == 0.0 || rate == 0.0){
					console.log('Infusion action requires a concentration and a rate')
				} else {
					actionModel.addSwitch(description, 
																function () { scenario.create_substance_infusion_action(substance, concentration, rate)}, 
																function () { scenario.create_substance_infusion_action(substance, 0.0, 0.0) }
																);
					close();
				}
				break;
			case 'Oral':
				description += 'Dose (mg) = ' + dose
				if (dose == 0.0){
					console.log('Oral drug action requires a dose')
				} else {
					//Oral (GI) is CDM::enumOralAdministration::1
					actionModel.addSwitch(description, 
																function () { scenario.create_substance_oral_action(substance, 0, dose) } 
																);
					close();
				}
				break;
			case 'Transmucosal':
				description += 'Dose (mg) = ' + dose
				if (dose == 0.0){
					console.log('Tranmucosal action requires a dose')
				} else {
					//Transcmucosal is CDM::enumOralAdministration::0
					actionModel.addSwitch(description, 
																function () { scenario.create_substance_oral_action(substance, 1, dose) } 
																);
					close();
				}
				break;
		}
	}

	function setup_OtherActions(actionItem){
		console.log("Support coming for " + actionItem.name);
	}

}
