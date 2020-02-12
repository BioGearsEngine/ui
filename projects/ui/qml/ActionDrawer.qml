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
		var dialogStr = "import QtQuick.Controls 2.12; import QtQuick 2.12;
			Dialog {
				id : hemDialog;
				title : 'Hemorrhage Editor'
				width : 500;
				height : 250;
				modal : true;
				closePolicy : Popup.NoAutoClose;
				property int rate
				property string location
				property var action
				property var onFunc
				property var offFunc
				property string description
				footer : DialogButtonBox {
					standardButtons : Dialog.Apply | Dialog.Reset | Dialog.Cancel;
				}
				onApplied : {
					if (locationComboBox.currentIndex == -1 || rateSpinBox.value ==0) {
						console.log('Invalid entry: Provide a rate > 0 and a location');
					} else {
					description = action.name + ' : Location  = ' + location + '; Rate = ' + rate + ' mL/min'
						onFunc = function () { scenario.create_hemorrhage_action(location, rate) }
						offFunc = function () { scenario.create_hemorrhage_action(location, 0.0) }
						root.addSwitch(description, onFunc, offFunc)
						close();
					}
				}
				onReset : {
					rateSpinBox.value = 0
					locationComboBox.currentIndex = -1
				}
				onRejected : {
					close()
				}
				contentItem : Column {
					spacing : 10;
					anchors.left : parent.left;
					anchors.right : parent.right
					UISpinBox {
						id : rateSpinBox
						width : parent.width;
						height : parent.height / 2 - parent.spacing / 2;
						elementRatio : 0.5
						label.text : 'Bleeding Rate (mL/min)'
						label.horizontalAlignment : Text.AlignHCenter
						label.verticalAlignment : Text.AlignVCenter
						spinBox.to : 500
						spinBox.stepSize : 10
						spinBox.onValueModified : {
							hemDialog.rate = spinBox.value
						}
					}
					UIComboBox {
						id : locationComboBox
						width : parent.width * 0.9
						anchors.horizontalCenter : parent.horizontalCenter
						height : parent.height / 2 - parent.spacing / 2
						elementRatio : 0.6
						label.text : 'Location'
						label.font.pointSize : 12
						label.font.weight : Font.Normal
						label.horizontalAlignment : Text.AlignHCenter
						label.verticalAlignment : Text.AlignVCenter
						comboBox.font.pointSize : 12
						comboBox.font.weight : Font.Normal
						comboBox.model : compartmentModel
						comboBox.textRole : 'name'		//Tells UIComboBox to use 'name' role of compartmentModel to populate menu
						comboBox.currentIndex : -1
						comboBox.onActivated : {
							hemDialog.location = compartmentModel.get(comboBox.currentIndex).name;
						}
						ListModel {
							id : compartmentModel
							ListElement { name : 'Aorta'}
							ListElement { name : 'Brain'}
							ListElement { name : 'LeftArm'}
							ListElement { name : 'Gut' }
							ListElement { name : 'LeftLeg'}
							ListElement { name : 'RightArm'}
							ListElement { name : 'RightLeg'}
						}
					}
				}	
			}"
		var dialogBox = Qt.createQmlObject(dialogStr, root.parent, "DialogDebug");
		dialogBox.action = actionItem
		dialogBox.open()
	}

	//Infection (very similar to hemorrage--1 extra arg--could look into making widget that both can use)
	function setup_infection(actionItem){
		var dialogStr = "import QtQuick.Controls 2.12; import QtQuick 2.12; import QtQuick.Layouts 1.12; import QtQuick.Controls.Material 2.3;
			Dialog {
				id : infectionDialog;
				title : 'Infection Editor'
				width : 500;
				height : 250;
				modal : true;
				closePolicy : Popup.NoAutoClose;
				property int mic
				property int severity
				property string location
				property string description
				property var action
				property var onFunc
				property var offFunc
				footer : DialogButtonBox {
					standardButtons : Dialog.Apply | Dialog.Reset | Dialog.Cancel;
				}
				onApplied : {
					if (locationComboBox.currentIndex == -1 || severitySpinBox.value == 0 || micSpinBox.value == 0 ) {
						console.log('Invalid entry: Provide an MIC > 0, a severity, and a location');
					} else {
						description = action.name + ' : Severity = ' + severitySpinBox.textFromValue(severity) + '; Location  = ' + location + '; MIC = ' + mic + ' mg/L'
						onFunc = function () { scenario.create_infection_action(location, severity, mic) }
						offFunc = function () { scenario.create_infection_action(location, 0, mic) }
						root.addSwitch(description, onFunc, offFunc)
						close();
					}
				}
				onReset : {
					micSpinBox.value = 0
					severitySpinBox.value = 0
					locationComboBox.currentIndex = -1
				}
				onRejected : {
					close()
				}
				contentItem : Column {
					spacing : 5;
					anchors.left : parent.left;
					anchors.right : parent.right;
					UISpinBox {
						id: micSpinBox
						width : parent.width * 0.9;
						height : parent.height / 3 - parent.spacing / 3;
						anchors.right : parent.right
						elementRatio : 0.6
						label.text : 'Min. Inhibitory Concentration (mg/L)';
						label.horizontalAlignment : Text.AlignLeft
						label.verticalAlignment : Text.AlignVCenter
						spinBox.to : 300
						spinBox.stepSize : 10
						
						spinBox.onValueModified : {
							infectionDialog.mic = spinBox.value
						}

					}
					UISpinBox {
						id : severitySpinBox
						width : parent.width * 0.9;
						height : parent.height / 3 - parent.spacing / 3;
						anchors.right : parent.right
						elementRatio : 0.6
						displayEnum : ['','Mild','Moderate','Severe']
						label.text : 'Severity';
						label.horizontalAlignment : Text.AlignLeft
						label.verticalAlignment : Text.AlignVCenter
						spinBox.to : 3
						spinBox.stepSize : 1
						spinBox.valueFromText : function(text) { return valueFromEnum(spinBox.text)}    //arg to function must be text to match default valueFromText signature
						spinBox.textFromValue : function(value) { return valueToEnum(spinBox.value)}		//arg to function must be value to match defaul textFromValue signature
						spinBox.onValueModified : {
							infectionDialog.severity = spinBox.value
						}
					}
					UIComboBox {
						id : locationComboBox
						width : parent.width * 0.9
						anchors.right : parent.right
						elementRatio : 0.6
						height : parent.height / 3 - parent.spacing / 3
						label.text : 'Location'
						label.font.pointSize : 12
						label.font.weight : Font.Normal
						label.horizontalAlignment : Text.AlignLeft
						label.verticalAlignment : Text.AlignVCenter
						comboBox.font.pointSize : 12
						comboBox.font.weight : Font.Normal
						comboBox.model : compartmentModel
						comboBox.textRole : 'name'		//Tells UIComboBox to use 'name' role of compartmentModel to populate menu
						comboBox.currentIndex : -1
						comboBox.onActivated : {
							infectionDialog.location = compartmentModel.get(comboBox.currentIndex).name;
						}
						ListModel {
							id : compartmentModel
							ListElement { name : 'Gut' }
							ListElement { name : 'LeftArm' }
							ListElement { name : 'LeftLeg'}
							ListElement { name : 'RightArm'}
							ListElement { name : 'RightLeg'}
						} 
					}
				}	
			}"
		var dialogBox = Qt.createQmlObject(dialogStr, root.parent, "DialogDebug");
		dialogBox.action = actionItem
		dialogBox.open()
	}

	//Generic form for actions that take single severity input (asthma, burn, airway obstruction, etc.)
	function setup_severityAction(actionItem){
		var dialogStr = "import QtQuick.Controls 2.12; import QtQuick 2.12;
			Dialog {
				id : severityActionDialog;
				width : 500;
				height : 200;
				modal : true;
				closePolicy : Popup.NoAutoClose;
				property real severity
				property var action
				property var onFunc
				property var offFunc
				property string labelText
				property string description
				footer : DialogButtonBox {
					standardButtons : Dialog.Apply | Dialog.Reset | Dialog.Cancel;
				}
				onApplied : {
					if (severitySpinBox.value == 0) {
						console.log('Invalid entry: Provide a value in range (0, 1.0]' );
					} else {
						description = action.name + ' : ' + actionLabel + ' = ' + severity
						switch (action.name){
							case 'Asthma Attack' :
								onFunc = function () { scenario.create_asthma_action(severity) };
								offFunc = function () { scenario.create_asthma_action(0.0) }
								root.addSwitch(description, onFunc, offFunc);
								break;
							case 'Burn' :
								onFunc = function () { scenario.create_burn_action(severity) };
								offFunc = function () { return 0 };
								root.addSwitch(description, onFunc, offFunc);
								break;
							default :
								console.log('Support coming for ' + action.name);
							}
						close();
					}
				}
				onReset : {
					severitySpinBox.value = 0
				}
				onRejected : {
					close()
				}
				contentItem: UISpinBox {
					id : severitySpinBox
					width : parent.width * 0.9;
					height : parent.height / 2;
					anchors.horizontalCenter : parent.horizontalCenter
					elementRatio : 0.5
					unitScale : true
					label.text : 'Severity';
					label.horizontalAlignment : Text.AlignHCenter
					label.verticalAlignment : Text.AlignVCenter
					spinBox.to : 100
					spinBox.stepSize : 5
					spinBox.valueFromText : function(text) { return valueFromDecimal(spinBox.text)}    //arg to function must be text to match default valueFromText signature
					spinBox.textFromValue : function(value) { return valueToDecimal(spinBox.value)}		//arg to function must be value to match defaul textFromValue signature
					spinBox.onValueModified : {
						severityActionDialog.severity = spinBox.value / spinBox.to
					}

				}
		}"

		var dialogBox = Qt.createQmlObject(dialogStr, root.parent, "DialogDebug");
		dialogBox.title = actionItem.name + " Editor"
		dialogBox.labelText = actionItem.name == "Burn" ? "Fraction Body Surface Area" : "Severity";
		dialogBox.action = actionItem
		dialogBox.open()
	}

	//Substance Administration
	function setup_SubstanceActions(actionItem){
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
