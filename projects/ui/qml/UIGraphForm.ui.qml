import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Controls.Material 2.12
import QtCharts 2.3

ChartView {
    theme: ChartView.ChartThemeBlueCerulean
    property alias eatVal: eatSlice.value
    property alias eatColor: eatSlice.color
    property alias notEatColor: notEatSlice.color

    PieSeries {
        id: pieSeries
        PieSlice {
            id: eatSlice
            label: "eaten"
            color: "green"
            value: 94.9
        }
        PieSlice {
            id: notEatSlice
            label: "not yet eaten"
            color: "yellow"
            value: 100.0 - eatSlice.value
        }
    }
}




/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
