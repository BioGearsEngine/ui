#include "Scenario.h"

#include <cmath>
#include <exception>

#include "PatientConditions.h"
#include "PatientMetrics.h"
#include "PatientState.h"

//#include <biogears/version.h>
#include <biogears/cdm/patient/SEPatient.h>
#include <biogears/cdm/properties/SEScalar.h>
#include <biogears/cdm/properties/SEScalarTime.h>
#include <biogears/cdm/properties/SEScalarTypes.h>
#include <biogears/cdm/properties/SEUnitScalar.h>
#include <biogears/cdm/system/SESystem.h>
#include <biogears/cdm/system/environment/SEEnvironment.h>
#include <biogears/cdm/system/environment/SEEnvironmentalConditions.h>
#include <biogears/cdm/system/equipment/ElectroCardioGram/SEElectroCardioGram.h>
#include <biogears/container/Tree.tci.h>
#include <biogears/container/concurrent_queue.tci.h>
#include <biogears/engine/BioGearsPhysiologyEngine.h>
#include <biogears/framework/scmp/scmp_channel.tci.h>

#include <biogears/cdm/scenario/SEAction.h>
#include <chrono>
namespace bio {
Scenario::Scenario(QObject* parent)
  : Scenario("biogears_default", parent)
{
}
Scenario::Scenario(QString name, QObject* parent)
  : QObject(parent)
  , _thread()
  , _engine_mutex()
  , _logger(name.toStdString() + ".log")
  , _engine(std::make_unique<biogears::BioGearsEngine>(&_logger))
  , _action_queue()
  , _running(false)
  , _paused(true)
  , _throttle(true)
{
  _engine->GetPatient().SetName(name.toStdString());
}
//-------------------------------------------------------------------------------
Scenario::~Scenario()
{
  stop();
  if (_thread.joinable()) {
    _thread.join();
  }
}
//-------------------------------------------------------------------------------
void Scenario::restart(QString patient_file)
{
  _paused = true;
  emit pausedToggled(_paused);
  _throttle = true;
  emit throttledToggled(_throttle);
  load_patient(patient_file);
}
//-------------------------------------------------------------------------------
bool Scenario::pause_play()
{

  _paused = !_paused;
  emit pausedToggled(_paused);
  return _paused;
}
//-------------------------------------------------------------------------------
void Scenario::speed_toggle(int speed)
{
  switch (speed) {
  case 0:
  case 1:
    _throttle = true;
    break;
  case 2:
  default:
    _throttle = false;
    break;
  }
  emit throttledToggled(_throttle);
}
//-------------------------------------------------------------------------------
void Scenario::run()
{
  if (!_thread.joinable() && !_running) {
    _running = true;
    emit runningToggled(_running);
    _paused = false;
    emit pausedToggled(_paused);
    _throttle = true;
    emit throttledToggled(_throttle);
    _thread = std::thread(&Scenario::physiology_thread_main, this);
  }
}
//-----------------   --------------------------------------------------------------
void Scenario::stop()
{
  _running = false;
  emit runningToggled(_running);
  _paused = true;
  emit pausedToggled(_paused);
  _throttle = false;
  emit throttledToggled(_throttle);
}
//-------------------------------------------------------------------------------
void Scenario::join()
{
  if (_thread.joinable()) {
    _thread.join();
  }
}
//-------------------------------------------------------------------------------
void Scenario::step()
{
  physiology_thread_step();
}
//-------------------------------------------------------------------------------
bool Scenario::is_running() const
{
  return _running;
}
//-------------------------------------------------------------------------------
bool Scenario::is_paused() const
{
  return _paused;
}
//-------------------------------------------------------------------------------
bool Scenario::is_throttled() const
{
  return _throttle;
}
//-------------------------------------------------------------------------------
QString Scenario::patient_name()
{
  return _engine->GetPatient().GetName_cStr();
}
//--------      -----------------------------------------------------------------
QString Scenario::environment_name()
{
  return _engine->GetEnvironment().GetName_cStr();
}
//-------------------------------------------------------------------------------
Scenario& Scenario::patient_name(QString name)
{
  _engine->GetPatient().SetName(name.toStdString());
  return *this;
}
//-------------------------------------------------------------------------------
Scenario& Scenario::environment_name(QString name)
{
  _engine->GetEnvironment().SetName(name.toStdString());
  return *this;
}
//-------------------------------------------------------------------------------
Scenario& Scenario::load_patient(QString file)
{
  _drugs_list.clear();
  _compounds_list.clear();
  _transfusions_list.clear();
  parseSubstancesToLists();

  auto path = file.toStdString();
  if (!QFileInfo::exists(file)) {
    path = "states/" + path;
    if (!QFileInfo::exists("states/" + file)) {
      throw std::runtime_error("Unable to locate " + file.toStdString());
    }
  }

  _engine_mutex.lock(); //< I ran in to some -O2 issues when using an std::lock_guard in msvc
  _engine = std::make_unique<biogears::BioGearsEngine>(&_logger);
  if (dynamic_cast<biogears::BioGearsEngine*>(_engine.get())->LoadState(path)) {

    _data_request_table.clear();
    _data_requests.clear();
    auto engine = dynamic_cast<biogears::BioGearsEngine*>(_engine.get());
    auto bootstrap_physiology_request = [&, engine](const biogears::Tree<const char*>& tree, const auto& lambda, biogears::SESystem* system = nullptr, std::string prefix = "", biogears::Tree<const char*> const* parent = nullptr) -> void {
      //qInfo() << (prefix + tree.value()).c_str();

      if (system) {
        using namespace std::string_literals;
        std::string key = tree.value();
        biogears::SEScalar const* scalar = system->GetScalar(key);

        if (nullptr == scalar) {
          //Handles hypenated request
          key = parent->value() + "-"s + tree.value();
          scalar = system->GetScalar(key);
        }

        if (auto unitScalar = dynamic_cast<biogears::SEUnitScalar const*>(scalar)) {
          _data_request_table[prefix + tree.value()] = _data_requests.size();
          if (unitScalar->GetUnit()) {
            _data_requests.emplace_back(unitScalar, unitScalar->GetUnit()->GetString());
          } else {
            _data_requests.emplace_back(unitScalar, "");
          }
        } else if (scalar) {

          _data_request_table[prefix + tree.value()] = _data_requests.size();
          _data_requests.emplace_back(scalar, "unitless");
        }
      } else {
        using namespace std::string_literals;
        if ("Environment"s == tree.value()) {
          system = &_engine->GetEnvironment();
        } else if ("BloodChemistry"s == tree.value()) {
          system = &_engine->GetBloodChemistry();
        } else if ("Cardiovascular"s == tree.value()) {
          system = &_engine->GetCardiovascular();
        } else if ("Drugs"s == tree.value()) {
          system = &_engine->GetDrugs();
        } else if ("Endocrine"s == tree.value()) {
          system = &_engine->GetEndocrine();
        } else if ("Energy"s == tree.value()) {
          system = &_engine->GetEnergy();
        } else if ("Gastrointestinal"s == tree.value()) {
          system = &_engine->GetGastrointestinal();
        } else if ("Hepatic"s == tree.value()) {
          system = &_engine->GetHepatic();
        } else if ("Nervous"s == tree.value()) {
          system = &_engine->GetNervous();
        } else if ("Renal"s == tree.value()) {
          system = &_engine->GetRenal();
        } else if ("Respiratory"s == tree.value()) {
          system = &_engine->GetRespiratory();
        } else if ("Tissue"s == tree.value()) {
          system = &_engine->GetTissue();
        } else if ("AnesthesiaMachine"s == tree.value()) {
          system = &_engine->GetAnesthesiaMachine();
        } else if ("ECG"s == tree.value()) {
          system = &_engine->GetECG();
        } else if ("Inhaler"s == tree.value()) {
          system = &_engine->GetInhaler();
        }
      }
      if (system) {
        prefix = prefix + tree.value() + "-";
      }
      for (auto& node : tree) {
        lambda(node, lambda, system, prefix, &tree);
      };
    };

    bootstrap_physiology_request(engine->GetDataRequestGraph(), bootstrap_physiology_request);

    //for (auto request : _data_request_table) {
    //  try {
    //    qDebug() << QString("(%1, %2) = %3 %4\n")
    //                   .arg(request.first.c_str())
    //                   .arg(request.second)
    //                   .arg(_data_requests[request.second].first->GetValue())
    //                   .arg(_data_requests[request.second].second.c_str());
    //  } catch (biogears::CommonDataModelException ex) {
    //    qDebug() << QString("(%1, %2) = NaN N/A\n").arg(request.first.c_str()).arg(request.second);
    //  }
    //}

    auto& bloodChemistry = _engine->GetBloodChemistry();
    _arterialBloodPH = (bloodChemistry.HasArterialBloodPH()) ? &bloodChemistry.GetArterialBloodPH() : nullptr;
    _arterialBloodPHBaseline = (bloodChemistry.HasArterialBloodPHBaseline()) ? &bloodChemistry.GetArterialBloodPHBaseline() : nullptr;
    _bloodDensity = (bloodChemistry.HasBloodDensity()) ? &bloodChemistry.GetBloodDensity() : nullptr;
    _bloodSpecificHeat = (bloodChemistry.HasBloodSpecificHeat()) ? &bloodChemistry.GetBloodSpecificHeat() : nullptr;
    _bloodUreaNitrogenConcentration = (bloodChemistry.HasBloodUreaNitrogenConcentration()) ? &bloodChemistry.GetBloodUreaNitrogenConcentration() : nullptr;
    _carbonDioxideSaturation = (bloodChemistry.HasCarbonDioxideSaturation()) ? &bloodChemistry.GetCarbonDioxideSaturation() : nullptr;
    _carbonMonoxideSaturation = (bloodChemistry.HasCarbonMonoxideSaturation()) ? &bloodChemistry.GetCarbonMonoxideSaturation() : nullptr;
    _hematocrit = (bloodChemistry.HasHematocrit()) ? &bloodChemistry.GetHematocrit() : nullptr;
    _hemoglobinContent = (bloodChemistry.HasHemoglobinContent()) ? &bloodChemistry.GetHemoglobinContent() : nullptr;
    _oxygenSaturation = (bloodChemistry.HasOxygenSaturation()) ? &bloodChemistry.GetOxygenSaturation() : nullptr;
    _phosphate = (bloodChemistry.HasPhosphate()) ? &bloodChemistry.GetPhosphate() : nullptr;
    _plasmaVolume = (bloodChemistry.HasPlasmaVolume()) ? &bloodChemistry.GetPlasmaVolume() : nullptr;
    _pulseOximetry = (bloodChemistry.HasPulseOximetry()) ? &bloodChemistry.GetPulseOximetry() : nullptr;
    _redBloodCellAcetylcholinesterase = (bloodChemistry.HasRedBloodCellAcetylcholinesterase()) ? &bloodChemistry.GetRedBloodCellAcetylcholinesterase() : nullptr;
    _redBloodCellCount = (bloodChemistry.HasRedBloodCellCount()) ? &bloodChemistry.GetRedBloodCellCount() : nullptr;
    _shuntFraction = (bloodChemistry.HasShuntFraction()) ? &bloodChemistry.GetShuntFraction() : nullptr;
    _strongIonDifference = (bloodChemistry.HasStrongIonDifference()) ? &bloodChemistry.GetStrongIonDifference() : nullptr;
    _totalBilirubin = (bloodChemistry.HasTotalBilirubin()) ? &bloodChemistry.GetTotalBilirubin() : nullptr;
    _totalProteinConcentration = (bloodChemistry.HasTotalProteinConcentration()) ? &bloodChemistry.GetTotalProteinConcentration() : nullptr;
    _venousBloodPH = (bloodChemistry.HasVenousBloodPH()) ? &bloodChemistry.GetVenousBloodPH() : nullptr;
    _volumeFractionNeutralPhospholipidInPlasma = (bloodChemistry.HasVolumeFractionNeutralPhospholipidInPlasma()) ? &bloodChemistry.GetVolumeFractionNeutralPhospholipidInPlasma() : nullptr;
    _volumeFractionNeutralLipidInPlasma = (bloodChemistry.HasVolumeFractionNeutralLipidInPlasma()) ? &bloodChemistry.GetVolumeFractionNeutralLipidInPlasma() : nullptr;
    _arterialCarbonDioxidePressure = (bloodChemistry.HasArterialCarbonDioxidePressure()) ? &bloodChemistry.GetArterialCarbonDioxidePressure() : nullptr;
    _arterialOxygenPressure = (bloodChemistry.HasArterialOxygenPressure()) ? &bloodChemistry.GetArterialOxygenPressure() : nullptr;
    _pulmonaryArterialCarbonDioxidePressure = (bloodChemistry.HasPulmonaryArterialCarbonDioxidePressure()) ? &bloodChemistry.GetPulmonaryArterialCarbonDioxidePressure() : nullptr;
    _pulmonaryArterialOxygenPressure = (bloodChemistry.HasPulmonaryArterialOxygenPressure()) ? &bloodChemistry.GetPulmonaryArterialOxygenPressure() : nullptr;
    _pulmonaryVenousCarbonDioxidePressure = (bloodChemistry.HasPulmonaryVenousCarbonDioxidePressure()) ? &bloodChemistry.GetPulmonaryVenousCarbonDioxidePressure() : nullptr;
    _pulmonaryVenousOxygenPressure = (bloodChemistry.HasPulmonaryVenousOxygenPressure()) ? &bloodChemistry.GetPulmonaryVenousOxygenPressure() : nullptr;
    _venousCarbonDioxidePressure = (bloodChemistry.HasVenousCarbonDioxidePressure()) ? &bloodChemistry.GetVenousCarbonDioxidePressure() : nullptr;
    _venousOxygenPressure = (bloodChemistry.HasVenousOxygenPressure()) ? &bloodChemistry.GetVenousOxygenPressure() : nullptr;
    _inflammatoryResponse = bloodChemistry.HasInflammatoryResponse();

    auto& inflamatoryResponse = bloodChemistry.GetInflammatoryResponse();
    _inflammatoryResponseLocalPathogen = (inflamatoryResponse.HasLocalPathogen()) ? &inflamatoryResponse.GetLocalPathogen() : nullptr;
    _inflammatoryResponseLocalMacrophage = (inflamatoryResponse.HasLocalMacrophage()) ? &inflamatoryResponse.GetLocalMacrophage() : nullptr;
    _inflammatoryResponseLocalNeutrophil = (inflamatoryResponse.HasLocalNeutrophil()) ? &inflamatoryResponse.GetLocalNeutrophil() : nullptr;
    _inflammatoryResponseLocalBarrier = (inflamatoryResponse.HasLocalBarrier()) ? &inflamatoryResponse.GetLocalBarrier() : nullptr;
    _inflammatoryResponseBloodPathogen = (inflamatoryResponse.HasBloodPathogen()) ? &inflamatoryResponse.GetBloodPathogen() : nullptr;
    _inflammatoryResponseTrauma = (inflamatoryResponse.HasTrauma()) ? &inflamatoryResponse.GetTrauma() : nullptr;
    _inflammatoryResponseMacrophageResting = (inflamatoryResponse.HasMacrophageResting()) ? &inflamatoryResponse.GetMacrophageResting() : nullptr;
    _inflammatoryResponseMacrophageActive = (inflamatoryResponse.HasMacrophageActive()) ? &inflamatoryResponse.GetMacrophageActive() : nullptr;
    _inflammatoryResponseNeutrophilResting = (inflamatoryResponse.HasNeutrophilResting()) ? &inflamatoryResponse.GetNeutrophilResting() : nullptr;
    _inflammatoryResponseNeutrophilActive = (inflamatoryResponse.HasNeutrophilActive()) ? &inflamatoryResponse.GetNeutrophilActive() : nullptr;
    _inflammatoryResponseInducibleNOSPre = (inflamatoryResponse.HasInducibleNOSPre()) ? &inflamatoryResponse.GetInducibleNOSPre() : nullptr;
    _inflammatoryResponseInducibleNOS = (inflamatoryResponse.HasInducibleNOS()) ? &inflamatoryResponse.GetInducibleNOS() : nullptr;
    _inflammatoryResponseConstitutiveNOS = (inflamatoryResponse.HasConstitutiveNOS()) ? &inflamatoryResponse.GetConstitutiveNOS() : nullptr;
    _inflammatoryResponseNitrate = (inflamatoryResponse.HasNitrate()) ? &inflamatoryResponse.GetNitrate() : nullptr;
    _inflammatoryResponseNitricOxide = (inflamatoryResponse.HasNitricOxide()) ? &inflamatoryResponse.GetNitricOxide() : nullptr;
    _inflammatoryResponseTumorNecrosisFactor = (inflamatoryResponse.HasTumorNecrosisFactor()) ? &inflamatoryResponse.GetTumorNecrosisFactor() : nullptr;
    _inflammatoryResponseInterleukin6 = (inflamatoryResponse.HasInterleukin6()) ? &inflamatoryResponse.GetInterleukin6() : nullptr;
    _inflammatoryResponseInterleukin10 = (inflamatoryResponse.HasInterleukin10()) ? &inflamatoryResponse.GetInterleukin10() : nullptr;
    _inflammatoryResponseInterleukin12 = (inflamatoryResponse.HasInterleukin12()) ? &inflamatoryResponse.GetInterleukin12() : nullptr;
    _inflammatoryResponseCatecholamines = (inflamatoryResponse.HasCatecholamines()) ? &inflamatoryResponse.GetCatecholamines() : nullptr;
    _inflammatoryResponseTissueIntegrity = (inflamatoryResponse.HasTissueIntegrity()) ? &inflamatoryResponse.GetTissueIntegrity() : nullptr;

    auto& cardiovascular = _engine->GetCardiovascular();
    _arterialPressure = (cardiovascular.HasArterialPressure()) ? &cardiovascular.GetArterialPressure() : nullptr;
    _bloodVolume = (cardiovascular.HasBloodVolume()) ? &cardiovascular.GetBloodVolume() : nullptr;
    _cardiacIndex = (cardiovascular.HasCardiacIndex()) ? &cardiovascular.GetCardiacIndex() : nullptr;
    _cardiacOutput = (cardiovascular.HasCardiacOutput()) ? &cardiovascular.GetCardiacOutput() : nullptr;
    _centralVenousPressure = (cardiovascular.HasCentralVenousPressure()) ? &cardiovascular.GetCentralVenousPressure() : nullptr;
    _cerebralBloodFlow = (cardiovascular.HasCerebralBloodFlow()) ? &cardiovascular.GetCerebralBloodFlow() : nullptr;
    _cerebralPerfusionPressure = (cardiovascular.HasCerebralPerfusionPressure()) ? &cardiovascular.GetCerebralPerfusionPressure() : nullptr;
    _diastolicArterialPressure = (cardiovascular.HasDiastolicArterialPressure()) ? &cardiovascular.GetDiastolicArterialPressure() : nullptr;
    _heartEjectionFraction = (cardiovascular.HasHeartEjectionFraction()) ? &cardiovascular.GetHeartEjectionFraction() : nullptr;
    _heartRate = (cardiovascular.HasHeartRate()) ? &cardiovascular.GetHeartRate() : nullptr;
    _heartStrokeVolume = (cardiovascular.HasHeartStrokeVolume()) ? &cardiovascular.GetHeartStrokeVolume() : nullptr;
    _intracranialPressure = (cardiovascular.HasIntracranialPressure()) ? &cardiovascular.GetIntracranialPressure() : nullptr;
    _meanArterialPressure = (cardiovascular.HasMeanArterialPressure()) ? &cardiovascular.GetMeanArterialPressure() : nullptr;
    _meanArterialCarbonDioxidePartialPressure = (cardiovascular.HasMeanArterialCarbonDioxidePartialPressure()) ? &cardiovascular.GetMeanArterialCarbonDioxidePartialPressure() : nullptr;
    _meanArterialCarbonDioxidePartialPressureDelta = (cardiovascular.HasMeanArterialCarbonDioxidePartialPressureDelta()) ? &cardiovascular.GetMeanArterialCarbonDioxidePartialPressureDelta() : nullptr;
    _meanCentralVenousPressure = (cardiovascular.HasMeanCentralVenousPressure()) ? &cardiovascular.GetMeanCentralVenousPressure() : nullptr;
    _meanSkinFlow = (cardiovascular.HasMeanSkinFlow()) ? &cardiovascular.GetMeanSkinFlow() : nullptr;
    _pulmonaryArterialPressure = (cardiovascular.HasPulmonaryArterialPressure()) ? &cardiovascular.GetPulmonaryArterialPressure() : nullptr;
    _pulmonaryCapillariesWedgePressure = (cardiovascular.HasPulmonaryCapillariesWedgePressure()) ? &cardiovascular.GetPulmonaryCapillariesWedgePressure() : nullptr;
    _pulmonaryDiastolicArterialPressure = (cardiovascular.HasPulmonaryDiastolicArterialPressure()) ? &cardiovascular.GetPulmonaryDiastolicArterialPressure() : nullptr;
    _pulmonaryMeanArterialPressure = (cardiovascular.HasPulmonaryMeanArterialPressure()) ? &cardiovascular.GetPulmonaryMeanArterialPressure() : nullptr;
    _pulmonaryMeanCapillaryFlow = (cardiovascular.HasPulmonaryMeanArterialPressure()) ? &cardiovascular.GetPulmonaryMeanArterialPressure() : nullptr;
    _pulmonaryMeanShuntFlow = (cardiovascular.HasPulmonaryMeanShuntFlow()) ? &cardiovascular.GetPulmonaryMeanShuntFlow() : nullptr;
    _pulmonarySystolicArterialPressure = (cardiovascular.HasPulmonarySystolicArterialPressure()) ? &cardiovascular.GetPulmonarySystolicArterialPressure() : nullptr;
    _pulmonaryVascularResistance = (cardiovascular.HasPulmonaryVascularResistance()) ? &cardiovascular.GetPulmonaryVascularResistance() : nullptr;
    _pulmonaryVascularResistanceIndex = (cardiovascular.HasPulmonaryVascularResistanceIndex()) ? &cardiovascular.GetPulmonaryVascularResistanceIndex() : nullptr;
    _pulsePressure = (cardiovascular.HasPulsePressure()) ? &cardiovascular.GetPulsePressure() : nullptr;
    _systemicVascularResistance = (cardiovascular.HasSystemicVascularResistance()) ? &cardiovascular.GetSystemicVascularResistance() : nullptr;
    _systolicArterialPressure = (cardiovascular.HasSystolicArterialPressure()) ? &cardiovascular.GetSystolicArterialPressure() : nullptr;

    auto& drugs = _engine->GetDrugs();
    _bronchodilationLevel = (drugs.HasBronchodilationLevel()) ? &drugs.GetBronchodilationLevel() : nullptr;
    _heartRateChange = (drugs.HasHeartRateChange()) ? &drugs.GetHeartRateChange() : nullptr;
    _meanBloodPressureChange = (drugs.HasMeanBloodPressureChange()) ? &drugs.GetMeanBloodPressureChange() : nullptr;
    _neuromuscularBlockLevel = (drugs.HasNeuromuscularBlockLevel()) ? &drugs.GetNeuromuscularBlockLevel() : nullptr;
    _pulsePressureChange = (drugs.HasPulsePressureChange()) ? &drugs.GetPulsePressureChange() : nullptr;
    _respirationRateChange = (drugs.HasRespirationRateChange()) ? &drugs.GetRespirationRateChange() : nullptr;
    _sedationLevel = (drugs.HasSedationLevel()) ? &drugs.GetSedationLevel() : nullptr;
    _tidalVolumeChange = (drugs.HasTidalVolumeChange()) ? &drugs.GetTidalVolumeChange() : nullptr;
    _tubularPermeabilityChange = (drugs.HasTubularPermeabilityChange()) ? &drugs.GetTubularPermeabilityChange() : nullptr;
    _centralNervousResponse = (drugs.HasCentralNervousResponse()) ? &drugs.GetCentralNervousResponse() : nullptr;

    auto& endocrine = _engine->GetEndocrine();
    _insulinSynthesisRate = (endocrine.HasInsulinSynthesisRate()) ? &endocrine.GetInsulinSynthesisRate() : nullptr;
    _glucagonSynthesisRate = (endocrine.HasGlucagonSynthesisRate()) ? &endocrine.GetGlucagonSynthesisRate() : nullptr;

    auto& energy = _engine->GetEnergy();
    _achievedExerciseLevel = (energy.HasAchievedExerciseLevel()) ? &energy.GetAchievedExerciseLevel() : nullptr;
    _chlorideLostToSweat = (energy.HasChlorideLostToSweat()) ? &energy.GetChlorideLostToSweat() : nullptr;
    _coreTemperature = (energy.HasCoreTemperature()) ? &energy.GetCoreTemperature() : nullptr;
    _creatinineProductionRate = (energy.HasCreatinineProductionRate()) ? &energy.GetCreatinineProductionRate() : nullptr;
    _exerciseMeanArterialPressureDelta = (energy.HasExerciseMeanArterialPressureDelta()) ? &energy.GetExerciseMeanArterialPressureDelta() : nullptr;
    _fatigueLevel = (energy.HasFatigueLevel()) ? &energy.GetFatigueLevel() : nullptr;
    _lactateProductionRate = (energy.HasLactateProductionRate()) ? &energy.GetLactateProductionRate() : nullptr;
    _potassiumLostToSweat = (energy.HasPotassiumLostToSweat()) ? &energy.GetPotassiumLostToSweat() : nullptr;
    _skinTemperature = (energy.HasSkinTemperature()) ? &energy.GetSkinTemperature() : nullptr;
    _sodiumLostToSweat = (energy.HasSodiumLostToSweat()) ? &energy.GetSodiumLostToSweat() : nullptr;
    _sweatRate = (energy.HasSweatRate()) ? &energy.GetSweatRate() : nullptr;
    _totalMetabolicRate = (energy.HasTotalMetabolicRate()) ? &energy.GetTotalWorkRateLevel() : nullptr;
    _totalWorkRateLevel = (energy.HasTotalWorkRateLevel()) ? &energy.GetTotalWorkRateLevel() : nullptr;

    auto& gastrointestinal = _engine->GetGastrointestinal();
    _chymeAbsorptionRate = (gastrointestinal.HasChymeAbsorptionRate()) ? &gastrointestinal.GetChymeAbsorptionRate() : nullptr;
    _stomachContents_calcium = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasCalcium()) ? &gastrointestinal.GetStomachContents().GetCalcium() : nullptr;
    _stomachContents_carbohydrates = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasCarbohydrate()) ? &gastrointestinal.GetStomachContents().GetCarbohydrate() : nullptr;
    _stomachContents_carbohydrateDigationRate = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasCarbohydrateDigestionRate()) ? &gastrointestinal.GetStomachContents().GetCarbohydrateDigestionRate() : nullptr;
    _stomachContents_fat = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasFat()) ? &gastrointestinal.GetStomachContents().GetFat() : nullptr;
    _stomachContents_fatDigtationRate = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasFatDigestionRate()) ? &gastrointestinal.GetStomachContents().GetFatDigestionRate() : nullptr;
    _stomachContents_protien = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasProtein()) ? &gastrointestinal.GetStomachContents().GetProtein() : nullptr;
    _stomachContents_protienDigtationRate = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasProteinDigestionRate()) ? &gastrointestinal.GetStomachContents().GetProteinDigestionRate() : nullptr;
    _stomachContents_sodium = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasSodium()) ? &gastrointestinal.GetStomachContents().GetSodium() : nullptr;
    _stomachContents_water = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasWater()) ? &gastrointestinal.GetStomachContents().GetWater() : nullptr;

    auto& hepatic = _engine->GetHepatic();
    _hepaticGluconeogenesisRate = (hepatic.HasHepaticGluconeogenesisRate()) ? &hepatic.GetHepaticGluconeogenesisRate() : nullptr;
    _ketoneproductionRate = (hepatic.HasKetoneProductionRate()) ? &hepatic.GetKetoneProductionRate() : nullptr;

    auto& nervous = _engine->GetNervous();
    _baroreceptorHeartRateScale = (nervous.HasBaroreceptorHeartRateScale()) ? &nervous.GetBaroreceptorHeartRateScale() : nullptr;
    _baroreceptorHeartElastanceScale = (nervous.HasBaroreceptorHeartElastanceScale()) ? &nervous.GetBaroreceptorHeartElastanceScale() : nullptr;
    _baroreceptorResistanceScale = (nervous.HasBaroreceptorResistanceScale()) ? &nervous.GetBaroreceptorResistanceScale() : nullptr;
    _baroreceptorComplianceScale = (nervous.HasBaroreceptorComplianceScale()) ? &nervous.GetBaroreceptorComplianceScale() : nullptr;
    _chemoreceptorHeartRateScale = (nervous.HasChemoreceptorHeartRateScale()) ? &nervous.GetChemoreceptorHeartRateScale() : nullptr;
    _chemoreceptorHeartElastanceScale = (nervous.HasChemoreceptorHeartElastanceScale()) ? &nervous.GetChemoreceptorHeartElastanceScale() : nullptr;
    _painVisualAnalogueScale = (nervous.HasPainVisualAnalogueScale()) ? &nervous.GetPainVisualAnalogueScale() : nullptr;

    //TODO: Implement Pupillary Response  ReactivityModifier  ShapeModifier  SizeModifier;
    _leftEyePupillaryResponse = nullptr;
    _rightEyePupillaryResponse = nullptr;

    //Renal
    auto& renal = _engine->GetRenal();
    _glomerularFiltrationRate = (renal.HasGlomerularFiltrationRate()) ? &renal.GetGlomerularFiltrationRate() : nullptr;
    _filtrationFraction = (renal.HasFiltrationFraction()) ? &renal.GetFiltrationFraction() : nullptr;
    _leftAfferentArterioleResistance = (renal.HasLeftAfferentArterioleResistance()) ? &renal.GetLeftAfferentArterioleResistance() : nullptr;
    _leftBowmansCapsulesHydrostaticPressure = (renal.HasLeftBowmansCapsulesHydrostaticPressure()) ? &renal.GetLeftBowmansCapsulesHydrostaticPressure() : nullptr;
    _leftBowmansCapsulesOsmoticPressure = (renal.HasLeftBowmansCapsulesOsmoticPressure()) ? &renal.GetLeftBowmansCapsulesOsmoticPressure() : nullptr;
    _leftEfferentArterioleResistance = (renal.HasLeftEfferentArterioleResistance()) ? &renal.GetLeftEfferentArterioleResistance() : nullptr;
    _leftGlomerularCapillariesHydrostaticPressure = (renal.HasLeftGlomerularCapillariesHydrostaticPressure()) ? &renal.GetLeftGlomerularCapillariesHydrostaticPressure() : nullptr;
    _leftGlomerularCapillariesOsmoticPressure = (renal.HasLeftGlomerularCapillariesOsmoticPressure()) ? &renal.GetLeftGlomerularCapillariesOsmoticPressure() : nullptr;
    _leftGlomerularFiltrationCoefficient = (renal.HasLeftGlomerularFiltrationCoefficient()) ? &renal.GetLeftGlomerularFiltrationCoefficient() : nullptr;
    _leftGlomerularFiltrationRate = (renal.HasLeftGlomerularFiltrationRate()) ? &renal.GetLeftGlomerularFiltrationRate() : nullptr;
    _leftGlomerularFiltrationSurfaceArea = (renal.HasLeftGlomerularFiltrationSurfaceArea()) ? &renal.GetLeftGlomerularFiltrationSurfaceArea() : nullptr;
    _leftGlomerularFluidPermeability = (renal.HasLeftGlomerularFluidPermeability()) ? &renal.GetLeftGlomerularFluidPermeability() : nullptr;
    _leftFiltrationFraction = (renal.HasLeftFiltrationFraction()) ? &renal.GetLeftFiltrationFraction() : nullptr;
    _leftNetFiltrationPressure = (renal.HasLeftNetFiltrationPressure()) ? &renal.GetLeftNetFiltrationPressure() : nullptr;
    _leftNetReabsorptionPressure = (renal.HasLeftNetReabsorptionPressure()) ? &renal.GetLeftNetReabsorptionPressure() : nullptr;
    _leftPeritubularCapillariesHydrostaticPressure = (renal.HasLeftPeritubularCapillariesHydrostaticPressure()) ? &renal.GetLeftPeritubularCapillariesHydrostaticPressure() : nullptr;
    _leftPeritubularCapillariesOsmoticPressure = (renal.HasLeftPeritubularCapillariesOsmoticPressure()) ? &renal.GetLeftPeritubularCapillariesOsmoticPressure() : nullptr;
    _leftReabsorptionFiltrationCoefficient = (renal.HasLeftReabsorptionFiltrationCoefficient()) ? &renal.GetLeftReabsorptionFiltrationCoefficient() : nullptr;
    _leftReabsorptionRate = (renal.HasLeftReabsorptionRate()) ? &renal.GetLeftReabsorptionRate() : nullptr;
    _leftTubularReabsorptionFiltrationSurfaceArea = (renal.HasLeftTubularReabsorptionFiltrationSurfaceArea()) ? &renal.GetLeftTubularReabsorptionFiltrationSurfaceArea() : nullptr;
    _leftTubularReabsorptionFluidPermeability = (renal.HasLeftTubularReabsorptionFluidPermeability()) ? &renal.GetLeftTubularReabsorptionFluidPermeability() : nullptr;
    _leftTubularHydrostaticPressure = (renal.HasLeftTubularHydrostaticPressure()) ? &renal.GetLeftTubularHydrostaticPressure() : nullptr;
    _leftTubularOsmoticPressure = (renal.HasLeftTubularOsmoticPressure()) ? &renal.GetLeftTubularOsmoticPressure() : nullptr;
    _renalBloodFlow = (renal.HasRenalBloodFlow()) ? &renal.GetRenalBloodFlow() : nullptr;
    _renalPlasmaFlow = (renal.HasRenalPlasmaFlow()) ? &renal.GetRenalPlasmaFlow() : nullptr;
    _renalVascularResistance = (renal.HasRenalVascularResistance()) ? &renal.GetRenalVascularResistance() : nullptr;
    _rightAfferentArterioleResistance = (renal.HasRightAfferentArterioleResistance()) ? &renal.GetRightAfferentArterioleResistance() : nullptr;
    _rightBowmansCapsulesHydrostaticPressure = (renal.HasRightBowmansCapsulesHydrostaticPressure()) ? &renal.GetRightBowmansCapsulesHydrostaticPressure() : nullptr;
    _rightBowmansCapsulesOsmoticPressure = (renal.HasRightBowmansCapsulesOsmoticPressure()) ? &renal.GetRightBowmansCapsulesOsmoticPressure() : nullptr;
    _rightEfferentArterioleResistance = (renal.HasRightEfferentArterioleResistance()) ? &renal.GetRightEfferentArterioleResistance() : nullptr;
    _rightGlomerularCapillariesHydrostaticPressure = (renal.HasRightGlomerularCapillariesHydrostaticPressure()) ? &renal.GetRightGlomerularCapillariesHydrostaticPressure() : nullptr;
    _rightGlomerularCapillariesOsmoticPressure = (renal.HasRightGlomerularCapillariesOsmoticPressure()) ? &renal.GetRightGlomerularCapillariesOsmoticPressure() : nullptr;
    _rightGlomerularFiltrationCoefficient = (renal.HasRightGlomerularFiltrationCoefficient()) ? &renal.GetRightGlomerularFiltrationCoefficient() : nullptr;
    _rightGlomerularFiltrationRate = (renal.HasRightGlomerularFiltrationRate()) ? &renal.GetRightGlomerularFiltrationRate() : nullptr;
    _rightGlomerularFiltrationSurfaceArea = (renal.HasRightGlomerularFiltrationSurfaceArea()) ? &renal.GetRightGlomerularFiltrationSurfaceArea() : nullptr;
    _rightGlomerularFluidPermeability = (renal.HasRightGlomerularFluidPermeability()) ? &renal.GetRightGlomerularFluidPermeability() : nullptr;
    _rightFiltrationFraction = (renal.HasRightFiltrationFraction()) ? &renal.GetRightFiltrationFraction() : nullptr;
    _rightNetFiltrationPressure = (renal.HasRightNetFiltrationPressure()) ? &renal.GetRightNetFiltrationPressure() : nullptr;
    _rightNetReabsorptionPressure = (renal.HasRightNetReabsorptionPressure()) ? &renal.GetRightNetReabsorptionPressure() : nullptr;
    _rightPeritubularCapillariesHydrostaticPressure = (renal.HasRightPeritubularCapillariesHydrostaticPressure()) ? &renal.GetRightPeritubularCapillariesHydrostaticPressure() : nullptr;
    _rightPeritubularCapillariesOsmoticPressure = (renal.HasRightPeritubularCapillariesOsmoticPressure()) ? &renal.GetRightPeritubularCapillariesOsmoticPressure() : nullptr;
    _rightReabsorptionFiltrationCoefficient = (renal.HasRightReabsorptionFiltrationCoefficient()) ? &renal.GetRightReabsorptionFiltrationCoefficient() : nullptr;
    _rightReabsorptionRate = (renal.HasRightReabsorptionRate()) ? &renal.GetRightReabsorptionRate() : nullptr;
    _rightTubularReabsorptionFiltrationSurfaceArea = (renal.HasRightTubularReabsorptionFiltrationSurfaceArea()) ? &renal.GetRightTubularReabsorptionFiltrationSurfaceArea() : nullptr;
    _rightTubularReabsorptionFluidPermeability = (renal.HasRightTubularReabsorptionFluidPermeability()) ? &renal.GetRightTubularReabsorptionFluidPermeability() : nullptr;
    _rightTubularHydrostaticPressure = (renal.HasRightTubularHydrostaticPressure()) ? &renal.GetRightTubularHydrostaticPressure() : nullptr;
    _rightTubularOsmoticPressure = (renal.HasRightTubularOsmoticPressure()) ? &renal.GetRightTubularOsmoticPressure() : nullptr;
    _urinationRate = (renal.HasUrinationRate()) ? &renal.GetUrinationRate() : nullptr;
    _urineOsmolality = (renal.HasUrineOsmolality()) ? &renal.GetUrineOsmolality() : nullptr;
    _urineOsmolarity = (renal.HasUrineOsmolarity()) ? &renal.GetUrineOsmolarity() : nullptr;
    _urineProductionRate = (renal.HasUrineProductionRate()) ? &renal.GetUrineProductionRate() : nullptr;
    _meanUrineOutput = (renal.HasMeanUrineOutput()) ? &renal.GetMeanUrineOutput() : nullptr;
    _urineSpecificGravity = (renal.HasUrineSpecificGravity()) ? &renal.GetUrineSpecificGravity() : nullptr;
    _urineVolume = (renal.HasUrineVolume()) ? &renal.GetUrineVolume() : nullptr;
    _urineUreaNitrogenConcentration = (renal.HasUrineUreaNitrogenConcentration()) ? &renal.GetUrineUreaNitrogenConcentration() : nullptr;

    //Respiratory
    auto& respiratory = _engine->GetRespiratory();
    _alveolarArterialGradient = (respiratory.HasAlveolarArterialGradient()) ? &respiratory.GetAlveolarArterialGradient() : nullptr;
    _carricoIndex = (respiratory.HasCarricoIndex()) ? &respiratory.GetCarricoIndex() : nullptr;
    _endTidalCarbonDioxideFraction = (respiratory.HasEndTidalCarbonDioxideFraction()) ? &respiratory.GetEndTidalCarbonDioxideFraction() : nullptr;
    _endTidalCarbonDioxidePressure = (respiratory.HasEndTidalCarbonDioxidePressure()) ? &respiratory.GetEndTidalCarbonDioxidePressure() : nullptr;
    _expiratoryFlow = (respiratory.HasExpiratoryFlow()) ? &respiratory.GetExpiratoryFlow() : nullptr;
    _inspiratoryExpiratoryRatio = (respiratory.HasInspiratoryExpiratoryRatio()) ? &respiratory.GetInspiratoryExpiratoryRatio() : nullptr;
    _inspiratoryFlow = (respiratory.HasInspiratoryFlow()) ? &respiratory.GetInspiratoryFlow() : nullptr;
    _pulmonaryCompliance = (respiratory.HasPulmonaryCompliance()) ? &respiratory.GetPulmonaryCompliance() : nullptr;
    _pulmonaryResistance = (respiratory.HasPulmonaryResistance()) ? &respiratory.GetPulmonaryResistance() : nullptr;
    _respirationDriverPressure = (respiratory.HasRespirationDriverPressure()) ? &respiratory.GetRespirationDriverPressure() : nullptr;
    _respirationMusclePressure = (respiratory.HasRespirationMusclePressure()) ? &respiratory.GetRespirationMusclePressure() : nullptr;
    _respirationRate = (respiratory.HasRespirationRate()) ? &respiratory.GetRespirationRate() : nullptr;
    _specificVentilation = (respiratory.HasSpecificVentilation()) ? &respiratory.GetSpecificVentilation() : nullptr;
    _targetPulmonaryVentilation = (respiratory.HasTargetPulmonaryVentilation()) ? &respiratory.GetTargetPulmonaryVentilation() : nullptr;
    _tidalVolume = (respiratory.HasTidalVolume()) ? &respiratory.GetTidalVolume() : nullptr;
    _totalAlveolarVentilation = (respiratory.HasTotalAlveolarVentilation()) ? &respiratory.GetTotalAlveolarVentilation() : nullptr;
    _totalDeadSpaceVentilation = (respiratory.HasTotalDeadSpaceVentilation()) ? &respiratory.GetTotalDeadSpaceVentilation() : nullptr;
    _totalLungVolume = (respiratory.HasTotalLungVolume()) ? &respiratory.GetTotalLungVolume() : nullptr;
    _totalPulmonaryVentilation = (respiratory.HasTotalPulmonaryVentilation()) ? &respiratory.GetTotalPulmonaryVentilation() : nullptr;
    _transpulmonaryPressure = (respiratory.HasTranspulmonaryPressure()) ? &respiratory.GetTranspulmonaryPressure() : nullptr;

    //Tissue
    auto& tissue = _engine->GetTissue();
    _carbonDioxideProductionRate = (tissue.HasCarbonDioxideProductionRate()) ? &tissue.GetCarbonDioxideProductionRate() : nullptr;
    _dehydrationFraction = (tissue.HasDehydrationFraction()) ? &tissue.GetDehydrationFraction() : nullptr;
    _extracellularFluidVolume = (tissue.HasExtracellularFluidVolume()) ? &tissue.GetExtracellularFluidVolume() : nullptr;
    _extravascularFluidVolume = (tissue.HasExtravascularFluidVolume()) ? &tissue.GetExtravascularFluidVolume() : nullptr;
    _intracellularFluidPH = (tissue.HasIntracellularFluidPH()) ? &tissue.GetIntracellularFluidPH() : nullptr;
    _intracellularFluidVolume = (tissue.HasIntracellularFluidVolume()) ? &tissue.GetIntracellularFluidVolume() : nullptr;
    _totalBodyFluidVolume = (tissue.HasTotalBodyFluidVolume()) ? &tissue.GetTotalBodyFluidVolume() : nullptr;
    _oxygenConsumptionRate = (tissue.HasOxygenConsumptionRate()) ? &tissue.GetOxygenConsumptionRate() : nullptr;
    _respiratoryExchangeRatio = (tissue.HasRespiratoryExchangeRatio()) ? &tissue.GetRespiratoryExchangeRatio() : nullptr;
    _liverInsulinSetPoint = (tissue.HasLiverInsulinSetPoint()) ? &tissue.GetLiverInsulinSetPoint() : nullptr;
    _liverGlucagonSetPoint = (tissue.HasLiverGlucagonSetPoint()) ? &tissue.GetLiverGlucagonSetPoint() : nullptr;
    _muscleInsulinSetPoint = (tissue.HasMuscleInsulinSetPoint()) ? &tissue.GetMuscleInsulinSetPoint() : nullptr;
    _muscleGlucagonSetPoint = (tissue.HasMuscleGlucagonSetPoint()) ? &tissue.GetMuscleGlucagonSetPoint() : nullptr;
    _fatInsulinSetPoint = (tissue.HasFatInsulinSetPoint()) ? &tissue.GetFatInsulinSetPoint() : nullptr;
    _fatGlucagonSetPoint = (tissue.HasFatGlucagonSetPoint()) ? &tissue.GetFatGlucagonSetPoint() : nullptr;
    _liverGlycogen = (tissue.HasLiverGlycogen()) ? &tissue.GetLiverGlycogen() : nullptr;
    _muscleGlycogen = (tissue.HasMuscleGlycogen()) ? &tissue.GetMuscleGlycogen() : nullptr;
    _storedProtein = (tissue.HasStoredProtein()) ? &tissue.GetStoredProtein() : nullptr;
    _storedFat = (tissue.HasStoredFat()) ? &tissue.GetStoredFat() : nullptr;

    emit patientStateChanged(get_physiology_state());
    emit patientMetricsChanged(get_physiology_metrics());
    emit stateChanged();
  } else {
    _engine->GetLogger()->Error("Could not load state, check the error");
  }
  _engine_mutex.unlock();

  return *this;
}
//-------------------------------------------------------------------------------
void Scenario::physiology_thread_main()
{
  using namespace std::chrono_literals;

  auto current_time = std::chrono::steady_clock::now();
  std::chrono::time_point<std::chrono::steady_clock> prev;
  while (_running) {
    prev = current_time;
    physiology_thread_step();
    current_time = std::chrono::steady_clock::now();
    if (_throttle) {
      while ((current_time - prev) < 1s) {
        std::this_thread::sleep_for(16ms);
        current_time = std::chrono::steady_clock::now();
      }
    }
  }
}
//-------------------------------------------------------------------------------
inline void Scenario::physiology_thread_step()
{
  using namespace std::chrono_literals;

  if (!_paused) {
    _engine_mutex.lock(); //< I ran in to some -O2 issues when using an std::lock_guard in msvc

    if (_action_queue.size()) {
      dynamic_cast<biogears::BioGearsEngine*>(_engine.get())->ProcessAction(*_action_queue.consume());
    }
    dynamic_cast<biogears::BioGearsEngine*>(_engine.get())->AdvanceModelTime(1, biogears::TimeUnit::s);
    _engine_mutex.unlock();

    emit patientStateChanged(get_physiology_state());
    emit patientMetricsChanged(get_physiology_metrics());
    emit patientConditionsChanged(get_physiology_conditions());

  } else {
    std::this_thread::sleep_for(16ms);
  }
}
//---------------------------------------------------------------------------------
auto Scenario::get_physiology_state() -> PatientState
{
  PatientState current;
  const auto& patient = _engine->GetPatient();
  current.alive = "True";
  current.tacycardia = "False";

  current.age = (patient.HasAge()) ? QString::number(patient.GetAge(biogears::TimeUnit::yr), 'f', 0)
                                   : "N/A";
  current.height_cm = (patient.HasHeight()) ? QString::number(patient.GetHeight(biogears::LengthUnit::cm), 'f', 0)
                                            : "N/A";
  current.gender = (!patient.HasGender()) ? "N/A"
                                          : (patient.GetGender() == CDM::enumSex::Male) ? "Male"
                                                                                        : "Female";
  current.weight_kg = (patient.HasWeight()) ? QString::number(patient.GetWeight(biogears::MassUnit::kg), 'f', 2)
                                            : "N/A";
  if (patient.HasWeight() && patient.HasWeight()) {
    auto BSA = std::sqrt(patient.GetHeight(biogears::LengthUnit::cm) * patient.GetWeight(biogears::MassUnit::kg) / 3600.0);
    current.body_surface_area_m_sq = QString::number(BSA, 'f', 2);
    auto BMI = patient.GetWeight(biogears::MassUnit::kg) / std::pow(patient.GetHeight(biogears::LengthUnit::m), 2);
    current.body_mass_index_kg_per_m_sq = QString::number(BMI, 'f', 2);
  } else {
    current.body_surface_area_m_sq = "N/A";
    current.body_mass_index_kg_per_m_sq = "N/A";
  }
  current.body_fat_pct = (patient.HasBodyFatFraction()) ? QString::number(patient.GetBodyFatFraction(), 'f', 2)
                                                        : "N/A";
  //TODO: Lets take intensity and make a series of animated GIFs inspired off vault-boy
  current.exercise_state = (_engine->GetActions().GetPatientActions().HasExercise()) ? "Running" : "Standing";

  return current;
}
//---------------------------------------------------------------------------------
auto Scenario::get_physiology_metrics() -> PatientMetrics*
{
  PatientMetrics* current = new PatientMetrics();

  current->simulationTime = _engine->GetSimulationTime().GetValue(biogears::TimeUnit::s);
  current->timeStep = _engine->GetTimeStep().GetValue(biogears::TimeUnit::s);

  current->heart_rate_bpm = (_engine->GetCardiovascular().HasHeartRate())
    ? QString::number(_engine->GetCardiovascular().GetHeartRate().GetValue(biogears::FrequencyUnit::Per_min), 'f', 2)
    : "N/A";
  current->respiratory_rate_bpm = (_engine->GetRespiratory().HasRespirationRate())
    ? QString::number(_engine->GetRespiratory().GetRespirationRate().GetValue(biogears::FrequencyUnit::Per_min), 'f', 2)
    : "N/A";
  current->core_temperature_c = (_engine->GetEnergy().HasCoreTemperature())
    ? QString::number(_engine->GetEnergy().GetCoreTemperature(biogears::TemperatureUnit::C), 'f', 2)
    : "N/A";
  current->oxygen_saturation_pct = (_engine->GetBloodChemistry().HasOxygenSaturation())
    ? QString::number(_engine->GetBloodChemistry().GetOxygenSaturation().GetValue(), 'f', 2)
    : "N/A";
  current->systolic_blood_pressure_mmHg = (_engine->GetCardiovascular().HasSystolicArterialPressure())
    ? QString::number(_engine->GetCardiovascular().GetSystolicArterialPressure().GetValue(biogears::PressureUnit::mmHg), 'f', 2)
    : "N/A";
  current->diastolic_blood_pressure_mmHg = (_engine->GetCardiovascular().HasDiastolicArterialPressure())
    ? QString::number(_engine->GetCardiovascular().GetDiastolicArterialPressure().GetValue(biogears::PressureUnit::mmHg), 'f', 2)
    : "N/A";

  auto& bloodChemistry = _engine->GetBloodChemistry();
  current->arterialBloodPH = (_arterialBloodPH) ? _arterialBloodPH->GetValue() : 0.0;
  current->arterialBloodPHBaseline = (_arterialBloodPHBaseline) ? _arterialBloodPHBaseline->GetValue() : 0.0;
  current->bloodDensity = (_bloodDensity) ? _bloodDensity->GetValue() : 0.0;
  current->bloodSpecificHeat = (_bloodSpecificHeat) ? _bloodSpecificHeat->GetValue() : 0.0;
  current->bloodUreaNitrogenConcentration = (_bloodUreaNitrogenConcentration) ? _bloodUreaNitrogenConcentration->GetValue() : 0.0;
  current->carbonDioxideSaturation = (_carbonDioxideSaturation) ? _carbonDioxideSaturation->GetValue() : 0.0;
  current->carbonMonoxideSaturation = (_carbonMonoxideSaturation) ? _carbonMonoxideSaturation->GetValue() : 0.0;
  current->hematocrit = (_hematocrit) ? _hematocrit->GetValue() : 0.0;
  current->hemoglobinContent = (_hemoglobinContent) ? _hemoglobinContent->GetValue() : 0.0;
  current->oxygenSaturation = (_oxygenSaturation) ? _oxygenSaturation->GetValue() : 0.0;
  current->phosphate = (_phosphate) ? _phosphate->GetValue() : 0.0;
  current->plasmaVolume = (_plasmaVolume) ? _plasmaVolume->GetValue() : 0.0;
  current->pulseOximetry = (_pulseOximetry) ? _pulseOximetry->GetValue() : 0.0;
  current->redBloodCellAcetylcholinesterase = (_redBloodCellAcetylcholinesterase) ? _redBloodCellAcetylcholinesterase->GetValue() : 0.0;
  current->redBloodCellCount = (_redBloodCellCount) ? _redBloodCellCount->GetValue(biogears::AmountPerVolumeUnit::ct_Per_uL) : 0.0;
  current->shuntFraction = (_shuntFraction) ? _shuntFraction->GetValue() : 0.0;
  current->strongIonDifference = (_strongIonDifference) ? _strongIonDifference->GetValue() : 0.0;
  current->totalBilirubin = (_totalBilirubin) ? _totalBilirubin->GetValue() : 0.0;
  current->totalProteinConcentration = (_totalProteinConcentration) ? _totalProteinConcentration->GetValue() : 0.0;
  current->venousBloodPH = (_venousBloodPH) ? _venousBloodPH->GetValue() : 0.0;
  current->volumeFractionNeutralPhospholipidInPlasma = (_volumeFractionNeutralPhospholipidInPlasma) ? _volumeFractionNeutralPhospholipidInPlasma->GetValue() : 0.0;
  current->volumeFractionNeutralLipidInPlasma = (_volumeFractionNeutralLipidInPlasma) ? _volumeFractionNeutralLipidInPlasma->GetValue() : 0.0;
  current->arterialCarbonDioxidePressure = (_arterialCarbonDioxidePressure) ? _arterialCarbonDioxidePressure->GetValue() : 0.0;
  current->arterialOxygenPressure = (_arterialOxygenPressure) ? _arterialOxygenPressure->GetValue() : 0.0;
  current->pulmonaryArterialCarbonDioxidePressure = (_pulmonaryArterialCarbonDioxidePressure) ? _pulmonaryArterialCarbonDioxidePressure->GetValue() : 0.0;
  current->pulmonaryArterialOxygenPressure = (_pulmonaryArterialOxygenPressure) ? _pulmonaryArterialOxygenPressure->GetValue() : 0.0;
  current->pulmonaryVenousCarbonDioxidePressure = (_pulmonaryVenousCarbonDioxidePressure) ? _pulmonaryVenousCarbonDioxidePressure->GetValue() : 0.0;
  current->pulmonaryVenousOxygenPressure = (_pulmonaryVenousOxygenPressure) ? _pulmonaryVenousOxygenPressure->GetValue() : 0.0;
  current->venousCarbonDioxidePressure = (_venousCarbonDioxidePressure) ? _venousCarbonDioxidePressure->GetValue() : 0.0;
  current->venousOxygenPressure = (_venousOxygenPressure) ? _venousOxygenPressure->GetValue() : 0.0;
  current->inflammatoryResponse = bloodChemistry.HasInflammatoryResponse();

  auto& inflamatoryResponse = bloodChemistry.GetInflammatoryResponse();
  current->inflammatoryResponseLocalPathogen = (_inflammatoryResponseLocalPathogen) ? _inflammatoryResponseLocalPathogen->GetValue() : 0.0;
  current->inflammatoryResponseLocalMacrophage = (_inflammatoryResponseLocalMacrophage) ? _inflammatoryResponseLocalMacrophage->GetValue() : 0.0;
  current->inflammatoryResponseLocalNeutrophil = (_inflammatoryResponseLocalNeutrophil) ? _inflammatoryResponseLocalNeutrophil->GetValue() : 0.0;
  current->inflammatoryResponseLocalBarrier = (_inflammatoryResponseLocalBarrier) ? _inflammatoryResponseLocalBarrier->GetValue() : 0.0;
  current->inflammatoryResponseBloodPathogen = (_inflammatoryResponseBloodPathogen) ? _inflammatoryResponseBloodPathogen->GetValue() : 0.0;
  current->inflammatoryResponseTrauma = (_inflammatoryResponseTrauma) ? _inflammatoryResponseTrauma->GetValue() : 0.0;
  current->inflammatoryResponseMacrophageResting = (_inflammatoryResponseMacrophageResting) ? _inflammatoryResponseMacrophageResting->GetValue() : 0.0;
  current->inflammatoryResponseMacrophageActive = (_inflammatoryResponseMacrophageActive) ? _inflammatoryResponseMacrophageActive->GetValue() : 0.0;
  current->inflammatoryResponseNeutrophilResting = (_inflammatoryResponseNeutrophilResting) ? _inflammatoryResponseNeutrophilResting->GetValue() : 0.0;
  current->inflammatoryResponseNeutrophilActive = (_inflammatoryResponseNeutrophilActive) ? _inflammatoryResponseNeutrophilActive->GetValue() : 0.0;
  current->inflammatoryResponseInducibleNOSPre = (_inflammatoryResponseInducibleNOSPre) ? _inflammatoryResponseInducibleNOSPre->GetValue() : 0.0;
  current->inflammatoryResponseInducibleNOS = (_inflammatoryResponseInducibleNOS) ? _inflammatoryResponseInducibleNOS->GetValue() : 0.0;
  current->inflammatoryResponseConstitutiveNOS = (_inflammatoryResponseConstitutiveNOS) ? _inflammatoryResponseConstitutiveNOS->GetValue() : 0.0;
  current->inflammatoryResponseNitrate = (_inflammatoryResponseNitrate) ? _inflammatoryResponseNitrate->GetValue() : 0.0;
  current->inflammatoryResponseNitricOxide = (_inflammatoryResponseNitricOxide) ? _inflammatoryResponseNitricOxide->GetValue() : 0.0;
  current->inflammatoryResponseTumorNecrosisFactor = (_inflammatoryResponseTumorNecrosisFactor) ? _inflammatoryResponseTumorNecrosisFactor->GetValue() : 0.0;
  current->inflammatoryResponseInterleukin6 = (_inflammatoryResponseInterleukin6) ? _inflammatoryResponseInterleukin6->GetValue() : 0.0;
  current->inflammatoryResponseInterleukin10 = (_inflammatoryResponseInterleukin10) ? _inflammatoryResponseInterleukin10->GetValue() : 0.0;
  current->inflammatoryResponseInterleukin12 = (_inflammatoryResponseInterleukin12) ? _inflammatoryResponseInterleukin12->GetValue() : 0.0;
  current->inflammatoryResponseCatecholamines = (_inflammatoryResponseCatecholamines) ? _inflammatoryResponseCatecholamines->GetValue() : 0.0;
  current->inflammatoryResponseTissueIntegrity = (_inflammatoryResponseTissueIntegrity) ? _inflammatoryResponseTissueIntegrity->GetValue() : 0.0;

  auto& cardiovascular = _engine->GetCardiovascular();
  current->arterialPressure = (_arterialPressure) ? _arterialPressure->GetValue() : 0.0;
  current->bloodVolume = (_bloodVolume) ? _bloodVolume->GetValue() : 0.0;
  current->cardiacIndex = (_cardiacIndex) ? _cardiacIndex->GetValue() : 0.0;
  current->cardiacOutput = (_cardiacOutput) ? _cardiacOutput->GetValue() : 0.0;
  current->centralVenousPressure = (_centralVenousPressure) ? _centralVenousPressure->GetValue() : 0.0;
  current->cerebralBloodFlow = (_cerebralBloodFlow) ? _cerebralBloodFlow->GetValue() : 0.0;
  current->cerebralPerfusionPressure = (_cerebralPerfusionPressure) ? _cerebralPerfusionPressure->GetValue() : 0.0;
  current->diastolicArterialPressure = (_diastolicArterialPressure) ? _diastolicArterialPressure->GetValue() : 0.0;
  current->heartEjectionFraction = (_heartEjectionFraction) ? _heartEjectionFraction->GetValue() : 0.0;
  current->heartRate = (_heartRate) ? _heartRate->GetValue() : 0.0;
  current->heartStrokeVolume = (_heartStrokeVolume) ? _heartStrokeVolume->GetValue() : 0.0;
  current->intracranialPressure = (_intracranialPressure) ? _intracranialPressure->GetValue() : 0.0;
  current->meanArterialPressure = (_meanArterialPressure) ? _meanArterialPressure->GetValue() : 0.0;
  current->meanArterialCarbonDioxidePartialPressure = (_meanArterialCarbonDioxidePartialPressure) ? _meanArterialCarbonDioxidePartialPressure->GetValue() : 0.0;
  current->meanArterialCarbonDioxidePartialPressureDelta = (_meanArterialCarbonDioxidePartialPressureDelta) ? _meanArterialCarbonDioxidePartialPressureDelta->GetValue() : 0.0;
  current->meanCentralVenousPressure = (_meanCentralVenousPressure) ? _meanCentralVenousPressure->GetValue() : 0.0;
  current->meanSkinFlow = (_meanSkinFlow) ? _meanSkinFlow->GetValue() : 0.0;
  current->pulmonaryArterialPressure = (_pulmonaryArterialPressure) ? _pulmonaryArterialPressure->GetValue() : 0.0;
  current->pulmonaryCapillariesWedgePressure = (_pulmonaryCapillariesWedgePressure) ? _pulmonaryCapillariesWedgePressure->GetValue() : 0.0;
  current->pulmonaryDiastolicArterialPressure = (_pulmonaryDiastolicArterialPressure) ? _pulmonaryDiastolicArterialPressure->GetValue() : 0.0;
  current->pulmonaryMeanArterialPressure = (_pulmonaryMeanArterialPressure) ? _pulmonaryMeanArterialPressure->GetValue() : 0.0;
  current->pulmonaryMeanCapillaryFlow = (_pulmonaryMeanCapillaryFlow) ? _pulmonaryMeanCapillaryFlow->GetValue() : 0.0;
  current->pulmonaryMeanShuntFlow = (_pulmonaryMeanShuntFlow) ? _pulmonaryMeanShuntFlow->GetValue() : 0.0;
  current->pulmonarySystolicArterialPressure = (_pulmonarySystolicArterialPressure) ? _pulmonarySystolicArterialPressure->GetValue() : 0.0;
  current->pulmonaryVascularResistance = (_pulmonaryVascularResistance) ? _pulmonaryVascularResistance->GetValue() : 0.0;
  current->pulmonaryVascularResistanceIndex = (_pulmonaryVascularResistanceIndex) ? _pulmonaryVascularResistanceIndex->GetValue() : 0.0;
  current->pulsePressure = (_pulsePressure) ? _pulsePressure->GetValue() : 0.0;
  current->systemicVascularResistance = (_systemicVascularResistance) ? _systemicVascularResistance->GetValue() : 0.0;
  current->systolicArterialPressure = (_systolicArterialPressure) ? _systolicArterialPressure->GetValue() : 0.0;

  auto& drugs = _engine->GetDrugs();
  current->bronchodilationLevel = (_bronchodilationLevel) ? _bronchodilationLevel->GetValue() : 0.0;
  current->heartRateChange = (_heartRateChange) ? _heartRateChange->GetValue() : 0.0;
  current->meanBloodPressureChange = (_meanBloodPressureChange) ? _meanBloodPressureChange->GetValue() : 0.0;
  current->meanBloodPressureChange = (_meanBloodPressureChange) ? _meanBloodPressureChange->GetValue() : 0.0;
  current->neuromuscularBlockLevel = (_neuromuscularBlockLevel) ? _neuromuscularBlockLevel->GetValue() : 0.0;
  current->pulsePressureChange = (_pulsePressureChange) ? _pulsePressureChange->GetValue() : 0.0;
  current->respirationRateChange = (_respirationRateChange) ? _respirationRateChange->GetValue() : 0.0;
  current->sedationLevel = (_sedationLevel) ? _sedationLevel->GetValue() : 0.0;
  current->tidalVolumeChange = (_tidalVolumeChange) ? _tidalVolumeChange->GetValue() : 0.0;
  current->tubularPermeabilityChange = (_tubularPermeabilityChange) ? _tubularPermeabilityChange->GetValue() : 0.0;
  current->centralNervousResponse = (_centralNervousResponse) ? _centralNervousResponse->GetValue() : 0.0;

  auto& endocrine = _engine->GetEndocrine();
  current->insulinSynthesisRate = (_insulinSynthesisRate) ? _insulinSynthesisRate->GetValue() : 0.0;
  current->glucagonSynthesisRate = (_glucagonSynthesisRate) ? _glucagonSynthesisRate->GetValue() : 0.0;

  auto& energy = _engine->GetEnergy();
  current->achievedExerciseLevel = (_achievedExerciseLevel) ? _achievedExerciseLevel->GetValue() : 0.0;
  current->chlorideLostToSweat = (_chlorideLostToSweat) ? _chlorideLostToSweat->GetValue() : 0.0;
  current->coreTemperature = (_coreTemperature) ? _coreTemperature->GetValue() : 0.0;
  current->creatinineProductionRate = (_creatinineProductionRate) ? _creatinineProductionRate->GetValue() : 0.0;
  current->exerciseMeanArterialPressureDelta = (_exerciseMeanArterialPressureDelta) ? _exerciseMeanArterialPressureDelta->GetValue() : 0.0;
  current->fatigueLevel = (_fatigueLevel) ? _fatigueLevel->GetValue() : 0.0;
  current->lactateProductionRate = (_lactateProductionRate) ? _lactateProductionRate->GetValue() : 0.0;
  current->potassiumLostToSweat = (_potassiumLostToSweat) ? _potassiumLostToSweat->GetValue() : 0.0;
  current->skinTemperature = (_skinTemperature) ? _skinTemperature->GetValue() : 0.0;
  current->sodiumLostToSweat = (_sodiumLostToSweat) ? _sodiumLostToSweat->GetValue() : 0.0;
  current->sweatRate = (_sweatRate) ? _sweatRate->GetValue() : 0.0;
  current->totalMetabolicRate = (_totalMetabolicRate) ? _totalMetabolicRate->GetValue() : 0.0;
  current->totalWorkRateLevel = (_totalWorkRateLevel) ? _totalWorkRateLevel->GetValue() : 0.0;

  auto& gastrointestinal = _engine->GetGastrointestinal();
  current->chymeAbsorptionRate = (_chymeAbsorptionRate) ? _chymeAbsorptionRate->GetValue() : 0.0;
  current->stomachContents_calcium = (_stomachContents_calcium) ? _stomachContents_calcium->GetValue() : 0.0;
  current->stomachContents_carbohydrates = (_stomachContents_carbohydrates) ? _stomachContents_carbohydrates->GetValue() : 0.0;
  current->stomachContents_carbohydrateDigationRate = (_stomachContents_carbohydrateDigationRate) ? _stomachContents_carbohydrateDigationRate->GetValue() : 0.0;
  current->stomachContents_fat = (_stomachContents_fat) ? _stomachContents_fat->GetValue() : 0.0;
  current->stomachContents_fatDigtationRate = (_stomachContents_fatDigtationRate) ? _stomachContents_fatDigtationRate->GetValue() : 0.0;
  current->stomachContents_protien = (_stomachContents_protien) ? _stomachContents_protien->GetValue() : 0.0;
  current->stomachContents_protienDigtationRate = (_stomachContents_protienDigtationRate) ? _stomachContents_protienDigtationRate->GetValue() : 0.0;
  current->stomachContents_sodium = (_stomachContents_sodium) ? _stomachContents_sodium->GetValue() : 0.0;
  current->stomachContents_water = (_stomachContents_water) ? _stomachContents_water->GetValue() : 0.0;

  auto& hepatic = _engine->GetHepatic();
  current->hepaticGluconeogenesisRate = (_hepaticGluconeogenesisRate) ? _hepaticGluconeogenesisRate->GetValue() : 0.0;
  current->ketoneproductionRate = (_ketoneproductionRate) ? _ketoneproductionRate->GetValue() : 0.0;

  auto& nervous = _engine->GetNervous();
  current->baroreceptorHeartRateScale = (_baroreceptorHeartRateScale) ? _baroreceptorHeartRateScale->GetValue() : 0.0;
  current->baroreceptorHeartElastanceScale = (_baroreceptorHeartElastanceScale) ? _baroreceptorHeartElastanceScale->GetValue() : 0.0;
  current->baroreceptorResistanceScale = (_baroreceptorResistanceScale) ? _baroreceptorResistanceScale->GetValue() : 0.0;
  current->baroreceptorComplianceScale = (_baroreceptorComplianceScale) ? _baroreceptorComplianceScale->GetValue() : 0.0;
  current->chemoreceptorHeartRateScale = (_chemoreceptorHeartRateScale) ? _chemoreceptorHeartRateScale->GetValue() : 0.0;
  current->chemoreceptorHeartElastanceScale = (_chemoreceptorHeartElastanceScale) ? _chemoreceptorHeartElastanceScale->GetValue() : 0.0;
  current->painVisualAnalogueScale = (_painVisualAnalogueScale) ? _painVisualAnalogueScale->GetValue() : 0.0;

  //TODO: Implement Pupillary Response  ReactivityModifier  ShapeModifier  SizeModifier;
  current->leftEyePupillaryResponse = 0.0;
  current->rightEyePupillaryResponse = 0.0;

  //Renal
  auto& renal = _engine->GetRenal();
  current->glomerularFiltrationRate = (_glomerularFiltrationRate) ? _glomerularFiltrationRate->GetValue() : 0.0;
  ;
  current->filtrationFraction = (_filtrationFraction) ? _filtrationFraction->GetValue() : 0.0;
  ;
  current->leftAfferentArterioleResistance = (_leftAfferentArterioleResistance) ? _leftAfferentArterioleResistance->GetValue() : 0.0;
  ;
  current->leftBowmansCapsulesHydrostaticPressure = (_leftBowmansCapsulesHydrostaticPressure) ? _leftBowmansCapsulesHydrostaticPressure->GetValue() : 0.0;
  ;
  current->leftBowmansCapsulesOsmoticPressure = (_leftBowmansCapsulesOsmoticPressure) ? _leftBowmansCapsulesOsmoticPressure->GetValue() : 0.0;
  ;
  current->leftEfferentArterioleResistance = (_leftEfferentArterioleResistance) ? _leftEfferentArterioleResistance->GetValue() : 0.0;
  ;
  current->leftGlomerularCapillariesHydrostaticPressure = (_leftGlomerularCapillariesHydrostaticPressure) ? _leftGlomerularCapillariesHydrostaticPressure->GetValue() : 0.0;
  ;
  current->leftGlomerularCapillariesOsmoticPressure = (_leftGlomerularCapillariesOsmoticPressure) ? _leftGlomerularCapillariesOsmoticPressure->GetValue() : 0.0;
  ;
  current->leftGlomerularFiltrationCoefficient = (_leftGlomerularFiltrationCoefficient) ? _leftGlomerularFiltrationCoefficient->GetValue() : 0.0;
  ;
  current->leftGlomerularFiltrationRate = (_leftGlomerularFiltrationRate) ? _leftGlomerularFiltrationRate->GetValue() : 0.0;
  ;
  current->leftGlomerularFiltrationSurfaceArea = (_leftGlomerularFiltrationSurfaceArea) ? _leftGlomerularFiltrationSurfaceArea->GetValue() : 0.0;
  ;
  current->leftGlomerularFluidPermeability = (_leftGlomerularFluidPermeability) ? _leftGlomerularFluidPermeability->GetValue() : 0.0;
  ;
  current->leftFiltrationFraction = (_leftFiltrationFraction) ? _leftFiltrationFraction->GetValue() : 0.0;
  ;
  current->leftNetFiltrationPressure = (_leftNetFiltrationPressure) ? _leftNetFiltrationPressure->GetValue() : 0.0;
  ;
  current->leftNetReabsorptionPressure = (_leftNetReabsorptionPressure) ? _leftNetReabsorptionPressure->GetValue() : 0.0;
  ;
  current->leftPeritubularCapillariesHydrostaticPressure = (_leftPeritubularCapillariesHydrostaticPressure) ? _leftPeritubularCapillariesHydrostaticPressure->GetValue() : 0.0;
  ;
  current->leftPeritubularCapillariesOsmoticPressure = (_leftPeritubularCapillariesOsmoticPressure) ? _leftPeritubularCapillariesOsmoticPressure->GetValue() : 0.0;
  ;
  current->leftReabsorptionFiltrationCoefficient = (_leftReabsorptionFiltrationCoefficient) ? _leftReabsorptionFiltrationCoefficient->GetValue() : 0.0;
  ;
  current->leftReabsorptionRate = (_leftReabsorptionRate) ? _leftReabsorptionRate->GetValue() : 0.0;
  ;
  current->leftTubularReabsorptionFiltrationSurfaceArea = (_leftTubularReabsorptionFiltrationSurfaceArea) ? _leftTubularReabsorptionFiltrationSurfaceArea->GetValue() : 0.0;
  ;
  current->leftTubularReabsorptionFluidPermeability = (_leftTubularReabsorptionFluidPermeability) ? _leftTubularReabsorptionFluidPermeability->GetValue() : 0.0;
  ;
  current->leftTubularHydrostaticPressure = (_leftTubularHydrostaticPressure) ? _leftTubularHydrostaticPressure->GetValue() : 0.0;
  ;
  current->leftTubularOsmoticPressure = (_leftTubularOsmoticPressure) ? _leftTubularOsmoticPressure->GetValue() : 0.0;
  ;
  current->renalBloodFlow = (_renalBloodFlow) ? _renalBloodFlow->GetValue() : 0.0;
  ;
  current->renalPlasmaFlow = (_renalPlasmaFlow) ? _renalPlasmaFlow->GetValue() : 0.0;
  ;
  current->renalVascularResistance = (_renalVascularResistance) ? _renalVascularResistance->GetValue() : 0.0;
  ;
  current->rightAfferentArterioleResistance = (_rightAfferentArterioleResistance) ? _rightAfferentArterioleResistance->GetValue() : 0.0;
  ;
  current->rightBowmansCapsulesHydrostaticPressure = (_rightBowmansCapsulesHydrostaticPressure) ? _rightBowmansCapsulesHydrostaticPressure->GetValue() : 0.0;
  ;
  current->rightBowmansCapsulesOsmoticPressure = (_rightBowmansCapsulesOsmoticPressure) ? _rightBowmansCapsulesOsmoticPressure->GetValue() : 0.0;
  ;
  current->rightEfferentArterioleResistance = (_rightEfferentArterioleResistance) ? _rightEfferentArterioleResistance->GetValue() : 0.0;
  ;
  current->rightGlomerularCapillariesHydrostaticPressure = (_rightGlomerularCapillariesHydrostaticPressure) ? _rightGlomerularCapillariesHydrostaticPressure->GetValue() : 0.0;
  ;
  current->rightGlomerularCapillariesOsmoticPressure = (_rightGlomerularCapillariesOsmoticPressure) ? _rightGlomerularCapillariesOsmoticPressure->GetValue() : 0.0;
  ;
  current->rightGlomerularFiltrationCoefficient = (_rightGlomerularFiltrationCoefficient) ? _rightGlomerularFiltrationCoefficient->GetValue() : 0.0;
  ;
  current->rightGlomerularFiltrationRate = (_rightGlomerularFiltrationRate) ? _rightGlomerularFiltrationRate->GetValue() : 0.0;
  ;
  current->rightGlomerularFiltrationSurfaceArea = (_rightGlomerularFiltrationSurfaceArea) ? _rightGlomerularFiltrationSurfaceArea->GetValue() : 0.0;
  ;
  current->rightGlomerularFluidPermeability = (_rightGlomerularFluidPermeability) ? _rightGlomerularFluidPermeability->GetValue() : 0.0;
  ;
  current->rightFiltrationFraction = (_rightFiltrationFraction) ? _rightFiltrationFraction->GetValue() : 0.0;
  ;
  current->rightNetFiltrationPressure = (_rightNetFiltrationPressure) ? _rightNetFiltrationPressure->GetValue() : 0.0;
  ;
  current->rightNetReabsorptionPressure = (_rightNetReabsorptionPressure) ? _rightNetReabsorptionPressure->GetValue() : 0.0;
  ;
  current->rightPeritubularCapillariesHydrostaticPressure = (_rightPeritubularCapillariesHydrostaticPressure) ? _rightPeritubularCapillariesHydrostaticPressure->GetValue() : 0.0;
  ;
  current->rightPeritubularCapillariesOsmoticPressure = (_rightPeritubularCapillariesOsmoticPressure) ? _rightPeritubularCapillariesOsmoticPressure->GetValue() : 0.0;
  ;
  current->rightReabsorptionFiltrationCoefficient = (_rightReabsorptionFiltrationCoefficient) ? _rightReabsorptionFiltrationCoefficient->GetValue() : 0.0;
  ;
  current->rightReabsorptionRate = (_rightReabsorptionRate) ? _rightReabsorptionRate->GetValue() : 0.0;
  ;
  current->rightTubularReabsorptionFiltrationSurfaceArea = (_rightTubularReabsorptionFiltrationSurfaceArea) ? _rightTubularReabsorptionFiltrationSurfaceArea->GetValue() : 0.0;
  ;
  current->rightTubularReabsorptionFluidPermeability = (_rightTubularReabsorptionFluidPermeability) ? _rightTubularReabsorptionFluidPermeability->GetValue() : 0.0;
  ;
  current->rightTubularHydrostaticPressure = (_rightTubularHydrostaticPressure) ? _rightTubularHydrostaticPressure->GetValue() : 0.0;
  ;
  current->rightTubularOsmoticPressure = (_rightTubularOsmoticPressure) ? _rightTubularOsmoticPressure->GetValue() : 0.0;
  ;
  current->urinationRate = (_urinationRate) ? _urinationRate->GetValue() : 0.0;
  ;
  current->urineOsmolality = (_urineOsmolality) ? _urineOsmolality->GetValue() : 0.0;
  ;
  current->urineOsmolarity = (_urineOsmolarity) ? _urineOsmolarity->GetValue() : 0.0;
  ;
  current->urineProductionRate = (_urineProductionRate) ? _urineProductionRate->GetValue() : 0.0;
  ;
  current->meanUrineOutput = (_meanUrineOutput) ? _meanUrineOutput->GetValue() : 0.0;
  ;
  current->urineSpecificGravity = (_urineSpecificGravity) ? _urineSpecificGravity->GetValue() : 0.0;
  ;
  current->urineVolume = (_urineVolume) ? _urineVolume->GetValue() : 0.0;
  ;
  current->urineUreaNitrogenConcentration = (_urineUreaNitrogenConcentration) ? _urineUreaNitrogenConcentration->GetValue() : 0.0;
  ;

  //Respiratory
  auto& respiratory = _engine->GetRespiratory();
  current->alveolarArterialGradient = (_alveolarArterialGradient) ? _alveolarArterialGradient->GetValue() : 0.0;
  current->carricoIndex = (_carricoIndex) ? _carricoIndex->GetValue() : 0.0;
  current->endTidalCarbonDioxideFraction = (_endTidalCarbonDioxideFraction) ? _endTidalCarbonDioxideFraction->GetValue() : 0.0;
  current->endTidalCarbonDioxidePressure = (_endTidalCarbonDioxidePressure) ? _endTidalCarbonDioxidePressure->GetValue() : 0.0;
  current->expiratoryFlow = (_expiratoryFlow) ? _expiratoryFlow->GetValue() : 0.0;
  current->inspiratoryExpiratoryRatio = (_inspiratoryExpiratoryRatio) ? _inspiratoryExpiratoryRatio->GetValue() : 0.0;
  current->inspiratoryFlow = (_inspiratoryFlow) ? _inspiratoryFlow->GetValue() : 0.0;
  current->pulmonaryCompliance = (_pulmonaryCompliance) ? _pulmonaryCompliance->GetValue() : 0.0;
  current->pulmonaryResistance = (_pulmonaryResistance) ? _pulmonaryResistance->GetValue() : 0.0;
  current->respirationDriverPressure = (_respirationDriverPressure) ? _respirationDriverPressure->GetValue() : 0.0;
  current->respirationMusclePressure = (_respirationMusclePressure) ? _respirationMusclePressure->GetValue() : 0.0;
  current->respirationRate = (_respirationRate) ? _respirationRate->GetValue() : 0.0;
  current->specificVentilation = (_specificVentilation) ? _specificVentilation->GetValue() : 0.0;
  current->targetPulmonaryVentilation = (_targetPulmonaryVentilation) ? _targetPulmonaryVentilation->GetValue() : 0.0;
  current->tidalVolume = (_tidalVolume) ? _tidalVolume->GetValue() : 0.0;
  current->totalAlveolarVentilation = (_totalAlveolarVentilation) ? _totalAlveolarVentilation->GetValue() : 0.0;
  current->totalDeadSpaceVentilation = (_totalDeadSpaceVentilation) ? _totalDeadSpaceVentilation->GetValue() : 0.0;
  current->totalLungVolume = (_totalLungVolume) ? _totalLungVolume->GetValue() : 0.0;
  current->totalPulmonaryVentilation = (_totalPulmonaryVentilation) ? _totalPulmonaryVentilation->GetValue() : 0.0;
  current->transpulmonaryPressure = (_transpulmonaryPressure) ? _transpulmonaryPressure->GetValue() : 0.0;

  //Tissue
  auto& tissue = _engine->GetTissue();
  current->carbonDioxideProductionRate = (_carbonDioxideProductionRate) ? _carbonDioxideProductionRate->GetValue() : 0.0;
  current->dehydrationFraction = (_dehydrationFraction) ? _dehydrationFraction->GetValue() : 0.0;
  current->extracellularFluidVolume = (_extracellularFluidVolume) ? _extracellularFluidVolume->GetValue() : 0.0;
  current->extravascularFluidVolume = (_extravascularFluidVolume) ? _extravascularFluidVolume->GetValue() : 0.0;
  current->intracellularFluidPH = (_intracellularFluidPH) ? _intracellularFluidPH->GetValue() : 0.0;
  current->intracellularFluidVolume = (_intracellularFluidVolume) ? _intracellularFluidVolume->GetValue() : 0.0;
  current->totalBodyFluidVolume = (_totalBodyFluidVolume) ? _totalBodyFluidVolume->GetValue() : 0.0;
  current->oxygenConsumptionRate = (_oxygenConsumptionRate) ? _oxygenConsumptionRate->GetValue() : 0.0;
  current->respiratoryExchangeRatio = (_respiratoryExchangeRatio) ? _respiratoryExchangeRatio->GetValue() : 0.0;
  current->liverInsulinSetPoint = (_liverInsulinSetPoint) ? _liverInsulinSetPoint->GetValue() : 0.0;
  current->liverGlucagonSetPoint = (_liverGlucagonSetPoint) ? _liverGlucagonSetPoint->GetValue() : 0.0;
  current->muscleInsulinSetPoint = (_muscleInsulinSetPoint) ? _muscleInsulinSetPoint->GetValue() : 0.0;
  current->muscleGlucagonSetPoint = (_muscleGlucagonSetPoint) ? _muscleGlucagonSetPoint->GetValue() : 0.0;
  current->fatInsulinSetPoint = (_fatInsulinSetPoint) ? _fatInsulinSetPoint->GetValue() : 0.0;
  current->fatGlucagonSetPoint = (_fatGlucagonSetPoint) ? _fatGlucagonSetPoint->GetValue() : 0.0;
  current->liverGlycogen = (_liverGlycogen) ? _liverGlycogen->GetValue() : 0.0;
  current->muscleGlycogen = (_muscleGlycogen) ? _muscleGlycogen->GetValue() : 0.0;
  current->storedProtein = (_storedProtein) ? _storedProtein->GetValue() : 0.0;
  current->storedFat = (_storedFat) ? _storedFat->GetValue() : 0.0;

  return current;
}
//---------------------------------------------------------------------------------
auto Scenario::get_physiology_conditions() -> PatientConditions
{
  PatientConditions current;
  current.diabieties = _engine->GetConditions().HasDiabetesType1() | _engine->GetConditions().HasDiabetesType2();
  return current;
}
//---------------------------------------------------------------------------------
double Scenario::get_simulation_time()
{
  return _engine->GetSimulationTime().GetValue(biogears::TimeUnit::s);
}
//---------------------------------------------------------------------------------
void Scenario::parseSubstancesToLists()
{
  QDir subDirectory = QDir("substances");
  std::unique_ptr<CDM::ObjectData> subXmlData;
  CDM::SubstanceData* subData;
  CDM::SubstanceCompoundData* compoundData;
  std::string test = "test";
  QString qtest = QString::fromStdString(test);

  if (!subDirectory.exists()) {
    std::cout << "This is not the substance directory you're looking for";
  } else {
    QDirIterator subIt(subDirectory, QDirIterator::NoIteratorFlags);
    while (subIt.hasNext()) {
      auto it = subIt.next(); //Only used to advance iterator--don't really need the string that is returned by this function
      auto subFileInfo = subIt.fileInfo();
      if (subFileInfo.isFile()) {
        subData = nullptr;
        compoundData = nullptr;

        subXmlData = biogears::Serializer::ReadFile(subFileInfo.filePath().toStdString(), _engine->GetLogger());
        subData = dynamic_cast<CDM::SubstanceData*>(subXmlData.get());
        if (subData != nullptr) {
          if (subData->Pharmacodynamics().present() && subData->Pharmacokinetics().present()) {
            _drugs_list.append(QString::fromStdString(subData->Name()));
          }
          continue;
        }
        compoundData = dynamic_cast<CDM::SubstanceCompoundData*>(subXmlData.get());
        if (compoundData != nullptr) {
          if (compoundData->Classification().present()) {
            if (compoundData->Classification().get() == CDM::enumSubstanceClass::WholeBlood) {
              _transfusions_list.append(QString::fromStdString(compoundData->Name()));
            }
          } else {
            _compounds_list.append(QString::fromStdString(compoundData->Name()));
          }
          continue;
        }
      }
    }
  }
}
//---------------------------------------------------------------------------------
QVector<QString> Scenario::getDrugsList() 
{
  return _drugs_list;
}
//---------------------------------------------------------------------------------
QVector<QString> Scenario::getCompoundsList()
{
  return _compounds_list;
}
//---------------------------------------------------------------------------------
QVector<QString> Scenario::getTransfusionProductsList()
{
  return _transfusions_list;
}

}

