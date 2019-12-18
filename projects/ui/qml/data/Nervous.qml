import QtQuick 2.12
import QtCharts 2.3
// Nervous

Item {
  id: root
  property ValueAxis axisX : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  baroreceptorHeartRateScale : LineSeries {
    id: baroreceptorHeartRateScale
    name : "baroreceptorHeartRateScale"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  baroreceptorHeartElastanceScale : LineSeries {
    id: baroreceptorHeartElastanceScale
    name : "baroreceptorHeartElastanceScale"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  baroreceptorResistanceScale : LineSeries {
    id: baroreceptorResistanceScale
    name : "baroreceptorResistanceScale"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  baroreceptorComplianceScale : LineSeries {
    id: baroreceptorComplianceScale
    name : "baroreceptorComplianceScale"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  chemoreceptorHeartRateScale : LineSeries {
    id: chemoreceptorHeartRateScale
    name : "chemoreceptorHeartRateScale"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  chemoreceptorHeartElastanceScale : LineSeries {
    id: chemoreceptorHeartElastanceScale
    name : "chemoreceptorHeartElastanceScale"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  painVisualAnalogueScale : LineSeries {
    id: painVisualAnalogueScale
    name : "painVisualAnalogueScale"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftEyePupillaryResponse : LineSeries {
    id: leftEyePupillaryResponse
    name : "leftEyePupillaryResponse"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightEyePupillaryResponse : LineSeries {
    id: rightEyePupillaryResponse
    name : "rightEyePupillaryResponse"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
}