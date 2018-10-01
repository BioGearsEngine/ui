#include "PhysiologyThread.h"

//Standard Includes
#include <chrono>
#include <thread>
//External Includes
#include <biogears/cdm/engine/PhysiologyEngine.h>
#include <biogears/cdm/properties/SEScalarTime.h>
#include <biogears/engine/Controller/BioGears.h>
//Project Includes
#include "PhysiologyDriver.h"

using namespace std::literals::chrono_literals;
using namespace biogears;

namespace biogears_ui {
PhysiologyThread::PhysiologyThread(PhysiologyDriver& driver)
  : _physiology(driver.Physiology())
  , _tick(16ms)
  , _advance(1s)
{
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
  return [&](std::chrono::milliseconds duration) { _physiology->AdvanceModelTime((double)duration.count(), TimeUnit::s); };
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
  _done = false;
  while (!_done) {
    const auto start = std::chrono::steady_clock::now();
    _physiology->AdvanceModelTime(_advance.count(), TimeUnit::s);
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
  _thread.join();
}
//-----------------------------------------------------------------------------
}