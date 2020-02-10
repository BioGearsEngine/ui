import QtQuick 2.12
import QtQuick.Window 2.12
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

UIActionDrawerForm {
	id: root
	signal toggleState()
	
	property Scenario scenario
	property Controls controls
	property ObjectModel actionModel

	function addButton(name, bgFunc){
		actionModel.addButton(name, bgFunc)
	}

	function removeButton(menuElement){
		var index = -1
		for (var i = 0; i < actionModel.count; ++i){
			if (menuElement.name == actionModel.get(i).name){
				index = i;
				break;
			}
		}
		if (index!=-1) {
			actionModel.remove(index, 1);
		} else {
			console.log("No active button : " + menuElement.name);
		}
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
				footer : DialogButtonBox {
					standardButtons : Dialog.Apply | Dialog.Reset | Dialog.Cancel;
				}
				onApplied : {
					if (locationComboBox.currentIndex == -1 || rateSpinBox.value ==0) {
						console.log('Invalid entry: Provide a rate > 0 and a location');
					} else {
						var bgFunc = function () { scenario.create_hemorrhage_action(location, rate) }
						root.addButton(action.name, bgFunc)
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
					anchors.centerIn : parent;
					Row {
						width : parent.width;
						height : parent.height / 2 - parent.spacing / 2;
						spacing : 5;
						Label {
							id : rateLabel
							width : parent.width / 2;
							height : parent.height;
							text : 'Bleeding Rate (mL/min)';
							font.pointSize : 12;
							verticalAlignment : Text.AlignVCenter;
						}
						SpinBox {
							id : rateSpinBox
							width : parent.width / 2;
							height : parent.height;
							font.pointSize : 12;
							value : 0;
							from : 0;
							to : 500;
							editable : true;
							stepSize: 10;
							validator : IntValidator {
								bottom : rateSpinBox.from;
								top : rateSpinBox.to;
							}
							onValueModified : {
								hemDialog.rate = value
							}
						}
					}
					Row {
						spacing : width - (locationLabel.width + locationComboBox.width);
						width : parent.width;
						height : parent.height / 2 - parent.spacing / 2;
						Label {
							id : locationLabel
							width : parent.width / 3;
							height : parent.height;
							text : 'Location'
							font.pointSize : 12;
							verticalAlignment : Text.AlignVCenter;
						}
						ComboBox {
							id : locationComboBox
							width : parent.width / 2;
							height : parent.height;
							editable : false
							currentIndex : -1;
							contentItem : Text {
								text : locationComboBox.displayText;
								verticalAlignment : Text.AlignVCenter;
								horizontalAlignment : Text.AlignHCenter;
								font.pointSize : 12;
								height : parent.height;
							}
							delegate : ItemDelegate {
								width : locationComboBox.width;
								contentItem : Text {
									text : model.name;
									verticalAlignment : Text.AlignVCenter;
									horizontalAlignment : Text.AlignHCenter;
									font.pointSize : 12;
								}
								highlighted : locationComboBox.highlightedIndex === index;
							}
							model : ListModel {
								id : compartmentModel
								ListElement { name : 'Aorta'}
								ListElement { name : 'Brain'}
								ListElement { name : 'LeftArm'}
								ListElement { name : 'Gut' }
								ListElement { name : 'LeftLeg'}
								ListElement { name : 'RightArm'}
								ListElement { name : 'RightLeg'}
							}
							onActivated : {
								hemDialog.location = compartmentModel.get(currentIndex).name;
							}
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
		var dialogStr = "import QtQuick.Controls 2.12; import QtQuick 2.12;
			Dialog {
				id : infectionDialog;
				title : 'Infection Editor'
				width : 500;
				height : 250;
				modal : true;
				closePolicy : Popup.NoAutoClose;
				property int rate
				property int severity
				property string location
				property var action
				footer : DialogButtonBox {
					standardButtons : Dialog.Apply | Dialog.Reset | Dialog.Cancel;
				}
				onApplied : {
					if (locationComboBox.currentIndex == -1 || severitySpinBox.value == 0 || micSpinBox.value == 0 ) {
						console.log('Invalid entry: Provide an MIC > 0, a severity, and a location');
					} else {
						var bgFunc = function () { scenario.create_infection_action(location, severity, rate) }
						root.addButton(action.name, bgFunc)
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
					anchors.centerIn : parent;
					Row {
						width : parent.width;
						height : parent.height / 3 - parent.spacing / 3;
						spacing : 5;
						Label {
							id : micLabel
							width : parent.width / 1.5;
							height : parent.height;
							text : 'Minimum Inhibitory Concentration (mg/L)';
							font.pointSize : 12;
							verticalAlignment : Text.AlignVCenter;
						}
						SpinBox {
							id : micSpinBox
							width : parent.width / 3;
							height : parent.height;
							font.pointSize : 12;
							value : 0;
							from : 0;
							to : 300;
							editable : true;
							stepSize: 10;
							validator : IntValidator {
								bottom : micSpinBox.from;
								top : micSpinBox.to;
							}
							onValueModified : {
								infectionDialog.rate = value
							}
						}
					}
					Row {
						width : parent.width;
						height : parent.height / 3 - parent.spacing / 3;
						spacing : 5;
						Label {
							id : severityLabel
							width : parent.width / 2;
							height : parent.height;
							text : 'Severity';
							font.pointSize : 12;
							verticalAlignment : Text.AlignVCenter;
						}
						SpinBox {
							id : severitySpinBox
							width : parent.width / 2;
							height : parent.height;
							font.pointSize : 12;
							property var boxText: ['','Mild', 'Moderate', 'Severe']
							value : 0;
							from : 0;
							to : boxText.length;
							editable : false
							stepSize: 1;
							validator : IntValidator {
								bottom : severitySpinBox.from;
								top : severitySpinBox.to;
							}
							textFromValue : function(value) {
								return boxText[value]
							}
							valueFromText : function(text) {
								for (var i = 0; i < boxText.length; ++i){
									if (boxText[i] == text){
										return i
									}
								}
								return value
							}
							onValueModified : {
								infectionDialog.severity = value
							}
						}
					}
					Row {
						spacing : width - (locationLabel.width + locationComboBox.width);
						width : parent.width;
						height : parent.height / 3 - parent.spacing / 3;
						Label {
							id : locationLabel
							width : parent.width / 3;
							height : parent.height;
							text : 'Location'
							font.pointSize : 12;
							verticalAlignment : Text.AlignVCenter;
						}
						ComboBox {
							id : locationComboBox
							width : parent.width / 2;
							height : parent.height;
							editable : false
							currentIndex : -1;
							contentItem : Text {
								text : locationComboBox.displayText;
								verticalAlignment : Text.AlignVCenter;
								horizontalAlignment : Text.AlignHCenter;
								font.pointSize : 12;
								height : parent.height;
							}
							delegate : ItemDelegate {
								width : locationComboBox.width;
								contentItem : Text {
									text : model.name;
									verticalAlignment : Text.AlignVCenter;
									horizontalAlignment : Text.AlignHCenter;
									font.pointSize : 12;
								}
								highlighted : locationComboBox.highlightedIndex === index;
							}
							model : ListModel {
								id : compartmentModel
								ListElement { name : 'Gut' }
								ListElement { name : 'LeftArm' }
								ListElement { name : 'LeftLeg'}
								ListElement { name : 'RightArm'}
								ListElement { name : 'RightLeg'}
							}
							onActivated : {
								infectionDialog.location = compartmentModel.get(currentIndex).name;
							}
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
				property string labelText
				footer : DialogButtonBox {
					standardButtons : Dialog.Apply | Dialog.Reset | Dialog.Cancel;
				}
				onApplied : {
					if (severitySpinBox.value == 0) {
						console.log('Invalid entry: Provide a value in range (0, 1.0]' );
					} else {
						var bgFunc;
						switch (action.name){
							case 'Asthma Attack' :
								bgFunc = function () { scenario.create_asthma_action(severity) };
								root.addButton('Asthma Attack', bgFunc);
								break;
							case 'Burn' :
								bgFunc = function () { scenario.create_burn_action(severity) };
								root.addButton('Burn', bgFunc);
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
				contentItem : Row {
					width : parent.width;
					height : parent.height
					spacing : 5;
					Label {
						id : severityLabel
						width : parent.width / 2;
						text : severityActionDialog.labelText
						height : parent.height;
						font.pointSize : 12;
						verticalAlignment : Text.AlignVCenter;
					}
					SpinBox {
						id : severitySpinBox
						width : parent.width / 2;
						height : parent.height;
						font.pointSize : 12;
						property int decimals : 3
						value : 0;
						from : 0;
						to : 100;
						editable : true;
						stepSize: 5;
						validator : DoubleValidator {
							bottom : 0;
							top : 1.00;
						}
						onValueModified : {
							severityActionDialog.severity = value / 100;
						}
						textFromValue : function(value) {
							return Number(value/100).toLocaleString('f',severitySpinBox.decimals);
						}
						valueFromText : function(text) {
							return Number.fromLocaleString(text) * 100;
						}
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
				property real dose : 0.0
				property real concentration : 0.0
				property real rate : 0.0
				property string adminRoute
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
						var bgFunc;
						switch (adminRoute) {
							case 'Bolus - Intraarterial' :
							if (dose == 0.0 || concentration == 0.0){
									console.log('Bolus action requires a dose and concentration')
								}
								else {
									//Intraarterial is CDM::enumBolusAdministration::0
									bgFunc = function () { scenario.create_substance_bolus_action(substance, 0, dose, concentration) }
									root.addButton(substance + ' Bolus', bgFunc);
									close();
								}
								break;
							case 'Bolus - Intramuscular' :
								if (dose == 0.0 || concentration == 0.0){
									console.log('Bolus action requires a dose and concentration')
								}
								else {
									//Intramuscular is CDM::enumBolusAdministration::1
									bgFunc = function () { scenario.create_substance_bolus_action(substance, 1, dose, concentration) }
									root.addButton(substance + ' Bolus', bgFunc);
									close();
								}
								break;
							case 'Bolus - Intravenous' :
								if (dose == 0.0 || concentration == 0.0){
									console.log('Bolus action requires a dose and concentration')
								}
								else {
									//Intravenous is CDM::enumBolusAdministration::2
									bgFunc = function () { scenario.create_substance_bolus_action(substance, 2, dose, concentration) }
									root.addButton(substance + ' Bolus', bgFunc);
									close();
								}
								break;
							case 'Infusion - Intravenous' :
								if (concentration == 0.0 || rate == 0.0){
									console.log('Infusion action requires a concentration and a rate')
								} else {
									bgFunc = function () { scenario.create_substance_infusion_action(substance, concentration, rate) }
									root.addButton(substance + ' Infusion', bgFunc);
									close();
								}
								break;
							case 'Oral':
								if (dose == 0.0){
									console.log('Oral drug action requires a dose')
								} else {
									//Oral (GI) is CDM::enumOralAdministration::1
									bgFunc = function () { scenario.create_substance_oral_action(substance, 1, dose) }
									root.addButton('Oral ' +  substance, bgFunc);
									close();
								}
								break;
							case 'Transmucosal':
								if (dose == 0.0){
									console.log('Tranmucosal action requires a dose')
								} else {
									//Transcmucosal is CDM::enumOralAdministration::0
									bgFunc = function () { scenario.create_substance_oral_action(substance, 0, dose) }
									root.addButton('Transmucosal ' + substance, bgFunc);
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
					spacing : 20;
					anchors.left : parent.left
					anchors.right : parent.right;
					Row {
						id: adminRow
						width : parent.width
						height : parent.height / numRows
						anchors.horizontalCenter : parent.horizontalCenter
						spacing : 10
						Label {
								id : adminLabel
								width : parent.width / 5
								height : parent.height
								text : 'Administration Route'
								verticalAlignment : Text.AlignVCenter
								horizontalAlignment : Text.AlignRight
								font.pointSize : 12
						}
						ComboBox {
							id : adminCombo
							width : parent.width / 4
							height : parent.height
							currentIndex : -1
							contentItem : Text {
								text : adminCombo.displayText;
								verticalAlignment : Text.AlignVCenter;
								horizontalAlignment : Text.AlignHCenter;
								font.pointSize : 10;
								height : parent.height
								width : adminCombo.width
							} 
							delegate : ItemDelegate {
								width : adminCombo.width
								contentItem : Text {
									text : model.name;
									horizontalAlignment : Text.AlignHCenter
									font.pointSize : 10;
								}
								highlighted : adminCombo.highlightedIndex === index;
							}
							model : ListModel {
								id : adminModel
								ListElement {name : 'Bolus - Intraarterial'}
								ListElement {name : 'Bolus - Intramuscular'}
								ListElement {name : 'Bolus - Intravenous'}
								ListElement {name : 'Infusion - Intravenous'}
								ListElement {name : 'Oral'}
								ListElement {name : 'Transmucosal'}
							}
							onActivated : {
								substanceDialog.adminRoute = adminModel.get(currentIndex).name
								substanceDialog.adminChange(adminRoute)
							}
						}
						Label {
							id : subLabel
							width : parent.width / 5
							height : parent.height
							text : 'Substance'
							verticalAlignment : Text.AlignVCenter
							horizontalAlignment : Text.AlignRight
							font.pointSize : 12
						}
						ComboBox {
							id : subCombo
							width : parent.width / 4
							height : parent.height
							currentIndex : -1
							displayText : (model.status == FolderListModel.Ready && currentIndex != -1) ? model.get(currentIndex,'fileName').split('.')[0] : ''
							contentItem : Text {
								text : subCombo.displayText;
								verticalAlignment : Text.AlignVCenter;
								horizontalAlignment : Text.AlignHCenter;
								font.pointSize : 10;
								height : parent.height
								width : subCombo.width
							} 
							delegate : ItemDelegate {
								width : subCombo.width
								contentItem : Text {
									text : model.fileName.toString().split('.')[0];
									horizontalAlignment : Text.AlignHCenter
									font.pointSize : 10;
								}
								highlighted : subCombo.highlightedIndex === index;
							}
							model : subModel
							FolderListModel {
								id : subModel
								nameFilters : ['*.xml']
								folder : 'file:substances'
								showDirs : false
							}
							onActivated : {
								substanceDialog.substance = subModel.get(currentIndex, 'fileBaseName')
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
