import QtQuick 2.12
import QtCharts 2.3
// Endocrine

Item {
  id: root
  property ValueAxis axisX : ValueAxis {
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  insulinSynthesisRate : LineSeries {
    name : "insulinSynthesisRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "insulinSynthesisRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  glucagonSynthesisRate : LineSeries {
    name : "glucagonSynthesisRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "glucagonSynthesisRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
}