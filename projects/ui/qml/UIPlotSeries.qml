import QtQuick 2.12
import QtCharts 2.3

import com.biogearsengine.ui.scenario 1.0
UIPlotSeriesForm {
  id: root

  property int windowWidth_min : 10
  property var requestNames : []
  property var model : null
  property var index : null
  property int rate  : 1
  //Sets tickCount equal to global value (so that plot always knows time at which it started) and initializes request name that will be used to pull data from metrics object
  //Each requestElement is {request: "requestName" ; active: "true"; subRequests: []}.  If subRequests exists, we add a series for each subRequest.  Otherwise, we use the request name
  function initializeChart (physiologyRequest, tickCount) {
     root.model = physiologyRequest.model
     root.index = physiologyRequest
     yAxis.titleText = model.data(root.index, PhysiologyModel.UnitRole)
     root.rate = model.data(index, PhysiologyModel.RateRole)
    
     if(root.model.rowCount(root.index)){
       if( root.model.data(root.index, PhysiologyModel.NestedRole)){
         //NOTE: We should not ever get here as GraphAreaForm.ui should have
         //      broken the nested ot individual calls, but 
       } else {
          requestNames = []
          for (let i = 0; i < root.model.rowCount(root.index); ++i){
            let subIndex = root.model.index(i,0,index)
            requestNames.push(model.data(subIndex,Qt.DisplayRole))
            let series = root.createSeries(ChartView.SeriesTypeLine, model.data(subIndex,Qt.DisplayRole), xAxis, yAxis);
          }
          root.legend.visible = true
       }
     } else  {
      //Common single line plot
      let series = root.createSeries(ChartView.SeriesTypeLine, model.data(index,Qt.DisplayRole), xAxis, yAxis);
      yAxis.visible = false
      root.requestNames.push(model.data(index,Qt.DisplayRole));
    }
    xAxis.tickCount = tickCount;
    root.title = model.data(index,Qt.DisplayRole);
  }

  //Gets simulation time and physiology data request from patient metrics, appending new point to each series
  function update(time_s){
    let time = time_s / 60;
    if (root.count>1){
      for (let i = 0; i < root.count; ++i){
        let subRequest = root.requestNames[i]
        let subIndex = model.index(i,0,index)
        let prop = model.data(subIndex, PhysiologyModel.ValueRole)
        root.series(subRequest).append(time,prop)
      }
    } else {
      let prop = model.data(index, PhysiologyModel.ValueRole);
      root.series(root.requestNames[0]).append(time,prop)
    }
    updateDomainAndRange()

    if (!yAxis.visible){
      yAxis.visible = true
      yAxis.titleText = root.model.data(root.index, PhysiologyModel.UnitRole)
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
      if (newY >= 0){
        yAxis.min = yAxis.min == 0 ? 0.9 * newY : Math.min(yAxis.min, 0.9 * newY)
        yAxis.max = yAxis.max == 1 ? 1.1 * newY : Math.max(yAxis.max, 1.1 * newY)
      } else {
        yAxis.min = yAxis.min == 0 ? 1.1 * newY : Math.min(yAxis.min, 1.1 * newY)
        yAxis.max = yAxis.max == 1 ? 0.9 * newY : Math.max(yAxis.max, 0.9 * newY)
      }
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
