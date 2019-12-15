import QtQuick 2.12
import QtCharts 2.3
// Energy

Item {
id: root
  property ValueAxis axisX : ValueAxis {
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  achievedExerciseLevel : LineSeries {
    name : "achievedExerciseLevel"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "achievedExerciseLevel"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  chlorideLostToSweat : LineSeries {
    name : "chlorideLostToSweat"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "chlorideLostToSweat"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  coreTemperature : LineSeries {
    name : "coreTemperature"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "coreTemperature"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  creatinineProductionRate : LineSeries {
    name : "creatinineProductionRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "creatinineProductionRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  exerciseMeanArterialPressureDelta : LineSeries {
    name : "exerciseMeanArterialPressureDelta"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "exerciseMeanArterialPressureDelta"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  fatigueLevel : LineSeries {
    name : "fatigueLevel"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "fatigueLevel"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  lactateProductionRate : LineSeries {
    name : "lactateProductionRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "lactateProductionRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  potassiumLostToSweat : LineSeries {
    name : "potassiumLostToSweat"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "potassiumLostToSweat"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  skinTemperature : LineSeries {
    name : "skinTemperature"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "skinTemperature"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  sodiumLostToSweat : LineSeries {
    name : "sodiumLostToSweat"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "sodiumLostToSweat"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  sweatRate : LineSeries {
    name : "sweatRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "sweatRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  totalMetabolicRate : LineSeries {
    name : "totalMetabolicRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "totalMetabolicRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  totalWorkRateLevel : LineSeries {
    name : "totalWorkRateLevel"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "totalWorkRateLevel"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
}