import QtQuick 2.12
import QtCharts 2.3
// Gastrointestinal

Item {
  id: root
  property ValueAxis axisX : ValueAxis {
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  chymeAbsorptionRate : LineSeries {
    name : "chymeAbsorptionRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "chymeAbsorptionRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  stomachContents_calcium : LineSeries {
    name : "stomachContents_calcium"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "stomachContents_calcium"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  stomachContents_carbohydrates : LineSeries {
    name : "stomachContents_carbohydrates"
    axisY: ValueAxis {
              min : 0.
              max : 1.
              property string label : "stomachContents_carbohydrates"
              property string unit   : ""
              titleText : "%1 %2".arg(label).arg(unit)
              labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
      }
    }
  property LineSeries  stomachContents_carbohydrateDigationRate : LineSeries {
    name : "stomachContents_carbohydrateDigationRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "stomachContents_carbohydrateDigationRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  stomachContents_fat : LineSeries {
    name : "stomachContents_fat"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "stomachContents_fat"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  stomachContents_fatDigtationRate : LineSeries {
    name : "stomachContents_fatDigtationRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "stomachContents_fatDigtationRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  stomachContents_protien : LineSeries {
    name : "stomachContents_protien"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "stomachContents_protien"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  stomachContents_protienDigtationRate : LineSeries {
    name : "stomachContents_protienDigtationRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "stomachContents_protienDigtationRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  stomachContents_sodium : LineSeries {
    name : "stomachContents_sodium"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "stomachContents_sodium"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  stomachContents_water : LineSeries {
    name : "stomachContents_water"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "stomachContents_water"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
}