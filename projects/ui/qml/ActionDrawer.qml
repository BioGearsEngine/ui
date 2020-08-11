import QtQuick 2.12
import QtQuick.Window 2.12
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0


ActionDrawerForm {
    id: root
    signal openActionDrawer()
    
    property Scenario scenario
    property Controls controls
    property ObjectModel actionModel

    onOpenActionDrawer:{
        if (!root.opened){
            root.open();
        }
    }
    applyButton.onClicked: {
        if (root.opened){
            root.close();
        }
    }

    //--------------Action-specific dialog instantiators--------------------------------------
    
    /// setup_*Action* functions are called when *Action* is selected from ActionDrawer (see ActionDrawerForm.ui.qml)
    /// Each setup function creates a dialog window which can be customized to accept user input.  User input is 
    /// stored in a "properties" variable, which is passed as args to the appropriate callable BioGears action function 
    /// (see Scenario.cpp). The BioGears action is connected to an ON/OFF switch (Controls.qml and UIActionSwitch.qml)
    /// that is displayed in the control panel area.


    //----------------------------------------------------------------------------------------
    /// Creates a hemorrhage dialog window and assign properties for bleeding rate and location
    /// Sets up a spin box to set rate with upper bound of 1000 mL/min and step size of 10 mL/min
    /// Sets up a combo box for location and populate list with acceptable comparments
    function setup_hemorrhage(actionItem){
      var component = Qt.createComponent("UIActionDialog.qml");
      if ( component.status == Component.Ready){
            var dialog = component.createObject(root.parent, {'numRows' : 2, 'numColumns' : 1});
            let itemHeight = dialog.contentItem.height / 3
            dialog.initializeProperties({name : 'Hemorrhage', location : '', rate: 0});
            let rateSpinProps = {prefHeight : itemHeight, elementRatio : 0.6, spinMax : 1000, spinStep : 10}
            dialog.addSpinBox('Bleeding Rate (mL/min)', 'rate', rateSpinProps)
            let locationModelData = { type : 'ListModel', role : 'name', elements : ['Aorta', 'Left Arm', 'Left Leg', 'Right Arm', 'Right Leg']}
            dialog.addComboBox('Location', 'location', locationModelData, {prefHeight : itemHeight})

            
            dialog.applyProps.connect(function(props) {actionModel.add_hemorrhage_action(props)})
            actionDrawer.closed.connect(dialog.destroy)
            dialog.open()
      } else {
          if (component.status == Component.Error){
              console.log("Error : " + component.errorString() );
              return;
          }
        console.log("Error : Action dialog component not ready");
      } 
    }

    /// Creates a tourniquet dialog window and assign properties for location and application level
    /// Sets up a combo box for location and populate list with acceptable comparments
    /// Sets up a radio button group for application level (i.e. how well was the tourniquet applied)
    function setup_tourniquet(actionItem){
     var dialogComponent = Qt.createComponent("UIActionDialog.qml");
     if ( dialogComponent.status == Component.Ready) {
          var tourniquetDialog = dialogComponent.createObject(root.parent, {'numRows' : 1, 'numColumns' : 2});
            tourniquetDialog.initializeProperties({name : actionItem.name, location : '', level : 0})
            let dialogWidth = tourniquetDialog.contentItem.width
            let dialogHeight = tourniquetDialog.contentItem.height
            let locationComboData = {type : 'ListModel', role : 'compartment', elements : ['Left Arm', 'Left Leg', 'Right Arm','Right Leg']}
            let locationProps = {prefWidth : dialogWidth / 3, prefHeight : dialogHeight / 3, elementRatio : 0.3}
            let locationComboBox = tourniquetDialog.addComboBox('Location','location',locationComboData, locationProps)
            let levelButtonGroup = ["Correct", "Misapplied"]
            let levelProps = {prefWidth : dialogWidth / 2, prefHeight : dialogHeight / 2, elementRatio : 0.6}
            let levelRadioButton = tourniquetDialog.addRadioButton('Application Status','level',levelButtonGroup,levelProps)
            tourniquetDialog.applyProps.connect( function(props) {actionModel.add_tourniquet_action(props)} )
            //Note that "2" option for level in "Off Function" corresponds to "No tourniquet" in CDM::TourniquetApplicationLevel
            actionDrawer.closed.connect(tourniquetDialog.destroy)
            tourniquetDialog.open()
        } else {
          if (dialogComponent.status == Component.Error){
              console.log("Error : " + dialogComponent.errorString() );
              return;
          }
          console.log("Error : Action dialog component not ready");
      } 
    }
    
    //----------------------------------------------------------------------------------------
    /// Creates an infection dialog window and assign properties for severity, minimum inhibitory concentration, and location
    /// Sets up a spin box to set mic with upper bound of 500 mg/L and step size of 10 mg/L
    /// Sets up a spin box to set severity.  Passes an array ['Mild', 'Medium','Severe'] to display enums in spin box
    /// Sets up a combo box for location and populate list with acceptable comparments
    function setup_infection(actionItem){
        var component = Qt.createComponent("UIActionDialog.qml");
        if ( component.status == Component.Ready) {
            var dialog = component.createObject(root.parent, {'numRows' : 3, 'numColumns' : 1});
            let itemHeight = dialog.contentItem.height / 4
            dialog.initializeProperties({name : 'Infection', location : '', severity : 0, mic : 0})
            let micSpinProps = {prefHeight : itemHeight, elementRatio : 0.6, spinMax : 500, spinStep : 10}
            dialog.addSpinBox('Min. Inhibitory Concentration (mg/L)', 'mic', micSpinProps)
            let severitySpinProps = {prefHeight : itemHeight, elementRatio : 0.6, spinMax : 3, displayEnum : ['','Mild','Moderate','Severe']}
            dialog.addSpinBox('Severity', 'severity', severitySpinProps)
            let locationListData = { type : 'ListModel', role : 'name', elements : ['Gut', 'Left Arm', 'Left Leg', 'Right Arm', 'Right Leg']}
            let locationProps = {prefHeight : itemHeight, elementRatio : 0.6}
            dialog.addComboBox('Location', 'location', locationListData, locationProps)

            dialog.applyProps.connect(function(props) {actionModel.add_infection_action(props)})
            actionDrawer.closed.connect(dialog.destroy)
            dialog.open()
        } else {
            if (component.status == Component.Error){
                console.log("Error : %1".arg(component.errorString()))
                return;
            }
            console.log("Error : Action dialog component not ready")
        }
    }

    //----------------------------------------------------------------------------------------
    /// Creates burn dialog window and assign fraction body surface area burned property
    /// Sets up a spin box to set fraction body surface area (scales to output text in floating point)
    function setup_burn(actionItem){
      let severityProps = {elementRatio : 0.6, spinScale : 100, spinMax : 100, spinStep : 5}
      add_single_range_action("Burn Wound", "Fraction, Body Surface Area", severityProps, 
           function(props) {actionModel.add_single_range_action("UIBurnWound.qml", props)} )
    }

    //----------------------------------------------------------------------------------------
    /// Creates pain stimulus dialog window and assign location and severity on visual analog scale
    /// Sets up a combo box for location
    /// Sets up a spin box for VAS scale
    function setup_painStimulus(actionItem){
      var dialogComponent = Qt.createComponent("UIActionDialog.qml");
      if ( dialogComponent.status == Component.Ready){
          var painDialog = dialogComponent.createObject(root.parent, { numRows : 2, numColumns : 1});
          painDialog.initializeProperties({name : actionItem.name, location : '', painScore : 0 })
          let dialogHeight = painDialog.contentItem.height
          let locationData = {type : 'ListModel', role : 'location', elements : ['Abdomen', 'Chest','Head', 'LeftArm','LeftLeg','RightArm','RightLeg']}
          let locationProps = {prefHeight : dialogHeight / 3, elementRatio : 0.5}
          let locationCombo = painDialog.addComboBox('Location', 'location', locationData, locationProps)
          let painScoreProps = {prefHeight : dialogHeight / 3, spinMax : 10, spinStep : 1, elementRatio : 0.5}
          let painSpinBox = painDialog.addSpinBox('Visual Analog Score', 'painScore', painScoreProps)
          painDialog.applyProps.connect(function(props) {actionModel.add_pain_stimulus_action(props)})
          actionDrawer.closed.connect(painDialog.destroy)
          painDialog.open();
      } else {
        if (dialogComponent.status == Component.Error){
          console.log("Error : " + dialogComponent.errorString() );
          return;
        } else {
          console.log("Error : Action dialog component not ready");
          return 
        }
      }
    }

    //----------------------------------------------------------------------------------------
    /// Creates a tension pneumothorax dialog and assigns type, severity, and side
    /// Sets up a radio button group for type
    /// Sets up a radio button group for side
    /// Sets up a spinbox for severity
    function setup_tensionPneumothorax(actionItem){
        var dialogComponent = Qt.createComponent("UIActionDialog.qml");
        if ( dialogComponent.status == Component.Ready) {
            var tensionDialog = dialogComponent.createObject(root.parent, { numRows : 2, numColumns : 2});
            tensionDialog.initializeProperties({name : actionItem.name, severity : 0, type : 0, side : 0 })
            let dialogHeight = tensionDialog.contentItem.height
            let dialogWidth = tensionDialog.contentItem.width
            let typeButtons = ['Open','Closed']   //This is the order as defined in CDM::enumOpenClosed
            let typeOptions = {prefHeight : dialogHeight / 3, prefWidth : dialogWidth / 2.1, elementRatio : 0.3}
            let typeRadioButton = tensionDialog.addRadioButton('Type', 'type', typeButtons, typeOptions)
            let sideButtons = ['Left','Right']   //This is the order as defined in CDM::enumSide
            let sideOptions = {prefHeight : dialogHeight / 3, prefWidth : dialogWidth / 2.1, elementRatio : 0.3}
            let sideRadioButton = tensionDialog.addRadioButton('Side','side',sideButtons,sideOptions)
            let severityOptions = {prefHeight : dialogHeight / 3, prefWidth : dialogWidth / 2, colSpan : 2, elementRatio : 0.4, spinScale : 100, spinMax : 100, spinStep : 5}
            let severitySpinbox = tensionDialog.addSpinBox('Severity', 'severity',severityOptions)
            tensionDialog.applyProps.connect(function(props) {actionModel.add_tension_pneumothorax_action(props)})
            actionDrawer.closed.connect(tensionDialog.destroy)
            tensionDialog.open()
        } else {
            if (dialogComponent.status == Component.Error){
                console.log("Error : " + dialogComponent.errorString() );
                return;
            }
            console.log("Error : Action dialog component not ready");
        }
    }

    //----------------------------------------------------------------------------------------
    /// Creates a needle decompression dialog and assigns side (left/right)
    /// Sets up a radio button for side
    /// Assumes that state = on when function switch is on and state= off when function switch is off
    function setup_needleDecompression(actionItem) {
        var dialogComponent = Qt.createComponent("UIActionDialog.qml");
         if ( dialogComponent.status == Component.Ready){
            var needleDialog = dialogComponent.createObject(root.parent, { numRows : 1, numColumns : 1});
            needleDialog.initializeProperties({name : actionItem.name, side : ''})
            let needleRadioGroup = ['Left', 'Right']
            let needleProps = {prefHeight : needleDialog.contentItem.height / 3, prefWidth : needleDialog.contentItem.width / 2}
            let needleRadioButton = needleDialog.addRadioButton('Side', 'side', needleRadioGroup, needleProps)
            //In "On" function, 1 --> CDM::enumOnOff = On.  In "Off" function, 0 --> CDM::enumOnOff = Off
            needleDialog.applyProps.connect( function(props) {actionModel.add_needle_decompression_action(props)} )
            actionDrawer.closed.connect(needleDialog.destroy)
            needleDialog.open()
        }else {
          if (dialogComponent.status == Component.Error){
                console.log("Error : " + dialogComponent.errorString() );
                return;
            }
            console.log("Error : Action dialog component not ready");
        } 
    }


    //----------------------------------------------------------------------------------------
    /// Creates a traumatic brain injurty dialog and assigns type and severity
    /// Sets up a radio button group for type (left focal, right focal, or diffuse)
    /// Sets up a spinbox for severity
    function setup_traumaticBrainInjury(actionItem){
        var dialogComponent = Qt.createComponent("UIActionDialog.qml");
        if ( dialogComponent.status == Component.Ready){
            var tbiDialog = dialogComponent.createObject(root.parent, { numRows : 1, numColumns : 2});
            tbiDialog.initializeProperties({name : actionItem.name, severity : 0, type : 0})
            let dialogWidth = tbiDialog.contentItem.width
            let dialogHeight = tbiDialog.contentItem.height
            let typeButtons = ['Diffuse','Left Focal', 'Right Focal']
            let typeOptions = {prefWidth : dialogWidth / 2.5, prefHeight : dialogHeight / 2, elementRatio : 0.3}
            let typeRadioButton = tbiDialog.addRadioButton('Type','type',typeButtons, typeOptions);
            let severityOptions = {prefWidth : dialogWidth / 2.5, prefHeight : dialogHeight / 4, elementRatio : 0.4, spinScale : 100, spinMax : 100, spinStep : 5}
            let severitySpinBox = tbiDialog.addSpinBox('Severity','severity', severityOptions)
            tbiDialog.applyProps.connect( function(props) {actionModel.add_tramatic_brain_injury_action(props)})
            actionDrawer.closed.connect(tbiDialog.destroy)
            tbiDialog.open();
        } else {
            if (dialogComponent.status == Component.Error){
                console.log("Error : " + dialogComponent.errorString() );
                return;
            }
            console.log("Error : Action dialog component not ready");
        } 
    }

    //----------------------------------------------------------------------------------------
    /// Create exercise dialog window with options to supply arg as intensity scale or work rate
    /// Sets input method ratio button : User can input intensity (0-1) or work rate (in W)
    /// Sets up two text fields (one per option):  Visibility controlled by which input method is currently selected
    function setup_exercise(actionItem) {
      var dialogComponent =  Qt.createComponent("UIActionDialog.qml");
      if ( dialogComponent.status == Component.Ready ) {
        var exerciseDialog = dialogComponent.createObject(root.parent, {'width' : 800, 'numRows' : 5, 'numColumns' : 6 } );
        let itemHeight = exerciseDialog.contentItem.height / 3
        let itemWidth1 = exerciseDialog.contentItem.width / 2
        let itemWidth2 = exerciseDialog.contentItem.width / 3
        let exerciseListData = { type : 'ListModel', role : 'type', elements : ['Generic', 'Cycling', 'Running', 'Strength']}
        let exerciseComboProps = {prefHeight : itemHeight, prefWidth : itemWidth1, elementRatio : 0.4, colSpan : 3}
        let exerciseCombo = exerciseDialog.addComboBox('Exercise Type', 'exerciseType', exerciseListData, exerciseComboProps)
		
		let genericListData = { type : 'ListModel', role : 'type', elements : ['Work Rate (W)', 'Intensity']}
        let genericComboProps = {prefHeight : itemHeight, prefWidth : itemWidth1, elementRatio : 0.4, colSpan : 3, available: false, opacity: 0}
        let genericCombo = exerciseDialog.addComboBox('Generic Type', 'generictype', genericListData, genericComboProps)
        
        //let spacer = exerciseDialog.addTextField('Optional Pack (kg)', 'weightPack', {prefHeight : itemHeight, prefWidth : itemWidth2, available : false, colSpan : 3})
		//spacer.opacity = 0.0
        let field_1 = exerciseDialog.addTextField('field_1', 'field_1',  {prefHeight : itemHeight, prefWidth : itemWidth2, available : false, colSpan : 2})
		let field_3 = exerciseDialog.addTextField('field_3', 'field_3',  {prefHeight : itemHeight, prefWidth : itemWidth2, available : false, colSpan : 2})
        let weightPackField = exerciseDialog.addTextField('Optional Pack (kg)', 'weightPack',  {prefHeight : itemHeight, prefWidth : itemWidth2, available : false, colSpan : 2})

        exerciseCombo.comboUpdate.connect(function (value) {
          genericCombo.opacity = 0.0
		  genericCombo.available = false
		  field_1.available = false
          field_3.available = false
          weightPackField.available = false
          switch (value) {
            case 'Generic' : 
              //Generic
			  genericCombo.opacity = 1.0
			  genericCombo.available = true
			  field_1.available = false
              field_3.available = false
			  field_1.textField.placeholderText = "Work Rate (W)"
              field_3.textField.placeholderText = "Intensity"
			  genericCombo.comboUpdate.connect(function (value) {
				  field_1.available = false
				  field_3.available = false
				  weightPackField.available = false
				  switch (value) {
					case 'Work Rate (W)' :
						// Desired Work Rate
					    field_1.available = true
					    field_3.available = false
						break;
					case 'Intensity' :
						// Intensity
					    field_1.available = false
					    field_3.available = true
						break;
					default: 
						field_1.available = false
					    field_3.available = false
						break;
			      }
			  })
			 			  
              break;
            case 'Cycling' :  
              //Cycling
              genericCombo.available = false
			  genericCombo.required = false
			  field_1.available = true
              field_3.available = true
              field_1.textField.placeholderText = "Cadence (Hz)"
              field_3.textField.placeholderText = "PowerCycle (W)"
			  weightPackField.required = false
              weightPackField.available = true

              break;
            case 'Running' :  
              //Running
              genericCombo.available = false
			  genericCombo.required = false
			  field_1.available = true
              field_3.available = true
              field_1.textField.placeholderText = "Velocity (m/s)"
              field_3.textField.placeholderText = "Incline (fraction)"
			  weightPackField.required = false
              weightPackField.available = true
				
              break;
            case 'Strength' :  
              // Strength
              genericCombo.available = false
			  genericCombo.required = false
			  field_1.available = true
              field_3.available = true
              field_1.textField.placeholderText = "Weight (Kg)"
              field_3.textField.placeholderText = "Repititions"
				
              break;
			default :
				genericCombo.opacity = 0.0
				genericCombo.available = false
				genericCombo.required = false
				field_1.available = false
			    field_3.available = false
			    weightPackField.available = false
          }
        })
        exerciseDialog.applyProps.connect(function (props) {actionModel.add_exercise_action(props)})
        actionDrawer.closed.connect( exerciseDialog.destroy )
        exerciseDialog.open()
      } else {
        if ( dialogComponent.status == Component.Error ) {
          console.log("Error : " + dialogComponent.errorString() );
          return;
        }
      }
    }

    //----------------------------------------------------------------------------------------
    /// Set up function for cardiac arrest.  No dialog window is created because cardiac arrest 
    /// is either on or off.  The action switch is thus all we need
    function setup_cardiacArrest(actionItem){
        //In "On" function, 1 --> CDM::enumOnOff = On.  In "Off" function, 0 --> CDM::enumOnOff = Off
        
        actionModel.add_binary_action("UICardiacArrest.qml")
    }

    //----------------------------------------------------------------------------------------
    /// Set up function for Inhaler Action.  No dialog window is created because cardiac arrest 
    /// is either on or off.  The action switch is thus all we need
    function setup_inhaler(actionItem){
        //In "On" function, 1 --> CDM::enumOnOff = On.  In "Off" function, 0 --> CDM::enumOnOff = Off
        
        actionModel.add_binary_action("UIInhaler.qml")
    }

    //----------------------------------------------------------------------------------------
    /// Set up arguments for asthma action, including severity property and spin box arguments
    /// to track severity value
    /// Calls to generic setup_severityAction function to complete dialog instantiation
    function setup_asthma(actionItem){
      let severityProps = {elementRatio : 0.5, spinScale : 100, spinMax : 100, spinStep : 5}
      add_single_range_action("Asthma Attack", "Severity", severityProps, 
      function(props) {actionModel.add_single_range_action("UIAsthmaAttack.qml" ,props)} )
    }

    //----------------------------------------------------------------------------------------
    /// Set up arguments for acute respiratory distress action, including severity property 
    /// and spin box arguments to track severity value
    /// Calls to generic setup_severityAction function to complete dialog instantiation
    function setup_ards(actionItem){
      let severityProps = {elementRatio : 0.5, spinScale : 100, spinMax : 100, spinStep : 5}
      add_single_range_action("Acute Respiratory Distress", "Severity", severityProps, 
      function(props) {actionModel.add_single_range_action("UIAcuteRespiratoryDistress.qml" , props)} )
    }

    //----------------------------------------------------------------------------------------
    /// Set up arguments for apnea action, including severity property and spin box arguments
    /// to track severity value
    /// Calls to generic setup_severityAction function to complete dialog instantiation
    function setup_apnea(actionItem){
      let severityProps = {elementRatio : 0.5, spinScale : 100, spinMax : 100, spinStep : 5}
      add_single_range_action("Apnea", "Severity", severityProps, 
        function(props) {actionModel.add_single_range_action("UIApnea.qml", props)} )
    }

    //----------------------------------------------------------------------------------------
    /// Set up arguments for airway obstruction action, including severity property and spin box arguments
    /// to track severity value
    /// Calls to generic setup_severityAction function to complete dialog instantiation
    function setup_airwayObstruction(actionItem){
      let severityProps = {elementRatio : 0.5, spinScale : 100, spinMax : 100, spinStep : 5}
      add_single_range_action("Airway Obstruction", "Severity", severityProps, 
        function(props) {actionModel.add_single_range_action("UIAirwayObstruction.qml", props)} )
    }

    //----------------------------------------------------------------------------------------
    /// Set up arguments for bronchoconstriction action, including severity property and spin box arguments
    /// to track severity value
    /// Calls to generic setup_severityAction function to complete dialog instantiation
    function setup_bronchoconstriction(actionItem){
      let severityProps = {elementRatio : 0.5, spinScale : 100, spinMax : 100, spinStep : 5}
      add_single_range_action("Broncho Constriction", "Severity", severityProps, 
        function(props) {actionModel.add_single_range_action("UIBronchoconstriction.qml", props)} )
    }

    //----------------------------------------------------------------------------------------
    /// Set up arguments for acute stress, including severity property and spin box arguments
    /// to track severity value
    /// Calls to generic setup_severityAction function to complete dialog instantiation
    function setup_acuteStress(actionItem){
        let spinnerProperties = {elementRatio : 0.5, spinScale : 100, spinMax : 100, spinStep : 5}
        add_single_range_action("Acute Stress", "Severity", spinnerProperties, 
          function(props) {console.log(props.spinnerValue);actionModel.add_single_range_action("UIAcuteStress.qml", props)} )
    }

    //----------------------------------------------------------------------------------------
    /// Create dialog window for actions that accepts single let input (asthma, burn, airway obstruction, etc.)
    /// Accepts action name, label, biogears function, and args to customize spin box
    /// Sets up a spin box to track severity
    function add_single_range_action(title,label, spinnerProperties, creationFunc ){
       var dialogComponent = Qt.createComponent("UIActionDialog.qml");
       if ( dialogComponent.status == Component.Ready){
           var dialog = dialogComponent.createObject(root.parent, { numRows : 2, numColumns : 1});
           dialog.initializeProperties({name : title,  severity : 0 })
           let dialogHeight = dialog.contentItem.height
           //BEGIN  PROPERTIES
           spinnerProperties.prefHeight = dialogHeight / 3
           let severitySpinBox = dialog.addSpinBox(label, "spinnerValue", spinnerProperties)
           //END  PROPERTIES
           dialog.applyProps.connect(creationFunc)
           actionDrawer.closed.connect(dialog.destroy)
           dialog.open();
       } else {
           if (dialogComponent.status == Component.Error){
             console.log("Error : " + dialogComponent.errorString() );
           } else {
             console.log("Error : Action dialog component not ready");
           }
           return;
       }
    }

    //----------------------------------------------------------------------------------------
    /// Create drug dialog window that handles ALL currently available drug actions
    /// Initializes properties for route, substance, dose, concentration, and rate
    /// Sets up a combo box with all avaliable admin routes (bolus, infusion, oral)
    /// Sets up a combo box with all drugs in substance folder
    /// Sets up text fields for dose, concentration, and rate of infusion
    /// Calls to manage_substanceOptions and apply_SubstanceActions to customize look and output
    ///        depending on the currently selected admin route
    function setup_drugActions(actionItem){
        var dialogComponent = Qt.createComponent("UIActionDialog.qml");
        if ( dialogComponent.status != Component.Ready){
            if (dialogComponent.status == Component.Error){
                console.log("Error : " + dialogComponent.errorString() );
                return;
            }
            console.log("Error : Action dialog component not ready");
        } else {
            var drugDialog = dialogComponent.createObject(root.parent, {'width' : 800, 'numRows' : 2, 'numColumns' : 6 } );
            let itemHeight = drugDialog.contentItem.height / 3
            let itemWidth1 = drugDialog.contentItem.width / 2
            let itemWidth2 = drugDialog.contentItem.width / 3
            drugDialog.initializeProperties({name : actionItem.name, adminRoute : '', substance : '', dose : 0, concentration : 0, rate : 0})
            let adminListData = { type : 'ListModel', role : 'route', elements : ['Bolus-Intraarterial', 'Bolus-Intramuscular', 'Bolus-Intravenous', 'Infusion-Intravenous','Oral','Transmucosal']}
            let adminComboProps = {prefHeight : itemHeight, prefWidth : itemWidth1, elementRatio : 0.4, colSpan : 3}
            let adminCombo = drugDialog.addComboBox('Admin. Route', 'adminRoute', adminListData, adminComboProps)
            let drugsList = scenario.get_drugs();
            let subFolderData = {type : 'ListModel', role : 'drug', elements : drugsList}
            let subComboProps = {prefHeight : itemHeight, prefWidth : itemWidth1, elementRatio : 0.4, colSpan : 3}
            let subCombo = drugDialog.addComboBox('Substance', 'substance', subFolderData, subComboProps)
            let doseField = drugDialog.addTextField('Dose (ml)', 'dose', {prefHeight : itemHeight, prefWidth : itemWidth2, available : false, colSpan : 2})
            let concentrationField = drugDialog.addTextField('Concentration (ug/mL)', 'concentration', {prefHeight : itemHeight, prefWidth : itemWidth2, available : false, colSpan : 2})
            let rateField = drugDialog.addTextField('Rate (mL/min)', 'rate', { prefHeight : itemHeight, prefWidth : itemWidth2, available : false, colSpan : 2})
            drugDialog.applyProps.connect(function(props) { actionModel.add_drug_administration_action(props) } )
            adminCombo.comboUpdate.connect(function (value) { root.manage_drugOptions(value, doseField, concentrationField, rateField)} )
            actionDrawer.closed.connect(drugDialog.destroy)
            drugDialog.open();
        }
    }

    //----------------------------------------------------------------------------------------
    /// Helper function for setup_SubstanceActions
    /// Takes current adminRoute (value) and the three text fields defined in substance dialog
    /// Updates the visibility of each text field according to the current admin route
    ///        (e.g. bolus only needs dose and concentration, so rate visibility is set to false)
    function manage_drugOptions(value, doseField, concentrationField, rateField) {
        switch(value) {
            case 'Bolus-Intraarterial' :
            case 'Bolus-Intramuscular' :
            case 'Bolus-Intravenous' :
                doseField.textField.placeholderText = 'Dose (mL)'
                doseField.available = true
                concentrationField.available = true
                rateField.available = false
                break;
            case 'Infusion-Intravenous' :
                doseField.available = false
                concentrationField.available = true
                rateField.available = true
                break;
            case 'Oral':
            case 'Transmucosal':
                doseField.textField.placeholderText = 'Dose (mg)'
                doseField.available = true
                concentrationField.available = false
                rateField.available = false
                break;    
            default :
                doseField.available = false
                concentrationField.available = false
                rateField.available = false
        }
    }
    //----------------------------------------------------------------------------------------
    /// Create compound infusion dialog window that handles fluid infusion actions
    /// Initializes properties for compound, bag volume, and rate
    /// Sets up a combo box with all avaliable compounds
    /// Sets up a text field for bag volume
    /// Sets up a text field for rate
    function setup_fluidInfusion(actionItem){
        var dialogComponent = Qt.createComponent("UIActionDialog.qml");
        if ( dialogComponent.status == Component.Ready) {
            var infusionDialog = dialogComponent.createObject(root.parent, {'numRows' : 2, 'numColumns' : 2});
            infusionDialog.initializeProperties({name : actionItem.name, compound : '', bagVolume : 0, rate : 0})
            let dialogHeight = infusionDialog.contentItem.height
            let dialogWidth = infusionDialog.contentItem.width
            let compoundList = scenario.get_compounds()
            let compoundListData = {type : 'ListModel', role : 'compound', elements : compoundList}
            let compoundComboProps = {prefHeight : dialogHeight / 4, prefWidth : 0.8 * dialogWidth, elementRatio : 0.4, colSpan : 2}
            let compoundCombo = infusionDialog.addComboBox('Compound', 'compound', compoundListData, compoundComboProps)
            let bagVolumeText = infusionDialog.addTextField('Bag Volume (mL)', 'bagVolume', {prefHeight : dialogHeight / 4, prefWidth : dialogWidth / 2.1, colSpan : 1})
            let rateText = infusionDialog.addTextField('Rate (mL/min)', 'rate', {prefHeight : dialogHeight / 4, prefWidth : dialogWidth / 2.1, colSpan : 1})            
            infusionDialog.applyProps.connect( function(props)    { actionModel.add_compound_infusion_action(props) })
            actionDrawer.closed.connect(infusionDialog.destroy)
            infusionDialog.open()
        } else {
            if (dialogComponent.status == Component.Error){
                console.log("Error : " + dialogComponent.errorString() );
                return;
            }
            console.log("Error : Action dialog component not ready");
        }
    }

    //----------------------------------------------------------------------------------------
    /// Create transfusion dialog window that handles blood transfusion actions
    /// Initializes properties for blood type, bag volume, and rate
    /// Sets up a combo box with all avaliable types
    /// Sets up a text field for bag volume
    /// Sets up a text field for rate
    function setup_transfusion(actionItem){
        var dialogComponent = Qt.createComponent("UIActionDialog.qml");
        if ( dialogComponent.status == Component.Ready) {
            var transfusionDialog = dialogComponent.createObject(root.parent, {'numRows' : 2, 'numColumns' : 2});
            transfusionDialog.initializeProperties({name : actionItem.name, type : '', bagVolume : 0, rate : 0})
            let dialogHeight = transfusionDialog.contentItem.height
            let dialogWidth = transfusionDialog.contentItem.width
            let bloodTypeList = scenario.get_transfusion_products()
            let bloodTypeListData = {type : 'ListModel', role : 'compound', elements : bloodTypeList}
            let bloodTypeComboProps = {prefHeight : dialogHeight / 4.0, prefWidth : dialogWidth * 0.8, colSpan : 2, elementRatio : 0.4}
            let compoundCombo = transfusionDialog.addComboBox('Blood Type', 'type', bloodTypeListData, bloodTypeComboProps)
            let bagVolumeText = transfusionDialog.addTextField('Bag Volume (mL)', 'bagVolume', {prefHeight : dialogHeight /4, prefWidth : dialogWidth / 2.1})
            let rateText = transfusionDialog.addTextField('Rate (mL/min)', 'rate', {prefHeight : dialogHeight / 4, prefWidth : dialogWidth / 2.1})            
            transfusionDialog.applyProps.connect( function(props){ actionModel.add_transfusion_action(props)})
            actionDrawer.closed.connect(transfusionDialog.destroy)
            transfusionDialog.open()
        } else {
            if (dialogComponent.status == Component.Error){
                console.log("Error : " + dialogComponent.errorString() );
                return;
            }
            console.log("Error : Action dialog component not ready");
        }
    }

    function setup_anesthesia_machine (actionItem) {
        var dialogComponent = Qt.createComponent("UIActionDialog.qml");
        if ( dialogComponent.status == Component.Ready) {
            var ventilatorDialog = dialogComponent.createObject(root.parent, { numRows : 8, numColumns : 2});
            ventilatorDialog.height = 450
            ventilatorDialog.width = 750
            ventilatorDialog.initializeProperties({name : actionItem.name, connection : '', primaryGas : '', inletFlow : 5, pMax : 10, peep : 1, ieRatio : 0.5, o2Frac : 0.25, o2Source : '', respirationRate : 12, reliefPressure : 100, bottle1 : 0, bottle2 : 0, leftSub : [], rightSub : []})
            let dialogHeight = ventilatorDialog.contentItem.height
            let dialogWidth = ventilatorDialog.contentItem.width
            //Connection type
            let connectionListData = {type : 'ListModel', role : 'type', elements : ["Mask", "Tube"]}
            let connectionOptions = {prefWidth : dialogWidth * 0.45, prefHeight : dialogHeight / ventilatorDialog.numRows, elementRatio : 0.4} 
            let connectionCombo = ventilatorDialog.addComboBox('Connection', 'connection', connectionListData, connectionOptions)
            //Primary gas
            let gasListData = {type : 'ListModel', role : 'gas', elements : ["Nitrogen", "Air"]}
            let gasOptions = {prefWidth : dialogWidth * 0.45, prefHeight : dialogHeight / ventilatorDialog.numRows, elementRatio : 0.5}
            let gasCombo = ventilatorDialog.addComboBox('Primary Gas', 'primaryGas', gasListData, gasOptions)
            //Inlet Flow
            let flowOptions = {prefWidth : dialogWidth * 0.45, prefHeight : dialogHeight / ventilatorDialog.numRows, elementRatio : 0.6, spinMax : 15, spinStep: 1}
            let flowSpinBox = ventilatorDialog.addSpinBox('Inlet Flow (L/min)', 'inletFlow', flowOptions)
            flowSpinBox.spinBox.value = ventilatorDialog.actionProps["inletFlow"]   //Set initial value to reasonable flow rate
            flowSpinBox.resetValue = ventilatorDialog.actionProps["inletFlow"] 
            //IE Ratio
            let ieOptions = {prefWidth : dialogWidth * 0.45, prefHeight : dialogHeight / ventilatorDialog.numRows, elementRatio : 0.6, spinMax : 200, spinStep : 5, spinScale : 100}
            let ieSpinBox = ventilatorDialog.addSpinBox('IE Ratio', 'ieRatio', ieOptions)
            ieSpinBox.spinBox.value = ventilatorDialog.actionProps["ieRatio"]*100   //Set initial value to reasonable ratio
            ieSpinBox.resetValue = ventilatorDialog.actionProps["ieRatio"]*100
            //Ventilator Pressure
            let pressureOptions = {prefWidth : dialogWidth * 0.45, prefHeight : dialogHeight / ventilatorDialog.numRows, elementRatio : 0.6, spinMax : 20, spinStep : 1}
            let pressureSpinBox = ventilatorDialog.addSpinBox('Max Pressure (cmH2O)', 'pMax', pressureOptions)
            pressureSpinBox.spinBox.value = ventilatorDialog.actionProps["pMax"]   //Set initial value to reasonable pressure
            pressureSpinBox.resetValue = ventilatorDialog.actionProps["pMax"]
            //Positive End Expired Pressure
            let peepOptions = {prefWidth : dialogWidth * 0.45, prefHeight : dialogHeight / ventilatorDialog.numRows, elementRatio : 0.6, spinMax : 5, spinStep : 1}
            let peepSpinBox = ventilatorDialog.addSpinBox('PEEP (cmH2O)', 'peep', peepOptions)
            peepSpinBox.spinBox.value = ventilatorDialog.actionProps["peep"]   //Set initial value to reasonable peep
            peepSpinBox.resetValue = ventilatorDialog.actionProps["peep"]
            //Respiration Rate
            let rrOptions = {prefWidth : dialogWidth * 0.45, prefHeight : dialogHeight / ventilatorDialog.numRows, elementRatio : 0.6, spinMax : 20, spinStep : 1}
            let rrSpinBox = ventilatorDialog.addSpinBox('Respiration Rate', 'respirationRate', rrOptions)
            rrSpinBox.spinBox.value = ventilatorDialog.actionProps["respirationRate"]   //Set initial value to reasonable respiration rate
            rrSpinBox.resetValue = ventilatorDialog.actionProps["respirationRate"]
            //Relief valve pressure
            let reliefOptions = {prefWidth : dialogWidth * 0.45, prefHeight : dialogHeight / ventilatorDialog.numRows, elementRatio : 0.6, spinMax : 150, spinStep : 10}
            let reliefSpinBox = ventilatorDialog.addSpinBox('Relief Valve Pressure (cmH2O)', 'reliefPressure', reliefOptions)
            reliefSpinBox.spinBox.value = ventilatorDialog.actionProps["reliefPressure"]   //Set initial value to reasonable relief
            reliefSpinBox.resetValue = ventilatorDialog.actionProps["reliefPressure"]
            //Oxygen fraction
            let o2FracOptions = {prefWidth : dialogWidth * 0.45, prefHeight : dialogHeight / ventilatorDialog.numRows, elementRatio : 0.6, spinMax : 100, spinStep : 1, spinScale : 100}
            let o2FracSpinBox = ventilatorDialog.addSpinBox('Oxygen Fraction', 'o2Frac', o2FracOptions)
            o2FracSpinBox.spinBox.value = ventilatorDialog.actionProps["o2Frac"]*100   //Set initial value to reasonable o2Frac
            o2FracSpinBox.resetValue = ventilatorDialog.actionProps["o2Frac"]*100
            //Oxygen source
            let sourceListData = {type : 'ListModel', role : 'type', elements : ["Wall", "Bottle One", "Bottle Two"]}
            let sourceOptions = {prefWidth : dialogWidth * 0.45, prefHeight : dialogHeight / ventilatorDialog.numRows, elementRatio : 0.4} 
            let sourceCombo = ventilatorDialog.addComboBox('Oxygen Source', 'o2Source', sourceListData, sourceOptions)
            //Oxygen bottle volumes
            let bottleOptions = {prefWidth : dialogWidth * .45 , prefHeight : dialogHeight / ventilatorDialog.numRows, elementRatio : 0.5, spinMax : 5000, spinStep : 100, required : false, available : false}
            let bottle1SpinBox = ventilatorDialog.addSpinBox('O2 Bottle 1 (mL)','bottle1', bottleOptions)
            let bottle2SpinBox = ventilatorDialog.addSpinBox('O2 Bottle 2 (mL)','bottle2', bottleOptions)
            //Left chamber -- for adding volatile anesthetic drugs
            let leftChamberLabel = Qt.createQmlObject("import QtQuick 2.12; import QtQuick.Controls 2.5; Item { width : 375; height : 55; Label {anchors.fill : parent; anchors.bottomMargin : 2; text : 'Left Chamber Substance'; font.pointSize : 12; horizontalAlignment : Text.AlignHCenter; verticalAlignment : Text.AlignBottom}}", ventilatorDialog.contentItem, "AM-LeftSubChamberLabel")
            let leftChamberSub = Qt.createQmlObject("import QtQuick 2.12; Item { objectName : 'Left ChamberSubstance'; width : 375; height : 55; property alias subEntry : subEntry; function isValid() { return subEntry.entry.validInput; } function getDescription() {return 'LeftChamber: Substance = ' + subEntry.entry.substanceInput.currentText + ', Fraction = ' + subEntry.entry.scalarInput.text} UISubstanceEntry {id : subEntry; type : 'fraction'; anchors.centerIn : parent; prefWidth : parent.width * 0.9; prefHeight : parent.height * 0.9; border.width : 0 } }", ventilatorDialog.contentItem, "AM-LeftSubChamberEntry")
            leftChamberSub.subEntry.entry.substanceInput.font.pointSize = 12
            leftChamberSub.subEntry.entry.scalarInput.font.pointSize = 12
            leftChamberSub.subEntry.setComponentList('VolatileDrugs')
            //right chamber -- for adding volatile anesthetic drugs
            let rightChamberLabel = Qt.createQmlObject("import QtQuick 2.12; import QtQuick.Controls 2.5; Item { width : 375; height : 55; Label {anchors.fill : parent; anchors.bottomMargin : 2; text : 'Right Chamber Substance'; font.pointSize : 12; horizontalAlignment : Text.AlignHCenter; verticalAlignment : Text.AlignBottom}}", ventilatorDialog.contentItem, "AM-RightSubChamberLabel")
            let rightChamberSub = Qt.createQmlObject("import QtQuick 2.12; Item {objectName : 'RightChamberSubstance'; width : 375; height : 55; property alias subEntry : subEntry; function isValid() { return subEntry.entry.validInput; } function getDescription() {return 'RightChamber: Substance = ' + subEntry.entry.substanceInput.currentText + ', Fraction = ' + subEntry.entry.scalarInput.text} UISubstanceEntry {id : subEntry; type : 'fraction'; anchors.centerIn : parent; prefWidth : parent.width * 0.9; prefHeight : parent.height * 0.9; border.width : 0} }", ventilatorDialog.contentItem, "AM-RightSubChamberEntry")
            rightChamberSub.subEntry.entry.substanceInput.font.pointSize = 12
            rightChamberSub.subEntry.entry.scalarInput.font.pointSize = 12
            rightChamberSub.subEntry.setComponentList('VolatileDrugs')
            //Signal handling
            sourceCombo.comboUpdate.connect(function(value) { switch(value){ case "Bottle One" : bottle1SpinBox.available = true; bottle1SpinBox.required = true; bottle2SpinBox.available = false; bottle2SpinBox.required =false; break; case "Bottle Two" : bottle1SpinBox.available = false; bottle1SpinBox.required = false; bottle2SpinBox.available = true; bottle2SpinBox.required = true; break; default : bottle1SpinBox.available = false; bottle1SpinBox.required = false; bottle2SpinBox.available = false; bottle2SpinBox.required = false}})
            leftChamberSub.subEntry.inputAccepted.connect(function (input) {ventilatorDialog.actionProps["leftSub"] = input})
            rightChamberSub.subEntry.inputAccepted.connect(function (input) {ventilatorDialog.actionProps["rightSub"] = input})
            ventilatorDialog.applyProps.connect(function (props) { actionModel.add_anesthesia_machine_action(props)})
            actionDrawer.closed.connect(ventilatorDialog.destroy)
            ventilatorDialog.open()
        } else {
            if (dialogComponent.status == Component.Error){
                console.log("Error : " + dialogComponent.errorString() );
                return;
            }
            console.log("Error : Action dialog component not ready");
        }
    }

    //Consume Meal
    function setup_consumeMeal(actionItem){
      var v_dialogComponent = Qt.createComponent("UIActionDialog.qml");
        if ( v_dialogComponent.status == Component.Ready) {
            var v_mealDialog = v_dialogComponent.createObject(root.parent, {'numRows' : 5, 'numColumns' : 2});
            v_mealDialog.height = 350
            v_mealDialog.initializeProperties({name : actionItem.name, fileName : '', mealName : '', carbohydrate : 0, fat : 0, protein : 0, calcium : 0, sodium : 0, water : 0, fileName : ''})
            let l_dialogHeight = v_mealDialog.contentItem.height
            let l_dialogWidth  = v_mealDialog.contentItem.width
            let l_nutritionList = scenario.get_nutrition()
            let l_nutritionListData = {type : 'ListModel', role : 'nutrition', elements : l_nutritionList}
            let l_nutritionFileProps = {prefHeight : l_dialogHeight / 5, prefWidth : l_dialogWidth, elementRatio : 0.55, colSpan : 2, fontSize : 10, required : false}
            let l_nutritionCombo = v_mealDialog.addComboBox('Load nutrition from file (optional)', 'fileName', l_nutritionListData, l_nutritionFileProps)
            let l_nutritionName = v_mealDialog.addTextField('Meal Name', 'mealName', {prefHeight : l_dialogHeight / 5, prefWidth : l_dialogWidth / 2.1, colSpan : 1, textSize : 10, validateDouble : false})
            let l_water = v_mealDialog.addTextField('Water (mL)', 'water', {prefHeight : l_dialogHeight / 5, prefWidth : l_dialogWidth / 2.1, colSpan : 1, textSize : 10})
            let l_fat = v_mealDialog.addTextField('Fat Content (g)', 'fat', {prefHeight : l_dialogHeight / 5, prefWidth : l_dialogWidth / 2.1, colSpan : 1, textSize : 10})
            let l_carbs = v_mealDialog.addTextField('Carbohydrate Content (g)', 'carbohydrate', {prefHeight : l_dialogHeight / 5, prefWidth : l_dialogWidth / 2.1, colSpan : 1, textSize : 10})
            let l_protein = v_mealDialog.addTextField('Protein Content (g)', 'protein', {prefHeight : l_dialogHeight / 5, prefWidth : l_dialogWidth / 2.1, colSpan : 1, textSize : 10})
            let l_sodium = v_mealDialog.addTextField('Sodium Content (mg)', 'sodium', {prefHeight : l_dialogHeight / 5, prefWidth : l_dialogWidth / 2.1, colSpan : 1, textSize : 10})
            let l_calcium = v_mealDialog.addTextField('Calcium Content (mg)', 'calcium', {prefHeight : l_dialogHeight / 5, prefWidth : l_dialogWidth / 2.1, colSpan : 1, textSize : 10})
            l_nutritionCombo.comboUpdate.connect(function(selection) { loadNutritionData(v_mealDialog, selection)} )
            v_mealDialog.applyProps.connect( function(props)    { actionModel.add_consume_meal_action(props) })
            actionDrawer.closed.connect(v_mealDialog.destroy)
            v_mealDialog.open()
        } else {
            if (v_dialogComponent.status == Component.Error){
                console.log("Error : " + v_dialogComponent.errorString() );
                return;
            }
            console.log("Error : Action dialog component not ready");
        }
    }
    function loadNutritionData(mealDialog, fileName){
      let l_children = mealDialog.contentItem.children      //content children of dialog are all the components we created
      let l_nutritionInfo = scenario.load_nutrition_for_meal(fileName)
      for (let child in l_children){
        //Only look for text fields (they have the data we need to overwrite).  Perform search by determing if child has textField prop
			  if (l_children[child].textField){
          let l_searchKey = l_children[child].textField.placeholderText.split(" ")[0]
          l_children[child].textField.text = l_nutritionInfo[l_searchKey]
          l_children[child].textFieldUpdate(l_nutritionInfo[l_searchKey])  //Force update to properties object to make sure we are tracking data
        }
		  }
    }

    //Placeholder function for other actions that have not yet been defined in Scenario.cpp
    function unsupported_action(actionItem){
        console.log("Support coming for " + actionItem.name);
        actionModel.prompt_user_of_unsupported_action({name : actionItem.name}) 
    }

        //----------------------------------------------------------------------------------------
}


