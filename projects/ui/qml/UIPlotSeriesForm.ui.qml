import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.11
import QtCharts 2.3

ChartView {
  id: root
  legend.visible : false
  theme : ChartView.ChartThemeBlueCerulean
  titleFont.pointSize : 12
  titleFont.bold : true

  property alias xAxis : xAxis
  property alias yAxis : yAxis

  localizeNumbers: true
  ValueAxis {
    id: xAxis
    property int tickCount : 0
    titleText: "Simulation Time (min)"
    min: 0
    max: windowWidth_min
  }
  ValueAxis {
    id: yAxis
    labelFormat: (max < 1.)? '%0.3f' : (max < 10.)? '%0.2f' : (max < 100.) ?  '%0.1f' : (max < 1000.) ?  '%0d' : '%0.2e'
  }
  MouseArea {
    anchors.fill : parent
    anchors.centerIn : parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: {
        if (mouse.button === Qt.RightButton)
             contextMenu.popup()
    }
    onPressAndHold: {
        if (mouse.source === Qt.MouseEventNotSynthesized)
            contextMenu.popup()
    }
    Menu {
        id: contextMenu

        property int timeRange :  (range_1.checked) ? 1 : (range_5.checked) ? 5 : (range_10.checked) ? 3 : 10
        property int rate :  (speed_l.checked) ? 1 : (speed_n.checked) ? 2 : (speed_h.checked) ? 3 : 1
        property alias autoScaleEnabled : autoEnabled.checked
        property double userSpecifiedMin : yAxis.min
        property double userSpecifiedMax : yAxis.max

        Label { text: "Refresh Rate"; font.pixelSize: 16;    font.bold: true}
        Row{RadioButton{ id:speed_l; text: "Low"; checked: true} RadioButton{id:speed_n; text: "Normal"} RadioButton{id:speed_h; text: "High"}}
        Label { text: "Time Scale"; font.pixelSize: 16;    font.bold: true}
        Row{RadioButton{ id:range_1; text: "1  min"} RadioButton{id:range_5; text: "5 min"} RadioButton{id:range_10; text: "10 min"; checked: true}}
        MenuSeparator {}
        Label { text : "Scaling"; font.pixelSize: 16;    font.bold: true }
        CheckBox { id: autoEnabled; text: "Automatic"; checked: true}
        RowLayout{ spacing: 15; anchors.left : parent.left ; anchors.right: parent.right; 
          Label{  font.pixelSize: 14;  font.italic: true; text: "Max"; Layout.preferredWidth: 15}  
          TextField{  text: (autoScaledEnabled) ? "%1".arg(yAxis.max) : userSpecficiedMin; width: 15;  horizontalAlignment  : TextInput.AlignHCenter}}
        RowLayout{ spacing: 15; anchors.left : parent.left ; anchors.right: parent.right; 
          Label{  font.pixelSize: 14;  font.italic: true; text: "Min"; Layout.preferredWidth: 15}  
          TextField{  text: (autoScaledEnabled) ? "%1".arg(yAxis.min) : userSpecficiedMin; width: 15;  horizontalAlignment  : TextInput.AlignHCenter}}
    }
  }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
