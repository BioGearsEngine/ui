import QtQuick 2.12
import QtCharts 2.3
// Nervous

Item {
  id: root
  property ValueAxis axisX : ValueAxis {
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  baroreceptorHeartRateScale : LineSeries {
    name : "baroreceptorHeartRateScale"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "baroreceptorHeartRateScale"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  baroreceptorHeartElastanceScale : LineSeries {
    name : "baroreceptorHeartElastanceScale"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "baroreceptorHeartElastanceScale"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  baroreceptorResistanceScale : LineSeries {
    name : "baroreceptorResistanceScale"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "baroreceptorResistanceScale"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  baroreceptorComplianceScale : LineSeries {
    name : "baroreceptorComplianceScale"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "baroreceptorComplianceScale"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  chemoreceptorHeartRateScale : LineSeries {
    name : "chemoreceptorHeartRateScale"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "chemoreceptorHeartRateScale"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  chemoreceptorHeartElastanceScale : LineSeries {
    name : "chemoreceptorHeartElastanceScale"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "chemoreceptorHeartElastanceScale"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  painVisualAnalogueScale : LineSeries {
    name : "painVisualAnalogueScale"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "painVisualAnalogueScale"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftEyePupillaryResponse : LineSeries {
    name : "leftEyePupillaryResponse"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftEyePupillaryResponse"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightEyePupillaryResponse : LineSeries {
    name : "rightEyePupillaryResponse"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightEyePupillaryResponse"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
}