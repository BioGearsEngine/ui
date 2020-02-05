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

	function addButton(menuElement){
		actionModel.addButton(menuElement)
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
	function call_hemorrhage(){
		console.log("Calling hemorrhage")
		var dialogStr = "import QtQuick.Controls 2.12; import QtQuick 2.12;
			Dialog {
				id : hemDialog;
				title : 'Hemorrhage Editor'
				width : 500;
				height : 200;
				modal : true;
				closePolicy : Popup.NoAutoClose;
				standardButtons : Dialog.Ok | Dialog.Cancel;
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
							contentItem : Text {
								text : locationComboBox.displayText;
								verticalAlignment : Text.AlignVCenter;
								horizontalAlignment : Text.AlignHCenter;
								font.pointSize : 12;
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
						}
					}
				}	
			}"
		var dialogBox = Qt.createQmlObject(dialogStr, root.parent, "DialogDebug");
		dialogBox.open()

	}
}
