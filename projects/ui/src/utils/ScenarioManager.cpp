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

//!
//! \author Matthew McDaniel
//! \date   August 30th 2018
//!
//!

#include "ScenarioManager.h"

//External Includes
#include <biogears/string-exports.h>

namespace biogears_ui {
struct ScenarioManager::BioGearsAction {
public:
  BioGearsAction(const std::string&, double);
  std::string actionName;
  double actionStartTime;

  bool operator==(const std::string&);
};
struct ScenarioManager::Implementation {
public:
  Implementation();
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  std::vector<BioGearsAction> bgActions;
  double scenarioTime;
};

ScenarioManager::BioGearsAction::BioGearsAction(const std::string& name, double startTime)
  : actionName(name)
  , actionStartTime(startTime)
{
}
//This equality operator works for testing, but will need to get more specific since we can have multiple scenarios of the same
//type in a single timeline (e.g. multiple substance boluses)
bool ScenarioManager::BioGearsAction::operator==(const std::string& rhs)
{
  if (this->actionName.compare(rhs) == 0) {
    return true;
  } else {
    return false;
  }
}

ScenarioManager::Implementation::Implementation()
  : bgActions()
  , scenarioTime(0)
{
}
//-------------------------------------------------------------------------------
ScenarioManager::Implementation::Implementation(const Implementation& obj)
{
  *this = obj;
}
//-------------------------------------------------------------------------------
ScenarioManager::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
ScenarioManager::Implementation& ScenarioManager::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
ScenarioManager::Implementation& ScenarioManager::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}

ScenarioManager::ScenarioManager()
  : _impl()
{
}
ScenarioManager::~ScenarioManager()
{
  _impl = nullptr;
}

void ScenarioManager::addAction(const std::string& name, double time)
{
  _impl->bgActions.emplace_back(name, time);
}

bool ScenarioManager::removeAction(const std::string& name)
{
  auto it = find(_impl->bgActions.begin(), _impl->bgActions.end(), name);
  if (it != _impl->bgActions.end()) {
    _impl->bgActions.erase(it);
    return true;
  } else {
    return false;
  }
}
//This is only to test functionality.  In practice, we should increment time as we add AdvanceTime actions to action struct
void ScenarioManager::scenarioTime(double time)
{
  _impl->scenarioTime = time;
}
double ScenarioManager::scenarioTime()
{
  return _impl->scenarioTime;
}
//----------------------------------
}