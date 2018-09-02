#ifndef BIOGEARSUI_WIDGETS_SIMULATION_TIMELINE_CONFIG_WIDGET_H
#define BIOGEARSUI_WIDGETS_SIMULATION_TIMELINE_CONFIG_WIDGET_H

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
//! \date   August 30th 2018
//!
//!

//External Includes
#include <QToolBar>

#include <biogears/framework/unique_propagate_const.h>
//Project Includes
#include "..\utils\ActionDataStruct.h"

namespace biogears_ui {
class TimelineConfigWidget : public QWidget {
  Q_OBJECT
public:
  TimelineConfigWidget(QWidget* parent = nullptr);
  ~TimelineConfigWidget();

  using TimelineConfigWidgetPtr = TimelineConfigWidget*;
  
  std::vector<ActionData> Actions() const;
  void Actions(std::vector<ActionData>) ;

  void ScenarioTime(double time);
  double ScenarioTime();

  void addAction(std::string& name, double time);
  bool removeAction(const std::string& name);
  static auto create(QWidget* parent = nullptr) -> TimelineConfigWidgetPtr;

signals:
  void actionAdded(const ActionData data);
  void timeChanged(int time);

private:
	struct Implementation;
	biogears::unique_propagate_const<Implementation> _impl;
};
}

#endif //BIOGEARSUI_WIDGETS_SIMULATION_TIMELINE_CONFIG_WIDGET_H
