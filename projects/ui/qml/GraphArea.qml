import QtQuick 2.4
import QtQuick.Controls.Material 2.12
import QtCharts 2.3

import com.biogearsengine.ui.scenario 1.0

GraphAreaForm {
  signal start()
  signal stop()
  signal pause()

  signal metricUpdates(PatientMetrics metrics)
  signal stateUpdates(PatientState state)
  signal conditionUpdates(PatientConditions conditions)

  property double count_1 : 0.0
  property double count_2 : 0.0

  onStart : {
    console.log("GraphAreaForm " + "start")
  }

  onStop : {
    console.log("GraphAreaForm " + "stop")
  }

  onPause: {
    console.log("GraphAreaForm " + "pause")
  }

   onMetricUpdates: {
    console.log ("GraphArea.onMetricUpdates redBloodCellCount(%1 %2)".arg(metrics.simulationTime).arg(metrics.redBloodCellCount))
    console.log ("GraphArea.onMetricUpdates venousOxygenPressure (%1 %2)".arg(metrics.simulationTime).arg(metrics.redBloodCellCount))
    bloodChemistry.requests.redBloodCellCount.append(metrics.simulationTime, metrics.redBloodCellCount)
    bloodChemistry.requests.venousOxygenPressure.append(metrics.simulationTime, metrics.venousOxygenPressure)
  }

  onStateUpdates: {
  }

  onConditionUpdates: {
  }
  ValueAxis {
    id: timeAxis
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  Component.onCompleted: {

    // lineSeries is a LineSeries object that has already been added to the ChartView; re-use its axes
    bloodChemistry.requests.redBloodCellCount = bloodChemistry.createSeries(bloodChemistry.requests.redBloodCellCount, "Red Blood Cell Count"
    , timeAxis, bloodChemistry.requests.redBloodCellCount.axisY);

    bloodChemistry.requests.redBloodCellCount.axisY = bloodChemistry.axisY(bloodChemistry.requests.redBloodCellCount)
    bloodChemistry.requests.redBloodCellCount.axisY.min = 0.
    bloodChemistry.requests.redBloodCellCount.axisY.max = 1.
    bloodChemistry.requests.redBloodCellCount.axisY.titleText = "redBloodCellCount"
bloodChemistry.requests.redBloodCellCount.axisY.labelFormat = '%0.2e'
    //Trying to get a Right sided Axis seems ignored because axisY and axisYRight are mutually exlusive
    //I figure bloodChemistry.axisY automatically asigns to axisY
    bloodChemistry.requests.venousOxygenPressure  = bloodChemistry.createSeries(ChartView.SeriesTypeLine, "Venous Oxygen Pressure",
    timeAxis, bloodChemistry.requests.venousOxygenPressure.axisY);

    bloodChemistry.requests.venousOxygenPressure.axisYRight = bloodChemistry.axisY(bloodChemistry.requests.venousOxygenPressure)
    bloodChemistry.requests.venousOxygenPressure.axisYRight.min = 0.
    bloodChemistry.requests.venousOxygenPressure.axisYRight.max = 1.
    bloodChemistry.requests.venousOxygenPressure.axisYRight.labelFormat = '%0.2d'
    bloodChemistry.requests.venousOxygenPressure.axisYRight.titleText = "venousOxygenPressure"

    // bloodChemistry.requests.venousOxygenPressure.pointAdded.connect (handleNewPoint)
  }


  function newPointHandler(series,pointIndex) {
      var start = ( series.count < 3600 ) ? 0 : series.count - 3600;
      var min = series.at(start).y;
      var max = series.at(start).y;

      for(var i = start; i < series.count; ++i){
          min = Math.min(min >= series.at(i).y) ? series.at(i).y : min;
          max = (max <= series.at(i).y) ? series.at(i).y : max;
      }
      if(series.axisY){
        series.axisY.min = Math.max(0,min * .90)
        series.axisY.max = Math.max(1,max * 1.10)
      } else if (series.axisYRight) {
        series.axisYRight.min = Math.max(0,min * .90)
        series.axisYRight.max = Math.max(1,max * 1.10)
      }
  }
function domainUpdate() {
  timeAxis.tickCount = timeAxis.tickCount + 1;
  const interval =  60 * 15
  if ( timeAxis.tickCount > interval ){
    timeAxis.min = timeAxis.tickCount - interval
    timeAxis.max = timeAxis.tickCount
  } else {
    timeAxis.min = 0
    timeAxis.max = interval
  }
}
  Connections {
    target : 
      bloodChemistry.requests.venousOxygenPressure
    onPointAdded : newPointHandler(bloodChemistry.requests.venousOxygenPressure, index)
  }
  // Connections {
  //   target : 
  //   bloodChemistry.requests.redBloodCellCount
  //   onPointAdded : newPointHandler(bloodChemistry.requests.redBloodCellCount, index)
  // }
    Connections {
    target : bloodChemistry.requests.venousOxygenPressure
    onPointAdded : domainUpdate()
  }
  // bloodChemistry.requests.redBloodCellCount.onPointAdded: {
  //   console.log("Five by Five in the Pipe")
  // }
}
