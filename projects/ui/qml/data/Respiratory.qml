import QtQuick 2.12
import QtCharts 2.3
// Respiratory

Item {
  id: root
  property ValueAxis axisX : ValueAxis {
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  alveolarArterialGradient : LineSeries {
    name : "alveolarArterialGradient"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "alveolarArterialGradient"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  carricoIndex : LineSeries {
    name : "carricoIndex"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "carricoIndex"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  endTidalCarbonDioxideFraction : LineSeries {
    name : "endTidalCarbonDioxideFraction"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "endTidalCarbonDioxideFraction"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  endTidalCarbonDioxidePressure : LineSeries {
    name : "endTidalCarbonDioxidePressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "endTidalCarbonDioxidePressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  expiratoryFlow : LineSeries {
    name : "expiratoryFlow"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "expiratoryFlow"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  inspiratoryExpiratoryRatio : LineSeries {
    name : "inspiratoryExpiratoryRatio"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "inspiratoryExpiratoryRatio"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  inspiratoryFlow : LineSeries {
    name : "inspiratoryFlow"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "inspiratoryFlow"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  pulmonaryCompliance : LineSeries {
    name : "pulmonaryCompliance"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "pulmonaryCompliance"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  pulmonaryResistance : LineSeries {
    name : "pulmonaryResistance"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "pulmonaryResistance"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  respirationDriverPressure : LineSeries {
    name : "respirationDriverPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "respirationDriverPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  respirationMusclePressure : LineSeries {
    name : "respirationMusclePressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "respirationMusclePressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  respirationRate : LineSeries {
    name : "respirationRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "respirationRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  specificVentilation : LineSeries {
    name : "specificVentilation"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "specificVentilation"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  targetPulmonaryVentilation : LineSeries {
    name : "targetPulmonaryVentilation"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "targetPulmonaryVentilation"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  tidalVolume : LineSeries {
    name : "tidalVolume"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "tidalVolume"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  totalAlveolarVentilation : LineSeries {
    name : "totalAlveolarVentilation"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "totalAlveolarVentilation"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  totalDeadSpaceVentilation : LineSeries {
    name : "totalDeadSpaceVentilation"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "totalDeadSpaceVentilation"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  totalLungVolume : LineSeries {
    name : "totalLungVolume"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "totalLungVolume"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  totalPulmonaryVentilation : LineSeries {
    name : "totalPulmonaryVentilation"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "totalPulmonaryVentilation"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  transpulmonaryPressure : LineSeries {
    name : "transpulmonaryPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "transpulmonaryPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
}