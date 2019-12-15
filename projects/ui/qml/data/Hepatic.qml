import QtQuick 2.12
import QtCharts 2.3
// Hepatic

Item {
  id: root
  property ValueAxis axisX : ValueAxis {
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  ketoneproductionRate : LineSeries {
    name : "ketoneproductionRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "ketoneproductionRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  hepaticGluconeogenesisRate : LineSeries {
    name : "hepaticGluconeogenesisRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "hepaticGluconeogenesisRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
}