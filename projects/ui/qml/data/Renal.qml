import QtQuick 2.12
import QtCharts 2.3
// Renal

Item {
  id: root
  property ValueAxis axisX : ValueAxis {
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  glomerularFiltrationRate : LineSeries {
    name : "glomerularFiltrationRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "glomerularFiltrationRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  filtrationFraction : LineSeries {
    name : "filtrationFraction"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "filtrationFraction"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftAfferentArterioleResistance : LineSeries {
    name : "leftAfferentArterioleResistance"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftAfferentArterioleResistance"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftBowmansCapsulesHydrostaticPressure : LineSeries {
    name : "leftBowmansCapsulesHydrostaticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftBowmansCapsulesHydrostaticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftBowmansCapsulesOsmoticPressure : LineSeries {
    name : "leftBowmansCapsulesOsmoticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftBowmansCapsulesOsmoticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftEfferentArterioleResistance : LineSeries {
    name : "leftEfferentArterioleResistance"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftEfferentArterioleResistance"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftGlomerularCapillariesHydrostaticPressure : LineSeries {
    name : "leftGlomerularCapillariesHydrostaticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftGlomerularCapillariesHydrostaticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftGlomerularCapillariesOsmoticPressure : LineSeries {
    name : "leftGlomerularCapillariesOsmoticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftGlomerularCapillariesOsmoticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftGlomerularFiltrationCoefficient : LineSeries {
    name : "leftGlomerularFiltrationCoefficient"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftGlomerularFiltrationCoefficient"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftGlomerularFiltrationRate : LineSeries {
    name : "leftGlomerularFiltrationRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftGlomerularFiltrationRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftGlomerularFiltrationSurfaceArea : LineSeries {
    name : "leftGlomerularFiltrationSurfaceArea"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftGlomerularFiltrationSurfaceArea"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftGlomerularFluidPermeability : LineSeries {
    name : "leftGlomerularFluidPermeability"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftGlomerularFluidPermeability"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftFiltrationFraction : LineSeries {
    name : "leftFiltrationFraction"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftFiltrationFraction"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftNetFiltrationPressure : LineSeries {
    name : "leftNetFiltrationPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftNetFiltrationPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftNetReabsorptionPressure : LineSeries {
    name : "leftNetReabsorptionPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftNetReabsorptionPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftPeritubularCapillariesHydrostaticPressure : LineSeries {
    name : "leftPeritubularCapillariesHydrostaticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftPeritubularCapillariesHydrostaticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftPeritubularCapillariesOsmoticPressure : LineSeries {
    name : "leftPeritubularCapillariesOsmoticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftPeritubularCapillariesOsmoticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftReabsorptionFiltrationCoefficient : LineSeries {
    name : "leftReabsorptionFiltrationCoefficient"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftReabsorptionFiltrationCoefficient"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftReabsorptionRate : LineSeries {
    name : "leftReabsorptionRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftReabsorptionRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftTubularReabsorptionFiltrationSurfaceArea : LineSeries {
    name : "leftTubularReabsorptionFiltrationSurfaceArea"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftTubularReabsorptionFiltrationSurfaceArea"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftTubularReabsorptionFluidPermeability : LineSeries {
    name : "leftTubularReabsorptionFluidPermeability"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftTubularReabsorptionFluidPermeability"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftTubularHydrostaticPressure : LineSeries {
    name : "leftTubularHydrostaticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftTubularHydrostaticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  leftTubularOsmoticPressure : LineSeries {
    name : "leftTubularOsmoticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "leftTubularOsmoticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  renalBloodFlow : LineSeries {
    name : "renalBloodFlow"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "renalBloodFlow"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  renalPlasmaFlow : LineSeries {
    name : "renalPlasmaFlow"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "renalPlasmaFlow"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  renalVascularResistance : LineSeries {
    name : "renalVascularResistance"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "renalVascularResistance"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightAfferentArterioleResistance : LineSeries {
    name : "rightAfferentArterioleResistance"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightAfferentArterioleResistance"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightBowmansCapsulesHydrostaticPressure : LineSeries {
    name : "rightBowmansCapsulesHydrostaticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightBowmansCapsulesHydrostaticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightBowmansCapsulesOsmoticPressure : LineSeries {
    name : "rightBowmansCapsulesOsmoticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightBowmansCapsulesOsmoticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightEfferentArterioleResistance : LineSeries {
    name : "rightEfferentArterioleResistance"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightEfferentArterioleResistance"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightGlomerularCapillariesHydrostaticPressure : LineSeries {
    name : "rightGlomerularCapillariesHydrostaticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightGlomerularCapillariesHydrostaticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightGlomerularCapillariesOsmoticPressure : LineSeries {
    name : "rightGlomerularCapillariesOsmoticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightGlomerularCapillariesOsmoticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightGlomerularFiltrationCoefficient : LineSeries {
    name : "rightGlomerularFiltrationCoefficient"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightGlomerularFiltrationCoefficient"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightGlomerularFiltrationRate : LineSeries {
    name : "rightGlomerularFiltrationRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightGlomerularFiltrationRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightGlomerularFiltrationSurfaceArea : LineSeries {
    name : "rightGlomerularFiltrationSurfaceArea"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightGlomerularFiltrationSurfaceArea"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightGlomerularFluidPermeability : LineSeries {
    name : "rightGlomerularFluidPermeability"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightGlomerularFluidPermeability"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightFiltrationFraction : LineSeries {
    name : "rightFiltrationFraction"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightFiltrationFraction"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightNetFiltrationPressure : LineSeries {
    name : "rightNetFiltrationPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightNetFiltrationPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightNetReabsorptionPressure : LineSeries {
    name : "rightNetReabsorptionPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightNetReabsorptionPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightPeritubularCapillariesHydrostaticPressure : LineSeries {
    name : "rightPeritubularCapillariesHydrostaticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightPeritubularCapillariesHydrostaticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightPeritubularCapillariesOsmoticPressure : LineSeries {
    name : "rightPeritubularCapillariesOsmoticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightPeritubularCapillariesOsmoticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightReabsorptionFiltrationCoefficient : LineSeries {
    name : "rightReabsorptionFiltrationCoefficient"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightReabsorptionFiltrationCoefficient"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightReabsorptionRate : LineSeries {
    name : "rightReabsorptionRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightReabsorptionRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightTubularReabsorptionFiltrationSurfaceArea : LineSeries {
    name : "rightTubularReabsorptionFiltrationSurfaceArea"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightTubularReabsorptionFiltrationSurfaceArea"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightTubularReabsorptionFluidPermeability : LineSeries {
    name : "rightTubularReabsorptionFluidPermeability"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightTubularReabsorptionFluidPermeability"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightTubularHydrostaticPressure : LineSeries {
    name : "rightTubularHydrostaticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightTubularHydrostaticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  rightTubularOsmoticPressure : LineSeries {
    name : "rightTubularOsmoticPressure"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "rightTubularOsmoticPressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  urinationRate : LineSeries {
    name : "urinationRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "urinationRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  urineOsmolality : LineSeries {
    name : "urineOsmolality"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "urineOsmolality"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  urineOsmolarity : LineSeries {
    name : "urineOsmolarity"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "urineOsmolarity"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  urineProductionRate : LineSeries {
    name : "urineProductionRate"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "urineProductionRate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  meanUrineOutput : LineSeries {
    name : "meanUrineOutput"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "meanUrineOutput"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  urineSpecificGravity : LineSeries {
    name : "urineSpecificGravity"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "urineSpecificGravity"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  urineVolume : LineSeries {
    name : "urineVolume"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "urineVolume"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
  property LineSeries  urineUreaNitrogenConcentration : LineSeries {
    name : "urineUreaNitrogenConcentration"
    axisY: ValueAxis {
            min : 0.
            max : 1.
            property string label : "urineUreaNitrogenConcentration"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
    }
  }
}