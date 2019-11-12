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

    Row {
        height: 10
        Layout.fillWidth: true
    }

    UIPatientBox {
        id: patientBox
        label: "Scenario"
        //value: "Default Adult Male"
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
            // Layout.preferredWidth: 75
            // Layout.preferredHeight: 25
        }
        UITextInputForm {
            id: gender
            name: "Gender:"
            value: "Female"
            Layout.alignment: Qt.AlignHCenter
            // Layout.preferredWidth: 80
            // Layout.preferredHeight: 25
        }
        UITextInputForm {
            id: fat_pct
            name: "Fat%:"
            value: "0.0%"
            Layout.alignment: Qt.AlignHCenter
            // Layout.preferredWidth: 75
        }
        UITextInputForm {
            id: core_temp
            name: "Temp:"
            value: "100.0"
            Layout.alignment: Qt.AlignHCenter
            // Layout.preferredWidth: 75
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
            // Layout.preferredWidth: 75
        }
        UITextInputForm {
            id: weight
            name: "Weight:"
            value: "Male"
            Layout.alignment: Qt.AlignHCenter
            // Layout.preferredWidth: 75
        }
        UITextInputForm {
            id: bodySurfaceArea
            name: "BSA:"
            value: "1.55"
            Layout.alignment: Qt.AlignHCenter
            // Layout.preferredWidth: 75
        }
        UITextInputForm {
            id: bodyMassIndex
            name: "BMI:"
            value: "36.2"
            Layout.alignment: Qt.AlignHCenter
            // Layout.preferredWidth: 75
        }
    }

    UIControlPhysiology {
        id: physiology
        Layout.fillWidth: true
        Layout.preferredWidth: parent.width
    }

    UIPlaybackForm {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillWidth: true
    }

    GridLayout {
        Layout.preferredWidth: parent.width
        Layout.fillWidth: true
        columns: 2
        Button {
            text: 'Action 1'
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
        }
        Button {
            text: 'Action 2'
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
        }
        Button {
            text: 'Action 3'
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
        }
        Button {
            text: 'Action 4'
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
        }
        Button {
            text: 'Action 5'
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
        }
        Button {
            text: 'Action 6'
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
        }
        Button {
            text: 'Action 7'
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 100
        }
    }
}
