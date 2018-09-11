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
//! \date   Sept 10th 2018
//!
//!
//! \brief A basic 3 field entry row for widgets label,spinbox,combo box to input different units in.
//!        This is a common widget for the type specific entries and does not auto convert between the entries on field change

#include "UnitInputWidget.h"
//External Includes
#include <QtWidgets>
#include <Units.h>
namespace biogears_ui {

struct UnitInputWidget::Implementation : public QObject {

public:
  Implementation(QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

public:
  QLabel* label = nullptr;
  QDoubleSpinBox* value = nullptr;
  QComboBox* units = nullptr;
};
//-------------------------------------------------------------------------------
UnitInputWidget::Implementation::Implementation(QWidget* parent)
  : label(new QLabel(tr("Uninitalized")))
  , value(new QDoubleSpinBox())
  , units(new QComboBox())
{
  auto layout = new QGridLayout;
  parent->setLayout(layout);
  parent->setSizePolicy(QSizePolicy::Minimum, QSizePolicy::Minimum);
  layout->setContentsMargins(0, 0, 0, 0);

  layout->addWidget(label, 0, 0);
  layout->addWidget(value, 0, 1);
  layout->addWidget(units, 0, 2);
  layout->setSizeConstraint(QLayout::SetMinimumSize);
  value->setDecimals(2);
}
//-------------------------------------------------------------------------------
UnitInputWidget::Implementation::Implementation(const Implementation& obj)

{
  *this = obj;
}
//-------------------------------------------------------------------------------
UnitInputWidget::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
UnitInputWidget::Implementation& UnitInputWidget::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
UnitInputWidget::Implementation& UnitInputWidget::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
UnitInputWidget::UnitInputWidget(QWidget* parent)
  : QWidget(parent)
  , _impl(this)
{
  connect(_impl->value, QOverload<double>::of(&QDoubleSpinBox::valueChanged), this, &UnitInputWidget::valueChanged);
  connect(_impl->units, QOverload<int>::of(&QComboBox::currentIndexChanged), this, &UnitInputWidget::unitChanged);
}
//-------------------------------------------------------------------------------
UnitInputWidget::~UnitInputWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto UnitInputWidget::create(QString label, double value, QString unit, QWidget* parent) -> UnitInputWidgetPtr
{
  auto widget = new UnitInputWidget(parent);
  widget->Label(label);
  widget->Value(value);
  widget->addUnit(unit);

  return widget;
}
//-------------------------------------------------------------------------------
double UnitInputWidget::Value() const
{
  return _impl->value->value();
}
//-------------------------------------------------------------------------------
void UnitInputWidget::Value(double given)
{
  _impl->value->setValue(given);
}
//-------------------------------------------------------------------------------
QString UnitInputWidget::Label() const
{
  return _impl->label->text();
}
//-------------------------------------------------------------------------------
void UnitInputWidget::Label(const QString& given)
{
  _impl->label->setText(given);
}
//-------------------------------------------------------------------------------
QString UnitInputWidget::UnitText() const
{
  return _impl->units->currentText();
}
//-------------------------------------------------------------------------------
int UnitInputWidget::UnitIndex() const
{
  return _impl->units->currentIndex();
}
//-------------------------------------------------------------------------------
void UnitInputWidget::addUnit(const QString& given)
{
  _impl->units->addItem(given);
}
//-------------------------------------------------------------------------------
void UnitInputWidget::setUnits(QStringList strings)
{
  _impl->units->clear();
  _impl->units->insertItems(0, strings);
}
//-------------------------------------------------------------------------------
void UnitInputWidget::setUnits(QStringList&& strings)
{
  _impl->units->clear();
  _impl->units->insertItems(0, std::move(strings));
}
//-------------------------------------------------------------------------------
void UnitInputWidget::setRange(double minimum, double maximum)
{
  _impl->value->setRange(minimum,maximum);
}
}