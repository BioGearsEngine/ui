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
//! \date   August 30th 2018
//!
//!
//! \brief Primary window of BioGears UI

#include "PatientConfigWidget.h"
//External Includes
#include <QtWidgets>
//Project Inclcudes
#include "DurationInputWidget.h"
#include "FrequencyInputWidget.h"
#include "LengthInputWidget.h"
#include "PressureInputWidget.h"
#include "UnitInputWidget.h"
#include "MassInputWidget.h"
namespace biogears_ui {

struct PatientConfigWidget::Implementation : public QObject {

public:
  Implementation(QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

public:
  QLineEdit* f_name = nullptr;
  QComboBox* f_gender = nullptr;
  DurationInputWidget* f_age = nullptr;
  MassInputWidget* f_weight = nullptr;
  LengthInputWidget* f_height = nullptr;
  UnitInputWidget* f_bodyFat = nullptr;
  FrequencyInputWidget* f_heartRate = nullptr;
  FrequencyInputWidget* f_respritoryRate = nullptr;
  PressureInputWidget* f_diastolic = nullptr;
  PressureInputWidget* f_systolic = nullptr;

};
//-------------------------------------------------------------------------------
PatientConfigWidget::Implementation::Implementation(QWidget* parent)
  : f_name(new QLineEdit(parent))
  , f_gender(new QComboBox(parent))
  , f_age(DurationInputWidget::create(tr("Age"), units::time::year_t(27), parent))
  , f_weight(MassInputWidget::create(tr("Weight"), units::mass::pound_t(160), parent))
  , f_height(LengthInputWidget::create(tr("Height"), 1.65, parent))
  , f_bodyFat(UnitInputWidget::create(tr("Body Fat"), 0.0, "%", parent))
  , f_heartRate(FrequencyInputWidget::create(tr("Heart Rate"), units::frequency::beats_per_minute_t(60), parent))
  , f_respritoryRate(FrequencyInputWidget::create(tr("Respitory Rate"), units::frequency::beats_per_minute_t(12), parent))
  , f_diastolic(PressureInputWidget::create(tr("Disatolic Pressure"), 120, parent))
  , f_systolic(PressureInputWidget::create(tr("Ststolic Pressure"), 80, parent))
{
  QGridLayout* grid = new QGridLayout;
  parent->setLayout(grid);
  //Labels
  int row = 0, col = 0;

  parent->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
  grid->addWidget(new QLabel(tr("Name") + ":", parent), row, col);
  grid->addWidget(f_name, row++, col+1);
  grid->addWidget(new QLabel(tr("Gender") + ":", parent), row, col);
  grid->addWidget(f_gender, row++, col+1);
  grid->addWidget(f_age->Widget(), row++, col, 1, 3);
  grid->addWidget(f_height->Widget(), row++, col, 1, 3);
  grid->addWidget(f_weight->Widget(), row++, col, 1, 3);
  grid->addWidget(f_bodyFat,row++,col,1,3);
  grid->addWidget(f_heartRate->Widget(), row++, col,1,3);
  grid->addWidget(f_respritoryRate->Widget(), row++, col, 1, 3);
  grid->addWidget(f_diastolic->Widget(), row++, col, 1, 3);
  grid->addWidget(f_systolic->Widget(), row, col, 1, 3);
   
  f_gender->addItem(tr("Male"));
  f_gender->addItem(tr("Female"));

  f_age->setUnitView(Duration::Years);
}
//-------------------------------------------------------------------------------
PatientConfigWidget::Implementation::Implementation(const Implementation& obj)

{
  *this = obj;
}
//-------------------------------------------------------------------------------
PatientConfigWidget::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
PatientConfigWidget::Implementation& PatientConfigWidget::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
PatientConfigWidget::Implementation& PatientConfigWidget::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
PatientConfigWidget::PatientConfigWidget(QWidget* parent)
  : QWidget(parent)
  , _impl(this)
{
  Implementation& implementation = *_impl.get();
  connect(implementation.f_name, &QLineEdit::textChanged, this, &PatientConfigWidget::valueChanged);
  connect(implementation.f_gender, QOverload<int>::of(&QComboBox::currentIndexChanged), this, &PatientConfigWidget::valueChanged);
  connect(implementation.f_age, &DurationInputWidget::valueChanged, this, &PatientConfigWidget::valueChanged);
  connect(implementation.f_weight, &MassInputWidget::valueChanged, this, &PatientConfigWidget::valueChanged);
  connect(implementation.f_height, &LengthInputWidget::valueChanged, this, &PatientConfigWidget::valueChanged);
  connect(implementation.f_bodyFat, &UnitInputWidget::valueChanged, this, &PatientConfigWidget::valueChanged);
  connect(implementation.f_heartRate, &FrequencyInputWidget::valueChanged, this, &PatientConfigWidget::valueChanged);
  connect(implementation.f_respritoryRate, &FrequencyInputWidget::valueChanged, this, &PatientConfigWidget::valueChanged);
  connect(implementation.f_diastolic, &PressureInputWidget::valueChanged, this, &PatientConfigWidget::valueChanged);
  connect(implementation.f_systolic, &PressureInputWidget::valueChanged, this, &PatientConfigWidget::valueChanged);
}
//-------------------------------------------------------------------------------
PatientConfigWidget::~PatientConfigWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto PatientConfigWidget::create(QWidget* parent) -> PatientConfigWidgetPtr
{
  return new PatientConfigWidget(parent);
}
//-------------------------------------------------------------------------------
QString PatientConfigWidget::Name() const
{
  return _impl->f_name->text();
}
//-------------------------------------------------------------------------------
EGender PatientConfigWidget::Gender() const
{
  return (0 == _impl->f_gender->currentIndex()) ? EGender::Male : EGender::Female;
}
//-------------------------------------------------------------------------------
double PatientConfigWidget::Age() const
{
  return _impl->f_age->Value();
}
//-------------------------------------------------------------------------------
double PatientConfigWidget::Weight() const
{
  return _impl->f_weight->Value();
}
//-------------------------------------------------------------------------------
double PatientConfigWidget::Height() const
{
  return _impl->f_height->Value();
}
//-------------------------------------------------------------------------------
double PatientConfigWidget::BodyFatPercentage() const
{
  return _impl->f_bodyFat->Value();
}
//-------------------------------------------------------------------------------
double PatientConfigWidget::HeartRate() const
{
  return _impl->f_heartRate->Value();
}
//-------------------------------------------------------------------------------
double PatientConfigWidget::RespritoryRate() const
{
  return _impl->f_respritoryRate->Value();
}
//-------------------------------------------------------------------------------
double PatientConfigWidget::DiastolicPressureBaseline() const
{
  return _impl->f_systolic->Value();
}
//-------------------------------------------------------------------------------
double PatientConfigWidget::SystolicPresureBaseline() const
{
  return _impl->f_systolic->Value();
}
//-------------------------------------------------------------------------------
PatientConfigWidget& PatientConfigWidget::Name(QString value)
{
  _impl->f_name->setText(value);
  return *this;
}
//-------------------------------------------------------------------------------

PatientConfigWidget& PatientConfigWidget::Gender(EGender value)
{
  (0 == _impl->f_gender->currentIndex()) ? EGender::Male : EGender::Female;
  return *this;
}
//-------------------------------------------------------------------------------

PatientConfigWidget& PatientConfigWidget::Age(units::time::year_t value)
{
  _impl->f_age->Value(value);
  return *this;
}
//-------------------------------------------------------------------------------

PatientConfigWidget& PatientConfigWidget::Weight(units::mass::kilogram_t value)
{
  _impl->f_weight->Value(value);
  return *this;
}
//-------------------------------------------------------------------------------

PatientConfigWidget& PatientConfigWidget::Height(units::length::meter_t value)
{
  _impl->f_height->Value(value);
  return *this;
}
//-------------------------------------------------------------------------------

PatientConfigWidget& PatientConfigWidget::BodyFatPercentage(double value)
{
  _impl->f_bodyFat->Value(value);
  return *this;
}
//-------------------------------------------------------------------------------

PatientConfigWidget& PatientConfigWidget::HeartRate(units::frequency::hertz_t value)
{
  _impl->f_heartRate->Value(value);
  return *this;
}
//-------------------------------------------------------------------------------

PatientConfigWidget& PatientConfigWidget::RespritoryRate(units::frequency::hertz_t value)
{
  _impl->f_respritoryRate->Value(value);
  return *this;
}
//-------------------------------------------------------------------------------

PatientConfigWidget& PatientConfigWidget::DiastolicPressureBaseline(units::pressure::milimeters_of_mercury_t value)
{
  _impl->f_diastolic->Value(value);
  return *this;
}
//-------------------------------------------------------------------------------

PatientConfigWidget& PatientConfigWidget::SystolicPresureBaseline(units::pressure::milimeters_of_mercury_t value)
{
  _impl->f_systolic->Value(value);
  return *this;
}
//-------------------------------------------------------------------------------
}