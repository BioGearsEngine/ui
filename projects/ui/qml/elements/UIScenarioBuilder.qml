import QtQuick 2.12
import QtQuick.Window 2.12


UIScenarioBuilderForm {
	id: root

	signal validScenario (string type, var data)
	signal invalidScenario(string errorStr)
	signal resetScenario()
	signal loadScenario()
	signal nameEdited ()

	onClosing : {
		clear();
	}

	function launch(){
		root.showNormal();
	}
	function clear(){
		builderModel.clear();
	}
	
}
