import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick 2.12
import QtQuick.Controls.Material 2.12

GridLayout {
    id: root
    layoutDirection: Qt.LeftToRight
    antialiasing: false
    columns: 3
    rows: 2
    columnSpacing : 45
    rowSpacing : 10

    property alias heartRate : heartRate
    property alias systolicBloodPressure : systolicBloodPressure
    property alias dystolicBloodPressure : dystolicBloodPressure
    property alias respiratoryRate : respiratoryRate
    property alias oxygenSaturation : oxygenSaturation
    property alias condition : condition

    UIScalarForm {
        id:heartRate
        Layout.alignment: Qt.AlignHCenter
        Layout.margins: 0
        name: "HR"
        value: "75"
    }
    UIScalarForm {
        id:systolicBloodPressure
        Layout.alignment: Qt.AlignHCenter
        Layout.margins: 0
        name: "SBP"
        value: "110"
    }
    UIScalarForm {
        id:respiratoryRate
        Layout.alignment: Qt.AlignHCenter
        name: "RR"
        value: "12"
    }
    UIScalarForm {
        id:dystolicBloodPressure
        Layout.alignment: Qt.AlignHCenter
        name: "DBP"
        value: "68"
    }
    UIScalarForm {
        id:oxygenSaturation
        Layout.alignment: Qt.AlignHCenter
        name: "SAT"
        value: "99"
    }
    UIScalarForm {
        id:condition
        Layout.alignment: Qt.AlignHCenter
        name: "Conditon"
        value: "Running"
    }
}




/*##^## Designer {
    D{i:0;width:300}
}
 ##^##*/
