import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Controls.Material 2.12
import QtCharts 2.3

ChartView {
    id: root
	legend.visible : false
	theme : ChartView.ChartThemeBlueCerulean
	


	ValueAxis {
		id: xAxis
		property int tickCount : 0
		titleText : "Simulation Time (s)"
		min: 0
		max : 60
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

	function setChartTitle (title) {
		root.title = title
		setYAxisName(title)
	}

	function setYAxisName(name){
		yAxis.titleText = name
	}

	function updateSeries(metrics){
		var time = metrics.simulationTime;
		var prop = metrics[root.title];
		lSeries.append(time, prop);
		updateDomain()
		updateYScale(prop)
	}

	function updateDomain(){
		++xAxis.tickCount;
		const interval = 60 * 5
		if(xAxis.tickCount > interval){
			xAxis.min = xAxis.tickCount - interval;
			xAxis.max = xAxis.tickCount;
		} else {
			xAxis.min = 0
			xAxis.max=interval
		}

	}

	function updateYScale(newY){
		if (newY < lSeries._minY){
			lSeries._minY = Math.floor(0.9 * newY);
		}
		if (newY > lSeries._maxY){
			lSeries._maxY = Math.ceil(1.1 * newY);
		}
	}

}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
