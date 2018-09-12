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

#include "MassInputWidget.h"
//Standard Includes
#include <cassert>
//External Includes
#include <QtWidgets>
#include <units.h>

#include "UnitInputWidget.h"
namespace biogears_ui {

struct MassInputWidget::Implementation : public QObject {
public:
  Implementation(QString label, double value, QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  void updateView();
  void notify();

  void subscribe(MassInputWidget*);
  void unsubscribe();

public slots:
  void processValueChange();
  void processViewChange();

public:
  UnitInputWidget* unitInput = nullptr;
  units::mass::kilogram_t value;
  units::mass::kilogram_t minimum;
  units::mass::kilogram_t maximum;

  MassInputWidget* subscriber = nullptr;
};
//-------------------------------------------------------------------------------
MassInputWidget::Implementation::Implementation(::QString label, double value, ::QWidget* parent)
  : unitInput(UnitInputWidget::create(label, value, "kg", parent))
  , value(value)
  , minimum(0)
  , maximum(1000.)
{
  unitInput->addUnit("g");
  unitInput->addUnit("lbs");
  unitInput->addUnit("stones");

  unitInput->setPercision(3);
  unitInput->setSingleStep(.01);
  unitInput->setRange(minimum(), maximum());
  unitInput->Value(value);

  connect(unitInput, &UnitInputWidget::valueChanged, this, &Implementation::processValueChange);
  connect(unitInput, &UnitInputWidget::unitChanged, this, &Implementation::processViewChange);
}
//-------------------------------------------------------------------------------
MassInputWidget::Implementation::Implementation(const Implementation& obj)
{
  *this = obj;
}
//-------------------------------------------------------------------------------
MassInputWidget::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
void MassInputWidget::Implementation::subscribe(MassInputWidget* obj)
{
  subscriber = obj;
}
//-------------------------------------------------------------------------------
void MassInputWidget::Implementation::unsubscribe()
{
  subscriber = nullptr;
}
//-------------------------------------------------------------------------------
void MassInputWidget::Implementation::processValueChange()
{
  switch (unitInput->UnitIndex()) {
  case 0: //View value as kg
    value = units::mass::kilogram_t(unitInput->Value());
    break;
  case 1: { //View value as g
    value = units::mass::gram_t(unitInput->Value());
  } break;
  case 2: { //View value as lbs
    value = units::mass::pound_t(unitInput->Value());
  } break;
  case 3: { //View value as stone
    value = units::mass::stone_t(unitInput->Value());
  } break;
  default: //Debug case for if this class is patched but updateView has not been modified
  {
    assert(unitInput->UnitIndex() < 3);
    value = units::mass::kilogram_t(unitInput->Value());
  } break;
  }
  if (subscriber) {
    emit subscriber->valueChanged();
  }
}
//-------------------------------------------------------------------------------
void MassInputWidget::Implementation::processViewChange()
{
  updateView();
}
//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
MassInputWidget::Implementation& MassInputWidget::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
MassInputWidget::Implementation& MassInputWidget::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
void MassInputWidget::Implementation::updateView()
{
  auto current = value;
  switch (unitInput->UnitIndex()) {
  case 0: //View value as Seconds
    unitInput->setRange(minimum(), maximum());
    unitInput->Value(current());
    break;
  case 1: { //View value as Minutes
    units::mass::gram_t view{ current };
    units::mass::gram_t min{ minimum };
    units::mass::gram_t max{ maximum };
    unitInput->setRange(min(), max());
    unitInput->Value(view());
  } break;
  case 2: { //View value as Minutes
    units::mass::pound_t view{ current };
    units::mass::pound_t min{ minimum };
    units::mass::pound_t max{ maximum };
    unitInput->setRange(min(), max());
    unitInput->Value(view());
  } break;
  case 3: { //View value as Minutes
    units::mass::stone_t view{ current };
    units::mass::stone_t min{ minimum };
    units::mass::stone_t max{ maximum };
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
MassInputWidget::MassInputWidget(QWidget* parent)
  : _impl("Mass", 0.0, parent)
{
  _impl->subscribe(this);
}
//-------------------------------------------------------------------------------
MassInputWidget::MassInputWidget(QString label, double value, QWidget* parent)
  : _impl(label, value, parent)
{
}
//-------------------------------------------------------------------------------
MassInputWidget::~MassInputWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto MassInputWidget::create(QString label, double value, QWidget* parent) -> MassInputWidgetPtr
{
  auto widget = new MassInputWidget(label, value, parent);
  return widget;
}
//-------------------------------------------------------------------------------
auto MassInputWidget::create(QString label, units::mass::kilogram_t value, QWidget* parent) -> MassInputWidgetPtr
{
  auto widget = new MassInputWidget(label, value(), parent);
  return widget;
}
//-------------------------------------------------------------------------------
double MassInputWidget::Value() const
{
  return _impl->value();
}
//-------------------------------------------------------------------------------
void MassInputWidget::Value(units::mass::kilogram_t given)
{
  _impl->value = given;
  _impl->updateView();
}
//-------------------------------------------------------------------------------
QString MassInputWidget::Label() const
{
  return _impl->unitInput->Label();
}
//-------------------------------------------------------------------------------
void MassInputWidget::Label(const QString& given)
{
  _impl->unitInput->Label(given);
}
//-------------------------------------------------------------------------------
QString MassInputWidget::ViewUnitText() const
{
  return _impl->unitInput->UnitText();
}
//-------------------------------------------------------------------------------
QWidget* MassInputWidget::Widget()
{
  return _impl->unitInput;
}
//-------------------------------------------------------------------------------
void MassInputWidget::setRange(double min, double max)
{
  _impl->minimum = units::mass::kilogram_t(min);
  _impl->maximum = units::mass::kilogram_t(max);
  _impl->updateView();
}
//-------------------------------------------------------------------------------
void MassInputWidget::setSingleStep(double step)
{
  _impl->unitInput->setSingleStep(step);
}
//-------------------------------------------------------------------------------
}