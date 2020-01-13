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
    var bloodChemistry = physiologyRequestModel.get(0).requests
    for ( var i = 0; i < bloodChemistry.count ; ++i){
      if (bloodChemistry.get(i).active){
		toggleBloodChemistrySeries(bloodChemistry.get(i).request, bloodChemistry.get(i).active)
		physiologyRequestModel.get(0).activeRequests.append({"request": bloodChemistry.get(i).request})
		}
    }
    var cardiovascular = physiologyRequestModel.get(1).requests
    for ( var i = 0; i < cardiovascular.count; ++i){
      if( cardiovascular.get(i).active)
       toggleCardiovascularSeries(cardiovascular.get(i).request, cardiovascular.get(i).active)
    }
    var drugs = physiologyRequestModel.get(2).requests
    for ( var i = 0; i < drugs.count; ++i){
      if( drugs.get(i).active)
       toggleDrugsSeries(drugs.get(i).request, drugs.get(i).active)
    }
    var endocrine = physiologyRequestModel.get(3).requests
    for ( var i = 0; i < endocrine.count ; ++i){
      if(endocrine.get(i).active)
       toggleEndocrineSeries(endocrine.get(i).request, endocrine.get(i).active)
    }
    var energy = physiologyRequestModel.get(4).requests
    for ( var i = 0; i < energy.count ; ++i){
      if(energy.get(i).active)
       toggleEnergySeries(energy.get(i).request, energy.get(i).active)
    }
    var gastrointestinal = physiologyRequestModel.get(5).requests
    for ( var i = 0; i < gastrointestinal.count ; ++i){
      if( gastrointestinal.get(i).active)
       toggleGastrointestinalSeries(gastrointestinal.get(i).request, gastrointestinal.get(i).active)
    }
    var hepatic = physiologyRequestModel.get(6).requests
    for ( var i = 0; i < hepatic.count ; ++i){
      if(hepatic.get(i).active)
       toggleHepaticSeries(hepatic.get(i).request, hepatic.get(i).active)
    }
    var nervous = physiologyRequestModel.get(7).requests
    for ( var i = 0; i < nervous.count; ++i){
      if( nervous.get(i).active)
       toggleNervousSeries(nervous.get(i).request, nervous.get(i).active)
    }
    var renal = physiologyRequestModel.get(8).requests
    for ( var i = 0; i < renal.count ; ++i){
      if(renal.get(i).active)
       toggleRenalSeries(renal.get(i).request, renal.get(i).active)
    }
    var respiratory = physiologyRequestModel.get(9).requests
    for ( var i = 0; i < respiratory.count ; ++i){
      if(respiratory.get(i).active)
       toggleRespiratorySeries(respiratory.get(i).request, respiratory.get(i).active)
    }
    var tissue = physiologyRequestModel.get(10).requests
    for ( var i = 0; i < tissue.count ; ++i){
      if(tissue.get(i).active)
       toggleTissueSeries(tissue.get(i).request, tissue.get(i).active)
    }
  }

  function newPointHandler(series,pointIndex) {
      const MAX_INTERVAL = 3600
      var start = ( series.count < MAX_INTERVAL ) ? 0 : series.count - MAX_INTERVAL;

      if ( !series.min || !series.max)  {
        series.min = series.at(series.count-1).y
        series.max = series.at(series.count-1).y
        series.min_count = 0
        series.max_count = 0
      }

      //New Poiunts
      if ( series.at(series.count-1).y < series.min) {
         series.min = series.at(series.count-1).y
         series.min_count = 1
      } else if ( series.at(series.count-1).y ==  series.min) {
          series.min_count += 1
      }

      if ( series.at(series.count-1).y > series.max) {
         series.max = series.at(series.count-1).y
         series.max_count = 1
      } else if ( series.at(series.count-1).y ==  series.max) {
          series.max_count += 1
      }
      //Deleting Points
      if ( series.at(start).y == series.min && series.count > MAX_INTERVAL ) {
         series.min_count -= 1
         if ( series.min_count == 0 ) {
          series.min = series.at(start - 1).y
         }
      }
      if ( series.at(start).y == series.max && series.count > MAX_INTERVAL ) {
         series.max_count -= 1
         if (series.max_count == 0 ) {
           series.max = series.at(series.count - 2 ).y
         }
      }
      
      series.axisY.min = (series.min == -1.0 || series.min == 0.0 ) ? series.min : series.min * 0.9
      series.axisY.max = (series.max == 1.0 ) ? series.max :series.max * 1.1
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

  //This function is specific to searching physiology request lists for an element with a "request" field that matches the input
  //We can look to generalize this to other fields if/when needed
  function findRequestIndex(list, request){
	var index = -1;
	for (var i = 0; i < list.count; ++i){
		if (list.get(i).request == request){
			index = i;
			break;
		}
	}
	return index;
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
    const DEFAULT_UNIT = ""
    const DEFAULT_LABEL_FORMAT = [Qt.binding( function() { return (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e';} )]

    switch (request) {
      case "arterialBloodPH":
      if(active){
        bloodChemistry.requests.arterialBloodPH = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.arterialBloodPH.name, bloodChemistry.axisX, bloodChemistry.requests.arterialBloodPH.axisY);
        bloodChemistry.requests.arterialBloodPH.axisY = bloodChemistry.axisY(bloodChemistry.requests.arterialBloodPH)
        bloodChemistry.requests.arterialBloodPH.axisY.visible = true
        bloodChemistry.requests.arterialBloodPH.axisY.titleText = bloodChemistry.requests.arterialBloodPH.name
        

      } else  if(bloodChemistry.series(bloodChemistry.requests.arterialBloodPH.name)){
        bloodChemistry.requests.arterialBloodPH.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.arterialBloodPH);
      }
      break;
      case "arterialBloodPHBaseline":
      if(active){
        bloodChemistry.requests.arterialBloodPHBaseline = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.arterialBloodPHBaseline.name, bloodChemistry.axisX, bloodChemistry.requests.arterialBloodPHBaseline.axisY);
        bloodChemistry.requests.arterialBloodPHBaseline.axisY = bloodChemistry.axisY(bloodChemistry.requests.arterialBloodPHBaseline)
        bloodChemistry.requests.arterialBloodPHBaseline.axisY.visible = true
        bloodChemistry.requests.arterialBloodPHBaseline.axisY.titleText = bloodChemistry.requests.arterialBloodPHBaseline.name
        
      } else  if(bloodChemistry.series(bloodChemistry.requests.arterialBloodPHBaseline.name)){
        bloodChemistry.requests.arterialBloodPHBaseline.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.arterialBloodPHBaseline);
      }
      break;
      case "bloodDensity":
      if(active){
        bloodChemistry.requests.bloodDensity = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.bloodDensity.name, bloodChemistry.axisX, bloodChemistry.requests.bloodDensity.axisY);
        bloodChemistry.requests.bloodDensity.axisY = bloodChemistry.axisY(bloodChemistry.requests.bloodDensity)
        bloodChemistry.requests.bloodDensity.axisY.visible = true
        bloodChemistry.requests.bloodDensity.axisY.titleText = bloodChemistry.requests.bloodDensity.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.bloodDensity.name)) {
        bloodChemistry.requests.bloodDensity.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.bloodDensity);
      }
      break;
      case "bloodSpecificHeat":
      if(active){
        bloodChemistry.requests.bloodSpecificHeat = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.bloodSpecificHeat.name, bloodChemistry.axisX, bloodChemistry.requests.bloodSpecificHeat.axisY);
        bloodChemistry.requests.bloodSpecificHeat.axisY = bloodChemistry.axisY(bloodChemistry.requests.bloodSpecificHeat)
        bloodChemistry.requests.bloodSpecificHeat.axisY.visible = true
        bloodChemistry.requests.bloodSpecificHeat.axisY.titleText = bloodChemistry.requests.bloodSpecificHeat.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.bloodSpecificHeat.name)){
        bloodChemistry.requests.bloodSpecificHeat.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.bloodSpecificHeat);
      }
      break;
      case "bloodUreaNitrogenConcentration":
      if(active){
        bloodChemistry.requests.bloodUreaNitrogenConcentration = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.bloodUreaNitrogenConcentration.name, bloodChemistry.axisX, bloodChemistry.requests.bloodUreaNitrogenConcentration.axisY);
        bloodChemistry.requests.bloodUreaNitrogenConcentration.axisY = bloodChemistry.axisY(bloodChemistry.requests.bloodUreaNitrogenConcentration)
        bloodChemistry.requests.bloodUreaNitrogenConcentration.axisY.visible = true
        bloodChemistry.requests.bloodUreaNitrogenConcentration.axisY.titleText = bloodChemistry.requests.bloodUreaNitrogenConcentration.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.bloodUreaNitrogenConcentration.name)){
        bloodChemistry.requests.bloodUreaNitrogenConcentration.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.bloodUreaNitrogenConcentration);
      }
      break;
      case "carbonDioxideSaturation":
      if(active){
        bloodChemistry.requests.carbonDioxideSaturation = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.carbonDioxideSaturation.name, bloodChemistry.axisX, bloodChemistry.requests.carbonDioxideSaturation.axisY);
        bloodChemistry.requests.carbonDioxideSaturation.axisY = bloodChemistry.axisY(bloodChemistry.requests.carbonDioxideSaturation)
        bloodChemistry.requests.carbonDioxideSaturation.axisY.visible = true
        bloodChemistry.requests.carbonDioxideSaturation.axisY.titleText = bloodChemistry.requests.carbonDioxideSaturation.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.carbonDioxideSaturation.name)){
        bloodChemistry.requests.carbonDioxideSaturation.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.carbonDioxideSaturation);
      }
      break;
      case "carbonMonoxideSaturation":
      if(active){
        bloodChemistry.requests.carbonMonoxideSaturation = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.carbonMonoxideSaturation.name, bloodChemistry.axisX, bloodChemistry.requests.carbonMonoxideSaturation.axisY);
        bloodChemistry.requests.carbonMonoxideSaturation.axisY = bloodChemistry.axisY(bloodChemistry.requests.carbonMonoxideSaturation)
        bloodChemistry.requests.carbonMonoxideSaturation.axisY.visible = true
        bloodChemistry.requests.carbonMonoxideSaturation.axisY.titleText = bloodChemistry.requests.carbonMonoxideSaturation.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.carbonMonoxideSaturation.name)){
        bloodChemistry.requests.carbonMonoxideSaturation.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.carbonMonoxideSaturation);
      }
      break;
      case "hematocrit":
      if(active){
        bloodChemistry.requests.hematocrit = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.hematocrit.name, bloodChemistry.axisX, bloodChemistry.requests.hematocrit.axisY);
        bloodChemistry.requests.hematocrit.axisY = bloodChemistry.axisY(bloodChemistry.requests.hematocrit)
        bloodChemistry.requests.hematocrit.axisY.visible = true
        bloodChemistry.requests.hematocrit.axisY.titleText = bloodChemistry.requests.hematocrit.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.hematocrit.name)){
        bloodChemistry.requests.hematocrit.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.hematocrit);
      }
      break;
      case "hemoglobinContent":
      if(active){
        bloodChemistry.requests.hemoglobinContent = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.hemoglobinContent.name, bloodChemistry.axisX, bloodChemistry.requests.hemoglobinContent.axisY);
        bloodChemistry.requests.hemoglobinContent.axisY = bloodChemistry.axisY(bloodChemistry.requests.hemoglobinContent)
        bloodChemistry.requests.hemoglobinContent.axisY.visible = true
        bloodChemistry.requests.hemoglobinContent.axisY.titleText = bloodChemistry.requests.hemoglobinContent.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.hemoglobinContent.name)){
        bloodChemistry.requests.hemoglobinContent.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.hemoglobinContent);
      }
      break;
      case "oxygenSaturation":
      if(active){
        bloodChemistry.requests.oxygenSaturation = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.oxygenSaturation.name, bloodChemistry.axisX, bloodChemistry.requests.oxygenSaturation.axisY);
        bloodChemistry.requests.oxygenSaturation.axisY = bloodChemistry.axisY(bloodChemistry.requests.oxygenSaturation)
        bloodChemistry.requests.oxygenSaturation.axisY.visible = true
        bloodChemistry.requests.oxygenSaturation.axisY.titleText = bloodChemistry.requests.oxygenSaturation.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.oxygenSaturation.name)){
        bloodChemistry.requests.oxygenSaturation.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.oxygenSaturation);
      }
      break;
      case "phosphate":
      if(active){
        bloodChemistry.requests.phosphate = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.phosphate.name, bloodChemistry.axisX, bloodChemistry.requests.phosphate.axisY);
        bloodChemistry.requests.phosphate.axisY = bloodChemistry.axisY(bloodChemistry.requests.phosphate)
        bloodChemistry.requests.phosphate.axisY.visible = true
        bloodChemistry.requests.phosphate.axisY.titleText = bloodChemistry.requests.phosphate.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.phosphate.name)){
        bloodChemistry.requests.phosphate.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.phosphate);
      }
      break;
      case "plasmaVolume":
      if(active){
        bloodChemistry.requests.plasmaVolume = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.plasmaVolume.name, bloodChemistry.axisX, bloodChemistry.requests.plasmaVolume.axisY);
        bloodChemistry.requests.plasmaVolume.axisY = bloodChemistry.axisY(bloodChemistry.requests.plasmaVolume)
        bloodChemistry.requests.plasmaVolume.axisY.visible = true
        bloodChemistry.requests.plasmaVolume.axisY.titleText = bloodChemistry.requests.plasmaVolume.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.plasmaVolume.name)){
        bloodChemistry.requests.plasmaVolume.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.plasmaVolume);
      }
      break;
      case "pulseOximetry":
      if(active){
        bloodChemistry.requests.pulseOximetry = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.pulseOximetry.name, bloodChemistry.axisX, bloodChemistry.requests.pulseOximetry.axisY);
        bloodChemistry.requests.pulseOximetry.axisY = bloodChemistry.axisY(bloodChemistry.requests.pulseOximetry)
        bloodChemistry.requests.pulseOximetry.axisY.visible = true
        bloodChemistry.requests.pulseOximetry.axisY.titleText = bloodChemistry.requests.pulseOximetry.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.pulseOximetry.name)){
        bloodChemistry.requests.pulseOximetry.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.pulseOximetry);
      }
      break;
      case "redBloodCellAcetylcholinesterase":
      if(active){
        bloodChemistry.requests.redBloodCellAcetylcholinesterase = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.redBloodCellAcetylcholinesterase.name, bloodChemistry.axisX, bloodChemistry.requests.redBloodCellAcetylcholinesterase.axisY);
        bloodChemistry.requests.redBloodCellAcetylcholinesterase.axisY = bloodChemistry.axisY(bloodChemistry.requests.redBloodCellAcetylcholinesterase)
        bloodChemistry.requests.redBloodCellAcetylcholinesterase.axisY.visible = true
        bloodChemistry.requests.redBloodCellAcetylcholinesterase.axisY.titleText = bloodChemistry.requests.redBloodCellAcetylcholinesterase.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.redBloodCellAcetylcholinesterase.name)){
        bloodChemistry.requests.redBloodCellAcetylcholinesterase.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.redBloodCellAcetylcholinesterase);
      }
      break;
      case "redBloodCellCount":
      if(active){
        bloodChemistry.requests.redBloodCellCount = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.redBloodCellCount.name, bloodChemistry.axisX, bloodChemistry.requests.redBloodCellCount.axisY);
        bloodChemistry.requests.redBloodCellCount.axisY = bloodChemistry.axisY(bloodChemistry.requests.redBloodCellCount)
        bloodChemistry.requests.redBloodCellCount.axisY.visible = true
        bloodChemistry.requests.redBloodCellCount.axisY.titleText = bloodChemistry.requests.redBloodCellCount.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.redBloodCellCount.name)){
        bloodChemistry.requests.redBloodCellCount.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.redBloodCellCount);
      }
      break;
      case "shuntFraction":
      if(active){
        bloodChemistry.requests.shuntFraction = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.shuntFraction.name, bloodChemistry.axisX, bloodChemistry.requests.shuntFraction.axisY);
        bloodChemistry.requests.shuntFraction.axisY = bloodChemistry.axisY(bloodChemistry.requests.shuntFraction)
        bloodChemistry.requests.shuntFraction.axisY.visible = true
        bloodChemistry.requests.shuntFraction.axisY.titleText = bloodChemistry.requests.shuntFraction.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.shuntFraction.name)){
        bloodChemistry.requests.shuntFraction.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.shuntFraction);
      }
      break;
      case "strongIonDifference":
      if(active){
        bloodChemistry.requests.strongIonDifference = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.strongIonDifference.name, bloodChemistry.axisX, bloodChemistry.requests.strongIonDifference.axisY);
        bloodChemistry.requests.strongIonDifference.axisY = bloodChemistry.axisY(bloodChemistry.requests.strongIonDifference)
        bloodChemistry.requests.strongIonDifference.axisY.visible = true
        bloodChemistry.requests.strongIonDifference.axisY.titleText = bloodChemistry.requests.strongIonDifference.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.strongIonDifference.name)){
        bloodChemistry.requests.strongIonDifference.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.strongIonDifference);
      }
      break;
      case "totalBilirubin":
      if(active){
        bloodChemistry.requests.totalBilirubin = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.totalBilirubin.name, bloodChemistry.axisX, bloodChemistry.requests.totalBilirubin.axisY);
        bloodChemistry.requests.totalBilirubin.axisY = bloodChemistry.axisY(bloodChemistry.requests.totalBilirubin)
        bloodChemistry.requests.totalBilirubin.axisY.visible = true
        bloodChemistry.requests.totalBilirubin.axisY.titleText = bloodChemistry.requests.totalBilirubin.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.totalBilirubin.name)){
        bloodChemistry.requests.totalBilirubin.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.totalBilirubin);
      }
      break;
      case "totalProteinConcentration":
      if(active){
        bloodChemistry.requests.totalProteinConcentration = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.totalProteinConcentration.name, bloodChemistry.axisX, bloodChemistry.requests.totalProteinConcentration.axisY);
        bloodChemistry.requests.totalProteinConcentration.axisY = bloodChemistry.axisY(bloodChemistry.requests.totalProteinConcentration)
        bloodChemistry.requests.totalProteinConcentration.axisY.visible = true
        bloodChemistry.requests.totalProteinConcentration.axisY.titleText = bloodChemistry.requests.totalProteinConcentration.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.totalProteinConcentration.name)){
        bloodChemistry.requests.totalProteinConcentration.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.totalProteinConcentration);
      }
      break;
      case "venousBloodPH":
      if(active){
        bloodChemistry.requests.venousBloodPH = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.venousBloodPH.name, bloodChemistry.axisX, bloodChemistry.requests.venousBloodPH.axisY);
        bloodChemistry.requests.venousBloodPH.axisY = bloodChemistry.axisY(bloodChemistry.requests.venousBloodPH)
        bloodChemistry.requests.venousBloodPH.axisY.visible = true
        bloodChemistry.requests.venousBloodPH.axisY.titleText = bloodChemistry.requests.venousBloodPH.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.venousBloodPH.name)){
        bloodChemistry.requests.venousBloodPH.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.venousBloodPH);
      }
      break;
      case "volumeFractionNeutralPhospholipidInPlasma":
      if(active){
        bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.name, bloodChemistry.axisX, bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.axisY);
        bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.axisY = bloodChemistry.axisY(bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma)
        bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.axisY.visible = true
        bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.axisY.titleText = bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.name)){
        bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.volumeFractionNeutralPhospholipidInPlasma);
      }
      break;
      case "volumeFractionNeutralLipidInPlasma":
      if(active){
        bloodChemistry.requests.volumeFractionNeutralLipidInPlasma = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.name, bloodChemistry.axisX, bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.axisY);
        bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.axisY = bloodChemistry.axisY(bloodChemistry.requests.volumeFractionNeutralLipidInPlasma)
        bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.axisY.visible = true
        bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.axisY.titleText = bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.name)){
        bloodChemistry.requests.volumeFractionNeutralLipidInPlasma.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.volumeFractionNeutralLipidInPlasma);
      }
      break;
      case "arterialCarbonDioxidePressure":
      if(active){
        bloodChemistry.requests.arterialCarbonDioxidePressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.arterialCarbonDioxidePressure.name, bloodChemistry.axisX, bloodChemistry.requests.arterialCarbonDioxidePressure.axisY);
        bloodChemistry.requests.arterialCarbonDioxidePressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.arterialCarbonDioxidePressure)
        bloodChemistry.requests.arterialCarbonDioxidePressure.axisY.visible = true
        bloodChemistry.requests.arterialCarbonDioxidePressure.axisY.titleText = bloodChemistry.requests.arterialCarbonDioxidePressure.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.arterialCarbonDioxidePressure.name)){
        bloodChemistry.requests.arterialCarbonDioxidePressure.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.arterialCarbonDioxidePressure);
      }
      break;
      case "arterialOxygenPressure":
      if(active){
        bloodChemistry.requests.arterialOxygenPressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.arterialOxygenPressure.name, bloodChemistry.axisX, bloodChemistry.requests.arterialOxygenPressure.axisY);
        bloodChemistry.requests.arterialOxygenPressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.arterialOxygenPressure)
        bloodChemistry.requests.arterialOxygenPressure.axisY.visible = true
        bloodChemistry.requests.arterialOxygenPressure.axisY.titleText = bloodChemistry.requests.arterialOxygenPressure.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.arterialOxygenPressure.name)){
        bloodChemistry.requests.arterialOxygenPressure.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.arterialOxygenPressure);
      }
      break;
      case "pulmonaryArterialCarbonDioxidePressure":
      if(active){
        bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.name, bloodChemistry.axisX, bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.axisY);
        bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure)
        bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.axisY.visible = true
        bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.axisY.titleText = bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.name)){
        bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.pulmonaryArterialCarbonDioxidePressure);
      }
      break;
      case "pulmonaryArterialOxygenPressure":
      if(active){
        bloodChemistry.requests.pulmonaryArterialOxygenPressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.pulmonaryArterialOxygenPressure.name, bloodChemistry.axisX, bloodChemistry.requests.pulmonaryArterialOxygenPressure.axisY);
        bloodChemistry.requests.pulmonaryArterialOxygenPressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.pulmonaryArterialOxygenPressure)
        bloodChemistry.requests.pulmonaryArterialOxygenPressure.axisY.visible = true
        bloodChemistry.requests.pulmonaryArterialOxygenPressure.axisY.titleText = bloodChemistry.requests.pulmonaryArterialOxygenPressure.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.pulmonaryArterialOxygenPressure.name)){
        bloodChemistry.requests.pulmonaryArterialOxygenPressure.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.pulmonaryArterialOxygenPressure);
      }
      break;
      case "pulmonaryVenousCarbonDioxidePressure":
      if(active){
        bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.name, bloodChemistry.axisX, bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.axisY);
        bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure)
        bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.axisY.visible = true
        bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.axisY.titleText = bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.name)){
        bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.pulmonaryVenousCarbonDioxidePressure);
      }
      break;
      case "pulmonaryVenousOxygenPressure":
      if(active){
        bloodChemistry.requests.pulmonaryVenousOxygenPressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.pulmonaryVenousOxygenPressure.name, bloodChemistry.axisX, bloodChemistry.requests.pulmonaryVenousOxygenPressure.axisY);
        bloodChemistry.requests.pulmonaryVenousOxygenPressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.pulmonaryVenousOxygenPressure)
        bloodChemistry.requests.pulmonaryVenousOxygenPressure.axisY.visible = true
        bloodChemistry.requests.pulmonaryVenousOxygenPressure.axisY.titleText = bloodChemistry.requests.pulmonaryVenousOxygenPressure.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.pulmonaryVenousOxygenPressure.name)){
        bloodChemistry.requests.pulmonaryVenousOxygenPressure.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.pulmonaryVenousOxygenPressure);
      }
      break;
      case "venousCarbonDioxidePressure":
      if(active){
        bloodChemistry.requests.venousCarbonDioxidePressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.venousCarbonDioxidePressure.name, bloodChemistry.axisX, bloodChemistry.requests.venousCarbonDioxidePressure.axisY);
        bloodChemistry.requests.venousCarbonDioxidePressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.venousCarbonDioxidePressure)
        bloodChemistry.requests.venousCarbonDioxidePressure.axisY.visible = true
        bloodChemistry.requests.venousCarbonDioxidePressure.axisY.titleText = bloodChemistry.requests.venousCarbonDioxidePressure.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.venousCarbonDioxidePressure.name)){
        bloodChemistry.requests.venousCarbonDioxidePressure.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.venousCarbonDioxidePressure);
      }
      break;
      case "venousOxygenPressure":
      if(active){
        bloodChemistry.requests.venousOxygenPressure = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.venousOxygenPressure.name, bloodChemistry.axisX, bloodChemistry.requests.venousOxygenPressure.axisY);
        bloodChemistry.requests.venousOxygenPressure.axisY = bloodChemistry.axisY(bloodChemistry.requests.venousOxygenPressure)
        bloodChemistry.requests.venousOxygenPressure.axisY.visible = true
        bloodChemistry.requests.venousOxygenPressure.axisY.titleText = bloodChemistry.requests.venousOxygenPressure.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.venousOxygenPressure.name)){
        bloodChemistry.requests.venousOxygenPressure.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.venousOxygenPressure);
      }
      break;
      case "inflammatoryResponse":
      if(active){
        bloodChemistry.requests.inflammatoryResponse = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponse.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponse.axisY);
        bloodChemistry.requests.inflammatoryResponse.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponse)
        bloodChemistry.requests.inflammatoryResponse.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponse.axisY.titleText = bloodChemistry.requests.inflammatoryResponse.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponse.name)){
        bloodChemistry.requests.inflammatoryResponse.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponse);
      }
      break;
      case "inflammatoryResponseLocalPathogen":
      if(active){
        bloodChemistry.requests.inflammatoryResponseLocalPathogen = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseLocalPathogen.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseLocalPathogen.axisY);
        bloodChemistry.requests.inflammatoryResponseLocalPathogen.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseLocalPathogen)
        bloodChemistry.requests.inflammatoryResponseLocalPathogen.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseLocalPathogen.axisY.titleText = bloodChemistry.requests.inflammatoryResponseLocalPathogen.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseLocalPathogen.name)){
        bloodChemistry.requests.inflammatoryResponseLocalPathogen.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseLocalPathogen);
      }
      break;
      case "inflammatoryResponseLocalMacrophage":
      if(active){
        bloodChemistry.requests.inflammatoryResponseLocalMacrophage = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseLocalMacrophage.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseLocalMacrophage.axisY);
        bloodChemistry.requests.inflammatoryResponseLocalMacrophage.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseLocalMacrophage)
        bloodChemistry.requests.inflammatoryResponseLocalMacrophage.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseLocalMacrophage.axisY.titleText = bloodChemistry.requests.inflammatoryResponseLocalMacrophage.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseLocalMacrophage.name)){
        bloodChemistry.requests.inflammatoryResponseLocalMacrophage.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseLocalMacrophage);
      }
      break;
      case "inflammatoryResponseLocalNeutrophil":
      if(active){
        bloodChemistry.requests.inflammatoryResponseLocalNeutrophil = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.axisY);
        bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseLocalNeutrophil)
        bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.axisY.titleText = bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.name)){
        bloodChemistry.requests.inflammatoryResponseLocalNeutrophil.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseLocalNeutrophil);
      }
      break;
      case "inflammatoryResponseLocalBarrier":
      if(active){
        bloodChemistry.requests.inflammatoryResponseLocalBarrier = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseLocalBarrier.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseLocalBarrier.axisY);
        bloodChemistry.requests.inflammatoryResponseLocalBarrier.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseLocalBarrier)
        bloodChemistry.requests.inflammatoryResponseLocalBarrier.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseLocalBarrier.axisY.titleText = bloodChemistry.requests.inflammatoryResponseLocalBarrier.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseLocalBarrier.name)){
        bloodChemistry.requests.inflammatoryResponseLocalBarrier.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseLocalBarrier);
      }
      break;
      case "inflammatoryResponseBloodPathogen":
      if(active){
        bloodChemistry.requests.inflammatoryResponseBloodPathogen = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseBloodPathogen.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseBloodPathogen.axisY);
        bloodChemistry.requests.inflammatoryResponseBloodPathogen.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseBloodPathogen)
        bloodChemistry.requests.inflammatoryResponseBloodPathogen.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseBloodPathogen.axisY.titleText = bloodChemistry.requests.inflammatoryResponseBloodPathogen.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseBloodPathogen.name)){
        bloodChemistry.requests.inflammatoryResponseBloodPathogen.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseBloodPathogen);
      }
      break;
      case "inflammatoryResponseTrauma":
      if(active){
        bloodChemistry.requests.inflammatoryResponseTrauma = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseTrauma.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseTrauma.axisY);
        bloodChemistry.requests.inflammatoryResponseTrauma.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseTrauma)
        bloodChemistry.requests.inflammatoryResponseTrauma.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseTrauma.axisY.titleText = bloodChemistry.requests.inflammatoryResponseTrauma.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseTrauma.name)){
        bloodChemistry.requests.inflammatoryResponseTrauma.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseTrauma);
      }
      break;
      case "inflammatoryResponseMacrophageResting":
      if(active){
        bloodChemistry.requests.inflammatoryResponseMacrophageResting = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseMacrophageResting.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseMacrophageResting.axisY);
        bloodChemistry.requests.inflammatoryResponseMacrophageResting.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseMacrophageResting)
        bloodChemistry.requests.inflammatoryResponseMacrophageResting.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseMacrophageResting.axisY.titleText = bloodChemistry.requests.inflammatoryResponseMacrophageResting.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseMacrophageResting.name)){
        bloodChemistry.requests.inflammatoryResponseMacrophageResting.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseMacrophageResting);
      }
      break;
      case "inflammatoryResponseMacrophageActive":
      if(active){
        bloodChemistry.requests.inflammatoryResponseMacrophageActive = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseMacrophageActive.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseMacrophageActive.axisY);
        bloodChemistry.requests.inflammatoryResponseMacrophageActive.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseMacrophageActive)
        bloodChemistry.requests.inflammatoryResponseMacrophageActive.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseMacrophageActive.axisY.titleText = bloodChemistry.requests.inflammatoryResponseMacrophageActive.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseMacrophageActive.name)){
        bloodChemistry.requests.inflammatoryResponseMacrophageActive.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseMacrophageActive);
      }
      break;
      case "inflammatoryResponseNeutrophilResting":
      if(active){
        bloodChemistry.requests.inflammatoryResponseNeutrophilResting = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseNeutrophilResting.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseNeutrophilResting.axisY);
        bloodChemistry.requests.inflammatoryResponseNeutrophilResting.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseNeutrophilResting)
        bloodChemistry.requests.inflammatoryResponseNeutrophilResting.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseNeutrophilResting.axisY.titleText = bloodChemistry.requests.inflammatoryResponseNeutrophilResting.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseNeutrophilResting.name)){
        bloodChemistry.requests.inflammatoryResponseNeutrophilResting.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseNeutrophilResting);
      }
      break;
      case "inflammatoryResponseNeutrophilActive":
      if(active){
        bloodChemistry.requests.inflammatoryResponseNeutrophilActive = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseNeutrophilActive.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseNeutrophilActive.axisY);
        bloodChemistry.requests.inflammatoryResponseNeutrophilActive.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseNeutrophilActive)
        bloodChemistry.requests.inflammatoryResponseNeutrophilActive.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseNeutrophilActive.axisY.titleText = bloodChemistry.requests.inflammatoryResponseNeutrophilActive.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseNeutrophilActive.name)){
        bloodChemistry.requests.inflammatoryResponseNeutrophilActive.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseNeutrophilActive);
      }
      break;
      case "inflammatoryResponseInducibleNOSPre":
      if(active){
        bloodChemistry.requests.inflammatoryResponseInducibleNOSPre = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.axisY);
        bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseInducibleNOSPre)
        bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.axisY.titleText = bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.name)){
        bloodChemistry.requests.inflammatoryResponseInducibleNOSPre.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseInducibleNOSPre);
      }
      break;
      case "inflammatoryResponseInducibleNOS":
      if(active){
        bloodChemistry.requests.inflammatoryResponseInducibleNOS = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseInducibleNOS.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseInducibleNOS.axisY);
        bloodChemistry.requests.inflammatoryResponseInducibleNOS.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseInducibleNOS)
        bloodChemistry.requests.inflammatoryResponseInducibleNOS.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseInducibleNOS.axisY.titleText = bloodChemistry.requests.inflammatoryResponseInducibleNOS.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseInducibleNOS.name)){
        bloodChemistry.requests.inflammatoryResponseInducibleNOS.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseInducibleNOS);
      }
      break;
      case "inflammatoryResponseConstitutiveNOS":
      if(active){
        bloodChemistry.requests.inflammatoryResponseConstitutiveNOS = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.axisY);
        bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseConstitutiveNOS)
        bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.axisY.titleText = bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.name)){
        bloodChemistry.requests.inflammatoryResponseConstitutiveNOS.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseConstitutiveNOS);
      }
      break;
      case "inflammatoryResponseNitrate":
      if(active){
        bloodChemistry.requests.inflammatoryResponseNitrate = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseNitrate.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseNitrate.axisY);
        bloodChemistry.requests.inflammatoryResponseNitrate.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseNitrate)
        bloodChemistry.requests.inflammatoryResponseNitrate.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseNitrate.axisY.titleText = bloodChemistry.requests.inflammatoryResponseNitrate.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseNitrate.name)){
        bloodChemistry.requests.inflammatoryResponseNitrate.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseNitrate);
      }
      break;
      case "inflammatoryResponseNitricOxide":
      if(active){
        bloodChemistry.requests.inflammatoryResponseNitricOxide = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseNitricOxide.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseNitricOxide.axisY);
        bloodChemistry.requests.inflammatoryResponseNitricOxide.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseNitricOxide)
        bloodChemistry.requests.inflammatoryResponseNitricOxide.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseNitricOxide.axisY.titleText = bloodChemistry.requests.inflammatoryResponseNitricOxide.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseNitricOxide.name)){
        bloodChemistry.requests.inflammatoryResponseNitricOxide.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseNitricOxide);
      }
      break;
      case "inflammatoryResponseTumorNecrosisFactor":
      if(active){
        bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.axisY);
        bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor)
        bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.axisY.titleText = bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.name)){
        bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseTumorNecrosisFactor);
      }
      break;
      case "inflammatoryResponseInterleukin6":
      if(active){
        bloodChemistry.requests.inflammatoryResponseInterleukin6 = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseInterleukin6.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseInterleukin6.axisY);
        bloodChemistry.requests.inflammatoryResponseInterleukin6.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseInterleukin6)
        bloodChemistry.requests.inflammatoryResponseInterleukin6.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseInterleukin6.axisY.titleText = bloodChemistry.requests.inflammatoryResponseInterleukin6.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseInterleukin6.name)){
        bloodChemistry.requests.inflammatoryResponseInterleukin6.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseInterleukin6);
      }
      break;
      case "inflammatoryResponseInterleukin10":
      if(active){
        bloodChemistry.requests.inflammatoryResponseInterleukin10 = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseInterleukin10.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseInterleukin10.axisY);
        bloodChemistry.requests.inflammatoryResponseInterleukin10.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseInterleukin10)
        bloodChemistry.requests.inflammatoryResponseInterleukin10.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseInterleukin10.axisY.titleText = bloodChemistry.requests.inflammatoryResponseInterleukin10.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseInterleukin10.name)){
        bloodChemistry.requests.inflammatoryResponseInterleukin10.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseInterleukin10);
      }
      break;
      case "inflammatoryResponseInterleukin12":
      if(active){
        bloodChemistry.requests.inflammatoryResponseInterleukin12 = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseInterleukin12.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseInterleukin12.axisY);
        bloodChemistry.requests.inflammatoryResponseInterleukin12.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseInterleukin12)
        bloodChemistry.requests.inflammatoryResponseInterleukin12.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseInterleukin12.axisY.titleText = bloodChemistry.requests.inflammatoryResponseInterleukin12.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseInterleukin12.name)){
        bloodChemistry.requests.inflammatoryResponseInterleukin12.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseInterleukin12);
      }
      break;
      case "inflammatoryResponseCatecholamines":
      if(active){
        bloodChemistry.requests.inflammatoryResponseCatecholamines = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseCatecholamines.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseCatecholamines.axisY);
        bloodChemistry.requests.inflammatoryResponseCatecholamines.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseCatecholamines)
        bloodChemistry.requests.inflammatoryResponseCatecholamines.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseCatecholamines.axisY.titleText = bloodChemistry.requests.inflammatoryResponseCatecholamines.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseCatecholamines.name)){
        bloodChemistry.requests.inflammatoryResponseCatecholamines.axisY.visible = false
        bloodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseCatecholamines);
      }
      break;
      case "inflammatoryResponseTissueIntegrity":
      if(active){
        bloodChemistry.requests.inflammatoryResponseTissueIntegrity = bloodChemistry.createSeries(ChartView.SeriesTypeLine, bloodChemistry.requests.inflammatoryResponseTissueIntegrity.name, bloodChemistry.axisX, bloodChemistry.requests.inflammatoryResponseTissueIntegrity.axisY);
        bloodChemistry.requests.inflammatoryResponseTissueIntegrity.axisY = bloodChemistry.axisY(bloodChemistry.requests.inflammatoryResponseTissueIntegrity)
        bloodChemistry.requests.inflammatoryResponseTissueIntegrity.axisY.visible = true
        bloodChemistry.requests.inflammatoryResponseTissueIntegrity.axisY.titleText = bloodChemistry.requests.inflammatoryResponseTissueIntegrity.name
        
      } else if(bloodChemistry.series(bloodChemistry.requests.inflammatoryResponseTissueIntegrity.name)){
        bloodChemistry.requests.inflammatoryResponseTissueIntegrity.axisY.visible = false
        loodChemistry.removeSeries(bloodChemistry.requests.inflammatoryResponseTissueIntegrity);
      }
      break;
    }
  }
  function toggleCardiovascularSeries(request, active){
    const DEFAULT_UNIT = ""
    const DEFAULT_LABEL_FORMAT = [Qt.binding( function() { return (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e';} )]
    switch (request) {
      case "arterialPressure":
      if(active){
        cardiovascular.requests.arterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.arterialPressure.name, cardiovascular.axisX, cardiovascular.requests.arterialPressure.axisY);
        cardiovascular.requests.arterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.arterialPressure)
        cardiovascular.requests.arterialPressure.axisY.visible = true
        cardiovascular.requests.arterialPressure.axisY.titleText = cardiovascular.requests.arterialPressure.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.arterialPressure.name)){
        cardiovascular.requests.arterialPressure.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.arterialPressure);
      }
      break;
      case "bloodVolume":
      if(active){
        cardiovascular.requests.bloodVolume = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.bloodVolume.name, cardiovascular.axisX, cardiovascular.requests.bloodVolume.axisY);
        cardiovascular.requests.bloodVolume.axisY = cardiovascular.axisY(cardiovascular.requests.bloodVolume)
        cardiovascular.requests.bloodVolume.axisY.visible = true
        cardiovascular.requests.bloodVolume.axisY.titleText = cardiovascular.requests.bloodVolume.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.bloodVolume.name)){
        cardiovascular.requests.bloodVolume.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.bloodVolume);
      }
      break;
      case "cardiacIndex":
      if(active){
        cardiovascular.requests.cardiacIndex = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.cardiacIndex.name, cardiovascular.axisX, cardiovascular.requests.cardiacIndex.axisY);
        cardiovascular.requests.cardiacIndex.axisY = cardiovascular.axisY(cardiovascular.requests.cardiacIndex)
        cardiovascular.requests.cardiacIndex.axisY.visible = true
        cardiovascular.requests.cardiacIndex.axisY.titleText = cardiovascular.requests.cardiacIndex.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.cardiacIndex.name)){
        cardiovascular.requests.cardiacIndex.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.cardiacIndex);
      }
      break;
      case "cardiacOutput":
      if(active){
        cardiovascular.requests.cardiacOutput = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.cardiacOutput.name, cardiovascular.axisX, cardiovascular.requests.cardiacOutput.axisY);
        cardiovascular.requests.cardiacOutput.axisY = cardiovascular.axisY(cardiovascular.requests.cardiacOutput)
        cardiovascular.requests.cardiacOutput.axisY.visible = true
        cardiovascular.requests.cardiacOutput.axisY.titleText = cardiovascular.requests.cardiacOutput.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.cardiacOutput.name)){
        cardiovascular.requests.cardiacOutput.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.cardiacOutput);
      }
      break;
      case "centralVenousPressure":
      if(active){
        cardiovascular.requests.centralVenousPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.centralVenousPressure.name, cardiovascular.axisX, cardiovascular.requests.centralVenousPressure.axisY);
        cardiovascular.requests.centralVenousPressure.axisY = cardiovascular.axisY(cardiovascular.requests.centralVenousPressure)
        cardiovascular.requests.centralVenousPressure.axisY.visible = true
        cardiovascular.requests.centralVenousPressure.axisY.titleText = cardiovascular.requests.centralVenousPressure.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.centralVenousPressure.name)){
        cardiovascular.requests.centralVenousPressure.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.centralVenousPressure);
      }
      break;
      case "cerebralBloodFlow":
      if(active){
        cardiovascular.requests.cerebralBloodFlow = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.cerebralBloodFlow.name, cardiovascular.axisX, cardiovascular.requests.cerebralBloodFlow.axisY);
        cardiovascular.requests.cerebralBloodFlow.axisY = cardiovascular.axisY(cardiovascular.requests.cerebralBloodFlow)
        cardiovascular.requests.cerebralBloodFlow.axisY.visible = true
        cardiovascular.requests.cerebralBloodFlow.axisY.titleText = cardiovascular.requests.cerebralBloodFlow.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.cerebralBloodFlow.name)){
        cardiovascular.requests.cerebralBloodFlow.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.cerebralBloodFlow);
      }
      break;
      case "cerebralPerfusionPressure":
      if(active){
        cardiovascular.requests.cerebralPerfusionPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.cerebralPerfusionPressure.name, cardiovascular.axisX, cardiovascular.requests.cerebralPerfusionPressure.axisY);
        cardiovascular.requests.cerebralPerfusionPressure.axisY = cardiovascular.axisY(cardiovascular.requests.cerebralPerfusionPressure)
        cardiovascular.requests.cerebralPerfusionPressure.axisY.visible = true
        cardiovascular.requests.cerebralPerfusionPressure.axisY.titleText = cardiovascular.requests.cerebralPerfusionPressure.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.cerebralPerfusionPressure.name)){
        cardiovascular.requests.cerebralPerfusionPressure.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.cerebralPerfusionPressure);
      }
      break;
      case "diastolicArterialPressure":
      if(active){
        cardiovascular.requests.diastolicArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.diastolicArterialPressure.name, cardiovascular.axisX, cardiovascular.requests.diastolicArterialPressure.axisY);
        cardiovascular.requests.diastolicArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.diastolicArterialPressure)
        cardiovascular.requests.diastolicArterialPressure.axisY.visible = true
        cardiovascular.requests.diastolicArterialPressure.axisY.titleText = cardiovascular.requests.diastolicArterialPressure.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.diastolicArterialPressure.name)){
        cardiovascular.requests.diastolicArterialPressure.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.diastolicArterialPressure);
      }
      break;
      case "heartEjectionFraction":
      if(active){
        cardiovascular.requests.heartEjectionFraction = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.heartEjectionFraction.name, cardiovascular.axisX, cardiovascular.requests.heartEjectionFraction.axisY);
        cardiovascular.requests.heartEjectionFraction.axisY = cardiovascular.axisY(cardiovascular.requests.heartEjectionFraction)
        cardiovascular.requests.heartEjectionFraction.axisY.visible = true
        cardiovascular.requests.heartEjectionFraction.axisY.titleText = cardiovascular.requests.heartEjectionFraction.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.heartEjectionFraction.name)){
        cardiovascular.requests.heartEjectionFraction.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.heartEjectionFraction);
      }
      break;
      case "heartRate":
      if(active){
        cardiovascular.requests.heartRate = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.heartRate.name, cardiovascular.axisX, cardiovascular.requests.heartRate.axisY);
        cardiovascular.requests.heartRate.axisY = cardiovascular.axisY(cardiovascular.requests.heartRate)
        cardiovascular.requests.heartRate.axisY.visible = true
        cardiovascular.requests.heartRate.axisY.titleText = cardiovascular.requests.heartRate.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.heartRate.name)){
        cardiovascular.requests.heartRate.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.heartRate);
      }
      break;
      case "heartStrokeVolume":
      if(active){
        cardiovascular.requests.heartStrokeVolume = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.heartStrokeVolume.name, cardiovascular.axisX, cardiovascular.requests.heartStrokeVolume.axisY);
        cardiovascular.requests.heartStrokeVolume.axisY = cardiovascular.axisY(cardiovascular.requests.heartStrokeVolume)
        cardiovascular.requests.heartStrokeVolume.axisY.visible = true
        cardiovascular.requests.heartStrokeVolume.axisY.titleText = cardiovascular.requests.heartStrokeVolume.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.heartStrokeVolume.name)){
        cardiovascular.requests.heartStrokeVolume.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.heartStrokeVolume);
      }
      break;
      case "intracranialPressure":
      if(active){
        cardiovascular.requests.intracranialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.intracranialPressure.name, cardiovascular.axisX, cardiovascular.requests.intracranialPressure.axisY);
        cardiovascular.requests.intracranialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.intracranialPressure)
        cardiovascular.requests.intracranialPressure.axisY.visible = true
        cardiovascular.requests.intracranialPressure.axisY.titleText = cardiovascular.requests.intracranialPressure.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.intracranialPressure.name)){
        cardiovascular.requests.intracranialPressure.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.intracranialPressure);
      }
      break;
      case "meanArterialPressure":
      if(active){
        cardiovascular.requests.meanArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.meanArterialPressure.name, cardiovascular.axisX, cardiovascular.requests.meanArterialPressure.axisY);
        cardiovascular.requests.meanArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.meanArterialPressure)
        cardiovascular.requests.meanArterialPressure.axisY.visible = true
        cardiovascular.requests.meanArterialPressure.axisY.titleText = cardiovascular.requests.meanArterialPressure.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.meanArterialPressure.name)){
        cardiovascular.requests.meanArterialPressure.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.meanArterialPressure);
      }
      break;
      case "meanArterialCarbonDioxidePartialPressure":
      if(active){
        cardiovascular.requests.meanArterialCarbonDioxidePartialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.name, cardiovascular.axisX, cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.axisY);
        cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.meanArterialCarbonDioxidePartialPressure)
        cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.axisY.visible = true
        cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.axisY.titleText = cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.name)){
        cardiovascular.requests.meanArterialCarbonDioxidePartialPressure.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.meanArterialCarbonDioxidePartialPressure);
      }
      break;
      case "meanArterialCarbonDioxidePartialPressureDelta":
      if(active){
        cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.name, cardiovascular.axisX, cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.axisY);
        cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.axisY = cardiovascular.axisY(cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta)
        cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.axisY.visible = true
        cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.axisY.titleText = cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.name)){
        cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.meanArterialCarbonDioxidePartialPressureDelta);
      }
      break;
      case "meanCentralVenousPressure":
      if(active){
        cardiovascular.requests.meanCentralVenousPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.meanCentralVenousPressure.name, cardiovascular.axisX, cardiovascular.requests.meanCentralVenousPressure.axisY);
        cardiovascular.requests.meanCentralVenousPressure.axisY = cardiovascular.axisY(cardiovascular.requests.meanCentralVenousPressure)
        cardiovascular.requests.meanCentralVenousPressure.axisY.visible = true
        cardiovascular.requests.meanCentralVenousPressure.axisY.titleText = cardiovascular.requests.meanCentralVenousPressure.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.meanCentralVenousPressure.name)){
        cardiovascular.requests.meanCentralVenousPressure.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.meanCentralVenousPressure);
      }
      break;
      case "meanSkinFlow":
      if(active){
        cardiovascular.requests.meanSkinFlow = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.meanSkinFlow.name, cardiovascular.axisX, cardiovascular.requests.meanSkinFlow.axisY);
        cardiovascular.requests.meanSkinFlow.axisY = cardiovascular.axisY(cardiovascular.requests.meanSkinFlow)
        cardiovascular.requests.meanSkinFlow.axisY.visible = true
        cardiovascular.requests.meanSkinFlow.axisY.titleText = cardiovascular.requests.meanSkinFlow.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.meanSkinFlow.name)){
        cardiovascular.requests.meanSkinFlow.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.meanSkinFlow);
      }
      break;
      case "pulmonaryArterialPressure":
      if(active){
        cardiovascular.requests.pulmonaryArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryArterialPressure.name, cardiovascular.axisX, cardiovascular.requests.pulmonaryArterialPressure.axisY);
        cardiovascular.requests.pulmonaryArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryArterialPressure)
        cardiovascular.requests.pulmonaryArterialPressure.axisY.visible = true
        cardiovascular.requests.pulmonaryArterialPressure.axisY.titleText = cardiovascular.requests.pulmonaryArterialPressure.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryArterialPressure.name)){
        cardiovascular.requests.pulmonaryArterialPressure.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.pulmonaryArterialPressure);
      }
      break;
      case "pulmonaryCapillariesWedgePressure":
      if(active){
        cardiovascular.requests.pulmonaryCapillariesWedgePressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryCapillariesWedgePressure.name, cardiovascular.axisX, cardiovascular.requests.pulmonaryCapillariesWedgePressure.axisY);
        cardiovascular.requests.pulmonaryCapillariesWedgePressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryCapillariesWedgePressure)
        cardiovascular.requests.pulmonaryCapillariesWedgePressure.axisY.visible = true
        cardiovascular.requests.pulmonaryCapillariesWedgePressure.axisY.titleText = cardiovascular.requests.pulmonaryCapillariesWedgePressure.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryCapillariesWedgePressure.name)){
        cardiovascular.requests.pulmonaryCapillariesWedgePressure.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.pulmonaryCapillariesWedgePressure);
      }
      break;
      case "pulmonaryDiastolicArterialPressure":
      if(active){
        cardiovascular.requests.pulmonaryDiastolicArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryDiastolicArterialPressure.name, cardiovascular.axisX, cardiovascular.requests.pulmonaryDiastolicArterialPressure.axisY);
        cardiovascular.requests.pulmonaryDiastolicArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryDiastolicArterialPressure)
        cardiovascular.requests.pulmonaryDiastolicArterialPressure.axisY.visible = true
        cardiovascular.requests.pulmonaryDiastolicArterialPressure.axisY.titleText = cardiovascular.requests.pulmonaryDiastolicArterialPressure.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryDiastolicArterialPressure.name)){
        cardiovascular.requests.pulmonaryDiastolicArterialPressure.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.pulmonaryDiastolicArterialPressure);
      }
      break;
      case "pulmonaryMeanArterialPressure":
      if(active){
        cardiovascular.requests.pulmonaryMeanArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryMeanArterialPressure.name, cardiovascular.axisX, cardiovascular.requests.pulmonaryMeanArterialPressure.axisY);
        cardiovascular.requests.pulmonaryMeanArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryMeanArterialPressure)
        cardiovascular.requests.pulmonaryMeanArterialPressure.axisY.visible = true
        cardiovascular.requests.pulmonaryMeanArterialPressure.axisY.titleText = cardiovascular.requests.pulmonaryMeanArterialPressure.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryMeanArterialPressure.name)){
        cardiovascular.requests.pulmonaryMeanArterialPressure.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.pulmonaryMeanArterialPressure);
      }
      break;
      case "pulmonaryMeanCapillaryFlow":
      if(active){
        cardiovascular.requests.pulmonaryMeanCapillaryFlow = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryMeanCapillaryFlow.name, cardiovascular.axisX, cardiovascular.requests.pulmonaryMeanCapillaryFlow.axisY);
        cardiovascular.requests.pulmonaryMeanCapillaryFlow.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryMeanCapillaryFlow)
        cardiovascular.requests.pulmonaryMeanCapillaryFlow.axisY.visible = true
        cardiovascular.requests.pulmonaryMeanCapillaryFlow.axisY.titleText = cardiovascular.requests.pulmonaryMeanCapillaryFlow.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryMeanCapillaryFlow.name)){
        cardiovascular.requests.pulmonaryMeanCapillaryFlow.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.pulmonaryMeanCapillaryFlow);
      }
      break;
      case "pulmonaryMeanShuntFlow":
      if(active){
        cardiovascular.requests.pulmonaryMeanShuntFlow = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryMeanShuntFlow.name, cardiovascular.axisX, cardiovascular.requests.pulmonaryMeanShuntFlow.axisY);
        cardiovascular.requests.pulmonaryMeanShuntFlow.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryMeanShuntFlow)
        cardiovascular.requests.pulmonaryMeanShuntFlow.axisY.visible = true
        cardiovascular.requests.pulmonaryMeanShuntFlow.axisY.titleText = cardiovascular.requests.pulmonaryMeanShuntFlow.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryMeanShuntFlow.name)){
        cardiovascular.requests.pulmonaryMeanShuntFlow.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.pulmonaryMeanShuntFlow);
      }
      break;
      case "pulmonarySystolicArterialPressure":
      if(active){
        cardiovascular.requests.pulmonarySystolicArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonarySystolicArterialPressure.name, cardiovascular.axisX, cardiovascular.requests.pulmonarySystolicArterialPressure.axisY);
        cardiovascular.requests.pulmonarySystolicArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonarySystolicArterialPressure)
        cardiovascular.requests.pulmonarySystolicArterialPressure.axisY.visible = true
        cardiovascular.requests.pulmonarySystolicArterialPressure.axisY.titleText = cardiovascular.requests.pulmonarySystolicArterialPressure.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonarySystolicArterialPressure.name)){
        cardiovascular.requests.pulmonarySystolicArterialPressure.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.pulmonarySystolicArterialPressure);
      }
      break;
      case "pulmonaryVascularResistance":
      if(active){
        cardiovascular.requests.pulmonaryVascularResistance = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryVascularResistance.name, cardiovascular.axisX, cardiovascular.requests.pulmonaryVascularResistance.axisY);
        cardiovascular.requests.pulmonaryVascularResistance.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryVascularResistance)
        cardiovascular.requests.pulmonaryVascularResistance.axisY.visible = true
        cardiovascular.requests.pulmonaryVascularResistance.axisY.titleText = cardiovascular.requests.pulmonaryVascularResistance.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryVascularResistance.name)){
        cardiovascular.requests.pulmonaryVascularResistance.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.pulmonaryVascularResistance);
      }
      break;
      case "pulmonaryVascularResistanceIndex":
      if(active){
        cardiovascular.requests.pulmonaryVascularResistanceIndex = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulmonaryVascularResistanceIndex.name, cardiovascular.axisX, cardiovascular.requests.pulmonaryVascularResistanceIndex.axisY);
        cardiovascular.requests.pulmonaryVascularResistanceIndex.axisY = cardiovascular.axisY(cardiovascular.requests.pulmonaryVascularResistanceIndex)
        cardiovascular.requests.pulmonaryVascularResistanceIndex.axisY.visible = true
        cardiovascular.requests.pulmonaryVascularResistanceIndex.axisY.titleText = cardiovascular.requests.pulmonaryVascularResistanceIndex.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.pulmonaryVascularResistanceIndex.name)){
        cardiovascular.requests.pulmonaryVascularResistanceIndex.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.pulmonaryVascularResistanceIndex);
      }
      break;
      case "pulsePressure":
      if(active){
        cardiovascular.requests.pulsePressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.pulsePressure.name, cardiovascular.axisX, cardiovascular.requests.pulsePressure.axisY);
        cardiovascular.requests.pulsePressure.axisY = cardiovascular.axisY(cardiovascular.requests.pulsePressure)
        cardiovascular.requests.pulsePressure.axisY.visible = true
        cardiovascular.requests.pulsePressure.axisY.titleText = cardiovascular.requests.pulsePressure.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.pulsePressure.name)){
        cardiovascular.requests.pulsePressure.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.pulsePressure);
      }
      break;
      case "systemicVascularResistance":
      if(active){
        cardiovascular.requests.systemicVascularResistance = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.systemicVascularResistance.name, cardiovascular.axisX, cardiovascular.requests.systemicVascularResistance.axisY);
        cardiovascular.requests.systemicVascularResistance.axisY = cardiovascular.axisY(cardiovascular.requests.systemicVascularResistance)
        cardiovascular.requests.systemicVascularResistance.axisY.visible = true
        cardiovascular.requests.systemicVascularResistance.axisY.titleText = cardiovascular.requests.systemicVascularResistance.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.systemicVascularResistance.name)){
        cardiovascular.requests.systemicVascularResistance.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.systemicVascularResistance);
      }
      break;
      case "systolicArterialPressure":
      if(active){
        cardiovascular.requests.systolicArterialPressure = cardiovascular.createSeries(ChartView.SeriesTypeLine, cardiovascular.requests.systolicArterialPressure.name, cardiovascular.axisX, cardiovascular.requests.systolicArterialPressure.axisY);
        cardiovascular.requests.systolicArterialPressure.axisY = cardiovascular.axisY(cardiovascular.requests.systolicArterialPressure)
        cardiovascular.requests.systolicArterialPressure.axisY.visible = true
        cardiovascular.requests.systolicArterialPressure.axisY.titleText = cardiovascular.requests.systolicArterialPressure.name
        
      } else  if(cardiovascular.series(cardiovascular.requests.systolicArterialPressure.name)){
        cardiovascular.requests.systolicArterialPressure.axisY.visible = false
        cardiovascular.removeSeries(cardiovascular.requests.systolicArterialPressure);
      }
      break;
    }
  }
  function toggleDrugsSeries(request, active){
    const DEFAULT_UNIT = ""
    const DEFAULT_LABEL_FORMAT = [Qt.binding( function() { return (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e';} )]
     switch(request){
      case "systolicArterialPressure":
      if(active){
        drugs.requests.bronchodilationLevel = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.bronchodilationLevel.name, drugs.axisX, drugs.requests.bronchodilationLevel.axisY);
        drugs.requests.bronchodilationLevel.axisY = drugs.axisY(drugs.requests.bronchodilationLevel)
        drugs.requests.bronchodilationLevel.axisY.visible = true
        drugs.requests.bronchodilationLevel.axisY.titleText = drugs.requests.bronchodilationLevel.name
        
      } else  if(drugs.series(drugs.requests.bronchodilationLevel.name)){
        drugs.requests.bronchodilationLevel.axisY.visible = false
        drugs.removeSeries(drugs.requests.bronchodilationLevel);
      }
      break;
      case "heartRateChange":
      if(active){
      drugs.requests.heartRateChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.heartRateChange.name, drugs.axisX, drugs.requests.heartRateChange.axisY);
      drugs.requests.heartRateChange.axisY = drugs.axisY(drugs.requests.heartRateChange)
        drugs.requests.heartRateChange.axisY.visible = true
        drugs.requests.heartRateChange.axisY.titleText = drugs.requests.heartRateChange.name
        
      } else  if(drugs.series(drugs.requests.heartRateChange.name)){
        drugs.requests.heartRateChange.axisY.visible = false
        drugs.removeSeries(drugs.requests.heartRateChange);
      }
      break;
      case "hemorrhageChange":
      if(active){
      drugs.requests.hemorrhageChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.hemorrhageChange.name, drugs.axisX, drugs.requests.hemorrhageChange.axisY);
      drugs.requests.hemorrhageChange.axisY = drugs.axisY(drugs.requests.hemorrhageChange)
        drugs.requests.hemorrhageChange.axisY.visible = true
        drugs.requests.hemorrhageChange.axisY.titleText = drugs.requests.hemorrhageChange.name
        
      } else  if(drugs.series(drugs.requests.hemorrhageChange.name)){
        drugs.requests.hemorrhageChange.axisY.visible = false
        drugs.removeSeries(drugs.requests.hemorrhageChange);
      }
      break;
      case "meanBloodPressureChange":
      if(active){
      drugs.requests.meanBloodPressureChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.meanBloodPressureChange.name, drugs.axisX, drugs.requests.meanBloodPressureChange.axisY);
      drugs.requests.meanBloodPressureChange.axisY = drugs.axisY(drugs.requests.meanBloodPressureChange)
        drugs.requests.meanBloodPressureChange.axisY.visible = true
        drugs.requests.meanBloodPressureChange.axisY.titleText = drugs.requests.meanBloodPressureChange.name
        
      } else  if(drugs.series(drugs.requests.meanBloodPressureChange.name)){
        drugs.requests.meanBloodPressureChange.axisY.visible = false
        drugs.removeSeries(drugs.requests.meanBloodPressureChange);
      }
      break;
      case "neuromuscularBlockLevel":
      if(active){
      drugs.requests.neuromuscularBlockLevel = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.neuromuscularBlockLevel.name, drugs.axisX, drugs.requests.neuromuscularBlockLevel.axisY);
      drugs.requests.neuromuscularBlockLevel.axisY = drugs.axisY(drugs.requests.neuromuscularBlockLevel)
        drugs.requests.neuromuscularBlockLevel.axisY.visible = true
        drugs.requests.neuromuscularBlockLevel.axisY.titleText = drugs.requests.neuromuscularBlockLevel.name
        
      } else  if(drugs.series(drugs.requests.neuromuscularBlockLevel.name)){
        drugs.requests.neuromuscularBlockLevel.axisY.visible = false
        drugs.removeSeries(drugs.requests.neuromuscularBlockLevel);
      }
      break;
      case "pulsePressureChange":
      if(active){
      drugs.requests.pulsePressureChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.pulsePressureChange.name, drugs.axisX, drugs.requests.pulsePressureChange.axisY);
      drugs.requests.pulsePressureChange.axisY = drugs.axisY(drugs.requests.pulsePressureChange)
        drugs.requests.pulsePressureChange.axisY.visible = true
        drugs.requests.pulsePressureChange.axisY.titleText = drugs.requests.pulsePressureChange.name
        
      } else  if(drugs.series(drugs.requests.pulsePressureChange.name)){
        drugs.requests.pulsePressureChange.axisY.visible = false
        drugs.removeSeries(drugs.requests.pulsePressureChange);
      }
      break;
      case "respirationRateChange":
      if(active){
      drugs.requests.respirationRateChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.respirationRateChange.name, drugs.axisX, drugs.requests.respirationRateChange.axisY);
      drugs.requests.respirationRateChange.axisY = drugs.axisY(drugs.requests.respirationRateChange)
        drugs.requests.respirationRateChange.axisY.visible = true
        drugs.requests.respirationRateChange.axisY.titleText = drugs.requests.respirationRateChange.name
        
      } else  if(drugs.series(drugs.requests.respirationRateChange.name)){
        drugs.requests.respirationRateChange.axisY.visible = false
        drugs.removeSeries(drugs.requests.respirationRateChange);
      }
      break;
      case "sedationLevel":
      if(active){
      drugs.requests.sedationLevel = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.sedationLevel.name, drugs.axisX, drugs.requests.sedationLevel.axisY);
      drugs.requests.sedationLevel.axisY = drugs.axisY(drugs.requests.sedationLevel)
        drugs.requests.sedationLevel.axisY.visible = true
        drugs.requests.sedationLevel.axisY.titleText = drugs.requests.sedationLevel.name
        
      } else  if(drugs.series(drugs.requests.sedationLevel.name)){
        drugs.requests.sedationLevel.axisY.visible = false
        drugs.removeSeries(drugs.requests.sedationLevel);
      }
      break;
      case "tidalVolumeChange":
      if(active){
      drugs.requests.tidalVolumeChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.tidalVolumeChange.name, drugs.axisX, drugs.requests.tidalVolumeChange.axisY);
      drugs.requests.tidalVolumeChange.axisY = drugs.axisY(drugs.requests.tidalVolumeChange)
        drugs.requests.tidalVolumeChange.axisY.visible = true
        drugs.requests.tidalVolumeChange.axisY.titleText = drugs.requests.tidalVolumeChange.name
        
      } else  if(drugs.series(drugs.requests.tidalVolumeChange.name)){
        drugs.requests.tidalVolumeChange.axisY.visible = false
        drugs.removeSeries(drugs.requests.tidalVolumeChange);
      }
      break;
      case "tubularPermeabilityChange":
      if(active){
      drugs.requests.tubularPermeabilityChange = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.tubularPermeabilityChange.name, drugs.axisX, drugs.requests.tubularPermeabilityChange.axisY);
      drugs.requests.tubularPermeabilityChange.axisY = drugs.axisY(drugs.requests.tubularPermeabilityChange)
        drugs.requests.tubularPermeabilityChange.axisY.visible = true
        drugs.requests.tubularPermeabilityChange.axisY.titleText = drugs.requests.tubularPermeabilityChange.name
        
      } else  if(drugs.series(drugs.requests.tubularPermeabilityChange.name)){
        drugs.requests.tubularPermeabilityChange.axisY.visible = false
        drugs.removeSeries(drugs.requests.tubularPermeabilityChange);
      }
      break;
      case "centralNervousResponse":
      if(active){
        drugs.requests.centralNervousResponse = drugs.createSeries(ChartView.SeriesTypeLine, drugs.requests.centralNervousResponse.name, drugs.axisX, drugs.requests.centralNervousResponse.axisY);
        drugs.requests.centralNervousResponse.axisY = drugs.axisY(drugs.requests.centralNervousResponse)
        drugs.requests.centralNervousResponse.axisY.visible = true
        drugs.requests.centralNervousResponse.axisY.titleText = drugs.requests.centralNervousResponse.name
        
      } else  if  (drugs.series(drugs.requests.centralNervousResponse.name)){
        drugs.requests.centralNervousResponse.axisY.visible = false
        drugs.removeSeries(drugs.requests.centralNervousResponse);
      }
      break;

     }
  }
  function toggleEndocrineSeries(request, active){
    const DEFAULT_UNIT = ""
    const DEFAULT_LABEL_FORMAT = [Qt.binding( function() { return (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e';} )]
    switch(request){
      case "insulinSynthesisRate":
      if(active){
        endocrine.requests.insulinSynthesisRate = endocrine.createSeries(ChartView.SeriesTypeLine, endocrine.requests.insulinSynthesisRate.name, endocrine.axisX, endocrine.requests.insulinSynthesisRate.axisY);
        endocrine.requests.insulinSynthesisRate.axisY = endocrine.axisY(endocrine.requests.insulinSynthesisRate)
        endocrine.requests.insulinSynthesisRate.axisY.visible = true
        endocrine.requests.insulinSynthesisRate.axisY.titleText = endocrine.requests.insulinSynthesisRate.name
        
      } else  if  (endocrine.series(endocrine.requests.insulinSynthesisRate.name)){
        endocrine.requests.insulinSynthesisRate.axisY.visible = false
        endocrine.removeSeries(endocrine.requests.insulinSynthesisRate);
      }
      break;
      case "glucagonSynthesisRate":
      if(active){
        endocrine.requests.glucagonSynthesisRate = endocrine.createSeries(ChartView.SeriesTypeLine, endocrine.requests.glucagonSynthesisRate.name, endocrine.axisX, endocrine.requests.glucagonSynthesisRate.axisY);
        endocrine.requests.glucagonSynthesisRate.axisY = endocrine.axisY(endocrine.requests.glucagonSynthesisRate)
        endocrine.requests.glucagonSynthesisRate.axisY.visible = true
        endocrine.requests.glucagonSynthesisRate.axisY.titleText = endocrine.requests.glucagonSynthesisRate.name
        
      } else  if  (endocrine.series(endocrine.requests.glucagonSynthesisRate.name)){
        endocrine.requests.glucagonSynthesisRate.axisY.visible = false
        endocrine.removeSeries(endocrine.requests.glucagonSynthesisRate);
      }
      break;
    }
  }
  function toggleEnergySeries(request, active){
    const DEFAULT_UNIT = ""
    const DEFAULT_LABEL_FORMAT = [Qt.binding( function() { return (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e';} )]
    switch(request){
      case "achievedExerciseLevel":
      if(active){
        energy.requests.achievedExerciseLevel = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.achievedExerciseLevel.name, energy.axisX, energy.requests.achievedExerciseLevel.axisY);
        energy.requests.achievedExerciseLevel.axisY = energy.axisY(energy.requests.achievedExerciseLevel)
        energy.requests.achievedExerciseLevel.axisY.visible = true
        energy.requests.achievedExerciseLevel.axisY.titleText = energy.requests.achievedExerciseLevel.name
        
      } else  if  (energy.series(energy.requests.achievedExerciseLevel.name)){
        energy.requests.achievedExerciseLevel.axisY.visible = false
        energy.removeSeries(energy.requests.achievedExerciseLevel);
      }
      break;
      case "chlorideLostToSweat":
      if(active){
        energy.requests.chlorideLostToSweat = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.chlorideLostToSweat.name, energy.axisX, energy.requests.chlorideLostToSweat.axisY);
        energy.requests.chlorideLostToSweat.axisY = energy.axisY(energy.requests.chlorideLostToSweat)
        energy.requests.chlorideLostToSweat.axisY.visible = true
        energy.requests.chlorideLostToSweat.axisY.titleText = energy.requests.chlorideLostToSweat.name
        
      } else  if  (energy.series(energy.requests.chlorideLostToSweat.name)){
        energy.requests.chlorideLostToSweat.axisY.visible = false
        energy.removeSeries(energy.requests.chlorideLostToSweat);
      }
      break;
      case "coreTemperature":
      if(active){
        energy.requests.coreTemperature = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.coreTemperature.name, energy.axisX, energy.requests.coreTemperature.axisY);
        energy.requests.coreTemperature.axisY = energy.axisY(energy.requests.coreTemperature)
        energy.requests.coreTemperature.axisY.visible = true
        energy.requests.coreTemperature.axisY.titleText = energy.requests.coreTemperature.name
        
      } else  if  (energy.series(energy.requests.coreTemperature.name)){
        energy.requests.coreTemperature.axisY.visible = false
        energy.removeSeries(energy.requests.coreTemperature);
      }
      break;
      case "creatinineProductionRate":
      if(active){
        energy.requests.creatinineProductionRate = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.creatinineProductionRate.name, energy.axisX, energy.requests.creatinineProductionRate.axisY);
        energy.requests.creatinineProductionRate.axisY = energy.axisY(energy.requests.creatinineProductionRate)
        energy.requests.creatinineProductionRate.axisY.visible = true
        energy.requests.creatinineProductionRate.axisY.titleText = energy.requests.creatinineProductionRate.name
        
      } else  if  (energy.series(energy.requests.creatinineProductionRate.name)){
        energy.requests.creatinineProductionRate.axisY.visible = false
        energy.removeSeries(energy.requests.creatinineProductionRate);
      }
      break;
      case "exerciseMeanArterialPressureDelta":
      if(active){
        energy.requests.exerciseMeanArterialPressureDelta = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.exerciseMeanArterialPressureDelta.name, energy.axisX, energy.requests.exerciseMeanArterialPressureDelta.axisY);
        energy.requests.exerciseMeanArterialPressureDelta.axisY = energy.axisY(energy.requests.exerciseMeanArterialPressureDelta)
        energy.requests.exerciseMeanArterialPressureDelta.axisY.visible = true
        energy.requests.exerciseMeanArterialPressureDelta.axisY.titleText = energy.requests.exerciseMeanArterialPressureDelta.name
        
      } else  if  (energy.series(energy.requests.exerciseMeanArterialPressureDelta.name)){
        energy.requests.exerciseMeanArterialPressureDelta.axisY.visible = false
        energy.removeSeries(energy.requests.exerciseMeanArterialPressureDelta);
      }
      break;
      case "fatigueLevel":
      if(active){
        energy.requests.fatigueLevel = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.fatigueLevel.name, energy.axisX, energy.requests.fatigueLevel.axisY);
        energy.requests.fatigueLevel.axisY = energy.axisY(energy.requests.fatigueLevel)
        energy.requests.fatigueLevel.axisY.visible = true
        energy.requests.fatigueLevel.axisY.titleText = energy.requests.fatigueLevel.name
        
      } else  if  (energy.series(energy.requests.fatigueLevel.name)){
        energy.requests.fatigueLevel.axisY.visible = false
        energy.removeSeries(energy.requests.fatigueLevel);
      }
      break;
      case "lactateProductionRate":
      if(active){
        energy.requests.lactateProductionRate = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.lactateProductionRate.name, energy.axisX, energy.requests.lactateProductionRate.axisY);
        energy.requests.lactateProductionRate.axisY = energy.axisY(energy.requests.lactateProductionRate)
        energy.requests.lactateProductionRate.axisY.visible = true
        energy.requests.lactateProductionRate.axisY.titleText = energy.requests.lactateProductionRate.name
        
      } else  if  (energy.series(energy.requests.lactateProductionRate.name)){
        energy.requests.lactateProductionRate.axisY.visible = false
        energy.removeSeries(energy.requests.lactateProductionRate);
      }
      break;
      case "potassiumLostToSweat":
      if(active){
        energy.requests.potassiumLostToSweat = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.potassiumLostToSweat.name, energy.axisX, energy.requests.potassiumLostToSweat.axisY);
        energy.requests.potassiumLostToSweat.axisY = energy.axisY(energy.requests.potassiumLostToSweat)
        energy.requests.potassiumLostToSweat.axisY.visible = true
        energy.requests.potassiumLostToSweat.axisY.titleText = energy.requests.potassiumLostToSweat.name
        
      } else  if  (energy.series(energy.requests.potassiumLostToSweat.name)){
        energy.requests.potassiumLostToSweat.axisY.visible = false
        energy.removeSeries(energy.requests.potassiumLostToSweat);
      }
      break;
      case "skinTemperature":
      if(active){
        energy.requests.skinTemperature = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.skinTemperature.name, energy.axisX, energy.requests.skinTemperature.axisY);
        energy.requests.skinTemperature.axisY = energy.axisY(energy.requests.skinTemperature)
        energy.requests.skinTemperature.axisY.visible = true
        energy.requests.skinTemperature.axisY.titleText = energy.requests.skinTemperature.name
        
      } else  if  (energy.series(energy.requests.skinTemperature.name)){
        energy.requests.skinTemperature.axisY.visible = false
        energy.removeSeries(energy.requests.skinTemperature);
      }
      break;
      case "sodiumLostToSweat":
      if(active){
        energy.requests.sodiumLostToSweat = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.sodiumLostToSweat.name, energy.axisX, energy.requests.sodiumLostToSweat.axisY);
        energy.requests.sodiumLostToSweat.axisY = energy.axisY(energy.requests.sodiumLostToSweat)
        energy.requests.sodiumLostToSweat.axisY.visible = true
        energy.requests.sodiumLostToSweat.axisY.titleText = energy.requests.sodiumLostToSweat.name
        
      } else  if  (energy.series(energy.requests.sodiumLostToSweat.name)){
        energy.requests.sodiumLostToSweat.axisY.visible = false
        energy.removeSeries(energy.requests.sodiumLostToSweat);
      }
      break;
      case "sweatRate":
      if(active){
        energy.requests.sweatRate = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.sweatRate.name, energy.axisX, energy.requests.sweatRate.axisY);
        energy.requests.sweatRate.axisY = energy.axisY(energy.requests.sweatRate)
        energy.requests.sweatRate.axisY.visible = true
        energy.requests.sweatRate.axisY.titleText = energy.requests.sweatRate.name
        
      } else  if  (energy.series(energy.requests.sweatRate.name)){
        energy.requests.sweatRate.axisY.visible = false
        energy.removeSeries(energy.requests.sweatRate);
      }
      break;
      case "totalMetabolicRate":
      if(active){
        energy.requests.totalMetabolicRate = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.totalMetabolicRate.name, energy.axisX, energy.requests.totalMetabolicRate.axisY);
        energy.requests.totalMetabolicRate.axisY = energy.axisY(energy.requests.totalMetabolicRate)
        energy.requests.totalMetabolicRate.axisY.visible = true
        energy.requests.totalMetabolicRate.axisY.titleText = energy.requests.totalMetabolicRate.name
        
      } else  if  (energy.series(energy.requests.totalMetabolicRate.name)){
        energy.requests.totalMetabolicRate.axisY.visible = false
        energy.removeSeries(energy.requests.totalMetabolicRate);
      }
      break;
      case "totalWorkRateLevel":
      if(active){
        energy.requests.totalWorkRateLevel = energy.createSeries(ChartView.SeriesTypeLine, energy.requests.totalWorkRateLevel.name, energy.axisX, energy.requests.totalWorkRateLevel.axisY);
        energy.requests.totalWorkRateLevel.axisY = energy.axisY(energy.requests.totalWorkRateLevel)
        energy.requests.totalWorkRateLevel.axisY.visible = true
        energy.requests.totalWorkRateLevel.axisY.titleText = energy.requests.totalWorkRateLevel.name
        
      } else  if  (energy.series(energy.requests.totalWorkRateLevel.name)){
        energy.requests.totalWorkRateLevel.axisY.visible = false
        energy.removeSeries(energy.requests.totalWorkRateLevel);
      }
      break;
    }
  }
  function toggleGastrointestinalSeries(request, active){
    const DEFAULT_UNIT = ""
    const DEFAULT_LABEL_FORMAT = [Qt.binding( function() { return (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e';} )]
    switch(request){
      case "chymeAbsorptionRate":
      if(active){
        gastrointestinal.requests.chymeAbsorptionRate = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.chymeAbsorptionRate.name, gastrointestinal.axisX, gastrointestinal.requests.chymeAbsorptionRate.axisY);
        gastrointestinal.requests.chymeAbsorptionRate.axisY = gastrointestinal.axisY(gastrointestinal.requests.chymeAbsorptionRate)
        gastrointestinal.requests.chymeAbsorptionRate.axisY.visible = true
        gastrointestinal.requests.chymeAbsorptionRate.axisY.titleText = gastrointestinal.requests.chymeAbsorptionRate.name
        
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.chymeAbsorptionRate.name)){
        gastrointestinal.requests.chymeAbsorptionRate.axisY.visible = false
        gastrointestinal.removeSeries(gastrointestinal.requests.chymeAbsorptionRate);
      }
      break;
      case "stomachContents_calcium":
      if(active){
        gastrointestinal.requests.stomachContents_calcium = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_calcium.name, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_calcium.axisY);
        gastrointestinal.requests.stomachContents_calcium.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_calcium)
        gastrointestinal.requests.stomachContents_calcium.axisY.visible = true
        gastrointestinal.requests.stomachContents_calcium.axisY.titleText = gastrointestinal.requests.stomachContents_calcium.name
        
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_calcium.name)){
        gastrointestinal.requests.stomachContents_calcium.axisY.visible = false
        gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_calcium);
      }
      break;
      case "stomachContents_carbohydrates":
      if(active){
        gastrointestinal.requests.stomachContents_carbohydrates = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_carbohydrates.name, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_carbohydrates.axisY);
        gastrointestinal.requests.stomachContents_carbohydrates.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_carbohydrates)
        gastrointestinal.requests.stomachContents_carbohydrates.axisY.visible = true
        gastrointestinal.requests.stomachContents_carbohydrates.axisY.titleText = gastrointestinal.requests.stomachContents_carbohydrates.name
        
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_carbohydrates.name)){
        gastrointestinal.requests.stomachContents_carbohydrates.axisY.visible = false
        gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_carbohydrates);
      }
      break;
      case "stomachContents_carbohydrateDigationRate":
      if(active){
        gastrointestinal.requests.stomachContents_carbohydrateDigationRate = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_carbohydrateDigationRate.name, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_carbohydrateDigationRate.axisY);
        gastrointestinal.requests.stomachContents_carbohydrateDigationRate.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_carbohydrateDigationRate)
        gastrointestinal.requests.stomachContents_carbohydrateDigationRate.axisY.visible = true
        gastrointestinal.requests.stomachContents_carbohydrateDigationRate.axisY.titleText = gastrointestinal.requests.stomachContents_carbohydrateDigationRate.name
        
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_carbohydrateDigationRate.name)){
        gastrointestinal.requests.stomachContents_carbohydrateDigationRate.axisY.visible = false
        gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_carbohydrateDigationRate);
      }
      break;
      case "stomachContents_fat":
      if(active){
        gastrointestinal.requests.stomachContents_fat = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_fat.name, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_fat.axisY);
        gastrointestinal.requests.stomachContents_fat.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_fat)
        gastrointestinal.requests.stomachContents_fat.axisY.visible = true
        gastrointestinal.requests.stomachContents_fat.axisY.titleText = gastrointestinal.requests.stomachContents_fat.name
        
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_fat.name)){
        gastrointestinal.requests.stomachContents_fat.axisY.visible = false
        gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_fat);
      }
      break;
      case "stomachContents_fatDigtationRate":
      if(active){
        gastrointestinal.requests.stomachContents_fatDigtationRate = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_fatDigtationRate.name, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_fatDigtationRate.axisY);
        gastrointestinal.requests.stomachContents_fatDigtationRate.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_fatDigtationRate)
        gastrointestinal.requests.stomachContents_fatDigtationRate.axisY.visible = true
        gastrointestinal.requests.stomachContents_fatDigtationRate.axisY.titleText = gastrointestinal.requests.stomachContents_fatDigtationRate.name
        
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_fatDigtationRate.name)){
        gastrointestinal.requests.stomachContents_fatDigtationRate.axisY.visible = false
        gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_fatDigtationRate);
      }
      break;
      case "stomachContents_protien":
      if(active){
        gastrointestinal.requests.stomachContents_protien = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_protien.name, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_protien.axisY);
        gastrointestinal.requests.stomachContents_protien.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_protien)
        gastrointestinal.requests.stomachContents_protien.axisY.visible = true
        gastrointestinal.requests.stomachContents_protien.axisY.titleText = gastrointestinal.requests.stomachContents_protien.name
        
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_protien.name)){
        gastrointestinal.requests.stomachContents_protien.axisY.visible = false
        gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_protien);
      }
      break;
      case "stomachContents_protienDigtationRate":
      if(active){
        gastrointestinal.requests.stomachContents_protienDigtationRate = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_protienDigtationRate.name, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_protienDigtationRate.axisY);
        gastrointestinal.requests.stomachContents_protienDigtationRate.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_protienDigtationRate)
        gastrointestinal.requests.stomachContents_protienDigtationRate.axisY.visible = true
        gastrointestinal.requests.stomachContents_protienDigtationRate.axisY.titleText = gastrointestinal.requests.stomachContents_protienDigtationRate.name
        
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_protienDigtationRate.name)){
        gastrointestinal.requests.stomachContents_protienDigtationRate.axisY.visible = false
        gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_protienDigtationRate);
      }
      break;
      case "stomachContents_sodium":
      if(active){
        gastrointestinal.requests.stomachContents_sodium = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_sodium.name, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_sodium.axisY);
        gastrointestinal.requests.stomachContents_sodium.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_sodium)
        gastrointestinal.requests.stomachContents_sodium.axisY.visible = true
        gastrointestinal.requests.stomachContents_sodium.axisY.titleText = gastrointestinal.requests.stomachContents_sodium.name
        
      } else  if  (engastrointestinalergy.series(gastrointestinal.requests.stomachContents_sodium.name)){
        gastrointestinal.requests.stomachContents_sodium.axisY.visible = false
        gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_sodium);
      }
      break;
      case "stomachContents_water":
      if(active){
        gastrointestinal.requests.stomachContents_water = gastrointestinal.createSeries(ChartView.SeriesTypeLine, gastrointestinal.requests.stomachContents_water.name, gastrointestinal.axisX, gastrointestinal.requests.stomachContents_water.axisY);
        gastrointestinal.requests.stomachContents_water.axisY = gastrointestinal.axisY(gastrointestinal.requests.stomachContents_water)
        gastrointestinal.requests.stomachContents_water.axisY.visible = true
        gastrointestinal.requests.stomachContents_water.axisY.titleText = gastrointestinal.requests.stomachContents_water.name
        
      } else  if  (gastrointestinal.series(gastrointestinal.requests.stomachContents_water.name)){
        gastrointestinal.requests.stomachContents_water.axisY.visible = false
        gastrointestinal.removeSeries(gastrointestinal.requests.stomachContents_water);
      }
      break;
    }
  }
  function toggleHepaticSeries(request, active){
    const DEFAULT_UNIT = ""
    const DEFAULT_LABEL_FORMAT = [Qt.binding( function() { return (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e';} )]
    switch(request){
      case "ketoneproductionRate":
      if(active){
        hepatic.requests.ketoneproductionRate = hepatic.createSeries(ChartView.SeriesTypeLine, hepatic.requests.ketoneproductionRate.name, hepatic.axisX, hepatic.requests.ketoneproductionRate.axisY);
        hepatic.requests.ketoneproductionRate.axisY = hepatic.axisY(hepatic.requests.ketoneproductionRate)
        hepatic.requests.ketoneproductionRate.axisY.visible = true
        hepatic.requests.ketoneproductionRate.axisY.titleText = hepatic.requests.ketoneproductionRate.name
        
      } else  if  (hepatic.series(hepatic.requests.ketoneproductionRate.name)){
        hepatic.requests.ketoneproductionRate.axisY.visible = false
        hepatic.removeSeries(hepatic.requests.ketoneproductionRate);
      }
      break;
      case "hepaticGluconeogenesisRate":
      if(active){
        hepatic.requests.hepaticGluconeogenesisRate = hepatic.createSeries(ChartView.SeriesTypeLine, hepatic.requests.hepaticGluconeogenesisRate.name, hepatic.axisX, hepatic.requests.hepaticGluconeogenesisRate.axisY);
        hepatic.requests.hepaticGluconeogenesisRate.axisY = hepatic.axisY(hepatic.requests.hepaticGluconeogenesisRate)
        hepatic.requests.hepaticGluconeogenesisRate.axisY.visible = true
        hepatic.requests.hepaticGluconeogenesisRate.axisY.titleText = hepatic.requests.hepaticGluconeogenesisRate.name
        
      } else  if  (hepatic.series(hepatic.requests.hepaticGluconeogenesisRate.name)){
        hepatic.requests.hepaticGluconeogenesisRate.axisY.visible = false
        hepatic.removeSeries(hepatic.requests.hepaticGluconeogenesisRate);
      }
      break;
    }
  }
  function toggleNervousSeries(request, active){
    const DEFAULT_UNIT = ""
    const DEFAULT_LABEL_FORMAT = [Qt.binding( function() { return (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e';} )  ]
    switch(request){
      case "baroreceptorHeartRateScale":
      if(active){
        nervous.requests.baroreceptorHeartRateScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.baroreceptorHeartRateScale.name, nervous.axisX, nervous.requests.baroreceptorHeartRateScale.axisY);
        nervous.requests.baroreceptorHeartRateScale.axisY = nervous.axisY(nervous.requests.baroreceptorHeartRateScale)
        nervous.requests.baroreceptorHeartRateScale.axisY.visible = true
        nervous.requests.baroreceptorHeartRateScale.axisY.titleText = nervous.requests.baroreceptorHeartRateScale.name
        
      } else  if  (nervous.series(nervous.requests.baroreceptorHeartRateScale.name)){
        nervous.requests.baroreceptorHeartRateScale.axisY.visible = false
        nervous.removeSeries(nervous.requests.baroreceptorHeartRateScale);
      }
      break;
      case "baroreceptorHeartElastanceScale":
      if(active){
        nervous.requests.baroreceptorHeartElastanceScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.baroreceptorHeartElastanceScale.name, nervous.axisX, nervous.requests.baroreceptorHeartElastanceScale.axisY);
        nervous.requests.baroreceptorHeartElastanceScale.axisY = nervous.axisY(nervous.requests.baroreceptorHeartElastanceScale)
        nervous.requests.baroreceptorHeartElastanceScale.axisY.visible = true
        nervous.requests.baroreceptorHeartElastanceScale.axisY.titleText = nervous.requests.baroreceptorHeartElastanceScale.name
        
      } else  if  (nervous.series(nervous.requests.baroreceptorHeartElastanceScale.name)){
        nervous.requests.baroreceptorHeartElastanceScale.axisY.visible = false
        nervous.removeSeries(nervous.requests.baroreceptorHeartElastanceScale);
      }
      break;
      case "baroreceptorResistanceScale":
      if(active){
        nervous.requests.baroreceptorResistanceScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.baroreceptorResistanceScale.name, nervous.axisX, nervous.requests.baroreceptorResistanceScale.axisY);
        nervous.requests.baroreceptorResistanceScale.axisY = nervous.axisY(nervous.requests.baroreceptorResistanceScale)
        nervous.requests.baroreceptorResistanceScale.axisY.visible = true
        nervous.requests.baroreceptorResistanceScale.axisY.titleText = nervous.requests.baroreceptorResistanceScale.name
        
      } else  if  (nervous.series(nervous.requests.baroreceptorResistanceScale.name)){
        nervous.requests.baroreceptorResistanceScale.axisY.visible = false
        nervous.removeSeries(nervous.requests.baroreceptorResistanceScale);
      }
      break;
      case "baroreceptorComplianceScale":
      if(active){
        nervous.requests.baroreceptorComplianceScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.baroreceptorComplianceScale.name, nervous.axisX, nervous.requests.baroreceptorComplianceScale.axisY);
        nervous.requests.baroreceptorComplianceScale.axisY = nervous.axisY(nervous.requests.baroreceptorComplianceScale)
        nervous.requests.baroreceptorComplianceScale.axisY.visible = true
        nervous.requests.baroreceptorComplianceScale.axisY.titleText = nervous.requests.baroreceptorComplianceScale.name
        
      } else  if  (nervous.series(nervous.requests.baroreceptorComplianceScale.name)){
        nervous.requests.baroreceptorComplianceScale.axisY.visible = false
        nervous.removeSeries(nervous.requests.baroreceptorComplianceScale);
      }
      break;
      case "chemoreceptorHeartRateScale":
      if(active){
        nervous.requests.chemoreceptorHeartRateScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.chemoreceptorHeartRateScale.name, nervous.axisX, nervous.requests.chemoreceptorHeartRateScale.axisY);
        nervous.requests.chemoreceptorHeartRateScale.axisY = nervous.axisY(nervous.requests.chemoreceptorHeartRateScale)
        nervous.requests.chemoreceptorHeartRateScale.axisY.visible = true
        nervous.requests.chemoreceptorHeartRateScale.axisY.titleText = nervous.requests.chemoreceptorHeartRateScale.name
        
      } else  if  (nervous.series(nervous.requests.chemoreceptorHeartRateScale.name)){
        nervous.requests.chemoreceptorHeartRateScale.axisY.visible = false
        nervous.removeSeries(nervous.requests.chemoreceptorHeartRateScale);
      }
      break;
      case "chemoreceptorHeartElastanceScale":
      if(active){
        nervous.requests.chemoreceptorHeartElastanceScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.chemoreceptorHeartElastanceScale.name, nervous.axisX, nervous.requests.chemoreceptorHeartElastanceScale.axisY);
        nervous.requests.chemoreceptorHeartElastanceScale.axisY = nervous.axisY(nervous.requests.chemoreceptorHeartElastanceScale)
        nervous.requests.chemoreceptorHeartElastanceScale.axisY.visible = true
        nervous.requests.chemoreceptorHeartElastanceScale.axisY.titleText = nervous.requests.chemoreceptorHeartElastanceScale.name
        
      } else  if  (nervous.series(nervous.requests.chemoreceptorHeartElastanceScale.name)){
        nervous.requests.chemoreceptorHeartElastanceScale.axisY.visible = false
        nervous.removeSeries(nervous.requests.chemoreceptorHeartElastanceScale);
      }
      break;
      case "painVisualAnalogueScale":
      if(active){
        nervous.requests.painVisualAnalogueScale = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.painVisualAnalogueScale.name, nervous.axisX, nervous.requests.painVisualAnalogueScale.axisY);
        nervous.requests.painVisualAnalogueScale.axisY = nervous.axisY(nervous.requests.painVisualAnalogueScale)
        nervous.requests.painVisualAnalogueScale.axisY.visible = true
        nervous.requests.painVisualAnalogueScale.axisY.titleText = nervous.requests.painVisualAnalogueScale.name
        
      } else  if  (nervous.series(nervous.requests.painVisualAnalogueScale.name)){
        nervous.requests.painVisualAnalogueScale.axisY.visible = false
        nervous.removeSeries(nervous.requests.painVisualAnalogueScale);
      }
      break;
      case "leftEyePupillaryResponse":
      if(active){
        nervous.requests.leftEyePupillaryResponse = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.leftEyePupillaryResponse.name, nervous.axisX, nervous.requests.leftEyePupillaryResponse.axisY);
        nervous.requests.leftEyePupillaryResponse.axisY = nervous.axisY(nervous.requests.leftEyePupillaryResponse)
        nervous.requests.leftEyePupillaryResponse.axisY.visible = true
        nervous.requests.leftEyePupillaryResponse.axisY.titleText = nervous.requests.leftEyePupillaryResponse.name
        
      } else  if  (nervous.series(nervous.requests.leftEyePupillaryResponse.name)){
        nervous.requests.leftEyePupillaryResponse.axisY.visible = false
        nervous.removeSeries(nervous.requests.leftEyePupillaryResponse);
      }
      break;
      case "rightEyePupillaryResponse":
      if(active){
        nervous.requests.rightEyePupillaryResponse = nervous.createSeries(ChartView.SeriesTypeLine, nervous.requests.rightEyePupillaryResponse.name, nervous.axisX, nervous.requests.rightEyePupillaryResponse.axisY);
        nervous.requests.rightEyePupillaryResponse.axisY = nervous.axisY(nervous.requests.rightEyePupillaryResponse)
        nervous.requests.rightEyePupillaryResponse.axisY.visible = true
        nervous.requests.rightEyePupillaryResponse.axisY.titleText = nervous.requests.rightEyePupillaryResponse.name
        
      } else  if  (nervous.series(nervous.requests.rightEyePupillaryResponse.name)){
        nervous.requests.rightEyePupillaryResponse.axisY.visible = false
        nervous.removeSeries(nervous.requests.rightEyePupillaryResponse);
      }
      break;
    } 
  }
  function toggleRenalSeries(request, active){
    const DEFAULT_UNIT = ""
    const DEFAULT_LABEL_FORMAT = [Qt.binding( function() { return (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e';} )]
    switch(request){
      case "glomerularFiltrationRate":
      if(active){
        renal.requests.glomerularFiltrationRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.glomerularFiltrationRate.name, renal.axisX, renal.requests.glomerularFiltrationRate.axisY);
        renal.requests.glomerularFiltrationRate.axisY = renal.axisY(renal.requests.glomerularFiltrationRate)
        renal.requests.glomerularFiltrationRate.axisY.visible = true
        renal.requests.glomerularFiltrationRate.axisY.titleText = renal.requests.glomerularFiltrationRate.name
        
      } else  if  (renal.series(renal.requests.glomerularFiltrationRate.name)){
        renal.requests.glomerularFiltrationRate.axisY.visible = false
        renal.removeSeries(renal.requests.glomerularFiltrationRate);
      }
      break;
      case "filtrationFraction":
      if(active){
        renal.requests.filtrationFraction = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.filtrationFraction.name, renal.axisX, renal.requests.filtrationFraction.axisY);
        renal.requests.filtrationFraction.axisY = renal.axisY(renal.requests.filtrationFraction)
        renal.requests.filtrationFraction.axisY.visible = true
        renal.requests.filtrationFraction.axisY.titleText = renal.requests.filtrationFraction.name
        
      } else  if  (renal.series(renal.requests.filtrationFraction.name)){
        renal.requests.filtrationFraction.axisY.visible = false
        renal.removeSeries(renal.requests.filtrationFraction);
      }
      break;
      case "leftAfferentArterioleResistance":
      if(active){
        renal.requests.leftAfferentArterioleResistance = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftAfferentArterioleResistance.name, renal.axisX, renal.requests.leftAfferentArterioleResistance.axisY);
        renal.requests.leftAfferentArterioleResistance.axisY = renal.axisY(renal.requests.leftAfferentArterioleResistance)
        renal.requests.leftAfferentArterioleResistance.axisY.visible = true
        renal.requests.leftAfferentArterioleResistance.axisY.titleText = renal.requests.leftAfferentArterioleResistance.name
        
      } else  if  (renal.series(renal.requests.leftAfferentArterioleResistance.name)){
        renal.requests.leftAfferentArterioleResistance.axisY.visible = false
        renal.removeSeries(renal.requests.leftAfferentArterioleResistance);
      }
      break;
      case "leftBowmansCapsulesHydrostaticPressure":
      if(active){
        renal.requests.leftBowmansCapsulesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftBowmansCapsulesHydrostaticPressure.name, renal.axisX, renal.requests.leftBowmansCapsulesHydrostaticPressure.axisY);
        renal.requests.leftBowmansCapsulesHydrostaticPressure.axisY = renal.axisY(renal.requests.leftBowmansCapsulesHydrostaticPressure)
        renal.requests.leftBowmansCapsulesHydrostaticPressure.axisY.visible = true
        renal.requests.leftBowmansCapsulesHydrostaticPressure.axisY.titleText = renal.requests.leftBowmansCapsulesHydrostaticPressure.name
        
      } else  if  (renal.series(renal.requests.leftBowmansCapsulesHydrostaticPressure.name)){
        renal.requests.leftBowmansCapsulesHydrostaticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.leftBowmansCapsulesHydrostaticPressure);
      }
      break;
      case "leftBowmansCapsulesOsmoticPressure":
      if(active){
        renal.requests.leftBowmansCapsulesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftBowmansCapsulesOsmoticPressure.name, renal.axisX, renal.requests.leftBowmansCapsulesOsmoticPressure.axisY);
        renal.requests.leftBowmansCapsulesOsmoticPressure.axisY = renal.axisY(renal.requests.leftBowmansCapsulesOsmoticPressure)
        renal.requests.leftBowmansCapsulesOsmoticPressure.axisY.visible = true
        renal.requests.leftBowmansCapsulesOsmoticPressure.axisY.titleText = renal.requests.leftBowmansCapsulesOsmoticPressure.name
        
      } else  if  (renal.series(renal.requests.leftBowmansCapsulesOsmoticPressure.name)){
        renal.requests.leftBowmansCapsulesOsmoticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.leftBowmansCapsulesOsmoticPressure);
      }
      break;
      case "leftEfferentArterioleResistance":
      if(active){
        renal.requests.leftEfferentArterioleResistance = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftEfferentArterioleResistance.name, renal.axisX, renal.requests.leftEfferentArterioleResistance.axisY);
        renal.requests.leftEfferentArterioleResistance.axisY = renal.axisY(renal.requests.leftEfferentArterioleResistance)
        renal.requests.leftEfferentArterioleResistance.axisY.visible = true
        renal.requests.leftEfferentArterioleResistance.axisY.titleText = renal.requests.leftEfferentArterioleResistance.name
        
      } else  if  (renal.series(renal.requests.leftEfferentArterioleResistance.name)){
        renal.requests.leftEfferentArterioleResistance.axisY.visible = false
        renal.removeSeries(renal.requests.leftEfferentArterioleResistance);
      }
      break;
      case "leftGlomerularCapillariesHydrostaticPressure":
      if(active){
        renal.requests.leftGlomerularCapillariesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularCapillariesHydrostaticPressure.name, renal.axisX, renal.requests.leftGlomerularCapillariesHydrostaticPressure.axisY);
        renal.requests.leftGlomerularCapillariesHydrostaticPressure.axisY = renal.axisY(renal.requests.leftGlomerularCapillariesHydrostaticPressure)
        renal.requests.leftGlomerularCapillariesHydrostaticPressure.axisY.visible = true
        renal.requests.leftGlomerularCapillariesHydrostaticPressure.axisY.titleText = renal.requests.leftGlomerularCapillariesHydrostaticPressure.name
        
      } else  if  (renal.series(renal.requests.leftGlomerularCapillariesHydrostaticPressure.name)){
        renal.requests.leftGlomerularCapillariesHydrostaticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.leftGlomerularCapillariesHydrostaticPressure);
      }
      break;
      case "leftGlomerularCapillariesOsmoticPressure":
      if(active){
        renal.requests.leftGlomerularCapillariesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularCapillariesOsmoticPressure.name, renal.axisX, renal.requests.leftGlomerularCapillariesOsmoticPressure.axisY);
        renal.requests.leftGlomerularCapillariesOsmoticPressure.axisY = renal.axisY(renal.requests.leftGlomerularCapillariesOsmoticPressure)
        renal.requests.leftGlomerularCapillariesOsmoticPressure.axisY.visible = true
        renal.requests.leftGlomerularCapillariesOsmoticPressure.axisY.titleText = renal.requests.leftGlomerularCapillariesOsmoticPressure.name
        
      } else  if  (renal.series(renal.requests.leftGlomerularCapillariesOsmoticPressure.name)){
        renal.requests.leftGlomerularCapillariesOsmoticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.leftGlomerularCapillariesOsmoticPressure);
      }
      break;
      case "leftGlomerularFiltrationCoefficient":
      if(active){
        renal.requests.leftGlomerularFiltrationCoefficient = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularFiltrationCoefficient.name, renal.axisX, renal.requests.leftGlomerularFiltrationCoefficient.axisY);
        renal.requests.leftGlomerularFiltrationCoefficient.axisY = renal.axisY(renal.requests.leftGlomerularFiltrationCoefficient)
        renal.requests.leftGlomerularFiltrationCoefficient.axisY.visible = true
        renal.requests.leftGlomerularFiltrationCoefficient.axisY.titleText = renal.requests.leftGlomerularFiltrationCoefficient.name
        
      } else  if  (renal.series(renal.requests.leftGlomerularFiltrationCoefficient.name)){
        renal.requests.leftGlomerularFiltrationCoefficient.axisY.visible = false
        renal.removeSeries(renal.requests.leftGlomerularFiltrationCoefficient);
      }
      break;
      case "leftGlomerularFiltrationRate":
      if(active){
        renal.requests.leftGlomerularFiltrationRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularFiltrationRate.name, renal.axisX, renal.requests.leftGlomerularFiltrationRate.axisY);
        renal.requests.leftGlomerularFiltrationRate.axisY = renal.axisY(renal.requests.leftGlomerularFiltrationRate)
        renal.requests.leftGlomerularFiltrationRate.axisY.visible = true
        renal.requests.leftGlomerularFiltrationRate.axisY.titleText = renal.requests.leftGlomerularFiltrationRate.name
        
      } else  if  (renal.series(renal.requests.leftGlomerularFiltrationRate.name)){
        renal.requests.leftGlomerularFiltrationRate.axisY.visible = false
        renal.removeSeries(renal.requests.leftGlomerularFiltrationRate);
      }
      break;
      case "leftGlomerularFiltrationSurfaceArea":
      if(active){
        renal.requests.leftGlomerularFiltrationSurfaceArea = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularFiltrationSurfaceArea.name, renal.axisX, renal.requests.leftGlomerularFiltrationSurfaceArea.axisY);
        renal.requests.leftGlomerularFiltrationSurfaceArea.axisY = renal.axisY(renal.requests.leftGlomerularFiltrationSurfaceArea)
        renal.requests.leftGlomerularFiltrationSurfaceArea.axisY.visible = true
        renal.requests.leftGlomerularFiltrationSurfaceArea.axisY.titleText = renal.requests.leftGlomerularFiltrationSurfaceArea.name
        
      } else  if  (renal.series(renal.requests.leftGlomerularFiltrationSurfaceArea.name)){
        renal.requests.leftGlomerularFiltrationSurfaceArea.axisY.visible = false
        renal.removeSeries(renal.requests.leftGlomerularFiltrationSurfaceArea);
      }
      break;
      case "leftGlomerularFluidPermeability":
      if(active){
        renal.requests.leftGlomerularFluidPermeability = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftGlomerularFluidPermeability.name, renal.axisX, renal.requests.leftGlomerularFluidPermeability.axisY);
        renal.requests.leftGlomerularFluidPermeability.axisY = renal.axisY(renal.requests.leftGlomerularFluidPermeability)
        renal.requests.leftGlomerularFluidPermeability.axisY.visible = true
        renal.requests.leftGlomerularFluidPermeability.axisY.titleText = renal.requests.leftGlomerularFluidPermeability.name
        
      } else  if  (renal.series(renal.requests.leftGlomerularFluidPermeability.name)){
        renal.requests.leftGlomerularFluidPermeability.axisY.visible = false
        renal.removeSeries(renal.requests.leftGlomerularFluidPermeability);
      }
      break;
      case "leftFiltrationFraction":
      if(active){
        renal.requests.leftFiltrationFraction = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftFiltrationFraction.name, renal.axisX, renal.requests.leftFiltrationFraction.axisY);
        renal.requests.leftFiltrationFraction.axisY = renal.axisY(renal.requests.leftFiltrationFraction)
        renal.requests.leftFiltrationFraction.axisY.visible = true
        renal.requests.leftFiltrationFraction.axisY.titleText = renal.requests.leftFiltrationFraction.name
        
      } else  if  (renal.series(renal.requests.leftFiltrationFraction.name)){
        renal.requests.leftFiltrationFraction.axisY.visible = false
        renal.removeSeries(renal.requests.leftFiltrationFraction);
      }
      break;
      case "leftNetFiltrationPressure":
      if(active){
        renal.requests.leftNetFiltrationPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftNetFiltrationPressure.name, renal.axisX, renal.requests.leftNetFiltrationPressure.axisY);
        renal.requests.leftNetFiltrationPressure.axisY = renal.axisY(renal.requests.leftNetFiltrationPressure)
        renal.requests.leftNetFiltrationPressure.axisY.visible = true
        renal.requests.leftNetFiltrationPressure.axisY.titleText = renal.requests.leftNetFiltrationPressure.name
        
      } else  if  (renal.series(renal.requests.leftNetFiltrationPressure.name)){
        renal.requests.leftNetFiltrationPressure.axisY.visible = false
        renal.removeSeries(renal.requests.leftNetFiltrationPressure);
      }
      break;
      case "leftNetReabsorptionPressure":
      if(active){
        renal.requests.leftNetReabsorptionPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftNetReabsorptionPressure.name, renal.axisX, renal.requests.leftNetReabsorptionPressure.axisY);
        renal.requests.leftNetReabsorptionPressure.axisY = renal.axisY(renal.requests.leftNetReabsorptionPressure)
        renal.requests.leftNetReabsorptionPressure.axisY.visible = true
        renal.requests.leftNetReabsorptionPressure.axisY.titleText = renal.requests.leftNetReabsorptionPressure.name
        
      } else  if  (renal.series(renal.requests.leftNetReabsorptionPressure.name)){
        renal.requests.leftNetReabsorptionPressure.axisY.visible = false
        renal.removeSeries(renal.requests.leftNetReabsorptionPressure);
      }
      break;
      case "leftPeritubularCapillariesHydrostaticPressure":
      if(active){
        renal.requests.leftPeritubularCapillariesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftPeritubularCapillariesHydrostaticPressure.name, renal.axisX, renal.requests.leftPeritubularCapillariesHydrostaticPressure.axisY);
        renal.requests.leftPeritubularCapillariesHydrostaticPressure.axisY = renal.axisY(renal.requests.leftPeritubularCapillariesHydrostaticPressure)
        renal.requests.leftPeritubularCapillariesHydrostaticPressure.axisY.visible = true
        renal.requests.leftPeritubularCapillariesHydrostaticPressure.axisY.titleText = renal.requests.leftPeritubularCapillariesHydrostaticPressure.name
        
      } else  if  (renal.series(renal.requests.leftPeritubularCapillariesHydrostaticPressure.name)){
        renal.requests.leftPeritubularCapillariesHydrostaticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.leftPeritubularCapillariesHydrostaticPressure);
      }
      break;
      case "leftPeritubularCapillariesOsmoticPressure":
      if(active){
        renal.requests.leftPeritubularCapillariesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftPeritubularCapillariesOsmoticPressure.name, renal.axisX, renal.requests.leftPeritubularCapillariesOsmoticPressure.axisY);
        renal.requests.leftPeritubularCapillariesOsmoticPressure.axisY = renal.axisY(renal.requests.leftPeritubularCapillariesOsmoticPressure)
        renal.requests.leftPeritubularCapillariesOsmoticPressure.axisY.visible = true
        renal.requests.leftPeritubularCapillariesOsmoticPressure.axisY.titleText = renal.requests.leftPeritubularCapillariesOsmoticPressure.name
        
      } else  if  (renal.series(renal.requests.leftPeritubularCapillariesOsmoticPressure.name)){
        renal.requests.leftPeritubularCapillariesOsmoticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.leftPeritubularCapillariesOsmoticPressure);
      }
      break;
      case "leftReabsorptionFiltrationCoefficient":
      if(active){
        renal.requests.leftReabsorptionFiltrationCoefficient = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftReabsorptionFiltrationCoefficient.name, renal.axisX, renal.requests.leftReabsorptionFiltrationCoefficient.axisY);
        renal.requests.leftReabsorptionFiltrationCoefficient.axisY = renal.axisY(renal.requests.leftReabsorptionFiltrationCoefficient)
        renal.requests.leftReabsorptionFiltrationCoefficient.axisY.visible = true
        renal.requests.leftReabsorptionFiltrationCoefficient.axisY.titleText = renal.requests.leftReabsorptionFiltrationCoefficient.name
        
      } else  if  (renal.series(renal.requests.leftReabsorptionFiltrationCoefficient.name)){
        renal.requests.leftReabsorptionFiltrationCoefficient.axisY.visible = false
        renal.removeSeries(renal.requests.leftReabsorptionFiltrationCoefficient);
      }
      break;
      case "leftReabsorptionRate":
      if(active){
        renal.requests.leftReabsorptionRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftReabsorptionRate.name, renal.axisX, renal.requests.leftReabsorptionRate.axisY);
        renal.requests.leftReabsorptionRate.axisY = renal.axisY(renal.requests.leftReabsorptionRate)
        renal.requests.leftReabsorptionRate.axisY.visible = true
        renal.requests.leftReabsorptionRate.axisY.titleText = renal.requests.leftReabsorptionRate.name
        
      } else  if  (renal.series(renal.requests.leftReabsorptionRate.name)){
        renal.requests.leftReabsorptionRate.axisY.visible = false
        renal.removeSeries(renal.requests.leftReabsorptionRate);
      }
      break;
      case "leftTubularReabsorptionFiltrationSurfaceArea":
      if(active){
        renal.requests.leftTubularReabsorptionFiltrationSurfaceArea = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.name, renal.axisX, renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.axisY);
        renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.axisY = renal.axisY(renal.requests.leftTubularReabsorptionFiltrationSurfaceArea)
        renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.axisY.visible = true
        renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.axisY.titleText = renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.name
        
      } else  if  (renal.series(renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.name)){
        renal.requests.leftTubularReabsorptionFiltrationSurfaceArea.axisY.visible = false
        renal.removeSeries(renal.requests.leftTubularReabsorptionFiltrationSurfaceArea);
      }
      break;
      case "leftTubularReabsorptionFluidPermeability":
      if(active){
        renal.requests.leftTubularReabsorptionFluidPermeability = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftTubularReabsorptionFluidPermeability.name, renal.axisX, renal.requests.leftTubularReabsorptionFluidPermeability.axisY);
        renal.requests.leftTubularReabsorptionFluidPermeability.axisY = renal.axisY(renal.requests.leftTubularReabsorptionFluidPermeability)
        renal.requests.leftTubularReabsorptionFluidPermeability.axisY.visible = true
        renal.requests.leftTubularReabsorptionFluidPermeability.axisY.titleText = renal.requests.leftTubularReabsorptionFluidPermeability.name
        
      } else  if  (renal.series(renal.requests.leftTubularReabsorptionFluidPermeability.name)){
        renal.requests.leftTubularReabsorptionFluidPermeability.axisY.visible = false
        renal.removeSeries(renal.requests.leftTubularReabsorptionFluidPermeability);
      }
      break;
      case "leftTubularHydrostaticPressure":
      if(active){
        renal.requests.leftTubularHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftTubularHydrostaticPressure.name, renal.axisX, renal.requests.leftTubularHydrostaticPressure.axisY);
        renal.requests.leftTubularHydrostaticPressure.axisY = renal.axisY(renal.requests.leftTubularHydrostaticPressure)
        renal.requests.leftTubularHydrostaticPressure.axisY.visible = true
        renal.requests.leftTubularHydrostaticPressure.axisY.titleText = renal.requests.leftTubularHydrostaticPressure.name
        
      } else  if  (renal.series(renal.requests.leftTubularHydrostaticPressure.name)){
        renal.requests.leftTubularHydrostaticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.leftTubularHydrostaticPressure);
      }
      break;
      case "leftTubularOsmoticPressure":
      if(active){
        renal.requests.leftTubularOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.leftTubularOsmoticPressure.name, renal.axisX, renal.requests.leftTubularOsmoticPressure.axisY);
        renal.requests.leftTubularOsmoticPressure.axisY = renal.axisY(renal.requests.leftTubularOsmoticPressure)
        renal.requests.leftTubularOsmoticPressure.axisY.visible = true
        renal.requests.leftTubularOsmoticPressure.axisY.titleText = renal.requests.leftTubularOsmoticPressure.name
        
      } else  if  (renal.series(renal.requests.leftTubularOsmoticPressure.name)){
        renal.requests.leftTubularOsmoticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.leftTubularOsmoticPressure);
      }
      break;
      case "renalBloodFlow":
      if(active){
        renal.requests.renalBloodFlow = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.renalBloodFlow.name, renal.axisX, renal.requests.renalBloodFlow.axisY);
        renal.requests.renalBloodFlow.axisY = renal.axisY(renal.requests.renalBloodFlow)
        renal.requests.renalBloodFlow.axisY.visible = true
        renal.requests.renalBloodFlow.axisY.titleText = renal.requests.renalBloodFlow.name
        
      } else  if  (renal.series(renal.requests.renalBloodFlow.name)){
        renal.requests.renalBloodFlow.axisY.visible = false
        renal.removeSeries(renal.requests.renalBloodFlow);
      }
      break;
      case "renalPlasmaFlow":
      if(active){
        renal.requests.renalPlasmaFlow = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.renalPlasmaFlow.name, renal.axisX, renal.requests.renalPlasmaFlow.axisY);
        renal.requests.renalPlasmaFlow.axisY = renal.axisY(renal.requests.renalPlasmaFlow)
        renal.requests.renalPlasmaFlow.axisY.visible = true
        renal.requests.renalPlasmaFlow.axisY.titleText = renal.requests.renalPlasmaFlow.name
        
      } else  if  (renal.series(renal.requests.renalPlasmaFlow.name)){
        renal.requests.renalPlasmaFlow.axisY.visible = false
        renal.removeSeries(renal.requests.renalPlasmaFlow);
      }
      break;
      case "renalVascularResistance":
      if(active){
        renal.requests.renalVascularResistance = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.renalVascularResistance.name, renal.axisX, renal.requests.renalVascularResistance.axisY);
        renal.requests.renalVascularResistance.axisY = renal.axisY(renal.requests.renalVascularResistance)
        renal.requests.renalVascularResistance.axisY.visible = true
        renal.requests.renalVascularResistance.axisY.titleText = renal.requests.renalVascularResistance.name
        
      } else  if  (renal.series(renal.requests.renalVascularResistance.name)){
        renal.requests.renalVascularResistance.axisY.visible = false
        renal.removeSeries(renal.requests.renalVascularResistance);
      }
      break;
      case "rightAfferentArterioleResistance":
      if(active){
        renal.requests.rightAfferentArterioleResistance = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightAfferentArterioleResistance.name, renal.axisX, renal.requests.rightAfferentArterioleResistance.axisY);
        renal.requests.rightAfferentArterioleResistance.axisY = renal.axisY(renal.requests.rightAfferentArterioleResistance)
        renal.requests.rightAfferentArterioleResistance.axisY.visible = true
        renal.requests.rightAfferentArterioleResistance.axisY.titleText = renal.requests.rightAfferentArterioleResistance.name
        
      } else  if  (renal.series(renal.requests.rightAfferentArterioleResistance.name)){
        renal.requests.rightAfferentArterioleResistance.axisY.visible = false
        renal.removeSeries(renal.requests.rightAfferentArterioleResistance);
      }
      break;
      case "rightBowmansCapsulesHydrostaticPressure":
      if(active){
        renal.requests.rightBowmansCapsulesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightBowmansCapsulesHydrostaticPressure.name, renal.axisX, renal.requests.rightBowmansCapsulesHydrostaticPressure.axisY);
        renal.requests.rightBowmansCapsulesHydrostaticPressure.axisY = renal.axisY(renal.requests.rightBowmansCapsulesHydrostaticPressure)
        renal.requests.rightBowmansCapsulesHydrostaticPressure.axisY.visible = true
        renal.requests.rightBowmansCapsulesHydrostaticPressure.axisY.titleText = renal.requests.rightBowmansCapsulesHydrostaticPressure.name
        
      } else  if  (renal.series(renal.requests.rightBowmansCapsulesHydrostaticPressure.name)){
        renal.requests.rightBowmansCapsulesHydrostaticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.rightBowmansCapsulesHydrostaticPressure);
      }
      break;
      case "rightBowmansCapsulesOsmoticPressure":
      if(active){
        renal.requests.rightBowmansCapsulesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightBowmansCapsulesOsmoticPressure.name, renal.axisX, renal.requests.rightBowmansCapsulesOsmoticPressure.axisY);
        renal.requests.rightBowmansCapsulesOsmoticPressure.axisY = renal.axisY(renal.requests.rightBowmansCapsulesOsmoticPressure)
        renal.requests.rightBowmansCapsulesOsmoticPressure.axisY.visible = true
        renal.requests.rightBowmansCapsulesOsmoticPressure.axisY.titleText = renal.requests.rightBowmansCapsulesOsmoticPressure.name
        
      } else  if  (renal.series(renal.requests.rightBowmansCapsulesOsmoticPressure.name)){
        renal.requests.rightBowmansCapsulesOsmoticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.rightBowmansCapsulesOsmoticPressure);
      }
      break;
      case "rightEfferentArterioleResistance":
      if(active){
        renal.requests.rightEfferentArterioleResistance = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightEfferentArterioleResistance.name, renal.axisX, renal.requests.rightEfferentArterioleResistance.axisY);
        renal.requests.rightEfferentArterioleResistance.axisY = renal.axisY(renal.requests.rightEfferentArterioleResistance)
        renal.requests.rightEfferentArterioleResistance.axisY.visible = true
        renal.requests.rightEfferentArterioleResistance.axisY.titleText = renal.requests.rightEfferentArterioleResistance.name
        
      } else  if  (renal.series(renal.requests.rightEfferentArterioleResistance.name)){
        renal.requests.rightEfferentArterioleResistance.axisY.visible = false
        renal.removeSeries(renal.requests.rightEfferentArterioleResistance);
      }
      break;
      case "rightGlomerularCapillariesHydrostaticPressure":
      if(active){
        renal.requests.rightGlomerularCapillariesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularCapillariesHydrostaticPressure.name, renal.axisX, renal.requests.rightGlomerularCapillariesHydrostaticPressure.axisY);
        renal.requests.rightGlomerularCapillariesHydrostaticPressure.axisY = renal.axisY(renal.requests.rightGlomerularCapillariesHydrostaticPressure)
        renal.requests.rightGlomerularCapillariesHydrostaticPressure.axisY.visible = true
        renal.requests.rightGlomerularCapillariesHydrostaticPressure.axisY.titleText = renal.requests.rightGlomerularCapillariesHydrostaticPressure.name
        
      } else  if  (renal.series(renal.requests.rightGlomerularCapillariesHydrostaticPressure.name)){
        renal.requests.rightGlomerularCapillariesHydrostaticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.rightGlomerularCapillariesHydrostaticPressure);
      }
      break;
      case "rightGlomerularCapillariesOsmoticPressure":
      if(active){
        renal.requests.rightGlomerularCapillariesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularCapillariesOsmoticPressure.name, renal.axisX, renal.requests.rightGlomerularCapillariesOsmoticPressure.axisY);
        renal.requests.rightGlomerularCapillariesOsmoticPressure.axisY = renal.axisY(renal.requests.rightGlomerularCapillariesOsmoticPressure)
        renal.requests.rightGlomerularCapillariesOsmoticPressure.axisY.visible = true
        renal.requests.rightGlomerularCapillariesOsmoticPressure.axisY.titleText = renal.requests.rightGlomerularCapillariesOsmoticPressure.name
        
      } else  if  (renal.series(renal.requests.rightGlomerularCapillariesOsmoticPressure.name)){
        renal.requests.rightGlomerularCapillariesOsmoticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.rightGlomerularCapillariesOsmoticPressure);
      }
      break;
      case "rightGlomerularFiltrationCoefficient":
      if(active){
        renal.requests.rightGlomerularFiltrationCoefficient = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularFiltrationCoefficient.name, renal.axisX, renal.requests.rightGlomerularFiltrationCoefficient.axisY);
        renal.requests.rightGlomerularFiltrationCoefficient.axisY = renal.axisY(renal.requests.rightGlomerularFiltrationCoefficient)
        renal.requests.rightGlomerularFiltrationCoefficient.axisY.visible = true
        renal.requests.rightGlomerularFiltrationCoefficient.axisY.titleText = renal.requests.rightGlomerularFiltrationCoefficient.name
        
      } else  if  (renal.series(renal.requests.rightGlomerularFiltrationCoefficient.name)){
        renal.requests.rightGlomerularFiltrationCoefficient.axisY.visible = false
        renal.removeSeries(renal.requests.rightGlomerularFiltrationCoefficient);
      }
      break;
      case "rightGlomerularFiltrationRate":
      if(active){
        renal.requests.rightGlomerularFiltrationRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularFiltrationRate.name, renal.axisX, renal.requests.rightGlomerularFiltrationRate.axisY);
        renal.requests.rightGlomerularFiltrationRate.axisY = renal.axisY(renal.requests.rightGlomerularFiltrationRate)
        renal.requests.rightGlomerularFiltrationRate.axisY.visible = true
        renal.requests.rightGlomerularFiltrationRate.axisY.titleText = renal.requests.rightGlomerularFiltrationRate.name
        
      } else  if  (renal.series(renal.requests.rightGlomerularFiltrationRate.name)){
        renal.requests.rightGlomerularFiltrationRate.axisY.visible = false
        renal.removeSeries(renal.requests.rightGlomerularFiltrationRate);
      }
      break;
      case "rightGlomerularFiltrationSurfaceArea":
      if(active){
        renal.requests.rightGlomerularFiltrationSurfaceArea = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularFiltrationSurfaceArea.name, renal.axisX, renal.requests.rightGlomerularFiltrationSurfaceArea.axisY);
        renal.requests.rightGlomerularFiltrationSurfaceArea.axisY = renal.axisY(renal.requests.rightGlomerularFiltrationSurfaceArea)
        renal.requests.rightGlomerularFiltrationSurfaceArea.axisY.visible = true
        renal.requests.rightGlomerularFiltrationSurfaceArea.axisY.titleText = renal.requests.rightGlomerularFiltrationSurfaceArea.name
        
      } else  if  (renal.series(renal.requests.rightGlomerularFiltrationSurfaceArea.name)){
        renal.requests.rightGlomerularFiltrationSurfaceArea.axisY.visible = false
        renal.removeSeries(renal.requests.rightGlomerularFiltrationSurfaceArea);
      }
      break;
      case "rightGlomerularFluidPermeability":
      if(active){
        renal.requests.rightGlomerularFluidPermeability = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightGlomerularFluidPermeability.name, renal.axisX, renal.requests.rightGlomerularFluidPermeability.axisY);
        renal.requests.rightGlomerularFluidPermeability.axisY = renal.axisY(renal.requests.rightGlomerularFluidPermeability)
        renal.requests.rightGlomerularFluidPermeability.axisY.visible = true
        renal.requests.rightGlomerularFluidPermeability.axisY.titleText = renal.requests.rightGlomerularFluidPermeability.name
        
      } else  if  (renal.series(renal.requests.rightGlomerularFluidPermeability.name)){
        renal.requests.rightGlomerularFluidPermeability.axisY.visible = false
        renal.removeSeries(renal.requests.rightGlomerularFluidPermeability);
      }
      break;
      case "rightFiltrationFraction":
      if(active){
        renal.requests.rightFiltrationFraction = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightFiltrationFraction.name, renal.axisX, renal.requests.rightFiltrationFraction.axisY);
        renal.requests.rightFiltrationFraction.axisY = renal.axisY(renal.requests.rightFiltrationFraction)
        renal.requests.rightFiltrationFraction.axisY.visible = true
        renal.requests.rightFiltrationFraction.axisY.titleText = renal.requests.rightFiltrationFraction.name
        
      } else  if  (renal.series(renal.requests.rightFiltrationFraction.name)){
        renal.requests.rightFiltrationFraction.axisY.visible = false
        renal.removeSeries(renal.requests.rightFiltrationFraction);
      }
      break;
      case "rightNetFiltrationPressure":
      if(active){
        renal.requests.rightNetFiltrationPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightNetFiltrationPressure.name, renal.axisX, renal.requests.rightNetFiltrationPressure.axisY);
        renal.requests.rightNetFiltrationPressure.axisY = renal.axisY(renal.requests.rightNetFiltrationPressure)
        renal.requests.rightNetFiltrationPressure.axisY.visible = true
        renal.requests.rightNetFiltrationPressure.axisY.titleText = renal.requests.rightNetFiltrationPressure.name
        
      } else  if  (renal.series(renal.requests.rightNetFiltrationPressure.name)){
        renal.requests.rightNetFiltrationPressure.axisY.visible = false
        renal.removeSeries(renal.requests.rightNetFiltrationPressure);
      }
      break;
      case "rightNetReabsorptionPressure":
      if(active){
        renal.requests.rightNetReabsorptionPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightNetReabsorptionPressure.name, renal.axisX, renal.requests.rightNetReabsorptionPressure.axisY);
        renal.requests.rightNetReabsorptionPressure.axisY = renal.axisY(renal.requests.rightNetReabsorptionPressure)
        renal.requests.rightNetReabsorptionPressure.axisY.visible = true
        renal.requests.rightNetReabsorptionPressure.axisY.titleText = renal.requests.rightNetReabsorptionPressure.name
        
      } else  if  (renal.series(renal.requests.rightNetReabsorptionPressure.name)){
        renal.requests.rightNetReabsorptionPressure.axisY.visible = false
        renal.removeSeries(renal.requests.rightNetReabsorptionPressure);
      }
      break;
      case "rightPeritubularCapillariesHydrostaticPressure":
      if(active){
        renal.requests.rightPeritubularCapillariesHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightPeritubularCapillariesHydrostaticPressure.name, renal.axisX, renal.requests.rightPeritubularCapillariesHydrostaticPressure.axisY);
        renal.requests.rightPeritubularCapillariesHydrostaticPressure.axisY = renal.axisY(renal.requests.rightPeritubularCapillariesHydrostaticPressure)
        renal.requests.rightPeritubularCapillariesHydrostaticPressure.axisY.visible = true
        renal.requests.rightPeritubularCapillariesHydrostaticPressure.axisY.titleText = renal.requests.rightPeritubularCapillariesHydrostaticPressure.name
        
      } else  if  (renal.series(renal.requests.rightPeritubularCapillariesHydrostaticPressure.name)){
        renal.requests.rightPeritubularCapillariesHydrostaticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.rightPeritubularCapillariesHydrostaticPressure);
      }
      break;
      case "rightPeritubularCapillariesOsmoticPressure":
      if(active){
        renal.requests.rightPeritubularCapillariesOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightPeritubularCapillariesOsmoticPressure.name, renal.axisX, renal.requests.rightPeritubularCapillariesOsmoticPressure.axisY);
        renal.requests.rightPeritubularCapillariesOsmoticPressure.axisY = renal.axisY(renal.requests.rightPeritubularCapillariesOsmoticPressure)
        renal.requests.rightPeritubularCapillariesOsmoticPressure.axisY.visible = true
        renal.requests.rightPeritubularCapillariesOsmoticPressure.axisY.titleText = renal.requests.rightPeritubularCapillariesOsmoticPressure.name
        
      } else  if  (renal.series(renal.requests.rightPeritubularCapillariesOsmoticPressure.name)){
        renal.requests.rightPeritubularCapillariesOsmoticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.rightPeritubularCapillariesOsmoticPressure);
      }
      break;
      case "rightReabsorptionFiltrationCoefficient":
      if(active){
        renal.requests.rightReabsorptionFiltrationCoefficient = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightReabsorptionFiltrationCoefficient.name, renal.axisX, renal.requests.rightReabsorptionFiltrationCoefficient.axisY);
        renal.requests.rightReabsorptionFiltrationCoefficient.axisY = renal.axisY(renal.requests.rightReabsorptionFiltrationCoefficient)
        renal.requests.rightReabsorptionFiltrationCoefficient.axisY.visible = true
        renal.requests.rightReabsorptionFiltrationCoefficient.axisY.titleText = renal.requests.rightReabsorptionFiltrationCoefficient.name
        
      } else  if  (renal.series(renal.requests.rightReabsorptionFiltrationCoefficient.name)){
        renal.requests.rightReabsorptionFiltrationCoefficient.axisY.visible = false
        renal.removeSeries(renal.requests.rightReabsorptionFiltrationCoefficient);
      }
      break;
      case "rightReabsorptionRate":
      if(active){
        renal.requests.rightReabsorptionRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightReabsorptionRate.name, renal.axisX, renal.requests.rightReabsorptionRate.axisY);
        renal.requests.rightReabsorptionRate.axisY = renal.axisY(renal.requests.rightReabsorptionRate)
        renal.requests.rightReabsorptionRate.axisY.visible = true
        renal.requests.rightReabsorptionRate.axisY.titleText = renal.requests.rightReabsorptionRate.name
        
      } else  if  (renal.series(renal.requests.rightReabsorptionRate.name)){
        renal.requests.rightReabsorptionRate.axisY.visible = false
        renal.removeSeries(renal.requests.rightReabsorptionRate);
      }
      break;
      case "rightTubularReabsorptionFiltrationSurfaceArea":
      if(active){
        renal.requests.rightTubularReabsorptionFiltrationSurfaceArea = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.name, renal.axisX, renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.axisY);
        renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.axisY = renal.axisY(renal.requests.rightTubularReabsorptionFiltrationSurfaceArea)
        renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.axisY.visible = true
        renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.axisY.titleText = renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.name
        
      } else  if  (renal.series(renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.name)){
        renal.requests.rightTubularReabsorptionFiltrationSurfaceArea.axisY.visible = false
        renal.removeSeries(renal.requests.rightTubularReabsorptionFiltrationSurfaceArea);
      }
      break;
      case "rightTubularReabsorptionFluidPermeability":
      if(active){
        renal.requests.rightTubularReabsorptionFluidPermeability = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightTubularReabsorptionFluidPermeability.name, renal.axisX, renal.requests.rightTubularReabsorptionFluidPermeability.axisY);
        renal.requests.rightTubularReabsorptionFluidPermeability.axisY = renal.axisY(renal.requests.rightTubularReabsorptionFluidPermeability)
        renal.requests.rightTubularReabsorptionFluidPermeability.axisY.visible = true
        renal.requests.rightTubularReabsorptionFluidPermeability.axisY.titleText = renal.requests.rightTubularReabsorptionFluidPermeability.name
        
      } else  if  (renal.series(renal.requests.rightTubularReabsorptionFluidPermeability.name)){
        renal.requests.rightTubularReabsorptionFluidPermeability.axisY.visible = false
        renal.removeSeries(renal.requests.rightTubularReabsorptionFluidPermeability);
      }
      break;
      case "rightTubularHydrostaticPressure":
      if(active){
        renal.requests.rightTubularHydrostaticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightTubularHydrostaticPressure.name, renal.axisX, renal.requests.rightTubularHydrostaticPressure.axisY);
        renal.requests.rightTubularHydrostaticPressure.axisY = renal.axisY(renal.requests.rightTubularHydrostaticPressure)
        renal.requests.rightTubularHydrostaticPressure.axisY.visible = true
        renal.requests.rightTubularHydrostaticPressure.axisY.titleText = renal.requests.rightTubularHydrostaticPressure.name
        
      } else  if  (renal.series(renal.requests.rightTubularHydrostaticPressure.name)){
        renal.requests.rightTubularHydrostaticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.rightTubularHydrostaticPressure);
      }
      break;
      case "rightTubularOsmoticPressure":
      if(active){
        renal.requests.rightTubularOsmoticPressure = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.rightTubularOsmoticPressure.name, renal.axisX, renal.requests.rightTubularOsmoticPressure.axisY);
        renal.requests.rightTubularOsmoticPressure.axisY = renal.axisY(renal.requests.rightTubularOsmoticPressure)
        renal.requests.rightTubularOsmoticPressure.axisY.visible = true
        renal.requests.rightTubularOsmoticPressure.axisY.titleText = renal.requests.rightTubularOsmoticPressure.name
        
      } else  if  (renal.series(renal.requests.rightTubularOsmoticPressure.name)){
        renal.requests.rightTubularOsmoticPressure.axisY.visible = false
        renal.removeSeries(renal.requests.rightTubularOsmoticPressure);
      }
      break;
      case "urinationRate":
      if(active){
        renal.requests.urinationRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urinationRate.name, renal.axisX, renal.requests.urinationRate.axisY);
        renal.requests.urinationRate.axisY = renal.axisY(renal.requests.urinationRate)
        renal.requests.urinationRate.axisY.visible = true
        renal.requests.urinationRate.axisY.titleText = renal.requests.urinationRate.name
        
      } else  if  (renal.series(renal.requests.urinationRate.name)){
        renal.requests.urinationRate.axisY.visible = false
        renal.removeSeries(renal.requests.urinationRate);
      }
      break;
      case "urineOsmolality":
      if(active){
        renal.requests.urineOsmolality = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineOsmolality.name, renal.axisX, renal.requests.urineOsmolality.axisY);
        renal.requests.urineOsmolality.axisY = renal.axisY(renal.requests.urineOsmolality)
        renal.requests.urineOsmolality.axisY.visible = true
        renal.requests.urineOsmolality.axisY.titleText = renal.requests.urineOsmolality.name
        
      } else  if  (renal.series(renal.requests.urineOsmolality.name)){
        renal.requests.urineOsmolality.axisY.visible = false
        renal.removeSeries(renal.requests.urineOsmolality);
      }
      break;
      case "urineOsmolarity":
      if(active){
        renal.requests.urineOsmolarity = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineOsmolarity.name, renal.axisX, renal.requests.urineOsmolarity.axisY);
        renal.requests.urineOsmolarity.axisY = renal.axisY(renal.requests.urineOsmolarity)
        renal.requests.urineOsmolarity.axisY.visible = true
        renal.requests.urineOsmolarity.axisY.titleText = renal.requests.urineOsmolarity.name
        
      } else  if  (renal.series(renal.requests.urineOsmolarity.name)){
        renal.requests.urineOsmolarity.axisY.visible = false
        renal.removeSeries(renal.requests.urineOsmolarity);
      }
      break;
      case "urineProductionRate":
      if(active){
        renal.requests.urineProductionRate = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineProductionRate.name, renal.axisX, renal.requests.urineProductionRate.axisY);
        renal.requests.urineProductionRate.axisY = renal.axisY(renal.requests.urineProductionRate)
        renal.requests.urineProductionRate.axisY.visible = true
        renal.requests.urineProductionRate.axisY.titleText = renal.requests.urineProductionRate.name
        
      } else  if  (renal.series(renal.requests.urineProductionRate.name)){
        renal.requests.urineProductionRate.axisY.visible = false
        renal.removeSeries(renal.requests.urineProductionRate);
      }
      break;
      case "meanUrineOutput":
      if(active){
        renal.requests.meanUrineOutput = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.meanUrineOutput.name, renal.axisX, renal.requests.meanUrineOutput.axisY);
        renal.requests.meanUrineOutput.axisY = renal.axisY(renal.requests.meanUrineOutput)
        renal.requests.meanUrineOutput.axisY.visible = true
        renal.requests.meanUrineOutput.axisY.titleText = renal.requests.meanUrineOutput.name
        
      } else  if  (renal.series(renal.requests.meanUrineOutput.name)){
        renal.requests.meanUrineOutput.axisY.visible = false
        renal.removeSeries(renal.requests.meanUrineOutput);
      }
      break;
      case "urineSpecificGravity":
      if(active){
        renal.requests.urineSpecificGravity = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineSpecificGravity.name, renal.axisX, renal.requests.urineSpecificGravity.axisY);
        renal.requests.urineSpecificGravity.axisY = renal.axisY(renal.requests.urineSpecificGravity)
        renal.requests.urineSpecificGravity.axisY.visible = true
        renal.requests.urineSpecificGravity.axisY.titleText = renal.requests.urineSpecificGravity.name
        
      } else  if  (renal.series(renal.requests.urineSpecificGravity.name)){
        renal.requests.urineSpecificGravity.axisY.visible = false
        renal.removeSeries(renal.requests.urineSpecificGravity);
      }
      break;
      case "urineVolume":
      if(active){
        renal.requests.urineVolume = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineVolume.name, renal.axisX, renal.requests.urineVolume.axisY);
        renal.requests.urineVolume.axisY = renal.axisY(renal.requests.urineVolume)
        renal.requests.urineVolume.axisY.visible = true
        renal.requests.urineVolume.axisY.titleText = renal.requests.urineVolume.name
        
      } else  if  (renal.series(renal.requests.urineVolume.name)){
        renal.requests.urineVolume.axisY.visible = false
        renal.removeSeries(renal.requests.urineVolume);
      }
      break;
      case "urineUreaNitrogenConcentration":
      if(active){
        renal.requests.urineUreaNitrogenConcentration = renal.createSeries(ChartView.SeriesTypeLine, renal.requests.urineUreaNitrogenConcentration.name, renal.axisX, renal.requests.urineUreaNitrogenConcentration.axisY);
        renal.requests.urineUreaNitrogenConcentration.axisY = renal.axisY(renal.requests.urineUreaNitrogenConcentration)
        renal.requests.urineUreaNitrogenConcentration.axisY.visible = true
        renal.requests.urineUreaNitrogenConcentration.axisY.titleText = renal.requests.urineUreaNitrogenConcentration.name
        
      } else  if  (renal.series(renal.requests.urineUreaNitrogenConcentration.name)){
        renal.requests.urineUreaNitrogenConcentration.axisY.visible = false
        renal.removeSeries(renal.requests.urineUreaNitrogenConcentration);
      }
      break;
    }
  }
  function toggleRespiratorySeries(request, active){
    const DEFAULT_UNIT = ""
    const DEFAULT_LABEL_FORMAT = [Qt.binding( function() { return (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e';} )]
    switch(request){
      case "alveolarArterialGradient":
      if(active){
        respiratory.requests.alveolarArterialGradient = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.alveolarArterialGradient.name, respiratory.axisX, respiratory.requests.alveolarArterialGradient.axisY);
        respiratory.requests.alveolarArterialGradient.axisY = respiratory.axisY(respiratory.requests.alveolarArterialGradient)
        respiratory.requests.alveolarArterialGradient.axisY.visible = true
        respiratory.requests.alveolarArterialGradient.axisY.titleText = respiratory.requests.alveolarArterialGradient.name
        
      } else  if  (respiratory.series(respiratory.requests.alveolarArterialGradient.name)){
        respiratory.requests.alveolarArterialGradient.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.alveolarArterialGradient);
      }
      break;
      case "carricoIndex":
      if(active){
        respiratory.requests.carricoIndex = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.carricoIndex.name, respiratory.axisX, respiratory.requests.carricoIndex.axisY);
        respiratory.requests.carricoIndex.axisY = respiratory.axisY(respiratory.requests.carricoIndex)
        respiratory.requests.carricoIndex.axisY.visible = true
        respiratory.requests.carricoIndex.axisY.titleText = respiratory.requests.carricoIndex.name
        
      } else  if  (respiratory.series(respiratory.requests.carricoIndex.name)){
        respiratory.requests.carricoIndex.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.carricoIndex);
      }
      break;
      case "endTidalCarbonDioxideFraction":
      if(active){
        respiratory.requests.endTidalCarbonDioxideFraction = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.endTidalCarbonDioxideFraction.name, respiratory.axisX, respiratory.requests.endTidalCarbonDioxideFraction.axisY);
        respiratory.requests.endTidalCarbonDioxideFraction.axisY = respiratory.axisY(respiratory.requests.endTidalCarbonDioxideFraction)
        respiratory.requests.endTidalCarbonDioxideFraction.axisY.visible = true
        respiratory.requests.endTidalCarbonDioxideFraction.axisY.titleText = respiratory.requests.endTidalCarbonDioxideFraction.name
        
      } else  if  (respiratory.series(respiratory.requests.endTidalCarbonDioxideFraction.name)){
        respiratory.requests.endTidalCarbonDioxideFraction.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.endTidalCarbonDioxideFraction);
      }
      break;
      case "endTidalCarbonDioxidePressure":
      if(active){
        respiratory.requests.endTidalCarbonDioxidePressure = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.endTidalCarbonDioxidePressure.name, respiratory.axisX, respiratory.requests.endTidalCarbonDioxidePressure.axisY);
        respiratory.requests.endTidalCarbonDioxidePressure.axisY = respiratory.axisY(respiratory.requests.endTidalCarbonDioxidePressure)
        respiratory.requests.endTidalCarbonDioxidePressure.axisY.visible = true
        respiratory.requests.endTidalCarbonDioxidePressure.axisY.titleText = respiratory.requests.endTidalCarbonDioxidePressure.name
        
      } else  if  (respiratory.series(respiratory.requests.endTidalCarbonDioxidePressure.name)){
        respiratory.requests.endTidalCarbonDioxidePressure.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.endTidalCarbonDioxidePressure);
      }
      break;
      case "expiratoryFlow":
      if(active){
        respiratory.requests.expiratoryFlow = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.expiratoryFlow.name, respiratory.axisX, respiratory.requests.expiratoryFlow.axisY);
        respiratory.requests.expiratoryFlow.axisY = respiratory.axisY(respiratory.requests.expiratoryFlow)
        respiratory.requests.expiratoryFlow.axisY.visible = true
        respiratory.requests.expiratoryFlow.axisY.titleText = respiratory.requests.expiratoryFlow.name
        
      } else  if  (respiratory.series(respiratory.requests.expiratoryFlow.name)){
        respiratory.requests.expiratoryFlow.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.expiratoryFlow);
      }
      break;
      case "inspiratoryExpiratoryRatio":
      if(active){
        respiratory.requests.inspiratoryExpiratoryRatio = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.inspiratoryExpiratoryRatio.name, respiratory.axisX, respiratory.requests.inspiratoryExpiratoryRatio.axisY);
        respiratory.requests.inspiratoryExpiratoryRatio.axisY = respiratory.axisY(respiratory.requests.inspiratoryExpiratoryRatio)
        respiratory.requests.inspiratoryExpiratoryRatio.axisY.visible = true
        respiratory.requests.inspiratoryExpiratoryRatio.axisY.titleText = respiratory.requests.inspiratoryExpiratoryRatio.name
        
      } else  if  (respiratory.series(respiratory.requests.inspiratoryExpiratoryRatio.name)){
        respiratory.requests.inspiratoryExpiratoryRatio.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.inspiratoryExpiratoryRatio);
      }
      break;
      case "inspiratoryFlow":
      if(active){
        respiratory.requests.inspiratoryFlow = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.inspiratoryFlow.name, respiratory.axisX, respiratory.requests.inspiratoryFlow.axisY);
        respiratory.requests.inspiratoryFlow.axisY = respiratory.axisY(respiratory.requests.inspiratoryFlow)
        respiratory.requests.inspiratoryFlow.axisY.visible = true
        respiratory.requests.inspiratoryFlow.axisY.titleText = respiratory.requests.inspiratoryFlow.name
        
      } else  if  (respiratory.series(respiratory.requests.inspiratoryFlow.name)){
        respiratory.requests.inspiratoryFlow.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.inspiratoryFlow);
      }
      break;
      case "pulmonaryCompliance":
      if(active){
        respiratory.requests.pulmonaryCompliance = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.pulmonaryCompliance.name, respiratory.axisX, respiratory.requests.pulmonaryCompliance.axisY);
        respiratory.requests.pulmonaryCompliance.axisY = respiratory.axisY(respiratory.requests.pulmonaryCompliance)
        respiratory.requests.pulmonaryCompliance.axisY.visible = true
        respiratory.requests.pulmonaryCompliance.axisY.titleText = respiratory.requests.pulmonaryCompliance.name
        
      } else  if  (respiratory.series(respiratory.requests.pulmonaryCompliance.name)){
        respiratory.requests.pulmonaryCompliance.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.pulmonaryCompliance);
      }
      break;
      case "pulmonaryResistance":
      if(active){
        respiratory.requests.pulmonaryResistance = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.pulmonaryResistance.name, respiratory.axisX, respiratory.requests.pulmonaryResistance.axisY);
        respiratory.requests.pulmonaryResistance.axisY = respiratory.axisY(respiratory.requests.pulmonaryResistance)
        respiratory.requests.pulmonaryResistance.axisY.visible = true
        respiratory.requests.pulmonaryResistance.axisY.titleText = respiratory.requests.pulmonaryResistance.name
        
      } else  if  (respiratory.series(respiratory.requests.pulmonaryResistance.name)){
        respiratory.requests.pulmonaryResistance.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.pulmonaryResistance);
      }
      break;
      case "respirationDriverPressure":
      if(active){
        respiratory.requests.respirationDriverPressure = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.respirationDriverPressure.name, respiratory.axisX, respiratory.requests.respirationDriverPressure.axisY);
        respiratory.requests.respirationDriverPressure.axisY = respiratory.axisY(respiratory.requests.respirationDriverPressure)
        respiratory.requests.respirationDriverPressure.axisY.visible = true
        respiratory.requests.respirationDriverPressure.axisY.titleText = respiratory.requests.respirationDriverPressure.name
        
      } else  if  (respiratory.series(respiratory.requests.respirationDriverPressure.name)){
        respiratory.requests.respirationDriverPressure.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.respirationDriverPressure);
      }
      break;
      case "respirationMusclePressure":
      if(active){
        respiratory.requests.respirationMusclePressure = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.respirationMusclePressure.name, respiratory.axisX, respiratory.requests.respirationMusclePressure.axisY);
        respiratory.requests.respirationMusclePressure.axisY = respiratory.axisY(respiratory.requests.respirationMusclePressure)
        respiratory.requests.respirationMusclePressure.axisY.visible = true
        respiratory.requests.respirationMusclePressure.axisY.titleText = respiratory.requests.respirationMusclePressure.name
        
      } else  if  (respiratory.series(respiratory.requests.respirationMusclePressure.name)){
        respiratory.requests.respirationMusclePressure.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.respirationMusclePressure);
      }
      break;
      case "respirationRate":
      if(active){
        respiratory.requests.respirationRate = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.respirationRate.name, respiratory.axisX, respiratory.requests.respirationRate.axisY);
        respiratory.requests.respirationRate.axisY = respiratory.axisY(respiratory.requests.respirationRate)
        respiratory.requests.respirationRate.axisY.visible = true
        respiratory.requests.respirationRate.axisY.titleText = respiratory.requests.respirationRate.name
        
      } else  if  (respiratory.series(respiratory.requests.respirationRate.name)){
        respiratory.requests.respirationRate.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.respirationRate);
      }
      break;
      case "specificVentilation":
      if(active){
        respiratory.requests.specificVentilation = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.specificVentilation.name, respiratory.axisX, respiratory.requests.specificVentilation.axisY);
        respiratory.requests.specificVentilation.axisY = respiratory.axisY(respiratory.requests.specificVentilation)
        respiratory.requests.specificVentilation.axisY.visible = true
        respiratory.requests.specificVentilation.axisY.titleText = respiratory.requests.specificVentilation.name
        
      } else  if  (respiratory.series(respiratory.requests.specificVentilation.name)){
        respiratory.requests.specificVentilation.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.specificVentilation);
      }
      break;
      case "targetPulmonaryVentilation":
      if(active){
        respiratory.requests.targetPulmonaryVentilation = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.targetPulmonaryVentilation.name, respiratory.axisX, respiratory.requests.targetPulmonaryVentilation.axisY);
        respiratory.requests.targetPulmonaryVentilation.axisY = respiratory.axisY(respiratory.requests.targetPulmonaryVentilation)
        respiratory.requests.targetPulmonaryVentilation.axisY.visible = true
        respiratory.requests.targetPulmonaryVentilation.axisY.titleText = respiratory.requests.targetPulmonaryVentilation.name
        
      } else  if  (respiratory.series(respiratory.requests.targetPulmonaryVentilation.name)){
        respiratory.requests.targetPulmonaryVentilation.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.targetPulmonaryVentilation);
      }
      break;
      case "tidalVolume":
      if(active){
        respiratory.requests.tidalVolume = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.tidalVolume.name, respiratory.axisX, respiratory.requests.tidalVolume.axisY);
        respiratory.requests.tidalVolume.axisY = respiratory.axisY(respiratory.requests.tidalVolume)
        respiratory.requests.tidalVolume.axisY.visible = true
        respiratory.requests.tidalVolume.axisY.titleText = respiratory.requests.tidalVolume.name
        
      } else  if  (respiratory.series(respiratory.requests.tidalVolume.name)){
        respiratory.requests.tidalVolume.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.tidalVolume);
      }
      break;
      case "totalAlveolarVentilation":
      if(active){
        respiratory.requests.totalAlveolarVentilation = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.totalAlveolarVentilation.name, respiratory.axisX, respiratory.requests.totalAlveolarVentilation.axisY);
        respiratory.requests.totalAlveolarVentilation.axisY = respiratory.axisY(respiratory.requests.totalAlveolarVentilation)
        respiratory.requests.totalAlveolarVentilation.axisY.visible = true
        respiratory.requests.totalAlveolarVentilation.axisY.titleText = respiratory.requests.totalAlveolarVentilation.name
        
      } else  if  (respiratory.series(respiratory.requests.totalAlveolarVentilation.name)){
        respiratory.requests.totalAlveolarVentilation.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.totalAlveolarVentilation);
      }
      break;
      case "totalDeadSpaceVentilation":
      if(active){
        respiratory.requests.totalDeadSpaceVentilation = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.totalDeadSpaceVentilation.name, respiratory.axisX, respiratory.requests.totalDeadSpaceVentilation.axisY);
        respiratory.requests.totalDeadSpaceVentilation.axisY = respiratory.axisY(respiratory.requests.totalDeadSpaceVentilation)
        respiratory.requests.totalDeadSpaceVentilation.axisY.visible = true
        respiratory.requests.totalDeadSpaceVentilation.axisY.titleText = respiratory.requests.totalDeadSpaceVentilation.name
        
      } else  if  (respiratory.series(respiratory.requests.totalDeadSpaceVentilation.name)){
        respiratory.requests.totalDeadSpaceVentilation.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.totalDeadSpaceVentilation);
      }
      break;
      case "totalLungVolume":
      if(active){
        respiratory.requests.totalLungVolume = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.totalLungVolume.name, respiratory.axisX, respiratory.requests.totalLungVolume.axisY);
        respiratory.requests.totalLungVolume.axisY = respiratory.axisY(respiratory.requests.totalLungVolume)
        respiratory.requests.totalLungVolume.axisY.visible = true
        respiratory.requests.totalLungVolume.axisY.titleText = respiratory.requests.totalLungVolume.name
        
      } else  if  (respiratory.series(respiratory.requests.totalLungVolume.name)){
        respiratory.requests.totalLungVolume.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.totalLungVolume);
      }
      break;
      case "totalPulmonaryVentilation":
      if(active){
        respiratory.requests.totalPulmonaryVentilation = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.totalPulmonaryVentilation.name, respiratory.axisX, respiratory.requests.totalPulmonaryVentilation.axisY);
        respiratory.requests.totalPulmonaryVentilation.axisY = respiratory.axisY(respiratory.requests.totalPulmonaryVentilation)
        respiratory.requests.totalPulmonaryVentilation.axisY.visible = true
        respiratory.requests.totalPulmonaryVentilation.axisY.titleText = respiratory.requests.totalPulmonaryVentilation.name
        
      } else  if  (respiratory.series(respiratory.requests.totalPulmonaryVentilation.name)){
        respiratory.requests.totalPulmonaryVentilation.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.totalPulmonaryVentilation);
      }
      break;
      case "transpulmonaryPressure":
      if(active){
        respiratory.requests.transpulmonaryPressure = respiratory.createSeries(ChartView.SeriesTypeLine, respiratory.requests.transpulmonaryPressure.name, respiratory.axisX, respiratory.requests.transpulmonaryPressure.axisY);
        respiratory.requests.transpulmonaryPressure.axisY = respiratory.axisY(respiratory.requests.transpulmonaryPressure)
        respiratory.requests.transpulmonaryPressure.axisY.visible = true
        respiratory.requests.transpulmonaryPressure.axisY.titleText = respiratory.requests.transpulmonaryPressure.name
        
      } else  if  (respiratory.series(respiratory.requests.transpulmonaryPressure.name)){
        respiratory.requests.transpulmonaryPressure.axisY.visible = false
        respiratory.removeSeries(respiratory.requests.transpulmonaryPressure);
      }
      break;
    }
  }
  function toggleTissueSeries(request, active){
    const DEFAULT_UNIT = ""
    
    switch(request){
      case "carbonDioxideProductionRate":
      if(active){
        tissue.requests.carbonDioxideProductionRate = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.carbonDioxideProductionRate.name, tissue.axisX, tissue.requests.carbonDioxideProductionRate.axisY);
        tissue.requests.carbonDioxideProductionRate.axisY = tissue.axisY(tissue.requests.carbonDioxideProductionRate)
        tissue.requests.carbonDioxideProductionRate.axisY.visible = true
        tissue.requests.carbonDioxideProductionRate.axisY.titleText = tissue.requests.carbonDioxideProductionRate.name
        
      } else  if  (tissue.series(tissue.requests.transpulmonaryPressure.name)){
        tissue.requests.transpulmonaryPressure.axisY.visible = false
        tissue.removeSeries(tissue.requests.transpulmonaryPressure);
      }
      break;
      case "dehydrationFraction":
      if(active){
        tissue.requests.dehydrationFraction = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.dehydrationFraction.name, tissue.axisX, tissue.requests.dehydrationFraction.axisY);
        tissue.requests.dehydrationFraction.axisY = tissue.axisY(tissue.requests.dehydrationFraction)
        tissue.requests.dehydrationFraction.axisY.visible = true
        tissue.requests.dehydrationFraction.axisY.titleText = tissue.requests.dehydrationFraction.name
        
      } else  if  (tissue.series(tissue.requests.dehydrationFraction.name)){
        tissue.requests.dehydrationFraction.axisY.visible = false
        tissue.removeSeries(tissue.requests.dehydrationFraction);
      }
      break;
      case "extracellularFluidVolume":
      if(active){
        tissue.requests.extracellularFluidVolume = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.extracellularFluidVolume.name, tissue.axisX, tissue.requests.extracellularFluidVolume.axisY);
        tissue.requests.extracellularFluidVolume.axisY = tissue.axisY(tissue.requests.extracellularFluidVolume)
        tissue.requests.extracellularFluidVolume.axisY.visible = true
        tissue.requests.extracellularFluidVolume.axisY.titleText = tissue.requests.extracellularFluidVolume.name
        
      } else  if  (tissue.series(tissue.requests.extracellularFluidVolume.name)){
        tissue.requests.extracellularFluidVolume.axisY.visible = false
        tissue.removeSeries(tissue.requests.extracellularFluidVolume);
      }
      break;
      case "extravascularFluidVolume":
      if(active){
        tissue.requests.extravascularFluidVolume = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.extravascularFluidVolume.name, tissue.axisX, tissue.requests.extravascularFluidVolume.axisY);
        tissue.requests.extravascularFluidVolume.axisY = tissue.axisY(tissue.requests.extravascularFluidVolume)
        tissue.requests.extravascularFluidVolume.axisY.visible = true
        tissue.requests.extravascularFluidVolume.axisY.titleText = tissue.requests.extravascularFluidVolume.name
        
      } else  if  (tissue.series(tissue.requests.extravascularFluidVolume.name)){
        tissue.requests.extravascularFluidVolume.axisY.visible = false
        tissue.removeSeries(tissue.requests.extravascularFluidVolume);
      }
      break;
      case "intracellularFluidPH":
      if(active){
        tissue.requests.intracellularFluidPH = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.intracellularFluidPH.name, tissue.axisX, tissue.requests.intracellularFluidPH.axisY);
        tissue.requests.intracellularFluidPH.axisY = tissue.axisY(tissue.requests.intracellularFluidPH)
        tissue.requests.intracellularFluidPH.axisY.visible = true
        tissue.requests.intracellularFluidPH.axisY.titleText = tissue.requests.intracellularFluidPH.name
        
      } else  if  (tissue.series(tissue.requests.intracellularFluidPH.name)){
        tissue.requests.intracellularFluidPH.axisY.visible = false
        tissue.removeSeries(tissue.requests.intracellularFluidPH);
      }
      break;
      case "intracellularFluidVolume":
      if(active){
        tissue.requests.intracellularFluidVolume = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.intracellularFluidVolume.name, tissue.axisX, tissue.requests.intracellularFluidVolume.axisY);
        tissue.requests.intracellularFluidVolume.axisY = tissue.axisY(tissue.requests.intracellularFluidVolume)
        tissue.requests.intracellularFluidVolume.axisY.visible = true
        tissue.requests.intracellularFluidVolume.axisY.titleText = tissue.requests.intracellularFluidVolume.name
        
      } else  if  (tissue.series(tissue.requests.intracellularFluidVolume.name)){
        tissue.requests.intracellularFluidVolume.axisY.visible = false
        tissue.removeSeries(tissue.requests.intracellularFluidVolume);
      }
      break;
      case "totalBodyFluidVolume":
      if(active){
        tissue.requests.totalBodyFluidVolume = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.totalBodyFluidVolume.name, tissue.axisX, tissue.requests.totalBodyFluidVolume.axisY);
        tissue.requests.totalBodyFluidVolume.axisY = tissue.axisY(tissue.requests.totalBodyFluidVolume)
        tissue.requests.totalBodyFluidVolume.axisY.visible = true
        tissue.requests.totalBodyFluidVolume.axisY.titleText = tissue.requests.totalBodyFluidVolume.name
        
      } else  if  (tissue.series(tissue.requests.totalBodyFluidVolume.name)){
        tissue.requests.totalBodyFluidVolume.axisY.visible = false
        tissue.removeSeries(tissue.requests.totalBodyFluidVolume);
      }
      break;
      case "oxygenConsumptionRate":
      if(active){
        tissue.requests.oxygenConsumptionRate = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.oxygenConsumptionRate.name, tissue.axisX, tissue.requests.oxygenConsumptionRate.axisY);
        tissue.requests.oxygenConsumptionRate.axisY = tissue.axisY(tissue.requests.oxygenConsumptionRate)
        tissue.requests.oxygenConsumptionRate.axisY.visible = true
        tissue.requests.oxygenConsumptionRate.axisY.titleText = tissue.requests.oxygenConsumptionRate.name
        
      } else  if  (tissue.series(tissue.requests.oxygenConsumptionRate.name)){
        tissue.requests.oxygenConsumptionRate.axisY.visible = false
        tissue.removeSeries(tissue.requests.oxygenConsumptionRate);
      }
      break;
      case "respiratoryExchangeRatio":
      if(active){
        tissue.requests.respiratoryExchangeRatio = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.respiratoryExchangeRatio.name, tissue.axisX, tissue.requests.respiratoryExchangeRatio.axisY);
        tissue.requests.respiratoryExchangeRatio.axisY = tissue.axisY(tissue.requests.respiratoryExchangeRatio)
        tissue.requests.respiratoryExchangeRatio.axisY.visible = true
        tissue.requests.respiratoryExchangeRatio.axisY.titleText = tissue.requests.respiratoryExchangeRatio.name
        
      } else  if  (tissue.series(tissue.requests.respiratoryExchangeRatio.name)){
        tissue.requests.respiratoryExchangeRatio.axisY.visible = false
        tissue.removeSeries(tissue.requests.respiratoryExchangeRatio);
      }
      break;
      case "liverInsulinSetPoint":
      if(active){
        tissue.requests.liverInsulinSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.liverInsulinSetPoint.name, tissue.axisX, tissue.requests.liverInsulinSetPoint.axisY);
        tissue.requests.liverInsulinSetPoint.axisY = tissue.axisY(tissue.requests.liverInsulinSetPoint)
        tissue.requests.liverInsulinSetPoint.axisY.visible = true
        tissue.requests.liverInsulinSetPoint.axisY.titleText = tissue.requests.liverInsulinSetPoint.name
        
      } else  if  (tissue.series(tissue.requests.liverInsulinSetPoint.name)){
        tissue.requests.liverInsulinSetPoint.axisY.visible = false
        tissue.removeSeries(tissue.requests.liverInsulinSetPoint);
      }
      break;
      case "liverGlucagonSetPoint":
      if(active){
        tissue.requests.liverGlucagonSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.liverGlucagonSetPoint.name, tissue.axisX, tissue.requests.liverGlucagonSetPoint.axisY);
        tissue.requests.liverGlucagonSetPoint.axisY = tissue.axisY(tissue.requests.liverGlucagonSetPoint)
        tissue.requests.liverGlucagonSetPoint.axisY.visible = true
        tissue.requests.liverGlucagonSetPoint.axisY.titleText = tissue.requests.liverGlucagonSetPoint.name
        
      } else  if  (tissue.series(tissue.requests.liverGlucagonSetPoint.name)){
        tissue.requests.liverGlucagonSetPoint.axisY.visible = false
        tissue.removeSeries(tissue.requests.liverGlucagonSetPoint);
      }
      break;
      case "muscleInsulinSetPoint":
      if(active){
        tissue.requests.muscleInsulinSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.muscleInsulinSetPoint.name, tissue.axisX, tissue.requests.muscleInsulinSetPoint.axisY);
        tissue.requests.muscleInsulinSetPoint.axisY = tissue.axisY(tissue.requests.muscleInsulinSetPoint)
        tissue.requests.muscleInsulinSetPoint.axisY.visible = true
        tissue.requests.muscleInsulinSetPoint.axisY.titleText = tissue.requests.muscleInsulinSetPoint.name
        
      } else  if  (tissue.series(tissue.requests.muscleInsulinSetPoint.name)){
        tissue.requests.muscleInsulinSetPoint.axisY.visible = false
        tissue.removeSeries(tissue.requests.muscleInsulinSetPoint);
      }
      break;
      case "muscleGlucagonSetPoint":
      if(active){
        tissue.requests.muscleGlucagonSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.muscleGlucagonSetPoint.name, tissue.axisX, tissue.requests.muscleGlucagonSetPoint.axisY);
        tissue.requests.muscleGlucagonSetPoint.axisY = tissue.axisY(tissue.requests.muscleGlucagonSetPoint)
        tissue.requests.muscleGlucagonSetPoint.axisY.visible = true
        tissue.requests.muscleGlucagonSetPoint.axisY.titleText = tissue.requests.muscleGlucagonSetPoint.name
        
      } else  if  (tissue.series(tissue.requests.muscleGlucagonSetPoint.name)){
        tissue.requests.muscleGlucagonSetPoint.axisY.visible = false
        tissue.removeSeries(tissue.requests.muscleGlucagonSetPoint);
      }
      break;
      case "fatInsulinSetPoint":
      if(active){
        tissue.requests.fatInsulinSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.fatInsulinSetPoint.name, tissue.axisX, tissue.requests.fatInsulinSetPoint.axisY);
        tissue.requests.fatInsulinSetPoint.axisY = tissue.axisY(tissue.requests.fatInsulinSetPoint)
        tissue.requests.fatInsulinSetPoint.axisY.visible = true
        tissue.requests.fatInsulinSetPoint.axisY.titleText = tissue.requests.fatInsulinSetPoint.name
        
      } else  if  (tissue.series(tissue.requests.fatInsulinSetPoint.name)){
        tissue.requests.fatInsulinSetPoint.axisY.visible = false
        tissue.removeSeries(tissue.requests.fatInsulinSetPoint);
      }
      break;
      case "fatGlucagonSetPoint":
      if(active){
        tissue.requests.fatGlucagonSetPoint = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.fatGlucagonSetPoint.name, tissue.axisX, tissue.requests.fatGlucagonSetPoint.axisY);
        tissue.requests.fatGlucagonSetPoint.axisY = tissue.axisY(tissue.requests.fatGlucagonSetPoint)
        tissue.requests.fatGlucagonSetPoint.axisY.visible = true
        tissue.requests.fatGlucagonSetPoint.axisY.titleText = tissue.requests.fatGlucagonSetPoint.name
        
      } else  if  (tissue.series(tissue.requests.fatGlucagonSetPoint.name)){
        tissue.requests.fatGlucagonSetPoint.axisY.visible = false
        tissue.removeSeries(tissue.requests.fatGlucagonSetPoint);
      }
      break;
      case "liverGlycogen":
      if(active){
        tissue.requests.liverGlycogen = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.liverGlycogen.name, tissue.axisX, tissue.requests.liverGlycogen.axisY);
        tissue.requests.liverGlycogen.axisY = tissue.axisY(tissue.requests.liverGlycogen)
        tissue.requests.liverGlycogen.axisY.visible = true
        tissue.requests.liverGlycogen.axisY.titleText = tissue.requests.liverGlycogen.name
        
      } else  if  (tissue.series(tissue.requests.liverGlycogen.name)){
        tissue.requests.liverGlycogen.axisY.visible = false
        tissue.removeSeries(tissue.requests.liverGlycogen);
      }
      break;
      case "muscleGlycogen":
      if(active){
        tissue.requests.muscleGlycogen = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.muscleGlycogen.name, tissue.axisX, tissue.requests.muscleGlycogen.axisY);
        tissue.requests.muscleGlycogen.axisY = tissue.axisY(tissue.requests.muscleGlycogen)
        tissue.requests.muscleGlycogen.axisY.visible = true
        tissue.requests.muscleGlycogen.axisY.titleText = tissue.requests.muscleGlycogen.name
        
      } else  if  (tissue.series(tissue.requests.muscleGlycogen.name)){
        tissue.requests.muscleGlycogen.axisY.visible = false
        tissue.removeSeries(tissue.requests.muscleGlycogen);
      }
      break;
      case "storedProtein":
      if(active){
        tissue.requests.storedProtein = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.storedProtein.name, tissue.axisX, tissue.requests.storedProtein.axisY);
        tissue.requests.storedProtein.axisY = tissue.axisY(tissue.requests.storedProtein)
        tissue.requests.storedProtein.axisY.visible = true
        tissue.requests.storedProtein.axisY.titleText = tissue.requests.storedProtein.name
        
      } else  if  (tissue.series(tissue.requests.storedProtein.name)){
        tissue.requests.storedProtein.axisY.visible = false
        tissue.removeSeries(tissue.requests.storedProtein);
      }
      break;
      case "storedFat":
      if(active){
        tissue.requests.storedFat = tissue.createSeries(ChartView.SeriesTypeLine, tissue.requests.storedFat.name, tissue.axisX, tissue.requests.storedFat.axisY);
        tissue.requests.storedFat.axisY = tissue.axisY(tissue.requests.storedFat)
        tissue.requests.storedFat.axisY.visible = true
        tissue.requests.storedFat.axisY.titleText = tissue.requests.storedFat.name
        
      } else  if  (tissue.series(tissue.requests.storedFat.name)){
        tissue.requests.storedFat.axisY.visible = false
        tissue.removeSeries(tissue.requests.storedFat);
      }
      break;
    }
  }
  onFilterChange : {
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
