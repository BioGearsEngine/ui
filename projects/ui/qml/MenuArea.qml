import QtQuick 2.4
import com.biogearsengine.ui.scenario 1.0

MenuAreaForm {
  id : root
  signal stateLoadedFromMenu()

  saveAsDialog.onAccepted : {
    if (saveAsDialog.fileUrl){
      scenario.save_state(saveAsDialog.fileUrl)
    } else {
      console.log('Error')
    }
  }
  
  openDialog.onAccepted : {
    if (openDialog.fileUrl) {
      scenario.restart(openDialog.fileUrl)
      root.stateLoadedFromMenu()
    }
  }


}
