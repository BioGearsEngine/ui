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

	//Action-specific wrapper functions
	function call_hemorrhage(actionItem){
		var actionVar = actionItem
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
							from : 0;
							value : 0;
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
		dialogBox.action = actionVar
		dialogBox.open()
		

	}
}
