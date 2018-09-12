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
  //createActions();
  //createStatusBar();
  //readSettings();
  //setUnifiedTitleAndToolBarOnMac(true);
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
}