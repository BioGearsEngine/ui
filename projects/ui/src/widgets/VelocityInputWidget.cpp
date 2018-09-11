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

#include "VelocityInputWidget.h"
//Standard Includes
#include <cassert>
//External Includes
#include <QtWidgets>
#include <units.h>

#include "UnitInputWidget.h"
namespace biogears_ui {

struct VelocityInputWidget::Implementation : public QObject {
public:
  Implementation(QString label, double value, QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  void updateView();
  void notify();

  void subscribe(VelocityInputWidget*);
  void unsubscribe();

public slots:
  void processValueChange();
  void processViewChange();

public:
  UnitInputWidget* unitInput = nullptr;
  units::velocity::kilometers_per_hour_t value;
  units::velocity::kilometers_per_hour_t minimum;
  units::velocity::kilometers_per_hour_t maximum;

  VelocityInputWidget* subscriber = nullptr;
};
//-------------------------------------------------------------------------------
VelocityInputWidget::Implementation::Implementation(::QString label, double value, ::QWidget* parent)
  : unitInput(UnitInputWidget::create(label, value, "km/h", parent))
  , value(value)
  , minimum(0.0)
  , maximum(500.0)
{
  unitInput->addUnit("m/s");
  unitInput->addUnit("mph");

  connect(unitInput, &UnitInputWidget::valueChanged, this, &Implementation::processValueChange);
  connect(unitInput, &UnitInputWidget::unitChanged, this, &Implementation::processViewChange);
}
//-------------------------------------------------------------------------------
VelocityInputWidget::Implementation::Implementation(const Implementation& obj)
{
  *this = obj;
}
//-------------------------------------------------------------------------------
VelocityInputWidget::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
void VelocityInputWidget::Implementation::subscribe(VelocityInputWidget* obj)
{
  subscriber = obj;
}
//-------------------------------------------------------------------------------
void VelocityInputWidget::Implementation::unsubscribe()
{
  subscriber = nullptr;
}
//-------------------------------------------------------------------------------
void VelocityInputWidget::Implementation::processValueChange()
{
  switch (unitInput->UnitIndex()) {
  case 0: //View value as km/h
    value = units::velocity::kilometers_per_hour_t(unitInput->Value());
    break;
  case 1: { //View value as m/s
    value = units::velocity::meters_per_second_t(unitInput->Value());
  } break;
  case 2: { //View value as mph
    value = units::velocity::miles_per_hour_t(unitInput->Value());
  } break;
  default: //Debug case for if this class is patched but updateView has not been modified
  {
    assert(unitInput->UnitIndex() < 3);
    value = units::velocity::kilometers_per_hour_t(unitInput->Value());
  } break;
  }
  if (subscriber) {
    emit subscriber->valueChanged();
  }
}
//-------------------------------------------------------------------------------
void VelocityInputWidget::Implementation::processViewChange()
{
  updateView();
}
//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
VelocityInputWidget::Implementation& VelocityInputWidget::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
VelocityInputWidget::Implementation& VelocityInputWidget::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
void VelocityInputWidget::Implementation::updateView()
{
  auto current = value;
  switch (unitInput->UnitIndex()) {
  case 0: //View value as km/h
    unitInput->setRange(minimum(), maximum());
    unitInput->Value(current());
    break;
  case 1: { //View value as m/s
    units::velocity::meters_per_second_t view{ current };
    units::velocity::meters_per_second_t min{ minimum };
    units::velocity::meters_per_second_t max{ maximum };
    unitInput->setRange(min(), max());
    unitInput->Value(view());
  } break;
  case 2: { //View value as mph
    units::velocity::miles_per_hour_t view{ current };
    units::velocity::miles_per_hour_t min{ minimum };
    units::velocity::miles_per_hour_t max{ maximum };
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
VelocityInputWidget::VelocityInputWidget(QWidget* parent)
  : _impl("Velocity", 0.0, parent)
{
  _impl->subscribe(this);
}
//-------------------------------------------------------------------------------
VelocityInputWidget::VelocityInputWidget(QString label, double value, QWidget* parent)
  : _impl(label, value, parent)
{
}
//-------------------------------------------------------------------------------
VelocityInputWidget::~VelocityInputWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto VelocityInputWidget::create(QString label, double value, QWidget* parent) -> VelocityInputWidgetPtr
{
  auto widget = new VelocityInputWidget(label, value, parent);
  return widget;
}
//-------------------------------------------------------------------------------
double VelocityInputWidget::Value() const
{
  return _impl->value();
}
//-------------------------------------------------------------------------------
void VelocityInputWidget::Value(units::velocity::kilometers_per_hour_t given)
{
  _impl->value = given;
  _impl->updateView();
}
//-------------------------------------------------------------------------------
QString VelocityInputWidget::Label() const
{
  return _impl->unitInput->Label();
}
//-------------------------------------------------------------------------------
void VelocityInputWidget::Label(const QString& given)
{
  _impl->unitInput->Label(given);
}
//-------------------------------------------------------------------------------
QString VelocityInputWidget::ViewUnitText() const
{
  return _impl->unitInput->UnitText();
}
//-------------------------------------------------------------------------------
QWidget* VelocityInputWidget::Widget()
{
  return _impl->unitInput;
}
//-------------------------------------------------------------------------------
void VelocityInputWidget::setRange(double min, double max)
{
  _impl->minimum = units::velocity::kilometers_per_hour_t(min);
  _impl->maximum = units::velocity::kilometers_per_hour_t(max);
  _impl->updateView();
}
//-------------------------------------------------------------------------------
void VelocityInputWidget::setSingleStep(double step)
{
  _impl->unitInput->setSingleStep(step);
}
//-------------------------------------------------------------------------------
}