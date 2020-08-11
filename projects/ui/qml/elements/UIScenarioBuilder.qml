import QtQuick 2.12
import QtQuick.Window 2.12


UIScenarioBuilderForm {
	id: root

	signal validScenario (string type, var data)
	signal invalidScenario(string errorStr)
	signal resetScenario()
	signal loadScenario()
	signal nameEdited ()

	function launch(){
		root.showNormal()
	}
	
	
}
