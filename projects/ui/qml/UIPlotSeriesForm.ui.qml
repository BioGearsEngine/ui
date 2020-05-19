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
    property int tickCount : 0
    titleText : "Simulation Time (min)"
    min: 0
    max : windowWidth_min
  }
  ValueAxis {
    id: yAxis
    labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
  }
  MouseArea {
    anchors.fill : parent
    anchors.centerIn : parent
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
    Rectangle{
    anchors.fill :parent
        color: 'transparent'
    border.color: 'yellow'
    }
    Menu {
        id: contextMenu
        MenuItem { text: "Cut" }
        MenuItem { text: "Copy" }
        MenuItem { text: "Paste" }
        CheckBox { text : "Manual Range"}
        Row{ Label{ text: "Y-MIN"} TextInput{ }}
        MenuSeparator {}
        UIUnitScalarEntry{}

    }
    Component.onCompleted: {
      console.log("Made a Mouse Area")
    }
  }
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
