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
#include <biogears/engine/BioGearsPhysiologyEngine.h>
#include <biogears/string-exports.h>
#include <boost/filesystem/path.hpp>
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_io.hpp>
#include <boost/uuid/uuid_generators.hpp>

namespace biogears_ui {
struct PhysiologyDriver::Implementation {
public:
  Implementation(const std::string&);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  std::unique_ptr<PhysiologyEngine> phy = nullptr;

  std::string patient_file = "";
  std::string environment_file = "";
  std::string timeline_file = "";
};
//-------------------------------------------------------------------------------
PhysiologyDriver::Implementation::Implementation(const std::string& scenario)
  : phy(CreateBioGearsEngine(scenario + ".log"))
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
bool PhysiologyDriver::loadPatient(std::string path, std::string filename)
{
  namespace bfs = boost::filesystem;
  _impl->patient_file = (bfs::path(path) / bfs::path(filename)).string();
  return true;
}
//-------------------------------------------------------------------------------
bool PhysiologyDriver::loadTimeline(std::string path, std::string filename)
{
  namespace bfs = boost::filesystem;
  _impl->timeline_file = (bfs::path(path) / bfs::path(filename)).string();
  return true;
}
//-------------------------------------------------------------------------------
bool PhysiologyDriver::loadEnvironment(std::string path, std::string filename)
{
  namespace bfs = boost::filesystem;
  _impl->environment_file = (bfs::path(path) / bfs::path(filename)).string();
  return true;
}
void PhysiologyDriver::clearPatient() { _impl->patient_file = ""; }
//-------------------------------------------------------------------------------
void PhysiologyDriver::clearEnvironment() { _impl->environment_file = ""; }
//-------------------------------------------------------------------------------
void PhysiologyDriver::clearTimeline() { _impl->timeline_file = ""; }
//-------------------------------------------------------------------------------
std::string PhysiologyDriver::patient() const
{
  return _impl->patient_file;
}
//-------------------------------------------------------------------------------
std::string PhysiologyDriver::environment() const
{
  return _impl->environment_file;
}
//-------------------------------------------------------------------------------
std::string PhysiologyDriver::timeline() const
{
  return _impl->timeline_file;
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::patient(const std::string& patient)
{
  _impl->patient_file = patient;
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::environment(const std::string& environment)
{
  _impl->environment_file = environment;
}
//-------------------------------------------------------------------------------
void PhysiologyDriver::timeline(const std::string& timeline)
{
  _impl->timeline_file = timeline;
}
//-------------------------------------------------------------------------------
bool PhysiologyDriver::applyAction()
{
  return true;
}
}
