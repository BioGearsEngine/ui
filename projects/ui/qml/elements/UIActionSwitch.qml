import QtQuick 2.12
import QtQuick.Window 2.12
import QtQml.Models 2.2

UIActionSwitchForm {
	id: root

  property int scrollCount : 0
  property bool supportDeactivate : true
  property bool activated : false
  signal toggleActionOn()
  signal toggleActionOff()


  actionSwitch.onPositionChanged : {
    if(actionSwitch.position == 1 && !activated){
      root.toggleActionOn();
      activated = !activated
    }
    else if (supportDeactivate) {
      root.toggleActionOff();
      activated = !activated
    }
    else {
      console.log('Action status cannot be changed once activated')
    }
  }

}
