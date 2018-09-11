#ifndef BIOGEARSUI_WIDGETS_THERMAL_RESISTANCE_WIDGET_WIDGET_H
#define BIOGEARSUI_WIDGETS_THERMAL_RESISTANCE_WIDGET_WIDGET_H

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
//! \date   Sept 11th 2018
//!
//! \brief This class is an input field for a ThermalResistance value. The return of Value will always be in the model unit of km/h
//!        passed in at construction. Additionally you can view and input velocities in mph and m/s
//!        you can retrieve the current view using ViewUnitText();

//External Includes
#include <QComboBox>
#include <units.h>
//Project Includes
#include <biogears/framework/unique_propagate_const.h>

namespace units {
  UNIT_ADD(insulation, r_value, r_values, R, units::compound_unit<squared<units::length::meters>, units::temperature::celsius, inverse<squared<units::power::watts>>>)
UNIT_ADD(insulation, rsi_value, rsi_values, RSI, units::unit<std::ratio<567826, 100000>, r_values>)
  UNIT_ADD(insulation, clo, clothes, clo, units::unit<std::ratio<86,100>, r_values>)
  UNIT_ADD(insulation, tog, togs, tog, units::unit<std::ratio<100,155>, clo>)
  }

namespace biogears_ui {
class ThermalResistanceInputWidget : public QObject {
  Q_OBJECT
public:
  ThermalResistanceInputWidget(QWidget* parent = nullptr);
  ThermalResistanceInputWidget(QString label, double value, QWidget* parent = nullptr);
  virtual ~ThermalResistanceInputWidget();

  using ThermalResistanceInputWidgetPtr = ThermalResistanceInputWidget*;
  static auto create(QString label, double value, QWidget* parent = nullptr) -> ThermalResistanceInputWidgetPtr;

  double Value() const;
  void Value(units::insulation::clo_t);

  QString Label() const;
  void Label(const QString&);

  QString ViewUnitText() const;

  QWidget* Widget();

  void setRange(double, double);
  void setSingleStep(double);

signals:
  void valueChanged();

private:
  struct Implementation;
  biogears::unique_propagate_const<Implementation> _impl;
};
}

#endif //BIOGEARSUI_WIDGETS_THERMAL_RESISTANCE_WIDGET_WIDGET_H