import QtQuick 2.12
import QtQuick.Window 2.12
import QtQml.Models 2.2
import com.biogearsengine.ui.scenario 1.0

Rectangle {
    signal activate()
    signal deactivate()
    signal adjust( var list)

    color: "red"
    border.color: "black"
}