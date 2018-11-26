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
#include <chrono>
#include <string>
#include <utility>
#include <vector>
//Project Includes
#include <QStringListModel>
#include <biogears/cdm/patient/SEPatient.h>
#include <biogears/cdm/scenario/SEAction.h>
#include <biogears/cdm/system/environment/SEEnvironment.h>

#include <biogears/exports.h>
#include <biogears/framework/unique_propagate_const.h>
#include <QTreeWidgetItem>

namespace biogears {
class PhysiologyEngine;
}

namespace biogears_ui {
class PhysiologyThread;
class PhysiologyDriver {
  friend PhysiologyThread;

public:
  using DataTrack = double;
  using DataTrackMap = std::map<std::string, DataTrack>;

  PhysiologyDriver();
  PhysiologyDriver(const std::string&);
  PhysiologyDriver(const PhysiologyDriver&) = delete;
  PhysiologyDriver(PhysiologyDriver&&);
  ~PhysiologyDriver();

  void advance(std::chrono::milliseconds deltaT);
  void async_start_realtime();
  void async_start();
  void async_pause();
  void async_resume();
  void async_stop();

  bool isPaused();
  bool isRunning();

  bool loadPatient(const std::string& filepath);
  bool loadTimeline(const std::string& filepath);
  bool loadEnvironment(const std::string& filepath);

  const std::vector<biogears::SEAction*> GetActions() const;
  void SetActionsAfter(const biogears::SEAction& reference, const biogears::SEAction& newAction);
  void SetActions(const std::vector<biogears::SEAction>& actions);

  QTreeWidgetItem* getPossiblePhysiologyDatarequest();
  QTreeWidgetItem* getPossibleCompartmentDataRequest();

  auto dataRequests() const -> DataTrackMap;
  auto dataRequest(std::string) const -> DataTrack;

  void clearPatient();
  void clearEnvironment();
  void clearTimeline();

  biogears::SEPatient& Patient();
  biogears::SEEnvironment& Environment();
  std::string timeline() const;

  bool applyAction();

  bool initialize();

private:
  biogears::PhysiologyEngine* Physiology();

private:
  struct Implementation;
  biogears::unique_propagate_const<Implementation> _impl;
};
}
#endif //BIOGEARSUI_PHYS_SCENARIO_DRIVER_H