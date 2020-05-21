import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Controls.Material 2.12
import QtCharts 2.3

ChartView {
  id: root

 legend.visible : false
 theme : ChartView.ChartThemeBlueCerulean
 titleFont.pointSize : 12
 titleFont.bold : true

 property alias xAxis : xAxis
 property alias yAxis : yAxis

 ValueAxis {
  id: xAxis
 }
 ValueAxis {
  id: yAxis
  labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
 }
  MouseArea {
  anchors.fill : parent
  acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: {
     console.log("CustomPLotsForm.clicked")
        if (mouse.button === Qt.RightButton){
           console.log("CustomPLotsForm.popup")
       contextMenu.popup()

    }
    }
    onPressAndHold: {
        if (mouse.source === Qt.MouseEventNotSynthesized)
            contextMenu.popup()
    }
  Menu {
      id: contextMenu
      Label { text: "Refresh Rate"; font.pixelSize: 16;    font.bold: true}
      Row{RadioButton{ id:range_1; text: "Low"; checked: true} RadioButton{id:range_2; text: "Normal"} RadioButton{id:range_3; text: "High"}}
  }
 }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
