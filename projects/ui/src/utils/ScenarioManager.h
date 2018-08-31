#ifndef BIOGEARSUI_UTILS_SCENARIO_MANAGER_H
#define BIOGEARSUI_UTILS_SCENARIO_MANAGER_H

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

//Project includes
#include <biogears/framework/unique_propagate_const.h>
//Standard Includes
#include <string>
#include <vector>

namespace biogears_ui {
class ScenarioManager {
public:
  ScenarioManager();
  ~ScenarioManager();

  void addAction(const std::string& name, double startTime);
  bool removeAction(const std::string& name);
  void scenarioTime(double time);
  double scenarioTime();

private:
  struct BioGearsAction;
  struct Implementation;
  biogears::unique_propagate_const<Implementation> _impl;
};
}
#endif