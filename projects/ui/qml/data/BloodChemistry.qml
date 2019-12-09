import QtQuick 2.12
import QtCharts 2.3
//BlodChemistry

Item {
  id:root

  property alias arterialBloodPH : arterialBloodPH
  property alias arterialBloodPHBaseline : arterialBloodPHBaseline
  property alias bloodDensity : bloodDensity
  property alias bloodSpecificHeat : bloodSpecificHeat
  property alias bloodUreaNitrogenConcentration : bloodUreaNitrogenConcentration
  property alias carbonDioxideSaturation : carbonDioxideSaturation
  property alias carbonMonoxideSaturation : carbonMonoxideSaturation
  property alias hematocrit : hematocrit
  property alias hemoglobinContent : hemoglobinContent
  property alias oxygenSaturation : oxygenSaturation
  property alias phosphate : phosphate
  property alias plasmaVolume : plasmaVolume
  property alias pulseOximetry : pulseOximetry
  property alias redBloodCellAcetylcholinesterase : redBloodCellAcetylcholinesterase
  property alias redBloodCellCount : redBloodCellCount
  property alias shuntFraction : shuntFraction
  property alias strongIonDifference : strongIonDifference
  property alias totalBilirubin : totalBilirubin
  property alias totalProteinConcentration : totalProteinConcentration
  property alias venousBloodPH : venousBloodPH
  property alias volumeFractionNeutralPhospholipidInPlasma : volumeFractionNeutralPhospholipidInPlasma
  property alias volumeFractionNeutralLipidInPlasma : volumeFractionNeutralLipidInPlasma
  property alias arterialCarbonDioxidePressure : arterialCarbonDioxidePressure
  property alias arterialOxygenPressure : arterialOxygenPressure
  property alias pulmonaryArterialCarbonDioxidePressure : pulmonaryArterialCarbonDioxidePressure
  property alias pulmonaryArterialOxygenPressure : pulmonaryArterialOxygenPressure
  property alias pulmonaryVenousCarbonDioxidePressure : pulmonaryVenousCarbonDioxidePressure
  property alias pulmonaryVenousOxygenPressure : pulmonaryVenousOxygenPressure
  property alias venousCarbonDioxidePressure : venousCarbonDioxidePressure
  property alias venousOxygenPressure : venousOxygenPressure
  property alias inflammatoryResponse : inflammatoryResponse
  property alias inflammatoryResponseLocalPathogen : inflammatoryResponseLocalPathogen
  property alias inflammatoryResponseLocalMacrophage : inflammatoryResponseLocalMacrophage
  property alias inflammatoryResponseLocalNeutrophil : inflammatoryResponseLocalNeutrophil
  property alias inflammatoryResponseLocalBarrier : inflammatoryResponseLocalBarrier
  property alias inflammatoryResponseBloodPathogen : inflammatoryResponseBloodPathogen
  property alias inflammatoryResponseTrauma : inflammatoryResponseTrauma
  property alias inflammatoryResponseMacrophageResting : inflammatoryResponseMacrophageResting
  property alias inflammatoryResponseMacrophageActive : inflammatoryResponseMacrophageActive
  property alias inflammatoryResponseNeutrophilResting : inflammatoryResponseNeutrophilResting
  property alias inflammatoryResponseNeutrophilActive : inflammatoryResponseNeutrophilActive
  property alias inflammatoryResponseInducibleNOSPre : inflammatoryResponseInducibleNOSPre
  property alias inflammatoryResponseInducibleNOS : inflammatoryResponseInducibleNOS
  property alias inflammatoryResponseConstitutiveNOS : inflammatoryResponseConstitutiveNOS
  property alias inflammatoryResponseNitrate : inflammatoryResponseNitrate
  property alias inflammatoryResponseNitricOxide : inflammatoryResponseNitricOxide
  property alias inflammatoryResponseTumorNecrosisFactor : inflammatoryResponseTumorNecrosisFactor
  property alias inflammatoryResponseInterleukin6 : inflammatoryResponseInterleukin6
  property alias inflammatoryResponseInterleukin10 : inflammatoryResponseInterleukin10
  property alias inflammatoryResponseInterleukin12 : inflammatoryResponseInterleukin12
  property alias inflammatoryResponseCatecholamines : inflammatoryResponseCatecholamines
  property alias inflammatoryResponseTissueIntegrity : inflammatoryResponseTissueIntegrity
  
  property list<LineSeries> requests : [

    LineSeries {
      id: arterialBloodPH
    }
   ,LineSeries {
      id: arterialBloodPHBaseline
    }
   ,LineSeries {
      id: bloodDensity
    }
   ,LineSeries {
      id: bloodSpecificHeat
    }
   ,LineSeries {
      id: bloodUreaNitrogenConcentration
    }
   ,LineSeries {
      id: carbonDioxideSaturation
    }
   ,LineSeries {
      id: carbonMonoxideSaturation
    }
   ,LineSeries {
      id: hematocrit
    }
   ,LineSeries {
      id: hemoglobinContent
    }
   ,LineSeries {
      id: oxygenSaturation
    }
   ,LineSeries {
      id: phosphate
    }
   ,LineSeries {
      id: plasmaVolume
    }
   ,LineSeries {
      id: pulseOximetry
    }
   ,LineSeries {
      id: redBloodCellAcetylcholinesterase
    }
   ,LineSeries {
      id: redBloodCellCount
    }
   ,LineSeries {
      id: shuntFraction
    }
   ,LineSeries {
      id: strongIonDifference
    }
   ,LineSeries {
      id: totalBilirubin
    }
   ,LineSeries {
      id: totalProteinConcentration
    }
   ,LineSeries {
      id: venousBloodPH
    }
   ,LineSeries {
      id: volumeFractionNeutralPhospholipidInPlasma
    }
   ,LineSeries {
      id: volumeFractionNeutralLipidInPlasma
    }
   ,LineSeries {
      id: arterialCarbonDioxidePressure
    }
   ,LineSeries {
      id: arterialOxygenPressure
    }
   ,LineSeries {
      id: pulmonaryArterialCarbonDioxidePressure
    }
   ,LineSeries {
      id: pulmonaryArterialOxygenPressure
    }
   ,LineSeries {
      id: pulmonaryVenousCarbonDioxidePressure
    }
   ,LineSeries {
      id: pulmonaryVenousOxygenPressure
    }
   ,LineSeries {
      id: venousCarbonDioxidePressure
    }
   ,LineSeries {
      id: venousOxygenPressure
    }
   ,LineSeries {
      id: inflammatoryResponse
    }
   ,LineSeries {
      id: inflammatoryResponseLocalPathogen
    }
   ,LineSeries {
      id: inflammatoryResponseLocalMacrophage
    }
   ,LineSeries {
      id: inflammatoryResponseLocalNeutrophil
    }
   ,LineSeries {
      id: inflammatoryResponseLocalBarrier
    }
   ,LineSeries {
      id: inflammatoryResponseBloodPathogen
    }
   ,LineSeries {
      id: inflammatoryResponseTrauma
    }
   ,LineSeries {
      id: inflammatoryResponseMacrophageResting
    }
   ,LineSeries {
      id: inflammatoryResponseMacrophageActive
    }
   ,LineSeries {
      id: inflammatoryResponseNeutrophilResting
    }
   ,LineSeries {
      id: inflammatoryResponseNeutrophilActive
    }
   ,LineSeries {
      id: inflammatoryResponseInducibleNOSPre
    }
   ,LineSeries {
      id: inflammatoryResponseInducibleNOS
    }
   ,LineSeries {
      id: inflammatoryResponseConstitutiveNOS
    }
   ,LineSeries {
      id: inflammatoryResponseNitrate
    }
   ,LineSeries {
      id: inflammatoryResponseNitricOxide
    }
   ,LineSeries {
      id: inflammatoryResponseTumorNecrosisFactor
    }
   ,LineSeries {
      id: inflammatoryResponseInterleukin6
    }
   ,LineSeries {
      id: inflammatoryResponseInterleukin10
    }
   ,LineSeries {
      id: inflammatoryResponseInterleukin12
    }
   ,LineSeries {
      id: inflammatoryResponseCatecholamines
    }
   ,LineSeries {
      id: inflammatoryResponseTissueIntegrity
    }
    ]
}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
