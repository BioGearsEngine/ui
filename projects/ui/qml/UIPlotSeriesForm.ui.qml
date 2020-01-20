import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Controls.Material 2.12
import QtCharts 2.3

ChartView {
    id: root
	legend.visible : false
	theme : ChartView.ChartThemeBlueCerulean
	property int windowWidth_min : 1


	ValueAxis {
		id: xAxis
		property int tickCount : 0
		titleText : "Simulation Time (min)"
		min: 0
		max : 10
	}
	ValueAxis {
		id: yAxis
		min: lSeries._minY
		max: lSeries._maxY
		labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
	}

	LineSeries {
		id: lSeries
		axisX: xAxis
		axisY: yAxis

		property int _minY : 0
		property int _maxY : 1
	}

	function initializeChart (title, tickCount) {
		root.title = title
		xAxis.tickCount = tickCount
		setYAxisName(title)
	}

	function setYAxisName(name){
		yAxis.titleText = name
	}

	function updateSeries(metrics){
		var time = metrics.simulationTime / 60;
		var prop = metrics[root.title];
		lSeries.append(time, prop);
		updateDomainAndRange(prop)
	}

	function updateDomainAndRange(){
		++xAxis.tickCount;
		const interval_s = 60 * root.windowWidth_min
		//Domain
		if(xAxis.tickCount > interval_s){
			xAxis.min = (xAxis.tickCount - interval_s) / 60;
			xAxis.max = xAxis.tickCount / 60
			//Remove first point, which will always be just outside (to left) of viewing window after updating domain
			lSeries.remove(0)
		} else {
			xAxis.min = 0
			xAxis.max=interval_s / 60
		}
		//Range
		if (newY < lSeries._minY){
			lSeries._minY = Math.floor(0.9 * newY);
		}
		if (newY > lSeries._maxY){
			lSeries._maxY = Math.ceil(1.1 * newY);
		}
	}

	function resizePlot(newWidth, newHeight){
		root.width = newWidth
		root.height = newHeight
	}
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
