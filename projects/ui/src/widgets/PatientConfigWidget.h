#ifndef BIOGEARSUI_WIDGETS_SIMULATION_PATIENT_CONFIG_WIDGET_H
#define BIOGEARSUI_WIDGETS_SIMULATION_PATIENT_CONFIG_WIDGET_H

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
//Project Includes
#include <biogears/framework/unique_propagate_const.h>

namespace biogears_ui {
class PatientConfigWidget : public QWidget {
  Q_OBJECT
public:
  PatientConfigWidget(QWidget* parent = nullptr);
  ~PatientConfigWidget();

  using PatientConfigWidgetPtr = PatientConfigWidget*;

  static auto create(QWidget* parent = nullptr) -> PatientConfigWidgetPtr;

  int patientListSize();
  int envrionmentListSize();
  int timelineListSize();

signals:
  void patientChanged(int index);
  void envonmentChanged(int index);
  void timelineChanged(int index);

private:
  struct Implementation;
  biogears::unique_propagate_const<Implementation> _impl;
};
}

#endif //BIOGEARSUI_WIDGETS_SIMULATION_PATIENT_CONFIG_WIDGET_H