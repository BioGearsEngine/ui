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
//-------------------------------------------------------------------------------
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
  dynamic_cast<biogears::BioGearsEngine*>(_engine.get())->AdvanceModelTime(1.0, biogears::TimeUnit::s);
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
    auto bootstrap_physiology_request = [&, engine](const biogears::Tree<const char*>& tree, const auto& lambda, biogears::SESystem* system = nullptr, std::string prefix = "", biogears::Tree<const char*> const * parent = nullptr) -> void {
      std::cout << prefix << tree.value() << "\n";

      if (system) {
        using namespace std::string_literals;
        std::string key = tree.value();
        biogears::SEScalar const* scalar = system->GetScalar(key);

        if (nullptr == scalar) {
          //Handles hyp
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
auto Scenario::get_physiology_metrics() -> PatientMetrics
{
  PatientMetrics current;
  current.heart_rate_bpm = (_engine->GetCardiovascular().HasHeartRate())
    ? QString::number(_engine->GetCardiovascular().GetHeartRate().GetValue(biogears::FrequencyUnit::Per_min), 'f', 2)
    : "N/A";
  current.respiratory_rate_bpm = (_engine->GetRespiratory().HasRespirationRate())
    ? QString::number(_engine->GetRespiratory().GetRespirationRate().GetValue(biogears::FrequencyUnit::Per_min), 'f', 2)
    : "N/A";
  current.core_temperature_c = (_engine->GetEnergy().HasCoreTemperature())
    ? QString::number(_engine->GetEnergy().GetCoreTemperature(biogears::TemperatureUnit::C), 'f', 2)
    : "N/A";
  current.oxygen_saturation_pct = (_engine->GetBloodChemistry().HasOxygenSaturation())
    ? QString::number(_engine->GetBloodChemistry().GetOxygenSaturation().GetValue(), 'f', 2)
    : "N/A";
  current.systolic_blood_pressure_mmHg = (_engine->GetCardiovascular().HasSystolicArterialPressure())
    ? QString::number(_engine->GetCardiovascular().GetSystolicArterialPressure().GetValue(biogears::PressureUnit::mmHg), 'f', 2)
    : "N/A";
  current.diastolic_blood_pressure_mmHg = (_engine->GetCardiovascular().HasDiastolicArterialPressure())
    ? QString::number(_engine->GetCardiovascular().GetDiastolicArterialPressure().GetValue(biogears::PressureUnit::mmHg), 'f', 2)
    : "N/A";

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
  return 0.;
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
