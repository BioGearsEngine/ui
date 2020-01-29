import QtQuick 2.12
import QtQuick.Window 2.12

import com.biogearsengine.ui.scenario 1.0

UIActionDrawerForm {
	id: root
	signal toggleState()
	
	property Scenario scenario

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
			scenario.create_hemorrhage_action("Aorta", 150.0);
		}
	}
}
