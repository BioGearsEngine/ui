import QtQuick 2.12
import QtQuick.Window 2.12
import com.biogearsengine.ui.scenario 1.0


WizardDialogForm {
	id: root

	property var activeWizard;

	function launchPatient(mode){
		mainDialog.title = 'Patient Wizard'
		let patientComponent = Qt.createComponent("UIPatientWizard.qml");
		if ( patientComponent.status != Component.Ready){
		  if (patientComponent.status == Component.Error){
			  console.log("Error : " + patientComponent.errorString() );
			  return;
		  }
	    console.log("Error : Action dialog component not ready");
	  } else {
		  activeWizard = patientComponent.createObject(mainDialog.contentItem);
			root.setHelpText("-Patient name and gender are required fields.  All other fields are optional and will be set to defaults in BioGears if not assigned. 
                \n\n -Baseline inputs will be used as targets for the engine but final values may change during the stabilization process.")
			if (mode === "Edit"){
				let patient = scenario.edit_patient()
				if (Object.keys(patient).length == 0){
					//We get an empty patient object if the user closed file explorer without selecting a patient
					activeWizard.destroy()
					return;
				} else {
					activeWizard.patientGridView.forceLayout() //Ensure that all grid view components are completed or else we will not have a place to put the data
					activeWizard.mergePatientData(patient)
					activeWizard.editMode = true
				}
			}
			//Connect standard dialog buttons to patient functions
			mainDialog.saveButton.onClicked.connect(activeWizard.checkConfiguration)
			mainDialog.onReset.connect(activeWizard.resetConfiguration)
			//Notifications from patient editor to main dialog
			activeWizard.onValidConfiguration.connect(root.saveData)
			activeWizard.onInvalidConfiguration.connect(root.showConfigWarning)
			activeWizard.onNameEdited.connect(root.showNameWarning)
			mainDialog.open()
		}
	}
	function launchEnvironment(mode){
		console.log(mode)
	}
	function launchSubstance(mode) {
		console.log(mode)
	}
	function launchCompound(mode) {
		mainDialog.title = 'Compound Wizard'
		let compoundComponent = Qt.createComponent("UICompoundWizard.qml");
		if ( compoundComponent.status != Component.Ready){
		  if (compoundComponent.status == Component.Error){
			  console.log("Error : " + compoundComponent.errorString() );
			  return;
		  }
	    console.log("Error : Action dialog component not ready");
	  } else {
		  activeWizard = compoundComponent.createObject(mainDialog.contentItem);
			root.setHelpText("-Use the '+' button to add components to the compound and specify their concentrations")
			if (mode === "Edit"){
				let compound = scenario.edit_compound()
				if (Object.keys(compound).length == 0){
					//We get an empty compound object if the user closed file explorer without selecting a compound
					activeWizard.destroy()
					return;
				} else {
					activeWizard.editMode = true
					activeWizard.mergeCompoundData(compound)
					activeWizard.compoundGridView.forceLayout()  //Ensure that all grid view components are completed or else we will not have a place to put the data	
				}
			}
			//Connect standard dialog buttons to compound functions
		  mainDialog.saveButton.onClicked.connect(activeWizard.checkConfiguration)
			mainDialog.onReset.connect(activeWizard.resetConfiguration)
			//Notify dialog that compound is ready
			activeWizard.onValidConfiguration.connect(root.saveData)
			activeWizard.onInvalidConfiguration.connect(root.showConfigWarning)
			activeWizard.onNameEdited.connect(root.showNameWarning)
			mainDialog.open()
		}
	}
	function launchNutrition(mode) {
		mainDialog.title = 'Nutrition Wizard'
		let nutritionComponent = Qt.createComponent("UINutritionWizard.qml");
		if ( nutritionComponent.status != Component.Ready){
		  if (nutritionComponent.status == Component.Error){
			  console.log("Error : " + nutritionComponent.errorString() );
			  return;
		  }
	    console.log("Error : Action dialog component not ready");
	  } else {
		  activeWizard = nutritionComponent.createObject(mainDialog.contentItem);
			root.setHelpText("-Nutrition name is required field.  All other fields are optional and will be set to 0 if not defined.")
			if (mode === "Edit"){
				let nutrition = scenario.edit_nutrition()
				if (Object.keys(nutrition).length == 0){
					//We get an empty nutrition object if the user closed file explorer without selecting a nutrition
					activeWizard.destroy()
					return;
				} else {
					activeWizard.nutritionGridView.forceLayout() //Ensure that all grid view components are completed or else we will not have a place to put the data
					activeWizard.mergeNutritionData(nutrition)
					activeWizard.editMode = true
				}
			}
			//Connect standard dialog buttons to nutrition functions
			mainDialog.saveButton.onClicked.connect(activeWizard.checkConfiguration)
			mainDialog.onReset.connect(activeWizard.resetConfiguration)
			//Notify dialog that nutrition is ready
			activeWizard.onValidConfiguration.connect(root.saveData)
			activeWizard.onInvalidConfiguration.connect(root.showConfigWarning)
			activeWizard.onNameEdited.connect(root.showNameWarning)
			mainDialog.open()
		}
	}
	function launchECG(mode){
		console.log(mode)
	}

	function saveData(type, dataMap){
		switch (type) {
			case 'Patient' : 
				scenario.create_patient(dataMap)
				break;
			case 'Nutrition':
				scenario.create_nutrition(dataMap)
				break;
			case 'Compound':
				scenario.create_compound(dataMap)
				break;
			}
		mainDialog.accept()
	}

	function setHelpText(helpText){
		helpDialog.helpText = helpText
	}
	function showNameWarning(){
		nameWarningDialog.open()
	}
	function showConfigWarning(errorStr){
		invalidConfigDialog.warningText = errorStr
		invalidConfigDialog.open()
	}

	function clearWizard(){
		mainDialog.saveButton.onClicked.disconnect(activeWizard.checkConfiguration)
		mainDialog.onReset.disconnect(activeWizard.resetConfiguration)
		activeWizard.onValidConfiguration.disconnect(root.saveData)
		activeWizard.onInvalidConfiguration.disconnect(root.showConfigWarning)
		activeWizard.onNameEdited.disconnect(root.showNameWarning)
		activeWizard.destroy()
		activeWizard = null
	}

	mainDialog.onAccepted : {
		root.clearWizard()
	}
	mainDialog.onRejected : {
		root.clearWizard()
	}
	mainDialog.onHelpRequested : {
		helpDialog.open()
	}
}
