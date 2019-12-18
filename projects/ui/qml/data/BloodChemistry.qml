import QtQuick 2.12
import QtCharts 2.3
//BlodChemistry

Item {
  id:root
  
  property ValueAxis axisX : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
    property int tickCount : 0
    titleText : "Simulation Time"
    min: 0
    max : 60
  }

  property LineSeries arterialBloodPH : LineSeries {
      id: arterialBloodPH
      name: "arterialBloodPH"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries arterialBloodPHBaseline : LineSeries {
      id: arterialBloodPHBaseline
      name: "arterialBloodPHBaseline"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries bloodDensity : LineSeries {
      id: bloodDensity
      name: "bloodDensity"      
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries bloodSpecificHeat : LineSeries {
      id: bloodSpecificHeat
      name: "bloodSpecificHeat"
      
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries bloodUreaNitrogenConcentration : LineSeries {
      id: bloodUreaNitrogenConcentration
      name: "bloodUreaNitrogenConcentration"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries carbonDioxideSaturation : LineSeries {
      id: carbonDioxideSaturation
      name: "carbonDioxideSaturation"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'            
      }
  }
  property LineSeries carbonMonoxideSaturation : LineSeries {
      id: carbonMonoxideSaturation
      name: "carbonMonoxideSaturation"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'            
      }
  }
  property LineSeries hematocrit : LineSeries {
      id: hematocrit
      name: "hematocrit"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries hemoglobinContent : LineSeries {
      id: hemoglobinContent
      name: "hemoglobinContent"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries oxygenSaturation : LineSeries {
      id: oxygenSaturation
      name: "oxygenSaturation"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries phosphate : LineSeries {
      id: phosphate
      name: "phosphate"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }   
  property LineSeries plasmaVolume : LineSeries {
      id: plasmaVolume
      name: "plasmaVolume"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }   
  property LineSeries pulseOximetry : LineSeries {
      id: pulseOximetry
      name: "pulseOximetry"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }   
  property LineSeries redBloodCellAcetylcholinesterase : LineSeries {
      id: redBloodCellAcetylcholinesterase
      name: "redBloodCellAcetylcholinesterase"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }   
  property LineSeries redBloodCellCount : LineSeries {
      id: redBloodCellCount
      name: "redBloodCellCount"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      
      }
  }
  property LineSeries shuntFraction : LineSeries {
      id: shuntFraction
      name: "shuntFraction"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }     
  property LineSeries strongIonDifference : LineSeries {
      id: strongIonDifference
      name: "strongIonDifference"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries totalBilirubin : LineSeries {
      id: totalBilirubin
      name: "totalBilirubin"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries totalProteinConcentration : LineSeries {
      id: totalProteinConcentration
      name: "totalProteinConcentration"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries venousBloodPH : LineSeries {
      id: venousBloodPH
      name: "venousBloodPH"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries volumeFractionNeutralPhospholipidInPlasma : LineSeries {
      id: volumeFractionNeutralPhospholipidInPlasma
      name: "volumeFractionNeutralPhospholipidInPlasma"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries volumeFractionNeutralLipidInPlasma : LineSeries {
      id: volumeFractionNeutralLipidInPlasma
      name: "volumeFractionNeutralLipidInPlasma"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries arterialCarbonDioxidePressure : LineSeries {
      id: arterialCarbonDioxidePressure
      name: "arterialCarbonDioxidePressure"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries arterialOxygenPressure : LineSeries {
      id: arterialOxygenPressure
      name: "arterialOxygenPressure"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries pulmonaryArterialCarbonDioxidePressure : LineSeries {
      id: pulmonaryArterialCarbonDioxidePressure
      name: "pulmonaryArterialCarbonDioxidePressure"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries pulmonaryArterialOxygenPressure :LineSeries {
      id: pulmonaryArterialOxygenPressure
      name: "pulmonaryArterialOxygenPressure"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries pulmonaryVenousCarbonDioxidePressure : LineSeries {
      id: pulmonaryVenousCarbonDioxidePressure
      name: "pulmonaryVenousCarbonDioxidePressure"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries pulmonaryVenousOxygenPressure : LineSeries {
      id: pulmonaryVenousOxygenPressure
      name: "pulmonaryVenousOxygenPressure"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries venousCarbonDioxidePressure : LineSeries {
      id: venousCarbonDioxidePressure
      name: "venousCarbonDioxidePressure"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries venousOxygenPressure : LineSeries {
      id: venousOxygenPressure
      name: "venousOxygenPressure"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
   }
   property LineSeries inflammatoryResponse : LineSeries {
      id: inflammatoryResponse
      name: "inflammatoryResponse"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseLocalPathogen : LineSeries {
      id: inflammatoryResponseLocalPathogen
      name: "inflammatoryResponseLocalPathogen"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseLocalMacrophage : LineSeries {
      id: inflammatoryResponseLocalMacrophage
      name: "inflammatoryResponseLocalMacrophage"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseLocalNeutrophil : LineSeries {
      id: inflammatoryResponseLocalNeutrophil
      name: "inflammatoryResponseLocalNeutrophil"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseLocalBarrier : LineSeries {
      id: inflammatoryResponseLocalBarrier
      name: "inflammatoryResponseLocalBarrier"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseBloodPathogen : LineSeries {
      id: inflammatoryResponseBloodPathogen
      name: "inflammatoryResponseBloodPathogen"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  } 
  property LineSeries inflammatoryResponseTrauma : LineSeries {
      id: inflammatoryResponseTrauma
      name: "inflammatoryResponseTrauma"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
   property LineSeries inflammatoryResponseMacrophageResting : LineSeries {
      id: inflammatoryResponseMacrophageResting
      name: "inflammatoryResponseMacrophageResting"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseMacrophageActive : LineSeries {
      id: inflammatoryResponseMacrophageActive
      name: "inflammatoryResponseMacrophageActive"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseNeutrophilResting : LineSeries {
      id: inflammatoryResponseNeutrophilResting
      name: "inflammatoryResponseNeutrophilResting"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseNeutrophilActive : LineSeries {
      id: inflammatoryResponseNeutrophilActive
      name: "inflammatoryResponseNeutrophilActive"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseInducibleNOSPre : LineSeries {
      id: inflammatoryResponseInducibleNOSPre
      name: "inflammatoryResponseInducibleNOSPre"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseInducibleNOS : LineSeries {
      id: inflammatoryResponseInducibleNOS
      name: "inflammatoryResponseInducibleNOS"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseConstitutiveNOS : LineSeries {
      id: inflammatoryResponseConstitutiveNOS
      name: "inflammatoryResponseConstitutiveNOS"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseNitrate : LineSeries {
      id: inflammatoryResponseNitrate
      name: "inflammatoryResponseNitrate"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseNitricOxide : LineSeries {
      id: inflammatoryResponseNitricOxide
      name: "inflammatoryResponseNitricOxide"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseTumorNecrosisFactor : LineSeries {
      id: inflammatoryResponseTumorNecrosisFactor
      name: "inflammatoryResponseTumorNecrosisFactor"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseInterleukin6 : LineSeries {
      id: inflammatoryResponseInterleukin6
      name: "inflammatoryResponseInterleukin6"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseInterleukin10 : LineSeries {
      id: inflammatoryResponseInterleukin10
      name: "inflammatoryResponseInterleukin10"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseInterleukin12 : LineSeries {
      id: inflammatoryResponseInterleukin12
      name: "inflammatoryResponseInterleukin12"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseCatecholamines : LineSeries {
      id: inflammatoryResponseCatecholamines
      name: "inflammatoryResponseCatecholamines"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }
  property LineSeries inflammatoryResponseTissueIntegrity : LineSeries {
      id: inflammatoryResponseTissueIntegrity
      name: "inflammatoryResponseTissueIntegrity"
      axisY : ValueAxis {
        labelFormat: (max < 1.)? '%0.2f' : (max < 10.)? '%0.1f' : (max < 100.) ?  '%3d' : '%0.2e'
      }
  }

}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
