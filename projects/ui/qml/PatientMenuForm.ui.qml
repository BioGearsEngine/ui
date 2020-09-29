import QtQuick 2.12
import QtQuick.Controls 2.12
import com.biogearsengine.ui.scenario 1.0

Button {
  id: patientMenuButton
  property alias patientText : patientText
  property alias patientMenuListModel : patientMenuListModel
  flat: true
  highlighted: false
  implicitHeight : patientText.implicitHeight * 2
  background : Rectangle {
    anchors.fill : parent
    color : "lightgray"
  }
  Text {
    id : patientText
    anchors.fill : parent
    text : "Select Patient" // If you actually see this then something is very wrong
    font.capitalization : Font.MixedCase
    fontSizeMode : Text.Fit
    horizontalAlignment : Text.AlignHCenter
    verticalAlignment : Text.AlignVCenter
  }
  Menu {
    id : patientMenu
    x : -200
    y : 50
    closePolicy : Popup.CloseOnEscape | Popup.CloseOnReleaseOutside
    Instantiator {
      id : menuItemInstance
      model : patientMenuListModel
      delegate : Menu {
        id : patientSubMenu
        title : patientName
        property string patient : patientName
        property var repeaterModel : []   //Assign when object is added to instantiator to make sure that model exists
        Repeater {
          id : subMenuInstance
          model : repeaterModel
          delegate : MenuItem {
            Button { 
              anchors.fill : parent
              flat : true
              highlighted : false
              text : propName
              onClicked : {
                patientMenu.close()
                if (!biogears_scenario.isRunning || biogears_scenario.isPaused){ // This should be redundant with the check to open the Menu, but I'm including it to be safe
                  //Update text before loading state because menu checks text against new patient to determine whether
                  // the name is correct (this check catches instances when state is loaded via "File->Load" vs patient menu)
                  root.updateText(propName)
                  root.loadState(propName)
                }          
              }
            }
          }
        }
      }
      onObjectAdded : {
        object.repeaterModel = patientMenuListModel.get(index).props
        patientMenu.insertMenu(index, object)  
      }
      onObjectRemoved : {
        patientMenu.removeMenu(object)
      }
    }    
  }
  onClicked: {
    if (!biogears_scenario.isRunning || biogears_scenario.isPaused) {
      if (patientMenu.visible) {
        patientMenu.close()
      } else {
        patientMenu.open()
      }
    } 
  }

  ListModel {
    id : patientMenuListModel
  }
}
