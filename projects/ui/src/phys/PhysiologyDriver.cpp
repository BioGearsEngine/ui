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
#include <memory>

//External Includes
#include <biogears/string-exports.h>

#include <biogears/engine/Controller/BioGears.h>
#include <biogears/engine/BioGearsPhysiologyEngine.h>
#include <biogears/cdm/patient/SEPatient.h>
#include <biogears/cdm/scenario/SEScenario.h>
#include <biogears/cdm/system/environment/SEEnvironment.h>

#include <boost/filesystem/path.hpp>
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_generators.hpp>
#include <boost/uuid/uuid_io.hpp>

namespace biogears_ui {
struct PhysiologyDriver::Implementation {
public:
  Implementation(const std::string&);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  std::unique_ptr<BioGears> phy = nullptr;

  void loadPatient();
  void loadTimeline();
  void loadEnvironment();

  std::string patient_file = "";
  std::string environment_file = "";
  std::string timeline_file = "";
};
//-------------------------------------------------------------------------------
PhysiologyDriver::Implementation::Implementation(const std::string& scenario)
  : phy(new BioGears(scenario + ".log"))
{
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
  SEPatient& patient = phy->GetPatient();
  patient.Load(patient_file);
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::Implementation::loadTimeline()
{
  //TODO:sawhite:Walk through with Matt on what to do here
  //auto& patient = phy->Ge();
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::Implementation::loadEnvironment()
{
  SEEnvironment& env = phy->GetEnvironment();
  env.Load(environment_file);
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
//PhysiologyDriver(const PhysiologyDriver&);
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
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::async_advance(std::chrono::milliseconds deltaT)
{
}
//-------------------------------------------------------------------------------
bool PhysiologyDriver::isPaused()
{
  return false;
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
void PhysiologyDriver::clearPatient() { _impl->patient_file = ""; }
//-------------------------------------------------------------------------------
void PhysiologyDriver::clearEnvironment() { _impl->environment_file = ""; }
//-------------------------------------------------------------------------------
void PhysiologyDriver::clearTimeline() { _impl->timeline_file = ""; }
//-------------------------------------------------------------------------------
SEPatient& PhysiologyDriver::Patient()
{
  return _impl->phy->GetPatient();
}
//-------------------------------------------------------------------------------
SEEnvironment& PhysiologyDriver::Environment()
{
  return _impl->phy->GetEnvironment();
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
}
