import QtQuick.Controls 2.12
import QtQuick 2.12

import com.biogearsengine.ui.scenario 1.0

Row {
    id : actionRow
    spacing : 5
    property string name
    property bool active : false
    property alias actionSwitch : actionSwitch
    property alias scrollTimer : scrollTimer
    property alias labelHoverArea : labelHoverArea
    property alias actionLabel : actionLabel

    Label {
        id : actionLabel
        width : parent.width * 3/4 - actionRow.spacing / 2
        height : parent.height * 0.9
        color : '#1A5276'
        text : actionRow.name
        elide : Text.ElideRight
        font.pointSize : 12
        font.bold : true
        horizontalAlignment  : Text.AlignHCenter
        verticalAlignment : Text.AlignVCenter
        background : Rectangle {
            id : labelBackground
            anchors.fill : parent
            color : 'transparent'
            border.color : 'grey'
            border.width : 0
        }
        MouseArea {
            id : labelHoverArea
            anchors.fill : parent
            hoverEnabled : true
        }
    }
    Switch {
        id : actionSwitch
        width : parent.width * 1/4 - actionRow.spacing / 2
        height : parent.height
        position : 0
    }


    Timer {
        id : scrollTimer
        interval : 300; running : false; repeat : true
    }

}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 