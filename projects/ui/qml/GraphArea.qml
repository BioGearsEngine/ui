import QtQuick 2.4
import QtQuick.Controls.Material 2.12
import QtCharts 2.3

import com.biogearsengine.ui.scenario 1.0

GraphAreaForm {
  signal start()
  signal stop()
  signal pause()

  signal plotUpdates(PatientMetrics metrics)

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

  onPlotUpdates: {
    bloodChemistry.requests.redBloodCellCount.append(count_1,count_1)
    bloodChemistry.requests.venousOxygenPressure.append(count_2,count_2)

    count_1 = count_1 + 0.1
    count_2 = count_2 + 0.2

    console.log("redBloodCellCount + %1,%2".arg(count_1).arg(count_1))
    console.log("venousOxygenPressure + %1,%2".arg(count_2).arg(count_2))
  }

  Component.onCompleted: {
    console.log("GraphaArea Componet.onCompleted")

    // lineSeries is a LineSeries object that has already been added to the ChartView; re-use its axes
    bloodChemistry.requests.redBloodCellCount = bloodChemistry.createSeries(bloodChemistry.requests.redBloodCellCount, "Red Blood Cell Count", bloodChemistry.requests.redBloodCellCount.axisX, bloodChemistry.requests.redBloodCellCount.axisY);
    bloodChemistry.requests.venousOxygenPressure  = bloodChemistry.createSeries(ChartView.SeriesTypeLine, "Venous Oxygen Pressure", bloodChemistry.requests.venousOxygenPressure.axisX, bloodChemistry.requests.venousOxygenPressure.axisY);

    bloodChemistry.requests.redBloodCellCount.axisX = bloodChemistry.axisX(bloodChemistry.requests.redBloodCellCount)
    bloodChemistry.requests.redBloodCellCount.axisY = bloodChemistry.axisY(bloodChemistry.requests.redBloodCellCount)
    
    bloodChemistry.requests.redBloodCellCount.axisX.min = 0.
    bloodChemistry.requests.redBloodCellCount.axisX.max = 10.
    bloodChemistry.requests.redBloodCellCount.axisY.min = 0.
    bloodChemistry.requests.redBloodCellCount.axisY.max = 10.

    bloodChemistry.requests.venousOxygenPressure.axisX = bloodChemistry.axisX(bloodChemistry.requests.venousOxygenPressure)
    bloodChemistry.requests.venousOxygenPressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.venousOxygenPressure)

    bloodChemistry.requests.venousOxygenPressure.axisX.min = 0.
    bloodChemistry.requests.venousOxygenPressure.axisX.max = 25.
    bloodChemistry.requests.venousOxygenPressure.axisY.min = 0.
    bloodChemistry.requests.venousOxygenPressure.axisY.max = 25.

    bloodChemistry.requests.venousOxygenPressure.pointAdded.connect (handleNewPoint)
  }

  function handleNewPoint() {
      console.log("Been a long road.")
  }
  // bloodChemistry.requests.redBloodCellCount.onPointAdded: {
  //   console.log("Five by Five in the Pipe")
  // }
}
