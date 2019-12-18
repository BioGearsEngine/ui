import QtQuick 2.12
import QtCharts 2.3
// Energy

Item {
id: root
  property ValueAxis axisX : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  achievedExerciseLevel : LineSeries {
    id: achievedExerciseLevel
    name : "achievedExerciseLevel"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  chlorideLostToSweat : LineSeries {
    id: chlorideLostToSweat
    name : "chlorideLostToSweat"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  coreTemperature : LineSeries {
    id: coreTemperature
    name : "coreTemperature"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  creatinineProductionRate : LineSeries {
    id: creatinineProductionRate
    name : "creatinineProductionRate"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  exerciseMeanArterialPressureDelta : LineSeries {
    id: exerciseMeanArterialPressureDelta
    name : "exerciseMeanArterialPressureDelta"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  fatigueLevel : LineSeries {
    id: fatigueLevel
    name : "fatigueLevel"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  lactateProductionRate : LineSeries {
    id: lactateProductionRate
    name : "lactateProductionRate"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  potassiumLostToSweat : LineSeries {
    id: potassiumLostToSweat
    name : "potassiumLostToSweat"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  skinTemperature : LineSeries {
    id: skinTemperature
    name : "skinTemperature"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  sodiumLostToSweat : LineSeries {
    id: sodiumLostToSweat
    name : "sodiumLostToSweat"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  sweatRate : LineSeries {
    id: sweatRate
    name : "sweatRate"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  totalMetabolicRate : LineSeries {
    id: totalMetabolicRate
    name : "totalMetabolicRate"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  totalWorkRateLevel : LineSeries {
    id: totalWorkRateLevel
    name : "totalWorkRateLevel"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
}