#include "Scenario.h"

#include <cmath>
#include <exception>

#include "PatientConditions.h"
#include "PatientMetrics.h"
#include "PatientState.h"

#include "Models/PhysiologyRequest.h"

//#include <biogears/version.h>
#include <biogears/cdm/compartment/fluid/SELiquidCompartment.h>
#include <biogears/cdm/compartment/substances/SELiquidSubstanceQuantity.h>
#include <biogears/cdm/patient/SEPatient.h>
#include <biogears/cdm/properties/SEScalar.h>
#include <biogears/cdm/properties/SEScalarTime.h>
#include <biogears/cdm/properties/SEScalarTimeMassPerVolume.h>
#include <biogears/cdm/properties/SEScalarTypes.h>
#include <biogears/cdm/properties/SEUnitScalar.h>
#include <biogears/cdm/substance/SESubstanceCompound.h>
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
  , _physiology_model(nullptr)
{
  _consoleLog = new QtLogForward(this);
  _logger.SetForward(_consoleLog);

  biogears::BioGears* engine = dynamic_cast<biogears::BioGears*>(_engine.get());
  engine->GetPatient().SetName(name.toStdString());

}
void Scenario::initialize_physiology_model()
{
  _physiology_model = std::make_unique<BioGearsData>(QString(_engine->GetPatient().GetName_cStr()), this).release();
  _physiology_model->initialize();
  emit physiologyChanged(_physiology_model);
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
  //"Open" command from visualizer sends full file path.  Getting fileName using QFileInfo gets state base name (e.g. StandardMale@0s.xml) relative to states folder
  //We could also remove the "file:\\\" tag, but that seems like it could cause platform specific issues
  QFileInfo pFile(patient_file);
  load_patient(pFile.fileName());
  _logger.SetForward(_consoleLog);
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

  return _engine->GetEnvironment()->GetName_cStr();
}
//-------------------------------------------------------------------------------
Scenario& Scenario::patient_name(QString name)
{
  biogears::BioGears* engine = dynamic_cast<biogears::BioGears*>(_engine.get());
  engine->GetPatient().SetName(name.toStdString());
  return *this;
}
//-------------------------------------------------------------------------------
Scenario& Scenario::environment_name(QString name)
{
  biogears::BioGears* engine = dynamic_cast<biogears::BioGears*>(_engine.get());
  engine->GetEnvironment().SetName(name.toStdString());
  return *this;
}
//-------------------------------------------------------------------------------
Scenario& Scenario::load_patient(QString file)
{
  substances_to_lists();

  auto path = file.toStdString();
  if (!QFileInfo::exists(file)) {
    path = "states/" + path;
    if (!QFileInfo::exists("states/" + file)) {
      throw std::runtime_error("Unable to locate " + file.toStdString());
    }
  }

  _engine_mutex.lock(); //< I ran in to some -O2 issues when using an std::lock_guard in msvc

  _engine = std::make_unique<biogears::BioGearsEngine>(&_logger);
  _logger.SetForward(_consoleLog);

  if (_engine->LoadState(path)) {
    if(!_physiology_model) {
      initialize_physiology_model();
    }
    auto vitals = static_cast<BioGearsData*>(_physiology_model->index(BioGearsData::VITALS, 0, QModelIndex()).internalPointer());
      {
      vitals->child(0)->unit_scalar(&_engine->GetCardiovascular().GetSystolicArterialPressure());
      vitals->child(1)->unit_scalar(&_engine->GetCardiovascular().GetDiastolicArterialPressure());
      vitals->child(2)->unit_scalar(&_engine->GetRespiratory().GetRespirationRate());
      vitals->child(3)->scalar(&_engine->GetBloodChemistry().GetOxygenSaturation());
      vitals->child(4)->unit_scalar(&_engine->GetCardiovascular().GetBloodVolume());
      vitals->child(5)->unit_scalar(&_engine->GetCardiovascular().GetCentralVenousPressure());
          }

    auto cardiopulmonary = static_cast<BioGearsData*>(_physiology_model->index(BioGearsData::CARDIOPULMONARY, 0, QModelIndex()).internalPointer());
      {
      cardiopulmonary->child(0)->unit_scalar(&_engine->GetCardiovascular().GetCerebralPerfusionPressure());
      cardiopulmonary->child(1)->unit_scalar(&_engine->GetCardiovascular().GetIntracranialPressure());
      cardiopulmonary->child(2)->unit_scalar(&_engine->GetCardiovascular().GetSystemicVascularResistance());
      cardiopulmonary->child(3)->unit_scalar(&_engine->GetCardiovascular().GetPulsePressure());
      cardiopulmonary->child(4)->scalar(&_engine->GetRespiratory().GetInspiratoryExpiratoryRatio());
      cardiopulmonary->child(5)->unit_scalar(&_engine->GetRespiratory().GetTotalPulmonaryVentilation());
      cardiopulmonary->child(6)->unit_scalar(&_engine->GetRespiratory().GetTotalLungVolume());
      cardiopulmonary->child(7)->unit_scalar(&_engine->GetRespiratory().GetTidalVolume());
      cardiopulmonary->child(8)->unit_scalar(&_engine->GetRespiratory().GetTotalAlveolarVentilation());
      cardiopulmonary->child(9)->unit_scalar(&_engine->GetRespiratory().GetTotalDeadSpaceVentilation());
      cardiopulmonary->child(0)->unit_scalar(&_engine->GetRespiratory().GetTranspulmonaryPressure());
    }

    auto blood_chemistry = static_cast<BioGearsData*>(_physiology_model->index(BioGearsData::BLOOD_CHEMISTRY, 0, QModelIndex()).internalPointer());
      {

      blood_chemistry->child(0)->scalar(&_engine->GetBloodChemistry().GetCarbonDioxideSaturation());
      blood_chemistry->child(1)->scalar(&_engine->GetBloodChemistry().GetCarbonMonoxideSaturation());
      blood_chemistry->child(2)->scalar(&_engine->GetBloodChemistry().GetOxygenSaturation());
      blood_chemistry->child(3)->scalar(&_engine->GetBloodChemistry().GetArterialBloodPH());
      blood_chemistry->child(4)->scalar(&_engine->GetBloodChemistry().GetHematocrit());
      blood_chemistry->child(5)->scalar(&_engine->GetBloodChemistry().GetStrongIonDifference());
      }

    auto energy_and_metabolism = static_cast<BioGearsData*>(_physiology_model->index(BioGearsData::ENERGY_AND_METABOLISM, 0, QModelIndex()).internalPointer());
      {
      energy_and_metabolism->child(0)->unit_scalar(&_engine->GetEnergy().GetCoreTemperature());
      energy_and_metabolism->child(1)->unit_scalar(&_engine->GetEnergy().GetSweatRate());
      energy_and_metabolism->child(2)->unit_scalar(&_engine->GetEnergy().GetSkinTemperature());
      energy_and_metabolism->child(3)->unit_scalar(&_engine->GetEnergy().GetTotalMetabolicRate());
        auto stomach_contents = energy_and_metabolism->child(4);
        auto& neutrition = _engine->GetGastrointestinal().GetStomachContents();
        {
        stomach_contents->child(0)->unit_scalar( &neutrition.GetCalcium());
        stomach_contents->child(1)->unit_scalar( &neutrition.GetCarbohydrate());
        stomach_contents->child(2)->unit_scalar( &neutrition.GetFat());
        stomach_contents->child(3)->unit_scalar( &neutrition.GetProtein());
        stomach_contents->child(4)->unit_scalar( &neutrition.GetSodium());
        stomach_contents->child(5)->unit_scalar( &neutrition.GetWater());
        }
      energy_and_metabolism->child(4)->unit_scalar( &_engine->GetTissue().GetOxygenConsumptionRate());
      energy_and_metabolism->child(5)->unit_scalar( &_engine->GetTissue().GetCarbonDioxideProductionRate());
      }

    auto renal_fluid_balance = static_cast<BioGearsData*>(_physiology_model->index(BioGearsData::RENAL_FLUID_BALANCE, 0, QModelIndex()).internalPointer());
      {

      renal_fluid_balance->child(0)->unit_scalar(&_engine->GetRenal().GetMeanUrineOutput());
      renal_fluid_balance->child(1)->unit_scalar(&_engine->GetRenal().GetUrineProductionRate());
      renal_fluid_balance->child(2)->unit_scalar(&_engine->GetRenal().GetUrineVolume());
      renal_fluid_balance->child(3)->unit_scalar(&_engine->GetRenal().GetUrineOsmolality());
      renal_fluid_balance->child(4)->unit_scalar(&_engine->GetRenal().GetUrineOsmolarity());
      renal_fluid_balance->child(5)->unit_scalar(&_engine->GetRenal().GetGlomerularFiltrationRate());
      renal_fluid_balance->child(6)->unit_scalar(&_engine->GetRenal().GetRenalBloodFlow());

      renal_fluid_balance->child(7)->unit_scalar(&_engine->GetTissue().GetTotalBodyFluidVolume());
      renal_fluid_balance->child(8)->unit_scalar(&_engine->GetTissue().GetExtracellularFluidVolume());
      renal_fluid_balance->child(9)->unit_scalar(&_engine->GetTissue().GetIntracellularFluidVolume());
      renal_fluid_balance->child(10)->unit_scalar(&_engine->GetTissue().GetExtravascularFluidVolume());
      }

    auto substances = static_cast<BioGearsData*>(_physiology_model->index(BioGearsData::SUBSTANCES, 0, QModelIndex()).internalPointer());
      {
      substances->child(0)->unit_scalar(&_engine->GetCardiovascular().GetCerebralPerfusionPressure());
      }

    auto customs = static_cast<BioGearsData*>(_physiology_model->index(BioGearsData::CUSTOM, 0, QModelIndex()).internalPointer());
      {
      customs->child(0)->unit_scalar(&_engine->GetCardiovascular().GetCerebralPerfusionPressure());
      customs->child(1)->unit_scalar(&_engine->GetCardiovascular().GetCerebralPerfusionPressure());
      customs->child(2)->unit_scalar(&_engine->GetCardiovascular().GetCerebralPerfusionPressure());
      customs->child(3)->unit_scalar(&_engine->GetCardiovascular().GetCerebralPerfusionPressure());
      }

    emit stateLoad();
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
      while ((current_time - prev) < 100ms) {
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
      _engine->ProcessAction(*_action_queue.consume());
    }
    _engine->AdvanceModelTime(0.1, biogears::TimeUnit::s);
    _engine_mutex.unlock();

    emit timeAdvance(_engine->GetSimulationTime(biogears::TimeUnit::s));

  } else {
    std::this_thread::sleep_for(16ms);
  }
}
//---------------------------------------------------------------------------------
auto Scenario::get_physiology_state() -> PatientState
{
  if (!_current_state) {
    _current_state = std::make_unique<PatientState>();
  }
  
  const auto& patient = _engine->GetPatient();
  _current_state->alive = "True";
  _current_state->tacycardia = "False";

  _current_state->age = (patient.HasAge()) ? QString::number(patient.GetAge(biogears::TimeUnit::yr), 'f', 0)
                                   : "N/A";
  _current_state->height_cm = (patient.HasHeight()) ? QString::number(patient.GetHeight(biogears::LengthUnit::cm), 'f', 0)
                                            : "N/A";
  _current_state->gender = (!patient.HasGender()) ? "N/A"
                                          : (patient.GetGender() == CDM::enumSex::Male) ? "Male"
                                                                                        : "Female";
  _current_state->weight_kg = (patient.HasWeight()) ? QString::number(patient.GetWeight(biogears::MassUnit::kg), 'f', 2)
                                            : "N/A";
  if (patient.HasWeight()) {
    auto BSA = std::sqrt(patient.GetHeight(biogears::LengthUnit::cm) * patient.GetWeight(biogears::MassUnit::kg) / 3600.0);
    _current_state->body_surface_area_m_sq = QString::number(BSA, 'f', 2);
    auto BMI = patient.GetWeight(biogears::MassUnit::kg) / std::pow(patient.GetHeight(biogears::LengthUnit::m), 2);
    _current_state->body_mass_index_kg_per_m_sq = QString::number(BMI, 'f', 2);
  } else {
    _current_state->body_surface_area_m_sq = "N/A";
    _current_state->body_mass_index_kg_per_m_sq = "N/A";
  }
  _current_state->body_fat_pct = (patient.HasBodyFatFraction()) ? QString::number(patient.GetBodyFatFraction(), 'f', 2)
                                                        : "N/A";
  //TODO: Lets take intensity and make a series of animated GIFs inspired off vault-boy
  _current_state->exercise_state = (_engine->GetActions().GetPatientActions().HasExercise()) ? "Running" : "Standing";

  return *_current_state;
}
//---------------------------------------------------------------------------------
auto Scenario::get_physiology_metrics() -> PatientMetrics*
{
  if(!_current_metrics) {
  _current_metrics = std::make_unique<PatientMetrics>();
  }

  _current_metrics->simulationTime = _engine->GetSimulationTime(biogears::TimeUnit::s);
  _current_metrics->timeStep = _engine->GetTimeStep(biogears::TimeUnit::s);

  _current_metrics->heart_rate_bpm = (_engine->GetCardiovascular().HasHeartRate())
    ? QString::number(_engine->GetCardiovascular().GetHeartRate().GetValue(biogears::FrequencyUnit::Per_min), 'f', 2)
    : "N/A";
  _current_metrics->respiratory_rate_bpm = (_engine->GetRespiratory().HasRespirationRate())
    ? QString::number(_engine->GetRespiratory().GetRespirationRate().GetValue(biogears::FrequencyUnit::Per_min), 'f', 2)
    : "N/A";
  _current_metrics->core_temperature_c = (_engine->GetEnergy().HasCoreTemperature())
    ? QString::number(_engine->GetEnergy().GetCoreTemperature(biogears::TemperatureUnit::C), 'f', 2)
    : "N/A";
  _current_metrics->oxygen_saturation_pct = (_engine->GetBloodChemistry().HasOxygenSaturation())
    ? QString::number(_engine->GetBloodChemistry().GetOxygenSaturation().GetValue(), 'f', 2)
    : "N/A";
  _current_metrics->systolic_blood_pressure_mmHg = (_engine->GetCardiovascular().HasSystolicArterialPressure())
    ? QString::number(_engine->GetCardiovascular().GetSystolicArterialPressure().GetValue(biogears::PressureUnit::mmHg), 'f', 2)
    : "N/A";
  _current_metrics->diastolic_blood_pressure_mmHg = (_engine->GetCardiovascular().HasDiastolicArterialPressure())
    ? QString::number(_engine->GetCardiovascular().GetDiastolicArterialPressure().GetValue(biogears::PressureUnit::mmHg), 'f', 2)
    : "N/A";

  auto& bloodChemistry = _engine->GetBloodChemistry();
  _current_metrics->arterialBloodPH = (bloodChemistry.HasArterialBloodPH()) ? bloodChemistry.GetArterialBloodPH().GetValue() : 0.0;
  _current_metrics->arterialBloodPHBaseline = (bloodChemistry.HasArterialBloodPHBaseline()) ? bloodChemistry.GetArterialBloodPHBaseline().GetValue() : 0.0;
  _current_metrics->bloodDensity = (bloodChemistry.HasBloodDensity()) ? bloodChemistry.GetBloodDensity().GetValue() : 0.0;
  _current_metrics->bloodSpecificHeat = (bloodChemistry.HasBloodSpecificHeat()) ? bloodChemistry.GetBloodSpecificHeat().GetValue() : 0.0;
  _current_metrics->bloodUreaNitrogenConcentration = (bloodChemistry.HasBloodUreaNitrogenConcentration()) ? bloodChemistry.GetBloodUreaNitrogenConcentration().GetValue() : 0.0;
  _current_metrics->carbonDioxideSaturation = (bloodChemistry.HasCarbonDioxideSaturation()) ? bloodChemistry.GetCarbonDioxideSaturation().GetValue() : 0.0;
  _current_metrics->carbonMonoxideSaturation = (bloodChemistry.HasCarbonMonoxideSaturation()) ? bloodChemistry.GetCarbonMonoxideSaturation().GetValue() : 0.0;
  _current_metrics->hematocrit = (bloodChemistry.HasHematocrit()) ? bloodChemistry.GetHematocrit().GetValue() : 0.0;
  _current_metrics->hemoglobinContent = (bloodChemistry.HasHemoglobinContent()) ? bloodChemistry.GetHemoglobinContent().GetValue() : 0.0;
  _current_metrics->oxygenSaturation = (bloodChemistry.HasOxygenSaturation()) ? bloodChemistry.GetOxygenSaturation().GetValue() : 0.0;
  _current_metrics->phosphate = (bloodChemistry.HasPhosphate()) ? bloodChemistry.GetPhosphate().GetValue() : 0.0;
  _current_metrics->plasmaVolume = (bloodChemistry.HasPlasmaVolume()) ? bloodChemistry.GetPlasmaVolume().GetValue() : 0.0;
  _current_metrics->pulseOximetry = (bloodChemistry.HasPulseOximetry()) ? bloodChemistry.GetPulseOximetry().GetValue() : 0.0;
  _current_metrics->redBloodCellAcetylcholinesterase = (bloodChemistry.HasRedBloodCellAcetylcholinesterase()) ? bloodChemistry.GetRedBloodCellAcetylcholinesterase().GetValue() : 0.0;
  _current_metrics->redBloodCellCount = (bloodChemistry.HasRedBloodCellCount()) ? bloodChemistry.GetRedBloodCellCount().GetValue() : 0.0;
  _current_metrics->shuntFraction = (bloodChemistry.HasShuntFraction()) ? bloodChemistry.GetShuntFraction().GetValue() : 0.0;
  _current_metrics->strongIonDifference = (bloodChemistry.HasStrongIonDifference()) ? bloodChemistry.GetStrongIonDifference().GetValue() : 0.0;
  _current_metrics->totalBilirubin = (bloodChemistry.HasTotalBilirubin()) ? bloodChemistry.GetTotalBilirubin().GetValue() : 0.0;
  _current_metrics->totalProteinConcentration = (bloodChemistry.HasTotalProteinConcentration()) ? bloodChemistry.GetTotalProteinConcentration().GetValue() : 0.0;
  _current_metrics->venousBloodPH = (bloodChemistry.HasVenousBloodPH()) ? bloodChemistry.GetVenousBloodPH().GetValue() : 0.0;
  _current_metrics->volumeFractionNeutralPhospholipidInPlasma = (bloodChemistry.HasVolumeFractionNeutralPhospholipidInPlasma()) ? bloodChemistry.GetVolumeFractionNeutralPhospholipidInPlasma().GetValue() : 0.0;
  _current_metrics->volumeFractionNeutralLipidInPlasma = (bloodChemistry.HasVolumeFractionNeutralLipidInPlasma()) ? bloodChemistry.GetVolumeFractionNeutralLipidInPlasma().GetValue() : 0.0;
  _current_metrics->arterialCarbonDioxidePressure = (bloodChemistry.HasArterialCarbonDioxidePressure()) ? bloodChemistry.GetArterialCarbonDioxidePressure().GetValue() : 0.0;
  _current_metrics->arterialOxygenPressure = (bloodChemistry.HasArterialOxygenPressure()) ? bloodChemistry.GetArterialOxygenPressure().GetValue() : 0.0;
  _current_metrics->pulmonaryArterialCarbonDioxidePressure = (bloodChemistry.HasPulmonaryArterialCarbonDioxidePressure()) ? bloodChemistry.GetPulmonaryArterialCarbonDioxidePressure().GetValue() : 0.0;
  _current_metrics->pulmonaryArterialOxygenPressure = (bloodChemistry.HasPulmonaryArterialOxygenPressure()) ? bloodChemistry.GetPulmonaryArterialOxygenPressure().GetValue() : 0.0;
  _current_metrics->pulmonaryVenousCarbonDioxidePressure = (bloodChemistry.HasPulmonaryVenousCarbonDioxidePressure()) ? bloodChemistry.GetPulmonaryVenousCarbonDioxidePressure().GetValue() : 0.0;
  _current_metrics->pulmonaryVenousOxygenPressure = (bloodChemistry.HasPulmonaryVenousOxygenPressure()) ? bloodChemistry.GetPulmonaryVenousOxygenPressure().GetValue() : 0.0;
  _current_metrics->venousCarbonDioxidePressure = (bloodChemistry.HasVenousCarbonDioxidePressure()) ? bloodChemistry.GetVenousCarbonDioxidePressure().GetValue() : 0.0;
  _current_metrics->venousOxygenPressure = (bloodChemistry.HasVenousOxygenPressure()) ? bloodChemistry.GetVenousOxygenPressure().GetValue() : 0.0;
  _current_metrics->inflammatoryResponse = bloodChemistry.HasInflammatoryResponse();

  auto& inflamatoryResponse = bloodChemistry.GetInflammatoryResponse();
  _current_metrics->inflammatoryResponseLocalPathogen = (inflamatoryResponse.HasLocalPathogen()) ? inflamatoryResponse.GetLocalPathogen().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseLocalMacrophage = (inflamatoryResponse.HasLocalMacrophage()) ? inflamatoryResponse.GetLocalMacrophage().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseLocalNeutrophil = (inflamatoryResponse.HasLocalNeutrophil()) ? inflamatoryResponse.GetLocalNeutrophil().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseLocalBarrier = (inflamatoryResponse.HasLocalBarrier()) ? inflamatoryResponse.GetLocalBarrier().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseBloodPathogen = (inflamatoryResponse.HasBloodPathogen()) ? inflamatoryResponse.GetBloodPathogen().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseTrauma = (inflamatoryResponse.HasTrauma()) ? inflamatoryResponse.GetTrauma().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseMacrophageResting = (inflamatoryResponse.HasMacrophageResting()) ? inflamatoryResponse.GetMacrophageResting().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseMacrophageActive = (inflamatoryResponse.HasMacrophageActive()) ? inflamatoryResponse.GetMacrophageActive().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseNeutrophilResting = (inflamatoryResponse.HasNeutrophilResting()) ? inflamatoryResponse.GetNeutrophilResting().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseNeutrophilActive = (inflamatoryResponse.HasNeutrophilActive()) ? inflamatoryResponse.GetNeutrophilActive().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseInducibleNOSPre = (inflamatoryResponse.HasInducibleNOSPre()) ? inflamatoryResponse.GetInducibleNOSPre().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseInducibleNOS = (inflamatoryResponse.HasInducibleNOS()) ? inflamatoryResponse.GetInducibleNOS().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseConstitutiveNOS = (inflamatoryResponse.HasConstitutiveNOS()) ? inflamatoryResponse.GetConstitutiveNOS().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseNitrate = (inflamatoryResponse.HasNitrate()) ? inflamatoryResponse.GetNitrate().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseNitricOxide = (inflamatoryResponse.HasNitricOxide()) ? inflamatoryResponse.GetNitricOxide().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseTumorNecrosisFactor = (inflamatoryResponse.HasTumorNecrosisFactor()) ? inflamatoryResponse.GetTumorNecrosisFactor().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseInterleukin6 = (inflamatoryResponse.HasInterleukin6()) ? inflamatoryResponse.GetInterleukin6().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseInterleukin10 = (inflamatoryResponse.HasInterleukin10()) ? inflamatoryResponse.GetInterleukin10().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseInterleukin12 = (inflamatoryResponse.HasInterleukin12()) ? inflamatoryResponse.GetInterleukin12().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseCatecholamines = (inflamatoryResponse.HasCatecholamines()) ? inflamatoryResponse.GetCatecholamines().GetValue() : 0.0;
  _current_metrics->inflammatoryResponseTissueIntegrity = (inflamatoryResponse.HasTissueIntegrity()) ? inflamatoryResponse.GetTissueIntegrity().GetValue() : 0.0;

  auto& cardiovascular = _engine->GetCardiovascular();
  _current_metrics->arterialPressure = (cardiovascular.HasArterialPressure()) ? cardiovascular.GetArterialPressure().GetValue() : 0.0;
  _current_metrics->bloodVolume = (cardiovascular.HasBloodVolume()) ? cardiovascular.GetBloodVolume().GetValue() : 0.0;
  _current_metrics->cardiacIndex = (cardiovascular.HasCardiacIndex()) ? cardiovascular.GetCardiacIndex().GetValue() : 0.0;
  _current_metrics->cardiacOutput = (cardiovascular.HasCardiacOutput()) ? cardiovascular.GetCardiacOutput().GetValue() : 0.0;
  _current_metrics->centralVenousPressure = (cardiovascular.HasCentralVenousPressure()) ? cardiovascular.GetCentralVenousPressure().GetValue() : 0.0;
  _current_metrics->cerebralBloodFlow = (cardiovascular.HasCerebralBloodFlow()) ? cardiovascular.GetCerebralBloodFlow().GetValue() : 0.0;
  _current_metrics->cerebralPerfusionPressure = (cardiovascular.HasCerebralPerfusionPressure()) ? cardiovascular.GetCerebralPerfusionPressure().GetValue() : 0.0;
  _current_metrics->diastolicArterialPressure = (cardiovascular.HasDiastolicArterialPressure()) ? cardiovascular.GetDiastolicArterialPressure().GetValue() : 0.0;
  _current_metrics->heartEjectionFraction = (cardiovascular.HasHeartEjectionFraction()) ? cardiovascular.GetHeartEjectionFraction().GetValue() : 0.0;
  _current_metrics->heartRate = (cardiovascular.HasHeartRate()) ? cardiovascular.GetHeartRate().GetValue() : 0.0;
  _current_metrics->heartStrokeVolume = (cardiovascular.HasHeartStrokeVolume()) ? cardiovascular.GetHeartStrokeVolume().GetValue() : 0.0;
  _current_metrics->intracranialPressure = (cardiovascular.HasIntracranialPressure()) ? cardiovascular.GetIntracranialPressure().GetValue() : 0.0;
  _current_metrics->meanArterialPressure = (cardiovascular.HasMeanArterialPressure()) ? cardiovascular.GetMeanArterialPressure().GetValue() : 0.0;
  _current_metrics->meanArterialCarbonDioxidePartialPressure = (cardiovascular.HasMeanArterialCarbonDioxidePartialPressure()) ? cardiovascular.GetMeanArterialCarbonDioxidePartialPressure().GetValue() : 0.0;
  _current_metrics->meanArterialCarbonDioxidePartialPressureDelta = (cardiovascular.HasMeanArterialCarbonDioxidePartialPressureDelta()) ? cardiovascular.GetMeanArterialCarbonDioxidePartialPressureDelta().GetValue() : 0.0;
  _current_metrics->meanCentralVenousPressure = (cardiovascular.HasMeanCentralVenousPressure()) ? cardiovascular.GetMeanCentralVenousPressure().GetValue() : 0.0;
  _current_metrics->meanSkinFlow = (cardiovascular.HasMeanSkinFlow()) ? cardiovascular.GetMeanSkinFlow().GetValue() : 0.0;
  _current_metrics->pulmonaryArterialPressure = (cardiovascular.HasPulmonaryArterialPressure()) ? cardiovascular.GetPulmonaryArterialPressure().GetValue() : 0.0;
  _current_metrics->pulmonaryCapillariesWedgePressure = (cardiovascular.HasPulmonaryCapillariesWedgePressure()) ? cardiovascular.GetPulmonaryCapillariesWedgePressure().GetValue() : 0.0;
  _current_metrics->pulmonaryDiastolicArterialPressure = (cardiovascular.HasPulmonaryDiastolicArterialPressure()) ? cardiovascular.GetPulmonaryDiastolicArterialPressure().GetValue() : 0.0;
  _current_metrics->pulmonaryMeanArterialPressure = (cardiovascular.HasPulmonaryMeanArterialPressure()) ? cardiovascular.GetPulmonaryMeanArterialPressure().GetValue() : 0.0;
  _current_metrics->pulmonaryMeanCapillaryFlow = (cardiovascular.HasPulmonaryMeanArterialPressure()) ? cardiovascular.GetPulmonaryMeanArterialPressure().GetValue() : 0.0;
  _current_metrics->pulmonaryMeanShuntFlow = (cardiovascular.HasPulmonaryMeanShuntFlow()) ? cardiovascular.GetPulmonaryMeanShuntFlow().GetValue() : 0.0;
  _current_metrics->pulmonarySystolicArterialPressure = (cardiovascular.HasPulmonarySystolicArterialPressure()) ? cardiovascular.GetPulmonarySystolicArterialPressure().GetValue() : 0.0;
  _current_metrics->pulmonaryVascularResistance = (cardiovascular.HasPulmonaryVascularResistance()) ? cardiovascular.GetPulmonaryVascularResistance().GetValue() : 0.0;
  _current_metrics->pulmonaryVascularResistanceIndex = (cardiovascular.HasPulmonaryVascularResistanceIndex()) ? cardiovascular.GetPulmonaryVascularResistanceIndex().GetValue() : 0.0;
  _current_metrics->pulsePressure = (cardiovascular.HasPulsePressure()) ? cardiovascular.GetPulsePressure().GetValue() : 0.0;
  _current_metrics->systemicVascularResistance = (cardiovascular.HasSystemicVascularResistance()) ? cardiovascular.GetSystemicVascularResistance().GetValue() : 0.0;
  _current_metrics->systolicArterialPressure = (cardiovascular.HasSystolicArterialPressure()) ? cardiovascular.GetSystolicArterialPressure().GetValue() : 0.0;

  auto& drugs = _engine->GetDrugs();
  _current_metrics->bronchodilationLevel = (drugs.HasBronchodilationLevel()) ? drugs.GetBronchodilationLevel().GetValue() : 0.0;
  _current_metrics->heartRateChange = (drugs.HasHeartRateChange()) ? drugs.GetHeartRateChange().GetValue() : 0.0;
  _current_metrics->meanBloodPressureChange = (drugs.HasMeanBloodPressureChange()) ? drugs.GetMeanBloodPressureChange().GetValue() : 0.0;
  _current_metrics->neuromuscularBlockLevel = (drugs.HasNeuromuscularBlockLevel()) ? drugs.GetNeuromuscularBlockLevel().GetValue() : 0.0;
  _current_metrics->pulsePressureChange = (drugs.HasPulsePressureChange()) ? drugs.GetPulsePressureChange().GetValue() : 0.0;
  _current_metrics->respirationRateChange = (drugs.HasRespirationRateChange()) ? drugs.GetRespirationRateChange().GetValue() : 0.0;
  _current_metrics->sedationLevel = (drugs.HasSedationLevel()) ? drugs.GetSedationLevel().GetValue() : 0.0;
  _current_metrics->tidalVolumeChange = (drugs.HasTidalVolumeChange()) ? drugs.GetTidalVolumeChange().GetValue() : 0.0;
  _current_metrics->tubularPermeabilityChange = (drugs.HasTubularPermeabilityChange()) ? drugs.GetTubularPermeabilityChange().GetValue() : 0.0;
  _current_metrics->centralNervousResponse = (drugs.HasCentralNervousResponse()) ? drugs.GetCentralNervousResponse().GetValue() : 0.0;

  auto& endocrine = _engine->GetEndocrine();
  _current_metrics->insulinSynthesisRate = (endocrine.HasInsulinSynthesisRate()) ? endocrine.GetInsulinSynthesisRate().GetValue() : 0.0;
  _current_metrics->glucagonSynthesisRate = (endocrine.HasGlucagonSynthesisRate()) ? endocrine.GetGlucagonSynthesisRate().GetValue() : 0.0;

  auto& energy = _engine->GetEnergy();
  _current_metrics->achievedExerciseLevel = (energy.HasAchievedExerciseLevel()) ? energy.GetAchievedExerciseLevel().GetValue() : 0.0;
  _current_metrics->chlorideLostToSweat = (energy.HasChlorideLostToSweat()) ? energy.GetChlorideLostToSweat().GetValue() : 0.0;
  _current_metrics->coreTemperature = (energy.HasCoreTemperature()) ? energy.GetCoreTemperature().GetValue(biogears::TemperatureUnit::F) : 0.0;
  _current_metrics->creatinineProductionRate = (energy.HasCreatinineProductionRate()) ? energy.GetCreatinineProductionRate().GetValue() : 0.0;
  _current_metrics->exerciseMeanArterialPressureDelta = (energy.HasExerciseMeanArterialPressureDelta()) ? energy.GetExerciseMeanArterialPressureDelta().GetValue() : 0.0;
  _current_metrics->fatigueLevel = (energy.HasFatigueLevel()) ? energy.GetFatigueLevel().GetValue() : 0.0;
  _current_metrics->lactateProductionRate = (energy.HasLactateProductionRate()) ? energy.GetLactateProductionRate().GetValue() : 0.0;
  _current_metrics->potassiumLostToSweat = (energy.HasPotassiumLostToSweat()) ? energy.GetPotassiumLostToSweat().GetValue() : 0.0;
  _current_metrics->skinTemperature = (energy.HasSkinTemperature()) ? energy.GetSkinTemperature().GetValue(biogears::TemperatureUnit::F) : 0.0;
  _current_metrics->sodiumLostToSweat = (energy.HasSodiumLostToSweat()) ? energy.GetSodiumLostToSweat().GetValue() : 0.0;
  _current_metrics->sweatRate = (energy.HasSweatRate()) ? energy.GetSweatRate().GetValue() : 0.0;
  _current_metrics->totalMetabolicRate = (energy.HasTotalMetabolicRate()) ? energy.GetTotalWorkRateLevel().GetValue() : 0.0;
  _current_metrics->totalWorkRateLevel = (energy.HasTotalWorkRateLevel()) ? energy.GetTotalWorkRateLevel().GetValue() : 0.0;

  auto& gastrointestinal = _engine->GetGastrointestinal();
  _current_metrics->chymeAbsorptionRate = (gastrointestinal.HasChymeAbsorptionRate()) ? gastrointestinal.GetChymeAbsorptionRate().GetValue() : 0.0;
  _current_metrics->stomachContents_calcium = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasCalcium()) ? gastrointestinal.GetStomachContents().GetCalcium().GetValue() : 0.0;
  _current_metrics->stomachContents_carbohydrates = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasCarbohydrate()) ? gastrointestinal.GetStomachContents().GetCarbohydrate().GetValue() : 0.0;
  _current_metrics->stomachContents_carbohydrateDigationRate = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasCarbohydrateDigestionRate()) ? gastrointestinal.GetStomachContents().GetCarbohydrateDigestionRate().GetValue() : 0.0;
  _current_metrics->stomachContents_fat = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasFat()) ? gastrointestinal.GetStomachContents().GetFat().GetValue() : 0.0;
  _current_metrics->stomachContents_fatDigtationRate = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasFatDigestionRate()) ? gastrointestinal.GetStomachContents().GetFatDigestionRate().GetValue() : 0.0;
  _current_metrics->stomachContents_protien = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasProtein()) ? gastrointestinal.GetStomachContents().GetProtein().GetValue() : 0.0;
  _current_metrics->stomachContents_protienDigtationRate = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasProteinDigestionRate()) ? gastrointestinal.GetStomachContents().GetProteinDigestionRate().GetValue() : 0.0;
  _current_metrics->stomachContents_sodium = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasSodium()) ? gastrointestinal.GetStomachContents().GetSodium().GetValue() : 0.0;
  _current_metrics->stomachContents_water = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasWater()) ? gastrointestinal.GetStomachContents().GetWater().GetValue() : 0.0;

  auto& hepatic = _engine->GetHepatic();
  _current_metrics->hepaticGluconeogenesisRate = (hepatic.HasHepaticGluconeogenesisRate()) ? hepatic.GetHepaticGluconeogenesisRate().GetValue() : 0.0;
  _current_metrics->ketoneproductionRate = (hepatic.HasKetoneProductionRate()) ? hepatic.GetKetoneProductionRate().GetValue() : 0.0;

  auto& nervous = _engine->GetNervous();
  _current_metrics->baroreceptorHeartRateScale = (nervous.HasBaroreceptorHeartRateScale()) ? nervous.GetBaroreceptorHeartRateScale().GetValue() : 0.0;
  _current_metrics->baroreceptorHeartElastanceScale = (nervous.HasBaroreceptorHeartElastanceScale()) ? nervous.GetBaroreceptorHeartElastanceScale().GetValue() : 0.0;
  _current_metrics->baroreceptorResistanceScale = (nervous.HasBaroreceptorResistanceScale()) ? nervous.GetBaroreceptorResistanceScale().GetValue() : 0.0;
  _current_metrics->baroreceptorComplianceScale = (nervous.HasBaroreceptorComplianceScale()) ? nervous.GetBaroreceptorComplianceScale().GetValue() : 0.0;
  _current_metrics->chemoreceptorHeartRateScale = (nervous.HasChemoreceptorHeartRateScale()) ? nervous.GetChemoreceptorHeartRateScale().GetValue() : 0.0;
  _current_metrics->chemoreceptorHeartElastanceScale = (nervous.HasChemoreceptorHeartElastanceScale()) ? nervous.GetChemoreceptorHeartElastanceScale().GetValue() : 0.0;
  _current_metrics->painVisualAnalogueScale = (nervous.HasPainVisualAnalogueScale()) ? nervous.GetPainVisualAnalogueScale().GetValue() : 0.0;

  //TODO: Implement Pupillary Response  ReactivityModifier  ShapeModifier  SizeModifier;
  _current_metrics->leftEyePupillaryResponse = 0.0;
  _current_metrics->rightEyePupillaryResponse = 0.0;
  //Renal
  auto& renal = _engine->GetRenal();
  _current_metrics->glomerularFiltrationRate = (renal.HasGlomerularFiltrationRate()) ? renal.GetGlomerularFiltrationRate().GetValue() : 0.0;
  _current_metrics->filtrationFraction = (renal.HasFiltrationFraction()) ? renal.GetFiltrationFraction().GetValue() : 0.0;
  _current_metrics->leftAfferentArterioleResistance = (renal.HasLeftAfferentArterioleResistance()) ? renal.GetLeftAfferentArterioleResistance().GetValue() : 0.0;
  _current_metrics->leftBowmansCapsulesHydrostaticPressure = (renal.HasLeftBowmansCapsulesHydrostaticPressure()) ? renal.GetLeftBowmansCapsulesHydrostaticPressure().GetValue() : 0.0;
  _current_metrics->leftBowmansCapsulesOsmoticPressure = (renal.HasLeftBowmansCapsulesOsmoticPressure()) ? renal.GetLeftBowmansCapsulesOsmoticPressure().GetValue() : 0.0;
  _current_metrics->leftEfferentArterioleResistance = (renal.HasLeftEfferentArterioleResistance()) ? renal.GetLeftEfferentArterioleResistance().GetValue() : 0.0;
  _current_metrics->leftGlomerularCapillariesHydrostaticPressure = (renal.HasLeftGlomerularCapillariesHydrostaticPressure()) ? renal.GetLeftGlomerularCapillariesHydrostaticPressure().GetValue() : 0.0;
  _current_metrics->leftGlomerularCapillariesOsmoticPressure = (renal.HasLeftGlomerularCapillariesOsmoticPressure()) ? renal.GetLeftGlomerularCapillariesOsmoticPressure().GetValue() : 0.0;
  _current_metrics->leftGlomerularFiltrationCoefficient = (renal.HasLeftGlomerularFiltrationCoefficient()) ? renal.GetLeftGlomerularFiltrationCoefficient().GetValue() : 0.0;
  _current_metrics->leftGlomerularFiltrationRate = (renal.HasLeftGlomerularFiltrationRate()) ? renal.GetLeftGlomerularFiltrationRate().GetValue() : 0.0;
  _current_metrics->leftGlomerularFiltrationSurfaceArea = (renal.HasLeftGlomerularFiltrationSurfaceArea()) ? renal.GetLeftGlomerularFiltrationSurfaceArea().GetValue() : 0.0;
  _current_metrics->leftGlomerularFluidPermeability = (renal.HasLeftGlomerularFluidPermeability()) ? renal.GetLeftGlomerularFluidPermeability().GetValue() : 0.0;
  _current_metrics->leftFiltrationFraction = (renal.HasLeftFiltrationFraction()) ? renal.GetLeftFiltrationFraction().GetValue() : 0.0;
  _current_metrics->leftNetFiltrationPressure = (renal.HasLeftNetFiltrationPressure()) ? renal.GetLeftNetFiltrationPressure().GetValue() : 0.0;
  _current_metrics->leftNetReabsorptionPressure = (renal.HasLeftNetReabsorptionPressure()) ? renal.GetLeftNetReabsorptionPressure().GetValue() : 0.0;
  _current_metrics->leftPeritubularCapillariesHydrostaticPressure = (renal.HasLeftPeritubularCapillariesHydrostaticPressure()) ? renal.GetLeftPeritubularCapillariesHydrostaticPressure().GetValue() : 0.0;
  _current_metrics->leftPeritubularCapillariesOsmoticPressure = (renal.HasLeftPeritubularCapillariesOsmoticPressure()) ? renal.GetLeftPeritubularCapillariesOsmoticPressure().GetValue() : 0.0;
  _current_metrics->leftReabsorptionFiltrationCoefficient = (renal.HasLeftReabsorptionFiltrationCoefficient()) ? renal.GetLeftReabsorptionFiltrationCoefficient().GetValue() : 0.0;
  _current_metrics->leftReabsorptionRate = (renal.HasLeftReabsorptionRate()) ? renal.GetLeftReabsorptionRate().GetValue() : 0.0;
  _current_metrics->leftTubularReabsorptionFiltrationSurfaceArea = (renal.HasLeftTubularReabsorptionFiltrationSurfaceArea()) ? renal.GetLeftTubularReabsorptionFiltrationSurfaceArea().GetValue() : 0.0;
  _current_metrics->leftTubularReabsorptionFluidPermeability = (renal.HasLeftTubularReabsorptionFluidPermeability()) ? renal.GetLeftTubularReabsorptionFluidPermeability().GetValue() : 0.0;
  _current_metrics->leftTubularHydrostaticPressure = (renal.HasLeftTubularHydrostaticPressure()) ? renal.GetLeftTubularHydrostaticPressure().GetValue() : 0.0;
  _current_metrics->leftTubularOsmoticPressure = (renal.HasLeftTubularOsmoticPressure()) ? renal.GetLeftTubularOsmoticPressure().GetValue() : 0.0;
  _current_metrics->renalBloodFlow = (renal.HasRenalBloodFlow()) ? renal.GetRenalBloodFlow().GetValue() : 0.0;
  _current_metrics->renalPlasmaFlow = (renal.HasRenalPlasmaFlow()) ? renal.GetRenalPlasmaFlow().GetValue() : 0.0;
  _current_metrics->renalVascularResistance = (renal.HasRenalVascularResistance()) ? renal.GetRenalVascularResistance().GetValue() : 0.0;
  _current_metrics->rightAfferentArterioleResistance = (renal.HasRightAfferentArterioleResistance()) ? renal.GetRightAfferentArterioleResistance().GetValue() : 0.0;
  _current_metrics->rightBowmansCapsulesHydrostaticPressure = (renal.HasRightBowmansCapsulesHydrostaticPressure()) ? renal.GetRightBowmansCapsulesHydrostaticPressure().GetValue() : 0.0;
  _current_metrics->rightBowmansCapsulesOsmoticPressure = (renal.HasRightBowmansCapsulesOsmoticPressure()) ? renal.GetRightBowmansCapsulesOsmoticPressure().GetValue() : 0.0;
  _current_metrics->rightEfferentArterioleResistance = (renal.HasRightEfferentArterioleResistance()) ? renal.GetRightEfferentArterioleResistance().GetValue() : 0.0;
  _current_metrics->rightGlomerularCapillariesHydrostaticPressure = (renal.HasRightGlomerularCapillariesHydrostaticPressure()) ? renal.GetRightGlomerularCapillariesHydrostaticPressure().GetValue() : 0.0;
  _current_metrics->rightGlomerularCapillariesOsmoticPressure = (renal.HasRightGlomerularCapillariesOsmoticPressure()) ? renal.GetRightGlomerularCapillariesOsmoticPressure().GetValue() : 0.0;
  _current_metrics->rightGlomerularFiltrationCoefficient = (renal.HasRightGlomerularFiltrationCoefficient()) ? renal.GetRightGlomerularFiltrationCoefficient().GetValue() : 0.0;
  _current_metrics->rightGlomerularFiltrationRate = (renal.HasRightGlomerularFiltrationRate()) ? renal.GetRightGlomerularFiltrationRate().GetValue() : 0.0;
  _current_metrics->rightGlomerularFiltrationSurfaceArea = (renal.HasRightGlomerularFiltrationSurfaceArea()) ? renal.GetRightGlomerularFiltrationSurfaceArea().GetValue() : 0.0;
  _current_metrics->rightGlomerularFluidPermeability = (renal.HasRightGlomerularFluidPermeability()) ? renal.GetRightGlomerularFluidPermeability().GetValue() : 0.0;
  _current_metrics->rightFiltrationFraction = (renal.HasRightFiltrationFraction()) ? renal.GetRightFiltrationFraction().GetValue() : 0.0;
  _current_metrics->rightNetFiltrationPressure = (renal.HasRightNetFiltrationPressure()) ? renal.GetRightNetFiltrationPressure().GetValue() : 0.0;
  _current_metrics->rightNetReabsorptionPressure = (renal.HasRightNetReabsorptionPressure()) ? renal.GetRightNetReabsorptionPressure().GetValue() : 0.0;
  _current_metrics->rightPeritubularCapillariesHydrostaticPressure = (renal.HasRightPeritubularCapillariesHydrostaticPressure()) ? renal.GetRightPeritubularCapillariesHydrostaticPressure().GetValue() : 0.0;
  _current_metrics->rightPeritubularCapillariesOsmoticPressure = (renal.HasRightPeritubularCapillariesOsmoticPressure()) ? renal.GetRightPeritubularCapillariesOsmoticPressure().GetValue() : 0.0;
  _current_metrics->rightReabsorptionFiltrationCoefficient = (renal.HasRightReabsorptionFiltrationCoefficient()) ? renal.GetRightReabsorptionFiltrationCoefficient().GetValue() : 0.0;
  _current_metrics->rightReabsorptionRate = (renal.HasRightReabsorptionRate()) ? renal.GetRightReabsorptionRate().GetValue() : 0.0;
  _current_metrics->rightTubularReabsorptionFiltrationSurfaceArea = (renal.HasRightTubularReabsorptionFiltrationSurfaceArea()) ? renal.GetRightTubularReabsorptionFiltrationSurfaceArea().GetValue() : 0.0;
  _current_metrics->rightTubularReabsorptionFluidPermeability = (renal.HasRightTubularReabsorptionFluidPermeability()) ? renal.GetRightTubularReabsorptionFluidPermeability().GetValue() : 0.0;
  _current_metrics->rightTubularHydrostaticPressure = (renal.HasRightTubularHydrostaticPressure()) ? renal.GetRightTubularHydrostaticPressure().GetValue() : 0.0;
  _current_metrics->rightTubularOsmoticPressure = (renal.HasRightTubularOsmoticPressure()) ? renal.GetRightTubularOsmoticPressure().GetValue() : 0.0;
  _current_metrics->urinationRate = (renal.HasUrinationRate()) ? renal.GetUrinationRate().GetValue() : 0.0;
  _current_metrics->urineOsmolality = (renal.HasUrineOsmolality()) ? renal.GetUrineOsmolality().GetValue() : 0.0;
  _current_metrics->urineOsmolarity = (renal.HasUrineOsmolarity()) ? renal.GetUrineOsmolarity().GetValue() : 0.0;
  _current_metrics->urineProductionRate = (renal.HasUrineProductionRate()) ? renal.GetUrineProductionRate().GetValue() : 0.0;
  _current_metrics->meanUrineOutput = (renal.HasMeanUrineOutput()) ? renal.GetMeanUrineOutput().GetValue() : 0.0;
  _current_metrics->urineSpecificGravity = (renal.HasUrineSpecificGravity()) ? renal.GetUrineSpecificGravity().GetValue() : 0.0;
  _current_metrics->urineVolume = (renal.HasUrineVolume()) ? renal.GetUrineVolume().GetValue() : 0.0;
  _current_metrics->urineUreaNitrogenConcentration = (renal.HasUrineUreaNitrogenConcentration()) ? renal.GetUrineUreaNitrogenConcentration().GetValue() : 0.0;

  //Respiratory
  auto& respiratory = _engine->GetRespiratory();
  _current_metrics->alveolarArterialGradient = (respiratory.HasAlveolarArterialGradient()) ? respiratory.GetAlveolarArterialGradient().GetValue() : 0.0;
  _current_metrics->carricoIndex = (respiratory.HasCarricoIndex()) ? respiratory.GetCarricoIndex().GetValue() : 0.0;
  _current_metrics->endTidalCarbonDioxideFraction = (respiratory.HasEndTidalCarbonDioxideFraction()) ? respiratory.GetEndTidalCarbonDioxideFraction().GetValue() : 0.0;
  _current_metrics->endTidalCarbonDioxidePressure = (respiratory.HasEndTidalCarbonDioxidePressure()) ? respiratory.GetEndTidalCarbonDioxidePressure().GetValue() : 0.0;
  _current_metrics->expiratoryFlow = (respiratory.HasExpiratoryFlow()) ? respiratory.GetExpiratoryFlow().GetValue() : 0.0;
  _current_metrics->inspiratoryExpiratoryRatio = (respiratory.HasInspiratoryExpiratoryRatio()) ? respiratory.GetInspiratoryExpiratoryRatio().GetValue() : 0.0;
  _current_metrics->inspiratoryFlow = (respiratory.HasInspiratoryFlow()) ? respiratory.GetInspiratoryFlow().GetValue() : 0.0;
  _current_metrics->newBreathingCycle = _engine->GetPatient().IsEventActive(CDM::enumPatientEvent::StartOfInhale);
  _current_metrics->pulmonaryCompliance = (respiratory.HasPulmonaryCompliance()) ? respiratory.GetPulmonaryCompliance().GetValue() : 0.0;
  _current_metrics->pulmonaryResistance = (respiratory.HasPulmonaryResistance()) ? respiratory.GetPulmonaryResistance().GetValue() : 0.0;
  _current_metrics->respirationDriverPressure = (respiratory.HasRespirationDriverPressure()) ? respiratory.GetRespirationDriverPressure().GetValue() : 0.0;
  _current_metrics->respirationMusclePressure = (respiratory.HasRespirationMusclePressure()) ? respiratory.GetRespirationMusclePressure().GetValue() : 0.0;
  _current_metrics->respirationRate = (respiratory.HasRespirationRate()) ? respiratory.GetRespirationRate().GetValue() : 0.0;
  _current_metrics->specificVentilation = (respiratory.HasSpecificVentilation()) ? respiratory.GetSpecificVentilation().GetValue() : 0.0;
  _current_metrics->targetPulmonaryVentilation = (respiratory.HasTargetPulmonaryVentilation()) ? respiratory.GetTargetPulmonaryVentilation().GetValue() : 0.0;
  _current_metrics->tidalVolume = (respiratory.HasTidalVolume()) ? respiratory.GetTidalVolume().GetValue() : 0.0;
  _current_metrics->totalAlveolarVentilation = (respiratory.HasTotalAlveolarVentilation()) ? respiratory.GetTotalAlveolarVentilation().GetValue() : 0.0;
  _current_metrics->totalDeadSpaceVentilation = (respiratory.HasTotalDeadSpaceVentilation()) ? respiratory.GetTotalDeadSpaceVentilation().GetValue() : 0.0;
  _current_metrics->totalLungVolume = (respiratory.HasTotalLungVolume()) ? respiratory.GetTotalLungVolume().GetValue() : 0.0;
  _current_metrics->totalPulmonaryVentilation = (respiratory.HasTotalPulmonaryVentilation()) ? respiratory.GetTotalPulmonaryVentilation().GetValue() : 0.0;
  _current_metrics->transpulmonaryPressure = (respiratory.HasTranspulmonaryPressure()) ? respiratory.GetTranspulmonaryPressure().GetValue() : 0.0;

  //Tissue
  auto& tissue = _engine->GetTissue();
  _current_metrics->carbonDioxideProductionRate = (tissue.HasCarbonDioxideProductionRate()) ? tissue.GetCarbonDioxideProductionRate().GetValue() : 0.0;
  _current_metrics->dehydrationFraction = (tissue.HasDehydrationFraction()) ? tissue.GetDehydrationFraction().GetValue() : 0.0;
  _current_metrics->extracellularFluidVolume = (tissue.HasExtracellularFluidVolume()) ? tissue.GetExtracellularFluidVolume().GetValue() : 0.0;
  _current_metrics->extravascularFluidVolume = (tissue.HasExtravascularFluidVolume()) ? tissue.GetExtravascularFluidVolume().GetValue() : 0.0;
  _current_metrics->intracellularFluidPH = (tissue.HasIntracellularFluidPH()) ? tissue.GetIntracellularFluidPH().GetValue() : 0.0;
  _current_metrics->intracellularFluidVolume = (tissue.HasIntracellularFluidVolume()) ? tissue.GetIntracellularFluidVolume().GetValue() : 0.0;
  _current_metrics->totalBodyFluidVolume = (tissue.HasTotalBodyFluidVolume()) ? tissue.GetTotalBodyFluidVolume().GetValue() : 0.0;
  _current_metrics->oxygenConsumptionRate = (tissue.HasOxygenConsumptionRate()) ? tissue.GetOxygenConsumptionRate().GetValue() : 0.0;
  _current_metrics->respiratoryExchangeRatio = (tissue.HasRespiratoryExchangeRatio()) ? tissue.GetRespiratoryExchangeRatio().GetValue() : 0.0;
  _current_metrics->liverInsulinSetPoint = (tissue.HasLiverInsulinSetPoint()) ? tissue.GetLiverInsulinSetPoint().GetValue() : 0.0;
  _current_metrics->liverGlucagonSetPoint = (tissue.HasLiverGlucagonSetPoint()) ? tissue.GetLiverGlucagonSetPoint().GetValue() : 0.0;
  _current_metrics->muscleInsulinSetPoint = (tissue.HasMuscleInsulinSetPoint()) ? tissue.GetMuscleInsulinSetPoint().GetValue() : 0.0;
  _current_metrics->muscleGlucagonSetPoint = (tissue.HasMuscleGlucagonSetPoint()) ? tissue.GetMuscleGlucagonSetPoint().GetValue() : 0.0;
  _current_metrics->fatInsulinSetPoint = (tissue.HasFatInsulinSetPoint()) ? tissue.GetFatInsulinSetPoint().GetValue() : 0.0;
  _current_metrics->fatGlucagonSetPoint = (tissue.HasFatGlucagonSetPoint()) ? tissue.GetFatGlucagonSetPoint().GetValue() : 0.0;
  _current_metrics->liverGlycogen = (tissue.HasLiverGlycogen()) ? tissue.GetLiverGlycogen().GetValue() : 0.0;
  _current_metrics->muscleGlycogen = (tissue.HasMuscleGlycogen()) ? tissue.GetMuscleGlycogen().GetValue() : 0.0;
  _current_metrics->storedProtein = (tissue.HasStoredProtein()) ? tissue.GetStoredProtein().GetValue() : 0.0;
  _current_metrics->storedFat = (tissue.HasStoredFat()) ? tissue.GetStoredFat().GetValue() : 0.0;
  return _current_metrics.get();
}
//---------------------------------------------------------------------------------
auto Scenario::get_physiology_conditions() -> PatientConditions
{
  if (!_current_conditions) {
    _current_conditions = std::make_unique<PatientConditions>();
  }
  _current_conditions->diabieties = _engine->GetConditions().HasDiabetesType1() | _engine->GetConditions().HasDiabetesType2();
  return *_current_conditions;
}
//---------------------------------------------------------------------------------
QVariantMap Scenario::get_physiology_substances()
{
  //substanceMap.getSubstanceMap().clear();
  biogears::BioGears* engine = dynamic_cast<biogears::BioGears*>(_engine.get());
  biogears::SETissueCompartment* lKidney = engine->GetCompartments().GetTissueCompartment(BGE::TissueCompartment::LeftKidney);
  biogears::SETissueCompartment* rKidney = engine->GetCompartments().GetTissueCompartment(BGE::TissueCompartment::RightKidney);
  biogears::SETissueCompartment* liver = engine->GetCompartments().GetTissueCompartment(BGE::TissueCompartment::Liver);

  biogears::SELiquidCompartment& lKidneyIntracellular = engine->GetCompartments().GetIntracellularFluid(*lKidney);
  biogears::SELiquidCompartment& rKidneyIntracellular = engine->GetCompartments().GetIntracellularFluid(*rKidney);
  biogears::SELiquidCompartment& liverIntracellular = engine->GetCompartments().GetIntracellularFluid(*liver);

  QVariant subVariant;
  Substance* sub;
  bool newActiveSub = false;

  for (auto _activeSub : _engine->GetSubstances().GetActiveSubstances()) {
    if ((_activeSub->GetState() != CDM::enumSubstanceState::Liquid) && (_activeSub->GetState() != CDM::enumSubstanceState::Gas)) {
      //This prevents us from tracking molecular (hemoglobin species) and whole blood components (cellular)--not of interest for PK or nutrition purposes
      continue;
    }
    //The substance data map is type QVariantMap<QString, QVarint>, which automatically converts to javascript object in QML (and automatically converts back to QVariantMap in C++)
    subVariant = substanceData[QString::fromStdString(_activeSub->GetName())];
    newActiveSub = false;
    if (!subVariant.isValid()) {
      //QVariantMap returns an invalid object if key is not found.  If the substance does not exist yet, make a new entry for it and add it to map.
      sub = new Substance();
      sub->name = QString::fromStdString(_activeSub->GetName());
      substanceData[QString::fromStdString(_activeSub->GetName())] = QVariant::fromValue<QObject*>(sub);
      newActiveSub = true;
    } else {
      //If the substance does exist, we jsut need to update its values.  Firt we need to convert it back to Substance type.
      //QVariant.value function requires custom type to be defined as metatype and also requires copy constructor to be defined
      sub = subVariant.value<Substance*>();
    }
    //Let's be smart about what we define for each substance -- only assign props that apply (e.g. oxygen does not need an AUC)

    //Every substance should have blood concentration, mass in body, mass in blood, mass in tissue
    sub->blood_concentration = _activeSub->HasBloodConcentration() ? _activeSub->GetBloodConcentration(biogears::MassPerVolumeUnit::ug_Per_L) : 0;
    sub->mass_in_body = _activeSub->HasMassInBody() ? _activeSub->GetMassInBody(biogears::MassUnit::ug) : 0;
    sub->mass_in_blood = _activeSub->HasMassInBlood() ? _activeSub->GetMassInBlood(biogears::MassUnit::ug) : 0;
    sub->mass_in_tissue = _activeSub->HasMassInTissue() ? _activeSub->GetMassInTissue(biogears::MassUnit::ug) : 0;
    //Only subs that are dissolved gases need alveolar transfer and end tidal.  Use relative diffusion coefficient to filter
    if (_activeSub->HasRelativeDiffusionCoefficient()) {
      sub->alveolar_transfer = _activeSub->HasAlveolarTransfer() ? _activeSub->GetAlveolarTransfer(biogears::VolumePerTimeUnit::mL_Per_s) : 0;
      sub->end_tidal_fraction = _activeSub->HasEndTidalFraction() ? _activeSub->GetEndTidalFraction().GetValue() : 0;
    }
    //Only subs that have PK need effect site, plasma, AUC
    if (_activeSub->HasPK()) {
      sub->effect_site_concentration = _activeSub->HasEffectSiteConcentration() ? _activeSub->GetEffectSiteConcentration(biogears::MassPerVolumeUnit::ug_Per_L) : 0;
      sub->plasma_concentration = _activeSub->HasPlasmaConcentration() ? _activeSub->GetPlasmaConcentration(biogears::MassPerVolumeUnit::ug_Per_L) : 0;
      sub->area_under_curve = _activeSub->HasAreaUnderCurve() ? _activeSub->GetAreaUnderCurve(biogears::TimeMassPerVolumeUnit::hr_ug_Per_mL) : 0;
    }
    //Assign clearances, if applicable
    if (_activeSub->HasClearance()) {
      if (_activeSub->GetClearance().HasRenalClearance()) {
        sub->renal_mass_cleared = (lKidneyIntracellular.HasSubstanceQuantity(*_activeSub) && rKidneyIntracellular.HasSubstanceQuantity(*_activeSub)) ? lKidneyIntracellular.GetSubstanceQuantity(*_activeSub)->GetMassCleared(biogears::MassUnit::ug) + rKidneyIntracellular.GetSubstanceQuantity(*_activeSub)->GetMassCleared(biogears::MassUnit::ug) : 0;
      }
      if (_activeSub->GetClearance().HasIntrinsicClearance()) {
        sub->hepatic_mass_cleared = liverIntracellular.HasSubstanceQuantity(*_activeSub) ? liverIntracellular.GetSubstanceQuantity(*_activeSub)->GetMassCleared(biogears::MassUnit::g) : 0;
      }
      if (_activeSub->GetClearance().HasSystemicClearance()) {
        sub->systemic_mass_cleared = _activeSub->HasSystemicMassCleared() ? _activeSub->GetSystemicMassCleared(biogears::MassUnit::ug) : 0;
      }
    }
    if (newActiveSub) {
      //Wait to emit until we have initialized substances properties
      emit activeSubstanceAdded(sub);
    }
  }

  return substanceData;
}
//---------------------------------------------------------------------------------
double Scenario::get_simulation_time()
{
  return _engine->GetSimulationTime(biogears::TimeUnit::s);
}
//---------------------------------------------------------------------------------
void Scenario::substances_to_lists()
{
  _drugs_list.clear();
  _compounds_list.clear();
  _transfusions_list.clear();

  QDir subDirectory = QDir("substances");
  std::unique_ptr<CDM::ObjectData> subXmlData;
  CDM::SubstanceData* subData;
  CDM::SubstanceCompoundData* compoundData;

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
QVector<QString> Scenario::get_drugs()
{
  return _drugs_list;
}
//---------------------------------------------------------------------------------
QVector<QString> Scenario::get_compounds()
{
  return _compounds_list;
}
//---------------------------------------------------------------------------------
QVector<QString> Scenario::get_transfusion_products()
{
  return _transfusions_list;
}
//---------------------------------------------------------------------------------
QtLogForward* Scenario::getLogFoward()
{
  return _consoleLog;
}

void Scenario::export_patient(QString patientFileName)
{
  std::string fileLoc = "./patients/" + patientFileName.toStdString();
  std::string fullPath = biogears::ResolvePath(fileLoc);
  biogears::CreateFilePath(fullPath);
  std::ofstream stream(fullPath);
  xml_schema::namespace_infomap info;
  info[""].name = "uri:/mil/tatrc/physiology/datamodel";

  std::unique_ptr<CDM::PatientData> pData(_engine->GetPatient().Unload());
  Patient(stream, *pData, info);
  stream.close();
  _engine->GetLogger()->Info("Saved patient " + fullPath);
  return;
}

void Scenario::export_environment(QString environmentFileName)
{
  std::string fileLoc = "./environments/" + environmentFileName.toStdString();
  std::string fullPath = biogears::ResolvePath(fileLoc);
  biogears::CreateFilePath(fullPath);
  std::ofstream stream(fullPath);
  xml_schema::namespace_infomap info;
  info[""].name = "uri:/mil/tatrc/physiology/datamodel";

  std::unique_ptr<CDM::EnvironmentData> eData(_engine->GetEnvironment().Unload());
  Environment(stream, *eData, info);
  stream.close();
  _engine->GetLogger()->Info("Saved environemnt: " + fullPath);
  return;
}

void Scenario::export_state(QString stateFileName)
{
  std::string fileLoc = "./states/" + stateFileName.toStdString();
  std::string fullPath = biogears::ResolvePath(fileLoc);
  save_state(QString::fromStdString(fullPath));
}

void Scenario::save_state(QString filePath)
{
  std::string stateFileFullPath = filePath.toStdString();
  biogears::CreateFilePath(stateFileFullPath);
  std::ofstream stream(stateFileFullPath);
  xml_schema::namespace_infomap info;
  info[""].name = "uri:/mil/tatrc/physiology/datamodel";

  std::unique_ptr<CDM::BioGearsStateData> state(new CDM::BioGearsStateData);

  state->contentVersion(BGE::Version);

  state.get()->AirwayMode(_engine->GetAirwayMode());
  state.get()->Intubation(_engine->GetIntubation());
  // Patient
  state->Patient(std::unique_ptr<CDM::PatientData>(_engine->GetPatient().Unload()));
  // Conditions
  std::vector<CDM::ConditionData*> conditions;
  _engine->GetConditions().Unload(conditions);
  for (CDM::ConditionData* cData : conditions)
    state->Condition().push_back(std::unique_ptr<CDM::ConditionData>(cData));
  // Actions
  std::vector<CDM::ActionData*> activeActions;
  _engine->GetActions().Unload(activeActions);
  for (CDM::ActionData* aData : activeActions)
    state->ActiveAction().push_back(std::unique_ptr<CDM::ActionData>(aData));
  // Active Substances/Compounds
  for (biogears::SESubstance* s : _engine->GetSubstances().GetActiveSubstances())
    state->ActiveSubstance().push_back(std::unique_ptr<CDM::SubstanceData>(s->Unload()));
  for (biogears::SESubstanceCompound* c : _engine->GetSubstances().GetActiveCompounds())
    state->ActiveSubstanceCompound().push_back(std::unique_ptr<CDM::SubstanceCompoundData>(c->Unload()));
  // Systems
  state->System().push_back(*(_engine->GetBloodChemistry().Unload()));
  state->System().push_back(*(_engine->GetCardiovascular().Unload()));
  state->System().push_back(*(_engine->GetDrugs().Unload()));
  state->System().push_back(*(_engine->GetEndocrine().Unload()));
  state->System().push_back(*(_engine->GetEnergy().Unload()));
  state->System().push_back(*(_engine->GetGastrointestinal().Unload()));
  state->System().push_back(*(_engine->GetHepatic().Unload()));
  state->System().push_back(*(_engine->GetNervous().Unload()));
  state->System().push_back(*(_engine->GetRenal().Unload()));
  state->System().push_back(*(_engine->GetRespiratory().Unload()));
  state->System().push_back(*(_engine->GetTissue().Unload()));
  state->System().push_back(*(_engine->GetEnvironment().Unload()));
  state->System().push_back(*(_engine->GetAnesthesiaMachine().Unload()));
  state->System().push_back(*(_engine->GetECG().Unload()));
  state->System().push_back(*(_engine->GetInhaler().Unload()));
  // Compartments
  state->CompartmentManager(*(_engine->GetCompartments().Unload()));
  // Configuration
  state->Configuration(*(_engine->GetConfiguration().Unload()));
  // Circuits
  state->CircuitManager(*(_engine->GetCircuits().Unload()));
  BioGearsState(stream, *state, info);
  stream.close();
  _engine->GetLogger()->Info("Saved state: " + stateFileFullPath);
}

}
#include <biogears/cdm/patient/actions/SEAcuteStress.h>
#include <biogears/cdm/patient/actions/SEAirwayObstruction.h>
#include <biogears/cdm/patient/actions/SEApnea.h>
#include <biogears/cdm/patient/actions/SEAsthmaAttack.h>
#include <biogears/cdm/patient/actions/SEBrainInjury.h>
#include <biogears/cdm/patient/actions/SEBronchoconstriction.h>
#include <biogears/cdm/patient/actions/SEBurnWound.h>
#include <biogears/cdm/patient/actions/SECardiacArrest.h>
#include <biogears/cdm/patient/actions/SEExercise.h>
#include <biogears/cdm/patient/actions/SEHemorrhage.h>
#include <biogears/cdm/patient/actions/SEInfection.h>
#include <biogears/cdm/patient/actions/SENeedleDecompression.h>
#include <biogears/cdm/patient/actions/SEPainStimulus.h>
#include <biogears/cdm/patient/actions/SESubstanceAdministration.h>
#include <biogears/cdm/patient/actions/SESubstanceBolus.h>
#include <biogears/cdm/patient/actions/SESubstanceCompoundInfusion.h>
#include <biogears/cdm/patient/actions/SESubstanceInfusion.h>
#include <biogears/cdm/patient/actions/SESubstanceOralDose.h>
#include <biogears/cdm/patient/actions/SETensionPneumothorax.h>
#include <biogears/cdm/patient/actions/SETourniquet.h>

