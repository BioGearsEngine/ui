#ifndef BIOGEARSUI_PHYS_SCENARIO_DRIVER_H
#define BIOGEARSUI_PHYS_SCENARIO_DRIVER_H

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
//! \author Steven A White
//! \date   Aug 24th 2017
//!
//!  Wrapper Class for controlling Physiology Simulations
//!

//Standard Includes
#include <string>
#include <chrono>
//Project Includes
#include <biogears/framework/unique_propagate_const.h>
#include <chrono>

namespace biogears_ui {
class PhysiologyDriver {
public:
  PhysiologyDriver(const std::string&);
  ~PhysiologyDriver();


  void advance(std::chrono::milliseconds deltaT);
  void async_advance(std::chrono::milliseconds deltaT);

  bool isPaused();

  bool loadPatient(std::string path, std::string filename);
  bool loadScenario(std::string path, std::string filename);
  bool loadEnvironment(std::string path, std::string filename);

  bool applyAction();

private:
  struct Implementation;
  biogears::unique_propagate_const<Implementation> _impl;
};
}
#endif //BIOGEARSUI_PHYS_SCENARIO_DRIVER_H