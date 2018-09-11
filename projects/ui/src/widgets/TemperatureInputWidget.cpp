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

#include "TemperatureInputWidget.h"
//Standard Includes
#include <cassert>
//External Includes
#include <QtWidgets>
#include <units.h>

#include "UnitInputWidget.h"
namespace biogears_ui {

struct TemperatureInputWidget::Implementation : public QObject {
public:
  Implementation(QString label, double value, QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  void updateView();
  void notify();

  void subscribe(TemperatureInputWidget*);
  void unsubscribe();

public slots:
  void processValueChange();
  void processViewChange();

public:
  UnitInputWidget* unitInput = nullptr;
  units::temperature::celsius_t value;
  units::temperature::celsius_t minimum;
  units::temperature::celsius_t maximum;

  TemperatureInputWidget* subscriber = nullptr;
};
//-------------------------------------------------------------------------------
TemperatureInputWidget::Implementation::Implementation(::QString label, double value, ::QWidget* parent)
  : unitInput(UnitInputWidget::create(label, value, "C", parent))
  , value(0.0)
  ,minimum(-273.15)
  ,maximum(126.85)
{
  unitInput->addUnit("F");
  unitInput->addUnit("K");

  connect(unitInput, &UnitInputWidget::valueChanged, this, &Implementation::processValueChange);
  connect(unitInput, &UnitInputWidget::unitChanged, this, &Implementation::processViewChange);
}
//-------------------------------------------------------------------------------
TemperatureInputWidget::Implementation::Implementation(const Implementation& obj)
{
  *this = obj;
}
//-------------------------------------------------------------------------------
TemperatureInputWidget::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
void TemperatureInputWidget::Implementation::subscribe(TemperatureInputWidget* obj)
{
  subscriber = obj;
}
//-------------------------------------------------------------------------------
void TemperatureInputWidget::Implementation::unsubscribe()
{
  subscriber = nullptr;
}
//-------------------------------------------------------------------------------
void TemperatureInputWidget::Implementation::processValueChange()
{
  switch (unitInput->UnitIndex()) {
  case 0: //View value as celcius
    value = units::temperature::celsius_t(unitInput->Value());
    break;
  case 1: { //View value as Fahrenheit
    value = units::temperature::fahrenheit_t(unitInput->Value());
  } break;
  case 2: { //View value as Kelvin
    value = units::temperature::kelvin_t(unitInput->Value());
  } break;
  default: //Debug case for if this class is patched but updateView has not been modified
  {
    assert(unitInput->UnitIndex() < 3);
    value = units::temperature::celsius_t(unitInput->Value());
  } break;
  }
  if (subscriber) {
    emit subscriber->valueChanged();
  }
}
//-------------------------------------------------------------------------------
void TemperatureInputWidget::Implementation::processViewChange()
{
  updateView();
}
//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
TemperatureInputWidget::Implementation& TemperatureInputWidget::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
TemperatureInputWidget::Implementation& TemperatureInputWidget::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
void TemperatureInputWidget::Implementation::updateView()
{
  auto current = value;
  switch (unitInput->UnitIndex()) {
  case 0: //View value as celcius
    unitInput->setRange(minimum(), maximum());
    unitInput->Value(current());
    break;
  case 1: { //View value as Fahrenheit
    units::temperature::fahrenheit_t view{ current };
    units::temperature::fahrenheit_t minF{ minimum };
    units::temperature::fahrenheit_t maxF{ maximum };
    unitInput->setRange(minF(), maxF());
    unitInput->Value(view());
  } break;
  case 2: { //View value as Kelvin
    units::temperature::kelvin_t view{ current };
    units::temperature::kelvin_t minK{ minimum };
    units::temperature::kelvin_t maxK{ maximum };
    unitInput->setRange(minK(), maxK());
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
TemperatureInputWidget::TemperatureInputWidget(QWidget* parent)
  : _impl("Temperature", 0.0, parent)
{
  _impl->subscribe(this);
}
//-------------------------------------------------------------------------------
TemperatureInputWidget::TemperatureInputWidget(QString label, double value, QWidget* parent)
  : _impl(label, value, parent)
{
}
//-------------------------------------------------------------------------------
TemperatureInputWidget::~TemperatureInputWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto TemperatureInputWidget::create(QString label, double value, QWidget* parent) -> TemperatureInputWidgetPtr
{
  auto widget = new TemperatureInputWidget(label, value, parent);
  return widget;
}
//-------------------------------------------------------------------------------
double TemperatureInputWidget::Value() const
{
  return _impl->value();
}
//-------------------------------------------------------------------------------
void TemperatureInputWidget::Value(units::temperature::celsius_t given)
{
  _impl->value = given;
  _impl->updateView();
}
//-------------------------------------------------------------------------------
QString TemperatureInputWidget::Label() const
{
  return _impl->unitInput->Label();
}
//-------------------------------------------------------------------------------
void TemperatureInputWidget::Label(const QString& given)
{
  _impl->unitInput->Label(given);
}
//-------------------------------------------------------------------------------
QString TemperatureInputWidget::ViewUnitText() const
{
  return _impl->unitInput->UnitText();
}
//-------------------------------------------------------------------------------
QWidget* TemperatureInputWidget::Widget()
{
  return _impl->unitInput;
}
//-------------------------------------------------------------------------------
void TemperatureInputWidget::setRange(double min, double max)
{
  _impl->minimum = units::temperature::celsius_t(min);
  _impl->maximum = units::temperature::celsius_t(max);
  _impl->updateView();
}
}