#ifndef BIOGEARSUI_WIDGETS_PRESSURE_WIDGET_WIDGET_H
#define BIOGEARSUI_WIDGETS_PRESSURE_WIDGET_WIDGET_H

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
//! \brief This class is an input field for a Pressure value. The return of Value will always be in the model unit of mmHg
//!        passed in at construction. Additionally you can view and input pressures of bar and atm, inHG
//!        you can retrieve the current view using ViewUnitText();

//External Includes
#include <QComboBox>
#include <units.h>
//Project Includes
#include <biogears/framework/unique_propagate_const.h>

namespace units {
UNIT_ADD(pressure, milimeters_of_mercury, milimeters_of_mercury, mmHG, units::unit<std::ratio<1000000000, 133322387415>, units::pressure::pascals>)
UNIT_ADD(pressure, inches_of_mercury, inches_of_mercury, inHG, units::unit<std::ratio<25400, 1000>, milimeters_of_mercury>)
}

namespace biogears_ui {
class PressureInputWidget : public QObject {
  Q_OBJECT
public:
  PressureInputWidget(QWidget* parent = nullptr);
  PressureInputWidget(QString label, double value, QWidget* parent = nullptr);
  virtual ~PressureInputWidget();

  using PressureInputWidgetPtr = PressureInputWidget*;
  static auto create(QString label, double value, QWidget* parent = nullptr) -> PressureInputWidgetPtr;

  double Value() const;
  void Value(units::pressure::milimeters_of_mercury_t);

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

#endif //BIOGEARSUI_WIDGETS_PRESSURE_WIDGET_WIDGET_H