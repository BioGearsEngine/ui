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
  , _new_respiratory_cycle(std::make_unique<biogears::SEScalar>(0.0))
{
  _consoleLog = new QtLogForward(this);
  _logger.SetForward(_consoleLog);

  biogears::BioGears* engine = dynamic_cast<biogears::BioGears*>(_engine.get());
  engine->GetPatient().SetName(name.toStdString());
}
void Scenario::setup_physiology_model()
{
  _physiology_model = std::make_unique<BioGearsData>(QString(_engine->GetPatient().GetName_cStr()), this).release();
  _physiology_model->initialize();
  emit physiologyChanged(_physiology_model);
}
//-------------------------------------------------------------------------------
void Scenario::setup_physiology_substances(BioGearsData* substances)
{
  //NOTE: Must be called after setup_physiology_model, but after engine->load_state
  //TODO: Destroy and Recreate substances ever load state or we will be hurting.
  //
  biogears::BioGears* engine = dynamic_cast<biogears::BioGears*>(_engine.get());
  biogears::SETissueCompartment* lKidney = engine->GetCompartments().GetTissueCompartment(BGE::TissueCompartment::LeftKidney);
  biogears::SETissueCompartment* rKidney = engine->GetCompartments().GetTissueCompartment(BGE::TissueCompartment::RightKidney);
  biogears::SETissueCompartment* liver = engine->GetCompartments().GetTissueCompartment(BGE::TissueCompartment::Liver);

  biogears::SELiquidCompartment& lKidneyIntracellular = engine->GetCompartments().GetIntracellularFluid(*lKidney);
  biogears::SELiquidCompartment& rKidneyIntracellular = engine->GetCompartments().GetIntracellularFluid(*rKidney);
  biogears::SELiquidCompartment& liverIntracellular = engine->GetCompartments().GetIntracellularFluid(*liver);

  for (auto& _activeSub : _engine->GetSubstances().GetActiveSubstances()) {
    if ((_activeSub->GetState() != CDM::enumSubstanceState::Liquid) && (_activeSub->GetState() != CDM::enumSubstanceState::Gas)) {
      //This prevents us from tracking molecular (hemoglobin species) and whole blood components (cellular)--not of interest for PK or nutrition purposes
      continue;
    }
    //The substance data map is type QVariantMap<QString, QVarint>, which automatically converts to javascript object in QML (and automatically converts back to QVariantMap in C++)
    auto substance = substances->append(QString("Substances"), QString::fromStdString(_activeSub->GetName()));
    substance->nested(true);
    //Every substance should have blood concentration, mass in body, mass in blood, mass in tissue
    auto metric = substance->append(substance->name(), "Blood Concentration");
    metric->unit_scalar(_activeSub->HasBloodConcentration() ? &_activeSub->GetBloodConcentration() : nullptr);
    metric = substance->append(substance->name(), "Mass in Body");
    metric->unit_scalar(_activeSub->HasMassInBody() ? &_activeSub->GetMassInBody() : nullptr);
    metric = substance->append(substance->name(), "Mass in Blood");
    metric->unit_scalar(_activeSub->HasMassInBlood() ? &_activeSub->GetMassInBlood() : nullptr);
    metric = substance->append(substance->name(), "Mass in Tissue");
    metric->unit_scalar(_activeSub->HasMassInTissue() ? &_activeSub->GetMassInTissue() : nullptr);
    //Only subs that are dissolved gases need alveolar transfer and end tidal.  Use relative diffusion coefficient to filter
    if (_activeSub->HasRelativeDiffusionCoefficient()) {
      metric = substance->append(substance->name(), "Alveolar Transfer");
      metric->unit_scalar(_activeSub->HasAlveolarTransfer() ? &_activeSub->GetAlveolarTransfer() : nullptr);
      metric = substance->append(substance->name(), "End Tidal Fraction");
      metric->scalar(_activeSub->HasEndTidalFraction() ? &_activeSub->GetEndTidalFraction() : nullptr);
    }
    //Only subs that have PK need effect site, plasma, AUC
    if (_activeSub->HasPK()) {
      metric = substance->append(substance->name(), "EffectSiteConcentration");
      metric->unit_scalar(_activeSub->HasEffectSiteConcentration() ? &_activeSub->GetEffectSiteConcentration() : nullptr);
      metric = substance->append(substance->name(), "PlasmaConcentration");
      metric->unit_scalar(_activeSub->HasPlasmaConcentration() ? &_activeSub->GetPlasmaConcentration() : nullptr);
      metric = substance->append(substance->name(), "AreaUnderCurv");
      metric->unit_scalar(_activeSub->HasAreaUnderCurve() ? &_activeSub->GetAreaUnderCurve() : nullptr);
    }
    //Assign clearances, if applicable
    if (_activeSub->HasClearance()) {
      if (_activeSub->GetClearance().HasRenalClearance()) {
        //TODO: Upgrade Scalar PTRs to be a vector of PTRs so that we can do composite equations like this.
        //TODO: Add Lambda functiosn for calculating data values from composite functions.
        metric = substance->append(substance->name(), "Renal Clearance");

        std::function<QString(void)> unitFunc = [&lKidneyIntracellular]() {
          return "ug";
        };
        std::function<double(void)> valueFunc = [&, _activeSub]() { 
                 return (lKidneyIntracellular.HasSubstanceQuantity(*_activeSub) && rKidneyIntracellular.HasSubstanceQuantity(*_activeSub)) ? 
                   lKidneyIntracellular.GetSubstanceQuantity(*_activeSub)->GetMassCleared(biogears::MassUnit::ug) + rKidneyIntracellular.GetSubstanceQuantity(*_activeSub)->GetMassCleared(biogears::MassUnit::ug)
                 : 0;
        };

        metric->custom(std::move(valueFunc), std::move(unitFunc));
      }
      if (_activeSub->GetClearance().HasIntrinsicClearance()) {
        metric = substance->append(substance->name(), "Intrinsic Clearance");
        metric->unit_scalar(liverIntracellular.HasSubstanceQuantity(*_activeSub) ? &liverIntracellular.GetSubstanceQuantity(*_activeSub)->GetMassCleared() : nullptr);
      }
      if (_activeSub->GetClearance().HasSystemicClearance()) {
        metric = substance->append(substance->name(), "Systemic Clearance");
        metric->unit_scalar(_activeSub->HasSystemicMassCleared() ? &_activeSub->GetSystemicMassCleared() : nullptr);
      }
    }
  }
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
    if (!_physiology_model) {
      setup_physiology_model();
    }
    auto vitals = static_cast<BioGearsData*>(_physiology_model->index(BioGearsData::VITALS, 0, QModelIndex()).internalPointer());
    {
      auto vital = vitals->child(0);
      {
        vital->child(0)->unit_scalar(&_engine->GetCardiovascular().GetSystolicArterialPressure());
        vital->child(1)->unit_scalar(&_engine->GetCardiovascular().GetDiastolicArterialPressure());
      }
      vitals->child(1)->unit_scalar(&_engine->GetRespiratory().GetRespirationRate());
      vitals->child(2)->scalar(&_engine->GetBloodChemistry().GetOxygenSaturation());
      vitals->child(3)->unit_scalar(&_engine->GetCardiovascular().GetBloodVolume());
      vitals->child(4)->unit_scalar(&_engine->GetCardiovascular().GetCentralVenousPressure());
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
      cardiopulmonary->child(10)->unit_scalar(&_engine->GetRespiratory().GetTranspulmonaryPressure());
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
        stomach_contents->child(0)->unit_scalar(&neutrition.GetCalcium());
        stomach_contents->child(1)->unit_scalar(&neutrition.GetCarbohydrate());
        stomach_contents->child(2)->unit_scalar(&neutrition.GetFat());
        stomach_contents->child(3)->unit_scalar(&neutrition.GetProtein());
        stomach_contents->child(4)->unit_scalar(&neutrition.GetSodium());
        stomach_contents->child(5)->unit_scalar(&neutrition.GetWater());
      }
      energy_and_metabolism->child(4)->unit_scalar(&_engine->GetTissue().GetOxygenConsumptionRate());
      energy_and_metabolism->child(5)->unit_scalar(&_engine->GetTissue().GetCarbonDioxideProductionRate());
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
    setup_physiology_substances(substances);

    auto customs = static_cast<BioGearsData*>(_physiology_model->index(BioGearsData::CUSTOM, 0, QModelIndex()).internalPointer());
    {
      auto custom = customs->child(0);
      {
        custom->child(0)->unit_scalar(&dynamic_cast<biogears::BioGears*>(_engine.get())->GetRespiratory().GetRespirationMusclePressure());
        custom->child(1)->unit_scalar(&dynamic_cast<biogears::BioGears*>(_engine.get())->GetRespiratory().GetTotalLungVolume());
        custom->child(2)->scalar(_new_respiratory_cycle.get());
        custom->rate(10);
      }
      customs->child(1)->unit_scalar(&_engine->GetCardiovascular().GetCerebralPerfusionPressure());
      customs->child(2)->unit_scalar(&_engine->GetCardiovascular().GetCerebralPerfusionPressure());
      customs->child(3)->unit_scalar(&_engine->GetCardiovascular().GetCerebralPerfusionPressure());
    }

    emit patientMetricsChanged(get_physiology_metrics());
    emit patientStateChanged(get_physiology_state());
    emit patientConditionsChanged(get_physiology_conditions());
    emit stateLoad();
  } else {
    _engine->GetLogger()->Error("Could not load state, check the error");
  }
  _engine_mutex.unlock();
  std::string log_message = "Successfully Loaded: "+path;
  _logger.Info(log_message);
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

    auto test = _engine->GetPatient().IsEventActive(CDM::enumPatientEvent::StartOfInhale);
    if (test)
      std::cout << test << "\n";

    _new_respiratory_cycle->SetValue(_engine->GetPatient().IsEventActive(CDM::enumPatientEvent::StartOfInhale));

    emit patientMetricsChanged(get_physiology_metrics());
    emit patientStateChanged(get_physiology_state());
    emit patientConditionsChanged(get_physiology_conditions());
    emit timeAdvance(_engine->GetSimulationTime(biogears::TimeUnit::s));

  } else {
    std::this_thread::sleep_for(16ms);
  }
}
//---------------------------------------------------------------------------------
auto Scenario::get_physiology_metrics() -> PatientMetrics*
{
  if (!_current_metrics) {
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

  return _current_metrics.get();
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
auto Scenario::get_physiology_conditions() -> PatientConditions
{
  if (!_current_conditions) {
    _current_conditions = std::make_unique<PatientConditions>();
  }

  _current_conditions->diabieties = _engine->GetConditions().HasDiabetesType1() | _engine->GetConditions().HasDiabetesType2();
  return *_current_conditions;
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

QVariantMap Scenario::edit_patient()
{
  //Create a QVariantMap with key = PropName and item = {value, unit}
  //Qml interpets QVariantMaps as Javascript objects, which we can index by prop name
  QVariantMap patientMap;

  //Open file dialog in patients folder to select patient
  QString patientFile = QFileDialog::getOpenFileName(nullptr, "Edit Patient", "./patients");
  if (patientFile.isNull()) {
    //File returns null string if user cancels without selecting a patient.  Return empty map (Qml side will check for this) 
    return patientMap;
  }
  //Load file and create and SEPatient object from it using serializer
  if (!QFileInfo::exists(patientFile)) {
    throw std::runtime_error("Unable to locate " + patientFile.toStdString());
  }
  std::unique_ptr<CDM::ObjectData> patientXmlData = biogears::Serializer::ReadFile(patientFile.toStdString(), _engine->GetLogger());
  CDM::PatientData* patientData = dynamic_cast<CDM::PatientData*>(patientXmlData.get());
  biogears::SEPatient* patient = new biogears::SEPatient(_engine->GetLogger());
  patient->Load(*patientData);

  //Each map entry is a list of two items.  patientField[0] = value, patientField[1] = unit (or enum selection)
  QList<QVariant> patientField{ "", "" };

  //Name
  patientField[0] = QString::fromStdString(patient->GetName());
  patientField[1] = "";
  patientMap["Name"] = patientField;
  //Gender
  patientField[0] = patient->GetGender();
  patientField[1] = "";
  patientMap["Gender"] = patientField;
  //Age
  if (patient->HasAge()) {
    patientField[0] = patient->GetAge(biogears::TimeUnit::yr);
    patientField[1] = "yr";
    patientMap["Age"] = patientField;
  }
  //Weight
  if (patient->HasWeight()) {
    patientField[0] = patient->GetWeight(biogears::MassUnit::lb);
    patientField[1] = "lb";
    patientMap["Weight"] = patientField;
  }
  //Height
  if (patient->HasHeight()) {
    patientField[0] = patient->GetHeight(biogears::LengthUnit::in);
    patientField[1] = "in";
    patientMap["Height"] = patientField;
  }
  //Body Fat Fraction
  if (patient->HasBodyFatFraction()) {
    patientField[0] = patient->GetBodyFatFraction().GetValue();
    patientField[1] = "";
    patientMap["BodyFatFraction"] = patientField;
  }
  //Blood Volume baseline
  if (patient->HasBloodVolumeBaseline()) {
    patientField[0] = patient->GetBloodVolumeBaseline(biogears::VolumeUnit::L);
    patientField[1] = "L";
    patientMap["BloodVolumeBaseline"] = patientField;
  }
  //Blood type
  if (patient->HasBloodType()) {
    int bloodType = 2 * patient->GetBloodType();
    if (!patient->GetBloodRh()) {
      ++bloodType;
    }
    patientField[0] = bloodType;
    patientField[1] = "";
    patientMap["BloodType"] = patientField;
  }
  //Diastolic pressure baseline
  if (patient->HasDiastolicArterialPressureBaseline()) {
    patientField[0] = patient->GetDiastolicArterialPressureBaseline(biogears::PressureUnit::mmHg);
    patientField[1] = "mmHg";
    patientMap["DiastolicArterialPressureBaseline"] = patientField;
  }
  //Systolic pressure baseline
  if (patient->HasSystolicArterialPressureBaseline()) {
    patientField[0] = patient->GetSystolicArterialPressureBaseline(biogears::PressureUnit::mmHg);
    patientField[1] = "mmHg";
    patientMap["SystolicArterialPressureBaseline"] = patientField;
  }
  //Heart rate minimum
  if (patient->HasHeartRateMinimum()) {
    patientField[0] = patient->GetHeartRateMinimum(biogears::FrequencyUnit::Per_min);
    patientField[1] = "1/min";
    patientMap["HeartRateMinimum"] = patientField;
  }
  //Heart rate maximum
  if (patient->HasHeartRateMaximum()) {
    patientField[0] = patient->GetHeartRateMaximum(biogears::FrequencyUnit::Per_min);
    patientField[1] = "1/min";
    patientMap["HeartRateMaximum"] = patientField;
  }
  //Respiration rate baseline
  if (patient->HasRespirationRateBaseline()) {
    patientField[0] = patient->GetRespirationRateBaseline(biogears::FrequencyUnit::Per_min);
    patientField[1] = "1/min";
    patientMap["RespirationRateBaseline"] = patientField;
  }
  //Alveoli surface area
  if (patient->HasAlveoliSurfaceArea()) {
    patientField[0] = patient->GetAlveoliSurfaceArea(biogears::AreaUnit::m2);
    patientField[1] = "m^2";
    patientMap["AlveoliSurfaceArea"] = patientField;
  }
  //Right lung ratio
  if (patient->HasRightLungRatio()) {
    patientField[0] = patient->GetRightLungRatio().GetValue();
    patientField[1] = "";
    patientMap["RightLungRatio"] = patientField;
  }
  //Functional residual capacity
  if (patient->HasFunctionalResidualCapacity()) {
    patientField[0] = patient->GetFunctionalResidualCapacity(biogears::VolumeUnit::L);
    patientField[1] = "L";
    patientMap["FunctionalResidualCapacity"] = patientField;
  }
  //Residual volume
  if (patient->HasResidualVolume()) {
    patientField[0] = patient->GetResidualVolume(biogears::VolumeUnit::L);
    patientField[1] = "L";
    patientMap["ResidualVolume"] = patientField;
  }
  //Total lung capacity
  if (patient->HasTotalLungCapacity()) {
    patientField[0] = patient->GetTotalLungCapacity(biogears::VolumeUnit::L);
    patientField[1] = "L";
    patientMap["TotalLungCapacity"] = patientField;
  }
  //Skin surface area
  if (patient->HasSkinSurfaceArea()) {
    patientField[0] = patient->GetSkinSurfaceArea(biogears::AreaUnit::m2);
    patientField[1] = "m^2";
    patientMap["SkinSurfaceArea"] = patientField;
  }
  //Max work rate
  if (patient->HasMaxWorkRate()) {
    patientField[0] = patient->GetMaxWorkRate(biogears::PowerUnit::W);
    patientField[1] = "W";
    patientMap["MaxWorkRate"] = patientField;
  }
  //Pain susceptibility
  if (patient->HasPainSusceptibility()) {
    patientField[0] = patient->GetPainSusceptibility().GetValue();
    patientField[1] = "";
    patientMap["PainSusceptibility"] = patientField;
  }
  //Hyperhidrosis
  if (patient->HasHyperhidrosis()) {
    patientField[0] = patient->GetHyperhidrosis().GetValue();
    patientField[1] = "";
    patientMap["Hyperhidrosis"] = patientField;
  }

  return patientMap;
}

void Scenario::create_patient(QVariantMap patient)
{
  biogears::SEPatient* newPatient = new biogears::SEPatient(_engine->GetLogger());
  //JS objects are returned from QML as QVariantMap<QString (key), QVariant (item)>
  //The key will be the field in the patient CDM (e.g. Name, Age, Gender...)
  //The item is a pair (value, unit), which is returned by QML as QList<QVariant>
  //We first convert the QVariantList to a QList, which allows us to index the value and unit
  //We then access values and convert them from QVariant to the appropriate type (string, double, int, etc)

  //Name
  QList<QVariant> pMetric = patient["Name"].toList();
  QString patientName = pMetric[0].toString(); //Used to gen file name
  newPatient->SetName(patientName.toStdString());
  //Gender
  pMetric = patient["Gender"].toList();
  int gender = pMetric[0].toInt();
  newPatient->SetGender((CDM::enumSex::value)gender);
  //Age
  pMetric = patient["Age"].toList();
  if (!pMetric[0].isNull()) {
    double age = pMetric[0].toDouble();
    auto& tUnit = biogears::TimeUnit::GetCompoundUnit(pMetric[1].toString().toStdString());
    newPatient->GetAge().SetValue(age, tUnit);
  }
  //Weight
  pMetric = patient["Weight"].toList();
  if (!pMetric[0].isNull()) {
    double weight = pMetric[0].toDouble();
    auto& mUnit = biogears::MassUnit::GetCompoundUnit(pMetric[1].toString().toStdString());
    newPatient->GetWeight().SetValue(weight, mUnit);
  }
  //Height
  pMetric = patient["Height"].toList();
  if (!pMetric[0].isNull()) {
    double height = pMetric[0].toDouble();
    auto& lUnit = biogears::LengthUnit::GetCompoundUnit(pMetric[1].toString().toStdString());
    newPatient->GetHeight().SetValue(height, lUnit);
  }
  //Body Fat Fraction
  pMetric = patient["BodyFatFraction"].toList();
  if (!pMetric[0].isNull()) {
    double bodyFatFraction = pMetric[0].toDouble();
    newPatient->GetBodyFatFraction().SetValue(bodyFatFraction);
  }
  //Blood volume
  pMetric = patient["BloodVolumeBaseline"].toList();
  if (!pMetric[0].isNull()) {
    double bloodVolume = pMetric[0].toDouble();
    auto& vUnit = biogears::VolumeUnit::GetCompoundUnit(pMetric[1].toString().toStdString());
    newPatient->GetBloodVolumeBaseline().SetValue(bloodVolume, vUnit);
  }
  //Blood Type
  pMetric = patient["BloodType"].toList();
  if (!pMetric[0].isNull()) {
    int bloodType = pMetric[0].toInt();
    bool rHPositive = bloodType % 2 == 0;
    int abo = bloodType / 2;
    newPatient->SetBloodType((CDM::enumBloodType::value)abo);
    newPatient->SetBloodRh(rHPositive);
  }
  //Diastolic pressure
  pMetric = patient["DiastolicArterialPressureBaseline"].toList();
  if (!pMetric[0].isNull()) {
    double dapBaseline = pMetric[0].toDouble();
    auto& pUnit = biogears::PressureUnit::GetCompoundUnit(pMetric[1].toString().toStdString());
    newPatient->GetDiastolicArterialPressureBaseline().SetValue(dapBaseline, pUnit);
  }
  //Systolic pressure
  pMetric = patient["SystolicArterialPressureBaseline"].toList();
  if (!pMetric[0].isNull()) {
    double sapBaseline = pMetric[0].toDouble();
    auto& pUnit = biogears::PressureUnit::GetCompoundUnit(pMetric[1].toString().toStdString());
    newPatient->GetSystolicArterialPressureBaseline().SetValue(sapBaseline, pUnit);
  }
  //Heart Rate Max
  pMetric = patient["HeartRateMaximum"].toList();
  if (!pMetric[0].isNull()) {
    double hrMax = pMetric[0].toDouble();
    auto& fUnit = biogears::FrequencyUnit::GetCompoundUnit(pMetric[1].toString().toStdString());
    newPatient->GetHeartRateMaximum().SetValue(hrMax, fUnit);
  }
  //Heart Rate Min
  pMetric = patient["HeartRateMinimum"].toList();
  if (!pMetric[0].isNull()) {
    double hrMin = pMetric[0].toDouble();
    auto& fUnit = biogears::FrequencyUnit::GetCompoundUnit(pMetric[1].toString().toStdString());
    newPatient->GetHeartRateMinimum().SetValue(hrMin, fUnit);
  }
  //Respiration Rate
  pMetric = patient["RespirationRateBaseline"].toList();
  if (!pMetric[0].isNull()) {
    double respirationBase = pMetric[0].toDouble();
    auto& fUnit = biogears::FrequencyUnit::GetCompoundUnit(pMetric[1].toString().toStdString());
    newPatient->GetRespirationRateBaseline().SetValue(respirationBase, fUnit);
  }
  //Alveoli surface area
  pMetric = patient["AlveoliSurfaceArea"].toList();
  if (!pMetric[0].isNull()) {
    double alveoliSurfaceArea = pMetric[0].toDouble();
    auto& aUnit = biogears::AreaUnit::GetCompoundUnit(pMetric[1].toString().toStdString());
    newPatient->GetAlveoliSurfaceArea().SetValue(alveoliSurfaceArea, aUnit);
  }
  //Right Lung Ratio
  pMetric = patient["RightLungRatio"].toList();
  if (!pMetric[0].isNull()) {
    double rightLungRatio = pMetric[0].toDouble();
    newPatient->GetRightLungRatio().SetValue(rightLungRatio);
  }
  //Functional residual capacity
  pMetric = patient["FunctionalResidualCapacity"].toList();
  if (!pMetric[0].isNull()) {
    double frc = pMetric[0].toDouble();
    auto& vUnit = biogears::VolumeUnit::GetCompoundUnit(pMetric[1].toString().toStdString());
    newPatient->GetFunctionalResidualCapacity().SetValue(frc, vUnit);
  }
  //Residual volume
  pMetric = patient["ResidualVolume"].toList();
  if (!pMetric[0].isNull()) {
    double residualVolume = pMetric[0].toDouble();
    auto& vUnit = biogears::VolumeUnit::GetCompoundUnit(pMetric[1].toString().toStdString());
    newPatient->GetResidualVolume().SetValue(residualVolume, vUnit);
  }
  //Total lung capacity
  pMetric = patient["TotalLungCapacity"].toList();
  if (!pMetric[0].isNull()) {
    double totalCapacity = pMetric[0].toDouble();
    auto& vUnit = biogears::VolumeUnit::GetCompoundUnit(pMetric[1].toString().toStdString());
    newPatient->GetTotalLungCapacity().SetValue(totalCapacity, vUnit);
  }
  //Skin Surface Area
  pMetric = patient["SkinSurfaceArea"].toList();
  if (!pMetric[0].isNull()) {
    double skinArea = pMetric[0].toDouble();
    auto& aUnit = biogears::AreaUnit::GetCompoundUnit(pMetric[1].toString().toStdString());
    newPatient->GetSkinSurfaceArea().SetValue(skinArea, aUnit);
  }
  //Max Work Rate
  pMetric = patient["MaxWorkRate"].toList();
  if (!pMetric[0].isNull()) {
    double work = pMetric[0].toDouble();
    auto& powerUnit = biogears::PowerUnit::GetCompoundUnit(pMetric[1].toString().toStdString());
    newPatient->GetMaxWorkRate().SetValue(work, powerUnit);
  }
  //Pain susceptibility
  pMetric = patient["PainSusceptibility"].toList();
  if (!pMetric[0].isNull()) {
    double pain = pMetric[0].toDouble();
    newPatient->GetPainSusceptibility().SetValue(pain);
  }
  //Hyperhidrosis
  pMetric = patient["Hyperhidrosis"].toList();
  if (!pMetric[0].isNull()) {
    double schweaty = pMetric[0].toDouble();
    newPatient->GetHyperhidrosis().SetValue(schweaty);
  }

  save_patient(newPatient);
}

void Scenario::export_patient()
{
  save_patient(&(_engine->GetPatient()));
}

void Scenario::save_patient(const biogears::SEPatient* patient)
{
  std::string fileLoc = "./patients/" + patient->GetName() + ".xml";
  std::string fullPath = biogears::ResolvePath(fileLoc);
  biogears::CreateFilePath(fullPath);
  std::ofstream stream(fullPath);
  xml_schema::namespace_infomap info;
  info[""].name = "uri:/mil/tatrc/physiology/datamodel";

  std::unique_ptr<CDM::PatientData> pData(patient->Unload());
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

  std::unique_ptr<CDM::EnvironmentData> eData(_engine->GetEnvironment()->Unload());
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
  state->System().push_back(*(_engine->GetEnvironment()->Unload()));
  state->System().push_back(*(_engine->GetAnesthesiaMachine()->Unload()));
  state->System().push_back(*(_engine->GetECG().Unload()));
  state->System().push_back(*(_engine->GetInhaler()->Unload()));
  // Compartments
  state->CompartmentManager(*(_engine->GetCompartments().Unload()));
  // Configuration
  state->Configuration(*(_engine->GetConfiguration()->Unload()));
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

QString Scenario::patient_name_and_time()
{
  auto simulation_time = _engine->GetSimulationTime(biogears::TimeUnit::s);
  std::string time_in_simulation = std::to_string(simulation_time);
  std::string patient_name = _engine->GetPatient().GetName_cStr();
  return QString::fromStdString(patient_name+"@"+time_in_simulation+"s.xml");
}

bool Scenario::file_exists(QString file)
{
  return file_exists(file.toStdString());
}

bool Scenario::file_exists(std::string file)
{
  std::ifstream f(file.c_str());
  return f.good();
}

QList<QString> Scenario::get_nested_patient_state_list()
{
  DIR* dir;
  struct dirent* ent;
  std::map<std::string,int> patient_map;
  std::string contents;
  QList<QString> patient_list;
  if ((dir = opendir("states/")) != NULL) {
    while ((ent = readdir(dir)) != NULL) {
      std::string dirname = std::string(ent->d_name);
      if (dirname.find('@') == -1) {
        continue;
      }
      std::string patient_name = dirname.substr(0, dirname.find('@'));
      auto temp_patient = patient_map.find(patient_name);
      if (temp_patient == patient_map.end())
      {
        QString temp_list;
        temp_list += QString::fromStdString(patient_name);
        temp_list += ",";
        temp_list += ent->d_name;
        patient_list.push_back(temp_list);
        patient_map.insert(std::pair<std::string,int>(patient_name,patient_list.length()-1));
      } else {
        patient_list[temp_patient->second] += ",";
        patient_list[temp_patient->second] += ent->d_name;        
      }
    }
    closedir(dir);
  } else {
    std::cout << "Error could not read dir";
  }
  return patient_list;
}
QString Scenario::get_patient_state_files()
{
  DIR* dir;
  struct dirent* ent;
  std::string contents;
  if ((dir = opendir("states/")) != NULL) {
    while ((ent = readdir(dir)) != NULL) {
      if (ent->d_name[0] != static_cast<char>('.')) {        
        contents += ent->d_name;
        contents += "\n";
      }
    }
    closedir(dir);
  } else {
    std::cout << "Error could not read dir";
  }
  return QString::fromStdString(contents);
}

QString Scenario::get_patient_state_files(std::string patient)
{
  return get_patient_state_files(QString::fromStdString(patient));
}

QString Scenario::get_patient_state_files(QString patient)
{
  DIR* dir;
  struct dirent* ent;
  std::string contents;
  if ((dir = opendir("states/")) != NULL) {
    while ((ent = readdir(dir)) != NULL) {
      std::string dirname = std::string(ent->d_name);
      if (dirname.find('@') == -1) {
        continue;
      }
      if (patient.toStdString() == dirname.substr(0,dirname.find('@'))) {

        contents += ent->d_name;
        contents += '\n';
      }
    }
    closedir(dir);
  } else {
    std::cout << "Error could not read dir";
  }
  if ((dir = opendir("states/advanced")) != NULL) {
    while ((ent = readdir(dir)) != NULL) {
      std::string dirname = std::string(ent->d_name);
      if (dirname.find('@') == -1) {
        continue;
      }
      if (patient.toStdString() == dirname.substr(0, dirname.find('@'))) {
        contents += "advanced/";
        contents += ent->d_name;
        contents += '\n';
      }
    }
    closedir(dir);
  } else {
    std::cout << "Error could not read dir";
  }
  if (!contents.empty()) {
    contents.pop_back();
  }
  return QString::fromStdString(contents);
}



} //namespace ui
