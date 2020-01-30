import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick 2.12
import QtQuick.Controls.Material 2.12
import QtQml.Models 2.2

import com.biogearsengine.ui.scenario 1.0

ColumnLayout {
    id: root
    spacing: 5
    Layout.preferredHeight: implicitHeight
    Layout.preferredWidth: implicitWidth

    property ObjectModel actionModel : actionButtonModel
    property alias patientBox: patientBox
    property alias age_yr: age
    property alias gender: gender
    property alias fat_pct: fat_pct
    property alias core_temp_c: core_temp
    property alias height_cm: height_cm
    property alias weight_kg: weight
    property alias bodySufaceArea: bodySurfaceArea
    property alias bodyMassIndex: bodyMassIndex

    property alias heartRate : physiology.heartRate
    property alias systolicBloodPressure : physiology.systolicBloodPressure
    property alias dystolicBloodPressure : physiology.dystolicBloodPressure
    property alias respritoryRate : physiology.respritoryRate
    property alias oxygenSaturation : physiology.oxygenSaturation
    property alias condition : physiology.condition


    property alias playback : playback_controls
    property alias drawerToggle : drawerToggle

    Row {
        height: 10
        Layout.fillWidth: true
    }

    UIPatientBox {
        id: patientBox
        label: "Patient"
        Layout.alignment: Qt.AlignHCenter
    }

    RowLayout {
        // columns: 4
        // rows: 2
        id: configuration_row1
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        UITextInputForm {
            id: age
            name: "Age:"
            value: "21"
            Layout.alignment: Qt.AlignHCenter
        }
        UITextInputForm {
            id: gender
            name: "Gender:"
            value: "Female"
            Layout.alignment: Qt.AlignHCenter
        }
        UITextInputForm {
            id: fat_pct
            name: "Fat%:"
            value: "0.0%"
            Layout.alignment: Qt.AlignHCenter
        }
        UITextInputForm {
            id: core_temp
            name: "Temp:"
            value: "100.0"
            Layout.alignment: Qt.AlignHCenter
        }
    }
    RowLayout {
        id:configuration_row2
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        UITextInputForm {
            id: height_cm
            name: "Height:"
            value: "160"
            Layout.alignment: Qt.AlignHCenter
        }
        UITextInputForm {
            id: weight
            name: "Weight:"
            value: "Male"
            Layout.alignment: Qt.AlignHCenter
        }
        UITextInputForm {
            id: bodySurfaceArea
            name: "BSA:"
            value: "1.55"
            Layout.alignment: Qt.AlignHCenter
        }
        UITextInputForm {
            id: bodyMassIndex
            name: "BMI:"
            value: "36.2"
            Layout.alignment: Qt.AlignHCenter
        }
    }

    UIControlPhysiology {
        id: physiology
        Layout.fillWidth: true
        Layout.preferredWidth: parent.width
    }

    UIPlaybackForm {
        id: playback_controls
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillWidth: true
    }

    Button {
            id : drawerToggle
            text : 'Action Explorer'
            Layout.preferredWidth: root.width
            Layout.alignment: Qt.AlignHCenter
     }

     Item {
        id : actionButtonWrapper
        Layout.preferredWidth : root.width
        Layout.preferredHeight : 200
        

        GridView {
            id : actionButtonView
            clip: true
            anchors.fill : parent
            cellWidth : root.width / 2
            cellHeight : 60
            model : actionButtonModel
        }

        ObjectModel {
            id : actionButtonModel
            function addButton(menuElement) {
                var actionComponent = Qt.createComponent("UIActionButton.qml");
					if ( actionComponent.status != Component.Ready){
						if (actionComponent.status == Component.Error){
							console.log("Error : " + chartComponent.errorString() );
							return;
						}
						console.log("Error : Chart component not ready");
					} else {
						var actionObject = actionComponent.createObject(actionButtonView,{ "name" : menuElement.name, "width" : actionButtonView.cellWidth, "height" : actionButtonView.cellHeight });
						actionObject.actionClicked.connect(menuElement.func);
						actionButtonModel.append(actionObject);
					}
            }
        }
     }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/