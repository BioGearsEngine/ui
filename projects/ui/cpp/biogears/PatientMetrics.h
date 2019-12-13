#pragma once

#include <QObject>

struct PatientMetrics : QObject{
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
      && simulationTime == rhs.simulationTime
      && timeStep == rhs.timeStep
    ;
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

  Q_PROPERTY(double simulationTime MEMBER simulationTime)
  Q_PROPERTY(double timeStep MEMBER timeStep)

  Q_PROPERTY(double arterialBloodPH MEMBER arterialBloodPH )
  Q_PROPERTY(double arterialBloodPHBaseline MEMBER arterialBloodPHBaseline )
  Q_PROPERTY(double bloodDensity MEMBER bloodDensity )
  Q_PROPERTY(double bloodSpecificHeat MEMBER bloodSpecificHeat )
  Q_PROPERTY(double bloodUreaNitrogenConcentration MEMBER bloodUreaNitrogenConcentration )
  Q_PROPERTY(double carbonDioxideSaturation MEMBER carbonDioxideSaturation )
  Q_PROPERTY(double carbonMonoxideSaturation MEMBER carbonMonoxideSaturation )
  Q_PROPERTY(double hematocrit MEMBER hematocrit )
  Q_PROPERTY(double hemoglobinContent MEMBER hemoglobinContent )
  Q_PROPERTY(double oxygenSaturation MEMBER oxygenSaturation )
  Q_PROPERTY(double phosphate MEMBER phosphate )
  Q_PROPERTY(double plasmaVolume MEMBER plasmaVolume )
  Q_PROPERTY(double pulseOximetry MEMBER pulseOximetry )
  Q_PROPERTY(double redBloodCellAcetylcholinesterase MEMBER redBloodCellAcetylcholinesterase )
  Q_PROPERTY(double redBloodCellCount MEMBER redBloodCellCount )
  Q_PROPERTY(double shuntFraction MEMBER shuntFraction )
  Q_PROPERTY(double strongIonDifference MEMBER strongIonDifference )
  Q_PROPERTY(double totalBilirubin MEMBER totalBilirubin )
  Q_PROPERTY(double totalProteinConcentration MEMBER totalProteinConcentration )
  Q_PROPERTY(double venousBloodPH MEMBER venousBloodPH )
  Q_PROPERTY(double volumeFractionNeutralPhospholipidInPlasma MEMBER volumeFractionNeutralPhospholipidInPlasma )
  Q_PROPERTY(double volumeFractionNeutralLipidInPlasma MEMBER volumeFractionNeutralLipidInPlasma )
  Q_PROPERTY(double arterialCarbonDioxidePressure MEMBER arterialCarbonDioxidePressure )
  Q_PROPERTY(double arterialOxygenPressure MEMBER arterialOxygenPressure )
  Q_PROPERTY(double pulmonaryArterialCarbonDioxidePressure MEMBER pulmonaryArterialCarbonDioxidePressure )
  Q_PROPERTY(double pulmonaryArterialOxygenPressure MEMBER pulmonaryArterialOxygenPressure )
  Q_PROPERTY(double pulmonaryVenousCarbonDioxidePressure MEMBER pulmonaryVenousCarbonDioxidePressure )
  Q_PROPERTY(double pulmonaryVenousOxygenPressure MEMBER pulmonaryVenousOxygenPressure )
  Q_PROPERTY(double venousCarbonDioxidePressure MEMBER venousCarbonDioxidePressure )
  Q_PROPERTY(double venousOxygenPressure MEMBER venousOxygenPressure )
  Q_PROPERTY(bool inflammatoryResponse MEMBER inflammatoryResponse )
  Q_PROPERTY(double inflammatoryResponseLocalPathogen MEMBER inflammatoryResponseLocalPathogen )
  Q_PROPERTY(double inflammatoryResponseLocalMacrophage MEMBER inflammatoryResponseLocalMacrophage )
  Q_PROPERTY(double inflammatoryResponseLocalNeutrophil MEMBER inflammatoryResponseLocalNeutrophil )
  Q_PROPERTY(double inflammatoryResponseLocalBarrier MEMBER inflammatoryResponseLocalBarrier )
  Q_PROPERTY(double inflammatoryResponseBloodPathogen MEMBER inflammatoryResponseBloodPathogen )
  Q_PROPERTY(double inflammatoryResponseTrauma MEMBER inflammatoryResponseTrauma )
  Q_PROPERTY(double inflammatoryResponseMacrophageResting MEMBER inflammatoryResponseMacrophageResting )
  Q_PROPERTY(double inflammatoryResponseMacrophageActive MEMBER inflammatoryResponseMacrophageActive )
  Q_PROPERTY(double inflammatoryResponseNeutrophilResting MEMBER inflammatoryResponseNeutrophilResting )
  Q_PROPERTY(double inflammatoryResponseNeutrophilActive MEMBER inflammatoryResponseNeutrophilActive )
  Q_PROPERTY(double inflammatoryResponseInducibleNOSPre MEMBER inflammatoryResponseInducibleNOSPre )
  Q_PROPERTY(double inflammatoryResponseInducibleNOS MEMBER inflammatoryResponseInducibleNOS )
  Q_PROPERTY(double inflammatoryResponseConstitutiveNOS MEMBER inflammatoryResponseConstitutiveNOS )
  Q_PROPERTY(double inflammatoryResponseNitrate MEMBER inflammatoryResponseNitrate )
  Q_PROPERTY(double inflammatoryResponseNitricOxide MEMBER inflammatoryResponseNitricOxide )
  Q_PROPERTY(double inflammatoryResponseTumorNecrosisFactor MEMBER inflammatoryResponseTumorNecrosisFactor )
  Q_PROPERTY(double inflammatoryResponseInterleukin6 MEMBER inflammatoryResponseInterleukin6 )
  Q_PROPERTY(double inflammatoryResponseInterleukin10 MEMBER inflammatoryResponseInterleukin10 )
  Q_PROPERTY(double inflammatoryResponseInterleukin12 MEMBER inflammatoryResponseInterleukin12 )
  Q_PROPERTY(double inflammatoryResponseCatecholamines MEMBER inflammatoryResponseCatecholamines )
  Q_PROPERTY(double inflammatoryResponseTissueIntegrity MEMBER inflammatoryResponseTissueIntegrity )
};