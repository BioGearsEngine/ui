import QtQuick 2.12
import QtCharts 2.3
// Drugs

Item {
  id: root

property alias bronchodilationLevel: bronchodilationLevel
property alias heartRateChange: heartRateChange
property alias hemorrhageChange: hemorrhageChange
property alias meanBloodPressureChange: meanBloodPressureChange
property alias neuromuscularBlockLevel: neuromuscularBlockLevel
property alias pulsePressureChange: pulsePressureChange
property alias respirationRateChange: respirationRateChange
property alias sedationLevel: sedationLevel
property alias tidalVolumeChange: tidalVolumeChange
property alias tubularPermeabilityChange: tubularPermeabilityChange
property alias centralNervousResponse: centralNervousResponse

property list<LineSeries> requests : [
  LineSeries {
    id: bronchodilationLevel
  }
 ,LineSeries {
    id: heartRateChange
  }
 ,LineSeries {
    id: hemorrhageChange
  }
 ,LineSeries {
    id: meanBloodPressureChange
  }
 ,LineSeries {
    id: neuromuscularBlockLevel
  }
 ,LineSeries {
    id: pulsePressureChange
  }
 ,LineSeries {
    id: respirationRateChange
  }
 ,LineSeries {
    id: sedationLevel
  }
 ,LineSeries {
    id: tidalVolumeChange
  }
 ,LineSeries {
    id: tubularPermeabilityChange
  }
 ,LineSeries {
    id: centralNervousResponse
  }
  ]
}