import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls.Material 2.3
import com.biogearsengine.ui.scenario 1.0

UISubstanceEntryForm {
  id: root

  signal inputAccepted (var input)
  signal substanceUpdateRejected(string previousName) //Emitted if we try to set a component that already exists
 
  onSubstanceUpdateRejected : {
    root.substanceInput.currentIndex = root.substanceInput.find(previousName)
  }

  function setEntry( fromInput ){
    //Component input is [substance, concentration, unit].  Trim concentration down to 2 decimal place.  When setting 
    // based off values loaded from file, we get strings from the text field.  Thus, we check typeof input before trimming.
    if (fromInput[0]!=null && typeof fromInput[1]=="number"){
      let formattedValue = fromInput[1].toFixed(2)
      fromInput[1] = formattedValue
    }
    root.entry.setFromExisting(fromInput)
  }

  function setComponentList() { 
   let components = scenario.get_components()
    for (let i = 0; i < components.length; ++i){
      let element = { "component" : components[i] }
      componentListModel.append(element)
    }
  }

  function reset(){
    root.entry.reset()
  }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
