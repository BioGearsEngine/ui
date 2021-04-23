#include "Scenario.h"

#include <chrono>
#include <cmath>
#include <exception>

#include <QChart>
#include <QChartView>
#include <QDebug>
#include <QLineSeries>
#include <QSplineSeries>
#include <QValueAxis>

#include "PatientConditions.h"
#include "PatientMetrics.h"
#include "PatientState.h"

#include "Models/PhysiologyRequest.h"

//#include <biogears/version.h>
#include <biogears/cdm/compartment/fluid/SELiquidCompartment.h>
#include <biogears/cdm/compartment/substances/SELiquidSubstanceQuantity.h>
#include <biogears/cdm/patient/SEPatient.h>
#include <biogears/cdm/patient/assessments/SEComprehensiveMetabolicPanel.h>
#include <biogears/cdm/patient/assessments/SEPatientAssessment.h>
#include <biogears/cdm/patient/assessments/SEUrinalysis.h>
#include <biogears/cdm/properties/SEScalar.h>
#include <biogears/cdm/properties/SEScalarInversePressure.h>
#include <biogears/cdm/properties/SEScalarTime.h>
#include <biogears/cdm/properties/SEScalarTimeMassPerVolume.h>
#include <biogears/cdm/properties/SEScalarTypes.h>
#include <biogears/cdm/properties/SEScalarVolumePerTimeMass.h>
#include <biogears/cdm/properties/SEUnitScalar.h>
#include <biogears/cdm/scenario/SEAction.h>
#include <biogears/cdm/scenario/SEScenarioInitialParameters.h>
#include <biogears/cdm/substance/SESubstanceClearance.h>
#include <biogears/cdm/substance/SESubstanceCompound.h>
#include <biogears/cdm/substance/SESubstanceConcentration.h>
#include <biogears/cdm/substance/SESubstanceFraction.h>
#include <biogears/cdm/system/SESystem.h>
#include <biogears/cdm/system/environment/SEEnvironment.h>
#include <biogears/cdm/system/environment/SEEnvironmentalConditions.h>
#include <biogears/cdm/system/equipment/ElectroCardioGram/SEElectroCardioGram.h>
#include <biogears/container/Tree.tci.h>
#include <biogears/container/concurrent_queue.tci.h>
#include <biogears/engine/BioGearsPhysiologyEngine.h>
#include <biogears/framework/scmp/scmp_channel.tci.h>

