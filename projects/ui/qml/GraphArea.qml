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
    // var bc_requests = physiologyRequestModel.get(0).requests
    // for ( var i = 0; i < bc_requests.count; ++i){
    //    toggleBloodChemistrySeries(bc_requests.get(i).request, bc_requests.get(i).active)
    // }
    // var cardiovascular = physiologyRequestModel.get(1).requests
    // for ( var i = 0; i < cardiovascular.count; ++i){
    //    toggleCardiovascularSeries(cardiovascular.get(i).request, cardiovascular.get(i).active)
    // }
    // var drugs = physiologyRequestModel.get(2).requests
    // for ( var i = 0; i < drugs.count; ++i){
    //    toggleDrugsSeries(drugs.get(i).request, drugs.get(i).active)
    // }
    // var endocrine = physiologyRequestModel.get(3).requests
    // for ( var i = 0; i < endocrine.count; ++i){
    //    toggleEndocrineSeries(endocrine.get(i).request, endocrine.get(i).active)
    // }
    // var energy = physiologyRequestModel.get(4).requests
    // for ( var i = 0; i < energy.count; ++i){
    //    toggleEnergySeries(energy.get(i).request, energy.get(i).active)
    // }
    // var gastrointestinal = physiologyRequestModel.get(5).requests
    // for ( var i = 0; i < gastrointestinal.count; ++i){
    //    toggleGastrointestinalSeries(gastrointestinal.get(i).request, gastrointestinal.get(i).active)
    // }
    // var hepatic = physiologyRequestModel.get(6).requests
    // for ( var i = 0; i < hepatic.count; ++i){
    //    toggleHepaticSeries(hepatic.get(i).request, hepatic.get(i).active)
    // }
    // var nervous = physiologyRequestModel.get(7).requests
    // for ( var i = 0; i < nervous.count; ++i){
    //    toggleNervousSeries(nervous.get(i).request, nervous.get(i).active)
    // }
    // var renal = physiologyRequestModel.get(8).requests
    // for ( var i = 0; i < renal.count; ++i){
    //    toggleRenalSeries(renal.get(i).request, renal.get(i).active)
    // }
    // var respiratory = physiologyRequestModel.get(9).requests
    // for ( var i = 0; i < respiratory.count; ++i){
    //    toggleRespiratorySeries(respiratory.get(i).request, respiratory.get(i).active)
    // }
    // var tissue = physiologyRequestModel.get(10).requests
    // for ( var i = 0; i < tissue.count; ++i){
    //    toggleTissueSeries(tissue.get(i).request, tissue.get(i).active)
    // }
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
    updateDomain(bloodChemistry.axisX)
    var bc_requests = physiologyRequestModel.get(0).requests
    if(bc_requests.get(0).active){
      bloodChemistry.requests.arterialBloodPH.append(metrics.simulationTime,metrics.arterialBloodPH)
    }
    if(bc_requests.get(1).active){
      bloodChemistry.requests.arterialBloodPHBaseline.append(metrics.simulationTime,metrics.arterialBloodPHBaseline)
    }
    if(bc_requests.get(2).active){
      bloodChemistry.requests.bloodDensity.append(metrics.simulationTime,metrics.bloodDensity)
    }
    if(bc_requests.get(3).active){
      bloodChemistry.requests.bloodSpecificHeat.append(metrics.simulationTime,metrics.bloodSpecificHeat)
    }
    if(bc_requests.get(4).active){
      bloodChemistry.requests.bloodUreaNitrogenConcentration.append(metrics.simulationTime,metrics.bloodUreaNitrogenConcentration)
    }
    if(bc_requests.get(5).active){
      bloodChemistry.requests.carbonDioxideSaturation.append(metrics.simulationTime,metrics.carbonDioxideSaturation)
    }
    if(bc_requests.get(6).active){
      bloodChemistry.requests.carbonMonoxideSaturation.append(metrics.simulationTime,metrics.carbonMonoxideSaturation)
    }
    if(bc_requests.get(7).active){
      bloodChemistry.requests.hematocrit.append(metrics.simulationTime,metrics.hematocrit)
    }
    if(bc_requests.get(8).active){
      bloodChemistry.requests.hemoglobinContent.append(metrics.simulationTime,metrics.hemoglobinContent)
    }
    if(bc_requests.get(9).active){
      bloodChemistry.requests.oxygenSaturation.append(metrics.simulationTime,metrics.oxygenSaturation)
    }
    if(bc_requests.get(10).active){
      bloodChemistry.requests.phosphate.append(metrics.simulationTime,metrics.phosphate)
    }
    if(bc_requests.get(11).active){
      bloodChemistry.requests.plasmaVolume.append(metrics.simulationTime,metrics.plasmaVolume)
    }
    if(bc_requests.get(12).active){
      bloodChemistry.requests.pulseOximetry.append(metrics.simulationTime,metrics.pulseOximetry)
    }
    if(bc_requests.get(13).active){
      bloodChemistry.requests.redBloodCellAcetylcholinesterase.append(metrics.simulationTime,metrics.redBloodCellAcetylcholinesterase)
    }
    if(bc_requests.get(14).active){
      bloodChemistry.requests.redBloodCellCount.append(metrics.simulationTime,metrics.redBloodCellCount)
    }
    if(bc_requests.get(15).active){
      bloodChemistry.requests.shuntFraction.append(metrics.simulationTime,metrics.shuntFraction)
    }
    if(bc_requests.get(16).active){
      bloodChemistry.requests.strongIonDifference.append(metrics.simulationTime,metrics.strongIonDifference)
    }
    if(bc_requests.get(17).active){
      bloodChemistry.requests.totalBilirubin.append(metrics.simulationTime,metrics.totalBilirubin)
    }
    if(bc_requests.get(18).active){
      bloodChemistry.requests.totalProteinConcentration.append(metrics.simulationTime,metrics.totalProteinConcentration)
    }
    if(bc_requests.get(19).active){
      bloodChemistry.requests.venousBloodPH.append(metrics.simulationTime,metrics.venousBloodPH)
    }
    if(bc_requests.get(20).active){
      bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.append(metrics.simulationTime,metrics.volumeFractionNeutralPhospholipidInPlasma)
    }
    if(bc_requests.get(21).active){
      bloodChemistry.re24quests.volumeFractionNeutralLipidInPlasma.append(metrics.simulationTime,metrics.volumeFractionNeutralLipidInPlasma)
    }
    if(bc_requests.get(22).active){
      bloodChemistry.requests.arterialCarbonDioxidePressure.append(metrics.simulationTime,metrics.arterialCarbonDioxidePressure)
    }
    if(bc_requests.get(23).active){
      bloodChemistry.requests.arterialOxygenPressure.append(metrics.simulationTime,metrics.arterialOxygenPressure)
    }
    if(bc_requests.get(24).active){
      bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.append(metrics.simulationTime,metrics.pulmonaryArterialCarbonDioxidePressure)
    }
    if(bc_requests.get(25).active){
      bloodChemistry.requests.pulmonaryArterialOxygenPressure.append(metrics.simulationTime,metrics.pulmonaryArterialOxygenPressure)
    }
    if(bc_requests.get(26).active){
      bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.append(metrics.simulationTime,metrics.pulmonaryVenousCarbonDioxidePressure)
    }
    if(bc_requests.get(27).active){
      bloodChemistry.requests.pulmonaryVenousOxygenPressure.append(metrics.simulationTime,metrics.pulmonaryVenousOxygenPressure)
    }
    if(bc_requests.get(28).active){
      bloodChemistry.requests.venousCarbonDioxidePressure.append(metrics.simulationTime,metrics.venousCarbonDioxidePressure)
    }
    if(bc_requests.get(29).active){
      bloodChemistry.requests.venousOxygenPressure.append(metrics.simulationTime,metrics.venousOxygenPressure)
    }
    if(bc_requests.get(30).active){
      bloodChemistry.requests.inflammatoryResponse.append(metrics.simulationTime,metrics.inflammatoryResponse)
    }
    if(bc_requests.get(31).active){
      bloodChemistry.requests.inflammatoryResponseLocalPathogen.append(metrics.simulationTime,metrics.inflammatoryResponseLocalPathogen)
    }
    if(bc_requests.get(32).active){
      bloodChemistry.requests.inflammatoryResponseLocalMacrophage.append(metrics.simulationTime,metrics.inflammatoryResponseLocalMacrophage)
    }
    if(bc_requests.get(33).active){
      bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.append(metrics.simulationTime,metrics.inflammatoryResponseLocalNeutrophil)
    }
    if(bc_requests.get(34).active){
      bloodChemistry.requests.inflammatoryResponseLocalBarrier.append(metrics.simulationTime,metrics.inflammatoryResponseLocalBarrier)
    }
    if(bc_requests.get(35).active){
      bloodChemistry.requests.inflammatoryResponseBloodPathogen.append(metrics.simulationTime,metrics.inflammatoryResponseBloodPathogen)
    }
    if(bc_requests.get(36).active){
      bloodChemistry.requests.inflammatoryResponseTrauma.append(metrics.simulationTime,metrics.inflammatoryResponseTrauma)
    }
    if(bc_requests.get(37).active){
      bloodChemistry.requests.inflammatoryResponseMacrophageResting.append(metrics.simulationTime,metrics.inflammatoryResponseMacrophageResting)
    }
    if(bc_requests.get(38).active){
      bloodChemistry.requests.inflammatoryResponseMacrophageActive.append(metrics.simulationTime,metrics.inflammatoryResponseMacrophageActive)
    }
    if(bc_requests.get(39).active){
      bloodChemistry.requests.inflammatoryResponseNeutrophilResting.append(metrics.simulationTime,metrics.inflammatoryResponseNeutrophilResting)
    }
    if(bc_requests.get(40).active){
      bloodChemistry.requests.inflammatoryResponseNeutrophilActive.append(metrics.simulationTime,metrics.inflammatoryResponseNeutrophilActive)
    }
    if(bc_requests.get(41).active){
      bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.append(metrics.simulationTime,metrics.inflammatoryResponseInducibleNOSPre)
    }
    if(bc_requests.get(42).active){
      bloodChemistry.requests.inflammatoryResponseInducibleNOS.append(metrics.simulationTime,metrics.inflammatoryResponseInducibleNOS)
    }
    if(bc_requests.get(43).active){
      bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.append(metrics.simulationTime,metrics.inflammatoryResponseConstitutiveNOS)
    }
    if(bc_requests.get(44).active){
      bloodChemistry.requests.inflammatoryResponseNitrate.append(metrics.simulationTime,metrics.inflammatoryResponseNitrate)
    }
    if(bc_requests.get(45).active){
      bloodChemistry.requests.inflammatoryResponseNitricOxide.append(metrics.simulationTime,metrics.inflammatoryResponseNitricOxide)
    }
    if(bc_requests.get(46).active){
      bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.append(metrics.simulationTime,metrics.inflammatoryResponseTumorNecrosisFactor)
    }
    if(bc_requests.get(47).active){
      bloodChemistry.requests.inflammatoryResponseInterleukin6.append(metrics.simulationTime,metrics.inflammatoryResponseInterleukin6)
    }
    if(bc_requests.get(48).active){
      bloodChemistry.requests.inflammatoryResponseInterleukin148.append(metrics.simulationTime,metrics.inflammatoryResponseInterleukin149)
    }
    if(bc_requests.get(49).active){
      bloodChemistry.requests.inflammatoryResponseInterleukin12.append(metrics.simulationTime,metrics.inflammatoryResponseInterleukin12)
    }
    if(bc_requests.get(50).active){
      bloodChemistry.requests.inflammatoryResponseCatecholamines.append(metrics.simulationTime,metrics.inflammatoryResponseCatecholamines)
    }
    if(bc_requests.get(51).active){
      bloodChemistry.requests.inflammatoryResponseTissueIntegrity.append(metrics.simulationTime,metrics.inflammatoryResponseTissueIntegrity)
    }
  }
  function updateCardiovascular(metrics){
    updateDomain(cardiovascular.axisX)
    var cv_requests = physiologyRequestModel.get(1).requests
    if(cv_requests.get(0).active){
      cardiovascular.requests.arterialPressure.append(metrics.simulationTime,metrics.arterialPressure)
    }
    if(cv_requests.get(1).active){
      cardiovascular.requests.bloodVolume.append(metrics.simulationTime,metrics.bloodVolume)
    }
    if(cv_requests.get(2).active){
      cardiovascular.requests.cardiacIndex.append(metrics.simulationTime,metrics.cardiacIndex)
    }
    if(cv_requests.get(3).active){
      cardiovascular.requests.cardiacOutput.append(metrics.simulationTime,metrics.cardiacOutput)
    }
    if(cv_requests.get(4).active){
      cardiovascular.requests.centralVenousPressure.append(metrics.simulationTime,metrics.centralVenousPressure)
    }
    if(cv_requests.get(5).active){
      cardiovascular.requests.cerebralBloodFlow.append(metrics.simulationTime,metrics.cerebralBloodFlow)
    }
    if(cv_requests.get(6).active){
      cardiovascular.requests.cerebralPerfusionPressure.append(metrics.simulationTime,metrics.cerebralPerfusionPressure)
    }
    if(cv_requests.get(7).active){
      cardiovascular.requests.diastolicArterialPressure.append(metrics.simulationTime,metrics.diastolicArterialPressure)
    }
    if(cv_requests.get(8).active){
      cardiovascular.requests.heartEjectionFraction.append(metrics.simulationTime,metrics.heartEjectionFraction)
    }
    if(cv_requests.get(9).active){
      cardiovascular.requests.heartRate.append(metrics.simulationTime,metrics.heartRate)
    }
    if(cv_requests.get(10).active){
      cardiovascular.requests.heartStrokeVolume.append(metrics.simulationTime,metrics.heartStrokeVolume)
    }
    if(cv_requests.get(11).active){
      cardiovascular.requests.intracranialPressure.append(metrics.simulationTime,metrics.intracranialPressure)
    }
    if(cv_requests.get(12).active){
      cardiovascular.requests.meanArterialPressure.append(metrics.simulationTime,metrics.meanArterialPressure)
    }
    if(cv_requests.get(13).active){
      cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.append(metrics.simulationTime,metrics.meanArterialCarbonDioxidePartialPressure)
    }
    if(cv_requests.get(14).active){
      cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.append(metrics.simulationTime,metrics.meanArterialCarbonDioxidePartialPressureDelta)
    }
    if(cv_requests.get(15).active){
      cardiovascular.requests.meanCentralVenousPressure.append(metrics.simulationTime,metrics.meanCentralVenousPressure)
    }
    if(cv_requests.get(16).active){
      cardiovascular.requests.meanSkinFlow.append(metrics.simulationTime,metrics.meanSkinFlow)
    }
    if(cv_requests.get(17).active){
      cardiovascular.requests.pulmonaryArterialPressure.append(metrics.simulationTime,metrics.pulmonaryArterialPressure)
    }
    if(cv_requests.get(18).active){
      cardiovascular.requests.pulmonaryCapillariesWedgePressure.append(metrics.simulationTime,metrics.pulmonaryCapillariesWedgePressure)
    }
    if(cv_requests.get(19).active){
      cardiovascular.requests.pulmonaryDiastolicArterialPressure.append(metrics.simulationTime,metrics.pulmonaryDiastolicArterialPressure)
    }
    if(cv_requests.get(20).active){
      cardiovascular.requests.pulmonaryMeanArterialPressure.append(metrics.simulationTime,metrics.pulmonaryMeanArterialPressure)
    }
    if(cv_requests.get(21).active){
      cardiovascular.requests.pulmonaryMeanCapillaryFlow.append(metrics.simulationTime,metrics.pulmonaryMeanCapillaryFlow)
    }
    if(cv_requests.get(22).active){
      cardiovascular.requests.pulmonaryMeanShuntFlow.append(metrics.simulationTime,metrics.pulmonaryMeanShuntFlow)
    }
    if(cv_requests.get(23).active){
      cardiovascular.requests.pulmonarySystolicArterialPressure.append(metrics.simulationTime,metrics.pulmonarySystolicArterialPressure)
    }
    if(cv_requests.get(24).active){
      cardiovascular.requests.pulmonaryVascularResistance.append(metrics.simulationTime,metrics.pulmonaryVascularResistance)
    }
    if(cv_requests.get(25).active){
      cardiovascular.requests.pulmonaryVascularResistanceIndex.append(metrics.simulationTime,metrics.pulmonaryVascularResistanceIndex)
    }
    if(cv_requests.get(26).active){
      cardiovascular.requests.pulsePressure.append(metrics.simulationTime,metrics.pulsePressure)
    }
    if(cv_requests.get(27).active){
      cardiovascular.requests.systemicVascularResistance.append(metrics.simulationTime,metrics.systemicVascularResistance)
    }
    if(cv_requests.get(28).active){
      cardiovascular.requests.systolicArterialPressure.append(metrics.simulationTime,metrics.systolicArterialPressure)
    }
  }
  function updateDrugs(metrics){
    updateDomain(drugs.axisX)
    var d_requests = physiologyRequestModel.get(2).requests
  
    if(d_requests.get(0).active){
      drugs.requests.bronchodilationLevel.append(metrics.simulationTime,metrics.bronchodilationLevel)
    }
    if(d_requests.get(1).active){
      drugs.requests.heartRateChange.append(metrics.simulationTime,metrics.heartRateChange)
    }
    if(d_requests.get(2).active){
      drugs.requests.hemorrhageChange.append(metrics.simulationTime,metrics.hemorrhageChange)
    }
    if(d_requests.get(3).active){
      drugs.requests.meanBloodPressureChange.append(metrics.simulationTime,metrics.meanBloodPressureChange)
    }
    if(d_requests.get(4).active){
      drugs.requests.neuromuscularBlockLevel.append(metrics.simulationTime,metrics.neuromuscularBlockLevel)
    }
    if(d_requests.get(5).active){
      drugs.requests.pulsePressureChange.append(metrics.simulationTime,metrics.pulsePressureChange)
    }
    if(d_requests.get(6).active){
      drugs.requests.respirationRateChange.append(metrics.simulationTime,metrics.respirationRateChange)
    }
    if(d_requests.get(7).active){
      drugs.requests.sedationLevel.append(metrics.simulationTime,metrics.sedationLevel)
    }
    if(d_requests.get(8).active){
      drugs.requests.tidalVolumeChange.append(metrics.simulationTime,metrics.tidalVolumeChange)
    }
    if(d_requests.get(9).active){
      drugs.requests.tubularPermeabilityChange.append(metrics.simulationTime,metrics.tubularPermeabilityChange)
    }
    if(d_requests.get(10).active){
      drugs.requests.centralNervousResponse.append(metrics.simulationTime,metrics.centralNervousResponse)
    }
  }
  function updateEndocrine(metrics){
    updateDomain(endocrine.axisX)
    var end_requests = physiologyRequestModel.get(3).requests
    if(end_requests.get(0).active){
      endocrine.requests.insulinSynthesisRate.append(metrics.simulationTime,metrics.insulinSynthesisRate)
    }
    if(end_requests.get(1).active){
      endocrine.requests.glucagonSynthesisRate.append(metrics.simulationTime,metrics.glucagonSynthesisRate)
    }
  }
  function updateEnergy(metrics){
    updateDomain(energy.axisX)
    var en_requests = physiologyRequestModel.get(4).requests
  
    if(en_requests.get(0).active){
      energy.requests.achievedExerciseLevel.append(metrics.simulationTime,metrics.achievedExerciseLevel)
    }
    if(en_requests.get(1).active){
      energy.requests.chlorideLostToSweat.append(metrics.simulationTime,metrics.chlorideLostToSweat)
    }
    if(en_requests.get(2).active){
      energy.requests.coreTemperature.append(metrics.simulationTime,metrics.coreTemperature)
    }
    if(en_requests.get(3).active){
      energy.requests.creatinineProductionRate.append(metrics.simulationTime,metrics.creatinineProductionRate)
    }
    if(en_requests.get(4).active){
      energy.requests.exerciseMeanArterialPressureDelta.append(metrics.simulationTime,metrics.exerciseMeanArterialPressureDelta)
    }
    if(en_requests.get(5).active){
      energy.requests.fatigueLevel.append(metrics.simulationTime,metrics.fatigueLevel)
    }
    if(en_requests.get(6).active){
      energy.requests.lactateProductionRate.append(metrics.simulationTime,metrics.lactateProductionRate)
    }
    if(en_requests.get(7).active){
      energy.requests.potassiumLostToSweat.append(metrics.simulationTime,metrics.potassiumLostToSweat)
    }
    if(en_requests.get(8).active){
      energy.requests.skinTemperature.append(metrics.simulationTime,metrics.skinTemperature)
    }
    if(en_requests.get(9).active){
      energy.requests.sodiumLostToSweat.append(metrics.simulationTime,metrics.sodiumLostToSweat)
    }
    if(en_requests.get(10).active){
      energy.requests.sweatRate.append(metrics.simulationTime,metrics.sweatRate)
    }
    if(en_requests.get(11).active){
      energy.requests.totalMetabolicRate.append(metrics.simulationTime,metrics.totalMetabolicRate)
    }
    if(en_requests.get(12).active){
      energy.requests.totalWorkRateLevel.append(metrics.simulationTime,metrics.totalWorkRateLevel)
    }
  }
  function updateGastrointestinal(metrics){
    updateDomain(gastrointestinal.axisX)
    var gas_requests = physiologyRequestModel.get(5).requests
    
    if(gas_requests.get(0).active){
      gastrointestinal.requests.chymeAbsorptionRate.append(metrics.simulationTime,metrics.chymeAbsorptionRate)
    }
    if(gas_requests.get(1).active){
      gastrointestinal.requests.stomachContents_calcium.append(metrics.simulationTime,metrics.stomachContents_calcium)
    }
    if(gas_requests.get(2).active){
      gastrointestinal.requests.stomachContents_carbohydrates.append(metrics.simulationTime,metrics.stomachContents_carbohydrates)
    }
    if(gas_requests.get(3).active){
      gastrointestinal.requests.stomachContents_carbohydrateDigationRate.append(metrics.simulationTime,metrics.stomachContents_carbohydrateDigationRate)
    }
    if(gas_requests.get(4).active){
      gastrointestinal.requests.stomachContents_fat.append(metrics.simulationTime,metrics.stomachContents_fat)
    }
    if(gas_requests.get(5).active){
      gastrointestinal.requests.stomachContents_fatDigtationRate.append(metrics.simulationTime,metrics.stomachContents_fatDigtationRate)
    }
    if(gas_requests.get(6).active){
      gastrointestinal.requests.stomachContents_protien.append(metrics.simulationTime,metrics.stomachContents_protien)
    }
    if(gas_requests.get(7).active){
      gastrointestinal.requests.stomachContents_protienDigtationRate.append(metrics.simulationTime,metrics.stomachContents_protienDigtationRate)
    }
    if(gas_requests.get(8).active){
      gastrointestinal.requests.stomachContents_sodium.append(metrics.simulationTime,metrics.stomachContents_sodium)
    }
    if(gas_requests.get(9).active){
      gastrointestinal.requests.stomachContents_water.append(metrics.simulationTime,metrics.stomachContents_water)
    }
  }
  function updateHepatic(metrics){
    updateDomain(hepatic.axisX)
    var hp_requests = physiologyRequestModel.get(6).requests
    if(hp_requests.get(0).active){
      hepatic.requests.ketoneproductionRate.append(metrics.simulationTime,metrics.ketoneproductionRate)
    }
    if(hp_requests.get(1).active){
      hepatic.requests.hepaticGluconeogenesisRate.append(metrics.simulationTime,metrics.hepaticGluconeogenesisRate)
    }
  }
  function updateNervous(metrics){
    updateDomain(nervous.axisX)
    var nv_requests = physiologyRequestModel.get(7).requests
    
    if(nv_requests.get(0).active){
      nervous.requests.baroreceptorHeartRateScale.append(metrics.simulationTime,metrics.baroreceptorHeartRateScale)
    }
    if(nv_requests.get(1).active){
      nervous.requests.baroreceptorHeartElastanceScale.append(metrics.simulationTime,metrics.baroreceptorHeartElastanceScale)
    }
    if(nv_requests.get(2).active){
      nervous.requests.baroreceptorResistanceScale.append(metrics.simulationTime,metrics.baroreceptorResistanceScale)
    }
    if(nv_requests.get(3).active){
      nervous.requests.baroreceptorComplianceScale.append(metrics.simulationTime,metrics.baroreceptorComplianceScale)
    }
    if(nv_requests.get(4).active){
      nervous.requests.chemoreceptorHeartRateScale.append(metrics.simulationTime,metrics.chemoreceptorHeartRateScale)
    }
    if(nv_requests.get(5).active){
      nervous.requests.chemoreceptorHeartElastanceScale.append(metrics.simulationTime,metrics.chemoreceptorHeartElastanceScale)
    }
    if(nv_requests.get(6).active){
      nervous.requests.painVisualAnalogueScale.append(metrics.simulationTime,metrics.painVisualAnalogueScale)
    }
    if(nv_requests.get(7).active){
      nervous.requests.leftEyePupillaryResponse.append(metrics.simulationTime,metrics.leftEyePupillaryResponse)
    }
    if(nv_requests.get(8).active){
      nervous.requests.rightEyePupillaryResponse.append(metrics.simulationTime,metrics.rightEyePupillaryResponse)
    }
  }
  function updateRenal(metrics){
    updateDomain(renal.axisX)
    var rl_requests = physiologyRequestModel.get(8).requests
    
    if(rl_requests.get(0).active){
      renal.requests.glomerularFiltrationRate.append(metrics.simulationTime,metrics.glomerularFiltrationRate)
    }
    if(rl_requests.get(1).active){
      renal.requests.filtrationFraction.append(metrics.simulationTime,metrics.filtrationFraction)
    }
    if(rl_requests.get(2).active){
      renal.requests.leftAfferentArterioleResistance.append(metrics.simulationTime,metrics.leftAfferentArterioleResistance)
    }
    if(rl_requests.get(3).active){
      renal.requests.leftBowmansCapsulesHydrostaticPressure.append(metrics.simulationTime,metrics.leftBowmansCapsulesHydrostaticPressure)
    }
    if(rl_requests.get(4).active){
      renal.requests.leftBowmansCapsulesOsmoticPressure.append(metrics.simulationTime,metrics.leftBowmansCapsulesOsmoticPressure)
    }
    if(rl_requests.get(5).active){
      renal.requests.leftEfferentArterioleResistance.append(metrics.simulationTime,metrics.leftEfferentArterioleResistance)
    }
    if(rl_requests.get(6).active){
      renal.requests.leftGlomerularCapillariesHydrostaticPressure.append(metrics.simulationTime,metrics.leftGlomerularCapillariesHydrostaticPressure)
    }
    if(rl_requests.get(7).active){
      renal.requests.leftGlomerularCapillariesOsmoticPressure.append(metrics.simulationTime,metrics.leftGlomerularCapillariesOsmoticPressure)
    }
    if(rl_requests.get(8).active){
      renal.requests.leftGlomerularFiltrationCoefficient.append(metrics.simulationTime,metrics.leftGlomerularFiltrationCoefficient)
    }
    if(rl_requests.get(9).active){
      renal.requests.leftGlomerularFiltrationRate.append(metrics.simulationTime,metrics.leftGlomerularFiltrationRate)
    }
    if(rl_requests.get(10).active){
      renal.requests.leftGlomerularFiltrationSurfaceArea.append(metrics.simulationTime,metrics.leftGlomerularFiltrationSurfaceArea)
    }
    if(rl_requests.get(11).active){
      renal.requests.leftGlomerularFluidPermeability.append(metrics.simulationTime,metrics.leftGlomerularFluidPermeability)
    }
    if(rl_requests.get(12).active){
      renal.requests.leftFiltrationFraction.append(metrics.simulationTime,metrics.leftFiltrationFraction)
    }
    if(rl_requests.get(13).active){
      renal.requests.leftNetFiltrationPressure.append(metrics.simulationTime,metrics.leftNetFiltrationPressure)
    }
    if(rl_requests.get(14).active){
      renal.requests.leftNetReabsorptionPressure.append(metrics.simulationTime,metrics.leftNetReabsorptionPressure)
    }
    if(rl_requests.get(15).active){
      renal.requests.leftPeritubularCapillariesHydrostaticPressure.append(metrics.simulationTime,metrics.leftPeritubularCapillariesHydrostaticPressure)
    }
    if(rl_requests.get(16).active){
      renal.requests.leftPeritubularCapillariesOsmoticPressure.append(metrics.simulationTime,metrics.leftPeritubularCapillariesOsmoticPressure)
    }
    if(rl_requests.get(17).active){
      renal.requests.leftReabsorptionFiltrationCoefficient.append(metrics.simulationTime,metrics.leftReabsorptionFiltrationCoefficient)
    }
    if(rl_requests.get(18).active){
      renal.requests.leftReabsorptionRate.append(metrics.simulationTime,metrics.leftReabsorptionRate)
    }
    if(rl_requests.get(19).active){
      renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.append(metrics.simulationTime,metrics.leftTubularReabsorptionFiltrationSurfaceArea)
    }
    if(rl_requests.get(20).active){
      renal.requests.leftTubularReabsorptionFluidPermeability.append(metrics.simulationTime,metrics.leftTubularReabsorptionFluidPermeability)
    }
    if(rl_requests.get(21).active){
      renal.requests.leftTubularHydrostaticPressure.append(metrics.simulationTime,metrics.leftTubularHydrostaticPressure)
    }
    if(rl_requests.get(22).active){
      renal.requests.leftTubularOsmoticPressure.append(metrics.simulationTime,metrics.leftTubularOsmoticPressure)
    }
    if(rl_requests.get(23).active){
      renal.requests.renalBloodFlow.append(metrics.simulationTime,metrics.renalBloodFlow)
    }
    if(rl_requests.get(24).active){
      renal.requests.renalPlasmaFlow.append(metrics.simulationTime,metrics.renalPlasmaFlow)
    }
    if(rl_requests.get(25).active){
      renal.requests.renalVascularResistance.append(metrics.simulationTime,metrics.renalVascularResistance)
    }
    if(rl_requests.get(26).active){
      renal.requests.rightAfferentArterioleResistance.append(metrics.simulationTime,metrics.rightAfferentArterioleResistance)
    }
    if(rl_requests.get(27).active){
      renal.requests.rightBowmansCapsulesHydrostaticPressure.append(metrics.simulationTime,metrics.rightBowmansCapsulesHydrostaticPressure)
    }
    if(rl_requests.get(28).active){
      renal.requests.rightBowmansCapsulesOsmoticPressure.append(metrics.simulationTime,metrics.rightBowmansCapsulesOsmoticPressure)
    }
    if(rl_requests.get(29).active){
      renal.requests.rightEfferentArterioleResistance.append(metrics.simulationTime,metrics.rightEfferentArterioleResistance)
    }
    if(rl_requests.get(30).active){
      renal.requests.rightGlomerularCapillariesHydrostaticPressure.append(metrics.simulationTime,metrics.rightGlomerularCapillariesHydrostaticPressure)
    }
    if(rl_requests.get(31).active){
      renal.requests.rightGlomerularCapillariesOsmoticPressure.append(metrics.simulationTime,metrics.rightGlomerularCapillariesOsmoticPressure)
    }
    if(rl_requests.get(32).active){
      renal.requests.rightGlomerularFiltrationCoefficient.append(metrics.simulationTime,metrics.rightGlomerularFiltrationCoefficient)
    }
    if(rl_requests.get(33).active){
      renal.requests.rightGlomerularFiltrationRate.append(metrics.simulationTime,metrics.rightGlomerularFiltrationRate)
    }
    if(rl_requests.get(34).active){
      renal.requests.rightGlomerularFiltrationSurfaceArea.append(metrics.simulationTime,metrics.rightGlomerularFiltrationSurfaceArea)
    }
    if(rl_requests.get(35).active){
      renal.requests.rightGlomerularFluidPermeability.append(metrics.simulationTime,metrics.rightGlomerularFluidPermeability)
    }
    if(rl_requests.get(36).active){
      renal.requests.rightFiltrationFraction.append(metrics.simulationTime,metrics.rightFiltrationFraction)
    }
    if(rl_requests.get(37).active){
      renal.requests.rightNetFiltrationPressure.append(metrics.simulationTime,metrics.rightNetFiltrationPressure)
    }
    if(rl_requests.get(38).active){
      renal.requests.rightNetReabsorptionPressure.append(metrics.simulationTime,metrics.rightNetReabsorptionPressure)
    }
    if(rl_requests.get(39).active){
      renal.requests.rightPeritubularCapillariesHydrostaticPressure.append(metrics.simulationTime,metrics.rightPeritubularCapillariesHydrostaticPressure)
    }
    if(rl_requests.get(40).active){
      renal.requests.rightPeritubularCapillariesOsmoticPressure.append(metrics.simulationTime,metrics.rightPeritubularCapillariesOsmoticPressure)
    }
    if(rl_requests.get(41).active){
      renal.requests.rightReabsorptionFiltrationCoefficient.append(metrics.simulationTime,metrics.rightReabsorptionFiltrationCoefficient)
    }
    if(rl_requests.get(42).active){
      renal.requests.rightReabsorptionRate.append(metrics.simulationTime,metrics.rightReabsorptionRate)
    }
    if(rl_requests.get(43).active){
      renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.append(metrics.simulationTime,metrics.rightTubularReabsorptionFiltrationSurfaceArea)
    }
    if(rl_requests.get(44).active){
      renal.requests.rightTubularReabsorptionFluidPermeability.append(metrics.simulationTime,metrics.rightTubularReabsorptionFluidPermeability)
    }
    if(rl_requests.get(44).active){
      renal.requests.rightTubularHydrostaticPressure.append(metrics.simulationTime,metrics.rightTubularHydrostaticPressure)
    }
    if(rl_requests.get(45).active){
      renal.requests.rightTubularOsmoticPressure.append(metrics.simulationTime,metrics.rightTubularOsmoticPressure)
    }
    if(rl_requests.get(46).active){
      renal.requests.urinationRate.append(metrics.simulationTime,metrics.urinationRate)
    }
    if(rl_requests.get(47).active){
      renal.requests.urineOsmolality.append(metrics.simulationTime,metrics.urineOsmolality)
    }
    if(rl_requests.get(48).active){
      renal.requests.urineOsmolarity.append(metrics.simulationTime,metrics.urineOsmolarity)
    }
    if(rl_requests.get(49).active){
      renal.requests.urineProductionRate.append(metrics.simulationTime,metrics.urineProductionRate)
    }
    if(rl_requests.get(50).active){
      renal.requests.meanUrineOutput.append(metrics.simulationTime,metrics.meanUrineOutput)
    }
    if(rl_requests.get(52).active){
      renal.requests.urineSpecificGravity.append(metrics.simulationTime,metrics.urineSpecificGravity)
    }
    if(rl_requests.get(53).active){
      renal.requests.urineVolume.append(metrics.simulationTime,metrics.urineVolume)
    }
    if(rl_requests.get(54).active){
      renal.requests.urineUreaNitrogenConcentration.append(metrics.simulationTime,metrics.urineUreaNitrogenConcentration)
    }
  }
  function updateRespiratory(metrics){
    updateDomain(respiratory.axisX)
    var rsp_requests = physiologyRequestModel.get(9).requests
    
    if(rsp_requests.get(0).active){
      respiratory.requests.alveolarArterialGradient.append(metrics.simulationTime,metrics.alveolarArterialGradient)
    }
    if(rsp_requests.get(1).active){
      respiratory.requests.carricoIndex.append(metrics.simulationTime,metrics.carricoIndex)
    }
    if(rsp_requests.get(2).active){
      respiratory.requests.endTidalCarbonDioxideFraction.append(metrics.simulationTime,metrics.endTidalCarbonDioxideFraction)
    }
    if(rsp_requests.get(3).active){
      respiratory.requests.endTidalCarbonDioxidePressure.append(metrics.simulationTime,metrics.endTidalCarbonDioxidePressure)
    }
    if(rsp_requests.get(4).active){
      respiratory.requests.expiratoryFlow.append(metrics.simulationTime,metrics.expiratoryFlow)
    }
    if(rsp_requests.get(5).active){
      respiratory.requests.inspiratoryExpiratoryRatio.append(metrics.simulationTime,metrics.inspiratoryExpiratoryRatio)
    }
    if(rsp_requests.get(6).active){
      respiratory.requests.inspiratoryFlow.append(metrics.simulationTime,metrics.inspiratoryFlow)
    }
    if(rsp_requests.get(7).active){
      respiratory.requests.pulmonaryCompliance.append(metrics.simulationTime,metrics.pulmonaryCompliance)
    }
    if(rsp_requests.get(8).active){
      respiratory.requests.pulmonaryResistance.append(metrics.simulationTime,metrics.pulmonaryResistance)
    }
    if(rsp_requests.get(9).active){
      respiratory.requests.respirationDriverPressure.append(metrics.simulationTime,metrics.respirationDriverPressure)
    }
    if(rsp_requests.get(10).active){
      respiratory.requests.respirationMusclePressure.append(metrics.simulationTime,metrics.respirationMusclePressure)
    }
    if(rsp_requests.get(11).active){
      respiratory.requests.respirationRate.append(metrics.simulationTime,metrics.respirationRate)
    }
    if(rsp_requests.get(12).active){
      respiratory.requests.specificVentilation.append(metrics.simulationTime,metrics.specificVentilation)
    }
    if(rsp_requests.get(13).active){
      respiratory.requests.targetPulmonaryVentilation.append(metrics.simulationTime,metrics.targetPulmonaryVentilation)
    }
    if(rsp_requests.get(14).active){
      respiratory.requests.tidalVolume.append(metrics.simulationTime,metrics.tidalVolume)
    }
    if(rsp_requests.get(15).active){
      respiratory.requests.totalAlveolarVentilation.append(metrics.simulationTime,metrics.totalAlveolarVentilation)
    }
    if(rsp_requests.get(16).active){
      respiratory.requests.totalDeadSpaceVentilation.append(metrics.simulationTime,metrics.totalDeadSpaceVentilation)
    }
    if(rsp_requests.get(17).active){
      respiratory.requests.totalLungVolume.append(metrics.simulationTime,metrics.totalLungVolume)
    }
    if(rsp_requests.get(18).active){
      respiratory.requests.totalPulmonaryVentilation.append(metrics.simulationTime,metrics.totalPulmonaryVentilation)
    }
    if(rsp_requests.get(19).active){
      respiratory.requests.transpulmonaryPressure.append(metrics.simulationTime,metrics.transpulmonaryPressure)
    }
  }
  function updateTissue(metrics){
    updateDomain(tissue.axisX)
    var ts_requests = physiologyRequestModel.get(10).requests
    
    if(ts_requests.get(0).active){
      tissue.requests.carbonDioxideProductionRate.append(metrics.simulationTime,metrics.carbonDioxideProductionRate)
    }
    if(ts_requests.get(1).active){
      tissue.requests.dehydrationFraction.append(metrics.simulationTime,metrics.dehydrationFraction)
    }
    if(ts_requests.get(2).active){
      tissue.requests.extracellularFluidVolume.append(metrics.simulationTime,metrics.extracellularFluidVolume)
    }
    if(ts_requests.get(3).active){
      tissue.requests.extravascularFluidVolume.append(metrics.simulationTime,metrics.extravascularFluidVolume)
    }
    if(ts_requests.get(4).active){
      tissue.requests.intracellularFluidPH.append(metrics.simulationTime,metrics.intracellularFluidPH)
    }
    if(ts_requests.get(5).active){
      tissue.requests.intracellularFluidVolume.append(metrics.simulationTime,metrics.intracellularFluidVolume)
    }
    if(ts_requests.get(6).active){
      tissue.requests.totalBodyFluidVolume.append(metrics.simulationTime,metrics.totalBodyFluidVolume)
    }
    if(ts_requests.get(7).active){
      tissue.requests.oxygenConsumptionRate.append(metrics.simulationTime,metrics.oxygenConsumptionRate)
    }
    if(ts_requests.get(8).active){
      tissue.requests.respiratoryExchangeRatio.append(metrics.simulationTime,metrics.respiratoryExchangeRatio)
    }
    if(ts_requests.get(9).active){
      tissue.requests.liverInsulinSetPoint.append(metrics.simulationTime,metrics.liverInsulinSetPoint)
    }
    if(ts_requests.get(10).active){
      tissue.requests.liverGlucagonSetPoint.append(metrics.simulationTime,metrics.liverGlucagonSetPoint)
    }
    if(ts_requests.get(11).active){
      tissue.requests.muscleInsulinSetPoint.append(metrics.simulationTime,metrics.muscleInsulinSetPoint)
    }
    if(ts_requests.get(12).active){
      tissue.requests.muscleGlucagonSetPoint.append(metrics.simulationTime,metrics.muscleGlucagonSetPoint)
    }
    if(ts_requests.get(13).active){
      tissue.requests.fatInsulinSetPoint.append(metrics.simulationTime,metrics.fatInsulinSetPoint)
    }
    if(ts_requests.get(14).active){
      tissue.requests.fatGlucagonSetPoint.append(metrics.simulationTime,metrics.fatGlucagonSetPoint)
    }
    if(ts_requests.get(15).active){
      tissue.requests.liverGlycogen.append(metrics.simulationTime,metrics.liverGlycogen)
    }
    if(ts_requests.get(16).active){
      tissue.requests.muscleGlycogen.append(metrics.simulationTime,metrics.muscleGlycogen)
    }
    if(ts_requests.get(17).active){
      tissue.requests.storedProtein.append(metrics.simulationTime,metrics.storedProtein)
    }
    if(ts_requests.get(18).active){
      tissue.requests.storedFat.append(metrics.simulationTime,metrics.storedFat)
    }
  }
  //!
  //!  Setup Functions for creating all the axis plots
  //!
  function toggleBloodChemistrySeries(request, active){
    switch (request) {
      case "arterialBloodPH":
      if(active){
       bloodChemistry.requests.arterialBloodPH = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.arterialBloodPH.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.arterialBloodPH.axisY);
       bloodChemistry.requests.arterialBloodPH.axisY = bloodChemistry.axisY(bloodChemistry.requests.arterialBloodPH)
      } else  if(bloodChemistry.series(bloodChemistry.requests.arterialBloodPH.axisY.label)){
        bloodChemistry.setAxisX(undefined, bloodChemistry.requests.arterialBloodPH);
        bloodChemistry.removeSeries(bloodChemistry.requests.arterialBloodPH);
      }
      break;
      case "arterialBloodPHBaseline":
      if(active){
        bloodChemistry.requests.arterialBloodPHBaseline = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.arterialBloodPHBaseline.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.arterialBloodPHBaseline.axisY);
        bloodChemistry.requests.arterialBloodPHBaseline.axisY = bloodChemistry.axisY(bloodChemistry.requests.arterialBloodPHBaseline)
      } else  if(bloodChemistry.series(bloodChemistry.requests.arterialBloodPHBaseline.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.arterialBloodPHBaseline);
      }
      break;
      case "bloodDensity":
      if(active){
        bloodChemistry.requests.bloodDensity = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.bloodDensity.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.bloodDensity.axisY);
        bloodChemistry.requests.bloodDensity.axisY = bloodChemistry.axisY(bloodChemistry.requests.bloodDensity)
      } else if(bloodChemistry.series(bloodChemistry.requests.bloodDensity.axisY.label)) {
        bloodChemistry.removeSeries(bloodChemistry.requests.bloodDensity);
      }
      break;
      case "bloodSpecificHeat":
      if(active){
        bloodChemistry.requests.bloodSpecificHeat = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.bloodSpecificHeat.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.bloodSpecificHeat.axisY);
        bloodChemistry.requests.bloodSpecificHeat.axisY = bloodChemistry.axisY(bloodChemistry.requests.bloodSpecificHeat)
      } else if(bloodChemistry.series(bloodChemistry.requests.bloodSpecificHeat.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.bloodSpecificHeat);
      }
      break;
      case "bloodUreaNitrogenConcentration":
      if(active){
        bloodChemistry.requests.bloodUreaNitrogenConcentration = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.bloodUreaNitrogenConcentration.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.bloodUreaNitrogenConcentration.axisY);
        bloodChemistry.requests.bloodUreaNitrogenConcentration.axisY = bloodChemistry.axisY(bloodChemistry.requests.bloodUreaNitrogenConcentration)
      } else if(bloodChemistry.series(bloodChemistry.requests.bloodUreaNitrogenConcentration.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.bloodUreaNitrogenConcentration);
      }
      break;
      case "carbonDioxideSaturation":
      if(active){
        bloodChemistry.requests.carbonDioxideSaturation = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.carbonDioxideSaturation.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.carbonDioxideSaturation.axisY);
        bloodChemistry.requests.carbonDioxideSaturation.axisY = bloodChemistry.axisY(bloodChemistry.requests.carbonDioxideSaturation)
      } else if(bloodChemistry.series(bloodChemistry.requests.carbonDioxideSaturation.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.carbonDioxideSaturation);
      }
      break;
      case "carbonMonoxideSaturation":
      if(active){
        bloodChemistry.requests.carbonMonoxideSaturation = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.carbonMonoxideSaturation.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.carbonMonoxideSaturation.axisY);
        bloodChemistry.requests.carbonMonoxideSaturation.axisY = bloodChemistry.axisY(bloodChemistry.requests.carbonMonoxideSaturation)
      } else if(bloodChemistry.series(bloodChemistry.requests.carbonMonoxideSaturation.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.carbonMonoxideSaturation);
      }
      break;
      case "hematocrit":
      if(active){
        bloodChemistry.requests.hematocrit = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.hematocrit.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.hematocrit.axisY);
        bloodChemistry.requests.hematocrit.axisY = bloodChemistry.axisY(bloodChemistry.requests.hematocrit)
      } else if(bloodChemistry.series(bloodChemistry.requests.hematocrit.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.hematocrit);
      }
      break;
      case "hemoglobinContent":
      if(active){
        bloodChemistry.requests.hemoglobinContent = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.hemoglobinContent.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.hemoglobinContent.axisY);
        bloodChemistry.requests.hemoglobinContent.axisY = bloodChemistry.axisY(bloodChemistry.requests.hemoglobinContent)
      } else if(bloodChemistry.series(bloodChemistry.requests.hemoglobinContent.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.hemoglobinContent);
      }
      break;
      case "oxygenSaturation":
      if(active){
        bloodChemistry.requests.oxygenSaturation = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.oxygenSaturation.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.oxygenSaturation.axisY);
        bloodChemistry.requests.oxygenSaturation.axisY = bloodChemistry.axisY(bloodChemistry.requests.oxygenSaturation)
      } else if(bloodChemistry.series(bloodChemistry.requests.oxygenSaturation.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.oxygenSaturation);
      }
      break;
      case "phosphate":
      if(active){
        bloodChemistry.requests.phosphate = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.phosphate.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.phosphate.axisY);
        bloodChemistry.requests.phosphate.axisY = bloodChemistry.axisY(bloodChemistry.requests.phosphate)
      } else if(bloodChemistry.series(bloodChemistry.requests.phosphate.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.phosphate);
      }
      break;
      case "plasmaVolume":
      if(active){
        bloodChemistry.requests.plasmaVolume = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.plasmaVolume.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.plasmaVolume.axisY);
        bloodChemistry.requests.plasmaVolume.axisY = bloodChemistry.axisY(bloodChemistry.requests.plasmaVolume)
      } else if(bloodChemistry.series(bloodChemistry.requests.plasmaVolume.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.plasmaVolume);
      }
      break;
      case "pulseOximetry":
      if(active){
        bloodChemistry.requests.pulseOximetry = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.pulseOximetry.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.pulseOximetry.axisY);
        bloodChemistry.requests.pulseOximetry.axisY = bloodChemistry.axisY(bloodChemistry.requests.pulseOximetry)
      } else if(bloodChemistry.series(bloodChemistry.requests.pulseOximetry.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.pulseOximetry);
      }
      break;
      case "redBloodCellAcetylcholinesterase":
      if(active){
        bloodChemistry.requests.redBloodCellAcetylcholinesterase = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.redBloodCellAcetylcholinesterase.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.redBloodCellAcetylcholinesterase.axisY);
        bloodChemistry.requests.redBloodCellAcetylcholinesterase.axisY = bloodChemistry.axisY(bloodChemistry.requests.redBloodCellAcetylcholinesterase)
      } else if(bloodChemistry.series(bloodChemistry.requests.redBloodCellAcetylcholinesterase.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.redBloodCellAcetylcholinesterase);
      }
      break;
      case "redBloodCellCount":
      if(active){
        bloodChemistry.requests.redBloodCellCount = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.redBloodCellCount.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.redBloodCellCount.axisY);
        bloodChemistry.requests.redBloodCellCount.axisY = bloodChemistry.axisY(bloodChemistry.requests.redBloodCellCount)
      } else if(bloodChemistry.series(bloodChemistry.requests.redBloodCellCount.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.redBloodCellCount);
      }
      break;
      case "shuntFraction":
      if(active){
        bloodChemistry.requests.shuntFraction = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.shuntFraction.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.shuntFraction.axisY);
        bloodChemistry.requests.shuntFraction.axisY = bloodChemistry.axisY(bloodChemistry.requests.shuntFraction)
      } else if(bloodChemistry.series(bloodChemistry.requests.shuntFraction.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.shuntFraction);
      }
      break;
      case "strongIonDifference":
      if(active){
        bloodChemistry.requests.strongIonDifference = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.strongIonDifference.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.strongIonDifference.axisY);
        bloodChemistry.requests.strongIonDifference.axisY = bloodChemistry.axisY(bloodChemistry.requests.strongIonDifference)
      } else if(bloodChemistry.series(bloodChemistry.requests.strongIonDifference.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.strongIonDifference);
      }
      break;
      case "totalBilirubin":
      if(active){
        bloodChemistry.requests.totalBilirubin = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.totalBilirubin.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.totalBilirubin.axisY);
        bloodChemistry.requests.totalBilirubin.axisY = bloodChemistry.axisY(bloodChemistry.requests.totalBilirubin)
      } else if(bloodChemistry.series(bloodChemistry.requests.totalBilirubin.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.totalBilirubin);
      }
      break;
      case "totalProteinConcentration":
      if(active){
        bloodChemistry.requests.totalProteinConcentration = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.totalProteinConcentration.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.totalProteinConcentration.axisY);
        bloodChemistry.requests.totalProteinConcentration.axisY = bloodChemistry.axisY(bloodChemistry.requests.totalProteinConcentration)
      } else if(bloodChemistry.series(bloodChemistry.requests.totalProteinConcentration.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.totalProteinConcentration);
      }
      break;
      case "venousBloodPH":
      if(active){
        bloodChemistry.requests.venousBloodPH = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.venousBloodPH.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.venousBloodPH.axisY);
        bloodChemistry.requests.venousBloodPH.axisY = bloodChemistry.axisY(bloodChemistry.requests.venousBloodPH)
      } else if(bloodChemistry.series(bloodChemistry.requests.venousBloodPH.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.venousBloodPH);
      }
      break;
      case "volumeFractionNeutralPhospholipidInPlasma":
      if(active){
        bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.axisY);
        bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.axisY = bloodChemistry.axisY(bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma)
      } else if(bloodChemistry.series(bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma);
      }
      break;
      case "volumeFractionNeutralLipidInPlasma":
      if(active){
        bloodChemistry.requests.volumeFractionNeutralLipidInPlasma = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.axisY);
        bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.axisY = bloodChemistry.axisY(bloodChemistry.requests.volumeFractionNeutralLipidInPlasma)
      } else if(bloodChemistry.series(bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.volumeFractionNeutralLipidInPlasma);
      }
      break;
      case "arterialCarbonDioxidePressure":
      if(active){
        bloodChemistry.requests.arterialCarbonDioxidePressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.arterialCarbonDioxidePressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.arterialCarbonDioxidePressure.axisY);
        bloodChemistry.requests.arterialCarbonDioxidePressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.arterialCarbonDioxidePressure)
      } else if(bloodChemistry.series(bloodChemistry.requests.arterialCarbonDioxidePressure.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.arterialCarbonDioxidePressure);
      }
      break;
      case "arterialOxygenPressure":
      if(active){
        bloodChemistry.requests.arterialOxygenPressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.arterialOxygenPressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.arterialOxygenPressure.axisY);
        bloodChemistry.requests.arterialOxygenPressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.arterialOxygenPressure)
      } else if(bloodChemistry.series(bloodChemistry.requests.arterialOxygenPressure.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.arterialOxygenPressure);
      }
      break;
      case "pulmonaryArterialCarbonDioxidePressure":
      if(active){
        bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.axisY);
        bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure)
      } else if(bloodChemistry.series(bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure);
      }
      break;
      case "pulmonaryArterialOxygenPressure":
      if(active){
        bloodChemistry.requests.pulmonaryArterialOxygenPressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.pulmonaryArterialOxygenPressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.pulmonaryArterialOxygenPressure.axisY);
        bloodChemistry.requests.pulmonaryArterialOxygenPressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.pulmonaryArterialOxygenPressure)
      } else if(bloodChemistry.series(bloodChemistry.requests.pulmonaryArterialOxygenPressure.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.pulmonaryArterialOxygenPressure);
      }
      break;
      case "pulmonaryVenousCarbonDioxidePressure":
      if(active){
        bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.axisY);
        bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure)
      } else if(bloodChemistry.series(bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure);
      }
      break;
      case "pulmonaryVenousOxygenPressure":
      if(active){
        bloodChemistry.requests.pulmonaryVenousOxygenPressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.pulmonaryVenousOxygenPressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.pulmonaryVenousOxygenPressure.axisY);
        bloodChemistry.requests.pulmonaryVenousOxygenPressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.pulmonaryVenousOxygenPressure)
      } else if(bloodChemistry.series(bloodChemistry.requests.pulmonaryVenousOxygenPressure.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.pulmonaryVenousOxygenPressure);
      }
      break;
      case "venousCarbonDioxidePressure":
      if(active){
        bloodChemistry.requests.venousCarbonDioxidePressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.venousCarbonDioxidePressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.venousCarbonDioxidePressure.axisY);
        bloodChemistry.requests.venousCarbonDioxidePressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.venousCarbonDioxidePressure)
      } else if(bloodChemistry.series(bloodChemistry.requests.venousCarbonDioxidePressure.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.venousCarbonDioxidePressure);
      }
      break;
      case "venousOxygenPressure":
      if(active){
        bloodChemistry.requests.venousOxygenPressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.venousOxygenPressure.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.venousOxygenPressure.axisY);
        bloodChemistry.requests.venousOxygenPressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.venousOxygenPressure)
      } else if(bloodChemistry.series(bloodChemistry.requests.venousOxygenPressure.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.venousOxygenPressure);
      }
      break;
      case "inflammatoryResponse":
      if(active){
        bloodChemistry.requests.inflammatoryResponse = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponse.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponse.axisY);
        bloodChemistry.requests.inflammatoryResponse.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponse)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponse.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponse);
      }
      break;
      case "inflammatoryResponseLocalPathogen":
      if(active){
        bloodChemistry.requests.inflammatoryResponseLocalPathogen = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseLocalPathogen.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseLocalPathogen.axisY);
        bloodChemistry.requests.inflammatoryResponseLocalPathogen.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseLocalPathogen)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseLocalPathogen.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseLocalPathogen);
      }
      break;
      case "inflammatoryResponseLocalMacrophage":
      if(active){
        bloodChemistry.requests.inflammatoryResponseLocalMacrophage = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseLocalMacrophage.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseLocalMacrophage.axisY);
        bloodChemistry.requests.inflammatoryResponseLocalMacrophage.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseLocalMacrophage)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseLocalMacrophage.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseLocalMacrophage);
      }
      break;
      case "inflammatoryResponseLocalNeutrophil":
      if(active){
        bloodChemistry.requests.inflammatoryResponseLocalNeutrophil = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.axisY);
        bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseLocalNeutrophil)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseLocalNeutrophil);
      }
      break;
      case "inflammatoryResponseLocalBarrier":
      if(active){
        bloodChemistry.requests.inflammatoryResponseLocalBarrier = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseLocalBarrier.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseLocalBarrier.axisY);
        bloodChemistry.requests.inflammatoryResponseLocalBarrier.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseLocalBarrier)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseLocalBarrier.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseLocalBarrier);
      }
      break;
      case "inflammatoryResponseBloodPathogen":
      if(active){
        bloodChemistry.requests.inflammatoryResponseBloodPathogen = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseBloodPathogen.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseBloodPathogen.axisY);
        bloodChemistry.requests.inflammatoryResponseBloodPathogen.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseBloodPathogen)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseBloodPathogen.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseBloodPathogen);
      }
      break;
      case "inflammatoryResponseTrauma":
      if(active){
        bloodChemistry.requests.inflammatoryResponseTrauma = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseTrauma.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseTrauma.axisY);
        bloodChemistry.requests.inflammatoryResponseTrauma.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseTrauma)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseTrauma.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseTrauma);
      }
      break;
      case "inflammatoryResponseMacrophageResting":
      if(active){
        bloodChemistry.requests.inflammatoryResponseMacrophageResting = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseMacrophageResting.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseMacrophageResting.axisY);
        bloodChemistry.requests.inflammatoryResponseMacrophageResting.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseMacrophageResting)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseMacrophageResting.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseMacrophageResting);
      }
      break;
      case "inflammatoryResponseMacrophageActive":
      if(active){
        bloodChemistry.requests.inflammatoryResponseMacrophageActive = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseMacrophageActive.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseMacrophageActive.axisY);
        bloodChemistry.requests.inflammatoryResponseMacrophageActive.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseMacrophageActive)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseMacrophageActive.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseMacrophageActive);
      }
      break;
      case "inflammatoryResponseNeutrophilResting":
      if(active){
        bloodChemistry.requests.inflammatoryResponseNeutrophilResting = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseNeutrophilResting.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseNeutrophilResting.axisY);
        bloodChemistry.requests.inflammatoryResponseNeutrophilResting.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseNeutrophilResting)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseNeutrophilResting.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseNeutrophilResting);
      }
      break;
      case "inflammatoryResponseNeutrophilActive":
      if(active){
        bloodChemistry.requests.inflammatoryResponseNeutrophilActive = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseNeutrophilActive.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseNeutrophilActive.axisY);
        bloodChemistry.requests.inflammatoryResponseNeutrophilActive.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseNeutrophilActive)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseNeutrophilActive.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseNeutrophilActive);
      }
      break;
      case "inflammatoryResponseInducibleNOSPre":
      if(active){
        bloodChemistry.requests.inflammatoryResponseInducibleNOSPre = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.axisY);
        bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseInducibleNOSPre)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseInducibleNOSPre);
      }
      break;
      case "inflammatoryResponseInducibleNOS":
      if(active){
        bloodChemistry.requests.inflammatoryResponseInducibleNOS = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseInducibleNOS.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseInducibleNOS.axisY);
        bloodChemistry.requests.inflammatoryResponseInducibleNOS.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseInducibleNOS)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseInducibleNOS.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseInducibleNOS);
      }
      break;
      case "inflammatoryResponseConstitutiveNOS":
      if(active){
        bloodChemistry.requests.inflammatoryResponseConstitutiveNOS = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.axisY);
        bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseConstitutiveNOS)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseConstitutiveNOS);
      }
      break;
      case "inflammatoryResponseNitrate":
      if(active){
        bloodChemistry.requests.inflammatoryResponseNitrate = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseNitrate.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseNitrate.axisY);
        bloodChemistry.requests.inflammatoryResponseNitrate.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseNitrate)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseNitrate.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseNitrate);
      }
      break;
      case "inflammatoryResponseNitricOxide":
      if(active){
        bloodChemistry.requests.inflammatoryResponseNitricOxide = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseNitricOxide.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseNitricOxide.axisY);
        bloodChemistry.requests.inflammatoryResponseNitricOxide.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseNitricOxide)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseNitricOxide.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseNitricOxide);
      }
      break;
      case "inflammatoryResponseTumorNecrosisFactor":
      if(active){
        bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.axisY);
        bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor);
      }
      break;
      case "inflammatoryResponseInterleukin6":
      if(active){
        bloodChemistry.requests.inflammatoryResponseInterleukin6 = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseInterleukin6.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseInterleukin6.axisY);
        bloodChemistry.requests.inflammatoryResponseInterleukin6.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseInterleukin6)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseInterleukin6.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseInterleukin6);
      }
      break;
      case "inflammatoryResponseInterleukin10":
      if(active){
        bloodChemistry.requests.inflammatoryResponseInterleukin10 = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseInterleukin10.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseInterleukin10.axisY);
        bloodChemistry.requests.inflammatoryResponseInterleukin10.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseInterleukin10)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseInterleukin10.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseInterleukin10);
      }
      break;
      case "inflammatoryResponseInterleukin12":
      if(active){
        bloodChemistry.requests.inflammatoryResponseInterleukin12 = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseInterleukin12.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseInterleukin12.axisY);
        bloodChemistry.requests.inflammatoryResponseInterleukin12.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseInterleukin12)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseInterleukin12.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseInterleukin12);
      }
      break;
      case "inflammatoryResponseCatecholamines":
      if(active){
        bloodChemistry.requests.inflammatoryResponseCatecholamines = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseCatecholamines.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseCatecholamines.axisY);
        bloodChemistry.requests.inflammatoryResponseCatecholamines.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseCatecholamines)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseCatecholamines.axisY.label)){
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseCatecholamines);
      }
      break;
      case "inflammatoryResponseTissueIntegrity":
      if(active){
        bloodChemistry.requests.inflammatoryResponseTissueIntegrity = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseTissueIntegrity.axisY.label, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseTissueIntegrity.axisY);
        bloodChemistry.requests.inflammatoryResponseTissueIntegrity.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseTissueIntegrity)
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseTissueIntegrity.axisY.label)){
        loodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseTissueIntegrity);
      }
      break;
    }
  }
  function toggleCardiovascularSeries(request, active){
    switch (request) {
      case "arterialPressure":
      if(active){
      cardiovascular.requests.arterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.arterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.arterialPressure.axisY);
      cardiovascular.requests.arterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.arterialPressure)
      } else  if(cardiovascular.series(cardiovascular.requests.arterialPressure.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.arterialPressure);
      }
      break;
      case "bloodVolume":
      if(active){
        cardiovascular.requests.bloodVolume = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.bloodVolume.axisY.label, cardiovascular.axisX, cardiovascular.requests.bloodVolume.axisY);
        cardiovascular.requests.bloodVolume.axisY = cardiovascular.axisY(cardiovascular.requests.bloodVolume)
      } else  if(cardiovascular.series(cardiovascular.requests.bloodVolume.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.bloodVolume);
      }
      break;
      case "cardiacIndex":
      if(active){
        cardiovascular.requests.cardiacIndex = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.cardiacIndex.axisY.label, cardiovascular.axisX, cardiovascular.requests.cardiacIndex.axisY);
        cardiovascular.requests.cardiacIndex.axisY = cardiovascular.axisY(cardiovascular.requests.cardiacIndex)
      } else  if(cardiovascular.series(cardiovascular.requests.cardiacIndex.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.cardiacIndex);
      }
      break;
      case "cardiacOutput":
      if(active){
        cardiovascular.requests.cardiacOutput = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.cardiacOutput.axisY.label, cardiovascular.axisX, cardiovascular.requests.cardiacOutput.axisY);
        cardiovascular.requests.cardiacOutput.axisY = cardiovascular.axisY(cardiovascular.requests.cardiacOutput)
      } else  if(cardiovascular.series(cardiovascular.requests.cardiacOutput.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.cardiacOutput);
      }
      break;
      case "centralVenousPressure":
      if(active){
        cardiovascular.requests.centralVenousPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.centralVenousPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.centralVenousPressure.axisY);
        cardiovascular.requests.centralVenousPressure.axisY = cardiovascular.axisY(cardiovascular.requests.centralVenousPressure)
      } else  if(cardiovascular.series(cardiovascular.requests.centralVenousPressure.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.centralVenousPressure);
      }
      break;
      case "cerebralBloodFlow":
      if(active){
        cardiovascular.requests.cerebralBloodFlow = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.cerebralBloodFlow.axisY.label, cardiovascular.axisX, cardiovascular.requests.cerebralBloodFlow.axisY);
        cardiovascular.requests.cerebralBloodFlow.axisY = cardiovascular.axisY(cardiovascular.requests.cerebralBloodFlow)
      } else  if(cardiovascular.series(cardiovascular.requests.cerebralBloodFlow.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.cerebralBloodFlow);
      }
      break;
      case "cerebralPerfusionPressure":
      if(active){
        cardiovascular.requests.cerebralPerfusionPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.cerebralPerfusionPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.cerebralPerfusionPressure.axisY);
        cardiovascular.requests.cerebralPerfusionPressure.axisY = cardiovascular.axisY(cardiovascular.requests.cerebralPerfusionPressure)
      } else  if(cardiovascular.series(cardiovascular.requests.cerebralPerfusionPressure.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.cerebralPerfusionPressure);
      }
      break;
      case "diastolicArterialPressure":
      if(active){
        cardiovascular.requests.diastolicArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.diastolicArterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.diastolicArterialPressure.axisY);
        cardiovascular.requests.diastolicArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.diastolicArterialPressure)
      } else  if(cardiovascular.series(cardiovascular.requests.diastolicArterialPressure.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.diastolicArterialPressure);
      }
      break;
      case "heartEjectionFraction":
      if(active){
        cardiovascular.requests.heartEjectionFraction = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.heartEjectionFraction.axisY.label, cardiovascular.axisX, cardiovascular.requests.heartEjectionFraction.axisY);
        cardiovascular.requests.heartEjectionFraction.axisY = cardiovascular.axisY(cardiovascular.requests.heartEjectionFraction)
      } else  if(cardiovascular.series(cardiovascular.requests.heartEjectionFraction.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.heartEjectionFraction);
      }
      break;
      case "heartRate":
      if(active){
        cardiovascular.requests.heartRate = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.heartRate.axisY.label, cardiovascular.axisX, cardiovascular.requests.heartRate.axisY);
        cardiovascular.requests.heartRate.axisY = cardiovascular.axisY(cardiovascular.requests.heartRate)
      } else  if(cardiovascular.series(cardiovascular.requests.heartRate.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.heartRate);
      }
      break;
      case "heartStrokeVolume":
      if(active){
        cardiovascular.requests.heartStrokeVolume = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.heartStrokeVolume.axisY.label, cardiovascular.axisX, cardiovascular.requests.heartStrokeVolume.axisY);
        cardiovascular.requests.heartStrokeVolume.axisY = cardiovascular.axisY(cardiovascular.requests.heartStrokeVolume)
      } else  if(cardiovascular.series(cardiovascular.requests.heartStrokeVolume.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.heartStrokeVolume);
      }
      break;
      case "intracranialPressure":
      if(active){
        cardiovascular.requests.intracranialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.intracranialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.intracranialPressure.axisY);
        cardiovascular.requests.intracranialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.intracranialPressure)
      } else  if(cardiovascular.series(cardiovascular.requests.intracranialPressure.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.intracranialPressure);
      }
      break;
      case "meanArterialPressure":
      if(active){
        cardiovascular.requests.meanArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.meanArterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.meanArterialPressure.axisY);
        cardiovascular.requests.meanArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.meanArterialPressure)
      } else  if(cardiovascular.series(cardiovascular.requests.meanArterialPressure.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.meanArterialPressure);
      }
      break;
      case "meanArterialCarbonDioxidePartialPressure":
      if(active){
        cardiovascular.requests.meanArterialCarbonDioxidePartialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.axisY);
        cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.meanArterialCarbonDioxidePartialPressure)
      } else  if(cardiovascular.series(cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.meanArterialCarbonDioxidePartialPressure);
      }
      break;
      case "meanArterialCarbonDioxidePartialPressureDelta":
      if(active){
        cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.axisY.label, cardiovascular.axisX, cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.axisY);
        cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.axisY = cardiovascular.axisY(cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta)
      } else  if(cardiovascular.series(cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta);
      }
      break;
      case "meanCentralVenousPressure":
      if(active){
        cardiovascular.requests.meanCentralVenousPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.meanCentralVenousPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.meanCentralVenousPressure.axisY);
        cardiovascular.requests.meanCentralVenousPressure.axisY = cardiovascular.axisY(cardiovascular.requests.meanCentralVenousPressure)
      } else  if(cardiovascular.series(cardiovascular.requests.meanCentralVenousPressure.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.meanCentralVenousPressure);
      }
      break;
      case "meanSkinFlow":
      if(active){
        cardiovascular.requests.meanSkinFlow = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.meanSkinFlow.axisY.label, cardiovascular.axisX, cardiovascular.requests.meanSkinFlow.axisY);
        cardiovascular.requests.meanSkinFlow.axisY = cardiovascular.axisY(cardiovascular.requests.meanSkinFlow)
      } else  if(cardiovascular.series(cardiovascular.requests.meanSkinFlow.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.meanSkinFlow);
      }
      break;
      case "pulmonaryArterialPressure":
      if(active){
        cardiovascular.requests.pulmonaryArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryArterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryArterialPressure.axisY);
        cardiovascular.requests.pulmonaryArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryArterialPressure)
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryArterialPressure.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.pulmonaryArterialPressure);
      }
      break;
      case "pulmonaryCapillariesWedgePressure":
      if(active){
        cardiovascular.requests.pulmonaryCapillariesWedgePressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryCapillariesWedgePressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryCapillariesWedgePressure.axisY);
        cardiovascular.requests.pulmonaryCapillariesWedgePressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryCapillariesWedgePressure)
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryCapillariesWedgePressure.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.pulmonaryCapillariesWedgePressure);
      }
      break;
      case "pulmonaryDiastolicArterialPressure":
      if(active){
        cardiovascular.requests.pulmonaryDiastolicArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryDiastolicArterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryDiastolicArterialPressure.axisY);
        cardiovascular.requests.pulmonaryDiastolicArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryDiastolicArterialPressure)
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryDiastolicArterialPressure.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.pulmonaryDiastolicArterialPressure);
      }
      break;
      case "pulmonaryMeanArterialPressure":
      if(active){
        cardiovascular.requests.pulmonaryMeanArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryMeanArterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryMeanArterialPressure.axisY);
        cardiovascular.requests.pulmonaryMeanArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryMeanArterialPressure)
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryMeanArterialPressure.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.pulmonaryMeanArterialPressure);
      }
      break;
      case "pulmonaryMeanCapillaryFlow":
      if(active){
        cardiovascular.requests.pulmonaryMeanCapillaryFlow = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryMeanCapillaryFlow.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryMeanCapillaryFlow.axisY);
        cardiovascular.requests.pulmonaryMeanCapillaryFlow.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryMeanCapillaryFlow)
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryMeanCapillaryFlow.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.pulmonaryMeanCapillaryFlow);
      }
      break;
      case "pulmonaryMeanShuntFlow":
      if(active){
        cardiovascular.requests.pulmonaryMeanShuntFlow = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryMeanShuntFlow.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryMeanShuntFlow.axisY);
        cardiovascular.requests.pulmonaryMeanShuntFlow.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryMeanShuntFlow)
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryMeanShuntFlow.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.pulmonaryMeanShuntFlow);
      }
      break;
      case "pulmonarySystolicArterialPressure":
      if(active){
        cardiovascular.requests.pulmonarySystolicArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonarySystolicArterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonarySystolicArterialPressure.axisY);
        cardiovascular.requests.pulmonarySystolicArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonarySystolicArterialPressure)
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonarySystolicArterialPressure.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.pulmonarySystolicArterialPressure);
      }
      break;
      case "pulmonaryVascularResistance":
      if(active){
        cardiovascular.requests.pulmonaryVascularResistance = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryVascularResistance.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryVascularResistance.axisY);
        cardiovascular.requests.pulmonaryVascularResistance.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryVascularResistance)
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryVascularResistance.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.pulmonaryVascularResistance);
      }
      break;
      case "pulmonaryVascularResistanceIndex":
      if(active){
        cardiovascular.requests.pulmonaryVascularResistanceIndex = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryVascularResistanceIndex.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulmonaryVascularResistanceIndex.axisY);
        cardiovascular.requests.pulmonaryVascularResistanceIndex.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryVascularResistanceIndex)
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryVascularResistanceIndex.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.pulmonaryVascularResistanceIndex);
      }
      break;
      case "pulsePressure":
      if(active){
        cardiovascular.requests.pulsePressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulsePressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.pulsePressure.axisY);
        cardiovascular.requests.pulsePressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulsePressure)
      } else  if(cardiovascular.series(cardiovascular.requests.pulsePressure.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.pulsePressure);
      }
      break;
      case "systemicVascularResistance":
      if(active){
        cardiovascular.requests.systemicVascularResistance = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.systemicVascularResistance.axisY.label, cardiovascular.axisX, cardiovascular.requests.systemicVascularResistance.axisY);
        cardiovascular.requests.systemicVascularResistance.axisY = cardiovascular.axisY(cardiovascular.requests.systemicVascularResistance)
      } else  if(cardiovascular.series(cardiovascular.requests.systemicVascularResistance.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.systemicVascularResistance);
      }
      break;
      case "systolicArterialPressure":
      if(active){
        cardiovascular.requests.systolicArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.systolicArterialPressure.axisY.label, cardiovascular.axisX, cardiovascular.requests.systolicArterialPressure.axisY);
        cardiovascular.requests.systolicArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.systolicArterialPressure)
      } else  if(cardiovascular.series(cardiovascular.requests.systolicArterialPressure.axisY.label)){
          cardiovascular.removeSeries(cardiovascular.requests.systolicArterialPressure);
      }
      break;
    }
  }
  function toggleDrugsSeries(request, active){
     switch(request){
      case "systolicArterialPressure":
      if(active){
        drugs.requests.bronchodilationLevel = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.bronchodilationLevel.axisY.label, drugs.axisX, drugs.requests.bronchodilationLevel.axisY);
        drugs.requests.bronchodilationLevel.axisY = drugs.axisY(drugs.requests.bronchodilationLevel)
      } else  if(drugs.series(drugs.requests.bronchodilationLevel.axisY.label)){
          drugs.removeSeries(drugs.requests.bronchodilationLevel);
      }
      break;
      case "heartRateChange":
      if(active){
      drugs.requests.heartRateChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.heartRateChange.axisY.label, drugs.axisX, drugs.requests.heartRateChange.axisY);
      drugs.requests.heartRateChange.axisY = drugs.axisY(drugs.requests.heartRateChange)
      } else  if(drugs.series(drugs.requests.heartRateChange.axisY.label)){
          drugs.removeSeries(drugs.requests.heartRateChange);
      }
      break;
      case "hemorrhageChange":
      if(active){
      drugs.requests.hemorrhageChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.hemorrhageChange.axisY.label, drugs.axisX, drugs.requests.hemorrhageChange.axisY);
      drugs.requests.hemorrhageChange.axisY = drugs.axisY(drugs.requests.hemorrhageChange)
      } else  if(drugs.series(drugs.requests.hemorrhageChange.axisY.label)){
          drugs.removeSeries(drugs.requests.hemorrhageChange);
      }
      break;
      case "meanBloodPressureChange":
      if(active){
      drugs.requests.meanBloodPressureChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.meanBloodPressureChange.axisY.label, drugs.axisX, drugs.requests.meanBloodPressureChange.axisY);
      drugs.requests.meanBloodPressureChange.axisY = drugs.axisY(drugs.requests.meanBloodPressureChange)
      } else  if(drugs.series(drugs.requests.meanBloodPressureChange.axisY.label)){
          drugs.removeSeries(drugs.requests.meanBloodPressureChange);
      }
      break;
      case "neuromuscularBlockLevel":
      if(active){
      drugs.requests.neuromuscularBlockLevel = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.neuromuscularBlockLevel.axisY.label, drugs.axisX, drugs.requests.neuromuscularBlockLevel.axisY);
      drugs.requests.neuromuscularBlockLevel.axisY = drugs.axisY(drugs.requests.neuromuscularBlockLevel)
      } else  if(drugs.series(drugs.requests.neuromuscularBlockLevel.axisY.label)){
          drugs.removeSeries(drugs.requests.neuromuscularBlockLevel);
      }
      break;
      case "pulsePressureChange":
      if(active){
      drugs.requests.pulsePressureChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.pulsePressureChange.axisY.label, drugs.axisX, drugs.requests.pulsePressureChange.axisY);
      drugs.requests.pulsePressureChange.axisY = drugs.axisY(drugs.requests.pulsePressureChange)
      } else  if(drugs.series(drugs.requests.pulsePressureChange.axisY.label)){
          drugs.removeSeries(drugs.requests.pulsePressureChange);
      }
      break;
      case "respirationRateChange":
      if(active){
      drugs.requests.respirationRateChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.respirationRateChange.axisY.label, drugs.axisX, drugs.requests.respirationRateChange.axisY);
      drugs.requests.respirationRateChange.axisY = drugs.axisY(drugs.requests.respirationRateChange)
      } else  if(drugs.series(drugs.requests.respirationRateChange.axisY.label)){
          drugs.removeSeries(drugs.requests.respirationRateChange);
      }
      break;
      case "sedationLevel":
      if(active){
      drugs.requests.sedationLevel = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.sedationLevel.axisY.label, drugs.axisX, drugs.requests.sedationLevel.axisY);
      drugs.requests.sedationLevel.axisY = drugs.axisY(drugs.requests.sedationLevel)
      } else  if(drugs.series(drugs.requests.sedationLevel.axisY.label)){
          drugs.removeSeries(drugs.requests.sedationLevel);
      }
      break;
      case "tidalVolumeChange":
      if(active){
      drugs.requests.tidalVolumeChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.tidalVolumeChange.axisY.label, drugs.axisX, drugs.requests.tidalVolumeChange.axisY);
      drugs.requests.tidalVolumeChange.axisY = drugs.axisY(drugs.requests.tidalVolumeChange)
      } else  if(drugs.series(drugs.requests.tidalVolumeChange.axisY.label)){
          drugs.removeSeries(drugs.requests.tidalVolumeChange);
      }
      break;
      case "tubularPermeabilityChange":
      if(active){
      drugs.requests.tubularPermeabilityChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.tubularPermeabilityChange.axisY.label, drugs.axisX, drugs.requests.tubularPermeabilityChange.axisY);
      drugs.requests.tubularPermeabilityChange.axisY = drugs.axisY(drugs.requests.tubularPermeabilityChange)
      } else  if(drugs.series(drugs.requests.tubularPermeabilityChange.axisY.label)){
          drugs.removeSeries(drugs.requests.tubularPermeabilityChange);
      }
      break;
      case "centralNervousResponse":
      if(active){
      drugs.requests.centralNervousResponse = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.centralNervousResponse.axisY.label, drugs.axisX, drugs.requests.centralNervousResponse.axisY);
      drugs.requests.centralNervousResponse.axisY = drugs.axisY(drugs.requests.centralNervousResponse)
      } else  if  (drugs.series(drugs.requests.centralNervousResponse.axisY.label)){
          drugs.removeSeries(drugs.requests.centralNervousResponse);
      }
      break;

     }
  }
  function toggleEndocrineSeries(request, active){
    switch(request){
      case "insulinSynthesisRate":
      if(active){
      endocrine.requests.insulinSynthesisRate = endocrine.createSeries(ChartView.SeriesTypeLine, endocrine.requests.insulinSynthesisRate.axisY.label, endocrine.axisX, endocrine.requests.insulinSynthesisRate.axisY);
      endocrine.requests.insulinSynthesisRate.axisY = endocrine.axisY(endocrine.requests.insulinSynthesisRate)
      } else  if  (endocrine.series(endocrine.requests.insulinSynthesisRate.axisY.label)){
          endocrine.removeSeries(endocrine.requests.insulinSynthesisRate);
      }
      break;
      case "glucagonSynthesisRate":
      if(active){
      endocrine.requests.glucagonSynthesisRate = endocrine.createSeries(ChartView.SeriesTypeLine, endocrine.requests.glucagonSynthesisRate.axisY.label, endocrine.axisX, endocrine.requests.glucagonSynthesisRate.axisY);
      endocrine.requests.glucagonSynthesisRate.axisY = endocrine.axisY(endocrine.requests.glucagonSynthesisRate)
      } else  if  (endocrine.series(endocrine.requests.glucagonSynthesisRate.axisY.label)){
          endocrine.removeSeries(endocrine.requests.glucagonSynthesisRate);
      }
      break;
    }
  }
  function toggleEnergySeries(request, active){
    switch(request){
      case "achievedExerciseLevel":
      if(active){
        energy.requests.achievedExerciseLevel = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.achievedExerciseLevel.axisY.label, energy.axisX, energy.requests.achievedExerciseLevel.axisY);
        energy.requests.achievedExerciseLevel.axisY = energy.axisY(energy.requests.achievedExerciseLevel)
      } else  if  (energy.series(energy.requests.achievedExerciseLevel.axisY.label)){
          energy.removeSeries(energy.requests.achievedExerciseLevel);
      }
      break;
      case "chlorideLostToSweat":
      if(active){
        energy.requests.chlorideLostToSweat = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.chlorideLostToSweat.axisY.label, energy.axisX, energy.requests.chlorideLostToSweat.axisY);
        energy.requests.chlorideLostToSweat.axisY = energy.axisY(energy.requests.chlorideLostToSweat)
      } else  if  (energy.series(energy.requests.chlorideLostToSweat.axisY.label)){
          energy.removeSeries(energy.requests.chlorideLostToSweat);
      }
      break;
      case "coreTemperature":
      if(active){
        energy.requests.coreTemperature = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.coreTemperature.axisY.label, energy.axisX, energy.requests.coreTemperature.axisY);
        energy.requests.coreTemperature.axisY = energy.axisY(energy.requests.coreTemperature)
      } else  if  (energy.series(energy.requests.coreTemperature.axisY.label)){
          energy.removeSeries(energy.requests.coreTemperature);
      }
      break;
      case "creatinineProductionRate":
      if(active){
        energy.requests.creatinineProductionRate = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.creatinineProductionRate.axisY.label, energy.axisX, energy.requests.creatinineProductionRate.axisY);
        energy.requests.creatinineProductionRate.axisY = energy.axisY(energy.requests.creatinineProductionRate)
      } else  if  (energy.series(energy.requests.creatinineProductionRate.axisY.label)){
          energy.removeSeries(energy.requests.creatinineProductionRate);
      }
      break;
      case "exerciseMeanArterialPressureDelta":
      if(active){
        energy.requests.exerciseMeanArterialPressureDelta = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.exerciseMeanArterialPressureDelta.axisY.label, energy.axisX, energy.requests.exerciseMeanArterialPressureDelta.axisY);
        energy.requests.exerciseMeanArterialPressureDelta.axisY = energy.axisY(energy.requests.exerciseMeanArterialPressureDelta)
      } else  if  (energy.series(energy.requests.exerciseMeanArterialPressureDelta.axisY.label)){
          energy.removeSeries(energy.requests.exerciseMeanArterialPressureDelta);
      }
      break;
      case "fatigueLevel":
      if(active){
        energy.requests.fatigueLevel = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.fatigueLevel.axisY.label, energy.axisX, energy.requests.fatigueLevel.axisY);
        energy.requests.fatigueLevel.axisY = energy.axisY(energy.requests.fatigueLevel)
      } else  if  (energy.series(energy.requests.fatigueLevel.axisY.label)){
          energy.removeSeries(energy.requests.fatigueLevel);
      }
      break;
      case "lactateProductionRate":
      if(active){
        energy.requests.lactateProductionRate = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.lactateProductionRate.axisY.label, energy.axisX, energy.requests.lactateProductionRate.axisY);
        energy.requests.lactateProductionRate.axisY = energy.axisY(energy.requests.lactateProductionRate)
      } else  if  (energy.series(energy.requests.lactateProductionRate.axisY.label)){
          energy.removeSeries(energy.requests.lactateProductionRate);
      }
      break;
      case "potassiumLostToSweat":
      if(active){
        energy.requests.potassiumLostToSweat = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.potassiumLostToSweat.axisY.label, energy.axisX, energy.requests.potassiumLostToSweat.axisY);
        energy.requests.potassiumLostToSweat.axisY = energy.axisY(energy.requests.potassiumLostToSweat)
      } else  if  (energy.series(energy.requests.potassiumLostToSweat.axisY.label)){
          energy.removeSeries(energy.requests.potassiumLostToSweat);
      }
      break;
      case "skinTemperature":
      if(active){
        energy.requests.skinTemperature = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.skinTemperature.axisY.label, energy.axisX, energy.requests.skinTemperature.axisY);
        energy.requests.skinTemperature.axisY = energy.axisY(energy.requests.skinTemperature)
      } else  if  (energy.series(energy.requests.skinTemperature.axisY.label)){
          energy.removeSeries(energy.requests.skinTemperature);
      }
      break;
      case "sodiumLostToSweat":
      if(active){
        energy.requests.sodiumLostToSweat = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.sodiumLostToSweat.axisY.label, energy.axisX, energy.requests.sodiumLostToSweat.axisY);
        energy.requests.sodiumLostToSweat.axisY = energy.axisY(energy.requests.sodiumLostToSweat)
      } else  if  (energy.series(energy.requests.sodiumLostToSweat.axisY.label)){
          energy.removeSeries(energy.requests.sodiumLostToSweat);
      }
      break;
      case "sweatRate":
      if(active){
        energy.requests.sweatRate = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.sweatRate.axisY.label, energy.axisX, energy.requests.sweatRate.axisY);
        energy.requests.sweatRate.axisY = energy.axisY(energy.requests.sweatRate)
      } else  if  (energy.series(energy.requests.sweatRate.axisY.label)){
          energy.removeSeries(energy.requests.sweatRate);
      }
      break;
      case "totalMetabolicRate":
      if(active){
        energy.requests.totalMetabolicRate = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.totalMetabolicRate.axisY.label, energy.axisX, energy.requests.totalMetabolicRate.axisY);
        energy.requests.totalMetabolicRate.axisY = energy.axisY(energy.requests.totalMetabolicRate)
      } else  if  (energy.series(energy.requests.totalMetabolicRate.axisY.label)){
          energy.removeSeries(energy.requests.totalMetabolicRate);
      }
      break;
      case "totalWorkRateLevel":
      if(active){
        energy.requests.totalWorkRateLevel = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.totalWorkRateLevel.axisY.label, energy.axisX, energy.requests.totalWorkRateLevel.axisY);
        energy.requests.totalWorkRateLevel.axisY = energy.axisY(energy.requests.totalWorkRateLevel)
      } else  if  (energy.series(energy.requests.totalWorkRateLevel.axisY.label)){
          energy.removeSeries(energy.requests.totalWorkRateLevel);
      }
      break;
    }
  }
  function toggleGastrointestinalSeries(request, active){
    switch(request){
      case "chymeAbsorptionRate":
      if(active){
        gastrointestinal.requests.chymeAbsorptionRate = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.chymeAbsorptionRate.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.chymeAbsorptionRate.axisY);
        gastrointestinal.requests.chymeAbsorptionRate.axisY = gastrointestinal.axisY(gastrointestinal.requests.chymeAbsorptionRate)
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.chymeAbsorptionRate.axisY.label)){
          gastrointestinal.removeSeries(gastrointestinal.requests.chymeAbsorptionRate);
      }
      break;
      case "stomachContents_calcium":
      if(active){
        gastrointestinal.requests.stomachContents_calcium = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_calcium.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_calcium.axisY);
        gastrointestinal.requests.stomachContents_calcium.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_calcium)
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_calcium.axisY.label)){
          gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_calcium);
      }
      break;
      case "stomachContents_carbohydrates":
      if(active){
        gastrointestinal.requests.stomachContents_carbohydrates = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_carbohydrates.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_carbohydrates.axisY);
        gastrointestinal.requests.stomachContents_carbohydrates.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_carbohydrates)
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_carbohydrates.axisY.label)){
          gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_carbohydrates);
      }
      break;
      case "stomachContents_carbohydrateDigationRate":
      if(active){
        gastrointestinal.requests.stomachContents_carbohydrateDigationRate = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_carbohydrateDigationRate.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_carbohydrateDigationRate.axisY);
        gastrointestinal.requests.stomachContents_carbohydrateDigationRate.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_carbohydrateDigationRate)
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_carbohydrateDigationRate.axisY.label)){
          gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_carbohydrateDigationRate);
      }
      break;
      case "stomachContents_fat":
      if(active){
        gastrointestinal.requests.stomachContents_fat = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_fat.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_fat.axisY);
        gastrointestinal.requests.stomachContents_fat.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_fat)
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_fat.axisY.label)){
          gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_fat);
      }
      break;
      case "stomachContents_fatDigtationRate":
      if(active){
        gastrointestinal.requests.stomachContents_fatDigtationRate = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_fatDigtationRate.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_fatDigtationRate.axisY);
        gastrointestinal.requests.stomachContents_fatDigtationRate.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_fatDigtationRate)
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_fatDigtationRate.axisY.label)){
          gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_fatDigtationRate);
      }
      break;
      case "stomachContents_protien":
      if(active){
        gastrointestinal.requests.stomachContents_protien = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_protien.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_protien.axisY);
        gastrointestinal.requests.stomachContents_protien.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_protien)
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_protien.axisY.label)){
          gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_protien);
      }
      break;
      case "stomachContents_protienDigtationRate":
      if(active){
        gastrointestinal.requests.stomachContents_protienDigtationRate = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_protienDigtationRate.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_protienDigtationRate.axisY);
        gastrointestinal.requests.stomachContents_protienDigtationRate.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_protienDigtationRate)
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_protienDigtationRate.axisY.label)){
          gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_protienDigtationRate);
      }
      break;
      case "stomachContents_sodium":
      if(active){
        gastrointestinal.requests.stomachContents_sodium = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_sodium.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_sodium.axisY);
        gastrointestinal.requests.stomachContents_sodium.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_sodium)
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_sodium.axisY.label)){
          gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_sodium);
      }
      break;
      case "stomachContents_water":
      if(active){
        gastrointestinal.requests.stomachContents_water = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_water.axisY.label, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_water.axisY);
        gastrointestinal.requests.stomachContents_water.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_water)
      } else  if  (gastrointestinal.series(gastrointestinal.requests.stomachContents_water.axisY.label)){
          gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_water);
      }
      break;
    }
  }
  function toggleHepaticSeries(request, active){
    switch(request){
      case "chymeAbsorptionRate":
      if(active){
        hepatic.requests.ketoneproductionRate = hepatic.createSeries(ChartView.SeriesTypeLine, hepatic.requests.ketoneproductionRate.axisY.label, hepatic.axisX, hepatic.requests.ketoneproductionRate.axisY);
        hepatic.requests.ketoneproductionRate.axisY = hepatic.axisY(hepatic.requests.ketoneproductionRate)
      } else  if  (hepatic.series(hepatic.requests.ketoneproductionRate.axisY.label)){
          hepatic.removeSeries(hepatic.requests.ketoneproductionRate);
      }
      break;
      case "hepaticGluconeogenesisRate":
      if(active){
        hepatic.requests.hepaticGluconeogenesisRate = hepatic.createSeries(ChartView.SeriesTypeLine, hepatic.requests.hepaticGluconeogenesisRate.axisY.label, hepatic.axisX, hepatic.requests.hepaticGluconeogenesisRate.axisY);
        hepatic.requests.hepaticGluconeogenesisRate.axisY = hepatic.axisY(hepatic.requests.hepaticGluconeogenesisRate)
      } else  if  (hepatic.series(hepatic.requests.hepaticGluconeogenesisRate.axisY.label)){
          hepatic.removeSeries(hepatic.requests.hepaticGluconeogenesisRate);
      }
      break;
    }
  }
  function toggleNervousSeries(request, active){  
    switch(request){
      case "baroreceptorHeartRateScale":
      if(active){
          nervous.requests.baroreceptorHeartRateScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.baroreceptorHeartRateScale.axisY.label, nervous.axisX, nervous.requests.baroreceptorHeartRateScale.axisY);
          nervous.requests.baroreceptorHeartRateScale.axisY = nervous.axisY(nervous.requests.baroreceptorHeartRateScale)
      } else  if  (nervous.series(nervous.requests.baroreceptorHeartRateScale.axisY.label)){
          nervous.removeSeries(nervous.requests.baroreceptorHeartRateScale);
      }
      break;
      case "baroreceptorHeartElastanceScale":
      if(active){
          nervous.requests.baroreceptorHeartElastanceScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.baroreceptorHeartElastanceScale.axisY.label, nervous.axisX, nervous.requests.baroreceptorHeartElastanceScale.axisY);
          nervous.requests.baroreceptorHeartElastanceScale.axisY = nervous.axisY(nervous.requests.baroreceptorHeartElastanceScale)
      } else  if  (nervous.series(nervous.requests.baroreceptorHeartElastanceScale.axisY.label)){
          nervous.removeSeries(nervous.requests.baroreceptorHeartElastanceScale);
      }
      break;
      case "baroreceptorResistanceScale":
      if(active){
          nervous.requests.baroreceptorResistanceScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.baroreceptorResistanceScale.axisY.label, nervous.axisX, nervous.requests.baroreceptorResistanceScale.axisY);
          nervous.requests.baroreceptorResistanceScale.axisY = nervous.axisY(nervous.requests.baroreceptorResistanceScale)
      } else  if  (nervous.series(nervous.requests.baroreceptorResistanceScale.axisY.label)){
          nervous.removeSeries(nervous.requests.baroreceptorResistanceScale);
      }
      break;
      case "baroreceptorComplianceScale":
      if(active){
          nervous.requests.baroreceptorComplianceScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.baroreceptorComplianceScale.axisY.label, nervous.axisX, nervous.requests.baroreceptorComplianceScale.axisY);
          nervous.requests.baroreceptorComplianceScale.axisY = nervous.axisY(nervous.requests.baroreceptorComplianceScale)
      } else  if  (nervous.series(nervous.requests.baroreceptorComplianceScale.axisY.label)){
          nervous.removeSeries(nervous.requests.baroreceptorComplianceScale);
      }
      break;
      case "chemoreceptorHeartRateScale":
      if(active){
          nervous.requests.chemoreceptorHeartRateScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.chemoreceptorHeartRateScale.axisY.label, nervous.axisX, nervous.requests.chemoreceptorHeartRateScale.axisY);
          nervous.requests.chemoreceptorHeartRateScale.axisY = nervous.axisY(nervous.requests.chemoreceptorHeartRateScale)
      } else  if  (nervous.series(nervous.requests.chemoreceptorHeartRateScale.axisY.label)){
          nervous.removeSeries(nervous.requests.chemoreceptorHeartRateScale);
      }
      break;
      case "chemoreceptorHeartElastanceScale":
      if(active){
          nervous.requests.chemoreceptorHeartElastanceScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.chemoreceptorHeartElastanceScale.axisY.label, nervous.axisX, nervous.requests.chemoreceptorHeartElastanceScale.axisY);
          nervous.requests.chemoreceptorHeartElastanceScale.axisY = nervous.axisY(nervous.requests.chemoreceptorHeartElastanceScale)
      } else  if  (nervous.series(nervous.requests.chemoreceptorHeartElastanceScale.axisY.label)){
          nervous.removeSeries(nervous.requests.chemoreceptorHeartElastanceScale);
      }
      break;
      case "painVisualAnalogueScale":
      if(active){
          nervous.requests.painVisualAnalogueScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.painVisualAnalogueScale.axisY.label, nervous.axisX, nervous.requests.painVisualAnalogueScale.axisY);
          nervous.requests.painVisualAnalogueScale.axisY = nervous.axisY(nervous.requests.painVisualAnalogueScale)
      } else  if  (nervous.series(nervous.requests.painVisualAnalogueScale.axisY.label)){
          nervous.removeSeries(nervous.requests.painVisualAnalogueScale);
      }
      break;
      case "leftEyePupillaryResponse":
      if(active){
          nervous.requests.leftEyePupillaryResponse = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.leftEyePupillaryResponse.axisY.label, nervous.axisX, nervous.requests.leftEyePupillaryResponse.axisY);
          nervous.requests.leftEyePupillaryResponse.axisY = nervous.axisY(nervous.requests.leftEyePupillaryResponse)
      } else  if  (nervous.series(nervous.requests.leftEyePupillaryResponse.axisY.label)){
          nervous.removeSeries(nervous.requests.leftEyePupillaryResponse);
      }
      break;
      case "rightEyePupillaryResponse":
      if(active){
          nervous.requests.rightEyePupillaryResponse = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.rightEyePupillaryResponse.axisY.label, nervous.axisX, nervous.requests.rightEyePupillaryResponse.axisY);
          nervous.requests.rightEyePupillaryResponse.axisY = nervous.axisY(nervous.requests.rightEyePupillaryResponse)
      } else  if  (nervous.series(nervous.requests.rightEyePupillaryResponse.axisY.label)){
          nervous.removeSeries(nervous.requests.rightEyePupillaryResponse);
      }
      break;
    } 
  }
  function toggleRenalSeries(request, active){
    switch(request){
      case "glomerularFiltrationRate":
      if(active){
        renal.requests.glomerularFiltrationRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.glomerularFiltrationRate.axisY.label, renal.axisX, renal.requests.glomerularFiltrationRate.axisY);
        renal.requests.glomerularFiltrationRate.axisY = renal.axisY(renal.requests.glomerularFiltrationRate)
      } else  if  (renal.series(renal.requests.glomerularFiltrationRate.axisY.label)){
          renal.removeSeries(renal.requests.glomerularFiltrationRate);
      }
      break;
      case "filtrationFraction":
      if(active){
        renal.requests.filtrationFraction = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.filtrationFraction.axisY.label, renal.axisX, renal.requests.filtrationFraction.axisY);
        renal.requests.filtrationFraction.axisY = renal.axisY(renal.requests.filtrationFraction)
      } else  if  (renal.series(renal.requests.filtrationFraction.axisY.label)){
          renal.removeSeries(renal.requests.filtrationFraction);
      }
      break;
      case "leftAfferentArterioleResistance":
      if(active){
        renal.requests.leftAfferentArterioleResistance = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftAfferentArterioleResistance.axisY.label, renal.axisX, renal.requests.leftAfferentArterioleResistance.axisY);
        renal.requests.leftAfferentArterioleResistance.axisY = renal.axisY(renal.requests.leftAfferentArterioleResistance)
      } else  if  (renal.series(renal.requests.leftAfferentArterioleResistance.axisY.label)){
          renal.removeSeries(renal.requests.leftAfferentArterioleResistance);
      }
      break;
      case "leftBowmansCapsulesHydrostaticPressure":
      if(active){
        renal.requests.leftBowmansCapsulesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftBowmansCapsulesHydrostaticPressure.axisY.label, renal.axisX, renal.requests.leftBowmansCapsulesHydrostaticPressure.axisY);
        renal.requests.leftBowmansCapsulesHydrostaticPressure.axisY = renal.axisY(renal.requests.leftBowmansCapsulesHydrostaticPressure)
      } else  if  (renal.series(renal.requests.leftBowmansCapsulesHydrostaticPressure.axisY.label)){
          renal.removeSeries(renal.requests.leftBowmansCapsulesHydrostaticPressure);
      }
      break;
      case "leftBowmansCapsulesOsmoticPressure":
      if(active){
        renal.requests.leftBowmansCapsulesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftBowmansCapsulesOsmoticPressure.axisY.label, renal.axisX, renal.requests.leftBowmansCapsulesOsmoticPressure.axisY);
        renal.requests.leftBowmansCapsulesOsmoticPressure.axisY = renal.axisY(renal.requests.leftBowmansCapsulesOsmoticPressure)
      } else  if  (renal.series(renal.requests.leftBowmansCapsulesOsmoticPressure.axisY.label)){
          renal.removeSeries(renal.requests.leftBowmansCapsulesOsmoticPressure);
      }
      break;
      case "leftEfferentArterioleResistance":
      if(active){
        renal.requests.leftEfferentArterioleResistance = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftEfferentArterioleResistance.axisY.label, renal.axisX, renal.requests.leftEfferentArterioleResistance.axisY);
        renal.requests.leftEfferentArterioleResistance.axisY = renal.axisY(renal.requests.leftEfferentArterioleResistance)
      } else  if  (renal.series(renal.requests.leftEfferentArterioleResistance.axisY.label)){
          renal.removeSeries(renal.requests.leftEfferentArterioleResistance);
      }
      break;
      case "leftGlomerularCapillariesHydrostaticPressure":
      if(active){
        renal.requests.leftGlomerularCapillariesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularCapillariesHydrostaticPressure.axisY.label, renal.axisX, renal.requests.leftGlomerularCapillariesHydrostaticPressure.axisY);
        renal.requests.leftGlomerularCapillariesHydrostaticPressure.axisY = renal.axisY(renal.requests.leftGlomerularCapillariesHydrostaticPressure)
      } else  if  (renal.series(renal.requests.leftGlomerularCapillariesHydrostaticPressure.axisY.label)){
          renal.removeSeries(renal.requests.leftGlomerularCapillariesHydrostaticPressure);
      }
      break;
      case "leftGlomerularCapillariesOsmoticPressure":
      if(active){
        renal.requests.leftGlomerularCapillariesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularCapillariesOsmoticPressure.axisY.label, renal.axisX, renal.requests.leftGlomerularCapillariesOsmoticPressure.axisY);
        renal.requests.leftGlomerularCapillariesOsmoticPressure.axisY = renal.axisY(renal.requests.leftGlomerularCapillariesOsmoticPressure)
      } else  if  (renal.series(renal.requests.leftGlomerularCapillariesOsmoticPressure.axisY.label)){
          renal.removeSeries(renal.requests.leftGlomerularCapillariesOsmoticPressure);
      }
      break;
      case "leftGlomerularFiltrationCoefficient":
      if(active){
        renal.requests.leftGlomerularFiltrationCoefficient = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularFiltrationCoefficient.axisY.label, renal.axisX, renal.requests.leftGlomerularFiltrationCoefficient.axisY);
        renal.requests.leftGlomerularFiltrationCoefficient.axisY = renal.axisY(renal.requests.leftGlomerularFiltrationCoefficient)
      } else  if  (renal.series(renal.requests.leftGlomerularFiltrationCoefficient.axisY.label)){
          renal.removeSeries(renal.requests.leftGlomerularFiltrationCoefficient);
      }
      break;
      case "leftGlomerularFiltrationRate":
      if(active){
        renal.requests.leftGlomerularFiltrationRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularFiltrationRate.axisY.label, renal.axisX, renal.requests.leftGlomerularFiltrationRate.axisY);
        renal.requests.leftGlomerularFiltrationRate.axisY = renal.axisY(renal.requests.leftGlomerularFiltrationRate)
      } else  if  (renal.series(renal.requests.leftGlomerularFiltrationRate.axisY.label)){
          renal.removeSeries(renal.requests.leftGlomerularFiltrationRate);
      }
      break;
      case "leftGlomerularFiltrationSurfaceArea":
      if(active){
        renal.requests.leftGlomerularFiltrationSurfaceArea = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularFiltrationSurfaceArea.axisY.label, renal.axisX, renal.requests.leftGlomerularFiltrationSurfaceArea.axisY);
        renal.requests.leftGlomerularFiltrationSurfaceArea.axisY = renal.axisY(renal.requests.leftGlomerularFiltrationSurfaceArea)
      } else  if  (renal.series(renal.requests.leftGlomerularFiltrationSurfaceArea.axisY.label)){
          renal.removeSeries(renal.requests.leftGlomerularFiltrationSurfaceArea);
      }
      break;
      case "leftGlomerularFluidPermeability":
      if(active){
        renal.requests.leftGlomerularFluidPermeability = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularFluidPermeability.axisY.label, renal.axisX, renal.requests.leftGlomerularFluidPermeability.axisY);
        renal.requests.leftGlomerularFluidPermeability.axisY = renal.axisY(renal.requests.leftGlomerularFluidPermeability)
      } else  if  (renal.series(renal.requests.leftGlomerularFluidPermeability.axisY.label)){
          renal.removeSeries(renal.requests.leftGlomerularFluidPermeability);
      }
      break;
      case "leftFiltrationFraction":
      if(active){
        renal.requests.leftFiltrationFraction = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftFiltrationFraction.axisY.label, renal.axisX, renal.requests.leftFiltrationFraction.axisY);
        renal.requests.leftFiltrationFraction.axisY = renal.axisY(renal.requests.leftFiltrationFraction)
      } else  if  (renal.series(renal.requests.leftFiltrationFraction.axisY.label)){
          renal.removeSeries(renal.requests.leftFiltrationFraction);
      }
      break;
      case "leftNetFiltrationPressure":
      if(active){
        renal.requests.leftNetFiltrationPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftNetFiltrationPressure.axisY.label, renal.axisX, renal.requests.leftNetFiltrationPressure.axisY);
        renal.requests.leftNetFiltrationPressure.axisY = renal.axisY(renal.requests.leftNetFiltrationPressure)
      } else  if  (renal.series(renal.requests.leftNetFiltrationPressure.axisY.label)){
          renal.removeSeries(renal.requests.leftNetFiltrationPressure);
      }
      break;
      case "leftNetReabsorptionPressure":
      if(active){
        renal.requests.leftNetReabsorptionPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftNetReabsorptionPressure.axisY.label, renal.axisX, renal.requests.leftNetReabsorptionPressure.axisY);
        renal.requests.leftNetReabsorptionPressure.axisY = renal.axisY(renal.requests.leftNetReabsorptionPressure)
      } else  if  (renal.series(renal.requests.leftNetReabsorptionPressure.axisY.label)){
          renal.removeSeries(renal.requests.leftNetReabsorptionPressure);
      }
      break;
      case "leftPeritubularCapillariesHydrostaticPressure":
      if(active){
        renal.requests.leftPeritubularCapillariesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftPeritubularCapillariesHydrostaticPressure.axisY.label, renal.axisX, renal.requests.leftPeritubularCapillariesHydrostaticPressure.axisY);
        renal.requests.leftPeritubularCapillariesHydrostaticPressure.axisY = renal.axisY(renal.requests.leftPeritubularCapillariesHydrostaticPressure)
      } else  if  (renal.series(renal.requests.leftPeritubularCapillariesHydrostaticPressure.axisY.label)){
          renal.removeSeries(renal.requests.leftPeritubularCapillariesHydrostaticPressure);
      }
      break;
      case "leftPeritubularCapillariesOsmoticPressure":
      if(active){
        renal.requests.leftPeritubularCapillariesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftPeritubularCapillariesOsmoticPressure.axisY.label, renal.axisX, renal.requests.leftPeritubularCapillariesOsmoticPressure.axisY);
        renal.requests.leftPeritubularCapillariesOsmoticPressure.axisY = renal.axisY(renal.requests.leftPeritubularCapillariesOsmoticPressure)
      } else  if  (renal.series(renal.requests.leftPeritubularCapillariesOsmoticPressure.axisY.label)){
          renal.removeSeries(renal.requests.leftPeritubularCapillariesOsmoticPressure);
      }
      break;
      case "leftReabsorptionFiltrationCoefficient":
      if(active){
        renal.requests.leftReabsorptionFiltrationCoefficient = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftReabsorptionFiltrationCoefficient.axisY.label, renal.axisX, renal.requests.leftReabsorptionFiltrationCoefficient.axisY);
        renal.requests.leftReabsorptionFiltrationCoefficient.axisY = renal.axisY(renal.requests.leftReabsorptionFiltrationCoefficient)
      } else  if  (renal.series(renal.requests.leftReabsorptionFiltrationCoefficient.axisY.label)){
          renal.removeSeries(renal.requests.leftReabsorptionFiltrationCoefficient);
      }
      break;
      case "leftReabsorptionRate":
      if(active){
        renal.requests.leftReabsorptionRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftReabsorptionRate.axisY.label, renal.axisX, renal.requests.leftReabsorptionRate.axisY);
        renal.requests.leftReabsorptionRate.axisY = renal.axisY(renal.requests.leftReabsorptionRate)
      } else  if  (renal.series(renal.requests.leftReabsorptionRate.axisY.label)){
          renal.removeSeries(renal.requests.leftReabsorptionRate);
      }
      break;
      case "leftTubularReabsorptionFiltrationSurfaceArea":
      if(active){
        renal.requests.leftTubularReabsorptionFiltrationSurfaceArea = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.axisY.label, renal.axisX, renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.axisY);
        renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.axisY = renal.axisY(renal.requests.leftTubularReabsorptionFiltrationSurfaceArea)
      } else  if  (renal.series(renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.axisY.label)){
          renal.removeSeries(renal.requests.leftTubularReabsorptionFiltrationSurfaceArea);
      }
      break;
      case "leftTubularReabsorptionFluidPermeability":
      if(active){
        renal.requests.leftTubularReabsorptionFluidPermeability = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftTubularReabsorptionFluidPermeability.axisY.label, renal.axisX, renal.requests.leftTubularReabsorptionFluidPermeability.axisY);
        renal.requests.leftTubularReabsorptionFluidPermeability.axisY = renal.axisY(renal.requests.leftTubularReabsorptionFluidPermeability)
      } else  if  (renal.series(renal.requests.leftTubularReabsorptionFluidPermeability.axisY.label)){
          renal.removeSeries(renal.requests.leftTubularReabsorptionFluidPermeability);
      }
      break;
      case "leftTubularHydrostaticPressure":
      if(active){
        renal.requests.leftTubularHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftTubularHydrostaticPressure.axisY.label, renal.axisX, renal.requests.leftTubularHydrostaticPressure.axisY);
        renal.requests.leftTubularHydrostaticPressure.axisY = renal.axisY(renal.requests.leftTubularHydrostaticPressure)
      } else  if  (renal.series(renal.requests.leftTubularHydrostaticPressure.axisY.label)){
          renal.removeSeries(renal.requests.leftTubularHydrostaticPressure);
      }
      break;
      case "leftTubularOsmoticPressure":
      if(active){
        renal.requests.leftTubularOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftTubularOsmoticPressure.axisY.label, renal.axisX, renal.requests.leftTubularOsmoticPressure.axisY);
        renal.requests.leftTubularOsmoticPressure.axisY = renal.axisY(renal.requests.leftTubularOsmoticPressure)
      } else  if  (renal.series(renal.requests.leftTubularOsmoticPressure.axisY.label)){
          renal.removeSeries(renal.requests.leftTubularOsmoticPressure);
      }
      break;
      case "renalBloodFlow":
      if(active){
        renal.requests.renalBloodFlow = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.renalBloodFlow.axisY.label, renal.axisX, renal.requests.renalBloodFlow.axisY);
        renal.requests.renalBloodFlow.axisY = renal.axisY(renal.requests.renalBloodFlow)
      } else  if  (renal.series(renal.requests.renalBloodFlow.axisY.label)){
          renal.removeSeries(renal.requests.renalBloodFlow);
      }
      break;
      case "renalPlasmaFlow":
      if(active){
        renal.requests.renalPlasmaFlow = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.renalPlasmaFlow.axisY.label, renal.axisX, renal.requests.renalPlasmaFlow.axisY);
        renal.requests.renalPlasmaFlow.axisY = renal.axisY(renal.requests.renalPlasmaFlow)
      } else  if  (renal.series(renal.requests.renalPlasmaFlow.axisY.label)){
          renal.removeSeries(renal.requests.renalPlasmaFlow);
      }
      break;
      case "renalVascularResistance":
      if(active){
        renal.requests.renalVascularResistance = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.renalVascularResistance.axisY.label, renal.axisX, renal.requests.renalVascularResistance.axisY);
        renal.requests.renalVascularResistance.axisY = renal.axisY(renal.requests.renalVascularResistance)
      } else  if  (renal.series(renal.requests.renalVascularResistance.axisY.label)){
          renal.removeSeries(renal.requests.renalVascularResistance);
      }
      break;
      case "rightAfferentArterioleResistance":
      if(active){
        renal.requests.rightAfferentArterioleResistance = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightAfferentArterioleResistance.axisY.label, renal.axisX, renal.requests.rightAfferentArterioleResistance.axisY);
        renal.requests.rightAfferentArterioleResistance.axisY = renal.axisY(renal.requests.rightAfferentArterioleResistance)
      } else  if  (renal.series(renal.requests.rightAfferentArterioleResistance.axisY.label)){
          renal.removeSeries(renal.requests.rightAfferentArterioleResistance);
      }
      break;
      case "rightBowmansCapsulesHydrostaticPressure":
      if(active){
        renal.requests.rightBowmansCapsulesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightBowmansCapsulesHydrostaticPressure.axisY.label, renal.axisX, renal.requests.rightBowmansCapsulesHydrostaticPressure.axisY);
        renal.requests.rightBowmansCapsulesHydrostaticPressure.axisY = renal.axisY(renal.requests.rightBowmansCapsulesHydrostaticPressure)
      } else  if  (renal.series(renal.requests.rightBowmansCapsulesHydrostaticPressure.axisY.label)){
          renal.removeSeries(renal.requests.rightBowmansCapsulesHydrostaticPressure);
      }
      break;
      case "rightBowmansCapsulesOsmoticPressure":
      if(active){
        renal.requests.rightBowmansCapsulesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightBowmansCapsulesOsmoticPressure.axisY.label, renal.axisX, renal.requests.rightBowmansCapsulesOsmoticPressure.axisY);
        renal.requests.rightBowmansCapsulesOsmoticPressure.axisY = renal.axisY(renal.requests.rightBowmansCapsulesOsmoticPressure)
      } else  if  (renal.series(renal.requests.rightBowmansCapsulesOsmoticPressure.axisY.label)){
          renal.removeSeries(renal.requests.rightBowmansCapsulesOsmoticPressure);
      }
      break;
      case "rightEfferentArterioleResistance":
      if(active){
        renal.requests.rightEfferentArterioleResistance = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightEfferentArterioleResistance.axisY.label, renal.axisX, renal.requests.rightEfferentArterioleResistance.axisY);
        renal.requests.rightEfferentArterioleResistance.axisY = renal.axisY(renal.requests.rightEfferentArterioleResistance)
      } else  if  (renal.series(renal.requests.rightEfferentArterioleResistance.axisY.label)){
          renal.removeSeries(renal.requests.rightEfferentArterioleResistance);
      }
      break;
      case "rightGlomerularCapillariesHydrostaticPressure":
      if(active){
        renal.requests.rightGlomerularCapillariesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularCapillariesHydrostaticPressure.axisY.label, renal.axisX, renal.requests.rightGlomerularCapillariesHydrostaticPressure.axisY);
        renal.requests.rightGlomerularCapillariesHydrostaticPressure.axisY = renal.axisY(renal.requests.rightGlomerularCapillariesHydrostaticPressure)
      } else  if  (renal.series(renal.requests.rightGlomerularCapillariesHydrostaticPressure.axisY.label)){
          renal.removeSeries(renal.requests.rightGlomerularCapillariesHydrostaticPressure);
      }
      break;
      case "rightGlomerularCapillariesOsmoticPressure":
      if(active){
        renal.requests.rightGlomerularCapillariesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularCapillariesOsmoticPressure.axisY.label, renal.axisX, renal.requests.rightGlomerularCapillariesOsmoticPressure.axisY);
        renal.requests.rightGlomerularCapillariesOsmoticPressure.axisY = renal.axisY(renal.requests.rightGlomerularCapillariesOsmoticPressure)
      } else  if  (renal.series(renal.requests.rightGlomerularCapillariesOsmoticPressure.axisY.label)){
          renal.removeSeries(renal.requests.rightGlomerularCapillariesOsmoticPressure);
      }
      break;
      case "rightGlomerularFiltrationCoefficient":
      if(active){
        renal.requests.rightGlomerularFiltrationCoefficient = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularFiltrationCoefficient.axisY.label, renal.axisX, renal.requests.rightGlomerularFiltrationCoefficient.axisY);
        renal.requests.rightGlomerularFiltrationCoefficient.axisY = renal.axisY(renal.requests.rightGlomerularFiltrationCoefficient)
      } else  if  (renal.series(renal.requests.rightGlomerularFiltrationCoefficient.axisY.label)){
          renal.removeSeries(renal.requests.rightGlomerularFiltrationCoefficient);
      }
      break;
      case "rightGlomerularFiltrationRate":
      if(active){
        renal.requests.rightGlomerularFiltrationRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularFiltrationRate.axisY.label, renal.axisX, renal.requests.rightGlomerularFiltrationRate.axisY);
        renal.requests.rightGlomerularFiltrationRate.axisY = renal.axisY(renal.requests.rightGlomerularFiltrationRate)
      } else  if  (renal.series(renal.requests.rightGlomerularFiltrationRate.axisY.label)){
          renal.removeSeries(renal.requests.rightGlomerularFiltrationRate);
      }
      break;
      case "rightGlomerularFiltrationSurfaceArea":
      if(active){
        renal.requests.rightGlomerularFiltrationSurfaceArea = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularFiltrationSurfaceArea.axisY.label, renal.axisX, renal.requests.rightGlomerularFiltrationSurfaceArea.axisY);
        renal.requests.rightGlomerularFiltrationSurfaceArea.axisY = renal.axisY(renal.requests.rightGlomerularFiltrationSurfaceArea)
      } else  if  (renal.series(renal.requests.rightGlomerularFiltrationSurfaceArea.axisY.label)){
          renal.removeSeries(renal.requests.rightGlomerularFiltrationSurfaceArea);
      }
      break;
      case "rightGlomerularFluidPermeability":
      if(active){
        renal.requests.rightGlomerularFluidPermeability = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularFluidPermeability.axisY.label, renal.axisX, renal.requests.rightGlomerularFluidPermeability.axisY);
        renal.requests.rightGlomerularFluidPermeability.axisY = renal.axisY(renal.requests.rightGlomerularFluidPermeability)
      } else  if  (renal.series(renal.requests.rightGlomerularFluidPermeability.axisY.label)){
          renal.removeSeries(renal.requests.rightGlomerularFluidPermeability);
      }
      break;
      case "rightFiltrationFraction":
      if(active){
        renal.requests.rightFiltrationFraction = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightFiltrationFraction.axisY.label, renal.axisX, renal.requests.rightFiltrationFraction.axisY);
        renal.requests.rightFiltrationFraction.axisY = renal.axisY(renal.requests.rightFiltrationFraction)
      } else  if  (renal.series(renal.requests.rightFiltrationFraction.axisY.label)){
          renal.removeSeries(renal.requests.rightFiltrationFraction);
      }
      break;
      case "rightNetFiltrationPressure":
      if(active){
        renal.requests.rightNetFiltrationPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightNetFiltrationPressure.axisY.label, renal.axisX, renal.requests.rightNetFiltrationPressure.axisY);
        renal.requests.rightNetFiltrationPressure.axisY = renal.axisY(renal.requests.rightNetFiltrationPressure)
      } else  if  (renal.series(renal.requests.rightNetFiltrationPressure.axisY.label)){
          renal.removeSeries(renal.requests.rightNetFiltrationPressure);
      }
      break;
      case "rightNetReabsorptionPressure":
      if(active){
        renal.requests.rightNetReabsorptionPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightNetReabsorptionPressure.axisY.label, renal.axisX, renal.requests.rightNetReabsorptionPressure.axisY);
        renal.requests.rightNetReabsorptionPressure.axisY = renal.axisY(renal.requests.rightNetReabsorptionPressure)
      } else  if  (renal.series(renal.requests.rightNetReabsorptionPressure.axisY.label)){
          renal.removeSeries(renal.requests.rightNetReabsorptionPressure);
      }
      break;
      case "rightPeritubularCapillariesHydrostaticPressure":
      if(active){
        renal.requests.rightPeritubularCapillariesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightPeritubularCapillariesHydrostaticPressure.axisY.label, renal.axisX, renal.requests.rightPeritubularCapillariesHydrostaticPressure.axisY);
        renal.requests.rightPeritubularCapillariesHydrostaticPressure.axisY = renal.axisY(renal.requests.rightPeritubularCapillariesHydrostaticPressure)
      } else  if  (renal.series(renal.requests.rightPeritubularCapillariesHydrostaticPressure.axisY.label)){
          renal.removeSeries(renal.requests.rightPeritubularCapillariesHydrostaticPressure);
      }
      break;
      case "rightPeritubularCapillariesOsmoticPressure":
      if(active){
        renal.requests.rightPeritubularCapillariesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightPeritubularCapillariesOsmoticPressure.axisY.label, renal.axisX, renal.requests.rightPeritubularCapillariesOsmoticPressure.axisY);
        renal.requests.rightPeritubularCapillariesOsmoticPressure.axisY = renal.axisY(renal.requests.rightPeritubularCapillariesOsmoticPressure)
      } else  if  (renal.series(renal.requests.rightPeritubularCapillariesOsmoticPressure.axisY.label)){
          renal.removeSeries(renal.requests.rightPeritubularCapillariesOsmoticPressure);
      }
      break;
      case "rightReabsorptionFiltrationCoefficient":
      if(active){
        renal.requests.rightReabsorptionFiltrationCoefficient = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightReabsorptionFiltrationCoefficient.axisY.label, renal.axisX, renal.requests.rightReabsorptionFiltrationCoefficient.axisY);
        renal.requests.rightReabsorptionFiltrationCoefficient.axisY = renal.axisY(renal.requests.rightReabsorptionFiltrationCoefficient)
      } else  if  (renal.series(renal.requests.rightReabsorptionFiltrationCoefficient.axisY.label)){
          renal.removeSeries(renal.requests.rightReabsorptionFiltrationCoefficient);
      }
      break;
      case "rightReabsorptionRate":
      if(active){
        renal.requests.rightReabsorptionRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightReabsorptionRate.axisY.label, renal.axisX, renal.requests.rightReabsorptionRate.axisY);
        renal.requests.rightReabsorptionRate.axisY = renal.axisY(renal.requests.rightReabsorptionRate)
      } else  if  (renal.series(renal.requests.rightReabsorptionRate.axisY.label)){
          renal.removeSeries(renal.requests.rightReabsorptionRate);
      }
      break;
      case "rightTubularReabsorptionFiltrationSurfaceArea":
      if(active){
        renal.requests.rightTubularReabsorptionFiltrationSurfaceArea = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.axisY.label, renal.axisX, renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.axisY);
        renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.axisY = renal.axisY(renal.requests.rightTubularReabsorptionFiltrationSurfaceArea)
      } else  if  (renal.series(renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.axisY.label)){
          renal.removeSeries(renal.requests.rightTubularReabsorptionFiltrationSurfaceArea);
      }
      break;
      case "rightTubularReabsorptionFluidPermeability":
      if(active){
        renal.requests.rightTubularReabsorptionFluidPermeability = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightTubularReabsorptionFluidPermeability.axisY.label, renal.axisX, renal.requests.rightTubularReabsorptionFluidPermeability.axisY);
        renal.requests.rightTubularReabsorptionFluidPermeability.axisY = renal.axisY(renal.requests.rightTubularReabsorptionFluidPermeability)
      } else  if  (renal.series(renal.requests.rightTubularReabsorptionFluidPermeability.axisY.label)){
          renal.removeSeries(renal.requests.rightTubularReabsorptionFluidPermeability);
      }
      break;
      case "rightTubularHydrostaticPressure":
      if(active){
        renal.requests.rightTubularHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightTubularHydrostaticPressure.axisY.label, renal.axisX, renal.requests.rightTubularHydrostaticPressure.axisY);
        renal.requests.rightTubularHydrostaticPressure.axisY = renal.axisY(renal.requests.rightTubularHydrostaticPressure)
      } else  if  (renal.series(renal.requests.rightTubularHydrostaticPressure.axisY.label)){
          renal.removeSeries(renal.requests.rightTubularHydrostaticPressure);
      }
      break;
      case "rightTubularOsmoticPressure":
      if(active){
        renal.requests.rightTubularOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightTubularOsmoticPressure.axisY.label, renal.axisX, renal.requests.rightTubularOsmoticPressure.axisY);
        renal.requests.rightTubularOsmoticPressure.axisY = renal.axisY(renal.requests.rightTubularOsmoticPressure)
      } else  if  (renal.series(renal.requests.rightTubularOsmoticPressure.axisY.label)){
          renal.removeSeries(renal.requests.rightTubularOsmoticPressure);
      }
      break;
      case "urinationRate":
      if(active){
        renal.requests.urinationRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urinationRate.axisY.label, renal.axisX, renal.requests.urinationRate.axisY);
        renal.requests.urinationRate.axisY = renal.axisY(renal.requests.urinationRate)
      } else  if  (renal.series(renal.requests.urinationRate.axisY.label)){
          renal.removeSeries(renal.requests.urinationRate);
      }
      break;
      case "urineOsmolality":
      if(active){
        renal.requests.urineOsmolality = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineOsmolality.axisY.label, renal.axisX, renal.requests.urineOsmolality.axisY);
        renal.requests.urineOsmolality.axisY = renal.axisY(renal.requests.urineOsmolality)
      } else  if  (renal.series(renal.requests.urineOsmolality.axisY.label)){
          renal.removeSeries(renal.requests.urineOsmolality);
      }
      break;
      case "urineOsmolarity":
      if(active){
        renal.requests.urineOsmolarity = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineOsmolarity.axisY.label, renal.axisX, renal.requests.urineOsmolarity.axisY);
        renal.requests.urineOsmolarity.axisY = renal.axisY(renal.requests.urineOsmolarity)
      } else  if  (renal.series(renal.requests.urineOsmolarity.axisY.label)){
          renal.removeSeries(renal.requests.urineOsmolarity);
      }
      break;
      case "urineProductionRate":
      if(active){
        renal.requests.urineProductionRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineProductionRate.axisY.label, renal.axisX, renal.requests.urineProductionRate.axisY);
        renal.requests.urineProductionRate.axisY = renal.axisY(renal.requests.urineProductionRate)
      } else  if  (renal.series(renal.requests.urineProductionRate.axisY.label)){
          renal.removeSeries(renal.requests.urineProductionRate);
      }
      break;
      case "meanUrineOutput":
      if(active){
        renal.requests.meanUrineOutput = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.meanUrineOutput.axisY.label, renal.axisX, renal.requests.meanUrineOutput.axisY);
        renal.requests.meanUrineOutput.axisY = renal.axisY(renal.requests.meanUrineOutput)
      } else  if  (renal.series(renal.requests.meanUrineOutput.axisY.label)){
          renal.removeSeries(renal.requests.meanUrineOutput);
      }
      break;
      case "urineSpecificGravity":
      if(active){
        renal.requests.urineSpecificGravity = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineSpecificGravity.axisY.label, renal.axisX, renal.requests.urineSpecificGravity.axisY);
        renal.requests.urineSpecificGravity.axisY = renal.axisY(renal.requests.urineSpecificGravity)
      } else  if  (renal.series(renal.requests.urineSpecificGravity.axisY.label)){
          renal.removeSeries(renal.requests.urineSpecificGravity);
      }
      break;
      case "urineVolume":
      if(active){
        renal.requests.urineVolume = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineVolume.axisY.label, renal.axisX, renal.requests.urineVolume.axisY);
        renal.requests.urineVolume.axisY = renal.axisY(renal.requests.urineVolume)
      } else  if  (renal.series(renal.requests.urineVolume.axisY.label)){
          renal.removeSeries(renal.requests.urineVolume);
      }
      break;
      case "urineUreaNitrogenConcentration":
      if(active){
        renal.requests.urineUreaNitrogenConcentration = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineUreaNitrogenConcentration.axisY.label, renal.axisX, renal.requests.urineUreaNitrogenConcentration.axisY);
        renal.requests.urineUreaNitrogenConcentration.axisY = renal.axisY(renal.requests.urineUreaNitrogenConcentration)
      } else  if  (renal.series(renal.requests.urineUreaNitrogenConcentration.axisY.label)){
          renal.removeSeries(renal.requests.urineUreaNitrogenConcentration);
      }
      break;
    }
  }
  function toggleRespiratorySeries(request, active){
    switch(request){
      case "alveolarArterialGradient":
      if(active){
        respiratory.requests.alveolarArterialGradient = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.alveolarArterialGradient.axisY.label, respiratory.axisX, respiratory.requests.alveolarArterialGradient.axisY);
        respiratory.requests.alveolarArterialGradient.axisY = respiratory.axisY(respiratory.requests.alveolarArterialGradient)
      } else  if  (respiratory.series(respiratory.requests.alveolarArterialGradient.axisY.label)){
          respiratory.removeSeries(respiratory.requests.alveolarArterialGradient);
      }
      break;
      case "carricoIndex":
      if(active){
        respiratory.requests.carricoIndex = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.carricoIndex.axisY.label, respiratory.axisX, respiratory.requests.carricoIndex.axisY);
        respiratory.requests.carricoIndex.axisY = respiratory.axisY(respiratory.requests.carricoIndex)
      } else  if  (respiratory.series(respiratory.requests.carricoIndex.axisY.label)){
          respiratory.removeSeries(respiratory.requests.carricoIndex);
      }
      break;
      case "endTidalCarbonDioxideFraction":
      if(active){
        respiratory.requests.endTidalCarbonDioxideFraction = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.endTidalCarbonDioxideFraction.axisY.label, respiratory.axisX, respiratory.requests.endTidalCarbonDioxideFraction.axisY);
        respiratory.requests.endTidalCarbonDioxideFraction.axisY = respiratory.axisY(respiratory.requests.endTidalCarbonDioxideFraction)
      } else  if  (respiratory.series(respiratory.requests.endTidalCarbonDioxideFraction.axisY.label)){
          respiratory.removeSeries(respiratory.requests.endTidalCarbonDioxideFraction);
      }
      break;
      case "endTidalCarbonDioxidePressure":
      if(active){
        respiratory.requests.endTidalCarbonDioxidePressure = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.endTidalCarbonDioxidePressure.axisY.label, respiratory.axisX, respiratory.requests.endTidalCarbonDioxidePressure.axisY);
        respiratory.requests.endTidalCarbonDioxidePressure.axisY = respiratory.axisY(respiratory.requests.endTidalCarbonDioxidePressure)
      } else  if  (respiratory.series(respiratory.requests.endTidalCarbonDioxidePressure.axisY.label)){
          respiratory.removeSeries(respiratory.requests.endTidalCarbonDioxidePressure);
      }
      break;
      case "expiratoryFlow":
      if(active){
        respiratory.requests.expiratoryFlow = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.expiratoryFlow.axisY.label, respiratory.axisX, respiratory.requests.expiratoryFlow.axisY);
        respiratory.requests.expiratoryFlow.axisY = respiratory.axisY(respiratory.requests.expiratoryFlow)
      } else  if  (respiratory.series(respiratory.requests.expiratoryFlow.axisY.label)){
          respiratory.removeSeries(respiratory.requests.expiratoryFlow);
      }
      break;
      case "inspiratoryExpiratoryRatio":
      if(active){
        respiratory.requests.inspiratoryExpiratoryRatio = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.inspiratoryExpiratoryRatio.axisY.label, respiratory.axisX, respiratory.requests.inspiratoryExpiratoryRatio.axisY);
        respiratory.requests.inspiratoryExpiratoryRatio.axisY = respiratory.axisY(respiratory.requests.inspiratoryExpiratoryRatio)
      } else  if  (respiratory.series(respiratory.requests.inspiratoryExpiratoryRatio.axisY.label)){
          respiratory.removeSeries(respiratory.requests.inspiratoryExpiratoryRatio);
      }
      break;
      case "inspiratoryFlow":
      if(active){
        respiratory.requests.inspiratoryFlow = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.inspiratoryFlow.axisY.label, respiratory.axisX, respiratory.requests.inspiratoryFlow.axisY);
        respiratory.requests.inspiratoryFlow.axisY = respiratory.axisY(respiratory.requests.inspiratoryFlow)
      } else  if  (respiratory.series(respiratory.requests.inspiratoryFlow.axisY.label)){
          respiratory.removeSeries(respiratory.requests.inspiratoryFlow);
      }
      break;
      case "pulmonaryCompliance":
      if(active){
        respiratory.requests.pulmonaryCompliance = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.pulmonaryCompliance.axisY.label, respiratory.axisX, respiratory.requests.pulmonaryCompliance.axisY);
        respiratory.requests.pulmonaryCompliance.axisY = respiratory.axisY(respiratory.requests.pulmonaryCompliance)
      } else  if  (respiratory.series(respiratory.requests.pulmonaryCompliance.axisY.label)){
          respiratory.removeSeries(respiratory.requests.pulmonaryCompliance);
      }
      break;
      case "pulmonaryResistance":
      if(active){
        respiratory.requests.pulmonaryResistance = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.pulmonaryResistance.axisY.label, respiratory.axisX, respiratory.requests.pulmonaryResistance.axisY);
        respiratory.requests.pulmonaryResistance.axisY = respiratory.axisY(respiratory.requests.pulmonaryResistance)
      } else  if  (respiratory.series(respiratory.requests.pulmonaryResistance.axisY.label)){
          respiratory.removeSeries(respiratory.requests.pulmonaryResistance);
      }
      break;
      case "respirationDriverPressure":
      if(active){
        respiratory.requests.respirationDriverPressure = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.respirationDriverPressure.axisY.label, respiratory.axisX, respiratory.requests.respirationDriverPressure.axisY);
        respiratory.requests.respirationDriverPressure.axisY = respiratory.axisY(respiratory.requests.respirationDriverPressure)
      } else  if  (respiratory.series(respiratory.requests.respirationDriverPressure.axisY.label)){
          respiratory.removeSeries(respiratory.requests.respirationDriverPressure);
      }
      break;
      case "respirationMusclePressure":
      if(active){
        respiratory.requests.respirationMusclePressure = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.respirationMusclePressure.axisY.label, respiratory.axisX, respiratory.requests.respirationMusclePressure.axisY);
        respiratory.requests.respirationMusclePressure.axisY = respiratory.axisY(respiratory.requests.respirationMusclePressure)
      } else  if  (respiratory.series(respiratory.requests.respirationMusclePressure.axisY.label)){
          respiratory.removeSeries(respiratory.requests.respirationMusclePressure);
      }
      break;
      case "respirationRate":
      if(active){
        respiratory.requests.respirationRate = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.respirationRate.axisY.label, respiratory.axisX, respiratory.requests.respirationRate.axisY);
        respiratory.requests.respirationRate.axisY = respiratory.axisY(respiratory.requests.respirationRate)
      } else  if  (respiratory.series(respiratory.requests.respirationRate.axisY.label)){
          respiratory.removeSeries(respiratory.requests.respirationRate);
      }
      break;
      case "specificVentilation":
      if(active){
        respiratory.requests.specificVentilation = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.specificVentilation.axisY.label, respiratory.axisX, respiratory.requests.specificVentilation.axisY);
        respiratory.requests.specificVentilation.axisY = respiratory.axisY(respiratory.requests.specificVentilation)
      } else  if  (respiratory.series(respiratory.requests.specificVentilation.axisY.label)){
          respiratory.removeSeries(respiratory.requests.specificVentilation);
      }
      break;
      case "targetPulmonaryVentilation":
      if(active){
        respiratory.requests.targetPulmonaryVentilation = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.targetPulmonaryVentilation.axisY.label, respiratory.axisX, respiratory.requests.targetPulmonaryVentilation.axisY);
        respiratory.requests.targetPulmonaryVentilation.axisY = respiratory.axisY(respiratory.requests.targetPulmonaryVentilation)
      } else  if  (respiratory.series(respiratory.requests.targetPulmonaryVentilation.axisY.label)){
          respiratory.removeSeries(respiratory.requests.targetPulmonaryVentilation);
      }
      break;
      case "tidalVolume":
      if(active){
        respiratory.requests.tidalVolume = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.tidalVolume.axisY.label, respiratory.axisX, respiratory.requests.tidalVolume.axisY);
        respiratory.requests.tidalVolume.axisY = respiratory.axisY(respiratory.requests.tidalVolume)
      } else  if  (respiratory.series(respiratory.requests.tidalVolume.axisY.label)){
          respiratory.removeSeries(respiratory.requests.tidalVolume);
      }
      break;
      case "totalAlveolarVentilation":
      if(active){
        respiratory.requests.totalAlveolarVentilation = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.totalAlveolarVentilation.axisY.label, respiratory.axisX, respiratory.requests.totalAlveolarVentilation.axisY);
        respiratory.requests.totalAlveolarVentilation.axisY = respiratory.axisY(respiratory.requests.totalAlveolarVentilation)
      } else  if  (respiratory.series(respiratory.requests.totalAlveolarVentilation.axisY.label)){
          respiratory.removeSeries(respiratory.requests.totalAlveolarVentilation);
      }
      break;
      case "totalDeadSpaceVentilation":
      if(active){
        respiratory.requests.totalDeadSpaceVentilation = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.totalDeadSpaceVentilation.axisY.label, respiratory.axisX, respiratory.requests.totalDeadSpaceVentilation.axisY);
        respiratory.requests.totalDeadSpaceVentilation.axisY = respiratory.axisY(respiratory.requests.totalDeadSpaceVentilation)
      } else  if  (respiratory.series(respiratory.requests.totalDeadSpaceVentilation.axisY.label)){
          respiratory.removeSeries(respiratory.requests.totalDeadSpaceVentilation);
      }
      break;
      case "totalLungVolume":
      if(active){
        respiratory.requests.totalLungVolume = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.totalLungVolume.axisY.label, respiratory.axisX, respiratory.requests.totalLungVolume.axisY);
        respiratory.requests.totalLungVolume.axisY = respiratory.axisY(respiratory.requests.totalLungVolume)
      } else  if  (respiratory.series(respiratory.requests.totalLungVolume.axisY.label)){
          respiratory.removeSeries(respiratory.requests.totalLungVolume);
      }
      break;
      case "totalPulmonaryVentilation":
      if(active){
        respiratory.requests.totalPulmonaryVentilation = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.totalPulmonaryVentilation.axisY.label, respiratory.axisX, respiratory.requests.totalPulmonaryVentilation.axisY);
        respiratory.requests.totalPulmonaryVentilation.axisY = respiratory.axisY(respiratory.requests.totalPulmonaryVentilation)
      } else  if  (respiratory.series(respiratory.requests.totalPulmonaryVentilation.axisY.label)){
          respiratory.removeSeries(respiratory.requests.totalPulmonaryVentilation);
      }
      break;
      case "transpulmonaryPressure":
      if(active){
        respiratory.requests.transpulmonaryPressure = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.transpulmonaryPressure.axisY.label, respiratory.axisX, respiratory.requests.transpulmonaryPressure.axisY);
        respiratory.requests.transpulmonaryPressure.axisY = respiratory.axisY(respiratory.requests.transpulmonaryPressure)
      } else  if  (respiratory.series(respiratory.requests.transpulmonaryPressure.axisY.label)){
          respiratory.removeSeries(respiratory.requests.transpulmonaryPressure);
      }
      break;
    }
  }
  function toggleTissueSeries(request, active){
    switch(request){
      case "carbonDioxideProductionRate":
      if(active){
        tissue.requests.carbonDioxideProductionRate = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.carbonDioxideProductionRate.axisY.label, tissue.axisX, tissue.requests.carbonDioxideProductionRate.axisY);
        tissue.requests.carbonDioxideProductionRate.axisY = tissue.axisY(tissue.requests.carbonDioxideProductionRate)
      } else  if  (tissue.series(tissue.requests.transpulmonaryPressure.axisY.label)){
          tissue.removeSeries(tissue.requests.transpulmonaryPressure);
      }
      break;
      case "dehydrationFraction":
      if(active){
        tissue.requests.dehydrationFraction = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.dehydrationFraction.axisY.label, tissue.axisX, tissue.requests.dehydrationFraction.axisY);
        tissue.requests.dehydrationFraction.axisY = tissue.axisY(tissue.requests.dehydrationFraction)
      } else  if  (tissue.series(tissue.requests.dehydrationFraction.axisY.label)){
          tissue.removeSeries(tissue.requests.dehydrationFraction);
      }
      break;
      case "extracellularFluidVolume":
      if(active){
        tissue.requests.extracellularFluidVolume = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.extracellularFluidVolume.axisY.label, tissue.axisX, tissue.requests.extracellularFluidVolume.axisY);
        tissue.requests.extracellularFluidVolume.axisY = tissue.axisY(tissue.requests.extracellularFluidVolume)
      } else  if  (tissue.series(tissue.requests.extracellularFluidVolume.axisY.label)){
          tissue.removeSeries(tissue.requests.extracellularFluidVolume);
      }
      break;
      case "extravascularFluidVolume":
      if(active){
        tissue.requests.extravascularFluidVolume = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.extravascularFluidVolume.axisY.label, tissue.axisX, tissue.requests.extravascularFluidVolume.axisY);
        tissue.requests.extravascularFluidVolume.axisY = tissue.axisY(tissue.requests.extravascularFluidVolume)
      } else  if  (tissue.series(tissue.requests.extravascularFluidVolume.axisY.label)){
          tissue.removeSeries(tissue.requests.extravascularFluidVolume);
      }
      break;
      case "intracellularFluidPH":
      if(active){
        tissue.requests.intracellularFluidPH = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.intracellularFluidPH.axisY.label, tissue.axisX, tissue.requests.intracellularFluidPH.axisY);
        tissue.requests.intracellularFluidPH.axisY = tissue.axisY(tissue.requests.intracellularFluidPH)
      } else  if  (tissue.series(tissue.requests.intracellularFluidPH.axisY.label)){
          tissue.removeSeries(tissue.requests.intracellularFluidPH);
      }
      break;
      case "intracellularFluidVolume":
      if(active){
        tissue.requests.intracellularFluidVolume = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.intracellularFluidVolume.axisY.label, tissue.axisX, tissue.requests.intracellularFluidVolume.axisY);
        tissue.requests.intracellularFluidVolume.axisY = tissue.axisY(tissue.requests.intracellularFluidVolume)
      } else  if  (tissue.series(tissue.requests.intracellularFluidVolume.axisY.label)){
          tissue.removeSeries(tissue.requests.intracellularFluidVolume);
      }
      break;
      case "totalBodyFluidVolume":
      if(active){
        tissue.requests.totalBodyFluidVolume = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.totalBodyFluidVolume.axisY.label, tissue.axisX, tissue.requests.totalBodyFluidVolume.axisY);
        tissue.requests.totalBodyFluidVolume.axisY = tissue.axisY(tissue.requests.totalBodyFluidVolume)
      } else  if  (tissue.series(tissue.requests.totalBodyFluidVolume.axisY.label)){
          tissue.removeSeries(tissue.requests.totalBodyFluidVolume);
      }
      break;
      case "oxygenConsumptionRate":
      if(active){
        tissue.requests.oxygenConsumptionRate = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.oxygenConsumptionRate.axisY.label, tissue.axisX, tissue.requests.oxygenConsumptionRate.axisY);
        tissue.requests.oxygenConsumptionRate.axisY = tissue.axisY(tissue.requests.oxygenConsumptionRate)
      } else  if  (tissue.series(tissue.requests.oxygenConsumptionRate.axisY.label)){
          tissue.removeSeries(tissue.requests.oxygenConsumptionRate);
      }
      break;
      case "respiratoryExchangeRatio":
      if(active){
        tissue.requests.respiratoryExchangeRatio = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.respiratoryExchangeRatio.axisY.label, tissue.axisX, tissue.requests.respiratoryExchangeRatio.axisY);
        tissue.requests.respiratoryExchangeRatio.axisY = tissue.axisY(tissue.requests.respiratoryExchangeRatio)
      } else  if  (tissue.series(tissue.requests.respiratoryExchangeRatio.axisY.label)){
          tissue.removeSeries(tissue.requests.respiratoryExchangeRatio);
      }
      break;
      case "liverInsulinSetPoint":
      if(active){
        tissue.requests.liverInsulinSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.liverInsulinSetPoint.axisY.label, tissue.axisX, tissue.requests.liverInsulinSetPoint.axisY);
        tissue.requests.liverInsulinSetPoint.axisY = tissue.axisY(tissue.requests.liverInsulinSetPoint)
      } else  if  (tissue.series(tissue.requests.liverInsulinSetPoint.axisY.label)){
          tissue.removeSeries(tissue.requests.liverInsulinSetPoint);
      }
      break;
      case "liverGlucagonSetPoint":
      if(active){
        tissue.requests.liverGlucagonSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.liverGlucagonSetPoint.axisY.label, tissue.axisX, tissue.requests.liverGlucagonSetPoint.axisY);
        tissue.requests.liverGlucagonSetPoint.axisY = tissue.axisY(tissue.requests.liverGlucagonSetPoint)
      } else  if  (tissue.series(tissue.requests.liverGlucagonSetPoint.axisY.label)){
          tissue.removeSeries(tissue.requests.liverGlucagonSetPoint);
      }
      break;
      case "muscleInsulinSetPoint":
      if(active){
        tissue.requests.muscleInsulinSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.muscleInsulinSetPoint.axisY.label, tissue.axisX, tissue.requests.muscleInsulinSetPoint.axisY);
        tissue.requests.muscleInsulinSetPoint.axisY = tissue.axisY(tissue.requests.muscleInsulinSetPoint)
      } else  if  (tissue.series(tissue.requests.muscleInsulinSetPoint.axisY.label)){
          tissue.removeSeries(tissue.requests.muscleInsulinSetPoint);
      }
      break;
      case "muscleGlucagonSetPoint":
      if(active){
        tissue.requests.muscleGlucagonSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.muscleGlucagonSetPoint.axisY.label, tissue.axisX, tissue.requests.muscleGlucagonSetPoint.axisY);
        tissue.requests.muscleGlucagonSetPoint.axisY = tissue.axisY(tissue.requests.muscleGlucagonSetPoint)
      } else  if  (tissue.series(tissue.requests.muscleGlucagonSetPoint.axisY.label)){
          tissue.removeSeries(tissue.requests.muscleGlucagonSetPoint);
      }
      break;
      case "fatInsulinSetPoint":
      if(active){
        tissue.requests.fatInsulinSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.fatInsulinSetPoint.axisY.label, tissue.axisX, tissue.requests.fatInsulinSetPoint.axisY);
        tissue.requests.fatInsulinSetPoint.axisY = tissue.axisY(tissue.requests.fatInsulinSetPoint)
      } else  if  (tissue.series(tissue.requests.fatInsulinSetPoint.axisY.label)){
          tissue.removeSeries(tissue.requests.fatInsulinSetPoint);
      }
      break;
      case "fatGlucagonSetPoint":
      if(active){
        tissue.requests.fatGlucagonSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.fatGlucagonSetPoint.axisY.label, tissue.axisX, tissue.requests.fatGlucagonSetPoint.axisY);
        tissue.requests.fatGlucagonSetPoint.axisY = tissue.axisY(tissue.requests.fatGlucagonSetPoint)
      } else  if  (tissue.series(tissue.requests.fatGlucagonSetPoint.axisY.label)){
          tissue.removeSeries(tissue.requests.fatGlucagonSetPoint);
      }
      break;
      case "liverGlycogen":
      if(active){
        tissue.requests.liverGlycogen = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.liverGlycogen.axisY.label, tissue.axisX, tissue.requests.liverGlycogen.axisY);
        tissue.requests.liverGlycogen.axisY = tissue.axisY(tissue.requests.liverGlycogen)
      } else  if  (tissue.series(tissue.requests.liverGlycogen.axisY.label)){
          tissue.removeSeries(tissue.requests.liverGlycogen);
      }
      break;
      case "muscleGlycogen":
      if(active){
        tissue.requests.muscleGlycogen = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.muscleGlycogen.axisY.label, tissue.axisX, tissue.requests.muscleGlycogen.axisY);
        tissue.requests.muscleGlycogen.axisY = tissue.axisY(tissue.requests.muscleGlycogen)
      } else  if  (tissue.series(tissue.requests.muscleGlycogen.axisY.label)){
          tissue.removeSeries(tissue.requests.muscleGlycogen);
      }
      break;
      case "storedProtein":
      if(active){
        tissue.requests.storedProtein = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.storedProtein.axisY.label, tissue.axisX, tissue.requests.storedProtein.axisY);
        tissue.requests.storedProtein.axisY = tissue.axisY(tissue.requests.storedProtein)
      } else  if  (tissue.series(tissue.requests.storedProtein.axisY.label)){
          tissue.removeSeries(tissue.requests.storedProtein);
      }
      break;
      case "storedFat":
      if(active){
        tissue.requests.storedFat = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.storedFat.axisY.label, tissue.axisX, tissue.requests.storedFat.axisY);
        tissue.requests.storedFat.axisY = tissue.axisY(tissue.requests.storedFat)
      } else  if  (tissue.series(tissue.requests.storedFat.axisY.label)){
          tissue.removeSeries(tissue.requests.storedFat);
      }
      break;
    }
  }
  onFilterChange : {
    console.log("GraphArea Filter Changed %1 %2 = %3".arg(system).arg(request).arg(active))
    switch ( system ) {
      case "BloodChemistry":
        toggleBloodChemistrySeries(request,active);
        break;
      case "Cardiovascular":
        toggleCardiovascularSeries(request,active);
        break;
      case "Drugs":
        toggleDrugsSeries(request,active);
        break;
      case "Endocrine":
        toggleEndocrineSeries(request,active);
        break;
      case "Energy":
        toggleEnergySeries(request,active);
        break;
      case "Gastrointestinal":
        toggleGastrointestinalSeries(request,active);
        break;
      case "Hepatic":
        toggleHepaticSeries(request,active);
        break;
      case "Nervous":
        toggleNervousSeries(request,active);
        break;
      case "Renal":
        toggleRenalSeries(request,active);
        break;
      case "Respiratory":
        toggleRespiratorySeries(request,active);
        break;
      case "Tissue":
        toggleTissueSeries(request,active);
        break;
    }
  }
}
