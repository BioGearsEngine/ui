import QtQuick 2.12
import QtQuick.Window 2.12
import QtQml.Models 2.2

UIActionSwitchForm {
	id: root
    property int scrollCount : 0
    signal toggleActionOn()
    signal toggleActionOff()


    actionSwitch.onPositionChanged : {
        if(actionSwitch.position == 1){
            root.toggleActionOn();
        }
        else {
            root.toggleActionOff();
        }
    }

    labelHoverArea.onEntered : {
        scrollTimer.restart()
    }

    labelHoverArea.onExited : {
        scrollTimer.stop()
        actionLabel.text = root.name
        scrollCount = 0
    }

    scrollTimer.onTriggered : {
        if (actionLabel.truncated){
            scrollCount++;
            actionLabel.text = root.name.substring(scrollCount, root.name.length)
        }
        else {
            scrollTimer.stop();
        }
    }
}
