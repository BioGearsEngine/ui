import QtQuick 2.12
import QtCharts 2.3
// Renal

Item {
  id: root
  property ValueAxis axisX : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }
  property LineSeries  glomerularFiltrationRate : LineSeries {
    id: glomerularFiltrationRate
    name : "glomerularFiltrationRate"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  filtrationFraction : LineSeries {
    id: filtrationFraction
    name : "filtrationFraction"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftAfferentArterioleResistance : LineSeries {
    id: leftAfferentArterioleResistance
    name : "leftAfferentArterioleResistance"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftBowmansCapsulesHydrostaticPressure : LineSeries {
    id: leftBowmansCapsulesHydrostaticPressure
    name : "leftBowmansCapsulesHydrostaticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftBowmansCapsulesOsmoticPressure : LineSeries {
    id: leftBowmansCapsulesOsmoticPressure
    name : "leftBowmansCapsulesOsmoticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftEfferentArterioleResistance : LineSeries {
    id: leftEfferentArterioleResistance
    name : "leftEfferentArterioleResistance"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftGlomerularCapillariesHydrostaticPressure : LineSeries {
    id: leftGlomerularCapillariesHydrostaticPressure
    name : "leftGlomerularCapillariesHydrostaticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftGlomerularCapillariesOsmoticPressure : LineSeries {
    id: leftGlomerularCapillariesOsmoticPressure
    name : "leftGlomerularCapillariesOsmoticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftGlomerularFiltrationCoefficient : LineSeries {
    id: leftGlomerularFiltrationCoefficient
    name : "leftGlomerularFiltrationCoefficient"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftGlomerularFiltrationRate : LineSeries {
    id: leftGlomerularFiltrationRate
    name : "leftGlomerularFiltrationRate"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftGlomerularFiltrationSurfaceArea : LineSeries {
    id: leftGlomerularFiltrationSurfaceArea
    name : "leftGlomerularFiltrationSurfaceArea"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftGlomerularFluidPermeability : LineSeries {
    id: leftGlomerularFluidPermeability
    name : "leftGlomerularFluidPermeability"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftFiltrationFraction : LineSeries {
    id: leftFiltrationFraction
    name : "leftFiltrationFraction"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftNetFiltrationPressure : LineSeries {
    id: leftNetFiltrationPressure
    name : "leftNetFiltrationPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftNetReabsorptionPressure : LineSeries {
    id: leftNetReabsorptionPressure
    name : "leftNetReabsorptionPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftPeritubularCapillariesHydrostaticPressure : LineSeries {
    id: leftPeritubularCapillariesHydrostaticPressure
    name : "leftPeritubularCapillariesHydrostaticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftPeritubularCapillariesOsmoticPressure : LineSeries {
    id: leftPeritubularCapillariesOsmoticPressure
    name : "leftPeritubularCapillariesOsmoticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftReabsorptionFiltrationCoefficient : LineSeries {
    id: leftReabsorptionFiltrationCoefficient
    name : "leftReabsorptionFiltrationCoefficient"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftReabsorptionRate : LineSeries {
    id: leftReabsorptionRate
    name : "leftReabsorptionRate"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftTubularReabsorptionFiltrationSurfaceArea : LineSeries {
    id: leftTubularReabsorptionFiltrationSurfaceArea
    name : "leftTubularReabsorptionFiltrationSurfaceArea"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftTubularReabsorptionFluidPermeability : LineSeries {
    id: leftTubularReabsorptionFluidPermeability
    name : "leftTubularReabsorptionFluidPermeability"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftTubularHydrostaticPressure : LineSeries {
    id: leftTubularHydrostaticPressure
    name : "leftTubularHydrostaticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  leftTubularOsmoticPressure : LineSeries {
    id: leftTubularOsmoticPressure
    name : "leftTubularOsmoticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  renalBloodFlow : LineSeries {
    id: renalBloodFlow
    name : "renalBloodFlow"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  renalPlasmaFlow : LineSeries {
    id: renalPlasmaFlow
    name : "renalPlasmaFlow"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  renalVascularResistance : LineSeries {
    id: renalVascularResistance
    name : "renalVascularResistance"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightAfferentArterioleResistance : LineSeries {
    id: rightAfferentArterioleResistance
    name : "rightAfferentArterioleResistance"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightBowmansCapsulesHydrostaticPressure : LineSeries {
    id: rightBowmansCapsulesHydrostaticPressure
    name : "rightBowmansCapsulesHydrostaticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightBowmansCapsulesOsmoticPressure : LineSeries {
    id: rightBowmansCapsulesOsmoticPressure
    name : "rightBowmansCapsulesOsmoticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightEfferentArterioleResistance : LineSeries {
    id: rightEfferentArterioleResistance
    name : "rightEfferentArterioleResistance"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightGlomerularCapillariesHydrostaticPressure : LineSeries {
    id: rightGlomerularCapillariesHydrostaticPressure
    name : "rightGlomerularCapillariesHydrostaticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightGlomerularCapillariesOsmoticPressure : LineSeries {
    id: rightGlomerularCapillariesOsmoticPressure
    name : "rightGlomerularCapillariesOsmoticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightGlomerularFiltrationCoefficient : LineSeries {
    id: rightGlomerularFiltrationCoefficient
    name : "rightGlomerularFiltrationCoefficient"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightGlomerularFiltrationRate : LineSeries {
    id: rightGlomerularFiltrationRate
    name : "rightGlomerularFiltrationRate"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightGlomerularFiltrationSurfaceArea : LineSeries {
    id: rightGlomerularFiltrationSurfaceArea
    name : "rightGlomerularFiltrationSurfaceArea"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightGlomerularFluidPermeability : LineSeries {
    id: rightGlomerularFluidPermeability
    name : "rightGlomerularFluidPermeability"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightFiltrationFraction : LineSeries {
    id: rightFiltrationFraction
    name : "rightFiltrationFraction"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightNetFiltrationPressure : LineSeries {
    id: rightNetFiltrationPressure
    name : "rightNetFiltrationPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightNetReabsorptionPressure : LineSeries {
    id: rightNetReabsorptionPressure
    name : "rightNetReabsorptionPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightPeritubularCapillariesHydrostaticPressure : LineSeries {
    id: rightPeritubularCapillariesHydrostaticPressure
    name : "rightPeritubularCapillariesHydrostaticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightPeritubularCapillariesOsmoticPressure : LineSeries {
    id: rightPeritubularCapillariesOsmoticPressure
    name : "rightPeritubularCapillariesOsmoticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightReabsorptionFiltrationCoefficient : LineSeries {
    id: rightReabsorptionFiltrationCoefficient
    name : "rightReabsorptionFiltrationCoefficient"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightReabsorptionRate : LineSeries {
    id: rightReabsorptionRate
    name : "rightReabsorptionRate"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightTubularReabsorptionFiltrationSurfaceArea : LineSeries {
    id: rightTubularReabsorptionFiltrationSurfaceArea
    name : "rightTubularReabsorptionFiltrationSurfaceArea"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightTubularReabsorptionFluidPermeability : LineSeries {
    id: rightTubularReabsorptionFluidPermeability
    name : "rightTubularReabsorptionFluidPermeability"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightTubularHydrostaticPressure : LineSeries {
    id: rightTubularHydrostaticPressure
    name : "rightTubularHydrostaticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  rightTubularOsmoticPressure : LineSeries {
    id: rightTubularOsmoticPressure
    name : "rightTubularOsmoticPressure"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  urinationRate : LineSeries {
    id: urinationRate
    name : "urinationRate"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  urineOsmolality : LineSeries {
    id: urineOsmolality
    name : "urineOsmolality"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  urineOsmolarity : LineSeries {
    id: urineOsmolarity
    name : "urineOsmolarity"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  urineProductionRate : LineSeries {
    id: urineProductionRate
    name : "urineProductionRate"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  meanUrineOutput : LineSeries {
    id: meanUrineOutput
    name : "meanUrineOutput"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  urineSpecificGravity : LineSeries {
    id: urineSpecificGravity
    name : "urineSpecificGravity"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  urineVolume : LineSeries {
    id: urineVolume
    name : "urineVolume"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
  property LineSeries  urineUreaNitrogenConcentration : LineSeries {
    id: urineUreaNitrogenConcentration
    name : "urineUreaNitrogenConcentration"
    property int min : 0;
    property int min_count : 1;
    property int max: 1;
    property int max_count : 1;
    axisY: ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    }
  }
}