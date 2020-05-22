import QtQuick 2.12
import QtCharts 2.3

import com.biogearsengine.ui.scenario 1.0
UIPlotSeriesForm {
  id: root

  property var requestNames : []
  property var model : null
  property var index : null
  property alias rate  : root.refresh_rate
  property int refreshOffset : 0

  //Sets tickCount equal to global value (so that plot always knows time at which it started) and initializes request name that will be used to pull data from metrics object
  //Each requestElement is {request: "requestName" ; active: "true"; subRequests: []}.  If subRequests exists, we add a series for each subRequest.  Otherwise, we use the request name
  function initializeChart (biogearsData, physiologyRequest, title) {
     model = biogearsData
     index = physiologyRequest
     var v_name = title
    
    root.refreshOffset = Math.floor(Math.random() * 10);  

    switch(model.data(index, PhysiologyModel.RateRole)) {
      case 1:
        speed_1hz.checked = true
      break;
      case 5:
        speed_5hz.checked = true
      break;
      case 10:
        speed_10hz.checked = true
      break;
      case -5:
        speed_5s.checked = true
      break;
      case -10:
        speed_10s.checked = true
      break;
      default:
      // code block
    } 

     if(model.rowCount(index)){
       if( model.data(index, PhysiologyModel.NestedRole) ){
         //NOTE: We should not ever get here as GraphAreaForm.ui should have
         //      broken the nested ot individual calls, but 
       } else {
          requestNames = []
          for (let i = 0; i < model.rowCount(index); ++i){
            let l_subIndex = biogearsData.index(i,0,physiologyRequest)
            requestNames.push(biogearsData.data(l_subIndex,Qt.DisplayRole))
            let l_series = root.createSeries(ChartView.SeriesTypeLine, biogearsData.data(l_subIndex,Qt.DisplayRole), xAxis, yAxis);
          }
          root.legend.visible = true
       }
     } else  {
      //Common single line plot
      let l_series = root.createSeries(ChartView.SeriesTypeLine, v_name, xAxis, yAxis);
      root.requestNames.push(v_name);
    }
    yAxis.visible = false
    root.title = v_name;
  }

  //Gets simulation time and physiology data request from patient metrics, appending new point to each series
  function update(time_s){
    let time_m = time_s / 60;
    if (root.count>1){
      for (let i = 0; i < root.count; ++i){
        let subRequest = requestNames[i]
        let subIndex = model.index(i,0,index)
        let prop = root.model.data(subIndex,PhysiologyModel.ValueRole)
        root.series(subRequest).append(time_m,prop)

        if (!yAxis.visible){
          yAxis.visible = true
          yAxis.titleText = root.model.data(subIndex, PhysiologyModel.UnitRole)
        }
      }
    } else {
      let prop = root.model.data(index, PhysiologyModel.ValueRole);
      root.series(root.requestNames[0]).append(time_m,prop)

      if (!yAxis.visible){
        yAxis.visible = true
        yAxis.titleText = root.model.data(index, PhysiologyModel.UnitRole)
      }
    }
    updateXInterval(time_s)
    
    if(  Math.floor(time_s + refreshOffset) % 5 == 0 ){
        updateYInterval(time_s)
    }

    if ( Math.floor(time_s + refreshOffset) % 10 == 0){
      pruneHistory(time_s)
    }

  }

  //Gets simulation time and substance data request from substance metrics, appending new point to each series
  function updateSubstanceSeries(time_s, subData){
    //Substance request names stored as (e.g.) Sodium-BloodConcentration.  Split at '-' to get substance (key) and property (object)
    let requestComponents = root.requestNames[0].split('-')
    let substance = requestComponents[0]
    let propName = requestComponents[1]
    let prop = subData[substance][propName]
    root.series(root.requestNames[0]).append(time_s/60.0, prop)
    updateDomainAndRange(time_s);
    if (!yAxis.visible){
      yAxis.visible = true
    }
  }


  //Gets simulation time and physiology data request from patient metrics, appending new point to each series
  function clear(){
    if (root.count>1){
      for (let i = 0; i < root.count; ++i){
        let series = root.series(root.requestNames[i])
        series.removePoints(0, series.count)
      }
    } else {
      let series = root.series(root.requestNames[0])
      series.removePoints(0, series.count)
    }
  }

  function updateXInterval(time_s){
    const interval_s = 60 * timeInterval_m
    if(time_s > interval_s){
      xAxis.min = (time_s - interval_s) / 60;
      xAxis.max = time_s / 60
    } else {
      xAxis.min = 0
      xAxis.max= timeInterval_m
    }
  }

  function updateYInterval(time_s){
    if( root.autoScaleEnabled) {
      yAxis.min = root.series(0).at(0).y
      yAxis.max = root.series(0).at(root.series(0).count-1).y
      calculateScale = false
      //TODO: To do this right we 
      for (let i = 0; i < root.count; ++i) {
        for (let j = 0 ; j < root.series(i).count; ++j){
          let curY = root.series(i).at(j).y
            yAxis.min = yAxis.min > curY ? curY : yAxis.min
            yAxis.max = yAxis.max < curY ? curY : yAxis.max
        }
        yAxis.min = yAxis.min - (yAxis.max - yAxis.min) * .5
        yAxis.max = yAxis.max + (yAxis.max - yAxis.min) * .5
      }
    } else {
       yAxis.min = userSpecifiedMin
       yAxis.max = userSpecifiedMax
       calculateScale = true
    }
  }

  function pruneHistory(time_s){
    const time_m = time_s / 60;
    for (let i = 0; i < root.count; ++i) {
      var trim_count = 0;

      //Currently, the maximum timescale is 10 minutes we need to remove any points outside of that scale
      //We assumed well ordered time data. 
      for (let j = 0; j < root.series(i).count; ++j){
      if (root.series(i).at(j).x < (time_m - 10 )){
        trim_count = j;
        continue;
      } break;
      }
      root.series(i).removePoints(0,trim_count)
    }
  }

  function updateDomainAndRange(time_s){
      updateYInterval(time_s)
      updateXInterval(time_s)
      pruneHistory(time_s)
  }

  //Updates plot size when the application window size changes
  function resizePlot(newWidth, newHeight){
    root.width = newWidth
    root.height = newHeight
  }



}
