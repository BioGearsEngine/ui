#pragma once
#include <functional>
#include <memory>
#include <vector>
#include <map>

#include <QString>
#include <QtQuick>
#include <QVariant>

#include <biogears/cdm/scenario/SEAction.h>
#include <biogears/container/concurrent_queue.h>
#include <biogears/engine/BioGearsPhysiologyEngine.h>
#include <biogears/engine/Controller/BioGearsEngine.h>
#include <biogears/framework/scmp/scmp_channel.h>
#include <biogears/threading/runnable.h>
#include <biogears/threading/steppable.h>

#include "PatientConditions.h"
#include "PatientMetrics.h"
#include "PatientState.h"
#include "DataRequest.h"
#include "DataRequestModel.h"

namespace biogears {
class SEScalar;
class SEUnitScalar;
}

namespace bio {

class Scenario : public QObject, public biogears::Runnable {

  Q_OBJECT
  Q_PROPERTY(double time READ get_simulation_time NOTIFY timeAdvance)
  Q_PROPERTY(double isRunning   READ is_running   NOTIFY runningToggled)
  Q_PROPERTY(double isPaused    READ is_paused    NOTIFY pausedToggled)
  Q_PROPERTY(double isThrottled READ is_throttled NOTIFY throttledToggled)
public:
  Scenario(QObject* parent = Q_NULLPTR);
  Scenario(QString name, QObject* parent = Q_NULLPTR);
  ~Scenario();

  using ActionQueue = biogears::ConcurrentQueue<std::unique_ptr<biogears::SEAction>>;
  using Channel = biogears::scmp::Channel<ActionQueue>;
  using Source = biogears::scmp::Source<ActionQueue>;

  Q_INVOKABLE QString patient_name();
  Q_INVOKABLE QString environment_name();

  Q_INVOKABLE Scenario& patinet_name(QString);
  Q_INVOKABLE Scenario& environment_name(QString);

  Q_INVOKABLE Scenario& load_patient(QString);


  Q_INVOKABLE double get_simulation_time();

  Q_INVOKABLE void restart(QString patient_file);
  Q_INVOKABLE bool pause_play();
  Q_INVOKABLE void speed_toggle(int speed);
  Q_INVOKABLE void run() final;
  Q_INVOKABLE void stop() final;
  Q_INVOKABLE void join() final;
  Q_INVOKABLE void step();

  bool is_running() const;
  bool is_paused() const;
  bool is_throttled() const;

  public: //Action Factory Interface;
  Q_INVOKABLE void create_hemorrhage_action(QString compartment, double ml_Per_min);
  Q_INVOKABLE void create_asthma_action();
  Q_INVOKABLE void create_substance_infusion_action();
  Q_INVOKABLE void create_burn_action();
  Q_INVOKABLE void create_infection_action();

signals:
  void patientStateChanged(PatientState patientState);
  void patientMetricsChanged(PatientMetrics* metrics);
  void patientConditionsChanged(PatientConditions conditions);
  void timeAdvance();
  void stateChanged();
  void runningToggled(bool isRunning);
  void pausedToggled(bool isPaused);
  void throttledToggled(bool isThrottled);

  protected:
  PatientState get_physiology_state();
  PatientMetrics* get_physiology_metrics();
  PatientConditions get_physiology_conditions();


protected:
  void physiology_thread_main();
  void physiology_thread_step();

private:
  std::thread _thread;
  biogears::Logger _logger;
  std::unique_ptr<biogears::BioGears> _engine;
  Channel _action_queue;

  std::mutex _engine_mutex;

  std::atomic<bool> _running;
  std::atomic<bool> _paused;
  std::atomic<bool> _throttle;

  std::vector<std::pair<biogears::SEScalar const *, std::string>> _data_requests;
  std::unordered_map<std::string, size_t> _data_request_table;

