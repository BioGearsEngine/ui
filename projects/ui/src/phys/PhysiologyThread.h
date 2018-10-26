#ifndef BIOGEARSUI_WIDGETS_PHYSIOLOGYTHREAD_WINDOW_H
#define BIOGEARSUI_WIDGETS_PHYSIOLOGYTHREAD_WINDOW_H

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
//! \date   September 19th 2018
//!
//!
//! \brief Thread for running a physiology simulation.
#include "PhysiologyDriver.h"

#include <atomic>
#include <chrono>
#include <functional>
#include <mutex>
#include <thread>

#include <biogears/threading/runnable.h>
#include <biogears/threading/steppable.h>
#include <biogears/cdm/engine/PhysiologyEngineConfiguration.h>

namespace biogears {
class PhysiologyEngine;
}
namespace biogears_ui {
class PhysiologyDriver;
class PhysiologyThread : public biogears::Runnable, public biogears::Steppable<void(std::chrono::milliseconds)> {
public:
  PhysiologyThread(PhysiologyDriver&);

  std::chrono::milliseconds TickRate();
  PhysiologyThread& TickRate(std::chrono::milliseconds);

  std::chrono::milliseconds AdvanceRate();
  PhysiologyThread& AdvanceRate(std::chrono::milliseconds);

  void step() override;
  std::function<void(std::chrono::milliseconds)> step_as_func() override;

  void run() override;
  void paused(bool);
  bool paused();
  void stop() override;
  void join() override;

protected:
  void execute();

private:
  //TODO:sawhite Upgrade to a shared PTR
  biogears::PhysiologyEngine* _physiology;

  std::unique_ptr<biogears::PhysiologyEngineConfiguration> config = nullptr;

  std::chrono::milliseconds _tick;
  std::chrono::seconds _advance;
  bool _started = false;
  std::atomic_bool _done = false;
  std::atomic_bool _paused = false;
  std::thread _thread;
  std::mutex _theadGuard;
};
;
}

#endif //BIOGEARSUI_WIDGETS_PHYSIOLOGYTHREAD_WINDOW_H