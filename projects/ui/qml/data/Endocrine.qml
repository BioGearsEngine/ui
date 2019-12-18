import QtQuick 2.12
import QtCharts 2.3
// Endocrine

Item {
  id: root
  property ValueAxis axisX : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  insulinSynthesisRate : LineSeries {
    id: insulinSynthesisRate
    name : "insulinSynthesisRate"
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  glucagonSynthesisRate : LineSeries {
    id: glucagonSynthesisRate
    name : "glucagonSynthesisRate"
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
}