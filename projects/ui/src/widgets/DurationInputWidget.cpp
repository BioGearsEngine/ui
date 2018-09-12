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

#include "DurationInputWidget.h"
//Standard Includes
#include <cassert>
//External Includes
#include <QtWidgets>
#include <units.h>

#include "UnitInputWidget.h"
namespace biogears_ui {

struct DurationInputWidget::Implementation : public QObject {
public:
  Implementation(QString label, double value, QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  void updateView();
  void notify();

  void subscribe(DurationInputWidget*);
  void unsubscribe();

public slots:
  void processValueChange();
  void processViewChange();

public:
  UnitInputWidget* unitInput = nullptr;
  units::time::second_t value;
  units::time::second_t minimum;
  units::time::second_t maximum;

  DurationInputWidget* subscriber = nullptr;
};
//-------------------------------------------------------------------------------
DurationInputWidget::Implementation::Implementation(::QString label, double value, ::QWidget* parent)
  : unitInput(UnitInputWidget::create(label, value, "s", parent))
  , value(value)
  , minimum(0 )
  , maximum(6'307'200'000.)
{
  unitInput->addUnit("min");
  unitInput->addUnit("h");
  unitInput->addUnit("yr");

  unitInput->setSingleStep(1.);
  unitInput->setRange(minimum(), maximum());
  unitInput->Value(value);

  connect(unitInput, &UnitInputWidget::valueChanged, this, &Implementation::processValueChange);
  connect(unitInput, &UnitInputWidget::unitChanged, this, &Implementation::processViewChange);
}
//-------------------------------------------------------------------------------
DurationInputWidget::Implementation::Implementation(const Implementation& obj)
{
  *this = obj;
}
//-------------------------------------------------------------------------------
DurationInputWidget::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
void DurationInputWidget::Implementation::subscribe(DurationInputWidget* obj)
{
  subscriber = obj;
}
//-------------------------------------------------------------------------------
void DurationInputWidget::Implementation::unsubscribe()
{
  subscriber = nullptr;
}
//-------------------------------------------------------------------------------
void DurationInputWidget::Implementation::processValueChange()
{
  switch (unitInput->UnitIndex()) {
  case 0: //View value as celcius
    value = units::time::second_t(unitInput->Value());
    break;
  case 1: { //View value as Fahrenheit
    value = units::time::minute_t(unitInput->Value());
  } break;
  case 2: { //View value as Fahrenheit
    value = units::time::hour_t(unitInput->Value());
  } break;
  case 3: { //View value as Fahrenheit
    value = units::time::year_t(unitInput->Value());
  } break;
  default: //Debug case for if this class is patched but updateView has not been modified
  {
    assert(unitInput->UnitIndex() < 3);
    value = units::time::second_t(unitInput->Value());
  } break;
  }
  if (subscriber) {
    emit subscriber->valueChanged();
  }
}
//-------------------------------------------------------------------------------
void DurationInputWidget::Implementation::processViewChange()
{
  updateView();
}
//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
DurationInputWidget::Implementation& DurationInputWidget::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
DurationInputWidget::Implementation& DurationInputWidget::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
void DurationInputWidget::Implementation::updateView()
{
  auto current = value;
  switch (unitInput->UnitIndex()) {
  case 0: //View value as Seconds
    unitInput->setRange(minimum(), maximum());
    unitInput->Value(current());
    break;
  case 1: { //View value as Minutes
    units::time::minute_t view{ current };
    units::time::minute_t min{ minimum };
    units::time::minute_t max{ maximum };
    unitInput->setRange(min(), max());
    unitInput->Value(view());
  } break;
  case 2: { //View value as Hours
    units::time::hour_t view{ current };
    units::time::hour_t min{ minimum };
    units::time::hour_t max{ maximum };
    unitInput->setRange(min(), max());
    unitInput->Value(view());
  } break;
  case 3: { //View value as Years
    units::time::year_t view{ current };
    units::time::year_t min{ minimum };
    units::time::year_t max{ maximum };
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
DurationInputWidget::DurationInputWidget(QWidget* parent)
  : _impl("Duration", 0.0, parent)
{
  _impl->subscribe(this);
}
//-------------------------------------------------------------------------------
DurationInputWidget::DurationInputWidget(QString label, double value, QWidget* parent)
  : _impl(label, value, parent)
{
}
//-------------------------------------------------------------------------------
DurationInputWidget::~DurationInputWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto DurationInputWidget::create(QString label, double value, QWidget* parent) -> DurationInputWidgetPtr
{
  auto widget = new DurationInputWidget(label, value, parent);
  return widget;
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto DurationInputWidget::create(QString label, units::time::second_t value, QWidget* parent) -> DurationInputWidgetPtr
{
  auto widget = new DurationInputWidget(label, value(), parent);
  return widget;
}
//------------------------------------------------------------------------------
double DurationInputWidget::Value() const
{
  return _impl->value();
}
//-------------------------------------------------------------------------------
void DurationInputWidget::Value(units::time::second_t given)
{
  _impl->value = given;
  _impl->updateView();
}
//-------------------------------------------------------------------------------
QString DurationInputWidget::Label() const
{
  return _impl->unitInput->Label();
}
//-------------------------------------------------------------------------------
void DurationInputWidget::Label(const QString& given)
{
  _impl->unitInput->Label(given);
}
//-------------------------------------------------------------------------------
QString DurationInputWidget::ViewUnitText() const
{
  return _impl->unitInput->UnitText();
}
//-------------------------------------------------------------------------------
void DurationInputWidget::setUnitView(enum Duration unit)
{
  switch (unit) {
  case Duration::Seconds:
    _impl->unitInput->UnitIndex(0);
    break;
  case Duration::Minutes:
    _impl->unitInput->UnitIndex(1);
    break;
  case Duration::Hours:
    _impl->unitInput->UnitIndex(2);
    break;
  case Duration::Years:
    _impl->unitInput->UnitIndex(3);
    break;
  default:
    _impl->unitInput->UnitIndex(0);
    break;
  };
}
//-------------------------------------------------------------------------------
QWidget* DurationInputWidget::Widget()
{
  return _impl->unitInput;
}
//-------------------------------------------------------------------------------
void DurationInputWidget::setRange(double min, double max)
{
  _impl->minimum = units::time::second_t(min);
  _impl->maximum = units::time::second_t(max);
  _impl->updateView();
}
//-------------------------------------------------------------------------------
void DurationInputWidget::setSingleStep(double step)
{
  _impl->unitInput->setSingleStep(step);
}
//-------------------------------------------------------------------------------
}