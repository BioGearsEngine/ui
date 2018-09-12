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
//!
//! \brief Primary window of BioGears UI

#include "ThermalResistanceInputWidget.h"
//Standard Includes
#include <cassert>
//External Includes
#include <QtWidgets>
#include <units.h>

#include "UnitInputWidget.h"
namespace biogears_ui {

struct ThermalResistanceInputWidget::Implementation : public QObject {
public:
  Implementation(QString label, double value, QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  void updateView();
  void notify();

  void subscribe(ThermalResistanceInputWidget*);
  void unsubscribe();

public slots:
  void processValueChange();
  void processViewChange();

public:
  UnitInputWidget* unitInput = nullptr;
  units::insulation::clo_t value;
  units::insulation::clo_t minimum;
  units::insulation::clo_t maximum;

  ThermalResistanceInputWidget* subscriber = nullptr;
};
//-------------------------------------------------------------------------------
ThermalResistanceInputWidget::Implementation::Implementation(::QString label, double value, ::QWidget* parent)
  : unitInput(UnitInputWidget::create(label, value, "clo", parent))
  , value(value)
  , minimum(0.0)
  , maximum(2.0)
{
  unitInput->addUnit("R");
  unitInput->addUnit("RSI");
  unitInput->addUnit("tog");
  unitInput->setSingleStep(0.01);
  unitInput->setRange(minimum(), maximum());
  unitInput->Value(value);

  connect(unitInput, &UnitInputWidget::valueChanged, this, &Implementation::processValueChange);
  connect(unitInput, &UnitInputWidget::unitChanged, this, &Implementation::processViewChange);
}
//-------------------------------------------------------------------------------
ThermalResistanceInputWidget::Implementation::Implementation(const Implementation& obj)
{
  *this = obj;
}
//-------------------------------------------------------------------------------
ThermalResistanceInputWidget::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
void ThermalResistanceInputWidget::Implementation::subscribe(ThermalResistanceInputWidget* obj)
{
  subscriber = obj;
}
//-------------------------------------------------------------------------------
void ThermalResistanceInputWidget::Implementation::unsubscribe()
{
  subscriber = nullptr;
}
//-------------------------------------------------------------------------------
void ThermalResistanceInputWidget::Implementation::processValueChange()
{
  switch (unitInput->UnitIndex()) {
  case 0: //View value as clo
    value = units::insulation::clo_t(unitInput->Value());
    break;
  case 1: { //View value as r_value
    value = units::insulation::r_value_t(unitInput->Value());
  } break;
  case 2: { //View value as rsi_value
    value = units::insulation::rsi_value_t(unitInput->Value());
  } break;
  case 3: { //View value as tog
    value = units::insulation::tog_t(unitInput->Value());
  } break;
  {
    assert(unitInput->UnitIndex() < 3);
    value = units::insulation::clo_t(unitInput->Value());
  } break;
  }
  if (subscriber) {
    emit subscriber->valueChanged();
  }
}
//-------------------------------------------------------------------------------
void ThermalResistanceInputWidget::Implementation::processViewChange()
{
  updateView();
}
//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
ThermalResistanceInputWidget::Implementation& ThermalResistanceInputWidget::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
ThermalResistanceInputWidget::Implementation& ThermalResistanceInputWidget::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
void ThermalResistanceInputWidget::Implementation::updateView()
{
  auto current = value;
  switch (unitInput->UnitIndex()) {
  case 0: //View value as km/h
    unitInput->setRange(minimum(), maximum());
    unitInput->Value(current());
    break;
  case 1: { //View value as m/s
    units::insulation::r_value_t view{ current };
    units::insulation::r_value_t min{ minimum };
    units::insulation::r_value_t max{ maximum };
    unitInput->setRange(min(), max());
    unitInput->Value(view());
  } break;
  case 2: { //View value as m/s
    units::insulation::rsi_value_t view{ current };
    units::insulation::rsi_value_t min{ minimum };
    units::insulation::rsi_value_t max{ maximum };
    unitInput->setRange(min(), max());
    unitInput->Value(view());
  } break;
  case 3: { //View value as m/s
    units::insulation::tog_t view{ current };
    units::insulation::tog_t min{ minimum };
    units::insulation::tog_t max{ maximum };
    unitInput->setRange(min(), max());
    unitInput->Value(view());
  } break;
  default: //Debug case for if this class is patched but updateView has not been modified
  {
    assert(unitInput->UnitIndex() < 3);
    unitInput->setRange(minimum(), maximum());
    unitInput->Value(current());
  } break;
  }
}
//-------------------------------------------------------------------------------
ThermalResistanceInputWidget::ThermalResistanceInputWidget(QWidget* parent)
  : _impl("ThermalResistance", 0.0, parent)
{
  _impl->subscribe(this);
}
//-------------------------------------------------------------------------------
ThermalResistanceInputWidget::ThermalResistanceInputWidget(QString label, double value, QWidget* parent)
  : _impl(label, value, parent)
{
}
//-------------------------------------------------------------------------------
ThermalResistanceInputWidget::~ThermalResistanceInputWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto ThermalResistanceInputWidget::create(QString label, double value, QWidget* parent) -> ThermalResistanceInputWidgetPtr
{
  auto widget = new ThermalResistanceInputWidget(label, value, parent);
  return widget;
}
//-------------------------------------------------------------------------------
double ThermalResistanceInputWidget::Value() const
{
  return _impl->value();
}
//-------------------------------------------------------------------------------
void ThermalResistanceInputWidget::Value(units::insulation::clo_t given)
{
  _impl->value = given;
  _impl->updateView();
}
//-------------------------------------------------------------------------------
QString ThermalResistanceInputWidget::Label() const
{
  return _impl->unitInput->Label();
}
//-------------------------------------------------------------------------------
void ThermalResistanceInputWidget::Label(const QString& given)
{
  _impl->unitInput->Label(given);
}
//-------------------------------------------------------------------------------
QString ThermalResistanceInputWidget::ViewUnitText() const
{
  return _impl->unitInput->UnitText();
}
//-------------------------------------------------------------------------------
QWidget* ThermalResistanceInputWidget::Widget()
{
  return _impl->unitInput;
}
//-------------------------------------------------------------------------------
void ThermalResistanceInputWidget::setRange(double min, double max)
{
  _impl->minimum = units::insulation::clo_t(min);
  _impl->maximum = units::insulation::clo_t(max);
  _impl->updateView();
}
//-------------------------------------------------------------------------------
void ThermalResistanceInputWidget::setSingleStep(double step)
{
  _impl->unitInput->setSingleStep(step);
}
//-------------------------------------------------------------------------------
}