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

#include "LengthInputWidget.h"
//Standard Includes
#include <cassert>
//External Includes
#include <QtWidgets>
#include <units.h>

#include "UnitInputWidget.h"
namespace biogears_ui {

struct LengthInputWidget::Implementation : public QObject {
public:
  Implementation(QString label, double value, QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  void updateView();
  void notify();

  void subscribe(LengthInputWidget*);
  void unsubscribe();

public slots:
  void processValueChange();
  void processViewChange();

public:
  UnitInputWidget* unitInput = nullptr;
  units::length::meter_t value;
  units::length::meter_t minimum;
  units::length::meter_t maximum;

  LengthInputWidget* subscriber = nullptr;
};
//-------------------------------------------------------------------------------
LengthInputWidget::Implementation::Implementation(::QString label, double value, ::QWidget* parent)
  : unitInput(UnitInputWidget::create(label, value, "m", parent))
  , value(value)
  , minimum(0)
  , maximum(10.)
{
  unitInput->addUnit("inch");

  unitInput->setPercision(3);
  unitInput->setSingleStep(.01);
  unitInput->setRange(minimum(), maximum());
  unitInput->Value(value);

  connect(unitInput, &UnitInputWidget::valueChanged, this, &Implementation::processValueChange);
  connect(unitInput, &UnitInputWidget::unitChanged, this, &Implementation::processViewChange);
}
//-------------------------------------------------------------------------------
LengthInputWidget::Implementation::Implementation(const Implementation& obj)
{
  *this = obj;
}
//-------------------------------------------------------------------------------
LengthInputWidget::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
void LengthInputWidget::Implementation::subscribe(LengthInputWidget* obj)
{
  subscriber = obj;
}
//-------------------------------------------------------------------------------
void LengthInputWidget::Implementation::unsubscribe()
{
  subscriber = nullptr;
}
//-------------------------------------------------------------------------------
void LengthInputWidget::Implementation::processValueChange()
{
  switch (unitInput->UnitIndex()) {
  case 0: //View value as celcius
    value = units::length::meter_t(unitInput->Value());
    break;
  case 1: { //View value as Fahrenheit
    value = units::length::inch_t(unitInput->Value());
  } break;
  default: //Debug case for if this class is patched but updateView has not been modified
  {
    assert(unitInput->UnitIndex() < 3);
    value = units::length::meter_t(unitInput->Value());
  } break;
  }
  if (subscriber) {
    emit subscriber->valueChanged();
  }
}
//-------------------------------------------------------------------------------
void LengthInputWidget::Implementation::processViewChange()
{
  updateView();
}
//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
LengthInputWidget::Implementation& LengthInputWidget::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
LengthInputWidget::Implementation& LengthInputWidget::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
void LengthInputWidget::Implementation::updateView()
{
  auto current = value;
  switch (unitInput->UnitIndex()) {
  case 0: //View value as Seconds
    unitInput->setRange(minimum(), maximum());
    unitInput->Value(current());
    break;
  case 1: { //View value as Minutes
    units::length::inch_t view{ current };
    units::length::inch_t min{ minimum };
    units::length::inch_t max{ maximum };
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
LengthInputWidget::LengthInputWidget(QWidget* parent)
  : _impl("Length", 0.0, parent)
{
  _impl->subscribe(this);
}
//-------------------------------------------------------------------------------
LengthInputWidget::LengthInputWidget(QString label, double value, QWidget* parent)
  : _impl(label, value, parent)
{
  _impl->subscribe(this);
}
//-------------------------------------------------------------------------------
LengthInputWidget::~LengthInputWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto LengthInputWidget::create(QString label, double value, QWidget* parent) -> LengthInputWidgetPtr
{
  auto widget = new LengthInputWidget(label, value, parent);
  return widget;
}
//-------------------------------------------------------------------------------
double LengthInputWidget::Value() const
{
  return _impl->value();
}
//-------------------------------------------------------------------------------
void LengthInputWidget::Value(units::length::meter_t given)
{
  _impl->value = given;
  _impl->updateView();
}
//-------------------------------------------------------------------------------
QString LengthInputWidget::Label() const
{
  return _impl->unitInput->Label();
}
//-------------------------------------------------------------------------------
void LengthInputWidget::Label(const QString& given)
{
  _impl->unitInput->Label(given);
}
//-------------------------------------------------------------------------------
QString LengthInputWidget::ViewUnitText() const
{
  return _impl->unitInput->UnitText();
}
//-------------------------------------------------------------------------------
QWidget* LengthInputWidget::Widget()
{
  return _impl->unitInput;
}
//-------------------------------------------------------------------------------
void LengthInputWidget::setRange(double min, double max)
{
  _impl->minimum = units::length::meter_t(min);
  _impl->maximum = units::length::meter_t(max);
  _impl->updateView();
}
//-------------------------------------------------------------------------------
void LengthInputWidget::setSingleStep(double step)
{
  _impl->unitInput->setSingleStep(step);
}
//-------------------------------------------------------------------------------
}