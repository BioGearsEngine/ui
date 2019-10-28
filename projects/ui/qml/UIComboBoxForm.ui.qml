import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.12
import QtQuick.Controls.Material 2.3

RowLayout {
    id: root

    property alias label: name
    property alias comboBox: value

    Layout.preferredWidth: 50
    Label {
        id: name
        text: "Unset"
        font.pointSize: 10
        font.weight: Font.DemiBold
        font.bold: false
    }

    ComboBox {
        id: value
        font.weight: Font.Medium
        font.pixelSize: 10
        editable: true
    }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:0;width:0}
}
 ##^##*/
