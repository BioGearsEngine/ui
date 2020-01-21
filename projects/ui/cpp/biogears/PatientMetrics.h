#pragma once

#include <QObject>

struct PatientMetrics : QObject {
  PatientMetrics(QObject* parent = nullptr)
    : QObject(parent)
  {
  }

  QString respiratory_rate_bpm;
  QString heart_rate_bpm;
  QString core_temperature_c;
  QString oxygen_saturation_pct;
  QString systolic_blood_pressure_mmHg;
  QString diastolic_blood_pressure_mmHg;

  double simulationTime;
  double timeStep;

  //Blood Chemistry
  double arterialBloodPH;
  double arterialBloodPHBaseline;
  double bloodDensity;
  double bloodSpecificHeat;
  double bloodUreaNitrogenConcentration;
  double carbonDioxideSaturation;
  double carbonMonoxideSaturation;
  double hematocrit;
  double hemoglobinContent;
  double oxygenSaturation;
  double phosphate;
  double plasmaVolume;
  double pulseOximetry;
  double redBloodCellAcetylcholinesterase;
  double redBloodCellCount;
  double shuntFraction;
  double strongIonDifference;
  double totalBilirubin;
  double totalProteinConcentration;
  double venousBloodPH;
  double volumeFractionNeutralPhospholipidInPlasma;
  double volumeFractionNeutralLipidInPlasma;
  double arterialCarbonDioxidePressure;
  double arterialOxygenPressure;
  double pulmonaryArterialCarbonDioxidePressure;
  double pulmonaryArterialOxygenPressure;
  double pulmonaryVenousCarbonDioxidePressure;
  double pulmonaryVenousOxygenPressure;
  double venousCarbonDioxidePressure;
  double venousOxygenPressure;

  //Inflamatory Response
  bool inflammatoryResponse;
  double inflammatoryResponseLocalPathogen;
  double inflammatoryResponseLocalMacrophage;
  double inflammatoryResponseLocalNeutrophil;
  double inflammatoryResponseLocalBarrier;
  double inflammatoryResponseBloodPathogen;
  double inflammatoryResponseTrauma;
  double inflammatoryResponseMacrophageResting;
  double inflammatoryResponseMacrophageActive;
  double inflammatoryResponseNeutrophilResting;
  double inflammatoryResponseNeutrophilActive;
  double inflammatoryResponseInducibleNOSPre;
  double inflammatoryResponseInducibleNOS;
  double inflammatoryResponseConstitutiveNOS;
  double inflammatoryResponseNitrate;
  double inflammatoryResponseNitricOxide;
  double inflammatoryResponseTumorNecrosisFactor;
  double inflammatoryResponseInterleukin6;
  double inflammatoryResponseInterleukin10;
  double inflammatoryResponseInterleukin12;
  double inflammatoryResponseCatecholamines;
  double inflammatoryResponseTissueIntegrity;

  //Cardiovascular
  double arterialPressure;
  double bloodVolume;
  double cardiacIndex;
  double cardiacOutput;
  double centralVenousPressure;
  double cerebralBloodFlow;
  double cerebralPerfusionPressure;
  double diastolicArterialPressure;
  double heartEjectionFraction;
  double heartRate;
  double heartStrokeVolume;
  double intracranialPressure;
  double meanArterialPressure;
  double meanArterialCarbonDioxidePartialPressure;
  double meanArterialCarbonDioxidePartialPressureDelta;
  double meanCentralVenousPressure;
  double meanSkinFlow;
  double pulmonaryArterialPressure;
  double pulmonaryCapillariesWedgePressure;
  double pulmonaryDiastolicArterialPressure;
  double pulmonaryMeanArterialPressure;
  double pulmonaryMeanCapillaryFlow;
  double pulmonaryMeanShuntFlow;
  double pulmonarySystolicArterialPressure;
  double pulmonaryVascularResistance;
  double pulmonaryVascularResistanceIndex;
  double pulsePressure;
  double systemicVascularResistance;
  double systolicArterialPressure;

  //Drugs
  double bronchodilationLevel;
  double heartRateChange;
  double hemorrhageChange;
  double meanBloodPressureChange;
  double neuromuscularBlockLevel;
  double pulsePressureChange;
  double respirationRateChange;
  double sedationLevel;
  double tidalVolumeChange;
  double tubularPermeabilityChange;
  double centralNervousResponse;

  //Endocrine
  double insulinSynthesisRate;
  double glucagonSynthesisRate;

  //Energy
  double achievedExerciseLevel;
  double chlorideLostToSweat;
  double coreTemperature;
  double creatinineProductionRate;
  double exerciseMeanArterialPressureDelta;
  double fatigueLevel;
  double lactateProductionRate;
  double potassiumLostToSweat;
  double skinTemperature;
  double sodiumLostToSweat;
  double sweatRate;
  double totalMetabolicRate;
  double totalWorkRateLevel;

  //Gastronintestinal
  double chymeAbsorptionRate;
  double stomachContents_calcium;
  double stomachContents_carbohydrates;
  double stomachContents_carbohydrateDigationRate;
  double stomachContents_fat;
  double stomachContents_fatDigtationRate;
  double stomachContents_protien;
  double stomachContents_protienDigtationRate;
  double stomachContents_sodium;
  double stomachContents_water;
  //Heptic
  double ketoneproductionRate;
  double hepaticGluconeogenesisRate;

  //Nervous
  double baroreceptorHeartRateScale;
  double baroreceptorHeartElastanceScale;
  double baroreceptorResistanceScale;
  double baroreceptorComplianceScale;
  double chemoreceptorHeartRateScale;
  double chemoreceptorHeartElastanceScale;
  double painVisualAnalogueScale;
  double leftEyePupillaryResponse;
  double rightEyePupillaryResponse;

