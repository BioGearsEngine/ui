import QtQuick 2.4
import QtQuick.Controls.Material 2.12
import QtCharts 2.3

import com.biogearsengine.ui.scenario 1.0

GraphAreaForm {
  signal start()
  signal stop()
  signal pause()

  signal metricUpdates(PatientMetrics metrics)
  signal stateUpdates(PatientState state)
  signal conditionUpdates(PatientConditions conditions)

  property double count_1 : 0.0
  property double count_2 : 0.0

  onStart : {
    console.log("GraphAreaForm " + "start")
  }

  onStop : {
    console.log("GraphAreaForm " + "stop")
  }

  onPause: {
    console.log("GraphAreaForm " + "pause")
  }

  onMetricUpdates: {
    updateBloodChemistry(metrics)
    updateCardiovascular(metrics)
    updateDrugs(metrics)
    updateEndocrine(metrics)
    updateEnergy(metrics)
    updateGastrointestinal(metrics)
    updateHepatic(metrics)
    updateNervous(metrics)
    updateRenal(metrics)
    updateRespiratory(metrics)
    updateTissue(metrics)
  }



  onStateUpdates: {
  }

  onConditionUpdates: {
  }
  Component.onCompleted: {
     setupBloodChemistry()
     setupCardiovascular()
     setupDrugs()
     setupEndocrine()
     setupEnergy()
     setupGastrointestinal()
     setupHepatic()
     setupNervous()
     setupRenal()
     setupRespiratory()
     setupTissue()
  }

  function newPointHandler(series,pointIndex) {
      var start = ( series.count < 3600 ) ? 0 : series.count - 3600;
      var min = series.at(start).y;
      var max = series.at(start).y;

      for(var i = start; i < series.count; ++i){
          min = Math.min(min >= series.at(i).y) ? series.at(i).y : min;
          max = (max <= series.at(i).y) ? series.at(i).y : max;
      }
      if(series.axisY){
        series.axisY.min = Math.max(0,min * .90)
        series.axisY.max = Math.max(1,max * 1.10)
      } else if (series.axisYRight) {
        series.axisYRight.min = Math.max(0,min * .90)
        series.axisYRight.max = Math.max(1,max * 1.10)
      }
  }

  function updateDomain(axisX) {
    axisX.tickCount = axisX.tickCount + 1;
    const interval =  60 * 15
    if ( axisX.tickCount > interval ){
      axisX.min = axisX.tickCount - interval
      axisX.max = axisX.tickCount
    } else {
      axisX.min = 0
      axisX.max = interval
    }
  }

  //!
  //!  Signal/Slot Connections for pointAdded
  //!  We eventually only want to update what is visible and maybe
  //!  clear data when its not on screen
  //!
  //!  If anyone finds a better layout for data/*.qml and these signal/slots
  //!  Feel free to refactor it, most clearner ways I tried did not work
  //!  Due to the insane way I have to add plots to a line series
  Connections {
    target : bloodChemistry.requests.arterialBloodPH
    onPointAdded : newPointHandler(bloodChemistry.requests.arterialBloodPH, index)
  }
  Connections {
    target : bloodChemistry.requests.arterialBloodPHBaseline
    onPointAdded : newPointHandler(bloodChemistry.requests.arterialBloodPHBaseline, index)
  }
  Connections {
    target : bloodChemistry.requests.bloodDensity
    onPointAdded : newPointHandler(bloodChemistry.requests.bloodDensity, index)
  }
  Connections {
    target : bloodChemistry.requests.bloodSpecificHeat
    onPointAdded : newPointHandler(bloodChemistry.requests.bloodSpecificHeat, index)
  }
  Connections {
    target : bloodChemistry.requests.bloodUreaNitrogenConcentration
    onPointAdded : newPointHandler(bloodChemistry.requests.bloodUreaNitrogenConcentration, index)
  }
  Connections {
    target : bloodChemistry.requests.carbonDioxideSaturation
    onPointAdded : newPointHandler(bloodChemistry.requests.carbonDioxideSaturation, index)
  }
  Connections {
    target : bloodChemistry.requests.carbonMonoxideSaturation
    onPointAdded : newPointHandler(bloodChemistry.requests.carbonMonoxideSaturation, index)
  }
  Connections {
    target : bloodChemistry.requests.hematocrit
    onPointAdded : newPointHandler(bloodChemistry.requests.hematocrit, index)
  }
  Connections {
    target : bloodChemistry.requests.hemoglobinContent
    onPointAdded : newPointHandler(bloodChemistry.requests.hemoglobinContent, index)
  }
  Connections {
    target : bloodChemistry.requests.oxygenSaturation
    onPointAdded : newPointHandler(bloodChemistry.requests.oxygenSaturation, index)
  }
  Connections {
    target : bloodChemistry.requests.phosphate
    onPointAdded : newPointHandler(bloodChemistry.requests.phosphate, index)
  }
  Connections {
    target : bloodChemistry.requests.plasmaVolume
    onPointAdded : newPointHandler(bloodChemistry.requests.plasmaVolume, index)
  }
  Connections {
    target : bloodChemistry.requests.pulseOximetry
    onPointAdded : newPointHandler(bloodChemistry.requests.pulseOximetry, index)
  }
  Connections {
    target : bloodChemistry.requests.redBloodCellAcetylcholinesterase
    onPointAdded : newPointHandler(bloodChemistry.requests.redBloodCellAcetylcholinesterase, index)
  }
  Connections {
    target : bloodChemistry.requests.redBloodCellCount
    onPointAdded : newPointHandler(bloodChemistry.requests.redBloodCellCount, index)
  }
  Connections {
    target : bloodChemistry.requests.shuntFraction
    onPointAdded : newPointHandler(bloodChemistry.requests.shuntFraction, index)
  }
  Connections {
    target : bloodChemistry.requests.strongIonDifference
    onPointAdded : newPointHandler(bloodChemistry.requests.strongIonDifference, index)
  }
  Connections {
    target : bloodChemistry.requests.totalBilirubin
    onPointAdded : newPointHandler(bloodChemistry.requests.totalBilirubin, index)
  }
  Connections {
    target : bloodChemistry.requests.totalProteinConcentration
    onPointAdded : newPointHandler(bloodChemistry.requests.totalProteinConcentration, index)
  }
  Connections {
    target : bloodChemistry.requests.venousBloodPH
    onPointAdded : newPointHandler(bloodChemistry.requests.venousBloodPH, index)
  }
  Connections {
    target : bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma
    onPointAdded : newPointHandler(bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma, index)
  }
  Connections {
    target : bloodChemistry.requests.volumeFractionNeutralLipidInPlasma
    onPointAdded : newPointHandler(bloodChemistry.requests.volumeFractionNeutralLipidInPlasma, index)
  }
  Connections {
    target : bloodChemistry.requests.arterialCarbonDioxidePressure
    onPointAdded : newPointHandler(bloodChemistry.requests.arterialCarbonDioxidePressure, index)
  }
  Connections {
    target : bloodChemistry.requests.arterialOxygenPressure
    onPointAdded : newPointHandler(bloodChemistry.requests.arterialOxygenPressure, index)
  }
  Connections {
    target : bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure
    onPointAdded : newPointHandler(bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure, index)
  }
  Connections {
    target : bloodChemistry.requests.pulmonaryArterialOxygenPressure
    onPointAdded : newPointHandler(bloodChemistry.requests.pulmonaryArterialOxygenPressure, index)
  }
  Connections {
    target : bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure
    onPointAdded : newPointHandler(bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure, index)
  }
  Connections {
    target : bloodChemistry.requests.pulmonaryVenousOxygenPressure
    onPointAdded : newPointHandler(bloodChemistry.requests.pulmonaryVenousOxygenPressure, index)
  }
  Connections {
    target : bloodChemistry.requests.venousCarbonDioxidePressure
    onPointAdded : newPointHandler(bloodChemistry.requests.venousCarbonDioxidePressure, index)
  }
  Connections {
    target : bloodChemistry.requests.venousOxygenPressure
    onPointAdded : newPointHandler(bloodChemistry.requests.venousOxygenPressure, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponse
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponse, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseLocalPathogen
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseLocalPathogen, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseLocalMacrophage
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseLocalMacrophage, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseLocalNeutrophil
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseLocalNeutrophil, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseLocalBarrier
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseLocalBarrier, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseBloodPathogen
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseBloodPathogen, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseTrauma
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseTrauma, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseMacrophageResting
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseMacrophageResting, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseMacrophageActive
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseMacrophageActive, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseNeutrophilResting
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseNeutrophilResting, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseNeutrophilActive
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseNeutrophilActive, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseInducibleNOSPre
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseInducibleNOSPre, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseInducibleNOS
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseInducibleNOS, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseConstitutiveNOS
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseConstitutiveNOS, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseNitrate
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseNitrate, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseNitricOxide
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseNitricOxide, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseInterleukin6
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseInterleukin6, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseInterleukin10
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseInterleukin10, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseInterleukin12
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseInterleukin12, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseCatecholamines
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseCatecholamines, index)
  }
  Connections {
    target : bloodChemistry.requests.inflammatoryResponseTissueIntegrity
    onPointAdded : newPointHandler(bloodChemistry.requests.inflammatoryResponseTissueIntegrity, index)
  }
////////////////////////
  Connections {
    target : cardiovascular.requests.arterialPressure
    onPointAdded : newPointHandler(cardiovascular.requests.arterialPressure, index)
  }
  Connections {
    target : cardiovascular.requests.bloodVolume
    onPointAdded : newPointHandler(cardiovascular.requests.bloodVolume, index)
  }
  Connections {
    target : cardiovascular.requests.cardiacIndex
    onPointAdded : newPointHandler(cardiovascular.requests.cardiacIndex, index)
  }
  Connections {
    target : cardiovascular.requests.cardiacOutput
    onPointAdded : newPointHandler(cardiovascular.requests.cardiacOutput, index)
  }
  Connections {
    target : cardiovascular.requests.centralVenousPressure
    onPointAdded : newPointHandler(cardiovascular.requests.centralVenousPressure, index)
  }
  Connections {
    target : cardiovascular.requests.cerebralBloodFlow
    onPointAdded : newPointHandler(cardiovascular.requests.cerebralBloodFlow, index)
  }
  Connections {
    target : cardiovascular.requests.cerebralPerfusionPressure
    onPointAdded : newPointHandler(cardiovascular.requests.cerebralPerfusionPressure, index)
  }
  Connections {
    target : cardiovascular.requests.diastolicArterialPressure
    onPointAdded : newPointHandler(cardiovascular.requests.diastolicArterialPressure, index)
  }
  Connections {
    target : cardiovascular.requests.heartEjectionFraction
    onPointAdded : newPointHandler(cardiovascular.requests.heartEjectionFraction, index)
  }
  Connections {
    target : cardiovascular.requests.heartRate
    onPointAdded : newPointHandler(cardiovascular.requests.heartRate, index)
  }
  Connections {
    target : cardiovascular.requests.heartStrokeVolume
    onPointAdded : newPointHandler(cardiovascular.requests.heartStrokeVolume, index)
  }
  Connections {
    target : cardiovascular.requests.intracranialPressure
    onPointAdded : newPointHandler(cardiovascular.requests.intracranialPressure, index)
  }
  Connections {
    target : cardiovascular.requests.meanArterialPressure
    onPointAdded : newPointHandler(cardiovascular.requests.meanArterialPressure, index)
  }
  Connections {
    target : cardiovascular.requests.meanArterialCarbonDioxidePartialPressure
    onPointAdded : newPointHandler(cardiovascular.requests.meanArterialCarbonDioxidePartialPressure, index)
  }
  Connections {
    target : cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta
    onPointAdded : newPointHandler(cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta, index)
  }
  Connections {
    target : cardiovascular.requests.meanCentralVenousPressure
    onPointAdded : newPointHandler(cardiovascular.requests.meanCentralVenousPressure, index)
  }
  Connections {
    target : cardiovascular.requests.meanSkinFlow
    onPointAdded : newPointHandler(cardiovascular.requests.meanSkinFlow, index)
  }
  Connections {
    target : cardiovascular.requests.pulmonaryArterialPressure
    onPointAdded : newPointHandler(cardiovascular.requests.pulmonaryArterialPressure, index)
  }
  Connections {
    target : cardiovascular.requests.pulmonaryCapillariesWedgePressure
    onPointAdded : newPointHandler(cardiovascular.requests.pulmonaryCapillariesWedgePressure, index)
  }
  Connections {
    target : cardiovascular.requests.pulmonaryDiastolicArterialPressure
    onPointAdded : newPointHandler(cardiovascular.requests.pulmonaryDiastolicArterialPressure, index)
  }
  Connections {
    target : cardiovascular.requests.pulmonaryMeanArterialPressure
    onPointAdded : newPointHandler(cardiovascular.requests.pulmonaryMeanArterialPressure, index)
  }
  Connections {
    target : cardiovascular.requests.pulmonaryMeanCapillaryFlow
    onPointAdded : newPointHandler(cardiovascular.requests.pulmonaryMeanCapillaryFlow, index)
  }
  Connections {
    target : cardiovascular.requests.pulmonaryMeanShuntFlow
    onPointAdded : newPointHandler(cardiovascular.requests.pulmonaryMeanShuntFlow, index)
  }
  Connections {
    target : cardiovascular.requests.pulmonarySystolicArterialPressure
    onPointAdded : newPointHandler(cardiovascular.requests.pulmonarySystolicArterialPressure, index)
  }
  Connections {
    target : cardiovascular.requests.pulmonaryVascularResistance
    onPointAdded : newPointHandler(cardiovascular.requests.pulmonaryVascularResistance, index)
  }
  Connections {
    target : cardiovascular.requests.pulmonaryVascularResistanceIndex
    onPointAdded : newPointHandler(cardiovascular.requests.pulmonaryVascularResistanceIndex, index)
  }
  Connections {
    target : cardiovascular.requests.pulsePressure
    onPointAdded : newPointHandler(cardiovascular.requests.pulsePressure, index)
  }
  Connections {
    target : cardiovascular.requests.systemicVascularResistance
    onPointAdded : newPointHandler(cardiovascular.requests.systemicVascularResistance, index)
  }
  Connections {
    target : cardiovascular.requests.systolicArterialPressure
    onPointAdded : newPointHandler(cardiovascular.requests.systolicArterialPressure, index)
  }
///////////////////////
  Connections {
    target : drugs.requests.bronchodilationLevel
    onPointAdded : newPointHandler(drugs.requests.bronchodilationLevel, index)
  }
  Connections {
    target : drugs.requests.heartRateChange
    onPointAdded : newPointHandler(drugs.requests.heartRateChange, index)
  }
  Connections {
    target : drugs.requests.hemorrhageChange
    onPointAdded : newPointHandler(drugs.requests.hemorrhageChange, index)
  }
  Connections {
    target : drugs.requests.meanBloodPressureChange
    onPointAdded : newPointHandler(drugs.requests.meanBloodPressureChange, index)
  }
  Connections {
    target : drugs.requests.neuromuscularBlockLevel
    onPointAdded : newPointHandler(drugs.requests.neuromuscularBlockLevel, index)
  }
  Connections {
    target : drugs.requests.pulsePressureChange
    onPointAdded : newPointHandler(drugs.requests.pulsePressureChange, index)
  }
  Connections {
    target : drugs.requests.respirationRateChange
    onPointAdded : newPointHandler(drugs.requests.respirationRateChange, index)
  }
  Connections {
    target : drugs.requests.sedationLevel
    onPointAdded : newPointHandler(drugs.requests.sedationLevel, index)
  }
  Connections {
    target : drugs.requests.tidalVolumeChange
    onPointAdded : newPointHandler(drugs.requests.tidalVolumeChange, index)
  }
  Connections {
    target : drugs.requests.tubularPermeabilityChange
    onPointAdded : newPointHandler(drugs.requests.tubularPermeabilityChange, index)
  }
  Connections {
    target : drugs.requests.centralNervousResponse
    onPointAdded : newPointHandler(drugs.requests.centralNervousResponse, index)
  }
///////////////////////
  Connections {
    target : endocrine.requests.insulinSynthesisRate
    onPointAdded : newPointHandler(endocrine.requests.insulinSynthesisRate, index)
  }
  Connections {
    target : endocrine.requests.glucagonSynthesisRate
    onPointAdded : newPointHandler(endocrine.requests.glucagonSynthesisRate, index)
  }
///////////////////////
  Connections {
    target : energy.requests.achievedExerciseLevel
    onPointAdded : newPointHandler(energy.requests.achievedExerciseLevel, index)
  }
  Connections {
    target : energy.requests.chlorideLostToSweat
    onPointAdded : newPointHandler(energy.requests.chlorideLostToSweat, index)
  }
  Connections {
    target : energy.requests.coreTemperature
    onPointAdded : newPointHandler(energy.requests.coreTemperature, index)
  }
  Connections {
    target : energy.requests.creatinineProductionRate
    onPointAdded : newPointHandler(energy.requests.creatinineProductionRate, index)
  }
  Connections {
    target : energy.requests.exerciseMeanArterialPressureDelta
    onPointAdded : newPointHandler(energy.requests.exerciseMeanArterialPressureDelta, index)
  }
  Connections {
    target : energy.requests.fatigueLevel
    onPointAdded : newPointHandler(energy.requests.fatigueLevel, index)
  }
  Connections {
    target : energy.requests.lactateProductionRate
    onPointAdded : newPointHandler(energy.requests.lactateProductionRate, index)
  }
  Connections {
    target : energy.requests.potassiumLostToSweat
    onPointAdded : newPointHandler(energy.requests.potassiumLostToSweat, index)
  }
  Connections {
    target : energy.requests.skinTemperature
    onPointAdded : newPointHandler(energy.requests.skinTemperature, index)
  }
  Connections {
    target : energy.requests.sodiumLostToSweat
    onPointAdded : newPointHandler(energy.requests.sodiumLostToSweat, index)
  }
  Connections {
    target : energy.requests.sweatRate
    onPointAdded : newPointHandler(energy.requests.sweatRate, index)
  }
  Connections {
    target : energy.requests.totalMetabolicRate
    onPointAdded : newPointHandler(energy.requests.totalMetabolicRate, index)
  }
  Connections {
    target : energy.requests.totalWorkRateLevel
    onPointAdded : newPointHandler(energy.requests.totalWorkRateLevel, index)
  }
///////////////////////
  Connections {
    target : gastrointestinal.requests.chymeAbsorptionRate
    onPointAdded : newPointHandler(gastrointestinal.requests.chymeAbsorptionRate, index)
  }
  Connections {
    target : gastrointestinal.requests.stomachContents_calcium
    onPointAdded : newPointHandler(gastrointestinal.requests.stomachContents_calcium, index)
  }
  Connections {
    target : gastrointestinal.requests.stomachContents_carbohydrates
    onPointAdded : newPointHandler(gastrointestinal.requests.stomachContents_carbohydrates, index)
  }
  Connections {
    target : gastrointestinal.requests.stomachContents_carbohydrateDigationRate
    onPointAdded : newPointHandler(gastrointestinal.requests.stomachContents_carbohydrateDigationRate, index)
  }
  Connections {
    target : gastrointestinal.requests.stomachContents_fat
    onPointAdded : newPointHandler(gastrointestinal.requests.stomachContents_fat, index)
  }
  Connections {
    target : gastrointestinal.requests.stomachContents_fatDigtationRate
    onPointAdded : newPointHandler(gastrointestinal.requests.stomachContents_fatDigtationRate, index)
  }
  Connections {
    target : gastrointestinal.requests.stomachContents_protien
    onPointAdded : newPointHandler(gastrointestinal.requests.stomachContents_protien, index)
  }
  Connections {
    target : gastrointestinal.requests.stomachContents_protienDigtationRate
    onPointAdded : newPointHandler(gastrointestinal.requests.stomachContents_protienDigtationRate, index)
  }
  Connections {
    target : gastrointestinal.requests.stomachContents_sodium
    onPointAdded : newPointHandler(gastrointestinal.requests.stomachContents_sodium, index)
  }
  Connections {
    target : gastrointestinal.requests.stomachContents_water
    onPointAdded : newPointHandler(gastrointestinal.requests.stomachContents_water, index)
  }
///////////////////////
  Connections {
    target : hepatic.requests.ketoneproductionRate
    onPointAdded : newPointHandler(hepatic.requests.ketoneproductionRate, index)
  }
  Connections {
    target : hepatic.requests.hepaticGluconeogenesisRate
    onPointAdded : newPointHandler(hepatic.requests.hepaticGluconeogenesisRate, index)
  }
///////////////////////
  Connections {
    target : nervous.requests.baroreceptorHeartRateScale
    onPointAdded : newPointHandler(nervous.requests.baroreceptorHeartRateScale, index)
  }
  Connections {
    target : nervous.requests.baroreceptorHeartElastanceScale
    onPointAdded : newPointHandler(nervous.requests.baroreceptorHeartElastanceScale, index)
  }
  Connections {
    target : nervous.requests.baroreceptorResistanceScale
    onPointAdded : newPointHandler(nervous.requests.baroreceptorResistanceScale, index)
  }
  Connections {
    target : nervous.requests.baroreceptorComplianceScale
    onPointAdded : newPointHandler(nervous.requests.baroreceptorComplianceScale, index)
  }
  Connections {
    target : nervous.requests.chemoreceptorHeartRateScale
    onPointAdded : newPointHandler(nervous.requests.chemoreceptorHeartRateScale, index)
  }
  Connections {
    target : nervous.requests.chemoreceptorHeartElastanceScale
    onPointAdded : newPointHandler(nervous.requests.chemoreceptorHeartElastanceScale, index)
  }
  Connections {
    target : nervous.requests.painVisualAnalogueScale
    onPointAdded : newPointHandler(nervous.requests.painVisualAnalogueScale, index)
  }
  Connections {
    target : nervous.requests.leftEyePupillaryResponse
    onPointAdded : newPointHandler(nervous.requests.leftEyePupillaryResponse, index)
  }
  Connections {
    target : nervous.requests.rightEyePupillaryResponse
    onPointAdded : newPointHandler(nervous.requests.rightEyePupillaryResponse, index)
  }
///////////////////////
  Connections {
    target : renal.requests.glomerularFiltrationRate
    onPointAdded : newPointHandler(renal.requests.glomerularFiltrationRate, index)
  }
  Connections {
    target : renal.requests.filtrationFraction
    onPointAdded : newPointHandler(renal.requests.filtrationFraction, index)
  }
  Connections {
    target : renal.requests.leftAfferentArterioleResistance
    onPointAdded : newPointHandler(renal.requests.leftAfferentArterioleResistance, index)
  }
  Connections {
    target : renal.requests.leftBowmansCapsulesHydrostaticPressure
    onPointAdded : newPointHandler(renal.requests.leftBowmansCapsulesHydrostaticPressure, index)
  }
  Connections {
    target : renal.requests.leftBowmansCapsulesOsmoticPressure
    onPointAdded : newPointHandler(renal.requests.leftBowmansCapsulesOsmoticPressure, index)
  }
  Connections {
    target : renal.requests.leftEfferentArterioleResistance
    onPointAdded : newPointHandler(renal.requests.leftEfferentArterioleResistance, index)
  }
  Connections {
    target : renal.requests.leftGlomerularCapillariesHydrostaticPressure
    onPointAdded : newPointHandler(renal.requests.leftGlomerularCapillariesHydrostaticPressure, index)
  }
  Connections {
    target : renal.requests.leftGlomerularCapillariesOsmoticPressure
    onPointAdded : newPointHandler(renal.requests.leftGlomerularCapillariesOsmoticPressure, index)
  }
  Connections {
    target : renal.requests.leftGlomerularFiltrationCoefficient
    onPointAdded : newPointHandler(renal.requests.leftGlomerularFiltrationCoefficient, index)
  }
  Connections {
    target : renal.requests.leftGlomerularFiltrationRate
    onPointAdded : newPointHandler(renal.requests.leftGlomerularFiltrationRate, index)
  }
  Connections {
    target : renal.requests.leftGlomerularFiltrationSurfaceArea
    onPointAdded : newPointHandler(renal.requests.leftGlomerularFiltrationSurfaceArea, index)
  }
  Connections {
    target : renal.requests.leftGlomerularFluidPermeability
    onPointAdded : newPointHandler(renal.requests.leftGlomerularFluidPermeability, index)
  }
  Connections {
    target : renal.requests.leftFiltrationFraction
    onPointAdded : newPointHandler(renal.requests.leftFiltrationFraction, index)
  }
  Connections {
    target : renal.requests.leftNetFiltrationPressure
    onPointAdded : newPointHandler(renal.requests.leftNetFiltrationPressure, index)
  }
  Connections {
    target : renal.requests.leftNetReabsorptionPressure
    onPointAdded : newPointHandler(renal.requests.leftNetReabsorptionPressure, index)
  }
  Connections {
    target : renal.requests.leftPeritubularCapillariesHydrostaticPressure
    onPointAdded : newPointHandler(renal.requests.leftPeritubularCapillariesHydrostaticPressure, index)
  }
  Connections {
    target : renal.requests.leftPeritubularCapillariesOsmoticPressure
    onPointAdded : newPointHandler(renal.requests.leftPeritubularCapillariesOsmoticPressure, index)
  }
  Connections {
    target : renal.requests.leftReabsorptionFiltrationCoefficient
    onPointAdded : newPointHandler(renal.requests.leftReabsorptionFiltrationCoefficient, index)
  }
  Connections {
    target : renal.requests.leftReabsorptionRate
    onPointAdded : newPointHandler(renal.requests.leftReabsorptionRate, index)
  }
  Connections {
    target : renal.requests.leftTubularReabsorptionFiltrationSurfaceArea
    onPointAdded : newPointHandler(renal.requests.leftTubularReabsorptionFiltrationSurfaceArea, index)
  }
  Connections {
    target : renal.requests.leftTubularReabsorptionFluidPermeability
    onPointAdded : newPointHandler(renal.requests.leftTubularReabsorptionFluidPermeability, index)
  }
  Connections {
    target : renal.requests.leftTubularHydrostaticPressure
    onPointAdded : newPointHandler(renal.requests.leftTubularHydrostaticPressure, index)
  }
  Connections {
    target : renal.requests.leftTubularOsmoticPressure
    onPointAdded : newPointHandler(renal.requests.leftTubularOsmoticPressure, index)
  }
  Connections {
    target : renal.requests.renalBloodFlow
    onPointAdded : newPointHandler(renal.requests.renalBloodFlow, index)
  }
  Connections {
    target : renal.requests.renalPlasmaFlow
    onPointAdded : newPointHandler(renal.requests.renalPlasmaFlow, index)
  }
  Connections {
    target : renal.requests.renalVascularResistance
    onPointAdded : newPointHandler(renal.requests.renalVascularResistance, index)
  }
  Connections {
    target : renal.requests.rightAfferentArterioleResistance
    onPointAdded : newPointHandler(renal.requests.rightAfferentArterioleResistance, index)
  }
  Connections {
    target : renal.requests.rightBowmansCapsulesHydrostaticPressure
    onPointAdded : newPointHandler(renal.requests.rightBowmansCapsulesHydrostaticPressure, index)
  }
  Connections {
    target : renal.requests.rightBowmansCapsulesOsmoticPressure
    onPointAdded : newPointHandler(renal.requests.rightBowmansCapsulesOsmoticPressure, index)
  }
  Connections {
    target : renal.requests.rightEfferentArterioleResistance
    onPointAdded : newPointHandler(renal.requests.rightEfferentArterioleResistance, index)
  }
  Connections {
    target : renal.requests.rightGlomerularCapillariesHydrostaticPressure
    onPointAdded : newPointHandler(renal.requests.rightGlomerularCapillariesHydrostaticPressure, index)
  }
  Connections {
    target : renal.requests.rightGlomerularCapillariesOsmoticPressure
    onPointAdded : newPointHandler(renal.requests.rightGlomerularCapillariesOsmoticPressure, index)
  }
  Connections {
    target : renal.requests.rightGlomerularFiltrationCoefficient
    onPointAdded : newPointHandler(renal.requests.rightGlomerularFiltrationCoefficient, index)
  }
  Connections {
    target : renal.requests.rightGlomerularFiltrationRate
    onPointAdded : newPointHandler(renal.requests.rightGlomerularFiltrationRate, index)
  }
  Connections {
    target : renal.requests.rightGlomerularFiltrationSurfaceArea
    onPointAdded : newPointHandler(renal.requests.rightGlomerularFiltrationSurfaceArea, index)
  }
  Connections {
    target : renal.requests.rightGlomerularFluidPermeability
    onPointAdded : newPointHandler(renal.requests.rightGlomerularFluidPermeability, index)
  }
  Connections {
    target : renal.requests.rightFiltrationFraction
    onPointAdded : newPointHandler(renal.requests.rightFiltrationFraction, index)
  }
  Connections {
    target : renal.requests.rightNetFiltrationPressure
    onPointAdded : newPointHandler(renal.requests.rightNetFiltrationPressure, index)
  }
  Connections {
    target : renal.requests.rightNetReabsorptionPressure
    onPointAdded : newPointHandler(renal.requests.rightNetReabsorptionPressure, index)
  }
  Connections {
    target : renal.requests.rightPeritubularCapillariesHydrostaticPressure
    onPointAdded : newPointHandler(renal.requests.rightPeritubularCapillariesHydrostaticPressure, index)
  }
  Connections {
    target : renal.requests.rightPeritubularCapillariesOsmoticPressure
    onPointAdded : newPointHandler(renal.requests.rightPeritubularCapillariesOsmoticPressure, index)
  }
  Connections {
    target : renal.requests.rightReabsorptionFiltrationCoefficient
    onPointAdded : newPointHandler(renal.requests.rightReabsorptionFiltrationCoefficient, index)
  }
  Connections {
    target : renal.requests.rightReabsorptionRate
    onPointAdded : newPointHandler(renal.requests.rightReabsorptionRate, index)
  }
  Connections {
    target : renal.requests.rightTubularReabsorptionFiltrationSurfaceArea
    onPointAdded : newPointHandler(renal.requests.rightTubularReabsorptionFiltrationSurfaceArea, index)
  }
  Connections {
    target : renal.requests.rightTubularReabsorptionFluidPermeability
    onPointAdded : newPointHandler(renal.requests.rightTubularReabsorptionFluidPermeability, index)
  }
  Connections {
    target : renal.requests.rightTubularHydrostaticPressure
    onPointAdded : newPointHandler(renal.requests.rightTubularHydrostaticPressure, index)
  }
  Connections {
    target : renal.requests.rightTubularOsmoticPressure
    onPointAdded : newPointHandler(renal.requests.rightTubularOsmoticPressure, index)
  }
  Connections {
    target : renal.requests.urinationRate
    onPointAdded : newPointHandler(renal.requests.urinationRate, index)
  }
  Connections {
    target : renal.requests.urineOsmolality
    onPointAdded : newPointHandler(renal.requests.urineOsmolality, index)
  }
  Connections {
    target : renal.requests.urineOsmolarity
    onPointAdded : newPointHandler(renal.requests.urineOsmolarity, index)
  }
  Connections {
    target : renal.requests.urineProductionRate
    onPointAdded : newPointHandler(renal.requests.urineProductionRate, index)
  }
  Connections {
    target : renal.requests.meanUrineOutput
    onPointAdded : newPointHandler(renal.requests.meanUrineOutput, index)
  }
  Connections {
    target : renal.requests.urineSpecificGravity
    onPointAdded : newPointHandler(renal.requests.urineSpecificGravity, index)
  }
  Connections {
    target : renal.requests.urineVolume
    onPointAdded : newPointHandler(renal.requests.urineVolume, index)
  }
  Connections {
    target : renal.requests.urineUreaNitrogenConcentration
    onPointAdded : newPointHandler(renal.requests.urineUreaNitrogenConcentration, index)
  }
///////////////////////
  Connections {
    target : respiratory.requests.alveolarArterialGradient
    onPointAdded : newPointHandler(respiratory.requests.alveolarArterialGradient, index)
  }
  Connections {
    target : respiratory.requests.carricoIndex
    onPointAdded : newPointHandler(respiratory.requests.carricoIndex, index)
  }
  Connections {
    target : respiratory.requests.endTidalCarbonDioxideFraction
    onPointAdded : newPointHandler(respiratory.requests.endTidalCarbonDioxideFraction, index)
  }
  Connections {
    target : respiratory.requests.endTidalCarbonDioxidePressure
    onPointAdded : newPointHandler(respiratory.requests.endTidalCarbonDioxidePressure, index)
  }
  Connections {
    target : respiratory.requests.expiratoryFlow
    onPointAdded : newPointHandler(respiratory.requests.expiratoryFlow, index)
  }
  Connections {
    target : respiratory.requests.inspiratoryExpiratoryRatio
    onPointAdded : newPointHandler(respiratory.requests.inspiratoryExpiratoryRatio, index)
  }
  Connections {
    target : respiratory.requests.inspiratoryFlow
    onPointAdded : newPointHandler(respiratory.requests.inspiratoryFlow, index)
  }
  Connections {
    target : respiratory.requests.pulmonaryCompliance
    onPointAdded : newPointHandler(respiratory.requests.pulmonaryCompliance, index)
  }
  Connections {
    target : respiratory.requests.pulmonaryResistance
    onPointAdded : newPointHandler(respiratory.requests.pulmonaryResistance, index)
  }
  Connections {
    target : respiratory.requests.respirationDriverPressure
    onPointAdded : newPointHandler(respiratory.requests.respirationDriverPressure, index)
  }
  Connections {
    target : respiratory.requests.respirationMusclePressure
    onPointAdded : newPointHandler(respiratory.requests.respirationMusclePressure, index)
  }
  Connections {
    target : respiratory.requests.respirationRate
    onPointAdded : newPointHandler(respiratory.requests.respirationRate, index)
  }
  Connections {
    target : respiratory.requests.specificVentilation
    onPointAdded : newPointHandler(respiratory.requests.specificVentilation, index)
  }
  Connections {
    target : respiratory.requests.targetPulmonaryVentilation
    onPointAdded : newPointHandler(respiratory.requests.targetPulmonaryVentilation, index)
  }
  Connections {
    target : respiratory.requests.tidalVolume
    onPointAdded : newPointHandler(respiratory.requests.tidalVolume, index)
  }
  Connections {
    target : respiratory.requests.totalAlveolarVentilation
    onPointAdded : newPointHandler(respiratory.requests.totalAlveolarVentilation, index)
  }
  Connections {
    target : respiratory.requests.totalDeadSpaceVentilation
    onPointAdded : newPointHandler(respiratory.requests.totalDeadSpaceVentilation, index)
  }
  Connections {
    target : respiratory.requests.totalLungVolume
    onPointAdded : newPointHandler(respiratory.requests.totalLungVolume, index)
  }
  Connections {
    target : respiratory.requests.totalPulmonaryVentilation
    onPointAdded : newPointHandler(respiratory.requests.totalPulmonaryVentilation, index)
  }
  Connections {
    target : respiratory.requests.transpulmonaryPressure
    onPointAdded : newPointHandler(respiratory.requests.transpulmonaryPressure, index)
  }
///////////////////////
  Connections {
    target : tissue.requests.carbonDioxideProductionRate
    onPointAdded : newPointHandler(tissue.requests.carbonDioxideProductionRate, index)
  }
  Connections {
    target : tissue.requests.dehydrationFraction
    onPointAdded : newPointHandler(tissue.requests.dehydrationFraction, index)
  }
  Connections {
    target : tissue.requests.extracellularFluidVolume
    onPointAdded : newPointHandler(tissue.requests.extracellularFluidVolume, index)
  }
  Connections {
    target : tissue.requests.extravascularFluidVolume
    onPointAdded : newPointHandler(tissue.requests.extravascularFluidVolume, index)
  }
  Connections {
    target : tissue.requests.intracellularFluidPH
    onPointAdded : newPointHandler(tissue.requests.intracellularFluidPH, index)
  }
  Connections {
    target : tissue.requests.intracellularFluidVolume
    onPointAdded : newPointHandler(tissue.requests.intracellularFluidVolume, index)
  }
  Connections {
    target : tissue.requests.totalBodyFluidVolume
    onPointAdded : newPointHandler(tissue.requests.totalBodyFluidVolume, index)
  }
  Connections {
    target : tissue.requests.oxygenConsumptionRate
    onPointAdded : newPointHandler(tissue.requests.oxygenConsumptionRate, index)
  }
  Connections {
    target : tissue.requests.respiratoryExchangeRatio
    onPointAdded : newPointHandler(tissue.requests.respiratoryExchangeRatio, index)
  }
  Connections {
    target : tissue.requests.liverInsulinSetPoint
    onPointAdded : newPointHandler(tissue.requests.liverInsulinSetPoint, index)
  }
  Connections {
    target : tissue.requests.liverGlucagonSetPoint
    onPointAdded : newPointHandler(tissue.requests.liverGlucagonSetPoint, index)
  }
  Connections {
    target : tissue.requests.muscleInsulinSetPoint
    onPointAdded : newPointHandler(tissue.requests.muscleInsulinSetPoint, index)
  }
  Connections {
    target : tissue.requests.muscleGlucagonSetPoint
    onPointAdded : newPointHandler(tissue.requests.muscleGlucagonSetPoint, index)
  }
  Connections {
    target : tissue.requests.fatInsulinSetPoint
    onPointAdded : newPointHandler(tissue.requests.fatInsulinSetPoint, index)
  }
  Connections {
    target : tissue.requests.fatGlucagonSetPoint
    onPointAdded : newPointHandler(tissue.requests.fatGlucagonSetPoint, index)
  }
  Connections {
    target : tissue.requests.liverGlycogen
    onPointAdded : newPointHandler(tissue.requests.liverGlycogen, index)
  }
  Connections {
    target : tissue.requests.muscleGlycogen
    onPointAdded : newPointHandler(tissue.requests.muscleGlycogen, index)
  }
  Connections {
    target : tissue.requests.storedProtein
    onPointAdded : newPointHandler(tissue.requests.storedProtein, index)
  }
  Connections {
    target : tissue.requests.storedFat
    onPointAdded : newPointHandler(tissue.requests.storedFat, index)
  }
  //!
  //!  Update Function
  //!  Calls Append for each Blood Chemistry Data Request
  function updateBloodChemistry( metrics ) {
    // console.log("Updating BloodChemistry")
    updateDomain(bloodChemistry.axisX)
    bloodChemistry.requests.arterialBloodPH.append(metrics.simulationTime,metrics.arterialBloodPH)
    bloodChemistry.requests.arterialBloodPHBaseline.append(metrics.simulationTime,metrics.arterialBloodPHBaseline)
    bloodChemistry.requests.bloodDensity.append(metrics.simulationTime,metrics.bloodDensity)
    bloodChemistry.requests.bloodSpecificHeat.append(metrics.simulationTime,metrics.bloodSpecificHeat)
    bloodChemistry.requests.bloodUreaNitrogenConcentration.append(metrics.simulationTime,metrics.bloodUreaNitrogenConcentration)
    bloodChemistry.requests.carbonDioxideSaturation.append(metrics.simulationTime,metrics.carbonDioxideSaturation)
    bloodChemistry.requests.carbonMonoxideSaturation.append(metrics.simulationTime,metrics.carbonMonoxideSaturation)
    bloodChemistry.requests.hematocrit.append(metrics.simulationTime,metrics.hematocrit)
    bloodChemistry.requests.hemoglobinContent.append(metrics.simulationTime,metrics.hemoglobinContent)
    bloodChemistry.requests.oxygenSaturation.append(metrics.simulationTime,metrics.oxygenSaturation)
    bloodChemistry.requests.phosphate.append(metrics.simulationTime,metrics.phosphate)
    bloodChemistry.requests.plasmaVolume.append(metrics.simulationTime,metrics.plasmaVolume)
    bloodChemistry.requests.pulseOximetry.append(metrics.simulationTime,metrics.pulseOximetry)
    bloodChemistry.requests.redBloodCellAcetylcholinesterase.append(metrics.simulationTime,metrics.redBloodCellAcetylcholinesterase)
    bloodChemistry.requests.redBloodCellCount.append(metrics.simulationTime,metrics.redBloodCellCount)
    bloodChemistry.requests.shuntFraction.append(metrics.simulationTime,metrics.shuntFraction)
    bloodChemistry.requests.strongIonDifference.append(metrics.simulationTime,metrics.strongIonDifference)
    bloodChemistry.requests.totalBilirubin.append(metrics.simulationTime,metrics.totalBilirubin)
    bloodChemistry.requests.totalProteinConcentration.append(metrics.simulationTime,metrics.totalProteinConcentration)
    bloodChemistry.requests.venousBloodPH.append(metrics.simulationTime,metrics.venousBloodPH)
    bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.append(metrics.simulationTime,metrics.volumeFractionNeutralPhospholipidInPlasma)
    bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.append(metrics.simulationTime,metrics.volumeFractionNeutralLipidInPlasma)
    bloodChemistry.requests.arterialCarbonDioxidePressure.append(metrics.simulationTime,metrics.arterialCarbonDioxidePressure)
    bloodChemistry.requests.arterialOxygenPressure.append(metrics.simulationTime,metrics.arterialOxygenPressure)
    bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.append(metrics.simulationTime,metrics.pulmonaryArterialCarbonDioxidePressure)
    bloodChemistry.requests.pulmonaryArterialOxygenPressure.append(metrics.simulationTime,metrics.pulmonaryArterialOxygenPressure)
    bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.append(metrics.simulationTime,metrics.pulmonaryVenousCarbonDioxidePressure)
    bloodChemistry.requests.pulmonaryVenousOxygenPressure.append(metrics.simulationTime,metrics.pulmonaryVenousOxygenPressure)
    bloodChemistry.requests.venousCarbonDioxidePressure.append(metrics.simulationTime,metrics.venousCarbonDioxidePressure)
    bloodChemistry.requests.venousOxygenPressure.append(metrics.simulationTime,metrics.venousOxygenPressure)
    bloodChemistry.requests.inflammatoryResponse.append(metrics.simulationTime,metrics.inflammatoryResponse)
    bloodChemistry.requests.inflammatoryResponseLocalPathogen.append(metrics.simulationTime,metrics.inflammatoryResponseLocalPathogen)
    bloodChemistry.requests.inflammatoryResponseLocalMacrophage.append(metrics.simulationTime,metrics.inflammatoryResponseLocalMacrophage)
    bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.append(metrics.simulationTime,metrics.inflammatoryResponseLocalNeutrophil)
    bloodChemistry.requests.inflammatoryResponseLocalBarrier.append(metrics.simulationTime,metrics.inflammatoryResponseLocalBarrier)
    bloodChemistry.requests.inflammatoryResponseBloodPathogen.append(metrics.simulationTime,metrics.inflammatoryResponseBloodPathogen)
    bloodChemistry.requests.inflammatoryResponseTrauma.append(metrics.simulationTime,metrics.inflammatoryResponseTrauma)
    bloodChemistry.requests.inflammatoryResponseMacrophageResting.append(metrics.simulationTime,metrics.inflammatoryResponseMacrophageResting)
    bloodChemistry.requests.inflammatoryResponseMacrophageActive.append(metrics.simulationTime,metrics.inflammatoryResponseMacrophageActive)
    bloodChemistry.requests.inflammatoryResponseNeutrophilResting.append(metrics.simulationTime,metrics.inflammatoryResponseNeutrophilResting)
    bloodChemistry.requests.inflammatoryResponseNeutrophilActive.append(metrics.simulationTime,metrics.inflammatoryResponseNeutrophilActive)
    bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.append(metrics.simulationTime,metrics.inflammatoryResponseInducibleNOSPre)
    bloodChemistry.requests.inflammatoryResponseInducibleNOS.append(metrics.simulationTime,metrics.inflammatoryResponseInducibleNOS)
    bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.append(metrics.simulationTime,metrics.inflammatoryResponseConstitutiveNOS)
    bloodChemistry.requests.inflammatoryResponseNitrate.append(metrics.simulationTime,metrics.inflammatoryResponseNitrate)
    bloodChemistry.requests.inflammatoryResponseNitricOxide.append(metrics.simulationTime,metrics.inflammatoryResponseNitricOxide)
    bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.append(metrics.simulationTime,metrics.inflammatoryResponseTumorNecrosisFactor)
    bloodChemistry.requests.inflammatoryResponseInterleukin6.append(metrics.simulationTime,metrics.inflammatoryResponseInterleukin6)
    bloodChemistry.requests.inflammatoryResponseInterleukin10.append(metrics.simulationTime,metrics.inflammatoryResponseInterleukin10)
    bloodChemistry.requests.inflammatoryResponseInterleukin12.append(metrics.simulationTime,metrics.inflammatoryResponseInterleukin12)
    bloodChemistry.requests.inflammatoryResponseCatecholamines.append(metrics.simulationTime,metrics.inflammatoryResponseCatecholamines)
    bloodChemistry.requests.inflammatoryResponseTissueIntegrity.append(metrics.simulationTime,metrics.inflammatoryResponseTissueIntegrity)
  }
  function updateCardiovascular(metrics){
    // console.log("Updating Cardiovascular")
    updateDomain(cardiovascular.axisX)
    cardiovascular.requests.arterialPressure.append(metrics.simulationTime,metrics.arterialPressure)
    cardiovascular.requests.bloodVolume.append(metrics.simulationTime,metrics.bloodVolume)
    cardiovascular.requests.cardiacIndex.append(metrics.simulationTime,metrics.cardiacIndex)
    cardiovascular.requests.cardiacOutput.append(metrics.simulationTime,metrics.cardiacOutput)
    cardiovascular.requests.centralVenousPressure.append(metrics.simulationTime,metrics.centralVenousPressure)
    cardiovascular.requests.cerebralBloodFlow.append(metrics.simulationTime,metrics.cerebralBloodFlow)
    cardiovascular.requests.cerebralPerfusionPressure.append(metrics.simulationTime,metrics.cerebralPerfusionPressure)
    cardiovascular.requests.diastolicArterialPressure.append(metrics.simulationTime,metrics.diastolicArterialPressure)
    cardiovascular.requests.heartEjectionFraction.append(metrics.simulationTime,metrics.heartEjectionFraction)
    cardiovascular.requests.heartRate.append(metrics.simulationTime,metrics.heartRate)
    cardiovascular.requests.heartStrokeVolume.append(metrics.simulationTime,metrics.heartStrokeVolume)
    cardiovascular.requests.intracranialPressure.append(metrics.simulationTime,metrics.intracranialPressure)
    cardiovascular.requests.meanArterialPressure.append(metrics.simulationTime,metrics.meanArterialPressure)
    cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.append(metrics.simulationTime,metrics.meanArterialCarbonDioxidePartialPressure)
    cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.append(metrics.simulationTime,metrics.meanArterialCarbonDioxidePartialPressureDelta)
    cardiovascular.requests.meanCentralVenousPressure.append(metrics.simulationTime,metrics.meanCentralVenousPressure)
    cardiovascular.requests.meanSkinFlow.append(metrics.simulationTime,metrics.meanSkinFlow)
    cardiovascular.requests.pulmonaryArterialPressure.append(metrics.simulationTime,metrics.pulmonaryArterialPressure)
    cardiovascular.requests.pulmonaryCapillariesWedgePressure.append(metrics.simulationTime,metrics.pulmonaryCapillariesWedgePressure)
    cardiovascular.requests.pulmonaryDiastolicArterialPressure.append(metrics.simulationTime,metrics.pulmonaryDiastolicArterialPressure)
    cardiovascular.requests.pulmonaryMeanArterialPressure.append(metrics.simulationTime,metrics.pulmonaryMeanArterialPressure)
    cardiovascular.requests.pulmonaryMeanCapillaryFlow.append(metrics.simulationTime,metrics.pulmonaryMeanCapillaryFlow)
    cardiovascular.requests.pulmonaryMeanShuntFlow.append(metrics.simulationTime,metrics.pulmonaryMeanShuntFlow)
    cardiovascular.requests.pulmonarySystolicArterialPressure.append(metrics.simulationTime,metrics.pulmonarySystolicArterialPressure)
    cardiovascular.requests.pulmonaryVascularResistance.append(metrics.simulationTime,metrics.pulmonaryVascularResistance)
    cardiovascular.requests.pulmonaryVascularResistanceIndex.append(metrics.simulationTime,metrics.pulmonaryVascularResistanceIndex)
    cardiovascular.requests.pulsePressure.append(metrics.simulationTime,metrics.pulsePressure)
    cardiovascular.requests.systemicVascularResistance.append(metrics.simulationTime,metrics.systemicVascularResistance)
    cardiovascular.requests.systolicArterialPressure.append(metrics.simulationTime,metrics.systolicArterialPressure)
  }
  function updateDrugs(metrics){
    // console.log("Updating Drugs")
    updateDomain(drugs.axisX)
    drugs.requests.bronchodilationLevel.append(metrics.simulationTime,metrics.bronchodilationLevel)
    drugs.requests.heartRateChange.append(metrics.simulationTime,metrics.heartRateChange)
    drugs.requests.hemorrhageChange.append(metrics.simulationTime,metrics.hemorrhageChange)
    drugs.requests.meanBloodPressureChange.append(metrics.simulationTime,metrics.meanBloodPressureChange)
    drugs.requests.neuromuscularBlockLevel.append(metrics.simulationTime,metrics.neuromuscularBlockLevel)
    drugs.requests.pulsePressureChange.append(metrics.simulationTime,metrics.pulsePressureChange)
    drugs.requests.respirationRateChange.append(metrics.simulationTime,metrics.respirationRateChange)
    drugs.requests.sedationLevel.append(metrics.simulationTime,metrics.sedationLevel)
    drugs.requests.tidalVolumeChange.append(metrics.simulationTime,metrics.tidalVolumeChange)
    drugs.requests.tubularPermeabilityChange.append(metrics.simulationTime,metrics.tubularPermeabilityChange)
    drugs.requests.centralNervousResponse.append(metrics.simulationTime,metrics.centralNervousResponse)
  }
  function updateEndocrine(metrics){
    // console.log("Updating Endocrine")
    updateDomain(endocrine.axisX)
    endocrine.requests.insulinSynthesisRate.append(metrics.simulationTime,metrics.insulinSynthesisRate)
    endocrine.requests.glucagonSynthesisRate.append(metrics.simulationTime,metrics.glucagonSynthesisRate)
  }
  function updateEnergy(metrics){
    // console.log("Updating Energy")
    updateDomain(energy.axisX)
    energy.requests.achievedExerciseLevel.append(metrics.simulationTime,metrics.achievedExerciseLevel)
    energy.requests.chlorideLostToSweat.append(metrics.simulationTime,metrics.chlorideLostToSweat)
    energy.requests.coreTemperature.append(metrics.simulationTime,metrics.coreTemperature)
    energy.requests.creatinineProductionRate.append(metrics.simulationTime,metrics.creatinineProductionRate)
    energy.requests.exerciseMeanArterialPressureDelta.append(metrics.simulationTime,metrics.exerciseMeanArterialPressureDelta)
    energy.requests.fatigueLevel.append(metrics.simulationTime,metrics.fatigueLevel)
    energy.requests.lactateProductionRate.append(metrics.simulationTime,metrics.lactateProductionRate)
    energy.requests.potassiumLostToSweat.append(metrics.simulationTime,metrics.potassiumLostToSweat)
    energy.requests.skinTemperature.append(metrics.simulationTime,metrics.skinTemperature)
    energy.requests.sodiumLostToSweat.append(metrics.simulationTime,metrics.sodiumLostToSweat)
    energy.requests.sweatRate.append(metrics.simulationTime,metrics.sweatRate)
    energy.requests.totalMetabolicRate.append(metrics.simulationTime,metrics.totalMetabolicRate)
    energy.requests.totalWorkRateLevel.append(metrics.simulationTime,metrics.totalWorkRateLevel)
  }
  function updateGastrointestinal(metrics){
    // console.log("Updating Gastrointestinal")
    updateDomain(gastrointestinal.axisX)
    // console.log("Updating chymeAbsorptionRate")
    gastrointestinal.requests.chymeAbsorptionRate.append(metrics.simulationTime,metrics.chymeAbsorptionRate)
    // console.log("Updating stomachContents_calcium")
    gastrointestinal.requests.stomachContents_calcium.append(metrics.simulationTime,metrics.stomachContents_calcium)
    // console.log("Updating stomachContents_carbohydrates")
    gastrointestinal.requests.stomachContents_carbohydrates.append(metrics.simulationTime,metrics.stomachContents_carbohydrates)
    // console.log("Updating stomachContents_carbohydrateDigationRate")
    gastrointestinal.requests.stomachContents_carbohydrateDigationRate.append(metrics.simulationTime,metrics.stomachContents_carbohydrateDigationRate)
    // console.log("Updating stomachContents_fat")
    gastrointestinal.requests.stomachContents_fat.append(metrics.simulationTime,metrics.stomachContents_fat)
    // console.log("Updating stomachContents_fatDigtationRate")
    gastrointestinal.requests.stomachContents_fatDigtationRate.append(metrics.simulationTime,metrics.stomachContents_fatDigtationRate)
    // console.log("Updating stomachContents_protien")
    gastrointestinal.requests.stomachContents_protien.append(metrics.simulationTime,metrics.stomachContents_protien)
    // console.log("Updating stomachContents_protienDigtationRate")
    gastrointestinal.requests.stomachContents_protienDigtationRate.append(metrics.simulationTime,metrics.stomachContents_protienDigtationRate)
    // console.log("Updating stomachContents_sodium")
    gastrointestinal.requests.stomachContents_sodium.append(metrics.simulationTime,metrics.stomachContents_sodium)
    // console.log("Updating stomachContents_water")
    gastrointestinal.requests.stomachContents_water.append(metrics.simulationTime,metrics.stomachContents_water)
  }
  function updateHepatic(metrics){
    // console.log("Updating Hepatic")
    updateDomain(hepatic.axisX)
    hepatic.requests.ketoneproductionRate.append(metrics.simulationTime,metrics.ketoneproductionRate)
    hepatic.requests.hepaticGluconeogenesisRate.append(metrics.simulationTime,metrics.hepaticGluconeogenesisRate)
  }
  function updateNervous(metrics){
    // console.log("Updating Nervous")
    updateDomain(nervous.axisX)
    nervous.requests.baroreceptorHeartRateScale.append(metrics.simulationTime,metrics.baroreceptorHeartRateScale)
    nervous.requests.baroreceptorHeartElastanceScale.append(metrics.simulationTime,metrics.baroreceptorHeartElastanceScale)
    nervous.requests.baroreceptorResistanceScale.append(metrics.simulationTime,metrics.baroreceptorResistanceScale)
    nervous.requests.baroreceptorComplianceScale.append(metrics.simulationTime,metrics.baroreceptorComplianceScale)
    nervous.requests.chemoreceptorHeartRateScale.append(metrics.simulationTime,metrics.chemoreceptorHeartRateScale)
    nervous.requests.chemoreceptorHeartElastanceScale.append(metrics.simulationTime,metrics.chemoreceptorHeartElastanceScale)
    nervous.requests.painVisualAnalogueScale.append(metrics.simulationTime,metrics.painVisualAnalogueScale)
    nervous.requests.leftEyePupillaryResponse.append(metrics.simulationTime,metrics.leftEyePupillaryResponse)
    nervous.requests.rightEyePupillaryResponse.append(metrics.simulationTime,metrics.rightEyePupillaryResponse)
  }
  function updateRenal(metrics){
    // console.log("Updating Renal")
    updateDomain(renal.axisX)
    renal.requests.glomerularFiltrationRate.append(metrics.simulationTime,metrics.glomerularFiltrationRate)
    renal.requests.filtrationFraction.append(metrics.simulationTime,metrics.filtrationFraction)
    renal.requests.leftAfferentArterioleResistance.append(metrics.simulationTime,metrics.leftAfferentArterioleResistance)
    renal.requests.leftBowmansCapsulesHydrostaticPressure.append(metrics.simulationTime,metrics.leftBowmansCapsulesHydrostaticPressure)
    renal.requests.leftBowmansCapsulesOsmoticPressure.append(metrics.simulationTime,metrics.leftBowmansCapsulesOsmoticPressure)
    renal.requests.leftEfferentArterioleResistance.append(metrics.simulationTime,metrics.leftEfferentArterioleResistance)
    renal.requests.leftGlomerularCapillariesHydrostaticPressure.append(metrics.simulationTime,metrics.leftGlomerularCapillariesHydrostaticPressure)
    renal.requests.leftGlomerularCapillariesOsmoticPressure.append(metrics.simulationTime,metrics.leftGlomerularCapillariesOsmoticPressure)
    renal.requests.leftGlomerularFiltrationCoefficient.append(metrics.simulationTime,metrics.leftGlomerularFiltrationCoefficient)
    renal.requests.leftGlomerularFiltrationRate.append(metrics.simulationTime,metrics.leftGlomerularFiltrationRate)
    renal.requests.leftGlomerularFiltrationSurfaceArea.append(metrics.simulationTime,metrics.leftGlomerularFiltrationSurfaceArea)
    renal.requests.leftGlomerularFluidPermeability.append(metrics.simulationTime,metrics.leftGlomerularFluidPermeability)
    renal.requests.leftFiltrationFraction.append(metrics.simulationTime,metrics.leftFiltrationFraction)
    renal.requests.leftNetFiltrationPressure.append(metrics.simulationTime,metrics.leftNetFiltrationPressure)
    renal.requests.leftNetReabsorptionPressure.append(metrics.simulationTime,metrics.leftNetReabsorptionPressure)
    renal.requests.leftPeritubularCapillariesHydrostaticPressure.append(metrics.simulationTime,metrics.leftPeritubularCapillariesHydrostaticPressure)
    renal.requests.leftPeritubularCapillariesOsmoticPressure.append(metrics.simulationTime,metrics.leftPeritubularCapillariesOsmoticPressure)
    renal.requests.leftReabsorptionFiltrationCoefficient.append(metrics.simulationTime,metrics.leftReabsorptionFiltrationCoefficient)
    renal.requests.leftReabsorptionRate.append(metrics.simulationTime,metrics.leftReabsorptionRate)
    renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.append(metrics.simulationTime,metrics.leftTubularReabsorptionFiltrationSurfaceArea)
    renal.requests.leftTubularReabsorptionFluidPermeability.append(metrics.simulationTime,metrics.leftTubularReabsorptionFluidPermeability)
    renal.requests.leftTubularHydrostaticPressure.append(metrics.simulationTime,metrics.leftTubularHydrostaticPressure)
    renal.requests.leftTubularOsmoticPressure.append(metrics.simulationTime,metrics.leftTubularOsmoticPressure)
    renal.requests.renalBloodFlow.append(metrics.simulationTime,metrics.renalBloodFlow)
    renal.requests.renalPlasmaFlow.append(metrics.simulationTime,metrics.renalPlasmaFlow)
    renal.requests.renalVascularResistance.append(metrics.simulationTime,metrics.renalVascularResistance)
    renal.requests.rightAfferentArterioleResistance.append(metrics.simulationTime,metrics.rightAfferentArterioleResistance)
    renal.requests.rightBowmansCapsulesHydrostaticPressure.append(metrics.simulationTime,metrics.rightBowmansCapsulesHydrostaticPressure)
    renal.requests.rightBowmansCapsulesOsmoticPressure.append(metrics.simulationTime,metrics.rightBowmansCapsulesOsmoticPressure)
    renal.requests.rightEfferentArterioleResistance.append(metrics.simulationTime,metrics.rightEfferentArterioleResistance)
    renal.requests.rightGlomerularCapillariesHydrostaticPressure.append(metrics.simulationTime,metrics.rightGlomerularCapillariesHydrostaticPressure)
    renal.requests.rightGlomerularCapillariesOsmoticPressure.append(metrics.simulationTime,metrics.rightGlomerularCapillariesOsmoticPressure)
    renal.requests.rightGlomerularFiltrationCoefficient.append(metrics.simulationTime,metrics.rightGlomerularFiltrationCoefficient)
    renal.requests.rightGlomerularFiltrationRate.append(metrics.simulationTime,metrics.rightGlomerularFiltrationRate)
    renal.requests.rightGlomerularFiltrationSurfaceArea.append(metrics.simulationTime,metrics.rightGlomerularFiltrationSurfaceArea)
    renal.requests.rightGlomerularFluidPermeability.append(metrics.simulationTime,metrics.rightGlomerularFluidPermeability)
    renal.requests.rightFiltrationFraction.append(metrics.simulationTime,metrics.rightFiltrationFraction)
    renal.requests.rightNetFiltrationPressure.append(metrics.simulationTime,metrics.rightNetFiltrationPressure)
    renal.requests.rightNetReabsorptionPressure.append(metrics.simulationTime,metrics.rightNetReabsorptionPressure)
    renal.requests.rightPeritubularCapillariesHydrostaticPressure.append(metrics.simulationTime,metrics.rightPeritubularCapillariesHydrostaticPressure)
    renal.requests.rightPeritubularCapillariesOsmoticPressure.append(metrics.simulationTime,metrics.rightPeritubularCapillariesOsmoticPressure)
    renal.requests.rightReabsorptionFiltrationCoefficient.append(metrics.simulationTime,metrics.rightReabsorptionFiltrationCoefficient)
    renal.requests.rightReabsorptionRate.append(metrics.simulationTime,metrics.rightReabsorptionRate)
    renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.append(metrics.simulationTime,metrics.rightTubularReabsorptionFiltrationSurfaceArea)
    renal.requests.rightTubularReabsorptionFluidPermeability.append(metrics.simulationTime,metrics.rightTubularReabsorptionFluidPermeability)
    renal.requests.rightTubularHydrostaticPressure.append(metrics.simulationTime,metrics.rightTubularHydrostaticPressure)
    renal.requests.rightTubularOsmoticPressure.append(metrics.simulationTime,metrics.rightTubularOsmoticPressure)
    renal.requests.urinationRate.append(metrics.simulationTime,metrics.urinationRate)
    renal.requests.urineOsmolality.append(metrics.simulationTime,metrics.urineOsmolality)
    renal.requests.urineOsmolarity.append(metrics.simulationTime,metrics.urineOsmolarity)
    renal.requests.urineProductionRate.append(metrics.simulationTime,metrics.urineProductionRate)
    renal.requests.meanUrineOutput.append(metrics.simulationTime,metrics.meanUrineOutput)
    renal.requests.urineSpecificGravity.append(metrics.simulationTime,metrics.urineSpecificGravity)
    renal.requests.urineVolume.append(metrics.simulationTime,metrics.urineVolume)
    renal.requests.urineUreaNitrogenConcentration.append(metrics.simulationTime,metrics.urineUreaNitrogenConcentration)
  }
  function updateRespiratory(metrics){
    // console.log("Updating Respiratory")
    updateDomain(respiratory.axisX)
    respiratory.requests.alveolarArterialGradient.append(metrics.simulationTime,metrics.alveolarArterialGradient)
    respiratory.requests.carricoIndex.append(metrics.simulationTime,metrics.carricoIndex)
    respiratory.requests.endTidalCarbonDioxideFraction.append(metrics.simulationTime,metrics.endTidalCarbonDioxideFraction)
    respiratory.requests.endTidalCarbonDioxidePressure.append(metrics.simulationTime,metrics.endTidalCarbonDioxidePressure)
    respiratory.requests.expiratoryFlow.append(metrics.simulationTime,metrics.expiratoryFlow)
    respiratory.requests.inspiratoryExpiratoryRatio.append(metrics.simulationTime,metrics.inspiratoryExpiratoryRatio)
    respiratory.requests.inspiratoryFlow.append(metrics.simulationTime,metrics.inspiratoryFlow)
    respiratory.requests.pulmonaryCompliance.append(metrics.simulationTime,metrics.pulmonaryCompliance)
    respiratory.requests.pulmonaryResistance.append(metrics.simulationTime,metrics.pulmonaryResistance)
    respiratory.requests.respirationDriverPressure.append(metrics.simulationTime,metrics.respirationDriverPressure)
    respiratory.requests.respirationMusclePressure.append(metrics.simulationTime,metrics.respirationMusclePressure)
    respiratory.requests.respirationRate.append(metrics.simulationTime,metrics.respirationRate)
    respiratory.requests.specificVentilation.append(metrics.simulationTime,metrics.specificVentilation)
    respiratory.requests.targetPulmonaryVentilation.append(metrics.simulationTime,metrics.targetPulmonaryVentilation)
    respiratory.requests.tidalVolume.append(metrics.simulationTime,metrics.tidalVolume)
    respiratory.requests.totalAlveolarVentilation.append(metrics.simulationTime,metrics.totalAlveolarVentilation)
    respiratory.requests.totalDeadSpaceVentilation.append(metrics.simulationTime,metrics.totalDeadSpaceVentilation)
    respiratory.requests.totalLungVolume.append(metrics.simulationTime,metrics.totalLungVolume)
    respiratory.requests.totalPulmonaryVentilation.append(metrics.simulationTime,metrics.totalPulmonaryVentilation)
    respiratory.requests.transpulmonaryPressure.append(metrics.simulationTime,metrics.transpulmonaryPressure)
  }
  function updateTissue(metrics){
    // console.log("Updating Tissue")
    updateDomain(tissue.axisX)
    tissue.requests.carbonDioxideProductionRate.append(metrics.simulationTime,metrics.carbonDioxideProductionRate)
    tissue.requests.dehydrationFraction.append(metrics.simulationTime,metrics.dehydrationFraction)
    tissue.requests.extracellularFluidVolume.append(metrics.simulationTime,metrics.extracellularFluidVolume)
    tissue.requests.extravascularFluidVolume.append(metrics.simulationTime,metrics.extravascularFluidVolume)
    tissue.requests.intracellularFluidPH.append(metrics.simulationTime,metrics.intracellularFluidPH)
    tissue.requests.intracellularFluidVolume.append(metrics.simulationTime,metrics.intracellularFluidVolume)
    tissue.requests.totalBodyFluidVolume.append(metrics.simulationTime,metrics.totalBodyFluidVolume)
    tissue.requests.oxygenConsumptionRate.append(metrics.simulationTime,metrics.oxygenConsumptionRate)
    tissue.requests.respiratoryExchangeRatio.append(metrics.simulationTime,metrics.respiratoryExchangeRatio)
    tissue.requests.liverInsulinSetPoint.append(metrics.simulationTime,metrics.liverInsulinSetPoint)
    tissue.requests.liverGlucagonSetPoint.append(metrics.simulationTime,metrics.liverGlucagonSetPoint)
    tissue.requests.muscleInsulinSetPoint.append(metrics.simulationTime,metrics.muscleInsulinSetPoint)
    tissue.requests.muscleGlucagonSetPoint.append(metrics.simulationTime,metrics.muscleGlucagonSetPoint)
    tissue.requests.fatInsulinSetPoint.append(metrics.simulationTime,metrics.fatInsulinSetPoint)
    tissue.requests.fatGlucagonSetPoint.append(metrics.simulationTime,metrics.fatGlucagonSetPoint)
    tissue.requests.liverGlycogen.append(metrics.simulationTime,metrics.liverGlycogen)
    tissue.requests.muscleGlycogen.append(metrics.simulationTime,metrics.muscleGlycogen)
    tissue.requests.storedProtein.append(metrics.simulationTime,metrics.storedProtein)
    tissue.requests.storedFat.append(metrics.simulationTime,metrics.storedFat)
  }
  //!
  //!  Setup Functions for creating all the axis plots
  //!
  function setupBloodChemistry(){
    bloodChemistry.requests.arterialBloodPH = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.arterialBloodPH.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.arterialBloodPH.axisY);
    bloodChemistry.requests.arterialBloodPH.axisY = bloodChemistry.axisY(bloodChemistry.requests.arterialBloodPH)

    bloodChemistry.requests.arterialBloodPHBaseline = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.arterialBloodPHBaseline.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.arterialBloodPHBaseline.axisY);
    bloodChemistry.requests.arterialBloodPHBaseline.axisY = bloodChemistry.axisY(bloodChemistry.requests.arterialBloodPHBaseline)

    bloodChemistry.requests.bloodDensity = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.bloodDensity.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.bloodDensity.axisY);
    bloodChemistry.requests.bloodDensity.axisY = bloodChemistry.axisY(bloodChemistry.requests.bloodDensity)

    bloodChemistry.requests.bloodSpecificHeat = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.bloodSpecificHeat.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.bloodSpecificHeat.axisY);
    bloodChemistry.requests.bloodSpecificHeat.axisY = bloodChemistry.axisY(bloodChemistry.requests.bloodSpecificHeat)

    bloodChemistry.requests.bloodUreaNitrogenConcentration = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.bloodUreaNitrogenConcentration.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.bloodUreaNitrogenConcentration.axisY);
    bloodChemistry.requests.bloodUreaNitrogenConcentration.axisY = bloodChemistry.axisY(bloodChemistry.requests.bloodUreaNitrogenConcentration)

    bloodChemistry.requests.carbonDioxideSaturation = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.carbonDioxideSaturation.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.carbonDioxideSaturation.axisY);
    bloodChemistry.requests.carbonDioxideSaturation.axisY = bloodChemistry.axisY(bloodChemistry.requests.carbonDioxideSaturation)

    bloodChemistry.requests.carbonMonoxideSaturation = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.carbonMonoxideSaturation.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.carbonMonoxideSaturation.axisY);
    bloodChemistry.requests.carbonMonoxideSaturation.axisY = bloodChemistry.axisY(bloodChemistry.requests.carbonMonoxideSaturation)

    bloodChemistry.requests.hematocrit = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.hematocrit.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.hematocrit.axisY);
    bloodChemistry.requests.hematocrit.axisY = bloodChemistry.axisY(bloodChemistry.requests.hematocrit)

    bloodChemistry.requests.hemoglobinContent = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.hemoglobinContent.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.hemoglobinContent.axisY);
    bloodChemistry.requests.hemoglobinContent.axisY = bloodChemistry.axisY(bloodChemistry.requests.hemoglobinContent)

    bloodChemistry.requests.oxygenSaturation = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.oxygenSaturation.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.oxygenSaturation.axisY);
    bloodChemistry.requests.oxygenSaturation.axisY = bloodChemistry.axisY(bloodChemistry.requests.oxygenSaturation)

    bloodChemistry.requests.phosphate = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.phosphate.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.phosphate.axisY);
    bloodChemistry.requests.phosphate.axisY = bloodChemistry.axisY(bloodChemistry.requests.phosphate)

    bloodChemistry.requests.plasmaVolume = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.plasmaVolume.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.plasmaVolume.axisY);
    bloodChemistry.requests.plasmaVolume.axisY = bloodChemistry.axisY(bloodChemistry.requests.plasmaVolume)

    bloodChemistry.requests.pulseOximetry = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.pulseOximetry.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.pulseOximetry.axisY);
    bloodChemistry.requests.pulseOximetry.axisY = bloodChemistry.axisY(bloodChemistry.requests.pulseOximetry)

    bloodChemistry.requests.redBloodCellAcetylcholinesterase = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.redBloodCellAcetylcholinesterase.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.redBloodCellAcetylcholinesterase.axisY);
    bloodChemistry.requests.redBloodCellAcetylcholinesterase.axisY = bloodChemistry.axisY(bloodChemistry.requests.redBloodCellAcetylcholinesterase)

    bloodChemistry.requests.redBloodCellCount = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.redBloodCellCount.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.redBloodCellCount.axisY);
    bloodChemistry.requests.redBloodCellCount.axisY = bloodChemistry.axisY(bloodChemistry.requests.redBloodCellCount)

    bloodChemistry.requests.shuntFraction = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.shuntFraction.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.shuntFraction.axisY);
    bloodChemistry.requests.shuntFraction.axisY = bloodChemistry.axisY(bloodChemistry.requests.shuntFraction)

    bloodChemistry.requests.strongIonDifference = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.strongIonDifference.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.strongIonDifference.axisY);
    bloodChemistry.requests.strongIonDifference.axisY = bloodChemistry.axisY(bloodChemistry.requests.strongIonDifference)

    bloodChemistry.requests.totalBilirubin = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.totalBilirubin.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.totalBilirubin.axisY);
    bloodChemistry.requests.totalBilirubin.axisY = bloodChemistry.axisY(bloodChemistry.requests.totalBilirubin)

    bloodChemistry.requests.totalProteinConcentration = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.totalProteinConcentration.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.totalProteinConcentration.axisY);
    bloodChemistry.requests.totalProteinConcentration.axisY = bloodChemistry.axisY(bloodChemistry.requests.totalProteinConcentration)

    bloodChemistry.requests.venousBloodPH = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.venousBloodPH.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.venousBloodPH.axisY);
    bloodChemistry.requests.venousBloodPH.axisY = bloodChemistry.axisY(bloodChemistry.requests.venousBloodPH)

    bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.axisY);
    bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.axisY = bloodChemistry.axisY(bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma)

    bloodChemistry.requests.volumeFractionNeutralLipidInPlasma = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.axisY);
    bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.axisY = bloodChemistry.axisY(bloodChemistry.requests.volumeFractionNeutralLipidInPlasma)

    bloodChemistry.requests.arterialCarbonDioxidePressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.arterialCarbonDioxidePressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.arterialCarbonDioxidePressure.axisY);
    bloodChemistry.requests.arterialCarbonDioxidePressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.arterialCarbonDioxidePressure)

    bloodChemistry.requests.arterialOxygenPressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.arterialOxygenPressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.arterialOxygenPressure.axisY);
    bloodChemistry.requests.arterialOxygenPressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.arterialOxygenPressure)

    bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.axisY);
    bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure)

    bloodChemistry.requests.pulmonaryArterialOxygenPressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.pulmonaryArterialOxygenPressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.pulmonaryArterialOxygenPressure.axisY);
    bloodChemistry.requests.pulmonaryArterialOxygenPressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.pulmonaryArterialOxygenPressure)

    bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.axisY);
    bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure)

    bloodChemistry.requests.pulmonaryVenousOxygenPressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.pulmonaryVenousOxygenPressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.pulmonaryVenousOxygenPressure.axisY);
    bloodChemistry.requests.pulmonaryVenousOxygenPressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.pulmonaryVenousOxygenPressure)

    bloodChemistry.requests.venousCarbonDioxidePressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.venousCarbonDioxidePressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.venousCarbonDioxidePressure.axisY);
    bloodChemistry.requests.venousCarbonDioxidePressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.venousCarbonDioxidePressure)

    bloodChemistry.requests.venousOxygenPressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.venousOxygenPressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.venousOxygenPressure.axisY);
    bloodChemistry.requests.venousOxygenPressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.venousOxygenPressure)

    bloodChemistry.requests.inflammatoryResponse = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponse.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponse.axisY);
    bloodChemistry.requests.inflammatoryResponse.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponse)

    bloodChemistry.requests.inflammatoryResponseLocalPathogen = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseLocalPathogen.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseLocalPathogen.axisY);
    bloodChemistry.requests.inflammatoryResponseLocalPathogen.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseLocalPathogen)

    bloodChemistry.requests.inflammatoryResponseLocalMacrophage = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseLocalMacrophage.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseLocalMacrophage.axisY);
    bloodChemistry.requests.inflammatoryResponseLocalMacrophage.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseLocalMacrophage)

    bloodChemistry.requests.inflammatoryResponseLocalNeutrophil = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.axisY);
    bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseLocalNeutrophil)

    bloodChemistry.requests.inflammatoryResponseLocalBarrier = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseLocalBarrier.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseLocalBarrier.axisY);
    bloodChemistry.requests.inflammatoryResponseLocalBarrier.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseLocalBarrier)

    bloodChemistry.requests.inflammatoryResponseBloodPathogen = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseBloodPathogen.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseBloodPathogen.axisY);
    bloodChemistry.requests.inflammatoryResponseBloodPathogen.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseBloodPathogen)

    bloodChemistry.requests.inflammatoryResponseTrauma = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseTrauma.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseTrauma.axisY);
    bloodChemistry.requests.inflammatoryResponseTrauma.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseTrauma)

    bloodChemistry.requests.inflammatoryResponseMacrophageResting = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseMacrophageResting.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseMacrophageResting.axisY);
    bloodChemistry.requests.inflammatoryResponseMacrophageResting.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseMacrophageResting)

    bloodChemistry.requests.inflammatoryResponseMacrophageActive = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseMacrophageActive.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseMacrophageActive.axisY);
    bloodChemistry.requests.inflammatoryResponseMacrophageActive.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseMacrophageActive)

    bloodChemistry.requests.inflammatoryResponseNeutrophilResting = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseNeutrophilResting.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseNeutrophilResting.axisY);
    bloodChemistry.requests.inflammatoryResponseNeutrophilResting.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseNeutrophilResting)

    bloodChemistry.requests.inflammatoryResponseNeutrophilActive = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseNeutrophilActive.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseNeutrophilActive.axisY);
    bloodChemistry.requests.inflammatoryResponseNeutrophilActive.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseNeutrophilActive)

    bloodChemistry.requests.inflammatoryResponseInducibleNOSPre = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.axisY);
    bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseInducibleNOSPre)

    bloodChemistry.requests.inflammatoryResponseInducibleNOS = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseInducibleNOS.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseInducibleNOS.axisY);
    bloodChemistry.requests.inflammatoryResponseInducibleNOS.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseInducibleNOS)

    bloodChemistry.requests.inflammatoryResponseConstitutiveNOS = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.axisY);
    bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseConstitutiveNOS)

    bloodChemistry.requests.inflammatoryResponseNitrate = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseNitrate.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseNitrate.axisY);
    bloodChemistry.requests.inflammatoryResponseNitrate.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseNitrate)

    bloodChemistry.requests.inflammatoryResponseNitricOxide = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseNitricOxide.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseNitricOxide.axisY);
    bloodChemistry.requests.inflammatoryResponseNitricOxide.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseNitricOxide)

    bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.axisY);
    bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor)

    bloodChemistry.requests.inflammatoryResponseInterleukin6 = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseInterleukin6.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseInterleukin6.axisY);
    bloodChemistry.requests.inflammatoryResponseInterleukin6.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseInterleukin6)

    bloodChemistry.requests.inflammatoryResponseInterleukin10 = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseInterleukin10.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseInterleukin10.axisY);
    bloodChemistry.requests.inflammatoryResponseInterleukin10.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseInterleukin10)

    bloodChemistry.requests.inflammatoryResponseInterleukin12 = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseInterleukin12.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseInterleukin12.axisY);
    bloodChemistry.requests.inflammatoryResponseInterleukin12.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseInterleukin12)

    bloodChemistry.requests.inflammatoryResponseCatecholamines = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseCatecholamines.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseCatecholamines.axisY);
    bloodChemistry.requests.inflammatoryResponseCatecholamines.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseCatecholamines)

    bloodChemistry.requests.inflammatoryResponseTissueIntegrity = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseTissueIntegrity.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseTissueIntegrity.axisY);
    bloodChemistry.requests.inflammatoryResponseTissueIntegrity.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseTissueIntegrity)
  }
  function setupCardiovascular(){
    cardiovascular.requests.arterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.arterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.arterialPressure.axisY);
    cardiovascular.requests.arterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.arterialPressure)

     cardiovascular.requests.bloodVolume = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.bloodVolume.axisY.label, cardiovascular.axisX, cardiovascular.requests.bloodVolume.axisY);
     cardiovascular.requests.bloodVolume.axisY = cardiovascular.axisY(cardiovascular.requests.bloodVolume)

     cardiovascular.requests.cardiacIndex = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.cardiacIndex.axisY.label, cardiovascular.axisX, cardiovascular.requests.cardiacIndex.axisY);
     cardiovascular.requests.cardiacIndex.axisY = cardiovascular.axisY(cardiovascular.requests.cardiacIndex)

     cardiovascular.requests.cardiacOutput = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.cardiacOutput.axisY.label, cardiovascular.axisX, cardiovascular.requests.cardiacOutput.axisY);
     cardiovascular.requests.cardiacOutput.axisY = cardiovascular.axisY(cardiovascular.requests.cardiacOutput)

     cardiovascular.requests.centralVenousPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.centralVenousPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.centralVenousPressure.axisY);
     cardiovascular.requests.centralVenousPressure.axisY = cardiovascular.axisY(cardiovascular.requests.centralVenousPressure)

     cardiovascular.requests.cerebralBloodFlow = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.cerebralBloodFlow.axisY.label, cardiovascular.axisX, cardiovascular.requests.cerebralBloodFlow.axisY);
     cardiovascular.requests.cerebralBloodFlow.axisY = cardiovascular.axisY(cardiovascular.requests.cerebralBloodFlow)

     cardiovascular.requests.cerebralPerfusionPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.cerebralPerfusionPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.cerebralPerfusionPressure.axisY);
     cardiovascular.requests.cerebralPerfusionPressure.axisY = cardiovascular.axisY(cardiovascular.requests.cerebralPerfusionPressure)

     cardiovascular.requests.diastolicArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.diastolicArterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.diastolicArterialPressure.axisY);
     cardiovascular.requests.diastolicArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.diastolicArterialPressure)

     cardiovascular.requests.heartEjectionFraction = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.heartEjectionFraction.axisY.label, cardiovascular.axisX, cardiovascular.requests.heartEjectionFraction.axisY);
     cardiovascular.requests.heartEjectionFraction.axisY = cardiovascular.axisY(cardiovascular.requests.heartEjectionFraction)

     cardiovascular.requests.heartRate = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.heartRate.axisY.label, cardiovascular.axisX, cardiovascular.requests.heartRate.axisY);
     cardiovascular.requests.heartRate.axisY = cardiovascular.axisY(cardiovascular.requests.heartRate)

     cardiovascular.requests.heartStrokeVolume = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.heartStrokeVolume.axisY.label, cardiovascular.axisX, cardiovascular.requests.heartStrokeVolume.axisY);
     cardiovascular.requests.heartStrokeVolume.axisY = cardiovascular.axisY(cardiovascular.requests.heartStrokeVolume)

     cardiovascular.requests.intracranialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.intracranialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.intracranialPressure.axisY);
     cardiovascular.requests.intracranialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.intracranialPressure)

     cardiovascular.requests.meanArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.meanArterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.meanArterialPressure.axisY);
     cardiovascular.requests.meanArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.meanArterialPressure)

     cardiovascular.requests.meanArterialCarbonDioxidePartialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.axisY);
     cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.meanArterialCarbonDioxidePartialPressure)

     cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.axisY.label, cardiovascular.axisX, cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.axisY);
     cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.axisY = cardiovascular.axisY(cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta)

     cardiovascular.requests.meanCentralVenousPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.meanCentralVenousPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.meanCentralVenousPressure.axisY);
     cardiovascular.requests.meanCentralVenousPressure.axisY = cardiovascular.axisY(cardiovascular.requests.meanCentralVenousPressure)

     cardiovascular.requests.meanSkinFlow = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.meanSkinFlow.axisY.label, cardiovascular.axisX, cardiovascular.requests.meanSkinFlow.axisY);
     cardiovascular.requests.meanSkinFlow.axisY = cardiovascular.axisY(cardiovascular.requests.meanSkinFlow)

     cardiovascular.requests.pulmonaryArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryArterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryArterialPressure.axisY);
     cardiovascular.requests.pulmonaryArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryArterialPressure)

     cardiovascular.requests.pulmonaryCapillariesWedgePressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryCapillariesWedgePressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryCapillariesWedgePressure.axisY);
     cardiovascular.requests.pulmonaryCapillariesWedgePressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryCapillariesWedgePressure)

     cardiovascular.requests.pulmonaryDiastolicArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryDiastolicArterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryDiastolicArterialPressure.axisY);
     cardiovascular.requests.pulmonaryDiastolicArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryDiastolicArterialPressure)

     cardiovascular.requests.pulmonaryMeanArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryMeanArterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryMeanArterialPressure.axisY);
     cardiovascular.requests.pulmonaryMeanArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryMeanArterialPressure)

     cardiovascular.requests.pulmonaryMeanCapillaryFlow = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryMeanCapillaryFlow.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryMeanCapillaryFlow.axisY);
     cardiovascular.requests.pulmonaryMeanCapillaryFlow.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryMeanCapillaryFlow)

     cardiovascular.requests.pulmonaryMeanShuntFlow = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryMeanShuntFlow.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryMeanShuntFlow.axisY);
     cardiovascular.requests.pulmonaryMeanShuntFlow.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryMeanShuntFlow)

     cardiovascular.requests.pulmonarySystolicArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonarySystolicArterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonarySystolicArterialPressure.axisY);
     cardiovascular.requests.pulmonarySystolicArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonarySystolicArterialPressure)

     cardiovascular.requests.pulmonaryVascularResistance = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryVascularResistance.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryVascularResistance.axisY);
     cardiovascular.requests.pulmonaryVascularResistance.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryVascularResistance)

     cardiovascular.requests.pulmonaryVascularResistanceIndex = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryVascularResistanceIndex.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryVascularResistanceIndex.axisY);
     cardiovascular.requests.pulmonaryVascularResistanceIndex.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryVascularResistanceIndex)

     cardiovascular.requests.pulsePressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulsePressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulsePressure.axisY);
     cardiovascular.requests.pulsePressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulsePressure)

     cardiovascular.requests.systemicVascularResistance = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.systemicVascularResistance.axisY.label, cardiovascular.axisX, cardiovascular.requests.systemicVascularResistance.axisY);
     cardiovascular.requests.systemicVascularResistance.axisY = cardiovascular.axisY(cardiovascular.requests.systemicVascularResistance)

     cardiovascular.requests.systolicArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.systolicArterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.systolicArterialPressure.axisY);
     cardiovascular.requests.systolicArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.systolicArterialPressure)
  }
  function setupDrugs(){
     drugs.requests.bronchodilationLevel = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.bronchodilationLevel.axisY.label, drugs.axisX, drugs.requests.bronchodilationLevel.axisY);
     drugs.requests.bronchodilationLevel.axisY = drugs.axisY(drugs.requests.bronchodilationLevel)

     drugs.requests.heartRateChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.heartRateChange.axisY.label, drugs.axisX, drugs.requests.heartRateChange.axisY);
     drugs.requests.heartRateChange.axisY = drugs.axisY(drugs.requests.heartRateChange)

     drugs.requests.hemorrhageChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.hemorrhageChange.axisY.label, drugs.axisX, drugs.requests.hemorrhageChange.axisY);
     drugs.requests.hemorrhageChange.axisY = drugs.axisY(drugs.requests.hemorrhageChange)

     drugs.requests.meanBloodPressureChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.meanBloodPressureChange.axisY.label, drugs.axisX, drugs.requests.meanBloodPressureChange.axisY);
     drugs.requests.meanBloodPressureChange.axisY = drugs.axisY(drugs.requests.meanBloodPressureChange)

     drugs.requests.neuromuscularBlockLevel = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.neuromuscularBlockLevel.axisY.label, drugs.axisX, drugs.requests.neuromuscularBlockLevel.axisY);
     drugs.requests.neuromuscularBlockLevel.axisY = drugs.axisY(drugs.requests.neuromuscularBlockLevel)

     drugs.requests.pulsePressureChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.pulsePressureChange.axisY.label, drugs.axisX, drugs.requests.pulsePressureChange.axisY);
     drugs.requests.pulsePressureChange.axisY = drugs.axisY(drugs.requests.pulsePressureChange)

     drugs.requests.respirationRateChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.respirationRateChange.axisY.label, drugs.axisX, drugs.requests.respirationRateChange.axisY);
     drugs.requests.respirationRateChange.axisY = drugs.axisY(drugs.requests.respirationRateChange)

     drugs.requests.sedationLevel = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.sedationLevel.axisY.label, drugs.axisX, drugs.requests.sedationLevel.axisY);
     drugs.requests.sedationLevel.axisY = drugs.axisY(drugs.requests.sedationLevel)

     drugs.requests.tidalVolumeChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.tidalVolumeChange.axisY.label, drugs.axisX, drugs.requests.tidalVolumeChange.axisY);
     drugs.requests.tidalVolumeChange.axisY = drugs.axisY(drugs.requests.tidalVolumeChange)

     drugs.requests.tubularPermeabilityChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.tubularPermeabilityChange.axisY.label, drugs.axisX, drugs.requests.tubularPermeabilityChange.axisY);
     drugs.requests.tubularPermeabilityChange.axisY = drugs.axisY(drugs.requests.tubularPermeabilityChange)

     drugs.requests.centralNervousResponse = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.centralNervousResponse.axisY.label, drugs.axisX, drugs.requests.centralNervousResponse.axisY);
     drugs.requests.centralNervousResponse.axisY = drugs.axisY(drugs.requests.centralNervousResponse)
  }
  function setupEndocrine(){
    endocrine.requests.insulinSynthesisRate = endocrine.createSeries(ChartView.SeriesTypeLine, endocrine.requests.insulinSynthesisRate.axisY.label, endocrine.axisX, endocrine.requests.insulinSynthesisRate.axisY);
    endocrine.requests.insulinSynthesisRate.axisY = endocrine.axisY(endocrine.requests.insulinSynthesisRate)

    endocrine.requests.glucagonSynthesisRate = endocrine.createSeries(ChartView.SeriesTypeLine, endocrine.requests.glucagonSynthesisRate.axisY.label, endocrine.axisX, endocrine.requests.glucagonSynthesisRate.axisY);
    endocrine.requests.glucagonSynthesisRate.axisY = endocrine.axisY(endocrine.requests.glucagonSynthesisRate)
  }
  function setupEnergy(){
    energy.requests.achievedExerciseLevel = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.achievedExerciseLevel.axisY.label, energy.axisX, energy.requests.achievedExerciseLevel.axisY);
    energy.requests.achievedExerciseLevel.axisY = energy.axisY(energy.requests.achievedExerciseLevel)

    energy.requests.chlorideLostToSweat = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.chlorideLostToSweat.axisY.label, energy.axisX, energy.requests.chlorideLostToSweat.axisY);
    energy.requests.chlorideLostToSweat.axisY = energy.axisY(energy.requests.chlorideLostToSweat)

    energy.requests.coreTemperature = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.coreTemperature.axisY.label, energy.axisX, energy.requests.coreTemperature.axisY);
    energy.requests.coreTemperature.axisY = energy.axisY(energy.requests.coreTemperature)

    energy.requests.creatinineProductionRate = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.creatinineProductionRate.axisY.label, energy.axisX, energy.requests.creatinineProductionRate.axisY);
    energy.requests.creatinineProductionRate.axisY = energy.axisY(energy.requests.creatinineProductionRate)

    energy.requests.exerciseMeanArterialPressureDelta = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.exerciseMeanArterialPressureDelta.axisY.label, energy.axisX, energy.requests.exerciseMeanArterialPressureDelta.axisY);
    energy.requests.exerciseMeanArterialPressureDelta.axisY = energy.axisY(energy.requests.exerciseMeanArterialPressureDelta)

    energy.requests.fatigueLevel = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.fatigueLevel.axisY.label, energy.axisX, energy.requests.fatigueLevel.axisY);
    energy.requests.fatigueLevel.axisY = energy.axisY(energy.requests.fatigueLevel)

    energy.requests.lactateProductionRate = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.lactateProductionRate.axisY.label, energy.axisX, energy.requests.lactateProductionRate.axisY);
    energy.requests.lactateProductionRate.axisY = energy.axisY(energy.requests.lactateProductionRate)

    energy.requests.potassiumLostToSweat = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.potassiumLostToSweat.axisY.label, energy.axisX, energy.requests.potassiumLostToSweat.axisY);
    energy.requests.potassiumLostToSweat.axisY = energy.axisY(energy.requests.potassiumLostToSweat)

    energy.requests.skinTemperature = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.skinTemperature.axisY.label, energy.axisX, energy.requests.skinTemperature.axisY);
    energy.requests.skinTemperature.axisY = energy.axisY(energy.requests.skinTemperature)

    energy.requests.sodiumLostToSweat = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.sodiumLostToSweat.axisY.label, energy.axisX, energy.requests.sodiumLostToSweat.axisY);
    energy.requests.sodiumLostToSweat.axisY = energy.axisY(energy.requests.sodiumLostToSweat)

    energy.requests.sweatRate = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.sweatRate.axisY.label, energy.axisX, energy.requests.sweatRate.axisY);
    energy.requests.sweatRate.axisY = energy.axisY(energy.requests.sweatRate)

    energy.requests.totalMetabolicRate = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.totalMetabolicRate.axisY.label, energy.axisX, energy.requests.totalMetabolicRate.axisY);
    energy.requests.totalMetabolicRate.axisY = energy.axisY(energy.requests.totalMetabolicRate)

    energy.requests.totalWorkRateLevel = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.totalWorkRateLevel.axisY.label, energy.axisX, energy.requests.totalWorkRateLevel.axisY);
    energy.requests.totalWorkRateLevel.axisY = energy.axisY(energy.requests.totalWorkRateLevel)
  }
  function setupGastrointestinal(){
    gastrointestinal.requests.chymeAbsorptionRate = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.chymeAbsorptionRate.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.chymeAbsorptionRate.axisY);
    gastrointestinal.requests.chymeAbsorptionRate.axisY = gastrointestinal.axisY(gastrointestinal.requests.chymeAbsorptionRate)

    gastrointestinal.requests.stomachContents_calcium = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_calcium.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_calcium.axisY);
    gastrointestinal.requests.stomachContents_calcium.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_calcium)

    gastrointestinal.requests.stomachContents_carbohydrates = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_carbohydrates.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_carbohydrates.axisY);
    gastrointestinal.requests.stomachContents_carbohydrates.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_carbohydrates)

    gastrointestinal.requests.stomachContents_carbohydrateDigationRate = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_carbohydrateDigationRate.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_carbohydrateDigationRate.axisY);
    gastrointestinal.requests.stomachContents_carbohydrateDigationRate.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_carbohydrateDigationRate)

    gastrointestinal.requests.stomachContents_fat = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_fat.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_fat.axisY);
    gastrointestinal.requests.stomachContents_fat.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_fat)

    gastrointestinal.requests.stomachContents_fatDigtationRate = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_fatDigtationRate.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_fatDigtationRate.axisY);
    gastrointestinal.requests.stomachContents_fatDigtationRate.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_fatDigtationRate)

    gastrointestinal.requests.stomachContents_protien = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_protien.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_protien.axisY);
    gastrointestinal.requests.stomachContents_protien.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_protien)

    gastrointestinal.requests.stomachContents_protienDigtationRate = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_protienDigtationRate.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_protienDigtationRate.axisY);
    gastrointestinal.requests.stomachContents_protienDigtationRate.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_protienDigtationRate)

    gastrointestinal.requests.stomachContents_sodium = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_sodium.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_sodium.axisY);
    gastrointestinal.requests.stomachContents_sodium.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_sodium)

    gastrointestinal.requests.stomachContents_water = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_water.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_water.axisY);
    gastrointestinal.requests.stomachContents_water.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_water)
  }
  function setupHepatic(){
    hepatic.requests.ketoneproductionRate = hepatic.createSeries(ChartView.SeriesTypeLine, hepatic.requests.ketoneproductionRate.axisY.label, hepatic.axisX, hepatic.requests.ketoneproductionRate.axisY);
    hepatic.requests.ketoneproductionRate.axisY = hepatic.axisY(hepatic.requests.ketoneproductionRate)

    hepatic.requests.hepaticGluconeogenesisRate = hepatic.createSeries(ChartView.SeriesTypeLine, hepatic.requests.hepaticGluconeogenesisRate.axisY.label, hepatic.axisX, hepatic.requests.hepaticGluconeogenesisRate.axisY);
    hepatic.requests.hepaticGluconeogenesisRate.axisY = hepatic.axisY(hepatic.requests.hepaticGluconeogenesisRate)
  }
  function setupNervous(){
    nervous.requests.baroreceptorHeartRateScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.baroreceptorHeartRateScale.axisY.label, nervous.axisX, nervous.requests.baroreceptorHeartRateScale.axisY);
    nervous.requests.baroreceptorHeartRateScale.axisY = nervous.axisY(nervous.requests.baroreceptorHeartRateScale)

    nervous.requests.baroreceptorHeartElastanceScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.baroreceptorHeartElastanceScale.axisY.label, nervous.axisX, nervous.requests.baroreceptorHeartElastanceScale.axisY);
    nervous.requests.baroreceptorHeartElastanceScale.axisY = nervous.axisY(nervous.requests.baroreceptorHeartElastanceScale)

    nervous.requests.baroreceptorResistanceScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.baroreceptorResistanceScale.axisY.label, nervous.axisX, nervous.requests.baroreceptorResistanceScale.axisY);
    nervous.requests.baroreceptorResistanceScale.axisY = nervous.axisY(nervous.requests.baroreceptorResistanceScale)

    nervous.requests.baroreceptorComplianceScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.baroreceptorComplianceScale.axisY.label, nervous.axisX, nervous.requests.baroreceptorComplianceScale.axisY);
    nervous.requests.baroreceptorComplianceScale.axisY = nervous.axisY(nervous.requests.baroreceptorComplianceScale)

    nervous.requests.chemoreceptorHeartRateScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.chemoreceptorHeartRateScale.axisY.label, nervous.axisX, nervous.requests.chemoreceptorHeartRateScale.axisY);
    nervous.requests.chemoreceptorHeartRateScale.axisY = nervous.axisY(nervous.requests.chemoreceptorHeartRateScale)

    nervous.requests.chemoreceptorHeartElastanceScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.chemoreceptorHeartElastanceScale.axisY.label, nervous.axisX, nervous.requests.chemoreceptorHeartElastanceScale.axisY);
    nervous.requests.chemoreceptorHeartElastanceScale.axisY = nervous.axisY(nervous.requests.chemoreceptorHeartElastanceScale)

    nervous.requests.painVisualAnalogueScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.painVisualAnalogueScale.axisY.label, nervous.axisX, nervous.requests.painVisualAnalogueScale.axisY);
    nervous.requests.painVisualAnalogueScale.axisY = nervous.axisY(nervous.requests.painVisualAnalogueScale)

    nervous.requests.leftEyePupillaryResponse = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.leftEyePupillaryResponse.axisY.label, nervous.axisX, nervous.requests.leftEyePupillaryResponse.axisY);
    nervous.requests.leftEyePupillaryResponse.axisY = nervous.axisY(nervous.requests.leftEyePupillaryResponse)

    nervous.requests.rightEyePupillaryResponse = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.rightEyePupillaryResponse.axisY.label, nervous.axisX, nervous.requests.rightEyePupillaryResponse.axisY);
    nervous.requests.rightEyePupillaryResponse.axisY = nervous.axisY(nervous.requests.rightEyePupillaryResponse)
  }
  function setupRenal(){
    renal.requests.glomerularFiltrationRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.glomerularFiltrationRate.axisY.label, renal.axisX, renal.requests.glomerularFiltrationRate.axisY);
    renal.requests.glomerularFiltrationRate.axisY = renal.axisY(renal.requests.glomerularFiltrationRate)

    renal.requests.filtrationFraction = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.filtrationFraction.axisY.label, renal.axisX, renal.requests.filtrationFraction.axisY);
    renal.requests.filtrationFraction.axisY = renal.axisY(renal.requests.filtrationFraction)

    renal.requests.leftAfferentArterioleResistance = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftAfferentArterioleResistance.axisY.label, renal.axisX, renal.requests.leftAfferentArterioleResistance.axisY);
    renal.requests.leftAfferentArterioleResistance.axisY = renal.axisY(renal.requests.leftAfferentArterioleResistance)

    renal.requests.leftBowmansCapsulesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftBowmansCapsulesHydrostaticPressure.axisY.label, renal.axisX, renal.requests.leftBowmansCapsulesHydrostaticPressure.axisY);
    renal.requests.leftBowmansCapsulesHydrostaticPressure.axisY = renal.axisY(renal.requests.leftBowmansCapsulesHydrostaticPressure)

    renal.requests.leftBowmansCapsulesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftBowmansCapsulesOsmoticPressure.axisY.label, renal.axisX, renal.requests.leftBowmansCapsulesOsmoticPressure.axisY);
    renal.requests.leftBowmansCapsulesOsmoticPressure.axisY = renal.axisY(renal.requests.leftBowmansCapsulesOsmoticPressure)

    renal.requests.leftEfferentArterioleResistance = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftEfferentArterioleResistance.axisY.label, renal.axisX, renal.requests.leftEfferentArterioleResistance.axisY);
    renal.requests.leftEfferentArterioleResistance.axisY = renal.axisY(renal.requests.leftEfferentArterioleResistance)

    renal.requests.leftGlomerularCapillariesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularCapillariesHydrostaticPressure.axisY.label, renal.axisX, renal.requests.leftGlomerularCapillariesHydrostaticPressure.axisY);
    renal.requests.leftGlomerularCapillariesHydrostaticPressure.axisY = renal.axisY(renal.requests.leftGlomerularCapillariesHydrostaticPressure)

    renal.requests.leftGlomerularCapillariesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularCapillariesOsmoticPressure.axisY.label, renal.axisX, renal.requests.leftGlomerularCapillariesOsmoticPressure.axisY);
    renal.requests.leftGlomerularCapillariesOsmoticPressure.axisY = renal.axisY(renal.requests.leftGlomerularCapillariesOsmoticPressure)

    renal.requests.leftGlomerularFiltrationCoefficient = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularFiltrationCoefficient.axisY.label, renal.axisX, renal.requests.leftGlomerularFiltrationCoefficient.axisY);
    renal.requests.leftGlomerularFiltrationCoefficient.axisY = renal.axisY(renal.requests.leftGlomerularFiltrationCoefficient)

    renal.requests.leftGlomerularFiltrationRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularFiltrationRate.axisY.label, renal.axisX, renal.requests.leftGlomerularFiltrationRate.axisY);
    renal.requests.leftGlomerularFiltrationRate.axisY = renal.axisY(renal.requests.leftGlomerularFiltrationRate)

    renal.requests.leftGlomerularFiltrationSurfaceArea = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularFiltrationSurfaceArea.axisY.label, renal.axisX, renal.requests.leftGlomerularFiltrationSurfaceArea.axisY);
    renal.requests.leftGlomerularFiltrationSurfaceArea.axisY = renal.axisY(renal.requests.leftGlomerularFiltrationSurfaceArea)

    renal.requests.leftGlomerularFluidPermeability = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularFluidPermeability.axisY.label, renal.axisX, renal.requests.leftGlomerularFluidPermeability.axisY);
    renal.requests.leftGlomerularFluidPermeability.axisY = renal.axisY(renal.requests.leftGlomerularFluidPermeability)

    renal.requests.leftFiltrationFraction = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftFiltrationFraction.axisY.label, renal.axisX, renal.requests.leftFiltrationFraction.axisY);
    renal.requests.leftFiltrationFraction.axisY = renal.axisY(renal.requests.leftFiltrationFraction)

    renal.requests.leftNetFiltrationPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftNetFiltrationPressure.axisY.label, renal.axisX, renal.requests.leftNetFiltrationPressure.axisY);
    renal.requests.leftNetFiltrationPressure.axisY = renal.axisY(renal.requests.leftNetFiltrationPressure)

    renal.requests.leftNetReabsorptionPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftNetReabsorptionPressure.axisY.label, renal.axisX, renal.requests.leftNetReabsorptionPressure.axisY);
    renal.requests.leftNetReabsorptionPressure.axisY = renal.axisY(renal.requests.leftNetReabsorptionPressure)

    renal.requests.leftPeritubularCapillariesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftPeritubularCapillariesHydrostaticPressure.axisY.label, renal.axisX, renal.requests.leftPeritubularCapillariesHydrostaticPressure.axisY);
    renal.requests.leftPeritubularCapillariesHydrostaticPressure.axisY = renal.axisY(renal.requests.leftPeritubularCapillariesHydrostaticPressure)

    renal.requests.leftPeritubularCapillariesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftPeritubularCapillariesOsmoticPressure.axisY.label, renal.axisX, renal.requests.leftPeritubularCapillariesOsmoticPressure.axisY);
    renal.requests.leftPeritubularCapillariesOsmoticPressure.axisY = renal.axisY(renal.requests.leftPeritubularCapillariesOsmoticPressure)

    renal.requests.leftReabsorptionFiltrationCoefficient = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftReabsorptionFiltrationCoefficient.axisY.label, renal.axisX, renal.requests.leftReabsorptionFiltrationCoefficient.axisY);
    renal.requests.leftReabsorptionFiltrationCoefficient.axisY = renal.axisY(renal.requests.leftReabsorptionFiltrationCoefficient)

    renal.requests.leftReabsorptionRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftReabsorptionRate.axisY.label, renal.axisX, renal.requests.leftReabsorptionRate.axisY);
    renal.requests.leftReabsorptionRate.axisY = renal.axisY(renal.requests.leftReabsorptionRate)

    renal.requests.leftTubularReabsorptionFiltrationSurfaceArea = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.axisY.label, renal.axisX, renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.axisY);
    renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.axisY = renal.axisY(renal.requests.leftTubularReabsorptionFiltrationSurfaceArea)

    renal.requests.leftTubularReabsorptionFluidPermeability = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftTubularReabsorptionFluidPermeability.axisY.label, renal.axisX, renal.requests.leftTubularReabsorptionFluidPermeability.axisY);
    renal.requests.leftTubularReabsorptionFluidPermeability.axisY = renal.axisY(renal.requests.leftTubularReabsorptionFluidPermeability)

    renal.requests.leftTubularHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftTubularHydrostaticPressure.axisY.label, renal.axisX, renal.requests.leftTubularHydrostaticPressure.axisY);
    renal.requests.leftTubularHydrostaticPressure.axisY = renal.axisY(renal.requests.leftTubularHydrostaticPressure)

    renal.requests.leftTubularOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftTubularOsmoticPressure.axisY.label, renal.axisX, renal.requests.leftTubularOsmoticPressure.axisY);
    renal.requests.leftTubularOsmoticPressure.axisY = renal.axisY(renal.requests.leftTubularOsmoticPressure)

    renal.requests.renalBloodFlow = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.renalBloodFlow.axisY.label, renal.axisX, renal.requests.renalBloodFlow.axisY);
    renal.requests.renalBloodFlow.axisY = renal.axisY(renal.requests.renalBloodFlow)

    renal.requests.renalPlasmaFlow = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.renalPlasmaFlow.axisY.label, renal.axisX, renal.requests.renalPlasmaFlow.axisY);
    renal.requests.renalPlasmaFlow.axisY = renal.axisY(renal.requests.renalPlasmaFlow)

    renal.requests.renalVascularResistance = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.renalVascularResistance.axisY.label, renal.axisX, renal.requests.renalVascularResistance.axisY);
    renal.requests.renalVascularResistance.axisY = renal.axisY(renal.requests.renalVascularResistance)

    renal.requests.rightAfferentArterioleResistance = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightAfferentArterioleResistance.axisY.label, renal.axisX, renal.requests.rightAfferentArterioleResistance.axisY);
    renal.requests.rightAfferentArterioleResistance.axisY = renal.axisY(renal.requests.rightAfferentArterioleResistance)

    renal.requests.rightBowmansCapsulesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightBowmansCapsulesHydrostaticPressure.axisY.label, renal.axisX, renal.requests.rightBowmansCapsulesHydrostaticPressure.axisY);
    renal.requests.rightBowmansCapsulesHydrostaticPressure.axisY = renal.axisY(renal.requests.rightBowmansCapsulesHydrostaticPressure)

    renal.requests.rightBowmansCapsulesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightBowmansCapsulesOsmoticPressure.axisY.label, renal.axisX, renal.requests.rightBowmansCapsulesOsmoticPressure.axisY);
    renal.requests.rightBowmansCapsulesOsmoticPressure.axisY = renal.axisY(renal.requests.rightBowmansCapsulesOsmoticPressure)

    renal.requests.rightEfferentArterioleResistance = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightEfferentArterioleResistance.axisY.label, renal.axisX, renal.requests.rightEfferentArterioleResistance.axisY);
    renal.requests.rightEfferentArterioleResistance.axisY = renal.axisY(renal.requests.rightEfferentArterioleResistance)

    renal.requests.rightGlomerularCapillariesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularCapillariesHydrostaticPressure.axisY.label, renal.axisX, renal.requests.rightGlomerularCapillariesHydrostaticPressure.axisY);
    renal.requests.rightGlomerularCapillariesHydrostaticPressure.axisY = renal.axisY(renal.requests.rightGlomerularCapillariesHydrostaticPressure)

    renal.requests.rightGlomerularCapillariesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularCapillariesOsmoticPressure.axisY.label, renal.axisX, renal.requests.rightGlomerularCapillariesOsmoticPressure.axisY);
    renal.requests.rightGlomerularCapillariesOsmoticPressure.axisY = renal.axisY(renal.requests.rightGlomerularCapillariesOsmoticPressure)

    renal.requests.rightGlomerularFiltrationCoefficient = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularFiltrationCoefficient.axisY.label, renal.axisX, renal.requests.rightGlomerularFiltrationCoefficient.axisY);
    renal.requests.rightGlomerularFiltrationCoefficient.axisY = renal.axisY(renal.requests.rightGlomerularFiltrationCoefficient)

    renal.requests.rightGlomerularFiltrationRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularFiltrationRate.axisY.label, renal.axisX, renal.requests.rightGlomerularFiltrationRate.axisY);
    renal.requests.rightGlomerularFiltrationRate.axisY = renal.axisY(renal.requests.rightGlomerularFiltrationRate)

    renal.requests.rightGlomerularFiltrationSurfaceArea = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularFiltrationSurfaceArea.axisY.label, renal.axisX, renal.requests.rightGlomerularFiltrationSurfaceArea.axisY);
    renal.requests.rightGlomerularFiltrationSurfaceArea.axisY = renal.axisY(renal.requests.rightGlomerularFiltrationSurfaceArea)

    renal.requests.rightGlomerularFluidPermeability = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularFluidPermeability.axisY.label, renal.axisX, renal.requests.rightGlomerularFluidPermeability.axisY);
    renal.requests.rightGlomerularFluidPermeability.axisY = renal.axisY(renal.requests.rightGlomerularFluidPermeability)

    renal.requests.rightFiltrationFraction = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightFiltrationFraction.axisY.label, renal.axisX, renal.requests.rightFiltrationFraction.axisY);
    renal.requests.rightFiltrationFraction.axisY = renal.axisY(renal.requests.rightFiltrationFraction)

    renal.requests.rightNetFiltrationPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightNetFiltrationPressure.axisY.label, renal.axisX, renal.requests.rightNetFiltrationPressure.axisY);
    renal.requests.rightNetFiltrationPressure.axisY = renal.axisY(renal.requests.rightNetFiltrationPressure)

    renal.requests.rightNetReabsorptionPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightNetReabsorptionPressure.axisY.label, renal.axisX, renal.requests.rightNetReabsorptionPressure.axisY);
    renal.requests.rightNetReabsorptionPressure.axisY = renal.axisY(renal.requests.rightNetReabsorptionPressure)

    renal.requests.rightPeritubularCapillariesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightPeritubularCapillariesHydrostaticPressure.axisY.label, renal.axisX, renal.requests.rightPeritubularCapillariesHydrostaticPressure.axisY);
    renal.requests.rightPeritubularCapillariesHydrostaticPressure.axisY = renal.axisY(renal.requests.rightPeritubularCapillariesHydrostaticPressure)

    renal.requests.rightPeritubularCapillariesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightPeritubularCapillariesOsmoticPressure.axisY.label, renal.axisX, renal.requests.rightPeritubularCapillariesOsmoticPressure.axisY);
    renal.requests.rightPeritubularCapillariesOsmoticPressure.axisY = renal.axisY(renal.requests.rightPeritubularCapillariesOsmoticPressure)

    renal.requests.rightReabsorptionFiltrationCoefficient = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightReabsorptionFiltrationCoefficient.axisY.label, renal.axisX, renal.requests.rightReabsorptionFiltrationCoefficient.axisY);
    renal.requests.rightReabsorptionFiltrationCoefficient.axisY = renal.axisY(renal.requests.rightReabsorptionFiltrationCoefficient)

    renal.requests.rightReabsorptionRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightReabsorptionRate.axisY.label, renal.axisX, renal.requests.rightReabsorptionRate.axisY);
    renal.requests.rightReabsorptionRate.axisY = renal.axisY(renal.requests.rightReabsorptionRate)

    renal.requests.rightTubularReabsorptionFiltrationSurfaceArea = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.axisY.label, renal.axisX, renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.axisY);
    renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.axisY = renal.axisY(renal.requests.rightTubularReabsorptionFiltrationSurfaceArea)

    renal.requests.rightTubularReabsorptionFluidPermeability = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightTubularReabsorptionFluidPermeability.axisY.label, renal.axisX, renal.requests.rightTubularReabsorptionFluidPermeability.axisY);
    renal.requests.rightTubularReabsorptionFluidPermeability.axisY = renal.axisY(renal.requests.rightTubularReabsorptionFluidPermeability)

    renal.requests.rightTubularHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightTubularHydrostaticPressure.axisY.label, renal.axisX, renal.requests.rightTubularHydrostaticPressure.axisY);
    renal.requests.rightTubularHydrostaticPressure.axisY = renal.axisY(renal.requests.rightTubularHydrostaticPressure)

    renal.requests.rightTubularOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightTubularOsmoticPressure.axisY.label, renal.axisX, renal.requests.rightTubularOsmoticPressure.axisY);
    renal.requests.rightTubularOsmoticPressure.axisY = renal.axisY(renal.requests.rightTubularOsmoticPressure)

    renal.requests.urinationRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urinationRate.axisY.label, renal.axisX, renal.requests.urinationRate.axisY);
    renal.requests.urinationRate.axisY = renal.axisY(renal.requests.urinationRate)

    renal.requests.urineOsmolality = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineOsmolality.axisY.label, renal.axisX, renal.requests.urineOsmolality.axisY);
    renal.requests.urineOsmolality.axisY = renal.axisY(renal.requests.urineOsmolality)

    renal.requests.urineOsmolarity = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineOsmolarity.axisY.label, renal.axisX, renal.requests.urineOsmolarity.axisY);
    renal.requests.urineOsmolarity.axisY = renal.axisY(renal.requests.urineOsmolarity)

    renal.requests.urineProductionRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineProductionRate.axisY.label, renal.axisX, renal.requests.urineProductionRate.axisY);
    renal.requests.urineProductionRate.axisY = renal.axisY(renal.requests.urineProductionRate)

    renal.requests.meanUrineOutput = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.meanUrineOutput.axisY.label, renal.axisX, renal.requests.meanUrineOutput.axisY);
    renal.requests.meanUrineOutput.axisY = renal.axisY(renal.requests.meanUrineOutput)

    renal.requests.urineSpecificGravity = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineSpecificGravity.axisY.label, renal.axisX, renal.requests.urineSpecificGravity.axisY);
    renal.requests.urineSpecificGravity.axisY = renal.axisY(renal.requests.urineSpecificGravity)

    renal.requests.urineVolume = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineVolume.axisY.label, renal.axisX, renal.requests.urineVolume.axisY);
    renal.requests.urineVolume.axisY = renal.axisY(renal.requests.urineVolume)

    renal.requests.urineUreaNitrogenConcentration = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineUreaNitrogenConcentration.axisY.label, renal.axisX, renal.requests.urineUreaNitrogenConcentration.axisY);
    renal.requests.urineUreaNitrogenConcentration.axisY = renal.axisY(renal.requests.urineUreaNitrogenConcentration)
  }
  function setupRespiratory(){
    respiratory.requests.alveolarArterialGradient = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.alveolarArterialGradient.axisY.label, respiratory.axisX, respiratory.requests.alveolarArterialGradient.axisY);
    respiratory.requests.alveolarArterialGradient.axisY = respiratory.axisY(respiratory.requests.alveolarArterialGradient)

    respiratory.requests.carricoIndex = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.carricoIndex.axisY.label, respiratory.axisX, respiratory.requests.carricoIndex.axisY);
    respiratory.requests.carricoIndex.axisY = respiratory.axisY(respiratory.requests.carricoIndex)

    respiratory.requests.endTidalCarbonDioxideFraction = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.endTidalCarbonDioxideFraction.axisY.label, respiratory.axisX, respiratory.requests.endTidalCarbonDioxideFraction.axisY);
    respiratory.requests.endTidalCarbonDioxideFraction.axisY = respiratory.axisY(respiratory.requests.endTidalCarbonDioxideFraction)

    respiratory.requests.endTidalCarbonDioxidePressure = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.endTidalCarbonDioxidePressure.axisY.label, respiratory.axisX, respiratory.requests.endTidalCarbonDioxidePressure.axisY);
    respiratory.requests.endTidalCarbonDioxidePressure.axisY = respiratory.axisY(respiratory.requests.endTidalCarbonDioxidePressure)

    respiratory.requests.expiratoryFlow = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.expiratoryFlow.axisY.label, respiratory.axisX, respiratory.requests.expiratoryFlow.axisY);
    respiratory.requests.expiratoryFlow.axisY = respiratory.axisY(respiratory.requests.expiratoryFlow)

    respiratory.requests.inspiratoryExpiratoryRatio = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.inspiratoryExpiratoryRatio.axisY.label, respiratory.axisX, respiratory.requests.inspiratoryExpiratoryRatio.axisY);
    respiratory.requests.inspiratoryExpiratoryRatio.axisY = respiratory.axisY(respiratory.requests.inspiratoryExpiratoryRatio)

    respiratory.requests.inspiratoryFlow = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.inspiratoryFlow.axisY.label, respiratory.axisX, respiratory.requests.inspiratoryFlow.axisY);
    respiratory.requests.inspiratoryFlow.axisY = respiratory.axisY(respiratory.requests.inspiratoryFlow)

    respiratory.requests.pulmonaryCompliance = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.pulmonaryCompliance.axisY.label, respiratory.axisX, respiratory.requests.pulmonaryCompliance.axisY);
    respiratory.requests.pulmonaryCompliance.axisY = respiratory.axisY(respiratory.requests.pulmonaryCompliance)

    respiratory.requests.pulmonaryResistance = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.pulmonaryResistance.axisY.label, respiratory.axisX, respiratory.requests.pulmonaryResistance.axisY);
    respiratory.requests.pulmonaryResistance.axisY = respiratory.axisY(respiratory.requests.pulmonaryResistance)

    respiratory.requests.respirationDriverPressure = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.respirationDriverPressure.axisY.label, respiratory.axisX, respiratory.requests.respirationDriverPressure.axisY);
    respiratory.requests.respirationDriverPressure.axisY = respiratory.axisY(respiratory.requests.respirationDriverPressure)

    respiratory.requests.respirationMusclePressure = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.respirationMusclePressure.axisY.label, respiratory.axisX, respiratory.requests.respirationMusclePressure.axisY);
    respiratory.requests.respirationMusclePressure.axisY = respiratory.axisY(respiratory.requests.respirationMusclePressure)

    respiratory.requests.respirationRate = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.respirationRate.axisY.label, respiratory.axisX, respiratory.requests.respirationRate.axisY);
    respiratory.requests.respirationRate.axisY = respiratory.axisY(respiratory.requests.respirationRate)

    respiratory.requests.specificVentilation = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.specificVentilation.axisY.label, respiratory.axisX, respiratory.requests.specificVentilation.axisY);
    respiratory.requests.specificVentilation.axisY = respiratory.axisY(respiratory.requests.specificVentilation)

    respiratory.requests.targetPulmonaryVentilation = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.targetPulmonaryVentilation.axisY.label, respiratory.axisX, respiratory.requests.targetPulmonaryVentilation.axisY);
    respiratory.requests.targetPulmonaryVentilation.axisY = respiratory.axisY(respiratory.requests.targetPulmonaryVentilation)

    respiratory.requests.tidalVolume = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.tidalVolume.axisY.label, respiratory.axisX, respiratory.requests.tidalVolume.axisY);
    respiratory.requests.tidalVolume.axisY = respiratory.axisY(respiratory.requests.tidalVolume)

    respiratory.requests.totalAlveolarVentilation = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.totalAlveolarVentilation.axisY.label, respiratory.axisX, respiratory.requests.totalAlveolarVentilation.axisY);
    respiratory.requests.totalAlveolarVentilation.axisY = respiratory.axisY(respiratory.requests.totalAlveolarVentilation)

    respiratory.requests.totalDeadSpaceVentilation = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.totalDeadSpaceVentilation.axisY.label, respiratory.axisX, respiratory.requests.totalDeadSpaceVentilation.axisY);
    respiratory.requests.totalDeadSpaceVentilation.axisY = respiratory.axisY(respiratory.requests.totalDeadSpaceVentilation)

    respiratory.requests.totalLungVolume = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.totalLungVolume.axisY.label, respiratory.axisX, respiratory.requests.totalLungVolume.axisY);
    respiratory.requests.totalLungVolume.axisY = respiratory.axisY(respiratory.requests.totalLungVolume)

    respiratory.requests.totalPulmonaryVentilation = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.totalPulmonaryVentilation.axisY.label, respiratory.axisX, respiratory.requests.totalPulmonaryVentilation.axisY);
    respiratory.requests.totalPulmonaryVentilation.axisY = respiratory.axisY(respiratory.requests.totalPulmonaryVentilation)

    respiratory.requests.transpulmonaryPressure = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.transpulmonaryPressure.axisY.label, respiratory.axisX, respiratory.requests.transpulmonaryPressure.axisY);
    respiratory.requests.transpulmonaryPressure.axisY = respiratory.axisY(respiratory.requests.transpulmonaryPressure)
  }
  function setupTissue(){
    tissue.requests.carbonDioxideProductionRate = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.carbonDioxideProductionRate.axisY.label, tissue.axisX, tissue.requests.carbonDioxideProductionRate.axisY);
    tissue.requests.carbonDioxideProductionRate.axisY = tissue.axisY(tissue.requests.carbonDioxideProductionRate)

    tissue.requests.dehydrationFraction = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.dehydrationFraction.axisY.label, tissue.axisX, tissue.requests.dehydrationFraction.axisY);
    tissue.requests.dehydrationFraction.axisY = tissue.axisY(tissue.requests.dehydrationFraction)

    tissue.requests.extracellularFluidVolume = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.extracellularFluidVolume.axisY.label, tissue.axisX, tissue.requests.extracellularFluidVolume.axisY);
    tissue.requests.extracellularFluidVolume.axisY = tissue.axisY(tissue.requests.extracellularFluidVolume)

    tissue.requests.extravascularFluidVolume = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.extravascularFluidVolume.axisY.label, tissue.axisX, tissue.requests.extravascularFluidVolume.axisY);
    tissue.requests.extravascularFluidVolume.axisY = tissue.axisY(tissue.requests.extravascularFluidVolume)

    tissue.requests.intracellularFluidPH = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.intracellularFluidPH.axisY.label, tissue.axisX, tissue.requests.intracellularFluidPH.axisY);
    tissue.requests.intracellularFluidPH.axisY = tissue.axisY(tissue.requests.intracellularFluidPH)

    tissue.requests.intracellularFluidVolume = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.intracellularFluidVolume.axisY.label, tissue.axisX, tissue.requests.intracellularFluidVolume.axisY);
    tissue.requests.intracellularFluidVolume.axisY = tissue.axisY(tissue.requests.intracellularFluidVolume)

    tissue.requests.totalBodyFluidVolume = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.totalBodyFluidVolume.axisY.label, tissue.axisX, tissue.requests.totalBodyFluidVolume.axisY);
    tissue.requests.totalBodyFluidVolume.axisY = tissue.axisY(tissue.requests.totalBodyFluidVolume)

    tissue.requests.oxygenConsumptionRate = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.oxygenConsumptionRate.axisY.label, tissue.axisX, tissue.requests.oxygenConsumptionRate.axisY);
    tissue.requests.oxygenConsumptionRate.axisY = tissue.axisY(tissue.requests.oxygenConsumptionRate)

    tissue.requests.respiratoryExchangeRatio = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.respiratoryExchangeRatio.axisY.label, tissue.axisX, tissue.requests.respiratoryExchangeRatio.axisY);
    tissue.requests.respiratoryExchangeRatio.axisY = tissue.axisY(tissue.requests.respiratoryExchangeRatio)

    tissue.requests.liverInsulinSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.liverInsulinSetPoint.axisY.label, tissue.axisX, tissue.requests.liverInsulinSetPoint.axisY);
    tissue.requests.liverInsulinSetPoint.axisY = tissue.axisY(tissue.requests.liverInsulinSetPoint)

    tissue.requests.liverGlucagonSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.liverGlucagonSetPoint.axisY.label, tissue.axisX, tissue.requests.liverGlucagonSetPoint.axisY);
    tissue.requests.liverGlucagonSetPoint.axisY = tissue.axisY(tissue.requests.liverGlucagonSetPoint)

    tissue.requests.muscleInsulinSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.muscleInsulinSetPoint.axisY.label, tissue.axisX, tissue.requests.muscleInsulinSetPoint.axisY);
    tissue.requests.muscleInsulinSetPoint.axisY = tissue.axisY(tissue.requests.muscleInsulinSetPoint)

    tissue.requests.muscleGlucagonSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.muscleGlucagonSetPoint.axisY.label, tissue.axisX, tissue.requests.muscleGlucagonSetPoint.axisY);
    tissue.requests.muscleGlucagonSetPoint.axisY = tissue.axisY(tissue.requests.muscleGlucagonSetPoint)

    tissue.requests.fatInsulinSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.fatInsulinSetPoint.axisY.label, tissue.axisX, tissue.requests.fatInsulinSetPoint.axisY);
    tissue.requests.fatInsulinSetPoint.axisY = tissue.axisY(tissue.requests.fatInsulinSetPoint)

    tissue.requests.fatGlucagonSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.fatGlucagonSetPoint.axisY.label, tissue.axisX, tissue.requests.fatGlucagonSetPoint.axisY);
    tissue.requests.fatGlucagonSetPoint.axisY = tissue.axisY(tissue.requests.fatGlucagonSetPoint)

    tissue.requests.liverGlycogen = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.liverGlycogen.axisY.label, tissue.axisX, tissue.requests.liverGlycogen.axisY);
    tissue.requests.liverGlycogen.axisY = tissue.axisY(tissue.requests.liverGlycogen)

    tissue.requests.muscleGlycogen = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.muscleGlycogen.axisY.label, tissue.axisX, tissue.requests.muscleGlycogen.axisY);
    tissue.requests.muscleGlycogen.axisY = tissue.axisY(tissue.requests.muscleGlycogen)

    tissue.requests.storedProtein = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.storedProtein.axisY.label, tissue.axisX, tissue.requests.storedProtein.axisY);
    tissue.requests.storedProtein.axisY = tissue.axisY(tissue.requests.storedProtein)

    tissue.requests.storedFat = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.storedFat.axisY.label, tissue.axisX, tissue.requests.storedFat.axisY);
    tissue.requests.storedFat.axisY = tissue.axisY(tissue.requests.storedFat)
  }
}
