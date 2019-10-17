import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick 2.12
import QtQuick.Controls.Material 2.12

GridLayout {
    id: gridLayout
    layoutDirection: Qt.LeftToRight
    antialiasing: false

    height: implicitHeight + 20
    width: implicitWidth + 20

    columns: 2
    rows: 2

    UIScalarForm {
        Layout.alignment: Qt.AlignHCenter
        Layout.margins: 0
        name: "HR"
        value: "75"
    }
    UIScalarForm {
        Layout.alignment: Qt.AlignHCenter
        Layout.margins: 0
        name: "SBP"
        value: "110"
    }
    UIScalarForm {
        Layout.alignment: Qt.AlignHCenter
        name: "RR"
        value: "12"
    }
    UIScalarForm {
        Layout.alignment: Qt.AlignHCenter
        name: "DBP"
        value: "68"
    }
    UIScalarForm {
        Layout.alignment: Qt.AlignHCenter
        name: "SAT"
        value: "99"
    }
    UIScalarForm {
        Layout.alignment: Qt.AlignHCenter
        name: "Conditon"
        value: "Running"
    }
}




/*##^## Designer {
    D{i:0;width:300}
}
 ##^##*/
