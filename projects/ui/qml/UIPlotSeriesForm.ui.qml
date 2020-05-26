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

  property bool   calculateScale : true;

  property alias  timeInterval_m : contextMenu.timeInterval
  property alias  refresh_rate   : contextMenu.refresh_rate
  property alias  autoScaleEnabled : contextMenu.autoScaleEnabled
  property alias  userSpecifiedMin : contextMenu.userSpecifiedMin
  property alias  userSpecifiedMax : contextMenu.userSpecifiedMax
  
  property alias speed_1hz : speed_lhz 
  property alias speed_5hz : speed_5hz 
  property alias speed_10hz : speed_10hz 
  property alias speed_5s : speed_5s
  property alias speed_10s : speed_10s 

  localizeNumbers: true
  ValueAxis {
    id: xAxis
    property int tickCount : 2
    titleText: "Simulation Time (min)"
    min: 0
    max: timeInterval_m
  }
  ValueAxis {
    id: yAxis
    //d, e, E, f, g, G, 
    labelFormat: (max < 1.)? '%.3f' : (max < 10.)? '%.2f' : (max < 100.) ?  '%.1f' : (max < 10000.) ?  '%.0f' : '%.2e'
    tickCount : 3
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

      property int timeInterval :  (range_1.checked) ? 1 : (range_5.checked) ? 5 : (range_10.checked) ? 10 : 1
      property int refresh_rate :  (speed_lhz.checked) ? 1 : (speed_5hz.checked) ? 5 : (speed_10hz.checked) ? 
                              10 : (speed_5s.checked) ? -5 : (speed_10s.checked) ? -10 : 1
      property alias autoScaleEnabled : autoEnabled.checked
      property double userSpecifiedMin : yAxis.min
      property double userSpecifiedMax : yAxis.max

      Label { text: "Refresh Rate"; font.pixelSize: 16;    font.bold: true}
      ButtonGroup { id: rateGroup }
      Row{ 
        id: rateRow1; 
        RadioButton{id:speed_lhz; text: "1hz"; checked: true; ButtonGroup.group:rateGroup} 
        RadioButton{id:speed_5hz; text: "5hz"; ButtonGroup.group:rateGroup} 
        RadioButton{id:speed_10hz; text: "10hz"; ButtonGroup.group:rateGroup}
      }
      Row{
        id: rateRow2;  
        RadioButton{id:speed_5s; text: "5s"; ButtonGroup.group:rateGroup} 
        RadioButton{id:speed_10s; text: "10s"; ButtonGroup.group:rateGroup}
      }
      Label { text: "Time Scale"; font.pixelSize: 16;    font.bold: true}
        Row{RadioButton{ id:range_1; text: "1  min"} 
        RadioButton{id:range_5; text: "5 min"} 
        RadioButton{id:range_10; text: "10 min"; 
        checked: true}}
      MenuSeparator {}
      Label { text : "Scaling"; font.pixelSize: 16;    font.bold: true }
      CheckBox { id: autoEnabled; text: "Automatic"; checked: true}
      GridLayout{ 
        columns : 4
        rows : 2
        anchors.left : parent.left ; anchors.right: parent.right; 
        Label{  
          font.pixelSize: 14
          font.italic: true
          text: "Min" 
          Layout.columnSpan: 2
          Layout.alignment: Qt.AlignHCenter|Qt.AlignVCenter
        }  
        Label{  
          font.pixelSize: 14  
          font.italic: true 
          text: "Max"
          Layout.columnSpan: 2
          Layout.alignment:Qt.AlignHCenter|Qt.AlignVCenter
        }
        TextField{  
          text: (contextMenu.autoScaleEnabled) ? "%1".arg(yAxis.min) : userSpecifiedMin;
          horizontalAlignment: TextInput.AlignHCenter
          Layout.alignment:Qt.AlignHCenter|Qt.AlignVCenter
          Layout.preferredWidth  : 50
          maximumLength : 7
          enabled : ! contextMenu.autoScaleEnabled
          onEditingFinished:{
            userSpecifiedMin = parseFloat(text)
          }
        } 
        Label{  
          font.pixelSize: 10  
          font.bold: true 
          text: yAxis.titleText
          Layout.alignment:Qt.AlignHCenter|Qt.AlignVCenter
        }
        TextField{  
          text: (contextMenu.autoScaleEnabled) ? "%1".arg(yAxis.max) : userSpecifiedMax
          horizontalAlignment: TextInput.AlignHCenter
          Layout.alignment:Qt.AlignHCenter|Qt.AlignVCenter
          Layout.preferredWidth  : 50
          maximumLength : 7
          enabled : ! contextMenu.autoScaleEnabled
          onEditingFinished:{
            userSpecifiedMax = parseFloat(text)
          }
        }
        Label{  
          font.pixelSize: 10
          font.bold: true 
          text: yAxis.titleText
          Layout.alignment:Qt.AlignHCenter|Qt.AlignVCenter
        }
      }
    }
  }
}


/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
