import QtQuick 2.12
import QtCharts 2.3
//BlodChemistry

Item {
  id:root
  
  property LineSeries arterialBloodPH : LineSeries {
      name: "arterialBloodPH"
      axisY : ValueAxis {
            min : 0.
            max : 1.
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Arterial BloodPH"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)

      }
  }
  property LineSeries arterialBloodPHBaseline : LineSeries {
      name: "arterialBloodPHBaseline"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Arterial BloodPH Baseline"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries bloodDensity : LineSeries {
      name: "bloodDensity"     
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Blood Density"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries bloodSpecificHeat : LineSeries {
      name: "bloodSpecificHeat"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Blood Specific Heat"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries bloodUreaNitrogenConcentration : LineSeries {
      name: "bloodUreaNitrogenConcentration"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Blood Urea N<sup>2</sup> Concentration"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries carbonDioxideSaturation : LineSeries {
      name: "carbonDioxideSaturation"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "CO<sup>2</sup> Saturation"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries carbonMonoxideSaturation : LineSeries {
      name: "carbonMonoxideSaturation"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "CO Saturation"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries hematocrit : LineSeries {
      name: "hematocrit"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Hematocrit"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries hemoglobinContent : LineSeries {
      name: "hemoglobinContent"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Hemoglobin Content"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries oxygenSaturation : LineSeries {
      name: "oxygenSaturation"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "O<sup>2</sup> Saturation"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries phosphate : LineSeries {
      name: "phosphate"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Phosphate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }   
  property LineSeries plasmaVolume : LineSeries {
      name: "plasmaVolume"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Plasma Volume"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }   
  property LineSeries pulseOximetry : LineSeries {
      name: "pulseOximetry"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Pulse Oximetry"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }   
  property LineSeries redBloodCellAcetylcholinesterase : LineSeries {
      name: "redBloodCellAcetylcholinesterase"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "RBC Acetylchol Cholinesterase"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }   
  property LineSeries redBloodCellCount : LineSeries {
      name: "redBloodCellCount"
      axisY : ValueAxis {
      min : 0.
      max : 1.
      property string label : "Red Blood Cell Count"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      labelFormat : (max < 100)?  '%0.2d': '%0.2e'
      }
  }
  property LineSeries shuntFraction : LineSeries {
      name: "shuntFraction"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Shunt Fraction"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }     
  property LineSeries strongIonDifference : LineSeries {
      name: "strongIonDifference"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Strong Ion Difference"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries totalBilirubin : LineSeries {
      name: "totalBilirubin"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Total Billirubin"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries totalProteinConcentration : LineSeries {
      name: "totalProteinConcentration"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Total Protein Concentration"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries venousBloodPH : LineSeries {
      name: "venousBloodPH"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Venous BloodPH"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries volumeFractionNeutralPhospholipidInPlasma : LineSeries {
      name: "volumeFractionNeutralPhospholipidInPlasma"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Volume Fraction Netural Phospholipid In Plasma"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries volumeFractionNeutralLipidInPlasma : LineSeries {
      name: "volumeFractionNeutralLipidInPlasma"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Volume Fraction Neutrual Lipid In Plasma"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries arterialCarbonDioxidePressure : LineSeries {
      name: "arterialCarbonDioxidePressure"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Arterial CO<sup>2</sup> Pressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries arterialOxygenPressure : LineSeries {
      name: "arterialOxygenPressure"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Pulmonary arterial  CO<sup>2</sup> Pressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries pulmonaryArterialCarbonDioxidePressure : LineSeries {
      name: "pulmonaryArterialCarbonDioxidePressure"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Pulmonary Arterial CO<sup>2</sup> Pressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries pulmonaryArterialOxygenPressure :LineSeries {
      name: "pulmonaryArterialOxygenPressure"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Pulmonary Arterial O<sup>2</sup> Pressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries pulmonaryVenousCarbonDioxidePressure : LineSeries {
      name: "pulmonaryVenousCarbonDioxidePressure"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Pulmonary Venous CO<sup>2</sup> Pressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries pulmonaryVenousOxygenPressure : LineSeries {
      name: "pulmonaryVenousOxygenPressure"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Pulmonary Venous O<sup>2</sup> Pressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries venousCarbonDioxidePressure : LineSeries {
      name: "venousCarbonDioxidePressure"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Venous CO<sup>2</sup> Pressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries venousOxygenPressure : LineSeries {
      name: "venousOxygenPressure"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Venous O<sup>2</sup> Pressure"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
   }
   property LineSeries inflammatoryResponse : LineSeries {
      name: "inflammatoryResponse"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseLocalPathogen : LineSeries {
      name: "inflammatoryResponseLocalPathogen"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Local Pathogen"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseLocalMacrophage : LineSeries {
      name: "inflammatoryResponseLocalMacrophage"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Local Macrophage"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseLocalNeutrophil : LineSeries {
      name: "inflammatoryResponseLocalNeutrophil"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Local Neutrophil"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseLocalBarrier : LineSeries {
      name: "inflammatoryResponseLocalBarrier"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Local Barrier"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseBloodPathogen : LineSeries {
      name: "inflammatoryResponseBloodPathogen"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Blood Pathogen"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  } 
  property LineSeries inflammatoryResponseTrauma : LineSeries {
      name: "inflammatoryResponseTrauma"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Trauma"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
   property LineSeries inflammatoryResponseMacrophageResting : LineSeries {
      name: "inflammatoryResponseMacrophageResting"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Macrophage Resting"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseMacrophageActive : LineSeries {
      name: "inflammatoryResponseMacrophageActive"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Macrophage Active"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseNeutrophilResting : LineSeries {
      name: "inflammatoryResponseNeutrophilResting"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Neutrophil Resting"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseNeutrophilActive : LineSeries {
      name: "inflammatoryResponseNeutrophilActive"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Neutrophil Active"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseInducibleNOSPre : LineSeries {
      name: "inflammatoryResponseInducibleNOSPre"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Inducible NOS Pre"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseInducibleNOS : LineSeries {
      name: "inflammatoryResponseInducibleNOS"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Inducible NOS"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseConstitutiveNOS : LineSeries {
      name: "inflammatoryResponseConstitutiveNOS"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Consitutive NOS"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseNitrate : LineSeries {
      name: "inflammatoryResponseNitrate"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Nitrate"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseNitricOxide : LineSeries {
      name: "inflammatoryResponseNitricOxide"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Nitric Oxide"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseTumorNecrosisFactor : LineSeries {
      name: "inflammatoryResponseTumorNecrosisFactor"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Tumor Necrosis Factor"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseInterleukin6 : LineSeries {
      name: "inflammatoryResponseInterleukin6"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Inter Lukin 6"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseInterleukin10 : LineSeries {
      name: "inflammatoryResponseInterleukin10"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Inter Lukin 10"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseInterleukin12 : LineSeries {
      name: "inflammatoryResponseInterleukin12"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Inter Lukin 12"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseCatecholamines : LineSeries {
      name: "inflammatoryResponseCatecholamines"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Catecholamines"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }
  property LineSeries inflammatoryResponseTissueIntegrity : LineSeries {
      name: "inflammatoryResponseTissueIntegrity"
      axisY : ValueAxis {
            min:0.0
            max:1.0
            labelFormat: (max < 100.) ?  '%0.2d': '%0.2e'
            property string label : "Inflammatory Response Tissue Integrity"
            property string unit   : ""
            titleText : "%1 %2".arg(label).arg(unit)
      }
  }

}

/*##^## Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
 ##^##*/