#include <biogears/cdm/patient/actions/SEAsthmaAttack.h>
#include <biogears/cdm/patient/actions/SEBurnWound.h>
#include <biogears/cdm/patient/actions/SEHemorrhage.h>
#include <biogears/cdm/patient/actions/SEInfection.h>
#include <biogears/cdm/patient/actions/SESubstanceAdministration.h>
#include <biogears/cdm/patient/actions/SESubstanceBolus.h>
#include <biogears/cdm/patient/actions/SESubstanceCompoundInfusion.h>
#include <biogears/cdm/patient/actions/SESubstanceInfusion.h>
#include <biogears/cdm/patient/actions/SESubstanceOralDose.h>

namespace bio {
//---------------------------------------------------------------------------------
// ACTION FACTORY FUNCTIONS TO BE REFACTORED TO ACTION FACTORY LATER
void Scenario::create_hemorrhage_action(QString compartment, double ml_Per_min)
{
  auto action = std::make_unique<biogears::SEHemorrhage>();
  action->SetCompartment(compartment.toStdString());
  action->GetInitialRate().SetValue(ml_Per_min, biogears::VolumePerTimeUnit::mL_Per_min);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_asthma_action(double severity)
{
  auto action = std::make_unique<biogears::SEAsthmaAttack>();
  action->GetSeverity().SetValue(severity);

  _action_queue.as_source().insert(std::move(action));
}

void Scenario::create_substance_infusion_action(QString substance, double concentration_ug_Per_mL, double rate_mL_Per_min)
{
  biogears::SESubstance* sub = _engine->GetSubstances().GetSubstance(substance.toStdString());
  auto action = std::make_unique<biogears::SESubstanceInfusion>(*sub);
  action->GetConcentration().SetValue(concentration_ug_Per_mL, biogears::MassPerVolumeUnit::ug_Per_mL);
  action->GetRate().SetValue(rate_mL_Per_min, biogears::VolumePerTimeUnit::mL_Per_min);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_substance_bolus_action(QString substance, int route, double dose_mL, double concentration_ug_Per_mL)
{
  biogears::SESubstance* sub = _engine->GetSubstances().GetSubstance(substance.toStdString());
  auto action = std::make_unique<biogears::SESubstanceBolus>(*sub);
  action->SetAdminRoute((CDM::enumBolusAdministration::value)route);
  action->GetDose().SetValue(dose_mL, biogears::VolumeUnit::mL);
  action->GetConcentration().SetValue(concentration_ug_Per_mL, biogears::MassPerVolumeUnit::ug_Per_mL);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_substance_oral_action(QString substance, int route, double dose_mg)
{
  biogears::SESubstance* sub = _engine->GetSubstances().GetSubstance(substance.toStdString());
  auto action = std::make_unique<biogears::SESubstanceOralDose>(*sub);
  action->SetAdminRoute((CDM::enumOralAdministration::value)route);
  action->GetDose().SetValue(dose_mg, biogears::MassUnit::mg);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_burn_action(double tbsa)
{
  auto action = std::make_unique<biogears::SEBurnWound>();
  action->GetTotalBodySurfaceArea().SetValue(tbsa);

  _action_queue.as_source().insert(std::move(action));
}

void Scenario::create_infection_action(QString location, int severity, double mic_mg_Per_L)
{
  auto action = std::make_unique<biogears::SEInfection>();
  action->SetLocation(location.toStdString());
  action->SetSeverity((CDM::enumInfectionSeverity::value)severity);
  action->GetMinimumInhibitoryConcentration().SetValue(mic_mg_Per_L, biogears::MassPerVolumeUnit::mg_Per_L);

  _action_queue.as_source().insert(std::move(action));
}

} //namspace ui
