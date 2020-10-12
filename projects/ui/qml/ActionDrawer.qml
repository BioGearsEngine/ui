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
}


