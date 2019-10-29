#include "Scenario.h"

#include <exception>

#include "Gadgets.h"

//#include <biogears/version.h>
#include <biogears/cdm/properties/SEScalarTime.h>
#include <biogears/engine/BioGearsPhysiologyEngine.h>

#include <biogears/cdm/patient/SEPatient.h>
#include <biogears/cdm/system/environment/SEEnvironment.h>
#include <biogears/cdm/system/environment/SEEnvironmentalConditions.h>
#include <biogears/container/concurrent_queue.tci.h>
#include <biogears/framework/scmp/scmp_channel.tci.h>

#include <chrono>
namespace bio {
Scenario::Scenario(QObject* parent)
  : Scenario("biogears_default",parent)
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
    path = "Patients/" + path;
    if (!QFileInfo::exists("Patients/" + file)) {
      throw std::runtime_error("Unable to locate " + file.toStdString());
    }
  }
  _engine->GetPatient().Load(path);
  return *this;
}
//-------------------------------------------------------------------------------
std::function<void(void)> Scenario::step_as_func()
{
  return std::function<void(void)>([this]() {
    if (this->_running) {
      return;
    } else {
      this->physiology_thread_step();
    }
    return;
  });
}
auto Scenario::get_channel() -> Source
{
  return Channel().as_source();
}
//-------------------------------------------------------------------------------
void Scenario::physiology_thread_main()
{
  using namespace std::chrono_literals;

  auto current_time = std::chrono::steady_clock::now();
  auto prev = current_time;
  while (_running) {
    physiology_thread_main();
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
  dynamic_cast<biogears::BioGearsEngine*>(_engine.get())->AdvanceModelTime(1, biogears::TimeUnit::s);
}
//---------------------------------------------------------------------------------
auto Scenario::get_physiology_state() -> State
{
  State current;
  current.alive = _engine->GetCardiovascular().GetHeartRate().GetValue(biogears::FrequencyUnit::Per_min) > 0.0;
  current.tacycardia = false;
  return current;
}
//---------------------------------------------------------------------------------
auto Scenario::get_pysiology_metrics() -> Metrics
{
  Metrics current;
  current.heart_rate_bpm = _engine->GetCardiovascular().GetHeartRate().GetValue(biogears::FrequencyUnit::Per_min);
  current.respretory_rate_bpm = _engine->GetRespiratory().GetRespirationRate().GetValue(biogears::FrequencyUnit::Per_min);
  return current;
}
//---------------------------------------------------------------------------------
auto Scenario::get_pysiology_conditions() -> Conditions
{
  Conditions current;
  current.diabieties = _engine->GetConditions().HasDiabetesType1() | _engine->GetConditions().HasDiabetesType2();
  return current;
}
//---------------------------------------------------------------------------------
double Scenario::get_simulation_time()
{
  return 0.;
}
//---------------------------------------------------------------------------------
QString ui_version_number()
{
  return "";//__UI_VERSION_NUMBER__;
}
//---------------------------------------------------------------------------------
QString ui_version_hash()
{
  return "";//__UI_VERSION_HASH__;
}
//---------------------------------------------------------------------------------
QString ui_version_date()
{
  return "";//__UI_TAG_DATE__;
}
//---------------------------------------------------------------------------------
QString ui_build_date()
{
  return __DATE__;
}
//---------------------------------------------------------------------------------
QString lib_version_number()
{
  return "";//biogears::version_string_str();
}
//---------------------------------------------------------------------------------
QString lib_version_hash()
{
  return "";//biogears::rev_tag_str();
}
//---------------------------------------------------------------------------------
QString lib_version_date()
{
  return "";//biogears::rev_tag_date();
}
//---------------------------------------------------------------------------------
QString lib_build_date()
{
     return "";//biogears::rev_build_date();
}
//---------------------------------------------------------------------------------
QString qt_version_number()
{
  return "";
}
//---------------------------------------------------------------------------------
} //namspace ui
