import QtQuick 2.12
import QtCharts 2.3
// Renal

Item {
  id: root

property alias glomerularFiltrationRate: glomerularFiltrationRate
property alias filtrationFraction: filtrationFraction
property alias leftAfferentArterioleResistance: leftAfferentArterioleResistance
property alias leftBowmansCapsulesHydrostaticPressure: leftBowmansCapsulesHydrostaticPressure
property alias leftBowmansCapsulesOsmoticPressure: leftBowmansCapsulesOsmoticPressure
property alias leftEfferentArterioleResistance: leftEfferentArterioleResistance
property alias leftGlomerularCapillariesHydrostaticPressure: leftGlomerularCapillariesHydrostaticPressure
property alias leftGlomerularCapillariesOsmoticPressure: leftGlomerularCapillariesOsmoticPressure
property alias leftGlomerularFiltrationCoefficient: leftGlomerularFiltrationCoefficient
property alias leftGlomerularFiltrationRate: leftGlomerularFiltrationRate
property alias leftGlomerularFiltrationSurfaceArea: leftGlomerularFiltrationSurfaceArea
property alias leftGlomerularFluidPermeability: leftGlomerularFluidPermeability
property alias leftFiltrationFraction: leftFiltrationFraction
property alias leftNetFiltrationPressure: leftNetFiltrationPressure
property alias leftNetReabsorptionPressure: leftNetReabsorptionPressure
property alias leftPeritubularCapillariesHydrostaticPressure: leftPeritubularCapillariesHydrostaticPressure
property alias leftPeritubularCapillariesOsmoticPressure: leftPeritubularCapillariesOsmoticPressure
property alias leftReabsorptionFiltrationCoefficient: leftReabsorptionFiltrationCoefficient
property alias leftReabsorptionRate: leftReabsorptionRate
property alias leftTubularReabsorptionFiltrationSurfaceArea: leftTubularReabsorptionFiltrationSurfaceArea
property alias leftTubularReabsorptionFluidPermeability: leftTubularReabsorptionFluidPermeability
property alias leftTubularHydrostaticPressure: leftTubularHydrostaticPressure
property alias leftTubularOsmoticPressure: leftTubularOsmoticPressure
property alias renalBloodFlow: renalBloodFlow
property alias renalPlasmaFlow: renalPlasmaFlow
property alias renalVascularResistance: renalVascularResistance
property alias rightAfferentArterioleResistance: rightAfferentArterioleResistance
property alias rightBowmansCapsulesHydrostaticPressure: rightBowmansCapsulesHydrostaticPressure
property alias rightBowmansCapsulesOsmoticPressure: rightBowmansCapsulesOsmoticPressure
property alias rightEfferentArterioleResistance: rightEfferentArterioleResistance
property alias rightGlomerularCapillariesHydrostaticPressure: rightGlomerularCapillariesHydrostaticPressure
property alias rightGlomerularCapillariesOsmoticPressure: rightGlomerularCapillariesOsmoticPressure
property alias rightGlomerularFiltrationCoefficient: rightGlomerularFiltrationCoefficient
property alias rightGlomerularFiltrationRate: rightGlomerularFiltrationRate
property alias rightGlomerularFiltrationSurfaceArea: rightGlomerularFiltrationSurfaceArea
property alias rightGlomerularFluidPermeability: rightGlomerularFluidPermeability
property alias rightFiltrationFraction: rightFiltrationFraction
property alias rightNetFiltrationPressure: rightNetFiltrationPressure
property alias rightNetReabsorptionPressure: rightNetReabsorptionPressure
property alias rightPeritubularCapillariesHydrostaticPressure: rightPeritubularCapillariesHydrostaticPressure
property alias rightPeritubularCapillariesOsmoticPressure: rightPeritubularCapillariesOsmoticPressure
property alias rightReabsorptionFiltrationCoefficient: rightReabsorptionFiltrationCoefficient
property alias rightReabsorptionRate: rightReabsorptionRate
property alias rightTubularReabsorptionFiltrationSurfaceArea: rightTubularReabsorptionFiltrationSurfaceArea
property alias rightTubularReabsorptionFluidPermeability: rightTubularReabsorptionFluidPermeability
property alias rightTubularHydrostaticPressure: rightTubularHydrostaticPressure
property alias rightTubularOsmoticPressure: rightTubularOsmoticPressure
property alias urinationRate: urinationRate
property alias urineOsmolality: urineOsmolality
property alias urineOsmolarity: urineOsmolarity
property alias urineProductionRate: urineProductionRate
property alias meanUrineOutput: meanUrineOutput
property alias urineSpecificGravity: urineSpecificGravity
property alias urineVolume: urineVolume
property alias urineUreaNitrogenConcentration: urineUreaNitrogenConcentration

property list<LineSeries> requests : [
  LineSeries {
    id: glomerularFiltrationRate
  }
 ,LineSeries {
    id: filtrationFraction
  }
 ,LineSeries {
    id: leftAfferentArterioleResistance
  }
 ,LineSeries {
    id: leftBowmansCapsulesHydrostaticPressure
  }
 ,LineSeries {
    id: leftBowmansCapsulesOsmoticPressure
  }
 ,LineSeries {
    id: leftEfferentArterioleResistance
  }
 ,LineSeries {
    id: leftGlomerularCapillariesHydrostaticPressure
  }
 ,LineSeries {
    id: leftGlomerularCapillariesOsmoticPressure
  }
 ,LineSeries {
    id: leftGlomerularFiltrationCoefficient
  }
 ,LineSeries {
    id: leftGlomerularFiltrationRate
  }
 ,LineSeries {
    id: leftGlomerularFiltrationSurfaceArea
  }
 ,LineSeries {
    id: leftGlomerularFluidPermeability
  }
 ,LineSeries {
    id: leftFiltrationFraction
  }
 ,LineSeries {
    id: leftNetFiltrationPressure
  }
 ,LineSeries {
    id: leftNetReabsorptionPressure
  }
 ,LineSeries {
    id: leftPeritubularCapillariesHydrostaticPressure
  }
 ,LineSeries {
    id: leftPeritubularCapillariesOsmoticPressure
  }
 ,LineSeries {
    id: leftReabsorptionFiltrationCoefficient
  }
 ,LineSeries {
    id: leftReabsorptionRate
  }
 ,LineSeries {
    id: leftTubularReabsorptionFiltrationSurfaceArea
  }
 ,LineSeries {
    id: leftTubularReabsorptionFluidPermeability
  }
 ,LineSeries {
    id: leftTubularHydrostaticPressure
  }
 ,LineSeries {
    id: leftTubularOsmoticPressure
  }
 ,LineSeries {
    id: renalBloodFlow
  }
 ,LineSeries {
    id: renalPlasmaFlow
  }
 ,LineSeries {
    id: renalVascularResistance
  }
 ,LineSeries {
    id: rightAfferentArterioleResistance
  }
 ,LineSeries {
    id: rightBowmansCapsulesHydrostaticPressure
  }
 ,LineSeries {
    id: rightBowmansCapsulesOsmoticPressure
  }
 ,LineSeries {
    id: rightEfferentArterioleResistance
  }
 ,LineSeries {
    id: rightGlomerularCapillariesHydrostaticPressure
  }
 ,LineSeries {
    id: rightGlomerularCapillariesOsmoticPressure
  }
 ,LineSeries {
    id: rightGlomerularFiltrationCoefficient
  }
 ,LineSeries {
    id: rightGlomerularFiltrationRate
  }
 ,LineSeries {
    id: rightGlomerularFiltrationSurfaceArea
  }
 ,LineSeries {
    id: rightGlomerularFluidPermeability
  }
 ,LineSeries {
    id: rightFiltrationFraction
  }
 ,LineSeries {
    id: rightNetFiltrationPressure
  }
 ,LineSeries {
    id: rightNetReabsorptionPressure
  }
 ,LineSeries {
    id: rightPeritubularCapillariesHydrostaticPressure
  }
 ,LineSeries {
    id: rightPeritubularCapillariesOsmoticPressure
  }
 ,LineSeries {
    id: rightReabsorptionFiltrationCoefficient
  }
 ,LineSeries {
    id: rightReabsorptionRate
  }
 ,LineSeries {
    id: rightTubularReabsorptionFiltrationSurfaceArea
  }
 ,LineSeries {
    id: rightTubularReabsorptionFluidPermeability
  }
 ,LineSeries {
    id: rightTubularHydrostaticPressure
  }
 ,LineSeries {
    id: rightTubularOsmoticPressure
  }
 ,LineSeries {
    id: urinationRate
  }
 ,LineSeries {
    id: urineOsmolality
  }
 ,LineSeries {
    id: urineOsmolarity
  }
 ,LineSeries {
    id: urineProductionRate
  }
 ,LineSeries {
    id: meanUrineOutput
  }
 ,LineSeries {
    id: urineSpecificGravity
  }
 ,LineSeries {
    id: urineVolume
  }
 ,LineSeries {
    id: urineUreaNitrogenConcentration
  }
  ]
}