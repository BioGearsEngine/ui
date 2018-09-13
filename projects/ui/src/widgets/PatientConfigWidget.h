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
#include <units.h>
//Project Includes
#include <biogears/framework/unique_propagate_const.h>
#include <biogears/math/units.h>

namespace biogears_ui {
enum class EGender { Male,
  Female };
class PatientConfigWidget : public QWidget {
  Q_OBJECT
public:
  PatientConfigWidget(QWidget* parent = nullptr);
  ~PatientConfigWidget();

  using PatientConfigWidgetPtr = PatientConfigWidget*;

  static auto create(QWidget* parent = nullptr) -> PatientConfigWidgetPtr;

  QString Name() const;
  PatientConfigWidget& Name(QString);
  EGender Gender() const;
  PatientConfigWidget& Gender(EGender);
  double Age() const;
  PatientConfigWidget& Age(units::time::year_t);
  double Weight() const;
  PatientConfigWidget& Weight(units::mass::kilogram_t);
  double Height() const;
  PatientConfigWidget& Height(units::length::meter_t);
  double BodyFatPercentage() const;
  PatientConfigWidget& BodyFatPercentage(double);
  double HeartRate() const;
  PatientConfigWidget& HeartRate(units::frequency::hertz_t);
  double RespritoryRate() const;
  PatientConfigWidget& RespritoryRate(units::frequency::hertz_t);
  double DiastolicPressureBaseline() const;
  PatientConfigWidget& DiastolicPressureBaseline(units::pressure::milimeters_of_mercury_t);
  double SystolicPresureBaseline() const;
  PatientConfigWidget& SystolicPresureBaseline(units::pressure::milimeters_of_mercury_t);

signals:
  void valueChanged();

private:
  struct Implementation;
  biogears::unique_propagate_const<Implementation> _impl;
};
}

#endif //BIOGEARSUI_WIDGETS_SIMULATION_PATIENT_CONFIG_WIDGET_H