  //Renal
  double glomerularFiltrationRate;
  double filtrationFraction;
  double leftAfferentArterioleResistance;
  double leftBowmansCapsulesHydrostaticPressure;
  double leftBowmansCapsulesOsmoticPressure;
  double leftEfferentArterioleResistance;
  double leftGlomerularCapillariesHydrostaticPressure;
  double leftGlomerularCapillariesOsmoticPressure;
  double leftGlomerularFiltrationCoefficient;
  double leftGlomerularFiltrationRate;
  double leftGlomerularFiltrationSurfaceArea;
  double leftGlomerularFluidPermeability;
  double leftFiltrationFraction;
  double leftNetFiltrationPressure;
  double leftNetReabsorptionPressure;
  double leftPeritubularCapillariesHydrostaticPressure;
  double leftPeritubularCapillariesOsmoticPressure;
  double leftReabsorptionFiltrationCoefficient;
  double leftReabsorptionRate;
  double leftTubularReabsorptionFiltrationSurfaceArea;
  double leftTubularReabsorptionFluidPermeability;
  double leftTubularHydrostaticPressure;
  double leftTubularOsmoticPressure;
  double renalBloodFlow;
  double renalPlasmaFlow;
  double renalVascularResistance;
  double rightAfferentArterioleResistance;
  double rightBowmansCapsulesHydrostaticPressure;
  double rightBowmansCapsulesOsmoticPressure;
  double rightEfferentArterioleResistance;
  double rightGlomerularCapillariesHydrostaticPressure;
  double rightGlomerularCapillariesOsmoticPressure;
  double rightGlomerularFiltrationCoefficient;
  double rightGlomerularFiltrationRate;
  double rightGlomerularFiltrationSurfaceArea;
  double rightGlomerularFluidPermeability;
  double rightFiltrationFraction;
  double rightNetFiltrationPressure;
  double rightNetReabsorptionPressure;
  double rightPeritubularCapillariesHydrostaticPressure;
  double rightPeritubularCapillariesOsmoticPressure;
  double rightReabsorptionFiltrationCoefficient;
  double rightReabsorptionRate;
  double rightTubularReabsorptionFiltrationSurfaceArea;
  double rightTubularReabsorptionFluidPermeability;
  double rightTubularHydrostaticPressure;
  double rightTubularOsmoticPressure;
  double urinationRate;
  double urineOsmolality;
  double urineOsmolarity;
  double urineProductionRate;
  double meanUrineOutput;
  double urineSpecificGravity;
  double urineVolume;
  double urineUreaNitrogenConcentration;

  //Respiratory
  double alveolarArterialGradient;
  double carricoIndex;
  double endTidalCarbonDioxideFraction;
  double endTidalCarbonDioxidePressure;
  double expiratoryFlow;
  double inspiratoryExpiratoryRatio;
  double inspiratoryFlow;
  double pulmonaryCompliance;
  double pulmonaryResistance;
  double respirationDriverPressure;
  double respirationMusclePressure;
  double respirationRate;
  double specificVentilation;
  double targetPulmonaryVentilation;
  double tidalVolume;
  double totalAlveolarVentilation;
  double totalDeadSpaceVentilation;
  double totalLungVolume;
  double totalPulmonaryVentilation;
  double transpulmonaryPressure;

  //Tissue
  double carbonDioxideProductionRate;
  double dehydrationFraction;
  double extracellularFluidVolume;
  double extravascularFluidVolume;
  double intracellularFluidPH;
  double intracellularFluidVolume;
  double totalBodyFluidVolume;
  double oxygenConsumptionRate;
  double respiratoryExchangeRatio;
  double liverInsulinSetPoint;
  double liverGlucagonSetPoint;
  double muscleInsulinSetPoint;
  double muscleGlucagonSetPoint;
  double fatInsulinSetPoint;
  double fatGlucagonSetPoint;
  double liverGlycogen;
  double muscleGlycogen;
  double storedProtein;
  double storedFat;

