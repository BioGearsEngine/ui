import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick 2.12
import QtQuick.Controls.Material 2.12

import com.biogearsengine.ui.scenario 1.0

ColumnLayout {
    id: root
    spacing: 5

    Layout.preferredHeight: implicitHeight
    Layout.preferredWidth: implicitWidth

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
    property alias action_1 : action_1
    property alias action_2 : action_2
    property alias action_3 : action_3
    property alias action_4 : action_4
    property alias action_5 : action_5
    property alias action_6 : action_6
    property alias action_7 : action_7
    property alias explorer : actionExplorer

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

    GridLayout {
        Layout.preferredWidth: parent.width
        Layout.fillWidth: true
        columns: 2
        Button {
            id : action_1
            text: 'Hemorrhage Stop'
            font.pixelSize: Qt.application.font.pixelSize * 0.8
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
        }
        Button {
            id : action_2
            text: 'Hemorrhage Mild '
            font.pixelSize: Qt.application.font.pixelSize * 0.8
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
        }
        Button {
            id : action_3
            text: 'Hemorrhage Extreme'
            font.pixelSize: Qt.application.font.pixelSize * 0.8
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
        }
        Button {
            id : action_4
            text: 'Asthma Attack'
            font.pixelSize: Qt.application.font.pixelSize * 0.8
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
        }
        Button {
            id : action_5
            text: 'Morphine Drip'
            font.pixelSize: Qt.application.font.pixelSize * 0.8
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
        }
        Button {
            id : action_6
            text: 'Burn Patient 25%'
            font.pixelSize: Qt.application.font.pixelSize * 0.8
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
        }
        Button {
            id : action_7
            text: 'Mild Infection'
            font.pixelSize: Qt.application.font.pixelSize * 0.8
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
        }
        Button {
            id : actionExplorer
            text : 'Action Explorer'
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
         } 
    }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/