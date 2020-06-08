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

 property alias speed_1hz : speed_lhz 
 property alias speed_5hz : speed_5hz 
 property alias speed_10hz : speed_10hz 
 property alias speed_5s : speed_5s
 property alias speed_10s : speed_10s 

property alias  refresh_rate   : contextMenu.refresh_rate
 ValueAxis {
  id: xAxis
 }
 ValueAxis {
  id: yAxis
  labelFormat: (max < 1.)? '%.3f' : (max < 10.)? '%.2f' : (max < 100.) ?  '%.1f' : (max < 10000.) ?  '%.0f' : '%.2e'
  tickCount : 3
 }
  MouseArea {
    anchors.fill : parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: {
        if (mouse.button === Qt.RightButton){
           contextMenu.popup()
        }
    }
    onPressAndHold: {
        if (mouse.source === Qt.MouseEventNotSynthesized)
            contextMenu.popup()
    }
    Menu {
        id: contextMenu

        property int refresh_rate : rateGroup.checkedButton.rate

        Label { text: "Refresh Rate"; font.pixelSize: 16; font.bold: true}
        ButtonGroup { 
          id: rateGroup 
        }
        Row{ 
          id: rateRow1; 
          RadioButton{id:speed_lhz;  property int rate:  1; text: "1hz";  ButtonGroup.group:rateGroup; checked: true} 
          RadioButton{id:speed_5hz;  property int rate:  5; text: "5hz";  ButtonGroup.group:rateGroup} 
          RadioButton{id:speed_10hz; property int rate: 10; text: "10hz"; ButtonGroup.group:rateGroup}
        }
        Row{
          id: rateRow2;  
          RadioButton{id:speed_5s;  property int rate:  -5;  text: "5s" ; ButtonGroup.group:rateGroup} 
          RadioButton{id:speed_10s; property int rate: -10;  text: "10s"; ButtonGroup.group:rateGroup}
        }
    }
  }
}