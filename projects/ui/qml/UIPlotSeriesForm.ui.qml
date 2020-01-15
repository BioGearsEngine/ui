import QtQuick.Controls 2.12
import QtQuick 2.12
import QtQuick.Controls.Material 2.12
import QtCharts 2.3

ChartView {
    id: root
	legend.visible : false

	ValueAxis {
		id: xAxis
		property int tickCount : 0
		titleText : "Simulation Time (min)"
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

	function signalTest(metrics){
		var time = metrics.simulationTime
		var prop = metrics[root.title]
		//console.log(time + "," + prop);
		lSeries.append(time, prop)
		//console.log(lSeries.at(0))
		++xAxis.tickCount
		updateYScale(prop)
	}

	function updateYScale(newY){
		if (newY < lSeries._minY){
			lSeries._minY = Math.floor(newY)
		}
		if (newY > lSeries._maxY){
			lSeries._maxY = Math.ceil(newY)
		}
	}

}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
