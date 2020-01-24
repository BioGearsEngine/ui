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
		max : 10
	}
	ValueAxis {
		id: yAxis
		min: 0
		labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
	}

}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
