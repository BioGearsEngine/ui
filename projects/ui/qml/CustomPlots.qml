import QtQuick 2.12
import QtCharts 2.3

import com.biogearsengine.ui.scenario 1.0

CustomPlotsForm {
  id: root

  property real breathingCycles : 0
  property string plotName: ""

  property var model : null
  property var index : null
  property int rate  : 1

  function initializeRespiratoryPVSeries(biogearsData, physiologyRequest, title) {
    root.model = biogearsData
    root.index = physiologyRequest
    root.rate  =  model.data(physiologyRequest, PhysiologyModel.RateRole)

    root.plotName = "pvCurve"
    let pvSeries = root.createSeries(ChartView.SeriesTypeLine, root.plotName, xAxis, yAxis);
    root.title = "Pressure-Volume Curve";
    xAxis.titleText = "Pleural Pressure (cmH2O)";
    yAxis.titleText = "Lung Volume (L)";

  }
 
   function update(currentTime_s){
     switch (root.title){
       case "Pressure-Volume Curve":
          updateRespiratoryPVSeries()
        break
        default:
          console.log("Unknown Graph %1".arg(root.title))
        break
     }
   }
  function updateRespiratoryPVSeries(){
    let maxCycles = 3;

    let pIndex = model.index(0,0,index)
    let vIndex = model.index(1,0,index)
    let cycleIndex = model.index(2,0,index)

    let pressure = model.data(pIndex, PhysiologyModel.ValueRole)
    let volume   = model.data(vIndex, PhysiologyModel.ValueRole) / 1000

    root.series(root.plotName).append(pressure, volume)
    if ( root.series(root.plotName).count == 1){
      yAxis.min =  root.series(root.plotName).at(0).y
      yAxis.max =  root.series(root.plotName).at(0).y
      xAxis.min =  root.series(root.plotName).at(0).x
      xAxis.max =  root.series(root.plotName).at(0).x
    }
    if ( model.data(cycleIndex, PhysiologyModel.ValueRole) > 0.5 ){
      ++breathingCycles;
    }
    if (breathingCycles > maxCycles){
      root.series(root.plotName).remove(0);
    }
    updateDomainAndRange();
  }

  function updateDomainAndRange(){
    let index = root.series(root.plotName).count-1
    let newPoint = root.series(root.plotName).at(index)
    if(newPoint.x >=0){
      xAxis.min = xAxis.min == 0 ? 0.975 * newPoint.x : Math.min(xAxis.min, Math.floor(0.975 * newPoint.x))
      xAxis.max = xAxis.max == 1 ? 1.025 * newPoint.x : Math.max(xAxis.max, Math.ceil(1.025 * newPoint.x))
    } else {
      xAxis.min = xAxis.min == 0 ? 1.025 * newPoint.x : Math.min(xAxis.min, Math.floor(1.025 * newPoint.x))
      xAxis.max = xAxis.max == 1 ? 0.975 * newPoint.x : Math.max(xAxis.max, Math.ceil(0.975 * newPoint.x))
    }
    if(newPoint.y >=0){
      yAxis.min = yAxis.min == 0 ? 0.975 * newPoint.y : Math.min(yAxis.min, Math.floor(0.975 * newPoint.y))
      yAxis.max = yAxis.max == 1 ? 1.025 * newPoint.y : Math.max(yAxis.max, Math.ceil(1.025 * newPoint.y))
    } else {
      yAxis.min =  Math.min(yAxis.min, 1.025 * newPoint.y)
      yAxis.max =  Math.max(yAxis.max, 0.975 * newPoint.y)
    }
  }

  function clear(){
    let series = root.series(root.plotName)
    let count = series.count
    series.removePoints(0,series.count)
    xAxis.min = 0
    xAxis.max = 1
    yAxis.min = 0
    yAxis.max = 1
  }

  function resizePlot(newWidth, newHeight){
    root.width = newWidth
    root.height = newHeight
  }

}
