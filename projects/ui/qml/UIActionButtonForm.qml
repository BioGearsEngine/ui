import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.12

import com.biogearsengine.ui.scenario 1.0

Item {
    id : root
    property string name
    property bool active : false
    property alias actionButton : actionButton
    property alias delayTimer : delayTimer
    
    //When created by ActionObjectModel, UIActionButton will fill the available cell area
    //Wrapping the active button inside an item like this allows us to add some padding around the button
    //and center it in its cell
    Button {
        id : actionButton
        text : parent.name
        width : parent.width * 0.9
        height : parent.height * 0.9
        anchors.centerIn : parent
        hoverEnabled : true

        contentItem : Text {
            text : actionButton.text
            horizontalAlignment : Text.AlignHCenter
            verticalAlignment : Text.AlignVCenter
            elide: Text.ElideRight

        }

        background : Rectangle {
            width : actionButton.width
            height : actionButton.height
            color : root.active ? "#7CB342" : "lightgray"
            border.color : "black"
            border.width : 2
            radius : 20
        }
    }

    Timer {
        id : delayTimer
        interval : 2000; running : false; repeat : false
    }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
