import QtQuick 2.12
import QtQuick.Window 2.12

import com.biogearsengine.ui.scenario 1.0

UIActionDrawerForm {
	id: root
	signal toggleState()
	
	property Scenario scenario
	property Controls controls

	function makeButton(index){
		/*var actionComponent = Qt.createComponent("Button");
		if ( actionComponent.status != Component.Ready){
			if (actionComponent.status == Component.Error){
				console.log("Error : " + actionComponent.errorString() );
				return;
			}
			console.log("Error : Chart component not ready");
		} else {
			var actionButton = actionComponent.createObject(controls, {"text" : "Hemorrhage Test"});
		}*/
		var actionButton = Qt.createQmlObject('import QtQuick.Controls 2.12; Button {text : "Hemorrhage Test"; width: 15; height:10}', controls, 'ActionButton');
		actionButton.clicked.connect(actionMenuModel.get(index).func)
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
}
