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

#include "FrequencyInputWidget.h"
//Standard Includes
#include <cassert>
//External Includes
#include <QtWidgets>
#include <units.h>

#include "UnitInputWidget.h"
namespace biogears_ui {

struct FrequencyInputWidget::Implementation : public QObject {
public:
  Implementation(QString label, double value, QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  void updateView();
  void notify();

  void subscribe(FrequencyInputWidget*);
  void unsubscribe();

public slots:
  void processValueChange();
  void processViewChange();

public:
  UnitInputWidget* unitInput = nullptr;
  units::frequency::hertz_t value;
  units::frequency::hertz_t minimum;
  units::frequency::hertz_t maximum;

  FrequencyInputWidget* subscriber = nullptr;
};
//-------------------------------------------------------------------------------
FrequencyInputWidget::Implementation::Implementation(::QString label, double value, ::QWidget* parent)
  : unitInput(UnitInputWidget::create(label, value, "hz", parent))
  , value(value)
  , minimum(-273.15)
  , maximum(126.85)
{
  unitInput->addUnit("bpm");
  unitInput->setRange(minimum(), maximum());
  unitInput->Value(value);

  connect(unitInput, &UnitInputWidget::valueChanged, this, &Implementation::processValueChange);
  connect(unitInput, &UnitInputWidget::unitChanged, this, &Implementation::processViewChange);
}
//-------------------------------------------------------------------------------
FrequencyInputWidget::Implementation::Implementation(const Implementation& obj)
{
  *this = obj;
}
//-------------------------------------------------------------------------------
FrequencyInputWidget::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
void FrequencyInputWidget::Implementation::subscribe(FrequencyInputWidget* obj)
{
  subscriber = obj;
}
//-------------------------------------------------------------------------------
void FrequencyInputWidget::Implementation::unsubscribe()
{
  subscriber = nullptr;
}
//-------------------------------------------------------------------------------
void FrequencyInputWidget::Implementation::processValueChange()
{
  switch (unitInput->UnitIndex()) {
  case 0: //View value as celcius
    value = units::frequency::hertz_t(unitInput->Value());
    break;
  case 1: { //View value as Fahrenheit
    value = units::frequency::beats_per_minute_t(unitInput->Value());
  } break;
  default: //Debug case for if this class is patched but updateView has not been modified
  {
    assert(unitInput->UnitIndex() < 3);
    value = units::frequency::hertz_t(unitInput->Value());
  } break;
  }
  if (subscriber) {
    emit subscriber->valueChanged();
  }
}
//-------------------------------------------------------------------------------
void FrequencyInputWidget::Implementation::processViewChange()
{
  updateView();
}
//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
FrequencyInputWidget::Implementation& FrequencyInputWidget::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
FrequencyInputWidget::Implementation& FrequencyInputWidget::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
void FrequencyInputWidget::Implementation::updateView()
{
  auto current = value;
  switch (unitInput->UnitIndex()) {
  case 0: //View value as celcius
    unitInput->setRange(minimum(), maximum());
    unitInput->Value(current());
    break;
  case 1: { //View value as Fahrenheit
    units::frequency::beats_per_minute_t view{ current };
    units::frequency::beats_per_minute_t minF{ minimum };
    units::frequency::beats_per_minute_t maxF{ maximum };
    unitInput->setRange(minF(), maxF());
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
FrequencyInputWidget::FrequencyInputWidget(QWidget* parent)
  : _impl("Frequency", 0.0, parent)
{
  _impl->subscribe(this);
}
//-------------------------------------------------------------------------------
FrequencyInputWidget::FrequencyInputWidget(QString label, double value, QWidget* parent)
  : _impl(label, value, parent)
{
  _impl->subscribe(this);
}
//-------------------------------------------------------------------------------
FrequencyInputWidget::~FrequencyInputWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto FrequencyInputWidget::create(QString label, double value, QWidget* parent) -> FrequencyInputWidgetPtr
{
  auto widget = new FrequencyInputWidget(label, value, parent);
  return widget;
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto FrequencyInputWidget::create(QString label, units::frequency::hertz_t value, QWidget* parent) -> FrequencyInputWidgetPtr
{
  auto widget = new FrequencyInputWidget(label, value(), parent);
  return widget;
}
//-------------------------------------------------------------------------------
double FrequencyInputWidget::Value() const
{
  return _impl->value();
}
//-------------------------------------------------------------------------------
void FrequencyInputWidget::Value(units::frequency::hertz_t given)
{
  _impl->value = given;
  _impl->updateView();
}
//-------------------------------------------------------------------------------
QString FrequencyInputWidget::Label() const
{
  return _impl->unitInput->Label();
}
//-------------------------------------------------------------------------------
void FrequencyInputWidget::Label(const QString& given)
{
  _impl->unitInput->Label(given);
}
//-------------------------------------------------------------------------------
QString FrequencyInputWidget::ViewUnitText() const
{
  return _impl->unitInput->UnitText();
}
//-------------------------------------------------------------------------------
QWidget* FrequencyInputWidget::Widget()
{
  return _impl->unitInput;
}
//-------------------------------------------------------------------------------
void FrequencyInputWidget::setRange(double min, double max)
{
  _impl->minimum = units::frequency::hertz_t(min);
  _impl->maximum = units::frequency::hertz_t(max);
  _impl->updateView();
}
//-------------------------------------------------------------------------------
void FrequencyInputWidget::setSingleStep(double step)
{
  _impl->unitInput->setSingleStep(step);
}
//-------------------------------------------------------------------------------
}