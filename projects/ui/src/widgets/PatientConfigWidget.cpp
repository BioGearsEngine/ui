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

namespace biogears_ui {

struct PatientConfigWidget::Implementation : QObject {

public:
  Implementation(QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

public:
  QLineEdit* f_name = nullptr;
  QComboBox* f_gender = nullptr;
  QSpinBox* f_age = nullptr;
  QSpinBox* f_height = nullptr;
  QSpinBox* f_bodyFat = nullptr;
  QSpinBox* f_heartRate = nullptr;
  QSpinBox* f_respritoryRate = nullptr;
  QSpinBox* f_diastolic = nullptr;
  QSpinBox* f_systolic = nullptr;

  QComboBox* f_age_unit = nullptr;
  QComboBox* f_height_unit = nullptr;
  QComboBox* f_bodyFat_unit = nullptr;
  QComboBox* f_heartRate_unit = nullptr;
  QComboBox* f_respritoryRate_unit = nullptr;
  QComboBox* f_diastolic_unit = nullptr;
  QComboBox* f_systolic_unit = nullptr;
};
//-------------------------------------------------------------------------------
PatientConfigWidget::Implementation::Implementation(QWidget* parent)
  : f_name(new QLineEdit(parent))
  , f_gender(new QComboBox(parent))
  , f_age(new QSpinBox(parent))
  , f_height(new QSpinBox(parent))
  , f_bodyFat(new QSpinBox(parent))
  , f_heartRate(new QSpinBox(parent))
  , f_respritoryRate(new QSpinBox(parent))
  , f_diastolic(new QSpinBox(parent))
  , f_systolic(new QSpinBox(parent))
  , f_age_unit(new QComboBox(parent))
  , f_height_unit(new QComboBox())
  , f_bodyFat_unit(new QComboBox(parent))
  , f_heartRate_unit(new QComboBox(parent))
  , f_respritoryRate_unit(new QComboBox(parent))
  , f_diastolic_unit(new QComboBox(parent))
  , f_systolic_unit(new QComboBox(parent))

{
  QGridLayout* grid = new QGridLayout;
  parent->setLayout(grid);

  //Labels
  int row = 0, col = 0;
  grid->addWidget(new QLabel(tr("Name") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Gender") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Age") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Height") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Body Fat") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Heart Rate") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Respritory Rate") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Disatolic Pressure") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Ststolic Pressure") + ":", parent), row, col);
  //Fields
  row = 0, ++col;
  grid->addWidget(f_name, row++, col);
  grid->addWidget(f_gender, row++, col);
  grid->addWidget(f_age, row++, col);
  grid->addWidget(f_height, row++, col);
  grid->addWidget(f_bodyFat, row++, col);
  grid->addWidget(f_heartRate, row++, col);
  grid->addWidget(f_respritoryRate, row++, col);
  grid->addWidget(f_diastolic, row++, col);
  grid->addWidget(f_systolic, row, col);
  //Unit Fields
  row = 2, ++col;
  grid->addWidget(f_age_unit, row++, col);
  grid->addWidget(f_height_unit, row++, col);
  grid->addWidget(f_bodyFat_unit, row++, col);
  grid->addWidget(f_heartRate_unit, row++, col);
  grid->addWidget(f_respritoryRate_unit, row++, col);
  grid->addWidget(f_diastolic_unit, row++, col);
  grid->addWidget(f_systolic_unit, row, col);

  f_gender->addItem(tr("Male"));
  f_gender->addItem(tr("Female"));

  f_age_unit->addItem(tr("Years"));
  f_age_unit->addItem(tr("Months"));
  f_age_unit->addItem(tr("Seconds"));
  f_age_unit->addItem(tr("Microfortnight"));

  f_height_unit->addItem(tr("cm"));
  f_height_unit->addItem(tr("in"));
  f_height_unit->addItem(tr("16th inches"));

  f_bodyFat_unit->addItem(tr("%"));

  f_heartRate_unit->addItem(tr("bpm"));
  f_heartRate_unit->addItem(tr("hz"));

  f_respritoryRate_unit->addItem(tr("bpm"));
  f_respritoryRate_unit->addItem(tr("hz"));

  
  f_diastolic_unit->addItem(tr("mmHg"));
  f_systolic_unit->addItem(tr("mmHg"));

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