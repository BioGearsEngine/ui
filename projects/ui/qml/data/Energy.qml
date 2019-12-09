import QtQuick 2.12
import QtCharts 2.3
// Energy

Item {
id: root

property alias achievedExerciseLevel: achievedExerciseLevel
property alias chlorideLostToSweat: chlorideLostToSweat
property alias coreTemperature: coreTemperature
property alias creatinineProductionRate: creatinineProductionRate
property alias exerciseMeanArterialPressureDelta: exerciseMeanArterialPressureDelta
property alias fatigueLevel: fatigueLevel
property alias lactateProductionRate: lactateProductionRate
property alias potassiumLostToSweat: potassiumLostToSweat
property alias skinTemperature: skinTemperature
property alias sodiumLostToSweat: sodiumLostToSweat
property alias sweatRate: sweatRate
property alias totalMetabolicRate: totalMetabolicRate
property alias totalWorkRateLevel: totalWorkRateLevel

property list<LineSeries> requests : [
  LineSeries {
    id: achievedExerciseLevel
  }
 ,LineSeries {
    id: chlorideLostToSweat
  }
 ,LineSeries {
    id: coreTemperature
  }
 ,LineSeries {
    id: creatinineProductionRate
  }
 ,LineSeries {
    id: exerciseMeanArterialPressureDelta
  }
 ,LineSeries {
    id: fatigueLevel
  }
 ,LineSeries {
    id: lactateProductionRate
  }
 ,LineSeries {
    id: potassiumLostToSweat
  }
 ,LineSeries {
    id: skinTemperature
  }
 ,LineSeries {
    id: sodiumLostToSweat
  }
 ,LineSeries {
    id: sweatRate
  }
 ,LineSeries {
    id: totalMetabolicRate
  }
 ,LineSeries {
    id: totalWorkRateLevel
  }
  ]
}