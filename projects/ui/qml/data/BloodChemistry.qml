import QtQuick 2.12
import QtCharts 2.3
//BlodChemistry

Item {
  id:root

  property LineSeries arterialBloodPH : LineSeries {
      
      name: "arterialBloodPH"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries arterialBloodPHBaseline : LineSeries {
      
      name: "arterialBloodPHBaseline"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries bloodDensity : LineSeries {
      
      name: "bloodDensity"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries bloodSpecificHeat : LineSeries {
      
      name: "bloodSpecificHeat"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries bloodUreaNitrogenConcentration : LineSeries {
      
      name: "bloodUreaNitrogenConcentration"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries carbonDioxideSaturation : LineSeries {
      
      name: "carbonDioxideSaturation"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries carbonMonoxideSaturation : LineSeries {
      
      name: "carbonMonoxideSaturation"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries hematocrit : LineSeries {
      
      name: "hematocrit"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
   property LineSeries hemoglobinContent : LineSeries {
      
      name: "hemoglobinContent"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries oxygenSaturation : LineSeries {
      
      name: "oxygenSaturation"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries phosphate : LineSeries {
      
      name: "phosphate"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }   
  property LineSeries plasmaVolume : LineSeries {
      
      name: "plasmaVolume"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }   
  property LineSeries pulseOximetry : LineSeries {
      
      name: "pulseOximetry"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }   
  property LineSeries redBloodCellAcetylcholinesterase : LineSeries {
      
      name: "redBloodCellAcetylcholinesterase"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }   
  property LineSeries redBloodCellCount : LineSeries {
      
      name: "redBloodCellCount"
      axisX : ValueAxis {}
      axisY : ValueAxis {}

      onPointAdded : {
        console.log("THE ROOF THE ROOF THE ROOF IS ON FIRE.")
      }
    }
  property LineSeries shuntFraction : LineSeries {
      
      name: "shuntFraction"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }     
  property LineSeries strongIonDifference : LineSeries {
      
      name: "strongIonDifference"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries totalBilirubin : LineSeries {
      
      name: "totalBilirubin"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries totalProteinConcentration : LineSeries {
      
      name: "totalProteinConcentration"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries venousBloodPH : LineSeries {
      
      name: "venousBloodPH"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries volumeFractionNeutralPhospholipidInPlasma : LineSeries {
      
      name: "volumeFractionNeutralPhospholipidInPlasma"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries volumeFractionNeutralLipidInPlasma : LineSeries {
      
      name: "volumeFractionNeutralLipidInPlasma"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries arterialCarbonDioxidePressure : LineSeries {
      
      name: "arterialCarbonDioxidePressure"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries arterialOxygenPressure : LineSeries {
      
      name: "arterialOxygenPressure"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries pulmonaryArterialCarbonDioxidePressure : LineSeries {
      
      name: "pulmonaryArterialCarbonDioxidePressure"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries pulmonaryArterialOxygenPressure :LineSeries {
      
      name: "pulmonaryArterialOxygenPressure"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries pulmonaryVenousCarbonDioxidePressure : LineSeries {
      
      name: "pulmonaryVenousCarbonDioxidePressure"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries pulmonaryVenousOxygenPressure : LineSeries {
      
      name: "pulmonaryVenousOxygenPressure"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries venousCarbonDioxidePressure : LineSeries {
      
      name: "venousCarbonDioxidePressure"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
   property LineSeries venousOxygenPressure : LineSeries {
      
      name: "venousOxygenPressure"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
    property LineSeries inflammatoryResponse : LineSeries {
      
      name: "inflammatoryResponse"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseLocalPathogen : LineSeries {
      
      name: "inflammatoryResponseLocalPathogen"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseLocalMacrophage : LineSeries {
      
      name: "inflammatoryResponseLocalMacrophage"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseLocalNeutrophil : LineSeries {
      
      name: "inflammatoryResponseLocalNeutrophil"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseLocalBarrier : LineSeries {
      
      name: "inflammatoryResponseLocalBarrier"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseBloodPathogen : LineSeries {
      
      name: "inflammatoryResponseBloodPathogen"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    } 
  property LineSeries inflammatoryResponseTrauma : LineSeries {
      
      name: "inflammatoryResponseTrauma"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
   property LineSeries inflammatoryResponseMacrophageResting : LineSeries {
      
      name: "inflammatoryResponseMacrophageResting"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseMacrophageActive : LineSeries {
      
      name: "inflammatoryResponseMacrophageActive"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseNeutrophilResting : LineSeries {
      
      name: "inflammatoryResponseNeutrophilResting"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseNeutrophilActive : LineSeries {
      
      name: "inflammatoryResponseNeutrophilActive"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseInducibleNOSPre : LineSeries {
      
      name: "inflammatoryResponseInducibleNOSPre"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseInducibleNOS : LineSeries {
      
      name: "inflammatoryResponseInducibleNOS"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseConstitutiveNOS : LineSeries {
      
      name: "inflammatoryResponseConstitutiveNOS"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseNitrate : LineSeries {
      
      name: "inflammatoryResponseNitrate"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseNitricOxide : LineSeries {
      
      name: "inflammatoryResponseNitricOxide"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseTumorNecrosisFactor : LineSeries {
      
      name: "inflammatoryResponseTumorNecrosisFactor"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseInterleukin6 : LineSeries {
      
      name: "inflammatoryResponseInterleukin6"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseInterleukin10 : LineSeries {
      
      name: "inflammatoryResponseInterleukin10"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseInterleukin12 : LineSeries {
      
      name: "inflammatoryResponseInterleukin12"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseCatecholamines : LineSeries {
      
      name: "inflammatoryResponseCatecholamines"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }
  property LineSeries inflammatoryResponseTissueIntegrity : LineSeries {
      
      name: "inflammatoryResponseTissueIntegrity"
      axisX : ValueAxis {}
      axisY : ValueAxis {}
    }

}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
