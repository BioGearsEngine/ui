import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls.Material 2.12
ApplicationWindow {
    visible: true

    Material.theme: Material.Light
    Material.accent: Material.LightBlue

    width: 1040
    height: 780

    MainForm {
        anchors.fill : parent
    }
}

