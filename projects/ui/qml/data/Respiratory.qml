import QtQuick 2.12
import QtCharts 2.3
// Respiratory

Item {
  id: root

property alias alveolarArterialGradient: alveolarArterialGradient
property alias carricoIndex: carricoIndex
property alias endTidalCarbonDioxideFraction: endTidalCarbonDioxideFraction
property alias endTidalCarbonDioxidePressure: endTidalCarbonDioxidePressure
property alias expiratoryFlow: expiratoryFlow
property alias inspiratoryExpiratoryRatio: inspiratoryExpiratoryRatio
property alias inspiratoryFlow: inspiratoryFlow
property alias pulmonaryCompliance: pulmonaryCompliance
property alias pulmonaryResistance: pulmonaryResistance
property alias respirationDriverPressure: respirationDriverPressure
property alias respirationMusclePressure: respirationMusclePressure
property alias respirationRate: respirationRate
property alias specificVentilation: specificVentilation
property alias targetPulmonaryVentilation: targetPulmonaryVentilation
property alias tidalVolume: tidalVolume
property alias totalAlveolarVentilation: totalAlveolarVentilation
property alias totalDeadSpaceVentilation: totalDeadSpaceVentilation
property alias totalLungVolume: totalLungVolume
property alias totalPulmonaryVentilation: totalPulmonaryVentilation
property alias transpulmonaryPressure: transpulmonaryPressure

property list<LineSeries> requests : [
  LineSeries {
    id: alveolarArterialGradient
  }
 ,LineSeries {
    id: carricoIndex
  }
 ,LineSeries {
    id: endTidalCarbonDioxideFraction
  }
 ,LineSeries {
    id: endTidalCarbonDioxidePressure
  }
 ,LineSeries {
    id: expiratoryFlow
  }
 ,LineSeries {
    id: inspiratoryExpiratoryRatio
  }
 ,LineSeries {
    id: inspiratoryFlow
  }
 ,LineSeries {
    id: pulmonaryCompliance
  }
 ,LineSeries {
    id: pulmonaryResistance
  }
 ,LineSeries {
    id: respirationDriverPressure
  }
 ,LineSeries {
    id: respirationMusclePressure
  }
 ,LineSeries {
    id: respirationRate
  }
 ,LineSeries {
    id: specificVentilation
  }
 ,LineSeries {
    id: targetPulmonaryVentilation
  }
 ,LineSeries {
    id: tidalVolume
  }
 ,LineSeries {
    id: totalAlveolarVentilation
  }
 ,LineSeries {
    id: totalDeadSpaceVentilation
  }
 ,LineSeries {
    id: totalLungVolume
  }
 ,LineSeries {
    id: totalPulmonaryVentilation
  }
 ,LineSeries {
    id: transpulmonaryPressure
  }
  ]
}