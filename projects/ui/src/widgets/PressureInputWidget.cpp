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

#include "PressureInputWidget.h"
//Standard Includes
#include <cassert>
//External Includes
#include <QtWidgets>
#include <units.h>

#include "UnitInputWidget.h"
#include "ThermalResistanceInputWidget.h"

namespace biogears_ui {

struct PressureInputWidget::Implementation : public QObject {
public:
  Implementation(QString label, double value, QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  void updateView();
  void notify();

  void subscribe(PressureInputWidget*);
  void unsubscribe();

public slots:
  void processValueChange();
  void processViewChange();

public:
  UnitInputWidget* unitInput = nullptr;
  units::pressure::milimeters_of_mercury_t value;
  units::pressure::milimeters_of_mercury_t minimum;
  units::pressure::milimeters_of_mercury_t maximum;

  PressureInputWidget* subscriber = nullptr;
};
//-------------------------------------------------------------------------------
PressureInputWidget::Implementation::Implementation(::QString label, double value, ::QWidget* parent)
  : unitInput(UnitInputWidget::create(label, value, "mmHg", parent))
  , value(value)
  , minimum(0.0)
  , maximum(1000.0)
{
  unitInput->addUnit("inHg");
  unitInput->addUnit("bar");
  unitInput->addUnit("atm");
  unitInput->setSingleStep(0.01);
  unitInput->setRange(minimum(), maximum());
  unitInput->Value(value);

  connect(unitInput, &UnitInputWidget::valueChanged, this, &Implementation::processValueChange);
  connect(unitInput, &UnitInputWidget::unitChanged, this, &Implementation::processViewChange);
}
//-------------------------------------------------------------------------------
PressureInputWidget::Implementation::Implementation(const Implementation& obj)
{
  *this = obj;
}
//-------------------------------------------------------------------------------
PressureInputWidget::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
void PressureInputWidget::Implementation::subscribe(PressureInputWidget* obj)
{
  subscriber = obj;
}
//-------------------------------------------------------------------------------
void PressureInputWidget::Implementation::unsubscribe()
{
  subscriber = nullptr;
}
//-------------------------------------------------------------------------------
void PressureInputWidget::Implementation::processValueChange()
{
  switch (unitInput->UnitIndex()) {
  case 0: //View value as mmHG
    value = units::pressure::milimeters_of_mercury_t(unitInput->Value());
    break;
  case 1: { //View value as inHG
    value = units::pressure::inches_of_mercury_t(unitInput->Value());
  } break;
  case 2: { //View value as bar
    value = units::pressure::bar_t(unitInput->Value());
  } break;
  case 3: { //View value as atm
    value = units::pressure::atmosphere_t(unitInput->Value());
  } break;
    {
      assert(unitInput->UnitIndex() < 3);
      value = units::pressure::milimeters_of_mercury_t(unitInput->Value());
    }
    break;
  }
  if (subscriber) {
    emit subscriber->valueChanged();
  }
}
//-------------------------------------------------------------------------------
void PressureInputWidget::Implementation::processViewChange()
{
  updateView();
}
//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
PressureInputWidget::Implementation& PressureInputWidget::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
PressureInputWidget::Implementation& PressureInputWidget::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
void PressureInputWidget::Implementation::updateView()
{
  auto current = value;
  switch (unitInput->UnitIndex()) {
  case 0: //View value as mmHG
    unitInput->setRange(minimum(), maximum());
    unitInput->Value(current());
    break;
  case 1: { //View value as inHG
    units::pressure::inches_of_mercury_t view{ current };
    units::pressure::inches_of_mercury_t min{ minimum };
    units::pressure::inches_of_mercury_t max{ maximum };
    unitInput->setRange(min(), max());
    unitInput->Value(view());
  } break;
  case 2: { //View value as bar
    units::pressure::bar_t view{ current };
    units::pressure::bar_t min{ minimum };
    units::pressure::bar_t max{ maximum };
    unitInput->setRange(min(), max());
    unitInput->Value(view());
  } break;
  case 3: { //View value as atm
    units::pressure::atmosphere_t view{ current };
    units::pressure::atmosphere_t min{ minimum };
    units::pressure::atmosphere_t max{ maximum };
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
PressureInputWidget::PressureInputWidget(QWidget* parent)
  : _impl("Pressure", 0.0, parent)
{
  _impl->subscribe(this);
}
//-------------------------------------------------------------------------------
PressureInputWidget::PressureInputWidget(QString label, double value, QWidget* parent)
  : _impl(label, value, parent)
{
  _impl->subscribe(this);
}
//-------------------------------------------------------------------------------
PressureInputWidget::~PressureInputWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto PressureInputWidget::create(QString label, double value, QWidget* parent) -> PressureInputWidgetPtr
{
  auto widget = new PressureInputWidget(label, value, parent);
  return widget;
}
//-------------------------------------------------------------------------------
double PressureInputWidget::Value() const
{
  return _impl->value();
}
//-------------------------------------------------------------------------------
void PressureInputWidget::Value(units::pressure::milimeters_of_mercury_t given)
{
  _impl->value = given;
  _impl->updateView();
}
//-------------------------------------------------------------------------------
QString PressureInputWidget::Label() const
{
  return _impl->unitInput->Label();
}
//-------------------------------------------------------------------------------
void PressureInputWidget::Label(const QString& given)
{
  _impl->unitInput->Label(given);
}
//-------------------------------------------------------------------------------
QString PressureInputWidget::ViewUnitText() const
{
  return _impl->unitInput->UnitText();
}
//-------------------------------------------------------------------------------
QWidget* PressureInputWidget::Widget()
{
  return _impl->unitInput;
}
//-------------------------------------------------------------------------------
void PressureInputWidget::setRange(double min, double max)
{
  _impl->minimum = units::pressure::milimeters_of_mercury_t(min);
  _impl->maximum = units::pressure::milimeters_of_mercury_t(max);
  _impl->updateView();
}
//-------------------------------------------------------------------------------
void PressureInputWidget::setSingleStep(double step)
{
  _impl->unitInput->setSingleStep(step);
}
//-------------------------------------------------------------------------------
}
