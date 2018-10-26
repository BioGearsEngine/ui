#include "PhysiologyThread.h"

//Standard Includes
#include <chrono>
#include <thread>
//External Includes
#include <biogears/cdm/engine/PhysiologyEngine.h>
#include <biogears/cdm/properties/SEScalarTime.h>
#include <biogears/engine/Controller/BioGears.h>
#include <biogears/engine/Controller/BioGearsEngine.h>
//Project Includes
#include "PhysiologyDriver.h"

using namespace std::literals::chrono_literals;
using namespace biogears;

namespace biogears_ui {
PhysiologyThread::PhysiologyThread(PhysiologyDriver& driver)
  : _physiology(driver.Physiology())
  , _tick(1s)
  , _advance(1s)
  , config(std::make_unique<PhysiologyEngineConfiguration>(_physiology->GetLogger()))
{
  config->Load("config/DynamicStabilization.xml");
}
//-----------------------------------------------------------------------------
std::chrono::milliseconds PhysiologyThread::TickRate()
{
  return _tick;
}
//-----------------------------------------------------------------------------
PhysiologyThread& PhysiologyThread::TickRate(std::chrono::milliseconds rate)
{
  _tick = rate;
  return *this;
}
//-----------------------------------------------------------------------------
void PhysiologyThread::step()
{
  _physiology->AdvanceModelTime(_advance.count(), TimeUnit::s);
}
//-----------------------------------------------------------------------------
std::function<void(std::chrono::milliseconds)> PhysiologyThread::step_as_func()
{
  using namespace std::chrono;
  using namespace std::chrono_literals;
  return [&](std::chrono::milliseconds duration)
  {
    auto as_sec = duration_cast<seconds>(duration);
    _physiology->AdvanceModelTime(static_cast<double>(as_sec.count()), TimeUnit::s);
  };
}
//-----------------------------------------------------------------------------
void PhysiologyThread::paused(bool state)
{
  _paused = state;
}
//-----------------------------------------------------------------------------
bool PhysiologyThread::paused()
{
  return _paused.load();
}
//-----------------------------------------------------------------------------
void PhysiologyThread::run()
{
  if (_started) { return; }
  auto& patient = _physiology->GetPatient();
   
  if( _physiology->InitializeEngine(patient, nullptr, config.get()) )
  {
    _started = true;
    _done = false;
    _thread = std::thread(&PhysiologyThread::execute, this);
  }
}
//-----------------------------------------------------------------------------
void PhysiologyThread::execute()
{
  while (!_done) {
    
    const auto start = std::chrono::steady_clock::now();
    if(!_paused)
    {
      _physiology->AdvanceModelTime(_advance.count(), TimeUnit::s);
    }
    const auto finish = std::chrono::steady_clock::now();
    const auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(finish - start);

    if (duration < _tick) {
      std::this_thread::sleep_for(_tick - duration);
    }
  }
}
//-----------------------------------------------------------------------------
void PhysiologyThread::stop()
{
  _done = true;
}
//-----------------------------------------------------------------------------
void PhysiologyThread::join()
{
  if(_thread.joinable())
  {
    _thread.join();
  }
}
//-----------------------------------------------------------------------------
}