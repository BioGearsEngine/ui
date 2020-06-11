import QtQuick.Controls 2.12
import QtQuick 2.12

import com.biogearsengine.ui.scenario 1.0

Row {
    id : actionRow
    spacing : 5
    property string nameLong
    property string namePretty
    property bool active : false
    property alias actionSwitch : actionSwitch
    property alias labelMouseArea : labelMouseArea
    property alias actionLabel : actionLabel

    Label {
        id : actionLabel
        width : parent.width * 3/4 - actionRow.spacing / 2
        height : parent.height * 0.9
        color : '#1A5276'
        text : actionRow.namePretty
        elide : Text.ElideRight
        font.pointSize : 12
        font.bold : true
        horizontalAlignment  : Text.AlignLeft
        leftPadding : 5
        verticalAlignment : Text.AlignVCenter
        background : Rectangle {
            id : labelBackground
            anchors.fill : parent
            color : 'transparent'
            border.color : 'grey'
            border.width : 0
        }
        MouseArea {
            id : labelMouseArea
            anchors.fill : parent
            acceptedButtons : Qt.RightButton
        }
        ToolTip {
          id : actionTip
          parent : actionLabel
          x : 0
          y : parent.height + 5
          visible : labelMouseArea.pressed
          text : actionRow.nameLong
          contentItem : Text {
            text : actionTip.text
            color : '#1A5276'
            font.pointSize : 10
          }
          background : Rectangle {
            color : "white"
            border.color : "black"
          }
        }
        
    }
    Switch {
        id : actionSwitch
        width : parent.width * 1/4 - actionRow.spacing / 2
        height : parent.height
        position : 0
    }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
 