  biogears::SEScalar* _arterialBloodPH;
  biogears::SEScalar* _arterialBloodPHBaseline;
  biogears::SEUnitScalar* _bloodDensity;
  biogears::SEUnitScalar* _bloodSpecificHeat;
  biogears::SEUnitScalar* _bloodUreaNitrogenConcentration;
  biogears::SEScalar* _carbonDioxideSaturation;
  biogears::SEScalar* _carbonMonoxideSaturation;
  biogears::SEScalar* _hematocrit;
  biogears::SEUnitScalar* _hemoglobinContent;
  biogears::SEScalar* _oxygenSaturation;
  biogears::SEUnitScalar* _phosphate;
  biogears::SEUnitScalar* _plasmaVolume;
  biogears::SEScalar* _pulseOximetry;
  biogears::SEUnitScalar* _redBloodCellAcetylcholinesterase;
  biogears::SEUnitScalar* _redBloodCellCount;
  biogears::SEScalar* _shuntFraction;
  biogears::SEUnitScalar* _strongIonDifference;
  biogears::SEUnitScalar* _totalBilirubin;
  biogears::SEUnitScalar* _totalProteinConcentration;
  biogears::SEScalar* _venousBloodPH;
  biogears::SEScalar* _volumeFractionNeutralPhospholipidInPlasma;
  biogears::SEScalar* _volumeFractionNeutralLipidInPlasma;
  biogears::SEUnitScalar* _arterialCarbonDioxidePressure;
  biogears::SEUnitScalar* _arterialOxygenPressure;
  biogears::SEUnitScalar* _pulmonaryArterialCarbonDioxidePressure;
  biogears::SEUnitScalar* _pulmonaryArterialOxygenPressure;
  biogears::SEUnitScalar* _pulmonaryVenousCarbonDioxidePressure;
  biogears::SEUnitScalar* _pulmonaryVenousOxygenPressure;
  biogears::SEUnitScalar* _venousCarbonDioxidePressure;
  biogears::SEUnitScalar* _venousOxygenPressure;
  bool _inflammatoryResponse;

  biogears::SEScalar* _inflammatoryResponseLocalPathogen;
  biogears::SEScalar* _inflammatoryResponseLocalMacrophage;
  biogears::SEScalar* _inflammatoryResponseLocalNeutrophil;
  biogears::SEScalar* _inflammatoryResponseLocalBarrier;
  biogears::SEScalar* _inflammatoryResponseBloodPathogen;
  biogears::SEScalar* _inflammatoryResponseTrauma;
  biogears::SEScalar* _inflammatoryResponseMacrophageResting;
  biogears::SEScalar* _inflammatoryResponseMacrophageActive;
  biogears::SEScalar* _inflammatoryResponseNeutrophilResting;
  biogears::SEScalar* _inflammatoryResponseNeutrophilActive;
  biogears::SEScalar* _inflammatoryResponseInducibleNOSPre;
  biogears::SEScalar* _inflammatoryResponseInducibleNOS;
  biogears::SEScalar* _inflammatoryResponseConstitutiveNOS;
  biogears::SEScalar* _inflammatoryResponseNitrate;
  biogears::SEScalar* _inflammatoryResponseNitricOxide;
  biogears::SEScalar* _inflammatoryResponseTumorNecrosisFactor;
  biogears::SEScalar* _inflammatoryResponseInterleukin6;
  biogears::SEScalar* _inflammatoryResponseInterleukin10;
  biogears::SEScalar* _inflammatoryResponseInterleukin12;
  biogears::SEScalar* _inflammatoryResponseCatecholamines;
  biogears::SEScalar* _inflammatoryResponseTissueIntegrity;

