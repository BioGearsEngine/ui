import QtQuick 2.12
import QtCharts 2.3

CustomPlotsForm {
  id: root

  property real breathingCycles : 0
  property string plotName: ""

  function initializeRespiratoryPVSeries() {
    root.plotName = "pvCurve"
    let pvSeries = root.createSeries(ChartView.SeriesTypeLine, root.plotName, xAxis, yAxis);
    root.title = "Pressure-Volume Curve";
    xAxis.titleText = "Pleural Pressure (cmH2O)";
    yAxis.titleText = "Lung Volume (L)";
  }

  function updateRespiratoryPVSeries(metrics){
    let maxCycles = 3;
    let pressure = metrics.respirationMusclePressure
    let volume = metrics["totalLungVolume"] / 1000
    root.series(root.plotName).append(pressure, volume)
    if (metrics.newBreathingCycle){
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
      xAxis.min = xAxis.min == 0 ? 0.9 * newPoint.x : Math.min(xAxis.min, Math.floor(0.9 * newPoint.x))
      xAxis.max = xAxis.max == 1 ? 1.1 * newPoint.x : Math.max(xAxis.max, Math.ceil(1.1 * newPoint.x))
    } else {
      xAxis.min = xAxis.min == 0 ? 1.1 * newPoint.x : Math.min(xAxis.min, Math.floor(1.1 * newPoint.x))
      xAxis.max = xAxis.max == 1 ? 0.9 * newPoint.x : Math.max(xAxis.max, Math.ceil(0.9 * newPoint.x))
    }
    if(newPoint.y >=0){
      yAxis.min = yAxis.min == 0 ? 0.9 * newPoint.y : Math.min(yAxis.min, Math.floor(0.9 * newPoint.y))
      yAxis.max = yAxis.max == 1 ? 1.1 * newPoint.y : Math.max(yAxis.max, Math.ceil(1.1 * newPoint.y))
    } else {
      yAxis.min = yAxis.min == 0 ? 1.1 * newPoint.y : Math.min(yAxis.min, Math.floor(1.1 * newPoint.y))
      yAxis.max = yAxis.max == 1 ? 0.9 * newPoint.y : Math.max(yAxis.max, Math.ceil(0.9 * newPoint.y))
    }
  }

}
