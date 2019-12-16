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
//--------      -----------------------------------------------------------------------
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

  auto& cardiovascular = _engine->GetCardiovascular();
  current->arterialPressure = (cardiovascular.HasArterialPressure()) ? cardiovascular.GetArterialPressure().GetValue(*cardiovascular.GetArterialPressure().GetUnit()) : 0.0;
  current->bloodVolume = (cardiovascular.HasBloodVolume()) ? cardiovascular.GetBloodVolume().GetValue(*cardiovascular.GetBloodVolume().GetUnit()) : 0.0;
  current->cardiacIndex = (cardiovascular.HasCardiacIndex()) ? cardiovascular.GetCardiacIndex().GetValue(*cardiovascular.GetCardiacIndex().GetUnit()) : 0.0;
  current->cardiacOutput = (cardiovascular.HasCardiacOutput()) ? cardiovascular.GetCardiacOutput().GetValue(*cardiovascular.GetCardiacOutput().GetUnit()) : 0.0;
  current->centralVenousPressure = (cardiovascular.HasCentralVenousPressure()) ? cardiovascular.GetCentralVenousPressure().GetValue(*cardiovascular.GetCentralVenousPressure().GetUnit()) : 0.0;
  current->cerebralBloodFlow = (cardiovascular.HasCerebralBloodFlow()) ? cardiovascular.GetCerebralBloodFlow().GetValue(*cardiovascular.GetCerebralBloodFlow().GetUnit()) : 0.0;
  current->cerebralPerfusionPressure = (cardiovascular.HasCerebralPerfusionPressure()) ? cardiovascular.GetCerebralPerfusionPressure().GetValue(*cardiovascular.GetCerebralPerfusionPressure().GetUnit()) : 0.0;
  current->diastolicArterialPressure = (cardiovascular.HasDiastolicArterialPressure()) ? cardiovascular.GetDiastolicArterialPressure().GetValue(*cardiovascular.GetDiastolicArterialPressure().GetUnit()) : 0.0;
  current->heartEjectionFraction = (cardiovascular.HasHeartEjectionFraction()) ? cardiovascular.GetHeartEjectionFraction().GetValue() : 0.0;
  current->heartRate = (cardiovascular.HasHeartRate()) ? cardiovascular.GetHeartRate().GetValue(*cardiovascular.GetHeartRate().GetUnit()) : 0.0;
  current->heartStrokeVolume = (cardiovascular.HasHeartStrokeVolume()) ? cardiovascular.GetHeartStrokeVolume().GetValue(*cardiovascular.GetBloodVolume().GetUnit()) : 0.0;
  current->intracranialPressure = (cardiovascular.HasIntracranialPressure()) ? cardiovascular.GetIntracranialPressure().GetValue(*cardiovascular.GetIntracranialPressure().GetUnit()) : 0.0;
  current->meanArterialPressure = (cardiovascular.HasMeanArterialPressure()) ? cardiovascular.GetMeanArterialPressure().GetValue(*cardiovascular.GetMeanArterialPressure().GetUnit()) : 0.0;
  current->meanArterialCarbonDioxidePartialPressure = (cardiovascular.HasMeanArterialCarbonDioxidePartialPressure()) ? cardiovascular.GetMeanArterialCarbonDioxidePartialPressure().GetValue(*cardiovascular.GetMeanArterialCarbonDioxidePartialPressure().GetUnit()) : 0.0;
  current->meanArterialCarbonDioxidePartialPressureDelta = (cardiovascular.HasMeanArterialCarbonDioxidePartialPressureDelta()) ? cardiovascular.GetMeanArterialCarbonDioxidePartialPressureDelta().GetValue(*cardiovascular.GetMeanArterialCarbonDioxidePartialPressureDelta().GetUnit()) : 0.0;
  current->meanCentralVenousPressure = (cardiovascular.HasMeanCentralVenousPressure()) ? cardiovascular.GetMeanCentralVenousPressure().GetValue(*cardiovascular.GetMeanCentralVenousPressure().GetUnit()) : 0.0;
  current->meanSkinFlow = (cardiovascular.HasMeanSkinFlow()) ? cardiovascular.GetMeanSkinFlow().GetValue(*cardiovascular.GetMeanSkinFlow().GetUnit()) : 0.0;
  current->pulmonaryArterialPressure = (cardiovascular.HasPulmonaryArterialPressure()) ? cardiovascular.GetPulmonaryArterialPressure().GetValue(*cardiovascular.GetPulmonaryArterialPressure().GetUnit()) : 0.0;
  current->pulmonaryCapillariesWedgePressure = (cardiovascular.HasPulmonaryCapillariesWedgePressure()) ? cardiovascular.GetPulmonaryCapillariesWedgePressure().GetValue(*cardiovascular.GetPulmonaryCapillariesWedgePressure().GetUnit()) : 0.0;
  current->pulmonaryDiastolicArterialPressure = (cardiovascular.HasPulmonaryDiastolicArterialPressure()) ? cardiovascular.GetPulmonaryDiastolicArterialPressure().GetValue(*cardiovascular.GetPulmonaryDiastolicArterialPressure().GetUnit()) : 0.0;
  current->pulmonaryMeanArterialPressure = (cardiovascular.HasPulmonaryMeanArterialPressure()) ? cardiovascular.GetPulmonaryMeanArterialPressure().GetValue(*cardiovascular.GetPulmonaryMeanArterialPressure().GetUnit()) : 0.0;
  current->pulmonaryMeanCapillaryFlow = (cardiovascular.HasPulmonaryMeanArterialPressure()) ? cardiovascular.GetPulmonaryMeanArterialPressure().GetValue(*cardiovascular.GetPulmonaryMeanArterialPressure().GetUnit()) : 0.0;
  current->pulmonaryMeanShuntFlow = (cardiovascular.HasPulmonaryMeanShuntFlow()) ? cardiovascular.GetPulmonaryMeanShuntFlow().GetValue(*cardiovascular.GetPulmonaryMeanShuntFlow().GetUnit()) : 0.0;
  current->pulmonarySystolicArterialPressure = (cardiovascular.HasPulmonarySystolicArterialPressure()) ? cardiovascular.GetPulmonarySystolicArterialPressure().GetValue(*cardiovascular.GetPulmonarySystolicArterialPressure().GetUnit()) : 0.0;
  current->pulmonaryVascularResistance = (cardiovascular.HasPulmonaryVascularResistance()) ? cardiovascular.GetPulmonaryVascularResistance().GetValue(*cardiovascular.GetPulmonaryVascularResistance().GetUnit()) : 0.0;
  current->pulmonaryVascularResistanceIndex = (cardiovascular.HasPulmonaryVascularResistanceIndex()) ? cardiovascular.GetPulmonaryVascularResistanceIndex().GetValue(*cardiovascular.GetPulmonaryVascularResistanceIndex().GetUnit()) : 0.0;
  current->pulsePressure = (cardiovascular.HasPulsePressure()) ? cardiovascular.GetPulsePressure().GetValue(*cardiovascular.GetPulsePressure().GetUnit()) : 0.0;
  current->systemicVascularResistance = (cardiovascular.HasSystemicVascularResistance()) ? cardiovascular.GetSystemicVascularResistance().GetValue(*cardiovascular.GetSystemicVascularResistance().GetUnit()) : 0.0;
  current->systolicArterialPressure = (cardiovascular.HasSystolicArterialPressure()) ? cardiovascular.GetSystolicArterialPressure().GetValue(*cardiovascular.GetSystolicArterialPressure().GetUnit()) : 0.0;

  auto& drugs = _engine->GetDrugs();
  current->bronchodilationLevel = (drugs.HasBronchodilationLevel()) ? drugs.GetBronchodilationLevel().GetValue() : 0.0;
  current->heartRateChange = (drugs.HasHeartRateChange()) ? drugs.GetHeartRateChange().GetValue(*drugs.GetHeartRateChange().GetUnit()) : 0.0;
  current->meanBloodPressureChange = (drugs.HasMeanBloodPressureChange()) ? drugs.GetMeanBloodPressureChange().GetValue(*drugs.GetMeanBloodPressureChange().GetUnit()) : 0.0;
  current->meanBloodPressureChange = (drugs.HasMeanBloodPressureChange()) ? drugs.GetMeanBloodPressureChange().GetValue(*drugs.GetMeanBloodPressureChange().GetUnit()) : 0.0;
  current->neuromuscularBlockLevel = (drugs.HasNeuromuscularBlockLevel()) ? drugs.GetNeuromuscularBlockLevel().GetValue() : 0.0;
  current->pulsePressureChange = (drugs.HasPulsePressureChange()) ? drugs.GetPulsePressureChange().GetValue(*drugs.GetPulsePressureChange().GetUnit()) : 0.0;
  current->respirationRateChange = (drugs.HasRespirationRateChange()) ? drugs.GetRespirationRateChange().GetValue(*drugs.GetRespirationRateChange().GetUnit()) : 0.0;
  current->sedationLevel = (drugs.HasSedationLevel()) ? drugs.GetSedationLevel().GetValue() : 0.0;
  current->tidalVolumeChange = (drugs.HasTidalVolumeChange()) ? drugs.GetTidalVolumeChange().GetValue(*drugs.GetTidalVolumeChange().GetUnit()) : 0.0;
  current->tubularPermeabilityChange = (drugs.HasTubularPermeabilityChange()) ? drugs.GetTubularPermeabilityChange().GetValue() : 0.0;
  current->centralNervousResponse = (drugs.HasCentralNervousResponse()) ? drugs.GetCentralNervousResponse().GetValue() : 0.0;

  auto& endocrine = _engine->GetEndocrine();
  current->insulinSynthesisRate = (endocrine.HasInsulinSynthesisRate()) ? endocrine.GetInsulinSynthesisRate().GetValue(*endocrine.GetInsulinSynthesisRate().GetUnit()) : 0.0;
  current->glucagonSynthesisRate = (endocrine.HasGlucagonSynthesisRate()) ? endocrine.GetGlucagonSynthesisRate().GetValue(*endocrine.GetGlucagonSynthesisRate().GetUnit()) : 0.0;

  auto& energy = _engine->GetEnergy();
  current->achievedExerciseLevel = (energy.HasAchievedExerciseLevel()) ? energy.GetAchievedExerciseLevel().GetValue() : 0.0;
  current->chlorideLostToSweat = (energy.HasChlorideLostToSweat()) ? energy.GetChlorideLostToSweat().GetValue(*energy.GetChlorideLostToSweat().GetUnit()) : 0.0;
  current->coreTemperature = (energy.HasCoreTemperature()) ? energy.GetCoreTemperature().GetValue(*energy.GetCoreTemperature().GetUnit()) : 0.0;
  current->creatinineProductionRate = (energy.HasCreatinineProductionRate()) ? energy.GetCreatinineProductionRate().GetValue(*energy.GetCreatinineProductionRate().GetUnit()) : 0.0;
  current->exerciseMeanArterialPressureDelta = (energy.HasExerciseMeanArterialPressureDelta()) ? energy.GetExerciseMeanArterialPressureDelta().GetValue(*energy.GetExerciseMeanArterialPressureDelta().GetUnit()) : 0.0;
  current->fatigueLevel = (energy.HasFatigueLevel()) ? energy.GetFatigueLevel().GetValue() : 0.0;
  current->lactateProductionRate = (energy.HasLactateProductionRate()) ? energy.GetLactateProductionRate().GetValue(*energy.GetLactateProductionRate().GetUnit()) : 0.0;
  current->potassiumLostToSweat = (energy.HasPotassiumLostToSweat()) ? energy.GetPotassiumLostToSweat().GetValue(*energy.GetPotassiumLostToSweat().GetUnit()) : 0.0;
  current->skinTemperature = (energy.HasSkinTemperature()) ? energy.GetSkinTemperature().GetValue(*energy.GetSkinTemperature().GetUnit()) : 0.0;
  current->sodiumLostToSweat = (energy.HasSodiumLostToSweat()) ? energy.GetSodiumLostToSweat().GetValue(*energy.GetSodiumLostToSweat().GetUnit()) : 0.0;
  current->sweatRate = (energy.HasSweatRate()) ? energy.GetSweatRate().GetValue(*energy.GetSweatRate().GetUnit()) : 0.0;
  current->totalMetabolicRate = (energy.HasTotalMetabolicRate()) ? energy.GetTotalWorkRateLevel().GetValue() : 0.0; 
  current->totalWorkRateLevel = (energy.HasTotalWorkRateLevel()) ? energy.GetTotalWorkRateLevel().GetValue() : 0.0;

  auto& gastrointestinal = _engine->GetGastrointestinal();
  current->chymeAbsorptionRate = (gastrointestinal.HasChymeAbsorptionRate()) ? gastrointestinal.GetChymeAbsorptionRate().GetValue(*gastrointestinal.GetChymeAbsorptionRate().GetUnit()) : 0.0;
  current->stomachContents_calcium = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasCalcium()) ? gastrointestinal.GetStomachContents().GetCalcium().GetValue(*gastrointestinal.GetStomachContents().GetCalcium().GetUnit()) : 0.0;
  current->stomachContents_carbohydrates = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasCarbohydrate()) ? gastrointestinal.GetStomachContents().GetCarbohydrate().GetValue(*gastrointestinal.GetStomachContents().GetCarbohydrate().GetUnit()) : 0.0;
  current->stomachContents_carbohydrateDigationRate = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasCarbohydrateDigestionRate()) ? gastrointestinal.GetStomachContents().GetCarbohydrateDigestionRate().GetValue(*gastrointestinal.GetStomachContents().GetCarbohydrateDigestionRate().GetUnit()) : 0.0;
  current->stomachContents_fat = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasFat()) ? gastrointestinal.GetStomachContents().GetFat().GetValue(*gastrointestinal.GetStomachContents().GetFat().GetUnit()) : 0.0;
  current->stomachContents_fatDigtationRate = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasFatDigestionRate()) ? gastrointestinal.GetStomachContents().GetFatDigestionRate().GetValue(*gastrointestinal.GetStomachContents().GetFatDigestionRate().GetUnit()) : 0.0;
  current->stomachContents_protien = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasProtein()) ? gastrointestinal.GetStomachContents().GetProtein().GetValue(*gastrointestinal.GetStomachContents().GetProtein().GetUnit()) : 0.0;
  current->stomachContents_protienDigtationRate = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasProteinDigestionRate()) ? gastrointestinal.GetStomachContents().GetProteinDigestionRate().GetValue(*gastrointestinal.GetStomachContents().GetProteinDigestionRate().GetUnit()) : 0.0;
  current->stomachContents_sodium = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasSodium()) ? gastrointestinal.GetStomachContents().GetSodium().GetValue(*gastrointestinal.GetStomachContents().GetSodium().GetUnit()) : 0.0;
  current->stomachContents_water = (gastrointestinal.HasStomachContents() && gastrointestinal.GetStomachContents().HasWater()) ? gastrointestinal.GetStomachContents().GetWater().GetValue(*gastrointestinal.GetStomachContents().GetWater().GetUnit()) : 0.0;

  auto& hepatic = _engine->GetHepatic();
  current->hepaticGluconeogenesisRate = (hepatic.HasHepaticGluconeogenesisRate()) ? hepatic.GetHepaticGluconeogenesisRate().GetValue(*hepatic.GetHepaticGluconeogenesisRate().GetUnit()) : 0.0;
  current->ketoneproductionRate = (hepatic.HasKetoneProductionRate()) ? hepatic.GetKetoneProductionRate().GetValue(*hepatic.GetKetoneProductionRate().GetUnit()) : 0.0;

  auto& nervous = _engine->GetNervous();
  current->baroreceptorHeartRateScale = (nervous.HasBaroreceptorHeartRateScale()) ? nervous.GetBaroreceptorHeartRateScale().GetValue() : 0.0;
  current->baroreceptorHeartElastanceScale = (nervous.HasBaroreceptorHeartElastanceScale()) ? nervous.GetBaroreceptorHeartElastanceScale().GetValue() : 0.0;
  current->baroreceptorResistanceScale = (nervous.HasBaroreceptorResistanceScale()) ? nervous.GetBaroreceptorResistanceScale().GetValue() : 0.0;
  current->baroreceptorComplianceScale = (nervous.HasBaroreceptorComplianceScale()) ? nervous.GetBaroreceptorComplianceScale().GetValue() : 0.0;
  current->chemoreceptorHeartRateScale = (nervous.HasChemoreceptorHeartRateScale()) ? nervous.GetChemoreceptorHeartRateScale().GetValue() : 0.0;
  current->chemoreceptorHeartElastanceScale = (nervous.HasChemoreceptorHeartElastanceScale()) ? nervous.GetChemoreceptorHeartElastanceScale().GetValue() : 0.0;
  current->painVisualAnalogueScale = (nervous.HasPainVisualAnalogueScale()) ? nervous.GetPainVisualAnalogueScale().GetValue() : 0.0;

  //TODO: Implement Pupillary Response  ReactivityModifier  ShapeModifier  SizeModifier;
  current->leftEyePupillaryResponse =  0.0;
  current->rightEyePupillaryResponse = 0.0;

  //Renal
  auto& renal = _engine->GetRenal();
  current->glomerularFiltrationRate = (renal.HasGlomerularFiltrationRate()) ? renal.GetGlomerularFiltrationRate().GetValue(*renal.GetGlomerularFiltrationRate().GetUnit()) : 0.0;;
  current->filtrationFraction = (renal.HasFiltrationFraction()) ? renal.GetFiltrationFraction().GetValue() : 0.0;;
  current->leftAfferentArterioleResistance = (renal.HasLeftAfferentArterioleResistance()) ? renal.GetLeftAfferentArterioleResistance().GetValue(*renal.GetLeftAfferentArterioleResistance().GetUnit()) : 0.0;;
  current->leftBowmansCapsulesHydrostaticPressure = (renal.HasLeftBowmansCapsulesHydrostaticPressure()) ? renal.GetLeftBowmansCapsulesHydrostaticPressure().GetValue(*renal.GetLeftBowmansCapsulesHydrostaticPressure().GetUnit()) : 0.0;;
  current->leftBowmansCapsulesOsmoticPressure = (renal.HasLeftBowmansCapsulesOsmoticPressure()) ? renal.GetLeftBowmansCapsulesOsmoticPressure().GetValue(*renal.GetLeftBowmansCapsulesOsmoticPressure().GetUnit()) : 0.0;;
  current->leftEfferentArterioleResistance = (renal.HasLeftEfferentArterioleResistance()) ? renal.GetLeftEfferentArterioleResistance().GetValue(*renal.GetLeftEfferentArterioleResistance().GetUnit()) : 0.0;;
  current->leftGlomerularCapillariesHydrostaticPressure = (renal.HasLeftGlomerularCapillariesHydrostaticPressure()) ? renal.GetLeftGlomerularCapillariesHydrostaticPressure().GetValue(*renal.GetLeftGlomerularCapillariesHydrostaticPressure().GetUnit()) : 0.0;;
  current->leftGlomerularCapillariesOsmoticPressure = (renal.HasLeftGlomerularCapillariesOsmoticPressure()) ? renal.GetLeftGlomerularCapillariesOsmoticPressure().GetValue(*renal.GetLeftGlomerularCapillariesOsmoticPressure().GetUnit()) : 0.0;;
  current->leftGlomerularFiltrationCoefficient = (renal.HasLeftGlomerularFiltrationCoefficient()) ? renal.GetLeftGlomerularFiltrationCoefficient().GetValue(*renal.GetLeftGlomerularFiltrationCoefficient().GetUnit()) : 0.0;;
  current->leftGlomerularFiltrationRate = (renal.HasLeftGlomerularFiltrationRate()) ? renal.GetLeftGlomerularFiltrationRate().GetValue(*renal.GetLeftGlomerularFiltrationRate().GetUnit()) : 0.0;;
  current->leftGlomerularFiltrationSurfaceArea = (renal.HasLeftGlomerularFiltrationSurfaceArea()) ? renal.GetLeftGlomerularFiltrationSurfaceArea().GetValue(*renal.GetLeftGlomerularFiltrationSurfaceArea().GetUnit()) : 0.0;;
  current->leftGlomerularFluidPermeability = (renal.HasLeftGlomerularFluidPermeability()) ? renal.GetLeftGlomerularFluidPermeability().GetValue(*renal.GetLeftGlomerularFluidPermeability().GetUnit()) : 0.0;;
  current->leftFiltrationFraction = (renal.HasLeftFiltrationFraction()) ? renal.GetLeftFiltrationFraction().GetValue() : 0.0;;
  current->leftNetFiltrationPressure = (renal.HasLeftNetFiltrationPressure()) ? renal.GetLeftNetFiltrationPressure().GetValue(*renal.GetLeftNetFiltrationPressure().GetUnit()) : 0.0;;
  current->leftNetReabsorptionPressure = (renal.HasLeftNetReabsorptionPressure()) ? renal.GetLeftNetReabsorptionPressure().GetValue(*renal.GetLeftNetReabsorptionPressure().GetUnit()) : 0.0;;
  current->leftPeritubularCapillariesHydrostaticPressure = (renal.HasLeftPeritubularCapillariesHydrostaticPressure()) ? renal.GetLeftPeritubularCapillariesHydrostaticPressure().GetValue(*renal.GetLeftPeritubularCapillariesHydrostaticPressure().GetUnit()) : 0.0;;
  current->leftPeritubularCapillariesOsmoticPressure = (renal.HasLeftPeritubularCapillariesOsmoticPressure()) ? renal.GetLeftPeritubularCapillariesOsmoticPressure().GetValue(*renal.GetLeftPeritubularCapillariesOsmoticPressure().GetUnit()) : 0.0;;
  current->leftReabsorptionFiltrationCoefficient = (renal.HasLeftReabsorptionFiltrationCoefficient()) ? renal.GetLeftReabsorptionFiltrationCoefficient().GetValue(*renal.GetLeftReabsorptionFiltrationCoefficient().GetUnit()) : 0.0;;
  current->leftReabsorptionRate = (renal.HasLeftReabsorptionRate()) ? renal.GetLeftReabsorptionRate().GetValue(*renal.GetLeftReabsorptionRate().GetUnit()) : 0.0;;
  current->leftTubularReabsorptionFiltrationSurfaceArea = (renal.HasLeftTubularReabsorptionFiltrationSurfaceArea()) ? renal.GetLeftTubularReabsorptionFiltrationSurfaceArea().GetValue(*renal.GetLeftTubularReabsorptionFiltrationSurfaceArea().GetUnit()) : 0.0;;
  current->leftTubularReabsorptionFluidPermeability = (renal.HasLeftTubularReabsorptionFluidPermeability()) ? renal.GetLeftTubularReabsorptionFluidPermeability().GetValue(*renal.GetLeftTubularReabsorptionFluidPermeability().GetUnit()) : 0.0;;
  current->leftTubularHydrostaticPressure = (renal.HasLeftTubularHydrostaticPressure()) ? renal.GetLeftTubularHydrostaticPressure().GetValue(*renal.GetLeftTubularHydrostaticPressure().GetUnit()) : 0.0;;
  current->leftTubularOsmoticPressure = (renal.HasLeftTubularOsmoticPressure()) ? renal.GetLeftTubularOsmoticPressure().GetValue(*renal.GetLeftTubularOsmoticPressure().GetUnit()) : 0.0;;
  current->renalBloodFlow = (renal.HasRenalBloodFlow()) ? renal.GetRenalBloodFlow().GetValue(*renal.GetRenalBloodFlow().GetUnit()) : 0.0;;
  current->renalPlasmaFlow = (renal.HasRenalPlasmaFlow()) ? renal.GetRenalPlasmaFlow().GetValue(*renal.GetRenalPlasmaFlow().GetUnit()) : 0.0;;
  current->renalVascularResistance = (renal.HasRenalVascularResistance()) ? renal.GetRenalVascularResistance().GetValue(*renal.GetRenalVascularResistance().GetUnit()) : 0.0;;
  current->rightAfferentArterioleResistance = (renal.HasRightAfferentArterioleResistance()) ? renal.GetRightAfferentArterioleResistance().GetValue(*renal.GetRightAfferentArterioleResistance().GetUnit()) : 0.0;;
  current->rightBowmansCapsulesHydrostaticPressure = (renal.HasRightBowmansCapsulesHydrostaticPressure()) ? renal.GetRightBowmansCapsulesHydrostaticPressure().GetValue(*renal.GetRightBowmansCapsulesHydrostaticPressure().GetUnit()) : 0.0;;
  current->rightBowmansCapsulesOsmoticPressure = (renal.HasRightBowmansCapsulesOsmoticPressure()) ? renal.GetRightBowmansCapsulesOsmoticPressure().GetValue(*renal.GetRightBowmansCapsulesOsmoticPressure().GetUnit()) : 0.0;;
  current->rightEfferentArterioleResistance = (renal.HasRightEfferentArterioleResistance()) ? renal.GetRightEfferentArterioleResistance().GetValue(*renal.GetRightEfferentArterioleResistance().GetUnit()) : 0.0;;
  current->rightGlomerularCapillariesHydrostaticPressure = (renal.HasRightGlomerularCapillariesHydrostaticPressure()) ? renal.GetRightGlomerularCapillariesHydrostaticPressure().GetValue(*renal.GetRightGlomerularCapillariesHydrostaticPressure().GetUnit()) : 0.0;;
  current->rightGlomerularCapillariesOsmoticPressure = (renal.HasRightGlomerularCapillariesOsmoticPressure()) ? renal.GetRightGlomerularCapillariesOsmoticPressure().GetValue(*renal.GetRightGlomerularCapillariesOsmoticPressure().GetUnit()) : 0.0;;
  current->rightGlomerularFiltrationCoefficient = (renal.HasRightGlomerularFiltrationCoefficient()) ? renal.GetRightGlomerularFiltrationCoefficient().GetValue(*renal.GetRightGlomerularFiltrationCoefficient().GetUnit()) : 0.0;;
  current->rightGlomerularFiltrationRate = (renal.HasRightGlomerularFiltrationRate()) ? renal.GetRightGlomerularFiltrationRate().GetValue(*renal.GetRightGlomerularFiltrationRate().GetUnit()) : 0.0;;
  current->rightGlomerularFiltrationSurfaceArea = (renal.HasRightGlomerularFiltrationSurfaceArea()) ? renal.GetRightGlomerularFiltrationSurfaceArea().GetValue(*renal.GetRightGlomerularFiltrationSurfaceArea().GetUnit()) : 0.0;;
  current->rightGlomerularFluidPermeability = (renal.HasRightGlomerularFluidPermeability()) ? renal.GetRightGlomerularFluidPermeability().GetValue(*renal.GetRightGlomerularFluidPermeability().GetUnit()) : 0.0;;
  current->rightFiltrationFraction = (renal.HasRightFiltrationFraction()) ? renal.GetRightFiltrationFraction().GetValue() : 0.0;;
  current->rightNetFiltrationPressure = (renal.HasRightNetFiltrationPressure()) ? renal.GetRightNetFiltrationPressure().GetValue(*renal.GetRightNetFiltrationPressure().GetUnit()) : 0.0;;
  current->rightNetReabsorptionPressure = (renal.HasRightNetReabsorptionPressure()) ? renal.GetRightNetReabsorptionPressure().GetValue(*renal.GetRightNetReabsorptionPressure().GetUnit()) : 0.0;;
  current->rightPeritubularCapillariesHydrostaticPressure = (renal.HasRightPeritubularCapillariesHydrostaticPressure()) ? renal.GetRightPeritubularCapillariesHydrostaticPressure().GetValue(*renal.GetRightPeritubularCapillariesHydrostaticPressure().GetUnit()) : 0.0;;
  current->rightPeritubularCapillariesOsmoticPressure = (renal.HasRightPeritubularCapillariesOsmoticPressure()) ? renal.GetRightPeritubularCapillariesOsmoticPressure().GetValue(*renal.GetRightPeritubularCapillariesOsmoticPressure().GetUnit()) : 0.0;;
  current->rightReabsorptionFiltrationCoefficient = (renal.HasRightReabsorptionFiltrationCoefficient()) ? renal.GetRightReabsorptionFiltrationCoefficient().GetValue(*renal.GetRightReabsorptionFiltrationCoefficient().GetUnit()) : 0.0;;
  current->rightReabsorptionRate = (renal.HasRightReabsorptionRate()) ? renal.GetRightReabsorptionRate().GetValue(*renal.GetRightReabsorptionRate().GetUnit()) : 0.0;;
  current->rightTubularReabsorptionFiltrationSurfaceArea = (renal.HasRightTubularReabsorptionFiltrationSurfaceArea()) ? renal.GetRightTubularReabsorptionFiltrationSurfaceArea().GetValue(*renal.GetRightTubularReabsorptionFiltrationSurfaceArea().GetUnit()) : 0.0;;
  current->rightTubularReabsorptionFluidPermeability = (renal.HasRightTubularReabsorptionFluidPermeability()) ? renal.GetRightTubularReabsorptionFluidPermeability().GetValue(*renal.GetRightTubularReabsorptionFluidPermeability().GetUnit()) : 0.0;;
  current->rightTubularHydrostaticPressure = (renal.HasRightTubularHydrostaticPressure()) ? renal.GetRightTubularHydrostaticPressure().GetValue(*renal.GetRightTubularHydrostaticPressure().GetUnit()) : 0.0;;
  current->rightTubularOsmoticPressure = (renal.HasRightTubularOsmoticPressure()) ? renal.GetRightTubularOsmoticPressure().GetValue(*renal.GetRightTubularOsmoticPressure().GetUnit()) : 0.0;;
  current->urinationRate = (renal.HasUrinationRate()) ? renal.GetUrinationRate().GetValue(*renal.GetUrinationRate().GetUnit()) : 0.0;;
  current->urineOsmolality = (renal.HasUrineOsmolality()) ? renal.GetUrineOsmolality().GetValue(*renal.GetUrineOsmolality().GetUnit()) : 0.0;;
  current->urineOsmolarity = (renal.HasUrineOsmolarity()) ? renal.GetUrineOsmolarity().GetValue(*renal.GetUrineOsmolarity().GetUnit()) : 0.0;;
  current->urineProductionRate = (renal.HasUrineProductionRate()) ? renal.GetUrineProductionRate().GetValue(*renal.GetUrineProductionRate().GetUnit()) : 0.0;;
  current->meanUrineOutput = (renal.HasMeanUrineOutput()) ? renal.GetMeanUrineOutput().GetValue(*renal.GetMeanUrineOutput().GetUnit()) : 0.0;;
  current->urineSpecificGravity = (renal.HasUrineSpecificGravity()) ? renal.GetUrineSpecificGravity().GetValue() : 0.0;;
  current->urineVolume = (renal.HasUrineVolume()) ? renal.GetUrineVolume().GetValue(*renal.GetUrineVolume().GetUnit()) : 0.0;;
  current->urineUreaNitrogenConcentration = (renal.HasUrineUreaNitrogenConcentration()) ? renal.GetUrineUreaNitrogenConcentration().GetValue(*renal.GetUrineUreaNitrogenConcentration().GetUnit()) : 0.0;;

  //Respiratory
  auto& respiratory = _engine->GetRespiratory();
  current->alveolarArterialGradient = (respiratory.HasAlveolarArterialGradient()) ? respiratory.GetAlveolarArterialGradient().GetValue(*respiratory.GetAlveolarArterialGradient().GetUnit()) : 0.0;
  current->carricoIndex = (respiratory.HasCarricoIndex()) ? respiratory.GetCarricoIndex().GetValue(*respiratory.GetCarricoIndex().GetUnit()) : 0.0;
  current->endTidalCarbonDioxideFraction = (respiratory.HasEndTidalCarbonDioxideFraction()) ? respiratory.GetEndTidalCarbonDioxideFraction().GetValue() : 0.0;
  current->endTidalCarbonDioxidePressure = (respiratory.HasEndTidalCarbonDioxidePressure()) ? respiratory.GetEndTidalCarbonDioxidePressure().GetValue(*respiratory.GetEndTidalCarbonDioxidePressure().GetUnit()) : 0.0;
  current->expiratoryFlow = (respiratory.HasExpiratoryFlow()) ? respiratory.GetExpiratoryFlow().GetValue(*respiratory.GetExpiratoryFlow().GetUnit()) : 0.0;
  current->inspiratoryExpiratoryRatio = (respiratory.HasInspiratoryExpiratoryRatio()) ? respiratory.GetInspiratoryExpiratoryRatio().GetValue() : 0.0;
  current->inspiratoryFlow = (respiratory.HasInspiratoryFlow()) ? respiratory.GetInspiratoryFlow().GetValue(*respiratory.GetInspiratoryFlow().GetUnit()) : 0.0;
  current->pulmonaryCompliance = (respiratory.HasPulmonaryCompliance()) ? respiratory.GetPulmonaryCompliance().GetValue(*respiratory.GetPulmonaryCompliance().GetUnit()) : 0.0;
  current->pulmonaryResistance = (respiratory.HasPulmonaryResistance()) ? respiratory.GetPulmonaryResistance().GetValue(*respiratory.GetPulmonaryResistance().GetUnit()) : 0.0;
  current->respirationDriverPressure = (respiratory.HasRespirationDriverPressure()) ? respiratory.GetRespirationDriverPressure().GetValue(*respiratory.GetRespirationDriverPressure().GetUnit()) : 0.0;
  current->respirationMusclePressure = (respiratory.HasRespirationMusclePressure()) ? respiratory.GetRespirationMusclePressure().GetValue(*respiratory.GetRespirationMusclePressure().GetUnit()) : 0.0;
  current->respirationRate = (respiratory.HasRespirationRate()) ? respiratory.GetRespirationRate().GetValue(*respiratory.GetRespirationRate().GetUnit()) : 0.0;
  current->specificVentilation = (respiratory.HasSpecificVentilation()) ? respiratory.GetSpecificVentilation().GetValue() : 0.0;
  current->targetPulmonaryVentilation = (respiratory.HasTargetPulmonaryVentilation()) ? respiratory.GetTargetPulmonaryVentilation().GetValue(*respiratory.GetTargetPulmonaryVentilation().GetUnit()) : 0.0;
  current->tidalVolume = (respiratory.HasTidalVolume()) ? respiratory.GetTidalVolume().GetValue(*respiratory.GetTidalVolume().GetUnit()) : 0.0;
  current->totalAlveolarVentilation = (respiratory.HasTotalAlveolarVentilation()) ? respiratory.GetTotalAlveolarVentilation().GetValue(*respiratory.GetTotalAlveolarVentilation().GetUnit()) : 0.0;
  current->totalDeadSpaceVentilation = (respiratory.HasTotalDeadSpaceVentilation()) ? respiratory.GetTotalDeadSpaceVentilation().GetValue(*respiratory.GetTotalDeadSpaceVentilation().GetUnit()) : 0.0;
  current->totalLungVolume = (respiratory.HasTotalLungVolume()) ? respiratory.GetTotalLungVolume().GetValue(*respiratory.GetTotalLungVolume().GetUnit()) : 0.0;
  current->totalPulmonaryVentilation = (respiratory.HasTotalPulmonaryVentilation()) ? respiratory.GetTotalPulmonaryVentilation().GetValue(*respiratory.GetTotalPulmonaryVentilation().GetUnit()) : 0.0;
  current->transpulmonaryPressure = (respiratory.HasTranspulmonaryPressure()) ? respiratory.GetTranspulmonaryPressure().GetValue(*respiratory.GetTranspulmonaryPressure().GetUnit()) : 0.0;

  //Tissue
  auto& tissue = _engine->GetTissue();
  current->carbonDioxideProductionRate = (tissue.HasCarbonDioxideProductionRate()) ? tissue.GetCarbonDioxideProductionRate().GetValue(*tissue.GetCarbonDioxideProductionRate().GetUnit()) : 0.0;
  current->dehydrationFraction = (tissue.HasDehydrationFraction()) ? tissue.GetDehydrationFraction().GetValue() : 0.0;
  current->extracellularFluidVolume = (tissue.HasExtracellularFluidVolume()) ? tissue.GetExtracellularFluidVolume().GetValue(*tissue.GetExtracellularFluidVolume().GetUnit()) : 0.0;
  current->extravascularFluidVolume = (tissue.HasExtravascularFluidVolume()) ? tissue.GetExtravascularFluidVolume().GetValue(*tissue.GetExtravascularFluidVolume().GetUnit()) : 0.0;
  current->intracellularFluidPH = (tissue.HasIntracellularFluidPH()) ? tissue.GetIntracellularFluidPH().GetValue() : 0.0;
  current->intracellularFluidVolume = (tissue.HasIntracellularFluidVolume()) ? tissue.GetIntracellularFluidVolume().GetValue(*tissue.GetIntracellularFluidVolume().GetUnit()) : 0.0;
  current->totalBodyFluidVolume = (tissue.HasTotalBodyFluidVolume()) ? tissue.GetTotalBodyFluidVolume().GetValue(*tissue.GetTotalBodyFluidVolume().GetUnit()) : 0.0;
  current->oxygenConsumptionRate = (tissue.HasOxygenConsumptionRate()) ? tissue.GetOxygenConsumptionRate().GetValue(*tissue.GetOxygenConsumptionRate().GetUnit()) : 0.0;
  current->respiratoryExchangeRatio = (tissue.HasRespiratoryExchangeRatio()) ? tissue.GetRespiratoryExchangeRatio().GetValue() : 0.0;
  current->liverInsulinSetPoint = (tissue.HasLiverInsulinSetPoint()) ? tissue.GetLiverInsulinSetPoint().GetValue(*tissue.GetLiverInsulinSetPoint().GetUnit()) : 0.0;
  current->liverGlucagonSetPoint = (tissue.HasLiverGlucagonSetPoint()) ? tissue.GetLiverGlucagonSetPoint().GetValue(*tissue.GetLiverGlucagonSetPoint().GetUnit()) : 0.0;
  current->muscleInsulinSetPoint = (tissue.HasMuscleInsulinSetPoint()) ? tissue.GetMuscleInsulinSetPoint().GetValue(*tissue.GetMuscleInsulinSetPoint().GetUnit()) : 0.0;
  current->muscleGlucagonSetPoint = (tissue.HasMuscleGlucagonSetPoint()) ? tissue.GetMuscleGlucagonSetPoint().GetValue(*tissue.GetMuscleGlucagonSetPoint().GetUnit()) : 0.0;
  current->fatInsulinSetPoint = (tissue.HasFatInsulinSetPoint()) ? tissue.GetFatInsulinSetPoint().GetValue(*tissue.GetFatInsulinSetPoint().GetUnit()) : 0.0;
  current->fatGlucagonSetPoint = (tissue.HasFatGlucagonSetPoint()) ? tissue.GetFatGlucagonSetPoint().GetValue(*tissue.GetFatGlucagonSetPoint().GetUnit()) : 0.0;
  current->liverGlycogen = (tissue.HasLiverGlycogen()) ? tissue.GetLiverGlycogen().GetValue(*tissue.GetLiverGlycogen().GetUnit()) : 0.0;
  current->muscleGlycogen = (tissue.HasMuscleGlycogen()) ? tissue.GetMuscleGlycogen().GetValue(*tissue.GetMuscleGlycogen().GetUnit()) : 0.0;
  current->storedProtein = (tissue.HasStoredProtein()) ? tissue.GetStoredProtein().GetValue(*tissue.GetStoredProtein().GetUnit()) : 0.0;
  current->storedFat = (tissue.HasStoredFat()) ? tissue.GetStoredFat().GetValue(*tissue.GetStoredFat().GetUnit()) : 0.0;

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
