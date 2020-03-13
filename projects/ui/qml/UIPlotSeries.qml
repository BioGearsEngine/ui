import QtQuick 2.12
import QtCharts 2.3

UIPlotSeriesForm {
  id: root

  property int windowWidth_min : 10
  property var requestNames : []

  //Sets tickCount equal to global value (so that plot always knows time at which it started) and initializes request name that will be used to pull data from metrics object
  //Each requestElement is {request: "requestName" ; active: "true"; subRequests: []}.  If subRequests exists, we add a series for each subRequest.  Otherwise, we use the request name
  function initializeChart (requestElement, tickCount) {
    if(requestElement.subRequests){
      for (let i = 0; i < requestElement.subRequests.count; ++i){
        let subRequest = requestElement.subRequests.get(i).subRequest
        let series = root.createSeries(ChartView.SeriesTypeLine, formatRequest(subRequest), xAxis, yAxis);
        root.requestNames.push(subRequest)
      }
      root.legend.visible = true
    } else {
      let series = root.createSeries(ChartView.SeriesTypeLine, requestElement.request, xAxis, yAxis);
      yAxis.visible = false
      root.requestNames.push(requestElement.request);
    }
    xAxis.tickCount = tickCount;
    root.title = formatRequest(requestElement.request);
    yAxis.titleText = "Unit Placeholder";
  }

  //Takes request (or subrequest) name (in camel case) and converts to normal format, e.g. systolicArterialPressure -> Systolic Arterial Pressure, for clear plot title and lengend labels
  function formatRequest(request){
    //Expression ([a-z])([A-Z]) searches for lower case letter followed by upper case (this way, something like "PH" isn't split into "P H").  
    //Parenthesis around each range capture the value in string, which we can call using $ syntax.  '$1 $2' means put a space between the first captured value (lower) and second captured value (upper)
    let formatted = request.replace(/([a-z])([A-Z])/g, '$1 $2')
    //Next, make sure that first character is upper case.  ^[a-z] specifies that we are only looking at leading character.
    formatted = formatted.replace(/^[a-z]/, u=>u.toUpperCase());
    return formatted
  }

  //Gets simulation time and physiology data request from patient metrics, appending new point to each series
  function updatePatientSeries(metrics){
    let time = metrics.SimulationTime / 60;
    if (root.count>1){
      for (let i = 0; i < root.count; ++i){
        let subRequest = root.requestNames[i]
        let prop = metrics[subRequest]
        //Need to grab the formatted request since sub-series use that version to make the legend labels look good.  Could loop through by index number, but this seems safer
        root.series(formatRequest(subRequest)).append(time,prop)
      }
    } else {
      let prop = metrics[root.requestNames[0]];
      root.series(root.requestNames[0]).append(time,prop)
    }
    updateDomainAndRange()
    if (!yAxis.visible){
      yAxis.visible = true
    }
  }

  //Gets simulation time and substance data request from substance metrics, appending new point to each series
  function updateSubstanceSeries(time, subData){
    //Substance request names stored as (e.g.) Sodium-BloodConcentration.  Split at '-' to get substance (key) and property (object)
    let requestComponents = root.requestNames[0].split('-')
    let substance = requestComponents[0]
    let propName = requestComponents[1]
    let prop = subData[substance][propName]
    root.series(root.requestNames[0]).append(time/60.0, prop)
    updateDomainAndRange();
    if (!yAxis.visible){
      yAxis.visible = true
    }
  }


  //Gets simulation time and physiology data request from patient metrics, appending new point to each series
  function clear(){
    if (root.count>1){
      for (let i = 0; i < root.count; ++i){
        let series = root.series(formatRequest(root.requestNames[i]))
        series.removePoints(0, series.count)
      }
    } else {
      let series = root.series(root.requestNames[0])
      series.removePoints(0, series.count)
    }

    updateDomainAndRange()
  }

  //Moves x-axis range if new data point is out of specified windowWidth and removes points no longer in visible range.  Update yAxis range according to min/max y-values
  function updateDomainAndRange(){
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
    //Range -- loop over series in the event that there are multiple defined for a chart
    for (let i = 0; i < root.count; ++i){
      let newY = root.series(i).at(root.series(i).count-1).y
      yAxis.min = Math.min(yAxis.min, Math.floor(0.9 * newY))
      yAxis.max = Math.max(yAxis.max, Math.ceil(1.1 * newY))
      //If the number of points in the series is greater than the number of points visible in the viewing window (assuming 1 pt per second), then remove the first point, which will always
      //be the one just outside the viewing area.  Note that we can't use tickCount for this or else we graphs that start later in simulation would have points removed almost immediately
      if (root.series(i).count > interval_s){
        root.series(i).remove(0)
      }
    }
  }

  //Updates plot size when the application window size changes
  function resizePlot(newWidth, newHeight){
    root.width = newWidth
    root.height = newHeight
  }



}
