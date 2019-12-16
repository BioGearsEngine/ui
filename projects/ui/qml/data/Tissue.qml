import QtQuick 2.12
import QtCharts 2.3
// Tissue

Item {
  id: root
  property ValueAxis axisX : ValueAxis {
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  carbonDioxideProductionRate : LineSeries {
    name : "carbonDioxideProductionRate"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "carbonDioxideProductionRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  dehydrationFraction : LineSeries {
    name : "dehydrationFraction"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "dehydrationFraction"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  extracellularFluidVolume : LineSeries {
    name : "extracellularFluidVolume"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "extracellularFluidVolume"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  extravascularFluidVolume : LineSeries {
    name : "extravascularFluidVolume"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "extravascularFluidVolume"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  intracellularFluidPH : LineSeries {
    name : "intracellularFluidPH"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "intracellularFluidPH"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  intracellularFluidVolume : LineSeries {
    name : "intracellularFluidVolume"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "intracellularFluidVolume"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  totalBodyFluidVolume : LineSeries {
    name : "totalBodyFluidVolume"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "totalBodyFluidVolume"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  oxygenConsumptionRate : LineSeries {
    name : "oxygenConsumptionRate"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "oxygenConsumptionRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  respiratoryExchangeRatio : LineSeries {
    name : "respiratoryExchangeRatio"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "respiratoryExchangeRatio"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  liverInsulinSetPoint : LineSeries {
    name : "liverInsulinSetPoint"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "liverInsulinSetPoint"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  liverGlucagonSetPoint : LineSeries {
    name : "liverGlucagonSetPoint"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "liverGlucagonSetPoint"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  muscleInsulinSetPoint : LineSeries {
    name : "muscleInsulinSetPoint"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "muscleInsulinSetPoint"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  muscleGlucagonSetPoint : LineSeries {
    name : "muscleGlucagonSetPoint"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "muscleGlucagonSetPoint"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  fatInsulinSetPoint : LineSeries {
    name : "fatInsulinSetPoint"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "fatInsulinSetPoint"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  fatGlucagonSetPoint : LineSeries {
    name : "fatGlucagonSetPoint"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "fatGlucagonSetPoint"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  liverGlycogen : LineSeries {
    name : "liverGlycogen"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "liverGlycogen"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  muscleGlycogen : LineSeries {
    name : "muscleGlycogen"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "muscleGlycogen"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  storedProtein : LineSeries {
    name : "storedProtein"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "storedProtein"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  storedFat : LineSeries {
    name : "storedFat"
    axisY: ValueAxis {
                  min : 0.
            max : 1.
            property string label : "storedFat"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
}