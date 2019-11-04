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

    property Scenario scenario
    Row {
        height: 10
        Layout.fillWidth: true
    }

    UIPatientBox {
        label.text: "Scenario"
        //value: "Default Adult Male"
        Layout.alignment: Qt.AlignHCenter
        scenario: root.scenario
    }

    GridLayout {
        columns: 4
        rows: 2
        id: configuration
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignHCenter
        UITextInputForm {
            name: "Age:"
            value: "22"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 75
            Layout.preferredHeight: 25
        }
        UITextInputForm {
            name: "Gender:"
            value: "Male"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 75
            Layout.preferredHeight: 25
        }
        UITextInputForm {
            name: "Fat%:"
            value: "22.5"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 75
        }
        UITextInputForm {
            name: "Temp:"
            value: "36.2"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 75
        }

        UITextInputForm {
            name: "Height:"
            value: "22"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 75
        }
        UITextInputForm {
            name: "Weight:"
            value: "Male"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 75
        }
        UITextInputForm {
            name: "BSA%:"
            value: "22.5"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 75
        }
        UITextInputForm {
            name: "BSA:"
            value: "36.2"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 75
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