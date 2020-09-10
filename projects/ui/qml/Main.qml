import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.2

import QtGraphicalEffects 1.12

import com.biogearsengine.ui.scenario 1.0


ApplicationWindow {
    id: root
    visible: true

    width: 1280
    height: 768

    MainForm {
        anchors.rightMargin: 0
        anchors.bottomMargin: 1
        anchors.leftMargin: 0
        anchors.topMargin: -1
        anchors.fill : parent
        Component.onCompleted : {
        }
        controls.onPlayClicked:  {
          graphArea.start()
        }
        controls.onPauseClicked: {
          graphArea.pause(paused)
        }
        controls.onRestartClicked: {
          graphArea.restart()
        }
        controls.onSpeedToggled: {
          graphArea.speedToggled(speed)
        }
        controls.onOpenActionDrawer: {
          actionDrawer.openActionDrawer();
        }
		controls.onPatientPhysiologyChanged : {
			graphArea.newPhysiologyModel(model)
		}
	  
		controls.onUrinalysisDataChanged : {
			graphArea.urinalysis = controls.urinalysisData
		}
		graphArea.onUrinalysisRequest : {
			controls.requestUrinalysis()
		}
    }

    Info {
        id : info
    }

    footer: RowLayout {
        layoutDirection: Qt.RightToLeft
        Image {
            id: help
            Layout.bottomMargin: 4
            Layout.rightMargin: 4
            source : "icons/help.svg"
            sourceSize.width : 10
            sourceSize.height: 10
            MouseArea {
                anchors.fill : help
                onClicked: {  infoBox.open() }
            }
        }
        Popup {
            id: infoBox
            width: 500; height: 300
            parent: Overlay.overlay
            anchors.centerIn: Overlay.overlay
            closePolicy: Popup.CloseOnEscape
            Image {
                id: infoBox_image
                source : "icons/biogears_logo.png"
                sourceSize.width : 100
                sourceSize.height: 100
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                id: infoBox_text
                anchors.left: infoBox_image.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 5
                text : info.About
            }
            Button {
                id: infoBox_button
                text : "Ok!"
                onClicked: infoBox.close()
                anchors.bottom : parent.bottom
                anchors.right: parent.right
            }
        }
    }
}





