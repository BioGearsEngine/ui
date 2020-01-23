import QtQuick 2.12


UIPlotSeriesForm {
	id: root

	property int windowWidth_min : 1
	property string requestName : ""

	//Sets tickCount equal to global value (so that plot always knows time at which it started) and initializes request name that will be used to pull data from metrics object
	function initializeChart (request, tickCount) {
		xAxis.tickCount = tickCount
		setPlotTitle(request)
		root.requestName = request
		yAxis.titleText = "Unit Placeholder"
	}

	//Takes request name (in camel case) and converts to normal format, e.g. systolicArterialPressure -> Systolic Arterial Pressure
	function setPlotTitle(request){
		//Expression ([a-z])([A-Z]) searches for lower case letter followed by upper case (this way, something like "PH" isn't split into "P H").  
		//Parenthesis around each range capture the value in string, which we can call using $ syntax.  '$1 $2' means put a space between the first captured value (lower) and second captured value (upper)
		var plotTitle = request.replace(/([a-z])([A-Z])/g, '$1 $2')
		//Next, make sure that first character is upper case.  ^[a-z] specifies that we are only looking at leading character.
		plotTitle = plotTitle.replace(/^[a-z]/, u=>u.toUpperCase());
		root.title = plotTitle
	}

	//Gets simulation time and physiology data request from patient metrics, appending new point to series
	function updateSeries(metrics){
		var time = metrics.SimulationTime / 60;
		var prop = metrics[root.requestName];
		lSeries.append(time, prop);
		updateDomainAndRange(prop)
	}

	//Moves x-axis range if new data point is out of specified windowWidth and removes points no longer in visible range.  Update yAxis range according to min/max y-values
	function updateDomainAndRange(newY){
		++xAxis.tickCount;
		const interval_s = 60 * root.windowWidth_min
		//Domain
		if(xAxis.tickCount > interval_s){
			xAxis.min = (xAxis.tickCount - interval_s) / 60;
			xAxis.max = xAxis.tickCount / 60
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
		//If the number of points in the series is greater than the number of points visible in the viewing window (assuming 1 pt per second), then remove the first point, which will always
		//be the one just outside the viewing area.  Note that we can't use tickCount for this or else we graphs that start later in simulation would have points removed almost immediately
		if (lSeries.count > interval_s){
			lSeries.remove(0)
		}
	}

	//Updates plot size when the application window size changes
	function resizePlot(newWidth, newHeight){
		root.width = newWidth
		root.height = newHeight
	}



}
