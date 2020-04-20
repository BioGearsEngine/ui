import QtQuick 2.12
import QtQuick.Window 2.12


UIPatientWizardForm {
	id: root

	signal saveConfiguration ()
	property var patientData : ({})

	Component.onDestruction : {
		console.log('Bye wizard')
	}

}