  //!
  //! Operators
  //!
  bool operator==(const PatientMetrics& rhs) const
  {
    return respiratory_rate_bpm == rhs.respiratory_rate_bpm
      && heart_rate_bpm == rhs.heart_rate_bpm
      && core_temperature_c == rhs.core_temperature_c
      && oxygen_saturation_pct == rhs.oxygen_saturation_pct
      && systolic_blood_pressure_mmHg == rhs.systolic_blood_pressure_mmHg
      && diastolic_blood_pressure_mmHg == rhs.diastolic_blood_pressure_mmHg
      && arterialBloodPH == rhs.arterialBloodPH
      && arterialBloodPHBaseline == rhs.arterialBloodPHBaseline
      && bloodDensity == rhs.bloodDensity
      && bloodSpecificHeat == rhs.bloodSpecificHeat
      && bloodUreaNitrogenConcentration == rhs.bloodUreaNitrogenConcentration
      && carbonDioxideSaturation == rhs.carbonDioxideSaturation
      && carbonMonoxideSaturation == rhs.carbonMonoxideSaturation
      && hematocrit == rhs.hematocrit
      && hemoglobinContent == rhs.hemoglobinContent
      && oxygenSaturation == rhs.oxygenSaturation
      && phosphate == rhs.phosphate
      && plasmaVolume == rhs.plasmaVolume
      && pulseOximetry == rhs.pulseOximetry
      && redBloodCellAcetylcholinesterase == rhs.redBloodCellAcetylcholinesterase
      && redBloodCellCount == rhs.redBloodCellCount
      && shuntFraction == rhs.shuntFraction
      && strongIonDifference == rhs.strongIonDifference
      && totalBilirubin == rhs.totalBilirubin
      && totalProteinConcentration == rhs.totalProteinConcentration
      && venousBloodPH == rhs.venousBloodPH
      && volumeFractionNeutralPhospholipidInPlasma == rhs.volumeFractionNeutralPhospholipidInPlasma
      && volumeFractionNeutralLipidInPlasma == rhs.volumeFractionNeutralLipidInPlasma
      && arterialCarbonDioxidePressure == rhs.arterialCarbonDioxidePressure
      && arterialOxygenPressure == rhs.arterialOxygenPressure
      && pulmonaryArterialCarbonDioxidePressure == rhs.pulmonaryArterialCarbonDioxidePressure
      && pulmonaryArterialOxygenPressure == rhs.pulmonaryArterialOxygenPressure
      && pulmonaryVenousCarbonDioxidePressure == rhs.pulmonaryVenousCarbonDioxidePressure
      && pulmonaryVenousOxygenPressure == rhs.pulmonaryVenousOxygenPressure
      && venousCarbonDioxidePressure == rhs.venousCarbonDioxidePressure
      && venousOxygenPressure == rhs.venousOxygenPressure
      && inflammatoryResponse == rhs.inflammatoryResponse
      && inflammatoryResponseLocalPathogen == rhs.inflammatoryResponseLocalPathogen
      && inflammatoryResponseLocalMacrophage == rhs.inflammatoryResponseLocalMacrophage
      && inflammatoryResponseLocalNeutrophil == rhs.inflammatoryResponseLocalNeutrophil
      && inflammatoryResponseLocalBarrier == rhs.inflammatoryResponseLocalBarrier
      && inflammatoryResponseBloodPathogen == rhs.inflammatoryResponseBloodPathogen
      && inflammatoryResponseTrauma == rhs.inflammatoryResponseTrauma
      && inflammatoryResponseMacrophageResting == rhs.inflammatoryResponseMacrophageResting
      && inflammatoryResponseMacrophageActive == rhs.inflammatoryResponseMacrophageActive
      && inflammatoryResponseNeutrophilResting == rhs.inflammatoryResponseNeutrophilResting
      && inflammatoryResponseNeutrophilActive == rhs.inflammatoryResponseNeutrophilActive
      && inflammatoryResponseInducibleNOSPre == rhs.inflammatoryResponseInducibleNOSPre
      && inflammatoryResponseInducibleNOS == rhs.inflammatoryResponseInducibleNOS
      && inflammatoryResponseConstitutiveNOS == rhs.inflammatoryResponseConstitutiveNOS
      && inflammatoryResponseNitrate == rhs.inflammatoryResponseNitrate
      && inflammatoryResponseNitricOxide == rhs.inflammatoryResponseNitricOxide
      && inflammatoryResponseTumorNecrosisFactor == rhs.inflammatoryResponseTumorNecrosisFactor
      && inflammatoryResponseInterleukin6 == rhs.inflammatoryResponseInterleukin6
      && inflammatoryResponseInterleukin10 == rhs.inflammatoryResponseInterleukin10
      && inflammatoryResponseInterleukin12 == rhs.inflammatoryResponseInterleukin12
      && inflammatoryResponseCatecholamines == rhs.inflammatoryResponseCatecholamines
      && inflammatoryResponseTissueIntegrity == rhs.inflammatoryResponseTissueIntegrity
      && arterialPressure == rhs.arterialPressure
      && bloodVolume == rhs.bloodVolume
      && cardiacIndex == rhs.cardiacIndex
      && cardiacOutput == rhs.cardiacOutput
      && centralVenousPressure == rhs.centralVenousPressure
      && cerebralBloodFlow == rhs.cerebralBloodFlow
      && cerebralPerfusionPressure == rhs.cerebralPerfusionPressure
      && diastolicArterialPressure == rhs.diastolicArterialPressure
      && heartEjectionFraction == rhs.heartEjectionFraction
      && heartRate == rhs.heartRate
      && heartStrokeVolume == rhs.heartStrokeVolume
      && intracranialPressure == rhs.intracranialPressure
      && meanArterialPressure == rhs.meanArterialPressure
      && meanArterialCarbonDioxidePartialPressure == rhs.meanArterialCarbonDioxidePartialPressure
      && meanArterialCarbonDioxidePartialPressureDelta == rhs.meanArterialCarbonDioxidePartialPressureDelta
      && meanCentralVenousPressure == rhs.meanCentralVenousPressure
      && meanSkinFlow == rhs.meanSkinFlow
      && pulmonaryArterialPressure == rhs.pulmonaryArterialPressure
      && pulmonaryCapillariesWedgePressure == rhs.pulmonaryCapillariesWedgePressure
      && pulmonaryDiastolicArterialPressure == rhs.pulmonaryDiastolicArterialPressure
      && pulmonaryMeanArterialPressure == rhs.pulmonaryMeanArterialPressure
      && pulmonaryMeanCapillaryFlow == rhs.pulmonaryMeanCapillaryFlow
      && pulmonaryMeanShuntFlow == rhs.pulmonaryMeanShuntFlow
      && pulmonarySystolicArterialPressure == rhs.pulmonarySystolicArterialPressure
      && pulmonaryVascularResistance == rhs.pulmonaryVascularResistance
      && pulmonaryVascularResistanceIndex == rhs.pulmonaryVascularResistanceIndex
      && pulsePressure == rhs.pulsePressure
      && systemicVascularResistance == rhs.systemicVascularResistance
      && systolicArterialPressure == rhs.systolicArterialPressure
      && bronchodilationLevel == rhs.bronchodilationLevel
      && heartRateChange == rhs.heartRateChange
      && hemorrhageChange == rhs.hemorrhageChange
      && meanBloodPressureChange == rhs.meanBloodPressureChange
      && neuromuscularBlockLevel == rhs.neuromuscularBlockLevel
      && pulsePressureChange == rhs.pulsePressureChange
      && respirationRateChange == rhs.respirationRateChange
      && sedationLevel == rhs.sedationLevel
      && tidalVolumeChange == rhs.tidalVolumeChange
      && tubularPermeabilityChange == rhs.tubularPermeabilityChange
      && centralNervousResponse == rhs.centralNervousResponse
      && insulinSynthesisRate == rhs.insulinSynthesisRate
      && glucagonSynthesisRate == rhs.glucagonSynthesisRate
      && achievedExerciseLevel == rhs.achievedExerciseLevel
      && chlorideLostToSweat == rhs.chlorideLostToSweat
      && coreTemperature == rhs.coreTemperature
      && creatinineProductionRate == rhs.creatinineProductionRate
      && exerciseMeanArterialPressureDelta == rhs.exerciseMeanArterialPressureDelta
      && fatigueLevel == rhs.fatigueLevel
      && lactateProductionRate == rhs.lactateProductionRate
      && potassiumLostToSweat == rhs.potassiumLostToSweat
      && skinTemperature == rhs.skinTemperature
      && sodiumLostToSweat == rhs.sodiumLostToSweat
      && sweatRate == rhs.sweatRate
      && totalMetabolicRate == rhs.totalMetabolicRate
      && totalWorkRateLevel == rhs.totalWorkRateLevel
      && chymeAbsorptionRate == rhs.chymeAbsorptionRate
      && stomachContents_calcium == rhs.stomachContents_calcium
      && stomachContents_carbohydrates == rhs.stomachContents_carbohydrates
      && stomachContents_carbohydrateDigationRate == rhs.stomachContents_carbohydrateDigationRate
      && stomachContents_fat == rhs.stomachContents_fat
      && stomachContents_fatDigtationRate == rhs.stomachContents_fatDigtationRate
      && stomachContents_protien == rhs.stomachContents_protien
      && stomachContents_protienDigtationRate == rhs.stomachContents_protienDigtationRate
      && stomachContents_sodium == rhs.stomachContents_sodium
      && stomachContents_water == rhs.stomachContents_water
      && ketoneproductionRate == rhs.ketoneproductionRate
      && hepaticGluconeogenesisRate == rhs.hepaticGluconeogenesisRate
      && baroreceptorHeartRateScale == rhs.baroreceptorHeartRateScale
      && baroreceptorHeartElastanceScale == rhs.baroreceptorHeartElastanceScale
      && baroreceptorResistanceScale == rhs.baroreceptorResistanceScale
      && baroreceptorComplianceScale == rhs.baroreceptorComplianceScale
      && chemoreceptorHeartRateScale == rhs.chemoreceptorHeartRateScale
      && chemoreceptorHeartElastanceScale == rhs.chemoreceptorHeartElastanceScale
      && painVisualAnalogueScale == rhs.painVisualAnalogueScale
      && leftEyePupillaryResponse == rhs.leftEyePupillaryResponse
      && rightEyePupillaryResponse == rhs.rightEyePupillaryResponse
      && glomerularFiltrationRate == rhs.glomerularFiltrationRate
      && filtrationFraction == rhs.filtrationFraction
      && leftAfferentArterioleResistance == rhs.leftAfferentArterioleResistance
      && leftBowmansCapsulesHydrostaticPressure == rhs.leftBowmansCapsulesHydrostaticPressure
      && leftBowmansCapsulesOsmoticPressure == rhs.leftBowmansCapsulesOsmoticPressure
      && leftEfferentArterioleResistance == rhs.leftEfferentArterioleResistance
      && leftGlomerularCapillariesHydrostaticPressure == rhs.leftGlomerularCapillariesHydrostaticPressure
      && leftGlomerularCapillariesOsmoticPressure == rhs.leftGlomerularCapillariesOsmoticPressure
      && leftGlomerularFiltrationCoefficient == rhs.leftGlomerularFiltrationCoefficient
      && leftGlomerularFiltrationRate == rhs.leftGlomerularFiltrationRate
      && leftGlomerularFiltrationSurfaceArea == rhs.leftGlomerularFiltrationSurfaceArea
      && leftGlomerularFluidPermeability == rhs.leftGlomerularFluidPermeability
      && leftFiltrationFraction == rhs.leftFiltrationFraction
      && leftNetFiltrationPressure == rhs.leftNetFiltrationPressure
      && leftNetReabsorptionPressure == rhs.leftNetReabsorptionPressure
      && leftPeritubularCapillariesHydrostaticPressure == rhs.leftPeritubularCapillariesHydrostaticPressure
      && leftPeritubularCapillariesOsmoticPressure == rhs.leftPeritubularCapillariesOsmoticPressure
      && leftReabsorptionFiltrationCoefficient == rhs.leftReabsorptionFiltrationCoefficient
      && leftReabsorptionRate == rhs.leftReabsorptionRate
      && leftTubularReabsorptionFiltrationSurfaceArea == rhs.leftTubularReabsorptionFiltrationSurfaceArea
      && leftTubularReabsorptionFluidPermeability == rhs.leftTubularReabsorptionFluidPermeability
      && leftTubularHydrostaticPressure == rhs.leftTubularHydrostaticPressure
      && leftTubularOsmoticPressure == rhs.leftTubularOsmoticPressure
      && renalBloodFlow == rhs.renalBloodFlow
      && renalPlasmaFlow == rhs.renalPlasmaFlow
      && renalVascularResistance == rhs.renalVascularResistance
      && rightAfferentArterioleResistance == rhs.rightAfferentArterioleResistance
      && rightBowmansCapsulesHydrostaticPressure == rhs.rightBowmansCapsulesHydrostaticPressure
      && rightBowmansCapsulesOsmoticPressure == rhs.rightBowmansCapsulesOsmoticPressure
      && rightEfferentArterioleResistance == rhs.rightEfferentArterioleResistance
      && rightGlomerularCapillariesHydrostaticPressure == rhs.rightGlomerularCapillariesHydrostaticPressure
      && rightGlomerularCapillariesOsmoticPressure == rhs.rightGlomerularCapillariesOsmoticPressure
      && rightGlomerularFiltrationCoefficient == rhs.rightGlomerularFiltrationCoefficient
      && rightGlomerularFiltrationRate == rhs.rightGlomerularFiltrationRate
      && rightGlomerularFiltrationSurfaceArea == rhs.rightGlomerularFiltrationSurfaceArea
      && rightGlomerularFluidPermeability == rhs.rightGlomerularFluidPermeability
      && rightFiltrationFraction == rhs.rightFiltrationFraction
      && rightNetFiltrationPressure == rhs.rightNetFiltrationPressure
      && rightNetReabsorptionPressure == rhs.rightNetReabsorptionPressure
      && rightPeritubularCapillariesHydrostaticPressure == rhs.rightPeritubularCapillariesHydrostaticPressure
      && rightPeritubularCapillariesOsmoticPressure == rhs.rightPeritubularCapillariesOsmoticPressure
      && rightReabsorptionFiltrationCoefficient == rhs.rightReabsorptionFiltrationCoefficient
      && rightReabsorptionRate == rhs.rightReabsorptionRate
      && rightTubularReabsorptionFiltrationSurfaceArea == rhs.rightTubularReabsorptionFiltrationSurfaceArea
      && rightTubularReabsorptionFluidPermeability == rhs.rightTubularReabsorptionFluidPermeability
      && rightTubularHydrostaticPressure == rhs.rightTubularHydrostaticPressure
      && rightTubularOsmoticPressure == rhs.rightTubularOsmoticPressure
      && urinationRate == rhs.urinationRate
      && urineOsmolality == rhs.urineOsmolality
      && urineOsmolarity == rhs.urineOsmolarity
      && urineProductionRate == rhs.urineProductionRate
      && meanUrineOutput == rhs.meanUrineOutput
      && urineSpecificGravity == rhs.urineSpecificGravity
      && urineVolume == rhs.urineVolume
      && urineUreaNitrogenConcentration == rhs.urineUreaNitrogenConcentration
      && alveolarArterialGradient == rhs.alveolarArterialGradient
      && carricoIndex == rhs.carricoIndex
      && endTidalCarbonDioxideFraction == rhs.endTidalCarbonDioxideFraction
      && endTidalCarbonDioxidePressure == rhs.endTidalCarbonDioxidePressure
      && expiratoryFlow == rhs.expiratoryFlow
      && inspiratoryExpiratoryRatio == rhs.inspiratoryExpiratoryRatio
      && inspiratoryFlow == rhs.inspiratoryFlow
      && pulmonaryCompliance == rhs.pulmonaryCompliance
      && pulmonaryResistance == rhs.pulmonaryResistance
      && respirationDriverPressure == rhs.respirationDriverPressure
      && respirationMusclePressure == rhs.respirationMusclePressure
      && respirationRate == rhs.respirationRate
      && specificVentilation == rhs.specificVentilation
      && targetPulmonaryVentilation == rhs.targetPulmonaryVentilation
      && tidalVolume == rhs.tidalVolume
      && totalAlveolarVentilation == rhs.totalAlveolarVentilation
      && totalDeadSpaceVentilation == rhs.totalDeadSpaceVentilation
      && totalLungVolume == rhs.totalLungVolume
      && totalPulmonaryVentilation == rhs.totalPulmonaryVentilation
      && transpulmonaryPressure == rhs.transpulmonaryPressure
      && carbonDioxideProductionRate == rhs.carbonDioxideProductionRate
      && dehydrationFraction == rhs.dehydrationFraction
      && extracellularFluidVolume == rhs.extracellularFluidVolume
      && extravascularFluidVolume == rhs.extravascularFluidVolume
      && intracellularFluidPH == rhs.intracellularFluidPH
      && intracellularFluidVolume == rhs.intracellularFluidVolume
      && totalBodyFluidVolume == rhs.totalBodyFluidVolume
      && oxygenConsumptionRate == rhs.oxygenConsumptionRate
      && respiratoryExchangeRatio == rhs.respiratoryExchangeRatio
      && liverInsulinSetPoint == rhs.liverInsulinSetPoint
      && liverGlucagonSetPoint == rhs.liverGlucagonSetPoint
      && muscleInsulinSetPoint == rhs.muscleInsulinSetPoint
      && muscleGlucagonSetPoint == rhs.muscleGlucagonSetPoint
      && fatInsulinSetPoint == rhs.fatInsulinSetPoint
      && fatGlucagonSetPoint == rhs.fatGlucagonSetPoint
      && liverGlycogen == rhs.liverGlycogen
      && muscleGlycogen == rhs.muscleGlycogen
      && storedProtein == rhs.storedProtein
      && storedFat == rhs.storedFat

      && simulationTime == rhs.simulationTime
      && timeStep == rhs.timeStep;
  }
  bool operator!=(const PatientMetrics& rhs) const { return !(*this == rhs); }

private:
  Q_OBJECT
  Q_PROPERTY(QString RespritoryRate MEMBER respiratory_rate_bpm)
  Q_PROPERTY(QString HeartRate MEMBER heart_rate_bpm)
  Q_PROPERTY(QString CoreTemp MEMBER core_temperature_c)
  Q_PROPERTY(QString OxygenSaturation MEMBER oxygen_saturation_pct)
  Q_PROPERTY(QString SystolicBloodPressure MEMBER systolic_blood_pressure_mmHg)
  Q_PROPERTY(QString DiastolicBloodPressure MEMBER diastolic_blood_pressure_mmHg)

