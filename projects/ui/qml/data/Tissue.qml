import QtQuick 2.12
import QtCharts 2.3
// Tissue

Item {
  id: root

property alias carbonDioxideProductionRate: carbonDioxideProductionRate
property alias dehydrationFraction: dehydrationFraction
property alias extracellularFluidVolume: extracellularFluidVolume
property alias extravascularFluidVolume: extravascularFluidVolume
property alias intracellularFluidPH: intracellularFluidPH
property alias intracellularFluidVolume: intracellularFluidVolume
property alias totalBodyFluidVolume: totalBodyFluidVolume
property alias oxygenConsumptionRate: oxygenConsumptionRate
property alias respiratoryExchangeRatio: respiratoryExchangeRatio
property alias liverInsulinSetPoint: liverInsulinSetPoint
property alias liverGlucagonSetPoint: liverGlucagonSetPoint
property alias muscleInsulinSetPoint: muscleInsulinSetPoint
property alias muscleGlucagonSetPoint: muscleGlucagonSetPoint
property alias fatInsulinSetPoint: fatInsulinSetPoint
property alias fatGlucagonSetPoint: fatGlucagonSetPoint
property alias liverGlycogen: liverGlycogen
property alias muscleGlycogen: muscleGlycogen
property alias storedProtein: storedProtein
property alias storedFat: storedFat

property list<LineSeries> requests : [
 LineSeries {
    id: carbonDioxideProductionRate
  }
 ,LineSeries {
    id: dehydrationFraction
  }
 ,LineSeries {
    id: extracellularFluidVolume
  }
 ,LineSeries {
    id: extravascularFluidVolume
  }
 ,LineSeries {
    id: intracellularFluidPH
  }
 ,LineSeries {
    id: intracellularFluidVolume
  }
 ,LineSeries {
    id: totalBodyFluidVolume
  }
 ,LineSeries {
    id: oxygenConsumptionRate
  }
 ,LineSeries {
    id: respiratoryExchangeRatio
  }
 ,LineSeries {
    id: liverInsulinSetPoint
  }
 ,LineSeries {
    id: liverGlucagonSetPoint
  }
 ,LineSeries {
    id: muscleInsulinSetPoint
  }
 ,LineSeries {
    id: muscleGlucagonSetPoint
  }
 ,LineSeries {
    id: fatInsulinSetPoint
  }
 ,LineSeries {
    id: fatGlucagonSetPoint
  }
 ,LineSeries {
    id: liverGlycogen
  }
 ,LineSeries {
    id: muscleGlycogen
  }
 ,LineSeries {
    id: storedProtein
  }
 ,LineSeries {
    id: storedFat
  }
  ]
}