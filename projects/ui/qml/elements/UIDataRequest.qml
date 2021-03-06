import QtQuick 2.12
import QtQuick.Controls 2.5

UIDataRequestForm {
  id: root
  
  signal substanceQuantityChanged(string sub, string quantity)
  //Helper function to format request name
  function displayFormat (role) {
		let formatted = role.replace(/([a-z])([A-Z])([a-z])/g, '$1 $2$3')     //Formats BloodVolume as "Blood Volume", but formats pH as "pH"
		return formatted
	}
  //Helper function to make sure strings are formatted properly to be sent to data request manager (no white space)
  function requestFormat (role){
    let formatted = role.replace(/\s/g, '');    //removes all white space characters
    return formatted
  }
  function formatOutput(){
    let type = "TYPE=";
    let name = "NAME=";
    let unit = "UNIT=" + unitValue;
    let precision = "PRECISION=" + precisionValue;
    if (requestRoot === "Compartment"){
      type += (requestBranches[0] + requestRoot)  //E.g. "TYPE=GasCompartment"
      if (requestLeaf.includes("SubstanceQuantity")){
        name += (requestBranches[1] + "," + requestFormat(quantityValue))    //E.g. "NAME="VenaCava,PartialPressure"  (sub stored in 'substanceValue')
      } else {
        name += (requestBranches[1] + "," + requestFormat(requestLeaf))      //E.g. "NAME=Aorta,Volume"
      }
    } else {
      type += requestRoot     //E.g/  "TYPE="Substance"
      if (requestRoot === "Substance") {
        name += (requestBranches[0] + "," + requestFormat(requestLeaf))      //E.g. "NAME=Albuterol,PlasmaConcentration"
      } else {
        name += requestFormat(requestLeaf)       //E.g. "NAME=MeanArterialPressure"
      }
    }
    let output = type + ";" + name + ";" + unit + ";" + precision
    if (requestLeaf.includes("SubstanceQuantity")){
      output += (";" + "SUBSTANCE=" + substanceValue)
    }
    return output;
  }
  //Connected to "save" function in scenario builder. 
  function isValid(){
    if (requestLeaf.includes("SubstanceQuantity")){
      if (unitValue === "" || precisionValue === "" || substanceValue === "" || quantityValue === ""){
        return false
      }
    } else {
      if (unitValue === "" || precisionValue ===""){
        return false
      }
    }
    return true
  }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
