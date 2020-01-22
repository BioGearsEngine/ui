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
	property alias lSeries : lSeries

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

	/*function initializeChart (request, tickCount) {
		xAxis.tickCount = tickCount
		setPlotTitle(request)
		root.requestName = request
		yAxis.titleText = "Unit Placeholder"
	}

	function setPlotTitle(title){
		//Function assumes that input title is camel case (i.e. arterialBloodPH)
		//Expression ([a-z])([A-Z]) searches for lower case letter followed by upper case (this way, something like "PH" isn't split into "P H").  
		//Parenthesis around each range capture the value in string, which we can call using $ syntax.  '$1 $2' means put a space between the first captured value (lower) and second captured value (upper)
		var plotTitle = title.replace(/([a-z])([A-Z])/g, '$1 $2')
		//Next, make sure that first character is upper case.  ^[a-z] specifies that we are only looking at leading character.
		plotTitle = plotTitle.replace(/^[a-z]/, u=>u.toUpperCase());
		root.title = plotTitle
	}

	function updateSeries(metrics){
		var time = metrics.simulationTime / 60;
		var prop = metrics[root.requestName];
		lSeries.append(time, prop);
		updateDomainAndRange(prop)
	}

	function updateDomainAndRange(newY){
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
	}*/
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