namespace bgui {
Scenario::Scenario(QObject* parent)
  : Scenario("DefaultTemplateMale", parent)
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
  , _urinalysis_qml(std::make_unique<Urinalysis>())
  , _data_request_tree(nullptr)
{
  _consoleLog = new QtLogForward(this);
  _logger.SetForward(_consoleLog);

  biogears::BioGears* engine = dynamic_cast<biogears::BioGears*>(_engine.get());
  engine->GetPatient().SetName(name.toStdString());
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
void Scenario::setup_physiology_model()
{
  _physiology_model = std::make_unique<BioGearsData>(QString(_engine->GetPatient().GetName_cStr()), this).release();
  _physiology_model->initialize(_engine->GetSubstances());
}
//-------------------------------------------------------------------------------
void Scenario::configure_physiology_model()
{
  auto vitals = static_cast<BioGearsData*>(_physiology_model->index(BioGearsData::VITALS, 0, QModelIndex()).internalPointer());
  {
    auto vital = vitals->child(0);
    {
      vital->child(0)->unit_scalar(&_engine->GetCardiovascular().GetSystolicArterialPressure());
      vital->child(1)->unit_scalar(&_engine->GetCardiovascular().GetDiastolicArterialPressure());
      vital->child(2)->unit_scalar(&_engine->GetCardiovascular().GetMeanArterialPressure());
    }
    vitals->child(1)->unit_scalar(&_engine->GetCardiovascular().GetHeartRate());
    vitals->child(2)->unit_scalar(&_engine->GetRespiratory().GetRespirationRate());
    vitals->child(3)->scalar(&_engine->GetBloodChemistry().GetOxygenSaturation());
    vitals->child(4)->unit_scalar(&_engine->GetCardiovascular().GetBloodVolume());
    vitals->child(4)->unit("L");
    vitals->child(5)->unit_scalar(&_engine->GetCardiovascular().GetCentralVenousPressure());
    vitals->child(6)->unit_scalar(&_engine->GetCardiovascular().GetCardiacOutput());
  }

  auto cardiovascular = static_cast<BioGearsData*>(_physiology_model->index(BioGearsData::CARDIOVASCULAR, 0, QModelIndex()).internalPointer());
  {
    cardiovascular->child(0)->unit_scalar(&_engine->GetCardiovascular().GetCerebralPerfusionPressure());
    cardiovascular->child(1)->unit_scalar(&_engine->GetCardiovascular().GetIntracranialPressure());
    cardiovascular->child(2)->unit_scalar(&_engine->GetCardiovascular().GetSystemicVascularResistance());
    cardiovascular->child(3)->unit_scalar(&_engine->GetCardiovascular().GetPulsePressure());
    cardiovascular->child(4)->unit_scalar(&_engine->GetCardiovascular().GetHeartStrokeVolume());
    cardiovascular->child(5)->unit_scalar(&_engine->GetCardiovascular().GetCardiacIndex());
    cardiovascular->child(6)->scalar(&_engine->GetCardiovascular().GetHeartEjectionFraction());
    cardiovascular->child(7)->unit_scalar(&_engine->GetTissue().GetExtravascularFluidVolume());
    cardiovascular->child(8)->unit_scalar(&_engine->GetTissue().GetExtracellularFluidVolume());
    cardiovascular->child(9)->unit_scalar(&_engine->GetTissue().GetIntracellularFluidVolume());
    cardiovascular->child(10)->unit_scalar(&_engine->GetTissue().GetTotalBodyFluidVolume());
  }

  auto respiratory = static_cast<BioGearsData*>(_physiology_model->index(BioGearsData::RESPIRATORY, 0, QModelIndex()).internalPointer());
  {
    respiratory->child(0)->scalar(&_engine->GetRespiratory().GetInspiratoryExpiratoryRatio());
    respiratory->child(1)->unit_scalar(&_engine->GetRespiratory().GetTotalPulmonaryVentilation());
    respiratory->child(2)->unit_scalar(&_engine->GetRespiratory().GetTotalLungVolume());
    respiratory->child(2)->unit("L");
    respiratory->child(3)->unit_scalar(&_engine->GetRespiratory().GetTidalVolume());
    respiratory->child(4)->unit_scalar(&_engine->GetRespiratory().GetTotalAlveolarVentilation());
    respiratory->child(5)->unit_scalar(&_engine->GetRespiratory().GetTotalDeadSpaceVentilation());
    respiratory->child(6)->unit_scalar(&_engine->GetRespiratory().GetTranspulmonaryPressure());
  }

  auto blood_chemistry = static_cast<BioGearsData*>(_physiology_model->index(BioGearsData::BLOOD_CHEMISTRY, 0, QModelIndex()).internalPointer());
  {
    blood_chemistry->child(0)->unit_scalar(&_engine->GetBloodChemistry().GetArterialOxygenPressure());
    blood_chemistry->child(1)->unit_scalar(&_engine->GetBloodChemistry().GetArterialCarbonDioxidePressure());
    blood_chemistry->child(2)->scalar(&_engine->GetBloodChemistry().GetOxygenSaturation());
    blood_chemistry->child(3)->scalar(&_engine->GetBloodChemistry().GetCarbonDioxideSaturation());
    blood_chemistry->child(4)->scalar(&_engine->GetBloodChemistry().GetArterialBloodPH());
    blood_chemistry->child(5)->scalar(&_engine->GetBloodChemistry().GetHematocrit());
    blood_chemistry->child(6)->unit_scalar(&_engine->GetSubstances().GetLactate().GetBloodConcentration());
    blood_chemistry->child(7)->scalar(&_engine->GetBloodChemistry().GetStrongIonDifference());
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
    energy_and_metabolism->child(5)->unit_scalar(&_engine->GetTissue().GetOxygenConsumptionRate());
    energy_and_metabolism->child(6)->unit_scalar(&_engine->GetTissue().GetCarbonDioxideProductionRate());
    energy_and_metabolism->child(7)->scalar(&_engine->GetTissue().GetDehydrationFraction());
    biogears::BioGears* engine_as_bg = dynamic_cast<biogears::BioGears*>(_engine.get());
    biogears::SEEnvironment& env = engine_as_bg->GetEnvironment();
    biogears::SEEnvironmentalConditions& cond = env.GetConditions();
    energy_and_metabolism->child(8)->unit_scalar(&cond.GetAmbientTemperature());
    energy_and_metabolism->child(9)->scalar(&cond.GetRelativeHumidity());
  }

  auto renal = static_cast<BioGearsData*>(_physiology_model->index(BioGearsData::RENAL, 0, QModelIndex()).internalPointer());
  {
    renal->child(0)->unit_scalar(&_engine->GetRenal().GetMeanUrineOutput());
    renal->child(0)->unit("mL/min");
    renal->child(1)->unit_scalar(&_engine->GetRenal().GetUrineProductionRate());
    renal->child(1)->unit("mL/min");
    renal->child(2)->unit_scalar(&_engine->GetRenal().GetGlomerularFiltrationRate());
    renal->child(2)->unit("mL/min");
    renal->child(3)->unit_scalar(&_engine->GetRenal().GetUrineVolume());
    renal->child(4)->unit_scalar(&_engine->GetRenal().GetUrineOsmolality());
    renal->child(5)->unit_scalar(&_engine->GetRenal().GetUrineOsmolarity());
    renal->child(6)->unit_scalar(&_engine->GetRenal().GetRenalBloodFlow());
    renal->child(6)->unit("L/min");
    renal->child(7)->unit_scalar(&_engine->GetRenal().GetLeftReabsorptionRate());
    renal->child(7)->unit("mL/min");
    renal->child(8)->unit_scalar(&_engine->GetRenal().GetRightReabsorptionRate());
    renal->child(8)->unit("mL/min");
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

  _physiology_model->setSimulationTime(_engine->GetSimulationTime(biogears::TimeUnit::s));
}
//-------------------------------------------------------------------------------
void Scenario::setup_data_request_tree()
{
  _data_request_tree = new DataRequestTree();
  _data_request_tree->initialize(const_cast<biogears::SECompartmentManager*>(&_engine->GetCompartments()), &_engine->GetSubstanceManager()); //Only need to initialize once, not at every patient reload
  emit dataRequestModelChanged(_data_request_tree);
}
//-------------------------------------------------------------------------------
inline void update_substance_data(biogears::SESubstance* sub, int row, BioGearsData* substances, biogears::SELiquidCompartment* lKidney, biogears::SELiquidCompartment* rKidney, biogears::SELiquidCompartment* liver)
{
  PhysiologyRequest* substance = static_cast<PhysiologyRequest*>(substances->index(row, 0, QModelIndex()).internalPointer());
  substance->usable(true);
  //Add bindings for properties which the substance has.  We assume we traverse the sub-tree in the order it was established in BiogearsData::Initialize
  int requestIndex = 0; //The first four properties are defined for every substance.  Others are conditional.  Use this value to track where we are
  substance->child(0)->unit_scalar(&sub->GetBloodConcentration());
  substance->child(1)->unit_scalar(&sub->GetMassInBody());
  substance->child(2)->unit_scalar(&sub->GetMassInBlood());
  substance->child(3)->unit_scalar(&sub->GetMassInTissue());
  requestIndex += 4;
  //Only subs that are dissolved gases need alveolar transfer and end tidal.  Use relative diffusion coefficient to filter
  if (sub->HasRelativeDiffusionCoefficient()) {
    substance->child(requestIndex)->unit_scalar(&sub->GetAlveolarTransfer());
    substance->child(requestIndex + 1)->scalar(&sub->GetEndTidalFraction());
    requestIndex += 2;
  }
  //Only subs that have PK need effect site, plasma, AUC
  if (sub->HasPK()) {
    substance->child(requestIndex)->unit_scalar(&sub->GetEffectSiteConcentration());
    substance->child(requestIndex + 1)->unit_scalar(&sub->GetPlasmaConcentration());
    substance->child(requestIndex + 2)->unit_scalar(&sub->GetAreaUnderCurve());
    requestIndex += 3;
  }
  //Assign clearances, if applicable
  if (sub->HasClearance()) {
    if (sub->GetClearance().HasRenalClearance()) {
      //TODO: Upgrade Scalar PTRs to be a vector of PTRs so that we can do composite equations like this.
      //TODO: Add Lambda functiosn for calculating data values from composite functions.
      std::function<QString(void)> unitFunc = [lKidney]() {
        return "ug";
      };
      std::function<double(void)> valueFunc = [&, sub]() {
        return (lKidney->HasSubstanceQuantity(*sub) && rKidney->HasSubstanceQuantity(*sub)) ? lKidney->GetSubstanceQuantity(*sub)->GetMassCleared(biogears::MassUnit::ug) + rKidney->GetSubstanceQuantity(*sub)->GetMassCleared(biogears::MassUnit::ug)
                                                                                            : 0;
      };

      //substance->child(requestIndex)->custom(std::move(valueFunc), std::move(unitFunc));
      //++requestIndex;
    }
    if (sub->GetClearance().HasIntrinsicClearance()) {
      substance->child(requestIndex)->unit_scalar(liver->HasSubstanceQuantity(*sub) ? &liver->GetSubstanceQuantity(*sub)->GetMassCleared() : nullptr);
      ++requestIndex;
    }
    if (sub->GetClearance().HasSystemicClearance()) {
      substance->child(requestIndex)->unit_scalar(&sub->GetSystemicMassCleared());
      ++requestIndex;
    }
  }
}
//-------------------------------------------------------------------------------
void Scenario::setup_physiology_substances(BioGearsData* substances)
{
  //NOTE: Assumes that all substances have been added to BioGears Data Model -> Substances.  This function is executed when a new state is loaded.
  //Loop over all substances: If a sub is active, find it in the Substances model and set assign substance data to appropriate fields.
  //IMPORTANT:  WE ASSUME THAT SUBSTANCES WERE LOADED IN ALPHABETICAL ORDER FROM SUBSTANCE DIRECTORY AND THAT THIS ORDER IS PRESERVED WHEN
  //WE LOOP THROUGH SUBSTANCES IN SUBSTANCE MANAGER.  IF THIS IS EVER NOT THE CASE, THIS FUNCION WILL NOT WORK.

  biogears::BioGears* engine = dynamic_cast<biogears::BioGears*>(_engine.get());
  biogears::SETissueCompartment* lKidney = engine->GetCompartments().GetTissueCompartment(BGE::TissueCompartment::LeftKidney);
  biogears::SETissueCompartment* rKidney = engine->GetCompartments().GetTissueCompartment(BGE::TissueCompartment::RightKidney);
  biogears::SETissueCompartment* liver = engine->GetCompartments().GetTissueCompartment(BGE::TissueCompartment::Liver);

  biogears::SELiquidCompartment& lKidneyIntracellular = engine->GetCompartments().GetIntracellularFluid(*lKidney);
  biogears::SELiquidCompartment& rKidneyIntracellular = engine->GetCompartments().GetIntracellularFluid(*rKidney);
  biogears::SELiquidCompartment& liverIntracellular = engine->GetCompartments().GetIntracellularFluid(*liver);

  for (int i = 0; i < _engine->GetSubstances().GetSubstances().size(); ++i) {
    auto& sub = _engine->GetSubstances().GetSubstances()[i]; //Not using range based loop because we need the index
    if ((sub->GetState() != CDM::enumSubstanceState::Liquid) && (sub->GetState() != CDM::enumSubstanceState::Gas)) {
      //Not planning to plot substances that don't meet this criteria (things like hemoglobin, antigens, etc.)
      continue;
    }
    //Check if substance is active.  If yes, set to "usable" (so it will show up in menu) and define its plottable properties
    bool active = _engine->GetSubstances().IsActive(*sub);
    if (!active) {
      continue;
    }
    update_substance_data(sub, i, substances, &lKidneyIntracellular, &rKidneyIntracellular, &liverIntracellular);
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
//!  Resets the required member variables for controlling the engine
//!  DO NOT call this with out the _engine_mutex lock
//!
void Scenario::remake_engine()
{
  _engine = std::make_unique<biogears::BioGearsEngine>(&_logger);
  _urinalysis = std::make_unique<biogears::SEUrinalysis>();
  _blood_panel = std::make_unique<biogears::SEComprehensiveMetabolicPanel>();
  _engine->GetLogger()->SetForward(_consoleLog);
}
//-------------------------------------------------------------------------------
Scenario& Scenario::load_patient(QString file)
{
  setup_physiology_lists();

  auto path = file.toStdString();
  if (!QFileInfo::exists(file)) {
    path = "states/" + path;
    if (!QFileInfo::exists("states/" + file)) {
      throw std::runtime_error("Unable to locate " + file.toStdString());
    }
  }

  _engine_mutex.lock(); //< I ran in to some -O2 issues when using an std::lock_guard in msvc

  remake_engine();
  // Physiology System Names are defined on the System Objects
  _engine->GetEngineTrack()->GetDataRequestManager().CreatePhysiologyDataRequest().Set("HeartRate", biogears::FrequencyUnit::Per_min);
  _engine->GetEngineTrack()->GetDataRequestManager().CreatePhysiologyDataRequest().Set("SystolicArterialPressure", biogears::PressureUnit::mmHg);
  _engine->GetEngineTrack()->GetDataRequestManager().CreatePhysiologyDataRequest().Set("DiastolicArterialPressure", biogears::PressureUnit::mmHg);
  _engine->GetEngineTrack()->GetDataRequestManager().CreatePhysiologyDataRequest().Set("RespirationRate", biogears::FrequencyUnit::Per_min);
  _engine->GetEngineTrack()->GetDataRequestManager().CreatePhysiologyDataRequest().Set("TidalVolume", biogears::VolumeUnit::mL);
  _engine->GetEngineTrack()->GetDataRequestManager().CreatePhysiologyDataRequest().Set("TotalLungVolume", biogears::VolumeUnit::mL);
  _engine->GetEngineTrack()->GetDataRequestManager().CreatePhysiologyDataRequest().Set("OxygenSaturation");
  
  _engine->GetEngineTrack()->GetDataRequestManager().SetResultsFilename("BioGearsUI.csv");

  if (_engine->LoadState(path)) {
    _scenario_name = _engine->GetPatient().GetName_cStr();
    if (!_physiology_model) {
      setup_physiology_model();
    }
    if (!_data_request_tree) {
      setup_data_request_tree();
    }
    configure_physiology_model();
    //Create file info and extract base name (e.g. Patient@0s or Patient).  We go through this process rather
    // than just taking file name because sometimes we pass only a name to LoadPatient (DefaultMale@0s.xml) and
    // sometimes we pass an absolute file path.
    QFileInfo stateFileInfo = QFileInfo(QString::fromStdString(path));
    QString stateBaseName = stateFileInfo.baseName();

    emit patientMetricsChanged(get_physiology_metrics());
    emit patientStateChanged(get_physiology_state());
    emit patientConditionsChanged(get_physiology_conditions());
    emit stateLoad(stateBaseName);
    emit physiologyChanged(_physiology_model);
  } else {
    _engine->GetLogger()->Error("Could not load state, check the error");
  }
  _engine_mutex.unlock();
  std::string log_message = "Successfully Loaded: " + path;
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
    if (_assessment_queue.size()) {
      auto assessment = _assessment_queue.consume();
      _engine->GetPatientAssessment(*assessment);
      if (dynamic_cast<biogears::SEUrinalysis*>(assessment)) {
        //std::cout << "Urinalysis completed classname(" << assessment->classname() << ")\n";
        // Urinalysis analysis;
        _urinalysis_qml->Appearance(CDM::enumClarityIndicator::Clear); // Using normal, not currently changed in BG engine
        _urinalysis_qml->Color(_urinalysis->GetColorResult());
        _urinalysis_qml->Appearance(CDM::enumClarityIndicator::Clear); // Using normal, not currently changed in BG engine
        _urinalysis_qml->Bilirubin(0.0); // Using normal, not currently changed in BG engine
        _urinalysis_qml->SpecificGravity(_urinalysis->GetSpecificGravityResult().GetValue());
        _urinalysis_qml->pH(6.7); // Using normal, not currently changed in BG engine
        _urinalysis_qml->Urobilinogen(0.6); // Using normal, not currently changed in BG engine
        _urinalysis_qml->Glucose(_urinalysis->GetGlucoseResult());
        _urinalysis_qml->Ketone(_urinalysis->GetKetoneResult());
        _urinalysis_qml->Protein(_urinalysis->GetProteinResult());
        _urinalysis_qml->Blood(_urinalysis->GetBloodResult());
        _urinalysis_qml->Nitrite(CDM::enumPresenceIndicator::Negative); // Using normal, not currently changed in BG engine
        _urinalysis_qml->LeukocyteEsterase(CDM::enumPresenceIndicator::Negative); // Using normal, not currently changed in BG engine

        emit urinalysis_completed(_urinalysis_qml.get());
      } else if (dynamic_cast<biogears::SEComprehensiveMetabolicPanel*>(assessment)) {
        //std::cout << "ComprehensiveMetabolicPanel completed classname(" << assessment->classname() << ")\n";
      } else {
        std::cout << "Unable to determine RTTI of the assessment " << assessment->classname() << "\n";
      }
    }
    _engine->AdvanceModelTime(0.1, biogears::TimeUnit::s);
    _engine_mutex.unlock();

    _new_respiratory_cycle->SetValue(_engine->GetPatient().IsEventActive(CDM::enumPatientEvent::StartOfInhale));

    _physiology_model->setSimulationTime(_engine->GetSimulationTime(biogears::TimeUnit::s));

    //Now that any drug actions have been processed and advanced, newly activated substances will have all members initialized.
    //At this point, we can search for new subs in physiology model and set them to usable so that graph area menu can find them
    QModelIndex substanceIndex = _physiology_model->index(BioGearsData::SUBSTANCES, 0, QModelIndex());
    auto substances = static_cast<BioGearsData*>(substanceIndex.internalPointer());
    if (!_substance_queue.empty()) {
      //Need pointers to kidney and liver so we can set up clearances
      biogears::BioGears* engine = dynamic_cast<biogears::BioGears*>(_engine.get());
      biogears::SETissueCompartment* lKidney = engine->GetCompartments().GetTissueCompartment(BGE::TissueCompartment::LeftKidney);
      biogears::SETissueCompartment* rKidney = engine->GetCompartments().GetTissueCompartment(BGE::TissueCompartment::RightKidney);
      biogears::SETissueCompartment* liver = engine->GetCompartments().GetTissueCompartment(BGE::TissueCompartment::Liver);

      biogears::SELiquidCompartment& lKidneyIntracellular = engine->GetCompartments().GetIntracellularFluid(*lKidney);
      biogears::SELiquidCompartment& rKidneyIntracellular = engine->GetCompartments().GetIntracellularFluid(*rKidney);
      biogears::SELiquidCompartment& liverIntracellular = engine->GetCompartments().GetIntracellularFluid(*liver);
      while (!_substance_queue.empty()) {
        for (int i = 0; i < substances->rowCount(); ++i) {
          if (substances->child(i)->name().toStdString() == _substance_queue.back()->GetName()) {
            substances->child(i)->usable(true);
            update_substance_data(_substance_queue.back(), i, substances, &lKidneyIntracellular, &rKidneyIntracellular, &liverIntracellular);
            substanceActivated(_physiology_model->index(i, 0, substanceIndex));
            break;
          }
        }
        _substance_queue.pop_back();
      }
    }

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
void Scenario::setup_physiology_lists()
{
  _drugs_list.clear(); //Substances with pharmacokinetic/pharmacodynamic props
  _compounds_list.clear(); //Consist of a combination of components
  _transfusions_list.clear(); //Blood products to be transfused
  _components_list.clear(); //Substances elibigle to be added as components to compounds
  _nutrition_list.clear(); //Nutrients that can be loaded to ConsumeMeal action

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
            if (subData->State().get() == CDM::enumSubstanceState::Gas) {
              _volatile_drugs_list.append(QString::fromStdString(subData->Name())); //Drugs that can be vaporized and given through ventilator
            }
          }
          if (subData->State().present() && subData->State().get() != CDM::enumSubstanceState::Solid) {
            _components_list.append(QString::fromStdString(subData->Name()));
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

  QDir nutritionDirectory = QDir("nutrition");
  if (!nutritionDirectory.exists()) {
    std::cout << "This is not the nutrition directory you're looking for";
  } else {
    QDirIterator nutritionIt(nutritionDirectory, QDirIterator::NoIteratorFlags);
    while (nutritionIt.hasNext()) {
      auto it = nutritionIt.next(); //Only used to advance iterator--don't really need the string that is returned by this function
      auto nutritionFileInfo = nutritionIt.fileInfo();
      QString nutritionName = nutritionFileInfo.baseName();
      if (!nutritionName.isEmpty()) {
        _nutrition_list.push_back(nutritionName);
      }
    }
  }
}
//---------------------------------------------------------------------------------
QVariantList Scenario::get_drugs()
{
  return _drugs_list;
}
//---------------------------------------------------------------------------------
QVariantList Scenario::get_volatile_drugs()
{
  return _volatile_drugs_list;
}
//---------------------------------------------------------------------------------
QVariantList Scenario::get_compounds()
{
  return _compounds_list;
}
//---------------------------------------------------------------------------------
QVariantList Scenario::get_transfusion_products()
{
  return _transfusions_list;
}
//---------------------------------------------------------------------------------
QVariantList Scenario::get_components()
{
  return _components_list;
}
//---------------------------------------------------------------------------------
QVariantList Scenario::get_nutrition()
{
  return _nutrition_list;
}
//---------------------------------------------------------------------------------
QtLogForward* Scenario::getLogForward()
{
  return _consoleLog;
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

  //Export new patient
  export_patient(newPatient);
}

QVariantMap Scenario::edit_patient()
{
  //Create a QVariantMap with key = PropName and item = {value, unit}
  //Qml interpets QVariantMaps as Javascript objects, which we can index by prop name
  QVariantMap patientMap;

  //Open file dialog in patients folder to select patient
  QString patientFile = QFileDialog::getOpenFileName(nullptr, "Edit Patient", "./patients", "Patients (*.xml)");
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
  patientField[0] = patient->GetGender() == CDM::enumSex::Female ? 1 : 0;
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

void Scenario::export_patient()
{
  //Function to export currently loaded patient
  export_patient(&(_engine->GetPatient()));
}

void Scenario::export_patient(const biogears::SEPatient* patient)
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

bool Scenario::create_scenario(EventTree* eventTree, QVariantList requests, QString sampling)
{
  QString scenarioFile = QFileDialog::getSaveFileName(nullptr, "Save Scenario", "./Scenarios", "Scenario (*.xml)");
  if (scenarioFile.isNull()) {
    return false;
  }
  eventTree->sort_events(); //Get actions in right order
  //Set scenario name
  auto buildScenario = std::make_unique<biogears::SEScenario>(_engine->GetSubstances());
  buildScenario->SetName(eventTree->get_timeline_name().toStdString());
  //Set initial patient/state file name
  std::string initialParams = eventTree->get_patient_name().toStdString();
  if (initialParams.find('@') != std::string::npos) {
    buildScenario->SetEngineStateFile(initialParams);
  } else {
    buildScenario->GetInitialParameters().SetPatientFile(initialParams);
  }
  //Set sampling frequency
  std::string frequencyStr = sampling.toStdString();
  size_t pos = frequencyStr.find(';');
  double frequency_Hz = std::stod(frequencyStr.substr(0, pos));
  std::cout << frequencyStr.substr(pos, frequencyStr.length());
  if (frequencyStr.substr(pos + 1, frequencyStr.length()) == "s") {
    frequency_Hz = 1.0 / frequency_Hz;
  }
  buildScenario->GetDataRequestManager().SetSamplesPerSecond(frequency_Hz);

  //Set up re-usable types
  biogears::SEAction* action; //Decoded information from event tree stored in SEAction class, writable to xml
  Event thisEvent; //The current biogears event being processed
  Event nextEvent; //The next biogears event in the queue
  Event advanceTime; //Store advance time event
  advanceTime.typeName = "AdvanceTime";
  advanceTime.eType = EventTree::EventTypes::AdvanceTime;

  //Event queue is set up such that a single Advance Time event is present at the end of the queue (no advance times between events -- taken care
  // of by "duration" fields).  Use this terminal Advance Time as a sentinal as we loop through queue and add events to scenario file
  int count = 0;
  while (eventTree->get_events()[count].eType != EventTree::EventTypes::AdvanceTime) {
    thisEvent = eventTree->get_events()[count];
    if (count == 0 && thisEvent.startTime > 0.0) {
      //If the first event does not start at time 0, then we need an advance time action before it
      advanceTime.startTime = 0.0;
      advanceTime.duration = thisEvent.startTime;
      action = eventTree->decode_action(advanceTime, _engine->GetSubstances());
      buildScenario->AddAction(*action);
    }
    action = eventTree->decode_action(thisEvent, _engine->GetSubstances());
    buildScenario->AddAction(*action);
    nextEvent = eventTree->get_events()[count + 1];
    //Place an advance time action between successive BG actions (unless the next action is the final advance time action in the scenario)
    if (nextEvent.eType != EventTree::EventTypes::AdvanceTime) {
      advanceTime.startTime = thisEvent.startTime; //Start at same time as action we just applied
      advanceTime.duration = nextEvent.startTime - advanceTime.startTime;
      action = eventTree->decode_action(advanceTime, _engine->GetSubstances());
      buildScenario->AddAction(*action);
    }
    //Update count
    ++count;
  }
  //Now add the final advance time action to the scenario (unless it's duration is 0) -- count will be value at end of queue by this point
  if (eventTree->get_events()[count].duration > 0) {
    action = eventTree->decode_action(eventTree->get_events()[count], _engine->GetSubstances());
    buildScenario->AddAction(*action);
  }

  //Create requests
  for (int i = 0; i < requests.size(); ++i) {
    buildScenario->GetDataRequestManager().CreateFromBind(*_data_request_tree->decode_request(requests[i].toString()), _engine->GetSubstanceManager());
  }

  std::string fullPath = biogears::ResolvePath(scenarioFile.toStdString());
  biogears::CreateFilePath(fullPath);
  std::ofstream stream(fullPath);
  xml_schema::namespace_infomap info;
  info[""].name = "uri:/mil/tatrc/physiology/datamodel";

  std::unique_ptr<CDM::ScenarioData> sceData(buildScenario->Unload());
  CDM::Scenario(stream, *sceData, info);
  stream.close();
  _engine->GetLogger()->Info("Saved scenario: " + fullPath);
  return true;
}
//Loads data from scenario to the scenario builder for editing
void Scenario::edit_scenario()
{
  //Open file dialog in scenario folder
  QString scenarioFile = QFileDialog::getOpenFileName(nullptr, "Edit Scenario", "./Scenarios", "Scenario (*.xml)");
  if (scenarioFile.isNull()) {
    return;
  }
  //Load file and create and SENutrition object from it using serializer
  if (!QFileInfo::exists(scenarioFile)) {
    throw std::runtime_error("Unable to locate " + scenarioFile.toStdString());
  }

  std::unique_ptr<CDM::ObjectData> scenarioXML = biogears::Serializer::ReadFile(scenarioFile.toStdString(), _engine->GetLogger());
  CDM::ScenarioData* scenarioData = dynamic_cast<CDM::ScenarioData*>(scenarioXML.get());

  EventTree* events = new EventTree();
  events->encode_actions(scenarioData);
  QVariantList requests = _data_request_tree->encode_requests(scenarioData);
  std::string sampling = "";
  if (scenarioData->DataRequests()->SamplesPerSecond().present()) {
    double frequency = scenarioData->DataRequests()->SamplesPerSecond().get();
    if (frequency < 1.0) {
      sampling = std::to_string(std::round(1.0 / frequency)) + ";s";
    } else {
      sampling = std::to_string(std::round(frequency)) + ";Hz";
    }
  }
  emit loadScenarioToBuilder(events, requests, QString::fromStdString(sampling));
}
//Loads scenario data to the active console (actions to Controls, data requests to Graph Area) so that
// user can execute scenario.
bool Scenario::load_scenario()
{
  _engine_mutex.lock();
  //Open file dialog in scenario folder
  QString scenarioFile = QFileDialog::getOpenFileName(nullptr, "Load Scenario", "./Scenarios", "Scenario (*.xml)");

  if (scenarioFile.isNull()) {
    return false;
  }
  //Load file and create and SENutrition object from it using serializer
  if (!QFileInfo::exists(scenarioFile)) {
    throw std::runtime_error("Unable to locate " + scenarioFile.toStdString());
    return false;
  }

  std::unique_ptr<CDM::ObjectData> scenarioXML = biogears::Serializer::ReadFile(scenarioFile.toStdString(), _engine->GetLogger());
  CDM::ScenarioData* scenarioData = dynamic_cast<CDM::ScenarioData*>(scenarioXML.get());

  EventTree* events = new EventTree();
  events->encode_actions(scenarioData);
  _physiology_model->enableFromScenario(scenarioData);

  remake_engine();

  if (scenarioData->InitialParameters().present()) {
    biogears::BioGears* engine = dynamic_cast<biogears::BioGears*>(_engine.get());
    if (scenarioData->InitialParameters()->Patient().present()) {
      biogears::SEPatient patient{ _engine->GetLogger() };
      patient.Load(scenarioData->InitialParameters()->Patient().get());
      _engine->InitializeEngine(patient);
    } else if (scenarioData->InitialParameters()->PatientFile()) {
      if (QFileInfo(scenarioData->InitialParameters()->PatientFile().get().c_str()).exists()) {
        _engine->InitializeEngine(scenarioData->InitialParameters()->PatientFile().get());
      } else if (scenarioData->InitialParameters()->PatientFile()) {
        _engine->InitializeEngine("patients/" + scenarioData->InitialParameters()->PatientFile().get());
      } else {
        _engine->InitializeEngine("patients/DefaultMale.xml");
      }
    }
  } else if (scenarioData->EngineStateFile().present()) {
    _engine->LoadState(scenarioData->EngineStateFile().get());
  } else {
    _engine->LoadState("states/DefaultMale@0s.xml");
  }

  if (!_physiology_model) {
    setup_physiology_model();
  }
  if (!_data_request_tree) {
    setup_data_request_tree();
  }
  configure_physiology_model();
  _scenario_name = (scenarioData->Name().present()) ? scenarioData->Name().get().c_str() : "";
  _engine->GetEngineTrack()->GetDataRequestManager().Load(scenarioData->DataRequests().get(), _engine->GetSubstanceManager());
  _engine->GetEngineTrack()->GetDataRequestManager().SetResultsFilename("BioGearsUI.csv");
  _engine_mutex.unlock();
  emit physiologyChanged(_physiology_model);
  emit loadScenarioToControls(events);
  return true;
}

void Scenario::create_substance(QVariantMap substanceData)
{
  biogears::SESubstance* newSubstance = new biogears::SESubstance(_engine->GetLogger());
  //JS objects are returned from QML as QVariantMap<QString (key), QVariant (item)>
  //The key will be the field in the patient CDM (e.g. Name, State, MolarMass...)
  //The item is a pair (value, unit), which is returned by QML as QList<QVariant>
  //We first convert the QVariantList to a QList, which allows us to index the value and unit
  //We then access values and convert them from QVariant to the appropriate type (string, double, int, etc)

  QVariantMap physicalData = substanceData["Physical"].toMap();

  //Name
  QList<QVariant> subMetric = physicalData["Name"].toList();
  QString subName = subMetric[0].toString(); //Used to gen file name
  newSubstance->SetName(subName.toStdString());
  //State
  subMetric = physicalData["State"].toList();
  int state = subMetric[0].toInt();
  newSubstance->SetState((CDM::enumSubstanceState::value)state);
  //Classification
  subMetric = physicalData["Classification"].toList();
  if (!subMetric[0].isNull()) {
    int subClass = subMetric[0].toInt();
    newSubstance->SetClassification((CDM::enumSubstanceClass::value)subClass);
  }
  //Density
  subMetric = physicalData["Density"].toList();
  if (!subMetric[0].isNull()) {
    double value = subMetric[0].toDouble();
    auto& unit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
    newSubstance->GetDensity().SetValue(value, unit);
  }
  //Maximum Diffusion Flux
  subMetric = physicalData["MaximumDiffusionFlux"].toList();
  if (!subMetric[0].isNull()) {
    double value = subMetric[0].toDouble();
    auto& unit = biogears::MassPerAreaTimeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
    newSubstance->GetMaximumDiffusionFlux().SetValue(value, unit);
  }
  //Michaelis Coefficient
  subMetric = physicalData["MichaelisCoefficient"].toList();
  if (!subMetric[0].isNull()) {
    double value = subMetric[0].toDouble();
    newSubstance->GetMichaelisCoefficient().SetValue(value);
  }
  //Membrane Resistance
  subMetric = physicalData["MembraneResistance"].toList();
  if (!subMetric[0].isNull()) {
    double value = subMetric[0].toDouble();
    auto& unit = biogears::ElectricResistanceUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
    newSubstance->GetMembraneResistance().SetValue(value, unit);
  }
  //Molar Mass
  subMetric = physicalData["MolarMass"].toList();
  if (!subMetric[0].isNull()) {
    double value = subMetric[0].toDouble();
    auto& unit = biogears::MassPerAmountUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
    newSubstance->GetMolarMass().SetValue(value, unit);
  }
  //Relative Diffusion Coefficient
  subMetric = physicalData["RelativeDiffusionCoefficient"].toList();
  if (!subMetric[0].isNull()) {
    double value = subMetric[0].toDouble();
    newSubstance->GetRelativeDiffusionCoefficient().SetValue(value);
  }
  //Solubility Coefficient
  subMetric = physicalData["SolubilityCoefficient"].toList();
  if (!subMetric[0].isNull()) {
    double value = subMetric[0].toDouble();
    auto& unit = biogears::InversePressureUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
    newSubstance->GetSolubilityCoefficient().SetValue(value, unit);
  }

  //--Clearance (only present if defined by user, otherwise skip)
  if (substanceData.find("Clearance") != substanceData.end()) {
    QVariantMap clearanceData = substanceData["Clearance"].toMap();

    //Get Clearance creates a new SESubstanceClearance and assigns it to substance if clearance does not yet exist
    auto& subClearance = newSubstance->GetClearance();

    //--Systemic Clearance--.
    //If "systemic" is present in map, then HasSystemic=true and all sub-data is present as well
    subClearance.SetSystemic(clearanceData.find("systemic") != clearanceData.end());
    if (subClearance.HasSystemic()) {
      subClearance.SetSystemic(true);
      QVariantMap systemicData = clearanceData["systemic"].toMap();
      //Fraction Excreted in Feces
      subMetric = systemicData["FractionExcretedInFeces"].toList();
      subClearance.GetFractionExcretedInFeces().SetValue(subMetric[0].toDouble());
      //Fraction Unbound in Plasma
      subMetric = systemicData["FractionUnboundInPlasma"].toList();
      subClearance.GetFractionUnboundInPlasma().SetValue(subMetric[0].toDouble());
      //Intrinsic clearance
      subMetric = systemicData["IntrinsicClearance"].toList();
      auto& clearanceUnit = biogears::VolumePerTimeMassUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subClearance.GetIntrinsicClearance().SetValue(subMetric[0].toDouble(), clearanceUnit);
      //Renal clearance
      subMetric = systemicData["RenalClearance"].toList();
      subClearance.GetRenalClearance().SetValue(subMetric[0].toDouble(), clearanceUnit);
      //Systemic clearance
      subMetric = systemicData["SystemicClearance"].toList();
      subClearance.GetSystemicClearance().SetValue(subMetric[0].toDouble(), clearanceUnit);
    }

    //---Renal Dynamics: Clearance or Regulation choice
    QString dynamicChoice = clearanceData["dynamicsChoice"].toString();
    if (dynamicChoice.toStdString().compare("clearance") == 0) {
      //If clearance, then BioGears will use the value of Systemic::RenalClearance
      subClearance.SetRenalDynamic(biogears::RenalDynamic::Clearance);
    } else {
      //We have Regulation defined -- all sub-data will be present
      subClearance.SetRenalDynamic(biogears::RenalDynamic::Regulation);
      QVariantMap regulationData = clearanceData["regulation"].toMap();
      //Charge in Blood
      subMetric = regulationData["ChargeInBlood"].toList();
      subClearance.SetChargeInBlood((CDM::enumCharge::value)subMetric[0].toInt());
      //Reabsorption Ratio
      subMetric = regulationData["ReabsorptionRatio"].toList();
      subClearance.GetRenalReabsorptionRatio().SetValue(subMetric[0].toDouble());
      //Transport Maximum
      subMetric = regulationData["TransportMaximum"].toList();
      auto& unit = biogears::MassPerTimeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subClearance.GetRenalTransportMaximum().SetValue(subMetric[0].toDouble(), unit);
      //Fraction Unbound In Plasma
      subMetric = regulationData["FractionUnboundInPlasma"].toList();
      subClearance.GetFractionUnboundInPlasma().SetValue(subMetric[0].toDouble());
    }
  }
  //--Pharmacokinetics--
  // Substance editor will send EITHER physicochemical data or tissueKinetics data (it cannot send both)
  // Set up PK depending on which one is provided.  If neither is given, then substance has no PK
  if (substanceData.find("Physicochemicals") != substanceData.end()) {
    QVariantMap pkData = substanceData["Physicochemicals"].toMap();

    auto& physChem = newSubstance->GetPK().GetPhysicochemicals(); //Creates SESubstancePharmacokinetics and SESubstancePhysicochemical props

    //If this section defined, substance editor will send all fields (no need to check for nulls --except for second PKA, which only zwitterions use)

    //Primary PKA
    subMetric = pkData["PrimaryPKA"].toList();
    physChem.GetPrimaryPKA().SetValue(subMetric[0].toDouble());
    //Secondary PKA
    subMetric = pkData["SecondaryPKA"].toList();
    if (!subMetric[0].isNull()) {
      physChem.GetSecondaryPKA().SetValue(subMetric[0].toDouble());
    }
    //Binding Protein
    subMetric = pkData["BindingProtein"].toList();
    physChem.SetBindingProtein((CDM::enumSubstanceBindingProtein::value)subMetric[0].toInt());
    //Blood Plasma Ratio
    subMetric = pkData["BloodPlasmaRatio"].toList();
    physChem.GetBloodPlasmaRatio().SetValue(subMetric[0].toDouble());
    //Fraction Unbound In Plasma
    subMetric = pkData["FractionUnboundInPlasma"].toList();
    physChem.GetFractionUnboundInPlasma().SetValue(subMetric[0].toDouble());
    //Ionic State
    subMetric = pkData["IonicState"].toList();
    physChem.SetIonicState((CDM::enumSubstanceIonicState::value)subMetric[0].toInt());
    //Log P
    subMetric = pkData["LogP"].toList();
    physChem.GetLogP().SetValue(subMetric[0].toDouble());
    //Hydrogen Bond Count
    subMetric = pkData["HydrogenBondCount"].toList();
    physChem.GetHydrogenBondCount().SetValue(subMetric[0].toDouble());
    //Polar Surface Area
    subMetric = pkData["PolarSurfaceArea"].toList();
    physChem.GetPolarSurfaceArea().SetValue(subMetric[0].toDouble());

  } else if (substanceData.find("TissueKinetics") != substanceData.end()) {
    QVariantMap pkData = substanceData["TissueKinetics"].toMap();

    auto& subPK = newSubstance->GetPK(); //Creates SESubstancePharmacokinetics

    //If this section defined, substance editor will send all fields (no need to check for nulls)
    //Need to add partition coefficients one by one
    //Bone
    subMetric = pkData["BonePartitionCoefficient"].toList();
    subPK.GetTissueKinetics("BoneTissue").GetPartitionCoefficient().SetValue(subMetric[0].toDouble());
    //Brain
    subMetric = pkData["BrainPartitionCoefficient"].toList();
    subPK.GetTissueKinetics("BrainTissue").GetPartitionCoefficient().SetValue(subMetric[0].toDouble());
    //Fat
    subMetric = pkData["FatPartitionCoefficient"].toList();
    subPK.GetTissueKinetics("FatTissue").GetPartitionCoefficient().SetValue(subMetric[0].toDouble());
    //Gut
    subMetric = pkData["GutPartitionCoefficient"].toList();
    subPK.GetTissueKinetics("GutTissue").GetPartitionCoefficient().SetValue(subMetric[0].toDouble());
    //LeftKidney
    subMetric = pkData["LeftKidneyPartitionCoefficient"].toList();
    subPK.GetTissueKinetics("LeftKidneyTissue").GetPartitionCoefficient().SetValue(subMetric[0].toDouble());
    //LeftLung
    subMetric = pkData["LeftLungPartitionCoefficient"].toList();
    subPK.GetTissueKinetics("LeftLungTissue").GetPartitionCoefficient().SetValue(subMetric[0].toDouble());
    //Liver
    subMetric = pkData["LiverPartitionCoefficient"].toList();
    subPK.GetTissueKinetics("LiverTissue").GetPartitionCoefficient().SetValue(subMetric[0].toDouble());
    //Muscle
    subMetric = pkData["MusclePartitionCoefficient"].toList();
    subPK.GetTissueKinetics("MuscleTissue").GetPartitionCoefficient().SetValue(subMetric[0].toDouble());
    //Myocardium
    subMetric = pkData["MyocardiumPartitionCoefficient"].toList();
    subPK.GetTissueKinetics("MyocardiumTissue").GetPartitionCoefficient().SetValue(subMetric[0].toDouble());
    //RightKidney
    subMetric = pkData["RightKidneyPartitionCoefficient"].toList();
    subPK.GetTissueKinetics("RightKidneyTissue").GetPartitionCoefficient().SetValue(subMetric[0].toDouble());
    //RightLung
    subMetric = pkData["RightLungPartitionCoefficient"].toList();
    subPK.GetTissueKinetics("RightLungTissue").GetPartitionCoefficient().SetValue(subMetric[0].toDouble());
    //Skin
    subMetric = pkData["SkinPartitionCoefficient"].toList();
    subPK.GetTissueKinetics("SkinTissue").GetPartitionCoefficient().SetValue(subMetric[0].toDouble());
    //Spleen
    subMetric = pkData["SpleenPartitionCoefficient"].toList();
    subPK.GetTissueKinetics("SpleenTissue").GetPartitionCoefficient().SetValue(subMetric[0].toDouble());
  }

  //--Pharmacodynamics--(only present if defined by user, otherwise skip)
  if (substanceData.find("Pharmacodynamics") != substanceData.end()) {
    QVariantMap pdData = substanceData["Pharmacodynamics"].toMap();

    auto& subPD = newSubstance->GetPD(); //Creates SESubstancePharmacodynamics

    //Shape Parameter is required -- All others default to 0 (no effect) if not given
    //Shape Parameter
    subMetric = pdData["ShapeParameter"].toList();
    subPD.GetEMaxShapeParameter().SetValue(subMetric[0].toDouble());
    //Effect Site Rate Constant
    subMetric = pdData["EffectSiteRateConstant"].toList();
    if (!subMetric[0].isNull()) {
      auto& rateUnit = biogears::FrequencyUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetEffectSiteRateConstant().SetValue(subMetric[0].toDouble(), rateUnit);
    } else {
      subPD.GetEffectSiteRateConstant().SetValue(0.0, biogears::FrequencyUnit::Per_s);
    }
    double modifierE0 = 0.0;
    double modifierEC50 = 0.0;
    //Bronchodilation
    subMetric = pdData["BronchodilationMaxEffect"].toList();
    modifierE0 = subMetric[0].isNull() ? 0.0 : subMetric[0].toDouble();
    subPD.GetBronchodilation().GetEMax().SetValue(modifierE0);
    subMetric = pdData["BronchodilationEC50"].toList();
    if (!subMetric[0].isNull()) {
      auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetBronchodilation().GetEC50().SetValue(subMetric[0].toDouble(), cUnit);
    } else {
      subPD.GetBronchodilation().GetEC50().SetValue(0.0, biogears::MassPerVolumeUnit::ug_Per_mL);
    }
    //Diastolic Pressure
    subMetric = pdData["DiastolicPressureMaxEffect"].toList();
    modifierE0 = subMetric[0].isNull() ? 0.0 : subMetric[0].toDouble();
    subPD.GetDiastolicPressureModifier().GetEMax().SetValue(modifierE0);
    subMetric = pdData["DiastolicPressureEC50"].toList();
    if (!subMetric[0].isNull()) {
      auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetDiastolicPressureModifier().GetEC50().SetValue(subMetric[0].toDouble(), cUnit);
    } else {
      subPD.GetDiastolicPressureModifier().GetEC50().SetValue(0.0, biogears::MassPerVolumeUnit::ug_Per_mL);
    }
    //Systolic Pressure
    subMetric = pdData["SystolicPressureMaxEffect"].toList();
    modifierE0 = subMetric[0].isNull() ? 0.0 : subMetric[0].toDouble();
    subPD.GetSystolicPressureModifier().GetEMax().SetValue(modifierE0);
    subMetric = pdData["SystolicPressureEC50"].toList();
    if (!subMetric[0].isNull()) {
      auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetSystolicPressureModifier().GetEC50().SetValue(subMetric[0].toDouble(), cUnit);
    } else {
      subPD.GetSystolicPressureModifier().GetEC50().SetValue(0.0, biogears::MassPerVolumeUnit::ug_Per_mL);
    }
    //Fever
    subMetric = pdData["FeverMaxEffect"].toList();
    modifierE0 = subMetric[0].isNull() ? 0.0 : subMetric[0].toDouble();
    subPD.GetFeverModifier().GetEMax().SetValue(modifierE0);
    subMetric = pdData["FeverEC50"].toList();
    if (!subMetric[0].isNull()) {
      auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetFeverModifier().GetEC50().SetValue(subMetric[0].toDouble(), cUnit);
    } else {
      subPD.GetFeverModifier().GetEC50().SetValue(0.0, biogears::MassPerVolumeUnit::ug_Per_mL);
    }
    //Heart Rate
    subMetric = pdData["HeartRateMaxEffect"].toList();
    modifierE0 = subMetric[0].isNull() ? 0.0 : subMetric[0].toDouble();
    subPD.GetHeartRateModifier().GetEMax().SetValue(modifierE0);
    subMetric = pdData["HeartRateEC50"].toList();
    if (!subMetric[0].isNull()) {
      auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetHeartRateModifier().GetEC50().SetValue(subMetric[0].toDouble(), cUnit);
    } else {
      subPD.GetHeartRateModifier().GetEC50().SetValue(0.0, biogears::MassPerVolumeUnit::ug_Per_mL);
    }
    //Hemorrhage
    subMetric = pdData["HemorrhageMaxEffect"].toList();
    modifierE0 = subMetric[0].isNull() ? 0.0 : subMetric[0].toDouble();
    subPD.GetHemorrhageModifier().GetEMax().SetValue(modifierE0);
    subMetric = pdData["HemorrhageEC50"].toList();
    if (!subMetric[0].isNull()) {
      auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetHemorrhageModifier().GetEC50().SetValue(subMetric[0].toDouble(), cUnit);
    } else {
      subPD.GetHemorrhageModifier().GetEC50().SetValue(0.0, biogears::MassPerVolumeUnit::ug_Per_mL);
    }
    //Respiration Rate
    subMetric = pdData["RespirationRateMaxEffect"].toList();
    modifierE0 = subMetric[0].isNull() ? 0.0 : subMetric[0].toDouble();
    subPD.GetRespirationRateModifier().GetEMax().SetValue(modifierE0);
    subMetric = pdData["RespirationRateEC50"].toList();
    if (!subMetric[0].isNull()) {
      auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetRespirationRateModifier().GetEC50().SetValue(subMetric[0].toDouble(), cUnit);
    } else {
      subPD.GetRespirationRateModifier().GetEC50().SetValue(0.0, biogears::MassPerVolumeUnit::ug_Per_mL);
    }
    //Sedation
    subMetric = pdData["SedationMaxEffect"].toList();
    modifierE0 = subMetric[0].isNull() ? 0.0 : subMetric[0].toDouble();
    subPD.GetSedation().GetEMax().SetValue(modifierE0);
    subMetric = pdData["SedationEC50"].toList();
    if (!subMetric[0].isNull()) {
      auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetSedation().GetEC50().SetValue(subMetric[0].toDouble(), cUnit);
    } else {
      subPD.GetSedation().GetEC50().SetValue(0.0, biogears::MassPerVolumeUnit::ug_Per_mL);
    }
    //Tidal Volume
    subMetric = pdData["TidalVolumeMaxEffect"].toList();
    modifierE0 = subMetric[0].isNull() ? 0.0 : subMetric[0].toDouble();
    subPD.GetTidalVolumeModifier().GetEMax().SetValue(modifierE0);
    subMetric = pdData["TidalVolumeEC50"].toList();
    if (!subMetric[0].isNull()) {
      auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetTidalVolumeModifier().GetEC50().SetValue(subMetric[0].toDouble(), cUnit);
    } else {
      subPD.GetTidalVolumeModifier().GetEC50().SetValue(0.0, biogears::MassPerVolumeUnit::ug_Per_mL);
    }
    //Tubular Permeability
    subMetric = pdData["TubularPermeabilityMaxEffect"].toList();
    modifierE0 = subMetric[0].isNull() ? 0.0 : subMetric[0].toDouble();
    subPD.GetTubularPermeabilityModifier().GetEMax().SetValue(modifierE0);
    subMetric = pdData["TubularPermeabilityEC50"].toList();
    if (!subMetric[0].isNull()) {
      auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetTubularPermeabilityModifier().GetEC50().SetValue(subMetric[0].toDouble(), cUnit);
    } else {
      subPD.GetTubularPermeabilityModifier().GetEC50().SetValue(0.0, biogears::MassPerVolumeUnit::ug_Per_mL);
    }
    //Central Nervous
    subMetric = pdData["CentralNervousMaxEffect"].toList();
    modifierE0 = subMetric[0].isNull() ? 0.0 : subMetric[0].toDouble();
    subPD.GetCentralNervousModifier().GetEMax().SetValue(modifierE0);
    subMetric = pdData["CentralNervousEC50"].toList();
    if (!subMetric[0].isNull()) {
      auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetCentralNervousModifier().GetEC50().SetValue(subMetric[0].toDouble(), cUnit);
    } else {
      subPD.GetCentralNervousModifier().GetEC50().SetValue(0.0, biogears::MassPerVolumeUnit::ug_Per_mL);
    }
    //Pain
    subMetric = pdData["PainReductionMaxEffect"].toList();
    modifierE0 = subMetric[0].isNull() ? 0.0 : subMetric[0].toDouble();
    subPD.GetPainModifier().GetEMax().SetValue(modifierE0);
    subMetric = pdData["PainReductionEC50"].toList();
    if (!subMetric[0].isNull()) {
      auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetPainModifier().GetEC50().SetValue(subMetric[0].toDouble(), cUnit);
    } else {
      subPD.GetPainModifier().GetEC50().SetValue(0.0, biogears::MassPerVolumeUnit::ug_Per_mL);
    }
    //Antibacterial Effect
    subMetric = pdData["AntibacterialEffect"].toList();
    if (!subMetric[0].isNull()) {
      auto& effectRateUnit = biogears::FrequencyUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetAntibacterialEffect().SetValue(subMetric[0].toDouble(), effectRateUnit);
    } else {
      subPD.GetAntibacterialEffect().SetValue(0.0, biogears::FrequencyUnit::Per_s);
    }
    //Neuromuscular Block
    subMetric = pdData["NeuromuscularBlockMaxEffect"].toList();
    modifierE0 = subMetric[0].isNull() ? 0.0 : subMetric[0].toDouble();
    subPD.GetNeuromuscularBlock().GetEMax().SetValue(modifierE0);
    subMetric = pdData["NeuromuscularBlockEC50"].toList();
    if (!subMetric[0].isNull()) {
      auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetNeuromuscularBlock().GetEC50().SetValue(subMetric[0].toDouble(), cUnit);
    } else {
      subPD.GetNeuromuscularBlock().GetEC50().SetValue(0.0, biogears::MassPerVolumeUnit::ug_Per_mL);
    }
    //Pupillary Response
    subMetric = pdData["PupilSizeMaxEffect"].toList();
    modifierE0 = subMetric[0].isNull() ? 0.0 : subMetric[0].toDouble();
    subPD.GetPupilSizeModifier().GetEMax().SetValue(modifierE0);
    subMetric = pdData["PupilSizeEC50"].toList();
    if (!subMetric[0].isNull()) {
      auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetPupilSizeModifier().GetEC50().SetValue(subMetric[0].toDouble(), cUnit);
    } else {
      subPD.GetPupilSizeModifier().GetEC50().SetValue(0.0, biogears::MassPerVolumeUnit::ug_Per_mL);
    }
    subMetric = pdData["PupilReactivityMaxEffect"].toList();
    modifierE0 = subMetric[0].isNull() ? 0.0 : subMetric[0].toDouble();
    subPD.GetPupilReactivityModifier().GetEMax().SetValue(modifierE0);
    subMetric = pdData["PupilReactivityEC50"].toList();
    if (!subMetric[0].isNull()) {
      auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(subMetric[1].toString().toStdString());
      subPD.GetPupilReactivityModifier().GetEC50().SetValue(subMetric[0].toDouble(), cUnit);
    } else {
      subPD.GetPupilReactivityModifier().GetEC50().SetValue(0.0, biogears::MassPerVolumeUnit::ug_Per_mL);
    }
  }

  export_substance(newSubstance);
  //If the substance has PD behavior, add it to the list of drugs so that it will be immediately available to use in Bg Actions
  if (newSubstance->HasPD() && newSubstance->HasPK()) {
    _drugs_list.append(QString::fromStdString(newSubstance->GetName()));
    if (newSubstance->GetState() == CDM::enumSubstanceState::Gas) {
      _volatile_drugs_list.append(QString::fromStdString(newSubstance->GetName())); //If drug is gaseous, it can be administered through ventilator
    }
  }
}

QVariantMap Scenario::edit_substance()
{
  //Create a QVariantMap with key = PropName and item = {value, unit}
  //Qml interpets QVariantMaps as Javascript objects, which we can index by prop name
  QVariantMap substanceMap;

  //Open file dialog in substance folder
  QString substanceFile = QFileDialog::getOpenFileName(nullptr, "Edit Substance", "./substances", "Substance (*.xml)");
  if (substanceFile.isNull()) {
    //File returns null string if user cancels without selecting a compound file.  Return empty map (Qml side will check for this)
    return substanceMap;
  }
  //Load file and create and SESubstance object from it using serializer
  if (!QFileInfo::exists(substanceFile)) {
    throw std::runtime_error("Unable to locate " + substanceFile.toStdString());
  }
  std::unique_ptr<CDM::ObjectData> substanceXmlData = biogears::Serializer::ReadFile(substanceFile.toStdString(), _engine->GetLogger());
  CDM::SubstanceData* substanceData = dynamic_cast<CDM::SubstanceData*>(substanceXmlData.get());
  biogears::SESubstance* sub = new biogears::SESubstance(_engine->GetLogger());
  sub->Load(*substanceData);

  //Each map entry is a list of two items.  subField[0] = value, subField[1] = unit
  QList<QVariant> subField{ "", "" };

  //Name (required)
  subField[0] = QString::fromStdString(sub->GetName());
  subField[1] = "";
  substanceMap["Name"] = subField;
  //State (required)
  subField[0] = (int)sub->GetState();
  subField[1] = "";
  substanceMap["State"] = subField;

  //----Optional physical data
  //Classification
  if (sub->HasClassification()) {
    subField[0] = (int)sub->GetClassification();
    subField[1] = "";
    substanceMap["Classification"] = subField;
  }
  //Molar Mass
  if (sub->HasMolarMass()) {
    subField[0] = sub->GetMolarMass(biogears::MassPerAmountUnit::g_Per_mol);
    subField[1] = "g/mol";
    substanceMap["MolarMass"] = subField;
  }
  //Density
  if (sub->HasDensity()) {
    subField[0] = sub->GetDensity(biogears::MassPerVolumeUnit::g_Per_mL);
    subField[1] = "g/mL";
    substanceMap["Density"] = subField;
  }
  //Maximum Diffusion Flux
  if (sub->HasMaximumDiffusionFlux()) {
    subField[0] = sub->GetMaximumDiffusionFlux(biogears::MassPerAreaTimeUnit::g_Per_cm2_s);
    subField[1] = "g/cm^2 s";
    substanceMap["MaximumDiffusionFlux"] = subField;
  }
  //Michaelis Coefficient
  if (sub->HasMichaelisCoefficient()) {
    subField[0] = sub->GetMichaelisCoefficient().GetValue();
    subField[1] = "";
    substanceMap["MichaelisCoefficient"] = subField;
  }
  //Membrane Resistance
  if (sub->HasMembraneResistance()) {
    subField[0] = sub->GetMembraneResistance().GetValue(biogears::ElectricResistanceUnit::Ohm);
    subField[1] = "ohm";
    substanceMap["MembraneResistance"] = subField;
  }
  //Relative Diffusion Coefficient
  if (sub->HasRelativeDiffusionCoefficient()) {
    subField[0] = sub->GetRelativeDiffusionCoefficient().GetValue();
    subField[1] = "";
    substanceMap["RelativeDiffusionCoefficient"] = subField;
  }
  //Solubility Coefficient
  if (sub->HasSolubilityCoefficient()) {
    subField[0] = sub->GetSolubilityCoefficient().GetValue(biogears::InversePressureUnit::Inverse_atm);
    subField[1] = "1/atm";
    substanceMap["SolubilityCoefficient"] = subField;
  }
  if (sub->HasClearance()) {
    auto& clearanceData = sub->GetClearance();
    QVariantMap clearanceMap;

    //--Check for systemic clearance data.  If present, all sub-fields will be defined
    if (clearanceData.HasSystemic()) {
      QVariantMap systemicMap;
      //Intrinsic Clearance
      subField[0] = clearanceData.GetIntrinsicClearance(biogears::VolumePerTimeMassUnit::mL_Per_min_kg);
      subField[1] = "mL/min kg";
      systemicMap["IntrinsicClearance"] = subField;
      //Renal Clearance
      subField[0] = clearanceData.GetRenalClearance(biogears::VolumePerTimeMassUnit::mL_Per_min_kg);
      subField[1] = "mL/min kg";
      systemicMap["RenalClearance"] = subField;
      //Systemic Clearance
      subField[0] = clearanceData.GetSystemicClearance(biogears::VolumePerTimeMassUnit::mL_Per_min_kg);
      subField[1] = "mL/min kg";
      systemicMap["SystemicClearance"] = subField;
      //Fraction unbound in plasma
      subField[0] = clearanceData.GetFractionUnboundInPlasma().GetValue();
      subField[1] = "";
      systemicMap["FractionUnboundInPlasma"] = subField;
      //Fraction excreted in feces
      subField[0] = clearanceData.GetFractionExcretedInFeces().GetValue();
      subField[1] = "";
      systemicMap["FractionExcretedInFeces"] = subField;

      //Add systemic map as submap to clearance map
      clearanceMap["systemic"] = systemicMap;
    }
    //--Check for renal dynamics
    if (clearanceData.HasRenalDynamic()) {
      if (clearanceData.GetRenalDynamic() == biogears::RenalDynamic::Clearance) {
        clearanceMap["dynamicsChoice"] = "clearance";
      } else if (clearanceData.GetRenalDynamic() == biogears::RenalDynamic::Regulation) {
        clearanceMap["dynamicsChoice"] = "regulation";
        QVariantMap regulationMap;
        //Charge in blood
        subField[0] = (int)clearanceData.GetChargeInBlood();
        subField[1] = "";
        regulationMap["ChargeInBlood"] = subField;
        //Reabsorption ratio
        subField[0] = clearanceData.GetRenalReabsorptionRatio().GetValue();
        subField[1] = "";
        regulationMap["ReabsorptionRatio"] = subField;
        //Transport maximum
        subField[0] = clearanceData.GetRenalTransportMaximum().GetValue(biogears::MassPerTimeUnit::mg_Per_min);
        subField[1] = "mg/min";
        regulationMap["TransportMaximum"] = subField;
        //Fraction unbound in plasma
        subField[0] = clearanceData.GetFractionUnboundInPlasma().GetValue();
        subField[1] = "";
        regulationMap["FractionUnboundInPlasma"] = subField;

        //Add regulation map to clearance map
        clearanceMap["regulation"] = regulationMap;
      }
    }
    //Add clearance map to substance map
    substanceMap["Clearance"] = clearanceMap;
  }

  //---Pharmacokinetics------
  if (sub->HasPK()) {
    auto& subPK = sub->GetPK();
    QVariantMap pkMap;

    //Option 1: Physicochemicals
    if (subPK.HasPhysicochemicals()) {
      auto& physChem = subPK.GetPhysicochemicals();
      subField[1] = ""; //None of these entries have units, so just set "unit" place to empty ahead of time
      //Primary PKA
      subField[0] = physChem.GetPrimaryPKA().GetValue();
      pkMap["PrimaryPKA"] = subField;
      //Secondary PKA -- only zwitterions will have this
      if (physChem.HasSecondaryPKA()) {
        subField[0] = physChem.GetSecondaryPKA().GetValue();
        pkMap["SecondaryPKA"] = subField;
      }
      //Binding Protein
      subField[0] = (int)physChem.GetBindingProtein();
      pkMap["BindingProtein"] = subField;
      //Blood Plasma Ratio
      subField[0] = physChem.GetBloodPlasmaRatio().GetValue();
      pkMap["BloodPlasmaRatio"] = subField;
      //Fraction Unbound in Plasma
      subField[0] = physChem.GetFractionUnboundInPlasma().GetValue();
      pkMap["FractionUnboundInPlasma"] = subField;
      //Ionic State
      subField[0] = (int)physChem.GetIonicState();
      pkMap["IonicState"] = subField;
      //Log P
      subField[0] = physChem.GetLogP().GetValue();
      pkMap["LogP"] = subField;
      //Hydrogen bond count
      subField[0] = physChem.GetHydrogenBondCount().GetValue();
      pkMap["HydrogenBondCount"] = subField;
      //Polar Surface Area
      subField[0] = physChem.GetPolarSurfaceArea().GetValue();
      pkMap["PolarSurfaceArea"] = subField;

      //Set "Physicochemical" field of substance map
      substanceMap["Physicochemicals"] = pkMap;
    }

    //Option 2 : Tissue Kinetics
    if (subPK.HasTissueKinetics()) {
      subField[1] = ""; //No units for any partition coefficient so set unit place to empty now
      //Bone Tissue
      subField[0] = subPK.GetTissueKinetics("BoneTissue").GetPartitionCoefficient().GetValue();
      pkMap["BonePartitionCoefficient"] = subField;
      //Brain Tissue
      subField[0] = subPK.GetTissueKinetics("BrainTissue").GetPartitionCoefficient().GetValue();
      pkMap["BrainPartitionCoefficient"] = subField;
      //Fat Tissue
      subField[0] = subPK.GetTissueKinetics("FatTissue").GetPartitionCoefficient().GetValue();
      pkMap["FatPartitionCoefficient"] = subField;
      //Gut Tissue
      subField[0] = subPK.GetTissueKinetics("GutTissue").GetPartitionCoefficient().GetValue();
      pkMap["GutPartitionCoefficient"] = subField;
      //LeftKidney Tissue
      subField[0] = subPK.GetTissueKinetics("LeftKidneyTissue").GetPartitionCoefficient().GetValue();
      pkMap["LeftKidneyPartitionCoefficient"] = subField;
      //LeftLung Tissue
      subField[0] = subPK.GetTissueKinetics("LeftLungTissue").GetPartitionCoefficient().GetValue();
      pkMap["LeftLungPartitionCoefficient"] = subField;
      //Liver Tissue
      subField[0] = subPK.GetTissueKinetics("LiverTissue").GetPartitionCoefficient().GetValue();
      pkMap["LiverPartitionCoefficient"] = subField;
      //Muscle Tissue
      subField[0] = subPK.GetTissueKinetics("MuscleTissue").GetPartitionCoefficient().GetValue();
      pkMap["MusclePartitionCoefficient"] = subField;
      //Myocardium Tissue
      subField[0] = subPK.GetTissueKinetics("MyocardiumTissue").GetPartitionCoefficient().GetValue();
      pkMap["MyocardiumPartitionCoefficient"] = subField;
      //RightKidney Tissue
      subField[0] = subPK.GetTissueKinetics("RightKidneyTissue").GetPartitionCoefficient().GetValue();
      pkMap["RightKidneyPartitionCoefficient"] = subField;
      //RightLung Tissue
      subField[0] = subPK.GetTissueKinetics("RightLungTissue").GetPartitionCoefficient().GetValue();
      pkMap["RightLungPartitionCoefficient"] = subField;
      //Skin Tissue
      subField[0] = subPK.GetTissueKinetics("SkinTissue").GetPartitionCoefficient().GetValue();
      pkMap["SkinPartitionCoefficient"] = subField;
      //Spleen Tissue
      subField[0] = subPK.GetTissueKinetics("SpleenTissue").GetPartitionCoefficient().GetValue();
      pkMap["SpleenPartitionCoefficient"] = subField;

      //Add map to Tissue Kinetics key of Substance Map
      substanceMap["TissueKinetics"] = pkMap;
    }
  }

  //----Pharmacodynamics
  if (sub->HasPD()) {
    auto& subPD = sub->GetPD();
    QVariantMap pdMap;
    //Shape parameter
    subField[0] = subPD.GetEMaxShapeParameter().GetValue();
    subField[1] = "";
    pdMap["ShapeParameter"] = subField;
    //Effect site rate constant
    subField[0] = subPD.GetEffectSiteRateConstant().GetValue(biogears::FrequencyUnit::Per_min);
    subField[1] = "1/min";
    pdMap["EffectSiteRateConstant"] = subField;
    //Antibacterial effect
    subField[0] = subPD.GetAntibacterialEffect().GetValue(biogears::FrequencyUnit::Per_s);
    subField[1] = "1/s";
    pdMap["AntibacterialEffect"] = subField;
    //Bronchodilation Modifier
    subField[0] = subPD.GetBronchodilation().GetEMax().GetValue();
    subField[1] = "";
    pdMap["BronchodilationMaxEffect"] = subField;
    subField[0] = subPD.GetBronchodilation().GetEC50().GetValue(biogears::MassPerVolumeUnit::ug_Per_L);
    subField[1] = "ug/L";
    pdMap["BronchodilationEC50"] = subField;
    //Diastolic pressure Modifier
    subField[0] = subPD.GetDiastolicPressureModifier().GetEMax().GetValue();
    subField[1] = "";
    pdMap["DiastolicPressureMaxEffect"] = subField;
    subField[0] = subPD.GetDiastolicPressureModifier().GetEC50().GetValue(biogears::MassPerVolumeUnit::ug_Per_L);
    subField[1] = "ug/L";
    pdMap["DiastolicPressureEC50"] = subField;
    //Systolic pressure Modifier
    subField[0] = subPD.GetSystolicPressureModifier().GetEMax().GetValue();
    subField[1] = "";
    pdMap["SystolicPressureMaxEffect"] = subField;
    subField[0] = subPD.GetSystolicPressureModifier().GetEC50().GetValue(biogears::MassPerVolumeUnit::ug_Per_L);
    subField[1] = "ug/L";
    pdMap["SystolicPressureEC50"] = subField;
    //Fever Modifier
    subField[0] = subPD.GetFeverModifier().GetEMax().GetValue();
    subField[1] = "";
    pdMap["FeverMaxEffect"] = subField;
    subField[0] = subPD.GetFeverModifier().GetEC50().GetValue(biogears::MassPerVolumeUnit::ug_Per_L);
    subField[1] = "ug/L";
    pdMap["FeverEC50"] = subField;
    //Heart Rate Modifier
    subField[0] = subPD.GetHeartRateModifier().GetEMax().GetValue();
    subField[1] = "";
    pdMap["HeartRateMaxEffect"] = subField;
    subField[0] = subPD.GetHeartRateModifier().GetEC50().GetValue(biogears::MassPerVolumeUnit::ug_Per_L);
    subField[1] = "ug/L";
    pdMap["HeartRateEC50"] = subField;
    //Hemorrhage Modifier
    subField[0] = subPD.GetHemorrhageModifier().GetEMax().GetValue();
    subField[1] = "";
    pdMap["HemorrhageMaxEffect"] = subField;
    subField[0] = subPD.GetHemorrhageModifier().GetEC50().GetValue(biogears::MassPerVolumeUnit::ug_Per_L);
    subField[1] = "ug/L";
    pdMap["HemorrhageEC50"] = subField;
    //Neuromuscular Modifier
    subField[0] = subPD.GetNeuromuscularBlock().GetEMax().GetValue();
    subField[1] = "";
    pdMap["NeuromuscularBlockMaxEffect"] = subField;
    subField[0] = subPD.GetNeuromuscularBlock().GetEC50().GetValue(biogears::MassPerVolumeUnit::ug_Per_L);
    subField[1] = "ug/L";
    pdMap["NeuromuscularBlockEC50"] = subField;
    //Pain Modifier
    subField[0] = subPD.GetPainModifier().GetEMax().GetValue();
    subField[1] = "";
    pdMap["PainReductionMaxEffect"] = subField;
    subField[0] = subPD.GetPainModifier().GetEC50().GetValue(biogears::MassPerVolumeUnit::ug_Per_L);
    subField[1] = "ug/L";
    pdMap["PainReductionEC50"] = subField;
    //Respiration Rate Modifier
    subField[0] = subPD.GetRespirationRateModifier().GetEMax().GetValue();
    subField[1] = "";
    pdMap["RespirationRateMaxEffect"] = subField;
    subField[0] = subPD.GetRespirationRateModifier().GetEC50().GetValue(biogears::MassPerVolumeUnit::ug_Per_L);
    subField[1] = "ug/L";
    pdMap["RespirationRateEC50"] = subField;
    //Tidal Volume Modifier
    subField[0] = subPD.GetTidalVolumeModifier().GetEMax().GetValue();
    subField[1] = "";
    pdMap["TidalVolumeMaxEffect"] = subField;
    subField[0] = subPD.GetTidalVolumeModifier().GetEC50().GetValue(biogears::MassPerVolumeUnit::ug_Per_L);
    subField[1] = "ug/L";
    pdMap["TidalVolumeEC50"] = subField;
    //Sedation Modifier
    subField[0] = subPD.GetSedation().GetEMax().GetValue();
    subField[1] = "";
    pdMap["SedationMaxEffect"] = subField;
    subField[0] = subPD.GetSedation().GetEC50().GetValue(biogears::MassPerVolumeUnit::ug_Per_L);
    subField[1] = "ug/L";
    pdMap["SedationEC50"] = subField;
    //Tubular Permeability Modifier
    subField[0] = subPD.GetTubularPermeabilityModifier().GetEMax().GetValue();
    subField[1] = "";
    pdMap["TubularPermeabilityMaxEffect"] = subField;
    subField[0] = subPD.GetTubularPermeabilityModifier().GetEC50().GetValue(biogears::MassPerVolumeUnit::ug_Per_L);
    subField[1] = "ug/L";
    pdMap["TubularPermeabilityEC50"] = subField;
    //Central Nervous Modifier
    subField[0] = subPD.GetCentralNervousModifier().GetEMax().GetValue();
    subField[1] = "";
    pdMap["CentralNervousMaxEffect"] = subField;
    subField[0] = subPD.GetCentralNervousModifier().GetEC50().GetValue(biogears::MassPerVolumeUnit::ug_Per_L);
    subField[1] = "ug/L";
    pdMap["CentralNervousEC50"] = subField;
    //Pupil-Size Modifier
    subField[0] = subPD.GetPupilSizeModifier().GetEMax().GetValue();
    subField[1] = "";
    pdMap["PupilSizeMaxEffect"] = subField;
    subField[0] = subPD.GetPupilSizeModifier().GetEC50().GetValue(biogears::MassPerVolumeUnit::ug_Per_L);
    subField[1] = "ug/L";
    pdMap["PupilSizeEC50"] = subField;
    //Pupil-Reactivity Modifier
    subField[0] = subPD.GetPupilReactivityModifier().GetEMax().GetValue();
    subField[1] = "";
    pdMap["PupilReactivityMaxEffect"] = subField;
    subField[0] = subPD.GetPupilReactivityModifier().GetEC50().GetValue(biogears::MassPerVolumeUnit::ug_Per_L);
    subField[1] = "ug/L";
    pdMap["PupilReactivityEC50"] = subField;

    //Add PD map to Substance Map
    substanceMap["Pharmacodynamics"] = pdMap;
  }

  return substanceMap;
}

void Scenario::export_substance()
{
}

void Scenario::export_substance(const biogears::SESubstance* substance)
{
  std::string fileLoc = "./substances/" + substance->GetName() + ".xml";
  std::string fullPath = biogears::ResolvePath(fileLoc);
  biogears::CreateFilePath(fullPath);
  std::ofstream stream(fullPath);
  xml_schema::namespace_infomap info;
  info[""].name = "uri:/mil/tatrc/physiology/datamodel";

  std::unique_ptr<CDM::SubstanceData> subData(substance->Unload());
  CDM::Substance(stream, *subData, info); //Need to speficy CDM so no collision with Substance QObject
  stream.close();
  _engine->GetLogger()->Info("Saved substance: " + fullPath);
  return;
}

void Scenario::create_compound(QVariantMap compoundData)
{
  biogears::SESubstanceCompound* newCompound = new biogears::SESubstanceCompound(_engine->GetLogger());
  //JS objects are returned from QML as QVariantMap<QString (key), QVariant (item)>
  //For compound data, one key:value pair is <CompoundName : Name>
  //The remaining pairs are <SubstanceName : [Concentration, unit]>

  //Name
  QString compoundName = compoundData["Name"].toString(); //Used to gen file name
  newCompound->SetName(compoundName.toStdString());
  compoundData.remove("Name"); //Pop name off map so that we can loop over remaining keys to make component substances
  //Components
  biogears::SESubstance* component = nullptr;
  biogears::SESubstanceConcentration* componentData = nullptr;
  for (auto key : compoundData.keys()) {
    component = _engine->GetSubstances().GetSubstance(key.toStdString());
    componentData = new biogears::SESubstanceConcentration(*component);
    double concentration = compoundData[key].toList()[0].toDouble();
    auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(compoundData[key].toList()[1].toString().toStdString());
    componentData->GetConcentration().SetValue(concentration, cUnit);
    newCompound->GetComponents().push_back(*componentData);
  }

  export_compound(newCompound);
  //Add compound to _compounds_list so that it is immediately available to use in SubCompoundInfusion action
  //Add to transfusion list as well if blood components are defined
  _compounds_list.push_back(QString::fromStdString(newCompound->GetName()));
}

QVariantMap Scenario::edit_compound()
{
  //Create a QVariantMap with key = PropName and item = {value, unit}
  //Qml interpets QVariantMaps as Javascript objects, which we can index by prop name
  QVariantMap compoundMap;

  //Open file dialog in compound folder
  QString compoundFile = QFileDialog::getOpenFileName(nullptr, "Edit Compound", "./substances", "Compound (*.xml)");
  if (compoundFile.isNull()) {
    //File returns null string if user cancels without selecting a compound file.  Return empty map (Qml side will check for this)
    return compoundMap;
  }
  //Load file and create and SESubstanceCompound object from it using serializer
  if (!QFileInfo::exists(compoundFile)) {
    throw std::runtime_error("Unable to locate " + compoundFile.toStdString());
  }
  std::unique_ptr<CDM::ObjectData> compoundXmlData = biogears::Serializer::ReadFile(compoundFile.toStdString(), _engine->GetLogger());
  CDM::SubstanceCompoundData* compoundData = dynamic_cast<CDM::SubstanceCompoundData*>(compoundXmlData.get());
  biogears::SESubstanceCompound* compound = new biogears::SESubstanceCompound(_engine->GetLogger());
  compound->Load(*compoundData, _engine->GetSubstanceManager());

  //Each map entry is a list of two items.  compoundField[0] = value, compoundField[1] = unit
  QList<QVariant> componentField{ "", "" };

  //Loop over all components in the compound and put them in map with component name as key and [value, unit] pair as entry
  for (auto sub : compound->GetComponents()) {
    QString subName = QString::fromStdString(sub.GetSubstance().GetName());
    componentField[0] = sub.GetConcentration(biogears::MassPerVolumeUnit::mg_Per_L);
    componentField[1] = "mg/L";
    compoundMap[subName] = componentField;
  }
  //Add compound name to map
  componentField[0] = QString::fromStdString(compound->GetName());
  componentField[1] = "";
  compoundMap["Name"] = componentField;

  return compoundMap;
}

void Scenario::export_compound()
{
}
void Scenario::export_compound(const biogears::SESubstanceCompound* compound)
{
  std::string fileLoc = "./substances/" + compound->GetName() + ".xml";
  std::string fullPath = biogears::ResolvePath(fileLoc);
  biogears::CreateFilePath(fullPath);
  std::ofstream stream(fullPath);
  xml_schema::namespace_infomap info;
  info[""].name = "uri:/mil/tatrc/physiology/datamodel";

  std::unique_ptr<CDM::SubstanceCompoundData> compoundData(compound->Unload());
  SubstanceCompound(stream, *compoundData, info);
  stream.close();
  _engine->GetLogger()->Info("Saved compound: " + fullPath);
  return;
}

void Scenario::create_nutrition(QVariantMap nutrition)
{
  biogears::SENutrition* newNutrition = new biogears::SENutrition(_engine->GetLogger());
  //JS objects are returned from QML as QVariantMap<QString (key), QVariant (item)>
  //The key will be the field in the patient CDM (e.g. Name, Age, Gender...)
  //The item is a pair (value, unit), which is returned by QML as QList<QVariant>
  //We first convert the QVariantList to a QList, which allows us to index the value and unit
  //We then access values and convert them from QVariant to the appropriate type (string, double, int, etc)

  //Name
  QList<QVariant> nMetric = nutrition["Name"].toList();
  QString nutritionName = nMetric[0].toString(); //Used to gen file name
  newNutrition->SetName(nutritionName.toStdString());
  //Carbohydrate mass
  nMetric = nutrition["Carbohydrate"].toList();
  if (!nMetric[0].isNull()) {
    double carbs = nMetric[0].toDouble();
    auto& massUnit = biogears::MassUnit::GetCompoundUnit(nMetric[1].toString().toStdString());
    newNutrition->GetCarbohydrate().SetValue(carbs, massUnit);
  }
  //Protein mass
  nMetric = nutrition["Protein"].toList();
  if (!nMetric[0].isNull()) {
    double protein = nMetric[0].toDouble();
    auto& massUnit = biogears::MassUnit::GetCompoundUnit(nMetric[1].toString().toStdString());
    newNutrition->GetProtein().SetValue(protein, massUnit);
  }
  //Fat mass
  nMetric = nutrition["Fat"].toList();
  if (!nMetric[0].isNull()) {
    double fat = nMetric[0].toDouble();
    auto& massUnit = biogears::MassUnit::GetCompoundUnit(nMetric[1].toString().toStdString());
    newNutrition->GetFat().SetValue(fat, massUnit);
  }
  //Calcium mass
  nMetric = nutrition["Calcium"].toList();
  if (!nMetric[0].isNull()) {
    double calcium = nMetric[0].toDouble();
    auto& massUnit = biogears::MassUnit::GetCompoundUnit(nMetric[1].toString().toStdString());
    newNutrition->GetCalcium().SetValue(calcium, massUnit);
  }
  //Sodium mass
  nMetric = nutrition["Sodium"].toList();
  if (!nMetric[0].isNull()) {
    double sodium = nMetric[0].toDouble();
    auto& massUnit = biogears::MassUnit::GetCompoundUnit(nMetric[1].toString().toStdString());
    newNutrition->GetSodium().SetValue(sodium, massUnit);
  }
  //Sodium mass
  nMetric = nutrition["Water"].toList();
  if (!nMetric[0].isNull()) {
    double water = nMetric[0].toDouble();
    auto& volUnit = biogears::VolumeUnit::GetCompoundUnit(nMetric[1].toString().toStdString());
    newNutrition->GetWater().SetValue(water, volUnit);
  }

  export_nutrition(newNutrition);
  //Add new nutriton to _nutrition_list so that it is immediately available to Bg Consume Meal action
  _nutrition_list.push_back(QString::fromStdString(newNutrition->GetName()));
}

QVariantMap Scenario::edit_nutrition()
{
  //Create a QVariantMap with key = PropName and item = {value, unit}
  //Qml interpets QVariantMaps as Javascript objects, which we can index by prop name
  QVariantMap nutritionMap;

  //Open file dialog in nutrition folder
  QString nutritionFile = QFileDialog::getOpenFileName(nullptr, "Edit Nutrition", "./nutrition", "Nutrition (*.xml)");
  if (nutritionFile.isNull()) {
    //File returns null string if user cancels without selecting a nutrition file.  Return empty map (Qml side will check for this)
    return nutritionMap;
  }
  //Load file and create and SENutrition object from it using serializer
  if (!QFileInfo::exists(nutritionFile)) {
    throw std::runtime_error("Unable to locate " + nutritionFile.toStdString());
  }
  std::unique_ptr<CDM::ObjectData> nutritionXmlData = biogears::Serializer::ReadFile(nutritionFile.toStdString(), _engine->GetLogger());
  CDM::NutritionData* nutritionData = dynamic_cast<CDM::NutritionData*>(nutritionXmlData.get());
  biogears::SENutrition* nutrition = new biogears::SENutrition(_engine->GetLogger());
  nutrition->Load(*nutritionData);

  //Each map entry is a list of two items.  nutritionField[0] = value, nutritionField[1] = unit
  QList<QVariant> nutritionField{ "", "" };

  //Name
  nutritionField[0] = QString::fromStdString(nutrition->GetName());
  nutritionField[1] = "";
  nutritionMap["Name"] = nutritionField;
  //Carbohydrates
  if (nutrition->HasCarbohydrate()) {
    nutritionField[0] = nutrition->GetCarbohydrate(biogears::MassUnit::g);
    nutritionField[1] = "g";
    nutritionMap["Carbohydrate"] = nutritionField;
  }
  //Proteins
  if (nutrition->HasProtein()) {
    nutritionField[0] = nutrition->GetProtein(biogears::MassUnit::g);
    nutritionField[1] = "g";
    nutritionMap["Protein"] = nutritionField;
  }
  //Fats
  if (nutrition->HasFat()) {
    nutritionField[0] = nutrition->GetFat(biogears::MassUnit::g);
    nutritionField[1] = "g";
    nutritionMap["Fat"] = nutritionField;
  }
  //Calcium
  if (nutrition->HasCalcium()) {
    nutritionField[0] = nutrition->GetCalcium(biogears::MassUnit::mg);
    nutritionField[1] = "mg";
    nutritionMap["Calcium"] = nutritionField;
  }
  //Sodium
  if (nutrition->HasSodium()) {
    nutritionField[0] = nutrition->GetSodium(biogears::MassUnit::mg);
    nutritionField[1] = "mg";
    nutritionMap["Sodium"] = nutritionField;
  }
  //Water
  if (nutrition->HasWater()) {
    nutritionField[0] = nutrition->GetWater(biogears::VolumeUnit::L);
    nutritionField[1] = "L";
    nutritionMap["Water"] = nutritionField;
  }

  return nutritionMap;
}

QVariantMap Scenario::load_nutrition_for_meal(QString nutritionName)
{
  //Create a QVariantMap with key = PropName and item = {value, unit}
  QVariantMap nutritionMap;
  QDir nutritionDirectory = QDir("nutrition");
  if (!nutritionDirectory.exists()) {
    std::cout << "This is not the nutrition directory you're looking for";
  } else {
    QString fileBaseName = nutritionName + ".xml";
    QFileInfo nutritionFileInfo(nutritionDirectory, fileBaseName);
    biogears::SENutrition* nutrition = new biogears::SENutrition(_engine->GetLogger());
    if (nutritionFileInfo.isFile()) {
      std::unique_ptr<CDM::ObjectData> nutritionXMLData = biogears::Serializer::ReadFile(nutritionFileInfo.filePath().toStdString(), _engine->GetLogger());
      CDM::NutritionData* nutritionData = dynamic_cast<CDM::NutritionData*>(nutritionXMLData.get());
      nutrition->Load(*nutritionData);
      if (nutrition->HasWater()) {
        nutritionMap["Water"] = nutrition->GetWater().GetValue(biogears::VolumeUnit::mL);
      }
      if (nutrition->HasFat()) {
        nutritionMap["Fat"] = nutrition->GetFat().GetValue(biogears::MassUnit::g);
      }
      if (nutrition->HasProtein()) {
        nutritionMap["Protein"] = nutrition->GetProtein().GetValue(biogears::MassUnit::g);
      }
      if (nutrition->HasCarbohydrate()) {
        nutritionMap["Carbohydrates"] = nutrition->GetCarbohydrate().GetValue(biogears::MassUnit::g);
      }
      if (nutrition->HasSodium()) {
        nutritionMap["Sodium"] = nutrition->GetSodium().GetValue(biogears::MassUnit::mg);
      }
      if (nutrition->HasCalcium()) {
        nutritionMap["Calcium"] = nutrition->GetCalcium().GetValue(biogears::MassUnit::mg);
      }
      if (nutrition->HasName()) {
        nutritionMap["Meal"] = QString::fromStdString(nutrition->GetName());
      }
    }
  }
  return nutritionMap;
}
void Scenario::export_nutrition()
{
  if (_engine->GetActions().GetPatientActions().HasConsumeNutrients()) {
    export_nutrition(&(_engine->GetActions().GetPatientActions().GetConsumeNutrients()->GetNutrition()));
  }
}

void Scenario::export_nutrition(const biogears::SENutrition* nutrition)
{
  std::string fileLoc = "./nutrition/" + nutrition->GetName() + ".xml";
  std::string fullPath = biogears::ResolvePath(fileLoc);
  biogears::CreateFilePath(fullPath);
  std::ofstream stream(fullPath);
  xml_schema::namespace_infomap info;
  info[""].name = "uri:/mil/tatrc/physiology/datamodel";

  std::unique_ptr<CDM::NutritionData> pData(nutrition->Unload());
  Nutrition(stream, *pData, info);
  stream.close();
  _engine->GetLogger()->Info("Saved nutrition data: " + fullPath);
  return;
}

// Environment ______________________________________
QVariantMap Scenario::load_environment_action(QString enviroActionName)
{
  //Create a QVariantMap with key = PropName and item = {value, unit}
  QVariantMap enviroMap;
  QDir environmentDirectory = QDir("environment");
  if (!environmentDirectory.exists()) {
    std::cout << "This is not the environment directory you're looking for";
  } else {
    QString fileBaseName = enviroActionName + ".xml";
    QFileInfo environmentFileInfo(environmentDirectory, fileBaseName);
    biogears::SEEnvironmentalConditions* environment = new biogears::SEEnvironmentalConditions(_engine->GetSubstances());
    if (environmentFileInfo.isFile()) {
      std::unique_ptr<CDM::ObjectData> environmentXMLData = biogears::Serializer::ReadFile(environmentFileInfo.filePath().toStdString(), _engine->GetLogger());
      CDM::EnvironmentalConditionsData* environmentData = dynamic_cast<CDM::EnvironmentalConditionsData*>(environmentXMLData.get());
      environment->Load(*environmentData);
      if (environment->HasAirDensity()) {
        enviroMap["AirDensity"] = environment->GetAirDensity().GetValue(biogears::MassPerVolumeUnit::kg_Per_m3);
      }
    }
  }
  return enviroMap;
}
void Scenario::create_environment(QVariantMap environmentData)
{
  biogears::SEEnvironmentalConditions* newEnvironment = new biogears::SEEnvironmentalConditions(_engine->GetSubstanceManager());
  //JS objects are returned from QML as QVariantMap<QString (key), QVariant (item)>
  //The key will be the field in the patient CDM (e.g. Name, Age, Gender...)
  //The item is a pair (value, unit), which is returned by QML as QList<QVariant>
  //We first convert the QVariantList to a QList, which allows us to index the value and unit
  //We then access values and convert them from QVariant to the appropriate type (string, double, int, etc)

  //Name
  QList<QVariant> eMetric = environmentData["Name"].toList();
  QString environmentName = eMetric[0].toString(); //Used to gen file name
  newEnvironment->SetName(environmentName.toStdString());
  environmentData.remove("Name");
  //SurroundingType
  eMetric = environmentData["SurroundingType"].toList();
  if (!eMetric[0].isNull()) {
    int type = eMetric[0].toInt();
    newEnvironment->SetSurroundingType((CDM::enumSurroundingType::value)type);
  }
  environmentData.remove("SurroundingType");
  //Air Density
  eMetric = environmentData["AirDensity"].toList();
  if (!eMetric[0].isNull()) {
    double density = eMetric[0].toDouble();
    auto& densityUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(eMetric[1].toString().toStdString());
    newEnvironment->GetAirDensity().SetValue(density, densityUnit);
  }
  environmentData.remove("AirDensity");
  //Air Velocity
  eMetric = environmentData["AirVelocity"].toList();
  if (!eMetric[0].isNull()) {
    double velocity = eMetric[0].toDouble();
    auto& velocityUnit = biogears::LengthPerTimeUnit::GetCompoundUnit(eMetric[1].toString().toStdString());
    newEnvironment->GetAirVelocity().SetValue(velocity, velocityUnit);
  }
  environmentData.remove("AirVelocity");
  //Ambient Temperature
  eMetric = environmentData["AmbientTemperature"].toList();
  if (!eMetric[0].isNull()) {
    double ambientTemp = eMetric[0].toDouble();
    auto& tempUnit = biogears::TemperatureUnit::GetCompoundUnit("deg" + eMetric[1].toString().toStdString());
    newEnvironment->GetAmbientTemperature().SetValue(ambientTemp, tempUnit);
  }
  environmentData.remove("AmbientTemperature");
  //Atmospheric Pressure
  eMetric = environmentData["AtmosphericPressure"].toList();
  if (!eMetric[0].isNull()) {
    double pressure = eMetric[0].toDouble();
    auto& pressureUnit = biogears::PressureUnit::GetCompoundUnit(eMetric[1].toString().toStdString());
    newEnvironment->GetAtmosphericPressure().SetValue(pressure, pressureUnit);
  }
  environmentData.remove("AtmosphericPressure");
  //Clothing Resistance
  eMetric = environmentData["ClothingResistance"].toList();
  if (!eMetric[0].isNull()) {
    double clothing = eMetric[0].toDouble();
    auto& resistanceUnit = biogears::HeatResistanceAreaUnit::GetCompoundUnit(eMetric[1].toString().toStdString());
    newEnvironment->GetClothingResistance().SetValue(clothing, resistanceUnit);
  }
  environmentData.remove("ClothingResistance");
  //Emissivity
  eMetric = environmentData["Emissivity"].toList();
  if (!eMetric[0].isNull()) {
    double emissivity = eMetric[0].toDouble();
    newEnvironment->GetEmissivity().SetValue(emissivity);
  }
  environmentData.remove("Emissivity");
  //Mean Radiant Temperature
  eMetric = environmentData["MeanRadiantTemperature"].toList();
  if (!eMetric[0].isNull()) {
    double meanRT = eMetric[0].toDouble();
    auto& tempUnit = biogears::TemperatureUnit::GetCompoundUnit("deg" + eMetric[1].toString().toStdString());
    newEnvironment->GetMeanRadiantTemperature().SetValue(meanRT, tempUnit);
  }
  environmentData.remove("MeanRadiantTemperature");
  //Relative Humidity
  eMetric = environmentData["RelativeHumidity"].toList();
  if (!eMetric[0].isNull()) {
    double humidity = eMetric[0].toDouble();
    newEnvironment->GetRelativeHumidity().SetValue(humidity);
  }
  environmentData.remove("RelativeHumidity");
  //Respiration Ambient Temperature
  eMetric = environmentData["RespirationAmbientTemperature"].toList();
  if (!eMetric[0].isNull()) {
    double respirationAT = eMetric[0].toDouble();
    auto& tempUnit = biogears::TemperatureUnit::GetCompoundUnit("deg" + eMetric[1].toString().toStdString());
    newEnvironment->GetRespirationAmbientTemperature().SetValue(respirationAT, tempUnit);
  }
  environmentData.remove("RespirationAmbientTemperature");
  //Ambient Gases
  biogears::SESubstance* ambientGas = nullptr;
  biogears::SESubstanceFraction* gasFraction = nullptr;
  //Oxygen
  eMetric = environmentData["Oxygen"].toList();
  if (!eMetric[0].isNull()) {
    ambientGas = &_engine->GetSubstances().GetO2();
    gasFraction = &newEnvironment->GetAmbientGas(*ambientGas); //If ambient gas is not found, SEEnvironmentConditions creates a new SubtanceFraction, adds it to ambient gases list, and returns a ptr to the fraction
    gasFraction->GetFractionAmount().SetValue(eMetric[0].toDouble());
  }
  environmentData.remove("Oxygen");
  //Nitrogen
  eMetric = environmentData["Nitrogen"].toList();
  if (!eMetric[0].isNull()) {
    if (!eMetric[0].isNull()) {
      ambientGas = &_engine->GetSubstances().GetN2();
      gasFraction = &newEnvironment->GetAmbientGas(*ambientGas); //If ambient gas is not found, SEEnvironmentConditions creates a new SubtanceFraction, adds it to ambient gases list, and returns a ptr to the fraction
      gasFraction->GetFractionAmount().SetValue(eMetric[0].toDouble());
    }
  }
  environmentData.remove("Nitrogen");
  //Carbon Dioxide
  eMetric = environmentData["CarbonDioxide"].toList();
  if (!eMetric[0].isNull()) {
    if (!eMetric[0].isNull()) {
      ambientGas = &_engine->GetSubstances().GetCO2();
      gasFraction = &newEnvironment->GetAmbientGas(*ambientGas); //If ambient gas is not found, SEEnvironmentConditions creates a new SubtanceFraction, adds it to ambient gases list, and returns a ptr to the fraction
      gasFraction->GetFractionAmount().SetValue(eMetric[0].toDouble());
    }
  }
  environmentData.remove("CarbonDioxide");
  //Carbon Monoxide
  eMetric = environmentData["CarbonMonoxide"].toList();
  if (!eMetric[0].isNull()) {
    if (!eMetric[0].isNull()) {
      ambientGas = &_engine->GetSubstances().GetCO();
      gasFraction = &newEnvironment->GetAmbientGas(*ambientGas); //If ambient gas is not found, SEEnvironmentConditions creates a new SubtanceFraction, adds it to ambient gases list, and returns a ptr to the fraction
      gasFraction->GetFractionAmount().SetValue(eMetric[0].toDouble());
    }
  }
  environmentData.remove("CarbonMonoxide");

  //Now that we have removed all used keys from environmentData, the only thing left over should be aerosols (if any)
  //Loop over aerosols and add them to environment.
  biogears::SESubstance* aerosol = nullptr;
  biogears::SESubstanceConcentration* aerosolConcentration = nullptr;
  for (auto key : environmentData.keys()) {
    aerosol = _engine->GetSubstances().GetSubstance(key.toStdString());
    aerosolConcentration = &newEnvironment->GetAmbientAerosol(*aerosol); //If ambient aerosol is not found, SEEnvironmentConditions creates a new SubtanceConcentration, adds it to ambient gases list, and returns a ptr to the concentration
    double concentration = environmentData[key].toList()[0].toDouble();
    auto& cUnit = biogears::MassPerVolumeUnit::GetCompoundUnit(environmentData[key].toList()[1].toString().toStdString());
    aerosolConcentration->GetConcentration().SetValue(concentration, cUnit);
  }

  export_environment(newEnvironment);
}

QVariantMap Scenario::edit_environment()
{
  //Create a QVariantMap with key = PropName and item = {value, unit}
  //Qml interpets QVariantMaps as Javascript objects, which we can index by prop name
  QVariantMap environmentMap;

  //Open file dialog in nutrition folder
  QString environmentFile = QFileDialog::getOpenFileName(nullptr, "Edit Environment", "./environments", "Environment (*.xml)");
  if (environmentFile.isNull()) {
    //File returns null string if user cancels without selecting a nutrition file.  Return empty map (Qml side will check for this)
    return environmentMap;
  }
  //Load file and create and SENutrition object from it using serializer
  if (!QFileInfo::exists(environmentFile)) {
    throw std::runtime_error("Unable to locate " + environmentFile.toStdString());
  }
  std::unique_ptr<CDM::ObjectData> environmentXmlData = biogears::Serializer::ReadFile(environmentFile.toStdString(), _engine->GetLogger());
  CDM::EnvironmentalConditionsData* environmentData = dynamic_cast<CDM::EnvironmentalConditionsData*>(environmentXmlData.get());
  biogears::SEEnvironmentalConditions* environment = new biogears::SEEnvironmentalConditions(_engine->GetSubstanceManager());
  environment->Load(*environmentData);

  //Each map entry is a list of two items.  environmentField[0] = value, environmentField[1] = unit
  QList<QVariant> environmentField{ "", "" };

  //Name
  environmentField[0] = QString::fromStdString(environment->GetName());
  environmentField[1] = "";
  environmentMap["Name"] = environmentField;
  //Surrounding Type
  if (environment->HasSurroundingType()) {
    int type = environment->GetSurroundingType();
    environmentField[0] = type;
    environmentField[1] = "";
    environmentMap["SurroundingType"] = environmentField;
  }
  //Air Density
  if (environment->HasAirDensity()) {
    environmentField[0] = environment->GetAirDensity(biogears::MassPerVolumeUnit::g_Per_mL);
    environmentField[1] = "g/mL";
    environmentMap["AirDensity"] = environmentField;
  }
  //Air Velocity
  if (environment->HasAirVelocity()) {
    environmentField[0] = environment->GetAirVelocity(biogears::LengthPerTimeUnit::m_Per_s);
    environmentField[1] = "m/s";
    environmentMap["AirVelocity"] = environmentField;
  }
  //Ambient Temperature
  if (environment->HasAmbientTemperature()) {
    environmentField[0] = environment->GetAmbientTemperature(biogears::TemperatureUnit::C);
    environmentField[1] = "C";
    environmentMap["AmbientTemperature"] = environmentField;
  }
  //Atmospheric Pressure
  if (environment->HasAtmosphericPressure()) {
    environmentField[0] = environment->GetAtmosphericPressure(biogears::PressureUnit::atm);
    environmentField[1] = "atm";
    environmentMap["AtmosphericPressure"] = environmentField;
  }
  //Clothing Resistance
  if (environment->HasClothingResistance()) {
    environmentField[0] = environment->GetClothingResistance(biogears::HeatResistanceAreaUnit::rsi);
    environmentField[1] = "rsi";
    environmentMap["ClothingResistance"] = environmentField;
  }
  //Emissivity
  if (environment->HasEmissivity()) {
    environmentField[0] = environment->GetEmissivity().GetValue();
    environmentField[1] = "";
    environmentMap["Emissivity"] = environmentField;
  }
  //Mean Radiant Temperature
  if (environment->HasMeanRadiantTemperature()) {
    environmentField[0] = environment->GetMeanRadiantTemperature(biogears::TemperatureUnit::C);
    environmentField[1] = "C";
    environmentMap["MeanRadiantTemperature"] = environmentField;
  }
  //Relative Humidity
  if (environment->HasRelativeHumidity()) {
    environmentField[0] = environment->GetRelativeHumidity().GetValue();
    environmentField[1] = "";
    environmentMap["RelativeHumidity"] = environmentField;
  }
  //Respiration Ambient Temperature
  if (environment->HasRespirationAmbientTemperature()) {
    environmentField[0] = environment->GetRespirationAmbientTemperature(biogears::TemperatureUnit::C);
    environmentField[1] = "C";
    environmentMap["RespirationAmbientTemperature"] = environmentField;
  }
  //Oxygen
  if (environment->HasAmbientGas(_engine->GetSubstances().GetO2())) {
    environmentField[0] = environment->GetAmbientGas(_engine->GetSubstances().GetO2()).GetFractionAmount().GetValue();
    environmentField[1] = "";
    environmentMap["Oxygen"] = environmentField;
  }
  //Carbon Dioxide
  if (environment->HasAmbientGas(_engine->GetSubstances().GetCO2())) {
    environmentField[0] = environment->GetAmbientGas(_engine->GetSubstances().GetCO2()).GetFractionAmount().GetValue();
    environmentField[1] = "";
    environmentMap["CarbonDioxide"] = environmentField;
  }
  //Nitrogen
  if (environment->HasAmbientGas(_engine->GetSubstances().GetN2())) {
    environmentField[0] = environment->GetAmbientGas(_engine->GetSubstances().GetN2()).GetFractionAmount().GetValue();
    environmentField[1] = "";
    environmentMap["Nitrogen"] = environmentField;
  }
  //Carbon Monoxide
  if (environment->HasAmbientGas(_engine->GetSubstances().GetCO())) {
    environmentField[0] = environment->GetAmbientGas(_engine->GetSubstances().GetCO()).GetFractionAmount().GetValue();
    environmentField[1] = "";
    environmentMap["CarbonMonoxide"] = environmentField;
  }

  //Loop over all aerosols and use aerosol name as key and [value, unit] pair as entry
  for (auto aerosol : environment->GetAmbientAerosols()) {
    QString subName = "Aerosol-" + QString::fromStdString(aerosol->GetSubstance().GetName());
    environmentField[0] = aerosol->GetConcentration(biogears::MassPerVolumeUnit::mg_Per_m3);
    environmentField[1] = "mg/m^3";
    environmentMap[subName] = environmentField;
  }

  return environmentMap;
}

void Scenario::export_environment()
{
  export_environment(_engine->GetEnvironment()->GetConditions());
}

void Scenario::export_environment(const biogears::SEEnvironmentalConditions* environment)
{
  std::string fileLoc = "./environments/" + environment->GetName() + ".xml";
  std::string fullPath = biogears::ResolvePath(fileLoc);
  biogears::CreateFilePath(fullPath);
  std::ofstream stream(fullPath);
  xml_schema::namespace_infomap info;
  info[""].name = "uri:/mil/tatrc/physiology/datamodel";

  std::unique_ptr<CDM::EnvironmentalConditionsData> eData(environment->Unload());
  EnvironmentalConditions(stream, *eData, info);
  stream.close();
  _engine->GetLogger()->Info("Saved environmental conditions: " + fullPath);
  return;
}

void Scenario::load_state()
{
  //Open file dialog in states
  QString stateFile = QFileDialog::getOpenFileName(nullptr, "Load state", "./states", "States (*.xml)");
  if (stateFile.isNull()) {
    return;
  } else {

    restart(stateFile);
  }
}

void Scenario::save_plots(QString location, QString name)
{
  _engine_mutex.lock();
  QFile results_file{ "BioGearsUI.csv" };
  QString destination;
  if (_scenario_name.empty()) {
    destination = QDir(location).filePath(QString("BioGears/runs/%1s-%2").arg(_engine->GetPatient().GetName_cStr()).arg(name));
  } else {
    destination = QDir(location).filePath(QString("BioGears/runs/%1-%2").arg(_scenario_name.c_str()).arg(name));
  }
  QDir destinationDir{ QUrl(destination).toLocalFile() };
  if (results_file.open(QIODevice::ReadOnly)) {
    QTextStream results_stream{ &results_file };
    QStringList headers;
    QVector<QVector<double>> tracks;

    headers = results_stream.readLine().split(',');
    tracks.resize(headers.size());

    if (!destinationDir.exists()) {
      destinationDir.mkpath(".");
    } else {
      destinationDir.removeRecursively();
      destinationDir.mkpath(".");
    }

    while (!results_stream.atEnd()) {
      auto currentLine = results_stream.readLine().split(',');
      for (auto ii = 0; ii < headers.size(); ++ii) {
        if (ii == 0) {
          tracks[ii].push_back(currentLine[ii].toDouble() / 60.0);
        } else {
          tracks[ii].push_back(currentLine[ii].toDouble());
        }
      }
    }

    for (auto ii = 1; ii < headers.size(); ++ii) {
      auto view = std::make_unique<QtCharts::QChartView>();
      view->resize(1280, 720);
      auto chart = std::make_unique<QtCharts::QChart>();
      auto series = new QtCharts::QLineSeries(chart.get());
      auto yAxis = new QtCharts::QValueAxis(chart.get());
      auto xAxis = new QtCharts::QValueAxis(chart.get());

      chart->addSeries(series);

      chart->addAxis(yAxis, Qt::AlignLeft);
      chart->addAxis(xAxis, Qt::AlignBottom);
      series->attachAxis(xAxis);
      series->attachAxis(yAxis);
      series->setPen(QPen(Qt::darkBlue, 3));

      QRegularExpression re(R"((.*)\((.*)\))");
      QRegularExpressionMatch match = re.match(headers[ii]);
      if (match.hasMatch()) {
        chart->setTitle(match.captured(1));
        yAxis->setTitleText(match.captured(2));
      } else {
        chart->setTitle(headers[ii]);
        yAxis->setTitleText("");
      }
      xAxis->setTitleText("Time(m)");
      yAxis->setGridLineVisible(false);
      xAxis->setGridLineVisible(false);

      QFont font;
      font.setPixelSize(30);
      chart->setTitleFont(font);
      font.setPixelSize(26);
      yAxis->setTitleFont(font);
      xAxis->setTitleFont(font);
      font.setPixelSize(16);
      yAxis->setLabelsFont(font);
      xAxis->setLabelsFont(font);

      chart->legend()->hide();
      for (auto jj = 0; jj < tracks[ii].size(); ++jj) {
        auto value = tracks[ii][jj];
        auto min = yAxis->min();
        auto max = yAxis->max();
        series->append(tracks[0][jj], tracks[ii][jj]);
        if (jj == 0) {
          yAxis->setMin(value * 0.9);
          yAxis->setMax(value * 1.1);
        } else {
          yAxis->setMin(std::min(min, value));
          yAxis->setMax(std::max(max, value));
        }
      }

      view->setChart(chart.get());
      chart->axes(Qt::Horizontal).back()->setMin(tracks[0].front());
      chart->axes(Qt::Horizontal).back()->setMax(tracks[0].back());

      view->setRenderHint(QPainter::Antialiasing, true);
      view->setRenderHint(QPainter::HighQualityAntialiasing, true);
      QPixmap buffer = view->grab();

      auto safe_header_name = headers[ii];
      safe_header_name.replace(QRegularExpression(R"([\\:*?\"<>|])"), QString("_"));
      safe_header_name.replace(QRegularExpression(R"([/])"), QString("_per_"));
      QFile file(QString("%1/%2.png").arg(destinationDir.absoluteFilePath(".")).arg(safe_header_name));
      file.open(QIODevice::WriteOnly);
      if (file.isOpen()) {
        buffer.save(&file, "PNG");
      }
    }
    auto results_file_name = QString("%1/%2.csv").arg(destinationDir.absoluteFilePath(".")).arg(_scenario_name.c_str()).arg(name);
    if (QFile::exists(results_file_name)) {
      QFile::remove(results_file_name);
    }
    results_file.copy(results_file_name);
  }
  _engine_mutex.unlock();
}

void Scenario::export_state(bool saveAs)
{
  QString stateFilePathQStr;
  std::string stateFilePath;
  if (saveAs) {
    stateFilePathQStr = QFileDialog::getSaveFileName(nullptr, "Save state as", "./states", "States (*.xml)");
    if (stateFilePathQStr.isNull()) {
      return;
    }
    stateFilePath = stateFilePathQStr.toStdString();
  } else {
    int simulationTime = std::round(_engine->GetSimulationTime(biogears::TimeUnit::s));
    std::string simTime = std::to_string(simulationTime);
    std::string stateName = "./states/" + _engine->GetPatient().GetName() + "@" + simTime + "s.xml";
    stateFilePath = biogears::ResolvePath(stateName);
  }

  biogears::CreateFilePath(stateFilePath);
  std::ofstream stream(stateFilePath);
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
  _engine->GetLogger()->Info("Saved state: " + stateFilePath);
  //Notify QML PatientMenu that a new state has been added to directory.
  emit newStateAdded();
}
}
#include <biogears/cdm/patient/actions/SEAcuteRespiratoryDistress.h>
#include <biogears/cdm/patient/actions/SEAcuteStress.h>
#include <biogears/cdm/patient/actions/SEAirwayObstruction.h>
#include <biogears/cdm/patient/actions/SEApnea.h>
#include <biogears/cdm/patient/actions/SEAsthmaAttack.h>
#include <biogears/cdm/patient/actions/SEBrainInjury.h>
#include <biogears/cdm/patient/actions/SEBreathHold.h>
#include <biogears/cdm/patient/actions/SEBronchoconstriction.h>
#include <biogears/cdm/patient/actions/SEBurnWound.h>
#include <biogears/cdm/patient/actions/SECardiacArrest.h>
#include <biogears/cdm/patient/actions/SEConsumeNutrients.h>
#include <biogears/cdm/patient/actions/SEExercise.h>
#include <biogears/cdm/patient/actions/SEForcedExhale.h>
#include <biogears/cdm/patient/actions/SEForcedInhale.h>
#include <biogears/cdm/patient/actions/SEHemorrhage.h>
#include <biogears/cdm/patient/actions/SEInfection.h>
#include <biogears/cdm/patient/actions/SEIntubation.h>
#include <biogears/cdm/patient/actions/SENeedleDecompression.h>
#include <biogears/cdm/patient/actions/SEPainStimulus.h>
#include <biogears/cdm/patient/actions/SESubstanceAdministration.h>
#include <biogears/cdm/patient/actions/SESubstanceBolus.h>
#include <biogears/cdm/patient/actions/SESubstanceCompoundInfusion.h>
#include <biogears/cdm/patient/actions/SESubstanceInfusion.h>
#include <biogears/cdm/patient/actions/SESubstanceOralDose.h>
#include <biogears/cdm/patient/actions/SETensionPneumothorax.h>
#include <biogears/cdm/patient/actions/SETourniquet.h>
#include <biogears/cdm/system/equipment/Anesthesia/SEAnesthesiaMachine.h>
#include <biogears/cdm/system/equipment/Anesthesia/SEAnesthesiaMachineChamber.h>
#include <biogears/cdm/system/equipment/Anesthesia/SEAnesthesiaMachineOxygenBottle.h>
#include <biogears/cdm/system/equipment/Anesthesia/actions/SEAnesthesiaMachineAction.h>
#include <biogears/cdm/system/equipment/Inhaler/actions/SEInhalerAction.h>
#include <biogears/cdm/system/equipment/Inhaler/actions/SEInhalerConfiguration.h>
namespace bgui {
//---------------------------------------------------------------------------------
// ACTION FACTORY FUNCTIONS TO BE REFACTORED TO ACTION FACTORY LATER
void Scenario::create_hemorrhage_action(QString compartment, double ml_Per_min)
{
  auto action = std::make_unique<biogears::SEHemorrhage>();
  QRegExp space("\\s"); //Hemorrhage compartments names need white space removed to process correctly ("Left Leg" --> "LeftLeg").  This assumes there is only one white space character
  action->SetCompartment(compartment.remove(space).toStdString());
  action->GetInitialRate().SetValue(ml_Per_min, biogears::VolumePerTimeUnit::mL_Per_min);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}
void Scenario::create_tourniquet_action(QString compartment, int level)
{
  auto action = std::make_unique<biogears::SETourniquet>();
  QRegExp space("\\s"); //Tourniquet compartments names need white space removed to process correctly ("Left Leg" --> "LeftLeg").  This assumes there is only one white space character
  action->SetCompartment(compartment.remove(space).toStdString());
  action->SetTourniquetLevel((CDM::enumTourniquetApplicationLevel::value)level);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}
void Scenario::create_asthma_action(double severity)
{
  auto action = std::make_unique<biogears::SEAsthmaAttack>();
  action->GetSeverity().SetValue(severity);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}
void Scenario::create_substance_infusion_action(QString substance, double concentration_ug_Per_mL, double rate_mL_Per_min)
{
  biogears::SESubstance* sub = _engine->GetSubstances().GetSubstance(substance.toStdString());
  auto action = std::make_unique<biogears::SESubstanceInfusion>(*sub);
  action->GetConcentration().SetValue(concentration_ug_Per_mL, biogears::MassPerVolumeUnit::ug_Per_mL);
  action->GetRate().SetValue(rate_mL_Per_min, biogears::VolumePerTimeUnit::mL_Per_min);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();

  //If substance is not active, queue it for addition to physiology model (must be added to model after AdvanceTime so that substance values have been initialized)
  if (!_engine->GetSubstances().IsActive(*sub)) {
    _substance_queue.push_back(sub);
  }
}
void Scenario::create_substance_bolus_action(QString substance, int route, double dose_mL, double concentration_ug_Per_mL)
{
  biogears::SESubstance* sub = _engine->GetSubstances().GetSubstance(substance.toStdString());
  auto action = std::make_unique<biogears::SESubstanceBolus>(*sub);
  action->SetAdminRoute((CDM::enumBolusAdministration::value)route);
  action->GetDose().SetValue(dose_mL, biogears::VolumeUnit::mL);
  action->GetConcentration().SetValue(concentration_ug_Per_mL, biogears::MassPerVolumeUnit::ug_Per_mL);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();

  //If substance is not active, queue it for addition to physiology model (must be added to model after AdvanceTime so that substance values have been initialized)
  if (!_engine->GetSubstances().IsActive(*sub)) {
    _substance_queue.push_back(sub);
  }
}
void Scenario::create_substance_oral_action(QString substance, int route, double dose_mg)
{
  biogears::SESubstance* sub = _engine->GetSubstances().GetSubstance(substance.toStdString());
  auto action = std::make_unique<biogears::SESubstanceOralDose>(*sub);
  action->SetAdminRoute((CDM::enumOralAdministration::value)route);
  action->GetDose().SetValue(dose_mg, biogears::MassUnit::mg);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();

  //If substance is not active, queue it for addition to physiology model (must be added to model after AdvanceTime so that substance values have been initialized)
  if (!_engine->GetSubstances().IsActive(*sub)) {
    _substance_queue.push_back(sub);
  }
}
void Scenario::create_substance_compound_infusion_action(QString compound, double bagVolume_mL, double rate_mL_Per_min)
{
  biogears::SESubstanceCompound* subCompound = _engine->GetSubstances().GetCompound(compound.toStdString());
  auto action = std::make_unique<biogears::SESubstanceCompoundInfusion>(*subCompound);
  action->GetBagVolume().SetValue(bagVolume_mL, biogears::VolumeUnit::mL);
  action->GetRate().SetValue(rate_mL_Per_min, biogears::VolumePerTimeUnit::mL_Per_min);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();

  //If compound components are not active, queue them for addition to physiology model (must be added to model after AdvanceTime so that substance values have been initialized)
  for (auto cmpt : subCompound->GetComponents()) {
    if (!_engine->GetSubstances().IsActive(cmpt.GetSubstance())) {
      _substance_queue.push_back(&cmpt.GetSubstance());
    }
  }
}
void Scenario::create_blood_transfusion_action(QString compound, double bagVolume_mL, double rate_mL_Per_min)
{
  biogears::SESubstanceCompound* bloodProduct = _engine->GetSubstances().GetCompound(compound.toStdString());
  auto action = std::make_unique<biogears::SESubstanceCompoundInfusion>(*bloodProduct);
  action->GetBagVolume().SetValue(bagVolume_mL, biogears::VolumeUnit::mL);
  action->GetRate().SetValue(rate_mL_Per_min, biogears::VolumePerTimeUnit::mL_Per_min);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}
void Scenario::create_burn_action(double tbsa)
{
  auto action = std::make_unique<biogears::SEBurnWound>();
  action->GetTotalBodySurfaceArea().SetValue(tbsa);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}
void Scenario::create_infection_action(QString location, int severity, double mic_mg_Per_L)
{
  auto action = std::make_unique<biogears::SEInfection>();
  action->SetLocation(location.toStdString());
  action->SetSeverity((CDM::enumInfectionSeverity::value)severity);
  action->GetMinimumInhibitoryConcentration().SetValue(mic_mg_Per_L, biogears::MassPerVolumeUnit::mg_Per_L);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}
void Scenario::create_exercise_action(int type, double weight_kg, double property_1, double property_2)
{
  auto action = std::make_unique<biogears::SEExercise>();

  auto generic = biogears::SEExercise::SEGeneric{};
  auto cycling = biogears::SEExercise::SECycling{};
  auto running = biogears::SEExercise::SERunning{};
  auto strength = biogears::SEExercise::SEStrengthTraining{};
  switch (type) {
  case 0: // Generic Exercise
    if (property_1 > 0) {
      generic.DesiredWorkRate.SetValue(property_1, biogears::PowerUnit::W);
    } else {
      generic.Intensity.SetValue(property_2);
    }
    action->SetGenericExercise(generic);
    break;
  case 1: // Cycling Exercise
    cycling.CadenceCycle.SetValue(property_1, biogears::FrequencyUnit::Hz);
    cycling.PowerCycle.SetValue(property_2, biogears::PowerUnit::W);
    cycling.AddedWeight.SetValue(weight_kg, biogears::MassUnit::kg);
    action->SetCyclingExercise(cycling);
    break;
  case 2: // Running Exercise
    running.SpeedRun.SetValue(property_1, biogears::LengthPerTimeUnit::m_Per_s);
    running.InclineRun.SetValue(property_2);
    running.AddedWeight.SetValue(weight_kg, biogears::MassUnit::kg);
    action->SetRunningExercise(running);
    break;
  case 3: // Strength Training Exercise
    strength.WeightStrength.SetValue(property_1, biogears::MassUnit::kg);
    strength.RepsStrength.SetValue(property_2);
    action->SetStrengthExercise(strength);
    break;
  }

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}
void Scenario::create_pain_stimulus_action(double severity, QString location)
{
  auto action = std::make_unique<biogears::SEPainStimulus>();
  action->GetSeverity().SetValue(severity);
  action->SetLocation(location.toStdString());

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}
void Scenario::create_traumatic_brain_injury_action(double severity, int type)
{
  auto action = std::make_unique<biogears::SEBrainInjury>();
  action->GetSeverity().SetValue(severity);
  action->SetType((CDM::enumBrainInjuryType::value)type);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}
void Scenario::create_tension_pneumothorax_action(double severity, int type, int side)
{
  auto action = std::make_unique<biogears::SETensionPneumothorax>();
  action->GetSeverity().SetValue(severity);
  action->SetType((CDM::enumPneumothoraxType::value)type);
  action->SetSide((CDM::enumSide::value)side);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}
void Scenario::create_needle_decompression_action(int state, int side)
{
  auto action = std::make_unique<biogears::SENeedleDecompression>();
  action->SetActive((CDM::enumOnOff::value)state);
  action->SetSide((CDM::enumSide::value)side);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}
void Scenario::create_cardiac_arrest_action(bool state)
{
  auto action = std::make_unique<biogears::SECardiacArrest>();
  action->SetActive(state);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}
void Scenario::create_inhaler_action()
{
  biogears::SESubstance* albuterol = _engine->GetSubstances().GetSubstance("Albuterol");
  //Configure inhaler
  auto action = std::make_unique<biogears::SEInhalerConfiguration>(_engine->GetSubstanceManager());
  auto& inhaler = action->GetConfiguration();
  inhaler.SetSubstance(albuterol);
  inhaler.GetMeteredDose().SetValue(90.0, biogears::MassUnit::ug);
  inhaler.GetNozzleLoss().SetValue(0.04);
  //Set up breath command sequence used in standard scenario Patients/Inhaler_OneActuation.xml
  auto breathData = std::make_unique<biogears::SEConsciousRespiration>();
  //Create first exhale command and append to breathing sequence
  CDM::ForcedExhaleData* exhale = new CDM::ForcedExhaleData();
  exhale->ExpiratoryReserveVolumeFraction(1.0);
  biogears::SEScalarTime* period = new biogears::SEScalarTime();
  period->SetValue(3.0, biogears::TimeUnit::s);
  exhale->Period(*period->Unload());
  breathData->AddForcedExhale().Load(*exhale);
  //Append use inhaler command to breathing sequence
  breathData->AddUseInhaler();
  //Create inhale command and add to breathing sequence
  CDM::ForcedInhaleData* inhale = new CDM::ForcedInhaleData();
  inhale->InspiratoryCapacityFraction(1.0);
  inhale->Period(*period->Unload());
  breathData->AddForcedInhale().Load(*inhale);
  //Create breath hold command and add to breathing sequence
  CDM::BreathHoldData* hold = new CDM::BreathHoldData();
  period->SetValue(10.0, biogears::TimeUnit::s);
  hold->Period(*period->Unload());
  breathData->AddBreathHold().Load(*hold);
  //Create exhale command and add to breathing sequence
  exhale->ExpiratoryReserveVolumeFraction(0.0); //Period stays @ 3.0 s
  breathData->AddForcedExhale().Load(*exhale);

  //Add inhaler configuration action and breath command actions
  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _action_queue.as_source().insert(std::move(breathData));
  _engine_mutex.unlock();

  //Add albuterol to active substance queue
  if (!_engine->GetSubstances().IsActive(*albuterol)) {
    _substance_queue.push_back(albuterol);
  }
}
void Scenario::create_airway_obstruction_action(double severity)
{
  auto action = std::make_unique<biogears::SEAirwayObstruction>();
  action->GetSeverity().SetValue(severity);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}
void Scenario::create_bronchoconstriction_action(double severity)
{
  auto action = std::make_unique<biogears::SEBronchoconstriction>();
  action->GetSeverity().SetValue(severity);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}
void Scenario::create_apnea_action(double severity)
{
  auto action = std::make_unique<biogears::SEApnea>();
  action->GetSeverity().SetValue(severity);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}
void Scenario::create_acute_stress_action(double severity)
{
  auto action = std::make_unique<biogears::SEAcuteStress>();
  action->GetSeverity().SetValue(severity);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();

}
void Scenario::create_ards_action(double severity)
{
  auto action = std::make_unique<biogears::SEAcuteRespiratoryDistress>();
  action->GetSeverity().SetValue(severity);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}

void Scenario::create_anesthesia_machine_action(int connection, int primaryGas, int source, double pMax_cmH2O, double peep_cmH2O, double reliefPressure_cmH2O, double inletFlow_L_Per_min, double respirationRate_Per_min, double ieRatio, double o2Fraction, double bottle1_mL, double bottle2_mL, QString leftSub, double leftSubFraction, QString rightSub, double rightSubFraction)
{
  auto action = std::make_unique<biogears::SEAnesthesiaMachineConfiguration>(_engine->GetSubstanceManager());
  auto intubationAction = std::make_unique<biogears::SEIntubation>();
  intubationAction->SetType(CDM::enumIntubationType::Tracheal);
  auto& config = action->GetConfiguration();

  config.SetConnection((CDM::enumAnesthesiaMachineConnection::value)connection);
  config.SetPrimaryGas((CDM::enumAnesthesiaMachinePrimaryGas::value)connection);
  config.SetOxygenSource((CDM::enumAnesthesiaMachineOxygenSource::value)source);
  config.GetVentilatorPressure().SetValue(pMax_cmH2O, biogears::PressureUnit::cmH2O);
  config.GetPositiveEndExpiredPressure().SetValue(peep_cmH2O, biogears::PressureUnit::cmH2O);
  config.GetReliefValvePressure().SetValue(reliefPressure_cmH2O, biogears::PressureUnit::cmH2O);
  config.GetInletFlow().SetValue(inletFlow_L_Per_min, biogears::VolumePerTimeUnit::L_Per_min);
  config.GetRespiratoryRate().SetValue(respirationRate_Per_min, biogears::FrequencyUnit::Per_min);
  config.GetInspiratoryExpiratoryRatio().SetValue(ieRatio);
  config.GetOxygenFraction().SetValue(o2Fraction);
  config.GetOxygenBottleOne().GetVolume().SetValue(bottle1_mL, biogears::VolumeUnit::L);
  config.GetOxygenBottleTwo().GetVolume().SetValue(bottle2_mL, biogears::VolumeUnit::L);
  if (!leftSub.isEmpty()) {
    config.GetLeftChamber().SetSubstance(*_engine->GetSubstanceManager().GetSubstance(leftSub.toStdString()));
    config.GetLeftChamber().GetSubstanceFraction().SetValue(leftSubFraction);
    leftSubFraction > 0.0 ? config.GetLeftChamber().SetState(CDM::enumOnOff::On) : config.GetLeftChamber().SetState(CDM::enumOnOff::Off);
  }
  if (!rightSub.isEmpty()) {
    config.GetRightChamber().SetSubstance(*_engine->GetSubstanceManager().GetSubstance(rightSub.toStdString()));
    config.GetRightChamber().GetSubstanceFraction().SetValue(rightSubFraction);
    rightSubFraction > 0.0 ? config.GetRightChamber().SetState(CDM::enumOnOff::On) : config.GetRightChamber().SetState(CDM::enumOnOff::Off);
  }

  if (config.GetConnection() == CDM::enumAnesthesiaMachineConnection::Tube) {
    _engine_mutex.lock();
    _action_queue.as_source().insert(std::move(intubationAction));
    _engine_mutex.unlock();
  }
  _action_queue.as_source().insert(std::move(action));
}

void Scenario::create_consume_meal_action(QString mealName, double carbs_g, double fat_g, double protein_g, double sodium_mg, double calcium_mg, double water_mL)
{
  auto action = std::make_unique<biogears::SEConsumeNutrients>();
  action->GetNutrition().SetName(mealName.toStdString());
  action->GetNutrition().GetCarbohydrate().SetValue(carbs_g, biogears::MassUnit::g);
  action->GetNutrition().GetFat().SetValue(fat_g, biogears::MassUnit::g);
  action->GetNutrition().GetProtein().SetValue(protein_g, biogears::MassUnit::g);
  action->GetNutrition().GetSodium().SetValue(sodium_mg, biogears::MassUnit::mg);
  action->GetNutrition().GetCalcium().SetValue(calcium_mg, biogears::MassUnit::mg);
  action->GetNutrition().GetWater().SetValue(water_mL, biogears::VolumeUnit::mL);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(action));
  _engine_mutex.unlock();
}

void Scenario::create_environment_action(QString enviroName, int surroundingType, double airDensity_kg_Per_m3, double airVelocity_m_Per_s, double ambientTemperature_C, double atmpshpericPressure_Pa, double clothingResistance_clo, double emissivity, double meanRadiantTemperature_C, double relativeHumidity, double respirationAmbientTemperature_C, double gasFractionO2, double gasFractionCO2, double gasFractionCO, double gasFractionN2, double concentrationSarin, double concentrationFireParticulate)
{
  auto environmentAction = std::make_unique<biogears::SEEnvironmentChange>(_engine->GetSubstances());
  auto& conditions = environmentAction->GetConditions();

  // Divide by spin scale from qml
  environmentAction->GetConditions().SetName(enviroName.toStdString());
  environmentAction->GetConditions().SetSurroundingType((CDM::enumSurroundingType::value)surroundingType);
  environmentAction->GetConditions().GetAirDensity().SetValue(airDensity_kg_Per_m3, biogears::MassPerVolumeUnit::kg_Per_m3);
  environmentAction->GetConditions().GetAirVelocity().SetValue(airVelocity_m_Per_s, biogears::LengthPerTimeUnit::m_Per_s);
  environmentAction->GetConditions().GetAmbientTemperature().SetValue(ambientTemperature_C, biogears::TemperatureUnit::C);
  environmentAction->GetConditions().GetAtmosphericPressure().SetValue(atmpshpericPressure_Pa, biogears::PressureUnit::Pa);
  environmentAction->GetConditions().GetClothingResistance().SetValue(clothingResistance_clo, biogears::HeatResistanceAreaUnit::clo);
  environmentAction->GetConditions().GetEmissivity().SetValue(emissivity);
  environmentAction->GetConditions().GetMeanRadiantTemperature().SetValue(meanRadiantTemperature_C, biogears::TemperatureUnit::C);
  environmentAction->GetConditions().GetRelativeHumidity().SetValue(relativeHumidity);
  environmentAction->GetConditions().GetRespirationAmbientTemperature().SetValue(respirationAmbientTemperature_C, biogears::TemperatureUnit::C);

  biogears::SESubstance* ambientGasO2 = nullptr;
  biogears::SESubstance* ambientGasCO2 = nullptr;
  biogears::SESubstance* ambientGasCO = nullptr;
  biogears::SESubstance* ambientGasN2 = nullptr;
  biogears::SESubstance* ambientAerosolSarin = nullptr;
  biogears::SESubstance* ambientAerosolForestFireParticulate = nullptr;
  ambientGasO2 = &_engine->GetSubstances().GetO2();
  ambientGasCO2 = &_engine->GetSubstances().GetCO2();
  ambientGasCO = &_engine->GetSubstances().GetCO();
  ambientGasN2 = &_engine->GetSubstances().GetN2();
  ambientAerosolSarin = _engine->GetSubstances().GetSubstance("Sarin");
  ambientAerosolForestFireParticulate = _engine->GetSubstances().GetSubstance("ForestFireParticulate");

  environmentAction->GetConditions().GetAmbientGas(*ambientGasO2).GetFractionAmount().SetValue(gasFractionO2);
  environmentAction->GetConditions().GetAmbientGas(*ambientGasCO2).GetFractionAmount().SetValue(gasFractionCO2);
  environmentAction->GetConditions().GetAmbientGas(*ambientGasCO).GetFractionAmount().SetValue(gasFractionCO);
  environmentAction->GetConditions().GetAmbientGas(*ambientGasN2).GetFractionAmount().SetValue(gasFractionN2);
  environmentAction->GetConditions().GetAmbientAerosol(*ambientAerosolSarin).GetConcentration().SetValue(concentrationSarin, biogears::MassPerVolumeUnit::mg_Per_m3);
  environmentAction->GetConditions().GetAmbientAerosol(*ambientAerosolForestFireParticulate).GetConcentration().SetValue(concentrationFireParticulate, biogears::MassPerVolumeUnit::mg_Per_m3);

  _engine_mutex.lock();
  _action_queue.as_source().insert(std::move(environmentAction));
  _engine_mutex.unlock();

}

QString Scenario::patient_name_and_time()
{
  auto simulation_time = _engine->GetSimulationTime(biogears::TimeUnit::s);
  std::string time_in_simulation = std::to_string(simulation_time);
  std::string patient_name = _engine->GetPatient().GetName_cStr();
  return QString::fromStdString(patient_name + "@" + time_in_simulation + "s.xml");
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
  std::map<std::string, int> patient_map;
  std::string contents;
  QList<QString> patient_list;
  if ((dir = opendir("states/")) != NULL) {
    while ((ent = readdir(dir)) != NULL) {
      std::string dirname = std::string(ent->d_name);
      if (dirname.find("xml") == -1) {
        continue;
      }
      //State files generated by BioGears will have '@' token. Files created by users may not.  In this case, fall
      // back to search for ".xml" substring.
      size_t splitLocation = dirname.find('@');
      if (splitLocation == std::string::npos) {
        splitLocation = dirname.find(".xml");
      }
      std::string patient_name = dirname.substr(0, splitLocation);
      auto temp_patient = patient_map.find(patient_name);
      if (temp_patient == patient_map.end()) {
        QString temp_list;
        temp_list += QString::fromStdString(patient_name);
        temp_list += ",";
        temp_list += ent->d_name;
        patient_list.push_back(temp_list);
        patient_map.insert(std::pair<std::string, int>(patient_name, patient_list.length() - 1));
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
      if (patient.toStdString() == dirname.substr(0, dirname.find('@'))) {

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

} // namespace ui

namespace bgui {
void Scenario::request_urinalysis()
{
  _assessment_queue.as_source().insert(_urinalysis.get());
}
//---------------------------------------------------------------------------------
void Scenario::request_blood_panel()
{
  _assessment_queue.as_source().insert(_blood_panel.get());
}

} //namespace bgui