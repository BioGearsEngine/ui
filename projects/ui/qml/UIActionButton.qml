import QtQuick 2.12
import QtQuick.Window 2.12
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

UIActionButtonForm {
	id: root

	signal actionClicked(string name)
	signal actionHoverToggle(string name, bool hoverStatus, string actionStatus, var coor)
    signal actionActiveToggle(string name, string status)

	actionButton.onClicked : {
        root.actionClicked(root.name)
        root.active = !root.active
    }

    actionButton.onHoveredChanged : {
        if (actionButton.hovered) {
            delayTimer.start()
        }
        else {
            root.actionHoverToggle(root.name, actionButton.hovered, "", Qt.point(0,0))
        }
    }

    delayTimer.onTriggered : {
        var coor = actionButton.mapToItem(root.parent, root.width / 4, root.height * 0.8)
        var status = root.active ? "Active" : "Inactive"
        root.actionHoverToggle(root.name, actionButton.hovered, status, coor)
    }

    //Ideally this functionality would be triggered by the actionClicked signal.  But that signal passes args directly corresponding create_scenario function,
    //which only takes name arg at this point.  So trying to have actionClicked also emit status causes create_scenario function to err
    onActiveChanged : {
        var status = root.active ? "Active" : "Inactive"
        actionActiveToggle(root.name, status);
    }

    
}
