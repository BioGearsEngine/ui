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
        scenario : scenario
        Component.onCompleted : {
            console.log ("Starting Biogears with %1".arg(scenario.patient_name()))
        }
    }

    Scenario {
        id : scenario
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
                text : "
                       <b>BioGears %1</b><br>
                       Based on Qt %2   %3<br>
                                libBioGears %4<br>
                       Built on %5<br>
                       From revision %6<br>
                       Copyright 2012-%7 Applied Research Associates<br>
                       <br>
                       This program is provided AS IS with NO WARRENTY OF ANY KIND<br>
                       INCLUDING THE WARRANTY OF DESIGN, MERCHANTABILITY AND FITNESS<br>
                       FOR A PARTICULAR PURPOSE<br>
                       ".arg(scenario.ui_version()).arg("5.12").arg("MSVC 2017")
                        .arg(scenario.lib_version()).arg(scenario.ui_builddate).arg(scenario.ui_hash())
                        .arg(Date.fromLocalDateString(Date()))
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





