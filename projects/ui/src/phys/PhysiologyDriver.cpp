#include "PhysiologyDriver.h"

//-------------------------------------------------------------------------------------------
//- Copyright 2018 Applied Research Associates, Inc.
//- Licensed under the Apache License, Version 2.0 (the "License"); you may not use
//- this file except in compliance with the License. You may obtain a copy of the License
//- at:
//- http://www.apache.org/licenses/LICENSE-2.0
//- Unless required by applicable law or agreed to in writing, software distributed under
//- the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//- CONDITIONS OF ANY KIND, either express or implied. See the License for the
//-  specific language governing permissions and limitations under the License.
//-------------------------------------------------------------------------------------------

//Standard Includes
#include <atomic>
#include <memory>
#include <thread>
#include <regex>
//External Includes
#include <biogears/exports.h>


#include <biogears/cdm/patient/SEPatient.h>
#include <biogears/cdm/properties/SEScalarTime.h>
#include <biogears/cdm/scenario/SEScenario.h>
#include <biogears/cdm/system/environment/SEEnvironment.h>
#include <biogears/container/Tree.tci.h>
#include <biogears/container/concurrent_ringbuffer.tci.h>
#include <biogears/engine/Controller/BioGearsEngine.h>

#include <boost/filesystem/path.hpp>
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_generators.hpp>
#include <boost/uuid/uuid_io.hpp>

using namespace biogears;

namespace biogears_ui {

struct PhysiologyDriver::Implementation {
public:
  Implementation(const std::string&);
  Implementation(const Implementation&);
  Implementation(Implementation&&);
  ~Implementation();

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  void loadPatient();
  void loadTimeline();
  void loadEnvironment();

  void async_realtime();
  void async_advance();

  std::unique_ptr<BioGearsEngine> phy = nullptr;
  std::unique_ptr<SEScenario> scenario = nullptr;
  std::unique_ptr<PhysiologyEngineConfiguration> config = nullptr;

  std::string patient_file = "";
  std::string environment_file = "";
  std::string timeline_file = "";

