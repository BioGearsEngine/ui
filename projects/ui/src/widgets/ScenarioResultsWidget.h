#ifndef BIOGEARSUI_WIDGETS_SCENARIO_RESULTS_WINDOW_H
#define BIOGEARSUI_WIDGETS_SCENARIO_RESULTS_WINDOW_H

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
//! \date   Octoer 25th 2018
//!
//!  
//! \brief Primary window of BioGears UI

//External Includes
#include <QWidget>
//Project Includes
#include <biogears/framework/unique_propagate_const.h>
#include "phys/PhysiologyThread.h"

namespace biogears_ui {
  class MultiSelectionWidget;
  class ScenarioToolbar;
  class PatientConfigWidget;
  class EnvironmentConfigWidget;
  class TimelineConfigWidget;

  class ScenarioResultsWidget : public QWidget {
    Q_OBJECT

  public:
    ScenarioResultsWidget(QWidget* parent);
    ~ScenarioResultsWidget();

    using ScenarioResultsWidgetPtr = ScenarioResultsWidget * ;
    static auto create(QWidget* parent = nullptr)->ScenarioResultsWidgetPtr;

    
    std::unique_ptr<PhysiologyDriver> getPhysiologyDriver();
    void  setPhysiologyDriver(std::unique_ptr<PhysiologyDriver>&& driver);

    void setSimulationTime(double);

    void lock();
    void unlock();

  public slots: //QT5 Slots >(
    void populateTimelineWidget();

  private:

  private: //Data
    std::unique_ptr<PhysiologyDriver> _driver;

    TimelineConfigWidget* _timeline_widget = nullptr;

  };
}

#endif //BIOGEARSUI_WIDGETS_SCENARIO_RESULTS_WINDOW_H