  biogears::SEUnitScalar* _arterialPressure;
  biogears::SEUnitScalar* _bloodVolume;
  biogears::SEUnitScalar* _cardiacIndex;
  biogears::SEUnitScalar* _cardiacOutput;
  biogears::SEUnitScalar* _centralVenousPressure;
  biogears::SEUnitScalar* _cerebralBloodFlow;
  biogears::SEUnitScalar* _cerebralPerfusionPressure;
  biogears::SEUnitScalar* _diastolicArterialPressure;
  biogears::SEScalar* _heartEjectionFraction;
  biogears::SEUnitScalar* _heartRate;
  biogears::SEUnitScalar* _heartStrokeVolume;
  biogears::SEUnitScalar* _intracranialPressure;
  biogears::SEUnitScalar* _meanArterialPressure;
  biogears::SEUnitScalar* _meanArterialCarbonDioxidePartialPressure;
  biogears::SEUnitScalar* _meanArterialCarbonDioxidePartialPressureDelta;
  biogears::SEUnitScalar* _meanCentralVenousPressure;
  biogears::SEUnitScalar* _meanSkinFlow;
  biogears::SEUnitScalar* _pulmonaryArterialPressure;
  biogears::SEUnitScalar* _pulmonaryCapillariesWedgePressure;
  biogears::SEUnitScalar* _pulmonaryDiastolicArterialPressure;
  biogears::SEUnitScalar* _pulmonaryMeanArterialPressure;
  biogears::SEUnitScalar* _pulmonaryMeanCapillaryFlow;
  biogears::SEUnitScalar* _pulmonaryMeanShuntFlow;
  biogears::SEUnitScalar* _pulmonarySystolicArterialPressure;
  biogears::SEUnitScalar* _pulmonaryVascularResistance;
  biogears::SEUnitScalar* _pulmonaryVascularResistanceIndex;
  biogears::SEUnitScalar* _pulsePressure;
  biogears::SEUnitScalar* _systemicVascularResistance;
  biogears::SEUnitScalar* _systolicArterialPressure;

  biogears::SEScalar* _bronchodilationLevel;
  biogears::SEUnitScalar* _heartRateChange;
  biogears::SEUnitScalar* _meanBloodPressureChange;
  biogears::SEScalar* _neuromuscularBlockLevel;
  biogears::SEUnitScalar* _pulsePressureChange;
  biogears::SEUnitScalar* _respirationRateChange;
  biogears::SEScalar* _sedationLevel;
  biogears::SEUnitScalar* _tidalVolumeChange;
  biogears::SEScalar* _tubularPermeabilityChange;
  biogears::SEScalar* _centralNervousResponse;

  biogears::SEUnitScalar* _insulinSynthesisRate;
  biogears::SEUnitScalar* _glucagonSynthesisRate;

  biogears::SEScalar* _achievedExerciseLevel;
  biogears::SEUnitScalar* _chlorideLostToSweat;
  biogears::SEUnitScalar* _coreTemperature;
  biogears::SEUnitScalar* _creatinineProductionRate;
  biogears::SEUnitScalar* _exerciseMeanArterialPressureDelta;
  biogears::SEScalar* _fatigueLevel;
  biogears::SEUnitScalar* _lactateProductionRate;
  biogears::SEUnitScalar* _potassiumLostToSweat;
  biogears::SEUnitScalar* _skinTemperature;
  biogears::SEUnitScalar* _sodiumLostToSweat;
  biogears::SEUnitScalar* _sweatRate;
  biogears::SEScalar* _totalMetabolicRate;
  biogears::SEScalar* _totalWorkRateLevel;

  biogears::SEUnitScalar* _chymeAbsorptionRate;
  biogears::SEUnitScalar* _stomachContents_calcium;
  biogears::SEUnitScalar* _stomachContents_carbohydrates;
  biogears::SEUnitScalar* _stomachContents_carbohydrateDigationRate;
  biogears::SEUnitScalar* _stomachContents_fat;
  biogears::SEUnitScalar* _stomachContents_fatDigtationRate;
  biogears::SEUnitScalar* _stomachContents_protien;
  biogears::SEUnitScalar* _stomachContents_protienDigtationRate;
  biogears::SEUnitScalar* _stomachContents_sodium;
  biogears::SEUnitScalar* _stomachContents_water;

