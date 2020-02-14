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
			hemDialog.initializeProperties({name : 'Hemorrhage', location : '', rate: 0});
			let rateSpinProps = {elementRatio : 0.6, spinMax : 1000, spinStep : 10}
			hemDialog.addSpinBox('Bleeding Rate (mL/min)', 'rate', rateSpinProps)
			let locationModelData = { type : 'ListModel', role : 'name', elements : ['Aorta', 'LeftArm', 'LeftLeg', 'RightArm', 'RightLeg']}
			hemDialog.addComboBox('Location', 'location', locationModelData, {})
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
			infectionDialog.initializeProperties({name : 'Infection', location : '', severity : 0, mic : 0})
			let micSpinProps = {elementRatio : 0.6, spinMax : 500, spinStep : 10}
			infectionDialog.addSpinBox('Min. Inhibitory Concentration (mg/L)', 'mic', micSpinProps)
			let severitySpinProps = {elementRatio : 0.6, spinMax : 3, displayEnum : ['','Mild','Moderate','Severe']}
			infectionDialog.addSpinBox('Severity', 'severity', severitySpinProps)
			let locationListData = { type : 'ListModel', role : 'name', elements : ['Gut', 'LeftArm', 'LeftLeg', 'RightArm', 'RightLeg']}
			let locationProps = {elementRatio : 0.6}
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
			burnDialog.initializeProperties({name : actionItem.name, severity : 0})
			let burnArgs = {elementRatio : 0.6, unitScale : true, spinMax : 100, spinStep : 5}
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
			var substanceDialog = dialogComponent.createObject(root.parent, {'numRows' : 2, 'numColumns' : 3 } );
			substanceDialog.initializeProperties({name : actionItem.name, adminRoute : '', substance : '', dose : 0, concentration : 0, rate : 0})
			let adminListData = { type : 'ListModel', role : 'route', elements : ['Bolus-Intraarterial', 'Bolus-Intramuscular', 'Bolus-Intravenous', 'Infusion-Intravenous','Oral','Transmucosal']}
			let adminComboProps = {elementRatio : 0.4, 'Layout.columnSpan' : 2}
			substanceDialog.addComboBox('Admin. Route', 'adminRoute', adminListData, adminComboProps)
			let subFolderData = {type : 'FolderModel', role : 'fileBaseName', elements : 'file:substances'}
			let subComboProps = {elementRatio : 0.4, colSpan : 2}
			substanceDialog.addComboBox('Substance', 'substance', subFolderData, subComboProps)
			substanceDialog.addTextField('Dose (ml)', 'dose', {})
			substanceDialog.addTextField('Concentration (ug/mL)', 'concentration', {})
			substanceDialog.addTextField('Rate (mL/min)', 'rate', {})
			substanceDialog.open();
		}
	}





	//Substance Administration
	function setup_SubstanceActions_archive(actionItem){
		var dialogStr = "import QtQuick.Controls 2.12; import QtQuick 2.12; import Qt.labs.folderlistmodel 2.12; import QtQuick.XmlListModel 2.12;
			Dialog {
				id : substanceDialog;
				width : 800;
				height : 300;
				modal : true;
				closePolicy : Popup.NoAutoClose;
				property string substance
				property var action
				property var onFunc
				property var offFunc
				property real dose : 0.0
				property real concentration : 0.0
				property real rate : 0.0
				property string adminRoute
				property string description
				property string doseLabel : 'Dose (mL)'
				property int numRows : 4
				signal adminChange (string route)
				footer : DialogButtonBox {
					standardButtons : Dialog.Apply | Dialog.Reset | Dialog.Cancel;
				}

				onApplied : {
					if (adminCombo.currentIndex == -1 || subCombo.currentIndex == -1){
						console.log('Invalid entry : Provide an admin route and a substance');
					}
					else {
						description = substance + ' ' + adminRoute + ' : '
						switch (adminRoute) {
							case 'Bolus - Intraarterial' :
								description += 'Dose = ' + dose + ' mL; Concentration = ' + concentration + ' ug/mL'
								if (dose == 0.0 || concentration == 0.0){
									console.log('Bolus action requires a dose and concentration')
								}
								else {
									//Intraarterial is CDM::enumBolusAdministration::0
									onFunc = function () { scenario.create_substance_bolus_action(substance, 0, dose, concentration) }
									offFunc = function () { return 0 }
									root.addSwitch(description, onFunc, offFunc);
									close();
								}
								break;
							case 'Bolus - Intramuscular' :
								description += 'Dose = ' + dose + ' mL; Concentration = ' + concentration + ' ug/mL'
								if (dose == 0.0 || concentration == 0.0){
									console.log('Bolus action requires a dose and concentration')
								}
								else {
									//Intramuscular is CDM::enumBolusAdministration::1
									onFunc = function () { scenario.create_substance_bolus_action(substance, 1, dose, concentration) }
									offFunc = function () { return 0 }
									root.addSwitch(description, onFunc, offFunc);
									close();
								}
								break;
							case 'Bolus - Intravenous' :
								description += 'Dose = ' + dose + ' mL; Concentration = ' + concentration + ' ug/mL'
								if (dose == 0.0 || concentration == 0.0){
									console.log('Bolus action requires a dose and concentration')
								}
								else {
									//Intravenous is CDM::enumBolusAdministration::2
									onFunc = function () { scenario.create_substance_bolus_action(substance, 2, dose, concentration) }
									offFunc = function () { return 0 }
									root.addSwitch(description, onFunc, offFunc);
									close();
								}
								break;
							case 'Infusion - Intravenous' :
								description += 'Concentration = ' + concentration + ' ug/mL; Rate = ' + rate + ' mL/min'
								if (concentration == 0.0 || rate == 0.0){
									console.log('Infusion action requires a concentration and a rate')
								} else {
									onFunc = function () { scenario.create_substance_infusion_action(substance, concentration, rate) }
									offFunc = function () { scenario.create_substance_infusion_action(substance, 0.0, 0.0) }
									root.addSwitch(description, onFunc, offFunc);
									close();
								}
								break;
							case 'Oral':
								description += 'Dose = ' + dose + ' mg'
								if (dose == 0.0){
									console.log('Oral drug action requires a dose')
								} else {
									//Oral (GI) is CDM::enumOralAdministration::1
									onFunc = function () { scenario.create_substance_oral_action(substance, 1, dose) }
									offFunc = function() { return 0}
									root.addSwitch(description, onFunc, offFunc);
									close();
								}
								break;
							case 'Transmucosal':
								description += 'Dose = ' + dose + ' mg'
								if (dose == 0.0){
									console.log('Tranmucosal action requires a dose')
								} else {
									//Transcmucosal is CDM::enumOralAdministration::0
									onFunc = function () { scenario.create_substance_oral_action(substance, 0, dose) }
									offFunc = function() { return 0 }
									root.addSwitch(description, onFunc, offFunc);
									close();
								}
								break;
						}
					}
				}
                
        onReset : {
					adminCombo.currentIndex = -1
					subCombo.currentIndex = -1
					doseField.clear()
					concentrationField.clear()
					rateField.clear()
					dose = 0.0
					concentration = 0.0
					rate = 0.0
					description = ''
					adminChange('')
					inputRow.fieldChange('')
				}

				onRejected : {
					close()
				}

				onAdminChange : {
					switch (route) {
						case 'Bolus - Intraarterial' :
						case 'Bolus - Intramuscular' :
						case 'Bolus - Intravenous' :
							doseLabel = 'Dose (mL)'
							doseField.visible = true
							concentrationField.visible = true
							rateField.visible = false
							break;
						case 'Infusion - Intravenous' :
							doseField.visible = false
							concentrationField.visible = true
							rateField.visible = true
							break;
						case 'Oral':
						case 'Transmucosal':
							doseLabel = 'Dose (mg)'
							doseField.visible = true
							concentrationField.visible = false
							rateField.visible = false
							break;	
						default :
							doseField.visible = false
							concentrationField.visible = false
							rate.Field.visible = false
					}
				}

				contentItem : Column {
					id : columnWrapper;
					spacing : 40;
					anchors.left : parent.left
					anchors.right : parent.right;
					Row {
						id: adminRow
						width : parent.width
						height : parent.height / numRows
						anchors.horizontalCenter : parent.horizontalCenter
						spacing : 10
						UIComboBox {
							id : adminCombo
							width : parent.width / 2.1 - spacing / 2
							anchors.left : parent.left
							elementRatio : 0.6
							height : parent.height
							label.text : 'Administration Route'
							label.font.pointSize : 12
							label.font.weight : Font.Normal
							label.horizontalAlignment : Text.AlignHCenter
							label.verticalAlignment : Text.AlignVCenter
							comboBox.font.pointSize : 10
							comboBox.font.weight : Font.Normal
							comboBox.currentIndex : -1
							comboBox.model : adminModel
							comboBox.textRole : 'name'		//Tells UIComboBox to use 'name' role of adminModel to populate menu
							ListModel {
								id : adminModel
								ListElement {name : 'Bolus - Intraarterial'}
								ListElement {name : 'Bolus - Intramuscular'}
								ListElement {name : 'Bolus - Intravenous'}
								ListElement {name : 'Infusion - Intravenous'}
								ListElement {name : 'Oral'}
								ListElement {name : 'Transmucosal'}
							}
							comboBox.onActivated : {
								substanceDialog.adminRoute = adminModel.get(comboBox.currentIndex).name
								substanceDialog.adminChange(adminRoute)
							}
						}
						UIComboBox{
							id : subCombo
							width : parent.width / 2.1 - spacing / 2
							anchors.left : parent.horizontalCenter
							elementRatio : 0.5
							height : parent.height
							label.text : 'Substance'
							label.font.pointSize : 12
							label.font.weight : Font.Normal
							label.horizontalAlignment : Text.AlignHCenter
							label.verticalAlignment : Text.AlignVCenter
							comboBox.font.pointSize : 10
							comboBox.font.weight : Font.Normal
							comboBox.currentIndex : -1
							comboBox.model : subModel
							comboBox.textRole : 'fileBaseName'  //FolderListModels have many built-in roles (fileName, fileBaseName, filePath, etc).  fileBaseName will remove the '.xml' from substance file name

							FolderListModel {
								id : subModel
								nameFilters : ['*.xml']
								folder : 'file:substances'
								showDirs : false
							}
							comboBox.onActivated : {
								substanceDialog.substance = subModel.get(comboBox.currentIndex, 'fileBaseName')
							}
						}
					}
					Row {
						id : inputRow
						width : parent.width;
						height : parent.height / numRows
						spacing : 0;
						signal fieldChange (string fieldName)
						onFieldChange : {
							switch (fieldName) {
								case 'Dose' :
									doseWrapper.editing = true
									concentrationWrapper.editing = false
									rateWrapper.editing = false
									break;
								case 'Concentration' :
									doseWrapper.editing = false
									concentrationWrapper.editing = true
									rateWrapper.editing = false
									break;
								case 'Rate' :
									doseWrapper.editing = false
									concentrationWrapper.editing = false
									rateWrapper.editing = true
									break;
								default : 
									doseWrapper.editing = false
									concentrationWrapper.editing = false
									rateWrapper.editing = false
							}
						}
						Item {
							id : doseWrapper
							width : parent.width / 3;
							height : inputRow.height;
							property bool editing : false
							TextField {
								id : doseField
								anchors.fill : parent
								placeholderText : substanceDialog.doseLabel
								verticalAlignment : Text.AlignBottom;
								horizontalAlignment : Text.AlignHCenter;
								font.pointSize : 12;
								visible : false
								validator : DoubleValidator {
									bottom : 0.0
								}
								background : Rectangle { 
									anchors.fill : parent; 
									color : 'transparent'; 
									border.color : doseWrapper.editing ? 'green' : 'grey'
									border.width : doseWrapper.editing ? 3 : 1
								}
								onPressed : {
									inputRow.fieldChange('Dose')
								}
								onEditingFinished : {
									substanceDialog.dose = doseField.text
								}
							}
						}
						Item {
							id : concentrationWrapper
							width : parent.width / 3;
							height : parent.height;
							property bool editing : false
							TextField {
								id : concentrationField
								anchors.fill : parent
								placeholderText : 'Concentration (ug/mL)'
								font.pointSize : 12;
								visible : false
								verticalAlignment : Text.AlignBottom;
								horizontalAlignment : Text.AlignHCenter;
								validator : DoubleValidator {
									bottom : 0.0
								}
								background : Rectangle { 
									anchors.fill : parent; 
									color : 'transparent'; 
									border.color :  concentrationWrapper.editing ? 'green' : 'grey'
									border.width : concentrationWrapper.editing ? 3 : 1
								}
								onPressed : {
									inputRow.fieldChange('Concentration')
								}
								onEditingFinished : {
									substanceDialog.concentration = concentrationField.text
								}
							}
							
						}
						Item {
							id : rateWrapper
							width : parent.width / 3;
							height : parent.height;
							property bool editing : false
							TextField {
								id : rateField
								anchors.fill : parent
								placeholderText : 'Infusion Rate (mL/min)'
								font.pointSize : 12;
								visible : false
								verticalAlignment : Text.AlignVCenter;
								horizontalAlignment : Text.AlignHCenter;
								validator : DoubleValidator {
									bottom : 0.0
								}
								background : Rectangle { 
									anchors.fill : parent; 
									color : 'transparent'; 
									border.color : rateWrapper.editing ? 'green' : 'grey'
									border.width : rateWrapper.editing ? 3 : 1
								}
								onPressed : {
									inputRow.fieldChange('Rate')
								}
								onEditingFinished : {
									substanceDialog.rate = rateField.text
								}
							}
						}
					}
				}
			}
		"
		var dialogBox = Qt.createQmlObject(dialogStr, root.parent, "DialogDebug");
		dialogBox.title = "Drug Administration Editor"
		dialogBox.action = actionItem
		dialogBox.open()
	}

	function setup_OtherActions(actionItem){
		console.log("Support coming for " + actionItem.name);
	}

}
