import QtQuick 2.12
import QtCharts 2.3
// Drugs

Item {
  id: root
  property ValueAxis axisX : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  bronchodilationLevel : LineSeries {
    id: bronchodilationLevel
    name : "bronchodilationLevel"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  heartRateChange : LineSeries {
    id: heartRateChange
    name : "heartRateChange"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  hemorrhageChange : LineSeries {
    id: hemorrhageChange
    name : "hemorrhageChange"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  meanBloodPressureChange : LineSeries {
    id: meanBloodPressureChange
    name : "meanBloodPressureChange"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  neuromuscularBlockLevel : LineSeries {
    id: neuromuscularBlockLevel
    name : "neuromuscularBlockLevel"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  pulsePressureChange : LineSeries {
    id: pulsePressureChange
    name : "pulsePressureChange"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  respirationRateChange : LineSeries {
    id: respirationRateChange
    name : "respirationRateChange"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  sedationLevel : LineSeries {
    id: sedationLevel
    name : "sedationLevel"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  tidalVolumeChange : LineSeries {
    id: tidalVolumeChange
    name : "tidalVolumeChange"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  tubularPermeabilityChange : LineSeries {
    id: tubularPermeabilityChange
    name : "tubularPermeabilityChange"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  centralNervousResponse : LineSeries {
    id: centralNervousResponse
    name : "centralNervousResponse"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
}