  biogears::SEUnitScalar* _hepaticGluconeogenesisRate;
  biogears::SEUnitScalar* _ketoneproductionRate;

  biogears::SEScalar* _baroreceptorHeartRateScale;
  biogears::SEScalar* _baroreceptorHeartElastanceScale;
  biogears::SEScalar* _baroreceptorResistanceScale;
  biogears::SEScalar* _baroreceptorComplianceScale;
  biogears::SEScalar* _chemoreceptorHeartRateScale;
  biogears::SEScalar* _chemoreceptorHeartElastanceScale;
  biogears::SEScalar* _painVisualAnalogueScale;

  //TODO: Implement Pupillary Response  ReactivityModifier  ShapeModifier  SizeModifier;
  biogears::SEUnitScalar* _leftEyePupillaryResponse;
  biogears::SEUnitScalar* _rightEyePupillaryResponse;

  //Renal
  biogears::SEUnitScalar* _glomerularFiltrationRate;
  biogears::SEScalar* _filtrationFraction;
  biogears::SEUnitScalar* _leftAfferentArterioleResistance;
  biogears::SEUnitScalar* _leftBowmansCapsulesHydrostaticPressure;
  biogears::SEUnitScalar* _leftBowmansCapsulesOsmoticPressure;
  biogears::SEUnitScalar* _leftEfferentArterioleResistance;
  biogears::SEUnitScalar* _leftGlomerularCapillariesHydrostaticPressure;
  biogears::SEUnitScalar* _leftGlomerularCapillariesOsmoticPressure;
  biogears::SEUnitScalar* _leftGlomerularFiltrationCoefficient;
  biogears::SEUnitScalar* _leftGlomerularFiltrationRate;
  biogears::SEUnitScalar* _leftGlomerularFiltrationSurfaceArea;
  biogears::SEUnitScalar* _leftGlomerularFluidPermeability;
  biogears::SEScalar* _leftFiltrationFraction;
  biogears::SEUnitScalar* _leftNetFiltrationPressure;
  biogears::SEUnitScalar* _leftNetReabsorptionPressure;
  biogears::SEUnitScalar* _leftPeritubularCapillariesHydrostaticPressure;
  biogears::SEUnitScalar* _leftPeritubularCapillariesOsmoticPressure;
  biogears::SEUnitScalar* _leftReabsorptionFiltrationCoefficient;
  biogears::SEUnitScalar* _leftReabsorptionRate;
  biogears::SEUnitScalar* _leftTubularReabsorptionFiltrationSurfaceArea;
  biogears::SEUnitScalar* _leftTubularReabsorptionFluidPermeability;
  biogears::SEUnitScalar* _leftTubularHydrostaticPressure;
  biogears::SEUnitScalar* _leftTubularOsmoticPressure;
  biogears::SEUnitScalar* _renalBloodFlow;
  biogears::SEUnitScalar* _renalPlasmaFlow;
  biogears::SEUnitScalar* _renalVascularResistance;
  biogears::SEUnitScalar* _rightAfferentArterioleResistance;
  biogears::SEUnitScalar* _rightBowmansCapsulesHydrostaticPressure;
  biogears::SEUnitScalar* _rightBowmansCapsulesOsmoticPressure;
  biogears::SEUnitScalar* _rightEfferentArterioleResistance;
  biogears::SEUnitScalar* _rightGlomerularCapillariesHydrostaticPressure;
  biogears::SEUnitScalar* _rightGlomerularCapillariesOsmoticPressure;
  biogears::SEUnitScalar* _rightGlomerularFiltrationCoefficient;
  biogears::SEUnitScalar* _rightGlomerularFiltrationRate;
  biogears::SEUnitScalar* _rightGlomerularFiltrationSurfaceArea;
  biogears::SEUnitScalar* _rightGlomerularFluidPermeability;
  biogears::SEScalar* _rightFiltrationFraction;
  biogears::SEUnitScalar* _rightNetFiltrationPressure;
  biogears::SEUnitScalar* _rightNetReabsorptionPressure;
  biogears::SEUnitScalar* _rightPeritubularCapillariesHydrostaticPressure;
  biogears::SEUnitScalar* _rightPeritubularCapillariesOsmoticPressure;
  biogears::SEUnitScalar* _rightReabsorptionFiltrationCoefficient;
  biogears::SEUnitScalar* _rightReabsorptionRate;
  biogears::SEUnitScalar* _rightTubularReabsorptionFiltrationSurfaceArea;
  biogears::SEUnitScalar* _rightTubularReabsorptionFluidPermeability;
  biogears::SEUnitScalar* _rightTubularHydrostaticPressure;
  biogears::SEUnitScalar* _rightTubularOsmoticPressure;
  biogears::SEUnitScalar* _urinationRate;
  biogears::SEUnitScalar* _urineOsmolality;
  biogears::SEUnitScalar* _urineOsmolarity;
  biogears::SEUnitScalar* _urineProductionRate;
  biogears::SEUnitScalar* _meanUrineOutput;
  biogears::SEScalar* _urineSpecificGravity;
  biogears::SEUnitScalar* _urineVolume;
  biogears::SEUnitScalar* _urineUreaNitrogenConcentration;
  //Respiratory
  biogears::SEUnitScalar* _alveolarArterialGradient;
  biogears::SEUnitScalar* _carricoIndex;
  biogears::SEScalar* _endTidalCarbonDioxideFraction;
  biogears::SEUnitScalar* _endTidalCarbonDioxidePressure;
  biogears::SEUnitScalar* _expiratoryFlow;
  biogears::SEScalar* _inspiratoryExpiratoryRatio;
  biogears::SEUnitScalar* _inspiratoryFlow;
  biogears::SEUnitScalar* _pulmonaryCompliance;
  biogears::SEUnitScalar* _pulmonaryResistance;
  biogears::SEUnitScalar* _respirationDriverPressure;
  biogears::SEUnitScalar* _respirationMusclePressure;
  biogears::SEUnitScalar* _respirationRate;
  biogears::SEScalar* _specificVentilation;
  biogears::SEUnitScalar* _targetPulmonaryVentilation;
  biogears::SEUnitScalar* _tidalVolume;
  biogears::SEUnitScalar* _totalAlveolarVentilation;
  biogears::SEUnitScalar* _totalDeadSpaceVentilation;
  biogears::SEUnitScalar* _totalLungVolume;
  biogears::SEUnitScalar* _totalPulmonaryVentilation;
  biogears::SEUnitScalar* _transpulmonaryPressure;

