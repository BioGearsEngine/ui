#include "Scenario.h"
#include <biogears/cdm/properties/SEScalarTime.h>
#include <biogears/engine/BioGearsPhysiologyEngine.h>

#include <biogears/cdm/patient/SEPatient.h>
#include <biogears/cdm/system/environment/SEEnvironment.h>
#include <biogears/cdm/system/environment/SEEnvironmentalConditions.h>
#include <biogears/container/concurrent_queue.tci.h>
#include <biogears/framework/scmp/scmp_channel.tci.h>

#include <chrono>
namespace bio {
Scenario::Scenario(QString name)
  : _thread()
  , _logger(name.toStdString() + ".log")
  , _engine(biogears::CreateBioGearsEngine(&_logger))
  , _action_queue()
{
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
  return _engine->GetEnvironment()->GetName_cStr();
}
//-------------------------------------------------------------------------------
QString Scenario::config_file()
{
  return "";
}
//-------------------------------------------------------------------------------
Scenario& Scenario::patinet_name(QString&)
{
  return *this;
}
//-------------------------------------------------------------------------------
Scenario& Scenario::environment_name(QString&)
{
  return *this;
}
//-------------------------------------------------------------------------------
Scenario& Scenario::config_file(QString&)
{
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
  _engine->AdvanceModelTime(1, biogears::TimeUnit::s);
}
//---------------------------------------------------------------------------------
State Scenario::get_physiology_state()
{
  return {};
}
//---------------------------------------------------------------------------------
Metrics Scenario::get_pysiology_metrics()
{
  return {};
}
//---------------------------------------------------------------------------------
Conditions Scenario::get_pysiology_conditions()
{
  return {};
}
//---------------------------------------------------------------------------------
double Scenario::get_simulation_time()
{
  return 0.;
}
//---------------------------------------------------------------------------------
} //namspace ui