  std::thread async_advance_thread;
  std::atomic<bool> running = false;
  std::atomic<bool> paused = false;
  bool initialized = false;
};
//-------------------------------------------------------------------------------
PhysiologyDriver::Implementation::Implementation(const std::string& scenario)
  : phy(std::make_unique<BioGearsEngine>(scenario + ".log"))
  , scenario(std::make_unique<SEScenario>(phy->GetSubstanceManager()))
  , config(std::make_unique<PhysiologyEngineConfiguration>(phy->GetLogger()))
{
  config->Load("config/DynamicStabilization.xml");
}
//-------------------------------------------------------------------------------
PhysiologyDriver::Implementation::Implementation(const Implementation& obj)

{
  *this = obj;
}
//-------------------------------------------------------------------------------
PhysiologyDriver::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
PhysiologyDriver::Implementation::~Implementation()
{
  running = false;
  paused = false;
  if (async_advance_thread.joinable()) {
    async_advance_thread.join();
  }
  config = nullptr;
  scenario = nullptr;
  phy = nullptr;
}

//-------------------------------------------------------------------------------
PhysiologyDriver::Implementation& PhysiologyDriver::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
PhysiologyDriver::Implementation& PhysiologyDriver::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::Implementation::loadPatient()
{
  SEPatient& patient = static_cast<BioGears*>(phy.get())->GetPatient();
  patient.Load(patient_file);
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::Implementation::loadTimeline()
{
  scenario->Load(timeline_file);
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::Implementation::loadEnvironment()
{
  SEEnvironment& env = static_cast<BioGears*>(phy.get())->GetEnvironment();
  SEEnvironmentalConditions& conditions = env.GetConditions();
  conditions.Load(environment_file);
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::Implementation::async_realtime()
{
  using namespace std::chrono_literals;
  while (running) {
    if (!paused) {
      auto start = std::chrono::steady_clock::now();
      phy->AdvanceModelTime(1.0, biogears::TimeUnit::s);
      phy->GetEngineTrack()->TrackData(phy->GetSimulationTime(biogears::TimeUnit::s));
      auto finish = std::chrono::steady_clock::now();
      if (finish - start < 1s) {
        std::this_thread::sleep_for(1s - (finish - start));
      }
    } else {
      std::this_thread::sleep_for(16ms);
    }
  }
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::Implementation::async_advance()
{
  using namespace std::chrono_literals;
  while (running) {
    if (!paused) {
      auto start = std::chrono::steady_clock::now();
      phy->AdvanceModelTime(1.0, biogears::TimeUnit::s);
      phy->GetEngineTrack()->TrackData(phy->GetSimulationTime(biogears::TimeUnit::s));
    } else {
      std::this_thread::sleep_for(16ms);
    }
  }
}
//-------------------------------------------------------------------------------
PhysiologyDriver::PhysiologyDriver()
  : _impl("BiogearsGUI")
{
}
//-------------------------------------------------------------------------------
PhysiologyDriver::PhysiologyDriver(const std::string& scenario)
  : _impl(scenario)
{
}
//-------------------------------------------------------------------------------
PhysiologyDriver::~PhysiologyDriver()
{
  _impl = nullptr;
}
PhysiologyDriver::PhysiologyDriver(PhysiologyDriver&& obj)
  : _impl(std::move(obj._impl))
{
  boost::uuids::random_generator gen;
  boost::uuids::uuid uuid = gen();
  obj._impl = Implementation(boost::uuids::to_string(uuid));
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::advance(std::chrono::milliseconds deltaT)
{
  if (_impl->initialized) {
    _impl->phy->AdvanceModelTime(static_cast<double>(std::chrono::duration_cast<std::chrono::seconds>(deltaT).count()), biogears::TimeUnit::s);
    _impl->phy->GetEngineTrack()->TrackData(_impl->phy->GetSimulationTime(biogears::TimeUnit::s));
  }
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::async_start_realtime()
{
  _impl->running = true;
  _impl->paused = false;
  _impl->async_advance_thread = std::thread(&Implementation::async_realtime, _impl.get());
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::async_start()
{
  _impl->running = true;
  _impl->paused = false;
  _impl->async_advance_thread = std::thread(&Implementation::async_advance, _impl.get());
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::async_pause()
{
  _impl->paused = true;
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::async_resume()
{
  if (_impl->running) {
    _impl->paused = true;
  }
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::async_stop()
{
  _impl->running = false;
}
//-------------------------------------------------------------------------------
bool PhysiologyDriver::isPaused()
{
  return _impl->running && !_impl->paused;
}
//-------------------------------------------------------------------------------
bool PhysiologyDriver::isRunning()
{
  return _impl->running;
}
//-------------------------------------------------------------------------------
bool PhysiologyDriver::loadPatient(const std::string& filepath)
{
  namespace bfs = boost::filesystem;
  _impl->patient_file = filepath;
  _impl->loadPatient();
  return true;
}
//-------------------------------------------------------------------------------
bool PhysiologyDriver::loadTimeline(const std::string& filepath)
{
  namespace bfs = boost::filesystem;
  _impl->timeline_file = filepath;
  _impl->loadTimeline();
  return true;
}
//-------------------------------------------------------------------------------
bool PhysiologyDriver::loadEnvironment(const std::string& filepath)
{
  namespace bfs = boost::filesystem;
  _impl->environment_file = filepath;
  _impl->loadEnvironment();
  return true;
}
//-------------------------------------------------------------------------------
//!
//! \brief Passes a copy
//!\return
//!
const std::vector<biogears::SEAction*> PhysiologyDriver::GetActions() const
{
  return _impl->scenario->GetActions();
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::SetActions(const std::vector<biogears::SEAction>& actions)
{
  //_impl->scenario->ClearActions();
  for (auto& action : actions) {
    _impl->scenario->AddAction(action);
  }
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::SetActionsAfter(const biogears::SEAction& reference, const biogears::SEAction& newAction)
{
  //_impl->scenario->AddActionAfter(reference, newAction);
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::clearPatient() { _impl->patient_file = ""; }
//-------------------------------------------------------------------------------
void PhysiologyDriver::clearEnvironment() { _impl->environment_file = ""; }
//-------------------------------------------------------------------------------
void PhysiologyDriver::clearTimeline() { _impl->timeline_file = ""; }
//-------------------------------------------------------------------------------
SEPatient& PhysiologyDriver::Patient()
{
  return static_cast<BioGears*>(_impl->phy.get())->GetPatient();
}
//-------------------------------------------------------------------------------
SEEnvironment& PhysiologyDriver::Environment()
{
  return static_cast<BioGears*>(_impl->phy.get())->GetEnvironment();
}
//-------------------------------------------------------------------------------
std::string PhysiologyDriver::timeline() const
{
  return _impl->timeline_file;
}
//-------------------------------------------------------------------------------
bool PhysiologyDriver::applyAction()
{
  return true;
}
//-------------------------------------------------------------------------------
PhysiologyEngine* PhysiologyDriver::Physiology()
{
  //note:sawhite: We are loosing control of Physiology for now
  return static_cast<PhysiologyEngine*>(_impl->phy.get());
}
//-------------------------------------------------------------------------------
bool PhysiologyDriver::initialize()
{
  auto& phy = _impl->phy;
  auto& patient = phy->GetPatient();
  _impl->initialized = phy->InitializeEngine(patient, nullptr, _impl->config.get());
  return _impl->initialized;
}
//-------------------------------------------------------------------------------
//! \brief Allocates memory but does not take ownership of it.
//!        It is a memory leak not to clean this memory up yourself;
DataRequestModel* PhysiologyDriver::getPossiblePhysiologyDatarequest()
{

  DataRequestModel* model = create_DataRequestModel(_impl->phy->GetDataRequestGraph() ).release();
  return model;
}
//-------------------------------------------------------------------------------
DataRequestModel* PhysiologyDriver::getPossibleCompartmentDataRequest()
{
  return new DataRequestModel;
}
//-------------------------------------------------------------------------------
auto PhysiologyDriver::dataRequests() const -> DataTrackMap
{
  DataTrackMap rValue;
  auto& tracks = _impl->phy->GetEngineTrack()->GetDataTrack();

  std::vector<std::string>& headings = tracks.GetHeadings();
  for (const auto& heading : headings) {
    rValue[heading] = tracks.GetProbe(heading);
  }
  return rValue;
}
//-------------------------------------------------------------------------------
auto PhysiologyDriver::dataRequest(std::string key) const -> DataTrack
{
  auto& tracks = _impl->phy->GetEngineTrack()->GetDataTrack();
  return tracks.GetProbe(key);
}
//-------------------------------------------------------------------------------
}