  //Tissue
  biogears::SEUnitScalar* _carbonDioxideProductionRate;
  biogears::SEScalar* _dehydrationFraction;
  biogears::SEUnitScalar* _extracellularFluidVolume;
  biogears::SEUnitScalar* _extravascularFluidVolume;
  biogears::SEScalar* _intracellularFluidPH;
  biogears::SEUnitScalar* _intracellularFluidVolume;
  biogears::SEUnitScalar* _totalBodyFluidVolume;
  biogears::SEUnitScalar* _oxygenConsumptionRate;
  biogears::SEScalar* _respiratoryExchangeRatio;
  biogears::SEUnitScalar* _liverInsulinSetPoint;
  biogears::SEUnitScalar* _liverGlucagonSetPoint;
  biogears::SEUnitScalar* _muscleInsulinSetPoint;
  biogears::SEUnitScalar* _muscleGlucagonSetPoint;
  biogears::SEUnitScalar* _fatInsulinSetPoint;
  biogears::SEUnitScalar* _fatGlucagonSetPoint;
  biogears::SEUnitScalar* _liverGlycogen;
  biogears::SEUnitScalar* _muscleGlycogen;
  biogears::SEUnitScalar* _storedProtein;
  biogears::SEUnitScalar* _storedFat;
};

}
