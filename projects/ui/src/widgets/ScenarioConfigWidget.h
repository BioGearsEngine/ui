#ifndef BIOGEARSUI_WIDGETS_SCENARIO_CONFIG_WINDOW_H
#define BIOGEARSUI_WIDGETS_SCENARIO_CONFIG_WINDOW_H

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

  class ScenarioConfigWidget : public QWidget {
    Q_OBJECT

  public:
    ScenarioConfigWidget(QWidget* parent);
    ~ScenarioConfigWidget();

    using ScenarioConfigWidgetPtr = ScenarioConfigWidget * ;
    static auto create(QWidget* parent = nullptr)->ScenarioConfigWidgetPtr;

    std::unique_ptr<PhysiologyDriver> getPhysiologyDriver();
    void  setPhysiologyDriver(std::unique_ptr<PhysiologyDriver>&&);

    ScenarioToolbar*  getScenarioToolbar();

   signals:

    
  public slots: //QT5 Slots >(
    void handlePatientFileChange(int index);
    void handleEnvironmentFileChange(int index);
    void handleTimelineFileChange(int index);
    void handlePatientValueChange();
    void handleEnvironmentValueChange();
    void handleTimelineValueChange();

    void loadPatient();
    void loadEnvironment();
    void loadTimeline();

    void populatePatientWidget();
    void populateEnvironmentWidget();
    void populateTimelineWidget();

  private:

  private: //Data
    std::unique_ptr<PhysiologyDriver> _driver;

    ScenarioToolbar*  _scenario_toolbar = nullptr;
    MultiSelectionWidget* _physiologySelection = nullptr;
    PatientConfigWidget* _patient_widget = nullptr;
    EnvironmentConfigWidget* _environment_widget = nullptr;
    TimelineConfigWidget* _timeline_widget = nullptr;
  };
}

#endif //BIOGEARSUI_WIDGETS_SCENARIO_CONFIG_WINDOW_H