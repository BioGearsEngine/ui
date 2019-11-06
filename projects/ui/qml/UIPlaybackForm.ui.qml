import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

ColumnLayout {
	id: root
	signal playActivated()
    RowLayout {
        spacing: 10
        Label {
            text: "Time:"
        }
        Text {
            text: "0:00:00"
        }
        Text {
            text: "Data"
        }
    }

    RowLayout {

        Button {
            id: stop
            text: "Stop"
            display: AbstractButton.IconOnly
            icon.source: "qrc:/icons/stop.png"
            icon.name: "terminate"
            icon.color: "transparent"
        }
        Button {
            id: pause
            text: "Pause"
            display: AbstractButton.IconOnly
            icon.source: "qrc:/icons/pause.png"
            icon.name: "pause"
            icon.color: "transparent"
        }
        Button {
            id: play
            text: "Realtime"
            display: AbstractButton.IconOnly
            icon.source: "qrc:/icons/play.png"
            icon.name: "realtime"
            icon.color: "transparent"
			onClicked: {root.playActivated()}
        }
        Button {
            id: foward
            text: "MaxSpeed"
            font.capitalization: Font.AllLowercase
            display: AbstractButton.IconOnly
            icon.source: "icons/foward.png"
            icon.name: "full-speed"
            icon.color: "transparent"
            Layout.preferredWidth: play.width
            Layout.preferredHeight: play.height
        }
    }
}




/*##^## Designer {
    D{i:0;height:62;width:271}
}
 ##^##*/
