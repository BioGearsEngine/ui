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
  , _logger(name.toStdString() + ".log")
  , _engine(std::make_unique<biogears::BioGearsEngine>(&_logger))
  , _action_queue()
  , _running(false)
  , _throttle(true)
{
  _engine->GetPatient().SetName(name.toStdString());
}
//-------------------------------------------------------------------------------
Scenario::~Scenario()
{
  if (_thread.joinable()) {
    _thread.join();
  }
}
//-------------------------------------------------------------------------------
void Scenario::run()
{
  if (!_thread.joinable() && !_running) {
    _running = true;
    _thread = std::thread(&Scenario::physiology_thread_main, this);
  }
}
//-----------------   --------------------------------------------------------------
void Scenario::stop()
{
}
//-------------------------------------------------------------------------------
void Scenario::join()
{
}
//-------------------------------------------------------------------------------
void Scenario::step()
{
  physiology_thread_step();
}
//-------------------------------------------------------------------------------
QString Scenario::patient_name()
{
  return _engine->GetPatient().GetName_cStr();
}
//-------------------------------------------------------------------------------
QString Scenario::environment_name()
{
  return _engine->GetEnvironment().GetName_cStr();
}
//-------------------------------------------------------------------------------
Scenario& Scenario::patinet_name(QString name)
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
  auto path = file.toStdString();
  if (!QFileInfo::exists(file)) {
    path = "states/" + path;
    if (!QFileInfo::exists("states/" + file)) {
      throw std::runtime_error("Unable to locate " + file.toStdString());
    }
  }

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

    emit patientStateChanged(get_physiology_state());
    emit patientMetricsChanged(get_physiology_metrics());
  } else {
    _engine->GetLogger()->Error("Could not load state, check the error");
  }

  return *this;
}
//-------------------------------------------------------------------------------
void Scenario::physiology_thread_main()
{
  using namespace std::chrono_literals;

  auto current_time = std::chrono::steady_clock::now();
  auto prev = current_time;
  while (_running) {
    step();
    if (_throttle) {
      while ((current_time - prev) > 1s) {
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
  if (_action_queue.size()) {
    dynamic_cast<biogears::BioGearsEngine*>(_engine.get())->ProcessAction(*_action_queue.consume());
  }
  dynamic_cast<biogears::BioGearsEngine*>(_engine.get())->AdvanceModelTime(1, biogears::TimeUnit::s);

  emit patientStateChanged(get_physiology_state());
  emit patientMetricsChanged(get_physiology_metrics());
  emit patientConditionsChanged(get_physiology_conditions());
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
  current->arterialBloodPH = (bloodChemistry.HasArterialBloodPH()) ? bloodChemistry.GetArterialBloodPH().GetValue() : 0.0;
  current->arterialBloodPHBaseline = (bloodChemistry.HasArterialBloodPHBaseline()) ? bloodChemistry.GetArterialBloodPHBaseline().GetValue() : 0.0;
  current->bloodDensity = (bloodChemistry.HasBloodDensity()) ? bloodChemistry.GetBloodDensity().GetValue( *bloodChemistry.GetBloodDensity().GetUnit() ) : 0.0;
  current->bloodSpecificHeat = (bloodChemistry.HasBloodSpecificHeat()) ? bloodChemistry.GetBloodSpecificHeat().GetValue(*bloodChemistry.GetBloodSpecificHeat().GetUnit()) : 0.0;
  current->bloodUreaNitrogenConcentration = (bloodChemistry.HasBloodUreaNitrogenConcentration()) ? bloodChemistry.GetBloodUreaNitrogenConcentration().GetValue(*bloodChemistry.GetBloodUreaNitrogenConcentration().GetUnit()) : 0.0;
  current->carbonDioxideSaturation = (bloodChemistry.HasCarbonDioxideSaturation()) ? bloodChemistry.GetCarbonDioxideSaturation().GetValue() : 0.0;
  current->carbonMonoxideSaturation = (bloodChemistry.HasCarbonMonoxideSaturation()) ? bloodChemistry.GetCarbonMonoxideSaturation().GetValue() : 0.0;
  current->hematocrit = (bloodChemistry.HasHematocrit()) ? bloodChemistry.GetHematocrit().GetValue() : 0.0;
  current->hemoglobinContent = (bloodChemistry.HasHemoglobinContent()) ? bloodChemistry.GetHemoglobinContent().GetValue(*bloodChemistry.GetHemoglobinContent().GetUnit()) : 0.0;
  current->oxygenSaturation = (bloodChemistry.HasOxygenSaturation()) ? bloodChemistry.GetOxygenSaturation().GetValue() : 0.0;
  current->phosphate = (bloodChemistry.HasPhosphate()) ? bloodChemistry.GetPhosphate().GetValue(*bloodChemistry.GetPhosphate().GetUnit()) : 0.0;
  current->plasmaVolume = (bloodChemistry.HasPlasmaVolume()) ? bloodChemistry.GetPlasmaVolume().GetValue(*bloodChemistry.GetPlasmaVolume().GetUnit()) : 0.0;
  current->pulseOximetry = (bloodChemistry.HasPulseOximetry()) ? bloodChemistry.GetPulseOximetry().GetValue() : 0.0;
  current->redBloodCellAcetylcholinesterase = (bloodChemistry.HasRedBloodCellAcetylcholinesterase()) ? bloodChemistry.GetRedBloodCellAcetylcholinesterase().GetValue(*bloodChemistry.GetRedBloodCellAcetylcholinesterase().GetUnit()) : 0.0;
  current->redBloodCellCount = (bloodChemistry.HasRedBloodCellCount()) ? bloodChemistry.GetRedBloodCellCount().GetValue(*bloodChemistry.GetRedBloodCellCount().GetUnit()) : 0.0;
  current->shuntFraction = (bloodChemistry.HasShuntFraction()) ? bloodChemistry.GetShuntFraction().GetValue() : 0.0;
  current->strongIonDifference = (bloodChemistry.HasStrongIonDifference()) ? bloodChemistry.GetStrongIonDifference().GetValue(*bloodChemistry.GetStrongIonDifference().GetUnit()) : 0.0;
  current->totalBilirubin = (bloodChemistry.HasTotalBilirubin()) ? bloodChemistry.GetTotalBilirubin().GetValue(*bloodChemistry.GetTotalBilirubin().GetUnit()) : 0.0;
  current->totalProteinConcentration = (bloodChemistry.HasTotalProteinConcentration()) ? bloodChemistry.GetTotalProteinConcentration().GetValue(*bloodChemistry.GetTotalProteinConcentration().GetUnit()) : 0.0;
  current->venousBloodPH = (bloodChemistry.HasVenousBloodPH()) ? bloodChemistry.GetVenousBloodPH().GetValue() : 0.0;
  current->volumeFractionNeutralPhospholipidInPlasma = (bloodChemistry.HasVolumeFractionNeutralPhospholipidInPlasma()) ? bloodChemistry.GetVolumeFractionNeutralPhospholipidInPlasma().GetValue() : 0.0;
  current->volumeFractionNeutralLipidInPlasma = (bloodChemistry.HasVolumeFractionNeutralLipidInPlasma()) ? bloodChemistry.GetVolumeFractionNeutralLipidInPlasma().GetValue() : 0.0;
  current->arterialCarbonDioxidePressure = (bloodChemistry.HasArterialCarbonDioxidePressure()) ? bloodChemistry.GetArterialCarbonDioxidePressure().GetValue(*bloodChemistry.GetArterialCarbonDioxidePressure().GetUnit()) : 0.0;
  current->arterialOxygenPressure = (bloodChemistry.HasArterialOxygenPressure()) ? bloodChemistry.GetArterialOxygenPressure().GetValue(*bloodChemistry.GetArterialOxygenPressure().GetUnit()) : 0.0;
  current->pulmonaryArterialCarbonDioxidePressure = (bloodChemistry.HasPulmonaryArterialCarbonDioxidePressure()) ? bloodChemistry.GetPulmonaryArterialCarbonDioxidePressure().GetValue(*bloodChemistry.GetPulmonaryArterialCarbonDioxidePressure().GetUnit()) : 0.0;
  current->pulmonaryArterialOxygenPressure = (bloodChemistry.HasPulmonaryArterialOxygenPressure()) ? bloodChemistry.GetPulmonaryArterialOxygenPressure().GetValue(*bloodChemistry.GetPulmonaryArterialOxygenPressure().GetUnit()) : 0.0;
  current->pulmonaryVenousCarbonDioxidePressure = (bloodChemistry.HasPulmonaryVenousCarbonDioxidePressure()) ? bloodChemistry.GetPulmonaryVenousCarbonDioxidePressure().GetValue(*bloodChemistry.GetPulmonaryVenousCarbonDioxidePressure().GetUnit()) : 0.0;
  current->pulmonaryVenousOxygenPressure = (bloodChemistry.HasPulmonaryVenousOxygenPressure()) ? bloodChemistry.GetPulmonaryVenousOxygenPressure().GetValue(*bloodChemistry.GetPulmonaryVenousOxygenPressure().GetUnit()) : 0.0;
  current->venousCarbonDioxidePressure = (bloodChemistry.HasVenousCarbonDioxidePressure()) ? bloodChemistry.GetVenousCarbonDioxidePressure().GetValue(*bloodChemistry.GetVenousCarbonDioxidePressure().GetUnit()) : 0.0;
  current->venousOxygenPressure = (bloodChemistry.HasVenousOxygenPressure()) ? bloodChemistry.GetVenousOxygenPressure().GetValue(*bloodChemistry.GetVenousOxygenPressure().GetUnit()) : 0.0;
  current->inflammatoryResponse = bloodChemistry.HasInflammatoryResponse();

  auto& inflamatoryResponse = bloodChemistry.GetInflammatoryResponse();
  current->inflammatoryResponseLocalPathogen = (inflamatoryResponse.HasLocalPathogen()) ? inflamatoryResponse.GetLocalPathogen().GetValue() : 0.0;
  current->inflammatoryResponseLocalMacrophage = (inflamatoryResponse.HasLocalMacrophage()) ? inflamatoryResponse.GetLocalMacrophage().GetValue() : 0.0;
  current->inflammatoryResponseLocalNeutrophil = (inflamatoryResponse.HasLocalNeutrophil()) ? inflamatoryResponse.GetLocalNeutrophil().GetValue() : 0.0;
  current->inflammatoryResponseLocalBarrier = (inflamatoryResponse.HasLocalBarrier()) ? inflamatoryResponse.GetLocalBarrier().GetValue() : 0.0;
  current->inflammatoryResponseBloodPathogen = (inflamatoryResponse.HasBloodPathogen()) ? inflamatoryResponse.GetBloodPathogen().GetValue() : 0.0;
  current->inflammatoryResponseTrauma = (inflamatoryResponse.HasTrauma()) ? inflamatoryResponse.GetTrauma().GetValue() : 0.0;
  current->inflammatoryResponseMacrophageResting = (inflamatoryResponse.HasMacrophageResting()) ? inflamatoryResponse.GetMacrophageResting().GetValue() : 0.0;
  current->inflammatoryResponseMacrophageActive = (inflamatoryResponse.HasMacrophageActive()) ? inflamatoryResponse.GetMacrophageActive().GetValue() : 0.0;
  current->inflammatoryResponseNeutrophilResting = (inflamatoryResponse.HasNeutrophilResting()) ? inflamatoryResponse.GetNeutrophilResting().GetValue() : 0.0;
  current->inflammatoryResponseNeutrophilActive = (inflamatoryResponse.HasNeutrophilActive()) ? inflamatoryResponse.GetNeutrophilActive().GetValue() : 0.0;
  current->inflammatoryResponseInducibleNOSPre = (inflamatoryResponse.HasInducibleNOSPre()) ? inflamatoryResponse.GetInducibleNOSPre().GetValue() : 0.0;
  current->inflammatoryResponseInducibleNOS = (inflamatoryResponse.HasInducibleNOS()) ? inflamatoryResponse.GetInducibleNOS().GetValue() : 0.0;
  current->inflammatoryResponseConstitutiveNOS = (inflamatoryResponse.HasConstitutiveNOS()) ? inflamatoryResponse.GetConstitutiveNOS().GetValue() : 0.0;
  current->inflammatoryResponseNitrate = (inflamatoryResponse.HasNitrate()) ? inflamatoryResponse.GetNitrate().GetValue() : 0.0;
  current->inflammatoryResponseNitricOxide = (inflamatoryResponse.HasNitricOxide()) ? inflamatoryResponse.GetNitricOxide().GetValue() : 0.0;
  current->inflammatoryResponseTumorNecrosisFactor = (inflamatoryResponse.HasTumorNecrosisFactor()) ? inflamatoryResponse.GetTumorNecrosisFactor().GetValue() : 0.0;
  current->inflammatoryResponseInterleukin6 = (inflamatoryResponse.HasInterleukin6()) ? inflamatoryResponse.GetInterleukin6().GetValue() : 0.0;
  current->inflammatoryResponseInterleukin10 = (inflamatoryResponse.HasInterleukin10()) ? inflamatoryResponse.GetInterleukin10().GetValue() : 0.0;
  current->inflammatoryResponseInterleukin12 = (inflamatoryResponse.HasInterleukin12()) ? inflamatoryResponse.GetInterleukin12().GetValue() : 0.0;
  current->inflammatoryResponseCatecholamines = (inflamatoryResponse.HasCatecholamines()) ? inflamatoryResponse.GetCatecholamines().GetValue() : 0.0;
  current->inflammatoryResponseTissueIntegrity = (inflamatoryResponse.HasTissueIntegrity()) ? inflamatoryResponse.GetTissueIntegrity().GetValue() : 0.0;

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
}

#include <biogears/cdm/patient/actions/SEHemorrhage.h>

namespace bio {
//---------------------------------------------------------------------------------
// ACTION FACTORY FUNCTIONS TO BE REFACTORED TO ACTION FACTORY LATER
void Scenario::create_hemorrhage_action(QString compartment, double ml_Per_min)
{
  auto action = std::make_unique<biogears::SEHemorrhage>();
  action->SetCompartment(compartment.toStdString());
  action->GetInitialRate().SetValue(2.0, biogears::VolumePerTimeUnit::mL_Per_min);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_asthma_action()
{
  auto action = std::make_unique<biogears::SEHemorrhage>();
  action->SetCompartment("RightLegt");
  action->GetInitialRate().SetValue(2.0, biogears::VolumePerTimeUnit::mL_Per_min);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_substance_infusion_action()
{
  auto action = std::make_unique<biogears::SEHemorrhage>();
  action->SetCompartment("RightLegt");
  action->GetInitialRate().SetValue(2.0, biogears::VolumePerTimeUnit::mL_Per_min);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_burn_action()
{
  auto action = std::make_unique<biogears::SEHemorrhage>();
  action->SetCompartment("RightLegt");
  action->GetInitialRate().SetValue(2.0, biogears::VolumePerTimeUnit::mL_Per_min);

  _action_queue.as_source().insert(std::move(action));
}
void Scenario::create_infection_action()
{
  auto action = std::make_unique<biogears::SEHemorrhage>();
  action->SetCompartment("RightLegt");
  action->GetInitialRate().SetValue(2.0, biogears::VolumePerTimeUnit::mL_Per_min);

  _action_queue.as_source().insert(std::move(action));
}
} //namspace ui