  Q_PROPERTY(double SimulationTime MEMBER simulationTime)
  Q_PROPERTY(double TimeStep MEMBER timeStep)

  Q_PROPERTY(double arterialBloodPH MEMBER arterialBloodPH)
  Q_PROPERTY(double arterialBloodPHBaseline MEMBER arterialBloodPHBaseline)
  Q_PROPERTY(double bloodDensity MEMBER bloodDensity)
  Q_PROPERTY(double bloodSpecificHeat MEMBER bloodSpecificHeat)
  Q_PROPERTY(double bloodUreaNitrogenConcentration MEMBER bloodUreaNitrogenConcentration)
  Q_PROPERTY(double carbonDioxideSaturation MEMBER carbonDioxideSaturation)
  Q_PROPERTY(double carbonMonoxideSaturation MEMBER carbonMonoxideSaturation)
  Q_PROPERTY(double hematocrit MEMBER hematocrit)
  Q_PROPERTY(double hemoglobinContent MEMBER hemoglobinContent)
  Q_PROPERTY(double oxygenSaturation MEMBER oxygenSaturation)
  Q_PROPERTY(double phosphate MEMBER phosphate)
  Q_PROPERTY(double plasmaVolume MEMBER plasmaVolume)
  Q_PROPERTY(double pulseOximetry MEMBER pulseOximetry)
  Q_PROPERTY(double redBloodCellAcetylcholinesterase MEMBER redBloodCellAcetylcholinesterase)
  Q_PROPERTY(double redBloodCellCount MEMBER redBloodCellCount)
  Q_PROPERTY(double shuntFraction MEMBER shuntFraction)
  Q_PROPERTY(double strongIonDifference MEMBER strongIonDifference)
  Q_PROPERTY(double totalBilirubin MEMBER totalBilirubin)
  Q_PROPERTY(double totalProteinConcentration MEMBER totalProteinConcentration)
  Q_PROPERTY(double venousBloodPH MEMBER venousBloodPH)
  Q_PROPERTY(double volumeFractionNeutralPhospholipidInPlasma MEMBER volumeFractionNeutralPhospholipidInPlasma)
  Q_PROPERTY(double volumeFractionNeutralLipidInPlasma MEMBER volumeFractionNeutralLipidInPlasma)
  Q_PROPERTY(double arterialCarbonDioxidePressure MEMBER arterialCarbonDioxidePressure)
  Q_PROPERTY(double arterialOxygenPressure MEMBER arterialOxygenPressure)
  Q_PROPERTY(double pulmonaryArterialCarbonDioxidePressure MEMBER pulmonaryArterialCarbonDioxidePressure)
  Q_PROPERTY(double pulmonaryArterialOxygenPressure MEMBER pulmonaryArterialOxygenPressure)
  Q_PROPERTY(double pulmonaryVenousCarbonDioxidePressure MEMBER pulmonaryVenousCarbonDioxidePressure)
  Q_PROPERTY(double pulmonaryVenousOxygenPressure MEMBER pulmonaryVenousOxygenPressure)
  Q_PROPERTY(double venousCarbonDioxidePressure MEMBER venousCarbonDioxidePressure)
  Q_PROPERTY(double venousOxygenPressure MEMBER venousOxygenPressure)
  Q_PROPERTY(bool inflammatoryResponse MEMBER inflammatoryResponse)
  Q_PROPERTY(double inflammatoryResponseLocalPathogen MEMBER inflammatoryResponseLocalPathogen)
  Q_PROPERTY(double inflammatoryResponseLocalMacrophage MEMBER inflammatoryResponseLocalMacrophage)
  Q_PROPERTY(double inflammatoryResponseLocalNeutrophil MEMBER inflammatoryResponseLocalNeutrophil)
  Q_PROPERTY(double inflammatoryResponseLocalBarrier MEMBER inflammatoryResponseLocalBarrier)
  Q_PROPERTY(double inflammatoryResponseBloodPathogen MEMBER inflammatoryResponseBloodPathogen)
  Q_PROPERTY(double inflammatoryResponseTrauma MEMBER inflammatoryResponseTrauma)
  Q_PROPERTY(double inflammatoryResponseMacrophageResting MEMBER inflammatoryResponseMacrophageResting)
  Q_PROPERTY(double inflammatoryResponseMacrophageActive MEMBER inflammatoryResponseMacrophageActive)
  Q_PROPERTY(double inflammatoryResponseNeutrophilResting MEMBER inflammatoryResponseNeutrophilResting)
  Q_PROPERTY(double inflammatoryResponseNeutrophilActive MEMBER inflammatoryResponseNeutrophilActive)
  Q_PROPERTY(double inflammatoryResponseInducibleNOSPre MEMBER inflammatoryResponseInducibleNOSPre)
  Q_PROPERTY(double inflammatoryResponseInducibleNOS MEMBER inflammatoryResponseInducibleNOS)
  Q_PROPERTY(double inflammatoryResponseConstitutiveNOS MEMBER inflammatoryResponseConstitutiveNOS)
  Q_PROPERTY(double inflammatoryResponseNitrate MEMBER inflammatoryResponseNitrate)
  Q_PROPERTY(double inflammatoryResponseNitricOxide MEMBER inflammatoryResponseNitricOxide)
  Q_PROPERTY(double inflammatoryResponseTumorNecrosisFactor MEMBER inflammatoryResponseTumorNecrosisFactor)
  Q_PROPERTY(double inflammatoryResponseInterleukin6 MEMBER inflammatoryResponseInterleukin6)
  Q_PROPERTY(double inflammatoryResponseInterleukin10 MEMBER inflammatoryResponseInterleukin10)
  Q_PROPERTY(double inflammatoryResponseInterleukin12 MEMBER inflammatoryResponseInterleukin12)
  Q_PROPERTY(double inflammatoryResponseCatecholamines MEMBER inflammatoryResponseCatecholamines)
  Q_PROPERTY(double inflammatoryResponseTissueIntegrity MEMBER inflammatoryResponseTissueIntegrity)
  Q_PROPERTY(double arterialPressure MEMBER arterialPressure)
  Q_PROPERTY(double bloodVolume MEMBER bloodVolume)
  Q_PROPERTY(double cardiacIndex MEMBER cardiacIndex)
  Q_PROPERTY(double cardiacOutput MEMBER cardiacOutput)
  Q_PROPERTY(double centralVenousPressure MEMBER centralVenousPressure)
  Q_PROPERTY(double cerebralBloodFlow MEMBER cerebralBloodFlow)
  Q_PROPERTY(double cerebralPerfusionPressure MEMBER cerebralPerfusionPressure)
  Q_PROPERTY(double diastolicArterialPressure MEMBER diastolicArterialPressure)
  Q_PROPERTY(double heartEjectionFraction MEMBER heartEjectionFraction)
  Q_PROPERTY(double heartRate MEMBER heartRate)
  Q_PROPERTY(double heartStrokeVolume MEMBER heartStrokeVolume)
  Q_PROPERTY(double intracranialPressure MEMBER intracranialPressure)
  Q_PROPERTY(double meanArterialPressure MEMBER meanArterialPressure)
  Q_PROPERTY(double meanArterialCarbonDioxidePartialPressure MEMBER meanArterialCarbonDioxidePartialPressure)
  Q_PROPERTY(double meanArterialCarbonDioxidePartialPressureDelta MEMBER meanArterialCarbonDioxidePartialPressureDelta)
  Q_PROPERTY(double meanCentralVenousPressure MEMBER meanCentralVenousPressure)
  Q_PROPERTY(double meanSkinFlow MEMBER meanSkinFlow)
  Q_PROPERTY(double pulmonaryArterialPressure MEMBER pulmonaryArterialPressure)
  Q_PROPERTY(double pulmonaryCapillariesWedgePressure MEMBER pulmonaryCapillariesWedgePressure)
  Q_PROPERTY(double pulmonaryDiastolicArterialPressure MEMBER pulmonaryDiastolicArterialPressure)
  Q_PROPERTY(double pulmonaryMeanArterialPressure MEMBER pulmonaryMeanArterialPressure)
  Q_PROPERTY(double pulmonaryMeanCapillaryFlow MEMBER pulmonaryMeanCapillaryFlow)
  Q_PROPERTY(double pulmonaryMeanShuntFlow MEMBER pulmonaryMeanShuntFlow)
  Q_PROPERTY(double pulmonarySystolicArterialPressure MEMBER pulmonarySystolicArterialPressure)
  Q_PROPERTY(double pulmonaryVascularResistance MEMBER pulmonaryVascularResistance)
  Q_PROPERTY(double pulmonaryVascularResistanceIndex MEMBER pulmonaryVascularResistanceIndex)
  Q_PROPERTY(double pulsePressure MEMBER pulsePressure)
  Q_PROPERTY(double systemicVascularResistance MEMBER systemicVascularResistance)
  Q_PROPERTY(double systolicArterialPressure MEMBER systolicArterialPressure)
  Q_PROPERTY(double bronchodilationLevel MEMBER bronchodilationLevel)
  Q_PROPERTY(double heartRateChange MEMBER heartRateChange)
  Q_PROPERTY(double hemorrhageChange MEMBER hemorrhageChange)
  Q_PROPERTY(double meanBloodPressureChange MEMBER meanBloodPressureChange)
  Q_PROPERTY(double neuromuscularBlockLevel MEMBER neuromuscularBlockLevel)
  Q_PROPERTY(double pulsePressureChange MEMBER pulsePressureChange)
  Q_PROPERTY(double respirationRateChange MEMBER respirationRateChange)
  Q_PROPERTY(double sedationLevel MEMBER sedationLevel)
  Q_PROPERTY(double tidalVolumeChange MEMBER tidalVolumeChange)
  Q_PROPERTY(double tubularPermeabilityChange MEMBER tubularPermeabilityChange)
  Q_PROPERTY(double centralNervousResponse MEMBER centralNervousResponse)
  Q_PROPERTY(double insulinSynthesisRate MEMBER insulinSynthesisRate)
  Q_PROPERTY(double glucagonSynthesisRate MEMBER glucagonSynthesisRate)
  Q_PROPERTY(double achievedExerciseLevel MEMBER achievedExerciseLevel)
  Q_PROPERTY(double chlorideLostToSweat MEMBER chlorideLostToSweat)
  Q_PROPERTY(double coreTemperature MEMBER coreTemperature)
  Q_PROPERTY(double creatinineProductionRate MEMBER creatinineProductionRate)
  Q_PROPERTY(double exerciseMeanArterialPressureDelta MEMBER exerciseMeanArterialPressureDelta)
  Q_PROPERTY(double fatigueLevel MEMBER fatigueLevel)
  Q_PROPERTY(double lactateProductionRate MEMBER lactateProductionRate)
  Q_PROPERTY(double potassiumLostToSweat MEMBER potassiumLostToSweat)
  Q_PROPERTY(double skinTemperature MEMBER skinTemperature)
  Q_PROPERTY(double sodiumLostToSweat MEMBER sodiumLostToSweat)
  Q_PROPERTY(double sweatRate MEMBER sweatRate)
  Q_PROPERTY(double totalMetabolicRate MEMBER totalMetabolicRate)
  Q_PROPERTY(double totalWorkRateLevel MEMBER totalWorkRateLevel)
  Q_PROPERTY(double chymeAbsorptionRate MEMBER chymeAbsorptionRate)
  Q_PROPERTY(double stomachContents_calcium MEMBER stomachContents_calcium)
  Q_PROPERTY(double stomachContents_carbohydrates MEMBER stomachContents_carbohydrates)
  Q_PROPERTY(double stomachContents_carbohydrateDigationRate MEMBER stomachContents_carbohydrateDigationRate)
  Q_PROPERTY(double stomachContents_fat MEMBER stomachContents_fat)
  Q_PROPERTY(double stomachContents_fatDigtationRate MEMBER stomachContents_fatDigtationRate)
  Q_PROPERTY(double stomachContents_protien MEMBER stomachContents_protien)
  Q_PROPERTY(double stomachContents_protienDigtationRate MEMBER stomachContents_protienDigtationRate)
  Q_PROPERTY(double stomachContents_sodium MEMBER stomachContents_sodium)
  Q_PROPERTY(double stomachContents_water MEMBER stomachContents_water)
  Q_PROPERTY(double ketoneproductionRate MEMBER ketoneproductionRate)
  Q_PROPERTY(double hepaticGluconeogenesisRate MEMBER hepaticGluconeogenesisRate)
  Q_PROPERTY(double baroreceptorHeartRateScale MEMBER baroreceptorHeartRateScale)
  Q_PROPERTY(double baroreceptorHeartElastanceScale MEMBER baroreceptorHeartElastanceScale)
  Q_PROPERTY(double baroreceptorResistanceScale MEMBER baroreceptorResistanceScale)
  Q_PROPERTY(double baroreceptorComplianceScale MEMBER baroreceptorComplianceScale)
  Q_PROPERTY(double chemoreceptorHeartRateScale MEMBER chemoreceptorHeartRateScale)
  Q_PROPERTY(double chemoreceptorHeartElastanceScale MEMBER chemoreceptorHeartElastanceScale)
  Q_PROPERTY(double painVisualAnalogueScale MEMBER painVisualAnalogueScale)
  Q_PROPERTY(double leftEyePupillaryResponse MEMBER leftEyePupillaryResponse)
  Q_PROPERTY(double rightEyePupillaryResponse MEMBER rightEyePupillaryResponse)
  Q_PROPERTY(double glomerularFiltrationRate MEMBER glomerularFiltrationRate)
  Q_PROPERTY(double filtrationFraction MEMBER filtrationFraction)
  Q_PROPERTY(double leftAfferentArterioleResistance MEMBER leftAfferentArterioleResistance)
  Q_PROPERTY(double leftBowmansCapsulesHydrostaticPressure MEMBER leftBowmansCapsulesHydrostaticPressure)
  Q_PROPERTY(double leftBowmansCapsulesOsmoticPressure MEMBER leftBowmansCapsulesOsmoticPressure)
  Q_PROPERTY(double leftEfferentArterioleResistance MEMBER leftEfferentArterioleResistance)
  Q_PROPERTY(double leftGlomerularCapillariesHydrostaticPressure MEMBER leftGlomerularCapillariesHydrostaticPressure)
  Q_PROPERTY(double leftGlomerularCapillariesOsmoticPressure MEMBER leftGlomerularCapillariesOsmoticPressure)
  Q_PROPERTY(double leftGlomerularFiltrationCoefficient MEMBER leftGlomerularFiltrationCoefficient)
  Q_PROPERTY(double leftGlomerularFiltrationRate MEMBER leftGlomerularFiltrationRate)
  Q_PROPERTY(double leftGlomerularFiltrationSurfaceArea MEMBER leftGlomerularFiltrationSurfaceArea)
  Q_PROPERTY(double leftGlomerularFluidPermeability MEMBER leftGlomerularFluidPermeability)
  Q_PROPERTY(double leftFiltrationFraction MEMBER leftFiltrationFraction)
  Q_PROPERTY(double leftNetFiltrationPressure MEMBER leftNetFiltrationPressure)
  Q_PROPERTY(double leftNetReabsorptionPressure MEMBER leftNetReabsorptionPressure)
  Q_PROPERTY(double leftPeritubularCapillariesHydrostaticPressure MEMBER leftPeritubularCapillariesHydrostaticPressure)
  Q_PROPERTY(double leftPeritubularCapillariesOsmoticPressure MEMBER leftPeritubularCapillariesOsmoticPressure)
  Q_PROPERTY(double leftReabsorptionFiltrationCoefficient MEMBER leftReabsorptionFiltrationCoefficient)
  Q_PROPERTY(double leftReabsorptionRate MEMBER leftReabsorptionRate)
  Q_PROPERTY(double leftTubularReabsorptionFiltrationSurfaceArea MEMBER leftTubularReabsorptionFiltrationSurfaceArea)
  Q_PROPERTY(double leftTubularReabsorptionFluidPermeability MEMBER leftTubularReabsorptionFluidPermeability)
  Q_PROPERTY(double leftTubularHydrostaticPressure MEMBER leftTubularHydrostaticPressure)
  Q_PROPERTY(double leftTubularOsmoticPressure MEMBER leftTubularOsmoticPressure)
  Q_PROPERTY(double renalBloodFlow MEMBER renalBloodFlow)
  Q_PROPERTY(double renalPlasmaFlow MEMBER renalPlasmaFlow)
  Q_PROPERTY(double renalVascularResistance MEMBER renalVascularResistance)
  Q_PROPERTY(double rightAfferentArterioleResistance MEMBER rightAfferentArterioleResistance)
  Q_PROPERTY(double rightBowmansCapsulesHydrostaticPressure MEMBER rightBowmansCapsulesHydrostaticPressure)
  Q_PROPERTY(double rightBowmansCapsulesOsmoticPressure MEMBER rightBowmansCapsulesOsmoticPressure)
  Q_PROPERTY(double rightEfferentArterioleResistance MEMBER rightEfferentArterioleResistance)
  Q_PROPERTY(double rightGlomerularCapillariesHydrostaticPressure MEMBER rightGlomerularCapillariesHydrostaticPressure)
  Q_PROPERTY(double rightGlomerularCapillariesOsmoticPressure MEMBER rightGlomerularCapillariesOsmoticPressure)
  Q_PROPERTY(double rightGlomerularFiltrationCoefficient MEMBER rightGlomerularFiltrationCoefficient)
  Q_PROPERTY(double rightGlomerularFiltrationRate MEMBER rightGlomerularFiltrationRate)
  Q_PROPERTY(double rightGlomerularFiltrationSurfaceArea MEMBER rightGlomerularFiltrationSurfaceArea)
  Q_PROPERTY(double rightGlomerularFluidPermeability MEMBER rightGlomerularFluidPermeability)
  Q_PROPERTY(double rightFiltrationFraction MEMBER rightFiltrationFraction)
  Q_PROPERTY(double rightNetFiltrationPressure MEMBER rightNetFiltrationPressure)
  Q_PROPERTY(double rightNetReabsorptionPressure MEMBER rightNetReabsorptionPressure)
  Q_PROPERTY(double rightPeritubularCapillariesHydrostaticPressure MEMBER rightPeritubularCapillariesHydrostaticPressure)
  Q_PROPERTY(double rightPeritubularCapillariesOsmoticPressure MEMBER rightPeritubularCapillariesOsmoticPressure)
  Q_PROPERTY(double rightReabsorptionFiltrationCoefficient MEMBER rightReabsorptionFiltrationCoefficient)
  Q_PROPERTY(double rightReabsorptionRate MEMBER rightReabsorptionRate)
  Q_PROPERTY(double rightTubularReabsorptionFiltrationSurfaceArea MEMBER rightTubularReabsorptionFiltrationSurfaceArea)
  Q_PROPERTY(double rightTubularReabsorptionFluidPermeability MEMBER rightTubularReabsorptionFluidPermeability)
  Q_PROPERTY(double rightTubularHydrostaticPressure MEMBER rightTubularHydrostaticPressure)
  Q_PROPERTY(double rightTubularOsmoticPressure MEMBER rightTubularOsmoticPressure)
  Q_PROPERTY(double urinationRate MEMBER urinationRate)
  Q_PROPERTY(double urineOsmolality MEMBER urineOsmolality)
  Q_PROPERTY(double urineOsmolarity MEMBER urineOsmolarity)
  Q_PROPERTY(double urineProductionRate MEMBER urineProductionRate)
  Q_PROPERTY(double meanUrineOutput MEMBER meanUrineOutput)
  Q_PROPERTY(double urineSpecificGravity MEMBER urineSpecificGravity)
  Q_PROPERTY(double urineVolume MEMBER urineVolume)
  Q_PROPERTY(double urineUreaNitrogenConcentration MEMBER urineUreaNitrogenConcentration)
  Q_PROPERTY(double alveolarArterialGradient MEMBER alveolarArterialGradient)
  Q_PROPERTY(double carricoIndex MEMBER carricoIndex)
  Q_PROPERTY(double endTidalCarbonDioxideFraction MEMBER endTidalCarbonDioxideFraction)
  Q_PROPERTY(double endTidalCarbonDioxidePressure MEMBER endTidalCarbonDioxidePressure)
  Q_PROPERTY(double expiratoryFlow MEMBER expiratoryFlow)
  Q_PROPERTY(double inspiratoryExpiratoryRatio MEMBER inspiratoryExpiratoryRatio)
  Q_PROPERTY(double inspiratoryFlow MEMBER inspiratoryFlow)
  Q_PROPERTY(double pulmonaryCompliance MEMBER pulmonaryCompliance)
  Q_PROPERTY(double pulmonaryResistance MEMBER pulmonaryResistance)
  Q_PROPERTY(double respirationDriverPressure MEMBER respirationDriverPressure)
  Q_PROPERTY(double respirationMusclePressure MEMBER respirationMusclePressure)
  Q_PROPERTY(double respirationRate MEMBER respirationRate)
  Q_PROPERTY(double specificVentilation MEMBER specificVentilation)
  Q_PROPERTY(double targetPulmonaryVentilation MEMBER targetPulmonaryVentilation)
  Q_PROPERTY(double tidalVolume MEMBER tidalVolume)
  Q_PROPERTY(double totalAlveolarVentilation MEMBER totalAlveolarVentilation)
  Q_PROPERTY(double totalDeadSpaceVentilation MEMBER totalDeadSpaceVentilation)
  Q_PROPERTY(double totalLungVolume MEMBER totalLungVolume)
  Q_PROPERTY(double totalPulmonaryVentilation MEMBER totalPulmonaryVentilation)
  Q_PROPERTY(double transpulmonaryPressure MEMBER transpulmonaryPressure)
  Q_PROPERTY(double carbonDioxideProductionRate MEMBER carbonDioxideProductionRate)
  Q_PROPERTY(double dehydrationFraction MEMBER dehydrationFraction)
  Q_PROPERTY(double extracellularFluidVolume MEMBER extracellularFluidVolume)
  Q_PROPERTY(double extravascularFluidVolume MEMBER extravascularFluidVolume)
  Q_PROPERTY(double intracellularFluidPH MEMBER intracellularFluidPH)
  Q_PROPERTY(double intracellularFluidVolume MEMBER intracellularFluidVolume)
  Q_PROPERTY(double totalBodyFluidVolume MEMBER totalBodyFluidVolume)
  Q_PROPERTY(double oxygenConsumptionRate MEMBER oxygenConsumptionRate)
  Q_PROPERTY(double respiratoryExchangeRatio MEMBER respiratoryExchangeRatio)
  Q_PROPERTY(double liverInsulinSetPoint MEMBER liverInsulinSetPoint)
  Q_PROPERTY(double liverGlucagonSetPoint MEMBER liverGlucagonSetPoint)
  Q_PROPERTY(double muscleInsulinSetPoint MEMBER muscleInsulinSetPoint)
  Q_PROPERTY(double muscleGlucagonSetPoint MEMBER muscleGlucagonSetPoint)
  Q_PROPERTY(double fatInsulinSetPoint MEMBER fatInsulinSetPoint)
  Q_PROPERTY(double fatGlucagonSetPoint MEMBER fatGlucagonSetPoint)
  Q_PROPERTY(double liverGlycogen MEMBER liverGlycogen)
  Q_PROPERTY(double muscleGlycogen MEMBER muscleGlycogen)
  Q_PROPERTY(double storedProtein MEMBER storedProtein)
  Q_PROPERTY(double storedFat MEMBER storedFat)
};