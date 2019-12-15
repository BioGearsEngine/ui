import QtQuick 2.12
import QtCharts 2.3
// Drugs

Item {
  id: root
  property ValueAxis axisX : ValueAxis {
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  bronchodilationLevel : LineSeries {
    name : "bronchodilationLevel"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "bronchodilationLevel"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  heartRateChange : LineSeries {
    name : "heartRateChange"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "heartRateChange"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  hemorrhageChange : LineSeries {
    name : "hemorrhageChange"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "hemorrhageChange"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  meanBloodPressureChange : LineSeries {
    name : "meanBloodPressureChange"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "meanBloodPressureChange"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  neuromuscularBlockLevel : LineSeries {
    name : "neuromuscularBlockLevel"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "neuromuscularBlockLevel"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  pulsePressureChange : LineSeries {
    name : "pulsePressureChange"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "pulsePressureChange"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  respirationRateChange : LineSeries {
    name : "respirationRateChange"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "respirationRateChange"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  sedationLevel : LineSeries {
    name : "sedationLevel"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "sedationLevel"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  tidalVolumeChange : LineSeries {
    name : "tidalVolumeChange"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "tidalVolumeChange"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  tubularPermeabilityChange : LineSeries {
    name : "tubularPermeabilityChange"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "tubularPermeabilityChange"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  centralNervousResponse : LineSeries {
    name : "centralNervousResponse"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "centralNervousResponse"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
}