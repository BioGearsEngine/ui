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
      if (actionDialog.opened){
        actionDialog.close()
        actionDialog.setContent("")
      }
      root.close();
    }
  }


    //----------------------------------------------------------------------------------------
    /// Set up function for Inhaler Action.  No dialog window is created because cardiac arrest 
    /// is either on or off.  The action switch is thus all we need
    function setup_inhaler(actionItem){
        //In "On" function, 1 --> CDM::enumOnOff = On.  In "Off" function, 0 --> CDM::enumOnOff = Off
        
        actionModel.add_binary_action("UIInhaler.qml")
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
}