namespace bio {
//---------------------------------------------------------------------------------
// ACTION FACTORY FUNCTIONS TO BE REFACTORED TO ACTION FACTORY LATER
void Scenario::create_hemorrhage_action(QString compartment, double ml_Per_min)
{
  auto action = std::make_unique<biogears::SEHemorrhage>();
  QRegExp space("\\s"); //Hemorrhage compartments names need white space removed to process correctly ("Left Leg" --> "LeftLeg").  This assumes there is only one white space character
  action->SetCompartment(compartment.remove(space).toStdString());
  action->GetInitialRate().SetValue(ml_Per_min, biogears::VolumePerTimeUnit::mL_Per_min);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_tourniquet_action(QString compartment, int level)
{
  auto action = std::make_unique<biogears::SETourniquet>();
  QRegExp space("\\s"); //Tourniquet compartments names need white space removed to process correctly ("Left Leg" --> "LeftLeg").  This assumes there is only one white space character
  action->SetCompartment(compartment.remove(space).toStdString());
  action->SetTourniquetLevel((CDM::enumTourniquetApplicationLevel::value)level);

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
void Scenario::create_substance_compound_infusion_action(QString compound, double bagVolume_mL, double rate_mL_Per_min)
{
  biogears::SESubstanceCompound* subCompound = _engine->GetSubstances().GetCompound(compound.toStdString());
  auto action = std::make_unique<biogears::SESubstanceCompoundInfusion>(*subCompound);
  action->GetBagVolume().SetValue(bagVolume_mL, biogears::VolumeUnit::mL);
  action->GetRate().SetValue(rate_mL_Per_min, biogears::VolumePerTimeUnit::mL_Per_min);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_blood_transfusion_action(QString compound, double bagVolume_mL, double rate_mL_Per_min)
{
  biogears::SESubstanceCompound* bloodProduct = _engine->GetSubstances().GetCompound(compound.toStdString());
  auto action = std::make_unique<biogears::SESubstanceCompoundInfusion>(*bloodProduct);
  action->GetBagVolume().SetValue(bagVolume_mL, biogears::VolumeUnit::mL);
  action->GetRate().SetValue(rate_mL_Per_min, biogears::VolumePerTimeUnit::mL_Per_min);

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
void Scenario::create_exercise_action(double intensity = 0.0, double workRate_W = 0.0)
{
  auto action = std::make_unique<biogears::SEExercise>();
  if (intensity > 0.0) {
    action->GetIntensity().SetValue(intensity);
  } else if (workRate_W > 0.0) {
    action->GetDesiredWorkRate().SetValue(workRate_W);
  } else {
    //Reach this block if both inputs are 0, meaning we turn off action)
    action->GetIntensity().SetValue(0.0);
  }

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_pain_stimulus_action(double severity, QString location)
{
  auto action = std::make_unique<biogears::SEPainStimulus>();
  action->GetSeverity().SetValue(severity);
  action->SetLocation(location.toStdString());

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_traumatic_brain_injury_action(double severity, int type)
{
  auto action = std::make_unique<biogears::SEBrainInjury>();
  action->GetSeverity().SetValue(severity);
  action->SetType((CDM::enumBrainInjuryType::value)type);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_tension_pneumothorax_action(double severity, int type, int side)
{
  auto action = std::make_unique<biogears::SETensionPneumothorax>();
  action->GetSeverity().SetValue(severity);
  action->SetType((CDM::enumPneumothoraxType::value)type);
  action->SetSide((CDM::enumSide::value)side);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_needle_decompression_action(int state, int side)
{
  auto action = std::make_unique<biogears::SENeedleDecompression>();
  action->SetActive((CDM::enumOnOff::value)state);
  action->SetSide((CDM::enumSide::value)side);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_cardiac_arrest_action(int state)
{
  auto action = std::make_unique<biogears::SECardiacArrest>();
  action->SetActive((CDM::enumOnOff::value)state);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_airway_obstruction_action(double severity)
{
  auto action = std::make_unique<biogears::SEAirwayObstruction>();
  action->GetSeverity().SetValue(severity);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_bronchoconstriction_action(double severity)
{
  auto action = std::make_unique<biogears::SEBronchoconstriction>();
  action->GetSeverity().SetValue(severity);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_apnea_action(double severity)
{
  auto action = std::make_unique<biogears::SEApnea>();
  action->GetSeverity().SetValue(severity);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_acute_stress_action(double severity)
{
  auto action = std::make_unique<biogears::SEAcuteStress>();
  action->GetSeverity().SetValue(severity);

  _action_queue.as_source().insert(std::move(action));
}

} //namspace ui
