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

#include "EnvironmentConfigWidget.h"
//External Includes
#include <QtWidgets>

namespace biogears_ui {
struct AmbientGasWidget : QObject {
};

struct EnvironmentConfigWidget::Implementation : QObject {

public:
  Implementation(QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

public:
  QComboBox* f_surroundings = nullptr;
  QSpinBox* f_airVelocity = nullptr;
  QSpinBox* f_ambientTemp = nullptr;
  QSpinBox* f_atmoosphericPressure = nullptr;
  QSpinBox* f_clothing = nullptr;
  QSpinBox* f_surroundingEmissivity = nullptr;
  QSpinBox* f_meanradientTemp = nullptr;
  QSpinBox* f_relativeHumidity = nullptr;
  QSpinBox* f_resperationAmbientTemp = nullptr;

  QComboBox* f_airVelocity_unit = nullptr;
  QComboBox* f_ambientTemp_unit = nullptr;
  QComboBox* f_atmoosphericPressure_unit = nullptr;
  QComboBox* f_clothing_unit = nullptr;
  QComboBox* f_surroundingEmissivity_unit = nullptr;
  QComboBox* f_meanradientTemp_unit = nullptr;
  QComboBox* f_relativeHumidity_unit = nullptr;
  QComboBox* f_resperationAmbientTemp_unit = nullptr;

  QPushButton* b_addAmbientGas = nullptr;
  QVBoxLayout* gasses = nullptr;
};
//-------------------------------------------------------------------------------
EnvironmentConfigWidget::Implementation::Implementation(QWidget* parent)
  : f_surroundings(new QComboBox(parent))
  , f_airVelocity(new QSpinBox(parent))
  , f_ambientTemp(new QSpinBox(parent))
  , f_atmoosphericPressure(new QSpinBox(parent))
  , f_clothing(new QSpinBox(parent))
  , f_surroundingEmissivity(new QSpinBox(parent))
  , f_meanradientTemp(new QSpinBox(parent))
  , f_relativeHumidity(new QSpinBox(parent))
  , f_resperationAmbientTemp(new QSpinBox(parent))
  , f_airVelocity_unit(new QComboBox(parent))
  , f_ambientTemp_unit(new QComboBox(parent))
  , f_atmoosphericPressure_unit(new QComboBox(parent))
  , f_clothing_unit(new QComboBox(parent))
  , f_surroundingEmissivity_unit(new QComboBox(parent))
  , f_meanradientTemp_unit(new QComboBox(parent))
  , f_relativeHumidity_unit(new QComboBox(parent))
  , f_resperationAmbientTemp_unit(new QComboBox(parent))
  , b_addAmbientGas(new QPushButton(tr("Add"), parent))
  , gasses(new QVBoxLayout())
{
  QGridLayout* grid = new QGridLayout;
  parent->setLayout(grid);

  //Labels
  int row = 0, col = 0;
  grid->addWidget(new QLabel(tr("Surrounding Substance") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Air Velocity") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Ambient Temperature") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Clothing Resistance") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Atmospheric Pressure") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Clothing Resitance") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Emissivity") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Mean Radiant Temperature") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Resperation Ambient Temperature") + ":", parent), row++, col);
  grid->addWidget(new QLabel(tr("Ambient Gasses") + ":", parent), row, col);
  grid->addWidget(b_addAmbientGas, row, col+2);
  //Fields
  row = 0, ++col;
  grid->addWidget(f_surroundings, row++, col);
  grid->addWidget(f_airVelocity, row++, col);
  grid->addWidget(f_ambientTemp, row++, col);
  grid->addWidget(f_atmoosphericPressure, row++, col);
  grid->addWidget(f_clothing, row++, col);
  grid->addWidget(f_surroundingEmissivity, row++, col);
  grid->addWidget(f_meanradientTemp, row++, col);
  grid->addWidget(f_relativeHumidity, row++, col);
  grid->addWidget(f_resperationAmbientTemp, row, col);

  //Unit Fields
  row = 1, ++col;
  grid->addWidget(f_airVelocity_unit, row++, col);
  grid->addWidget(f_ambientTemp_unit, row++, col);
  grid->addWidget(f_atmoosphericPressure_unit, row++, col);
  grid->addWidget(f_clothing_unit, row++, col);
  grid->addWidget(f_surroundingEmissivity_unit, row++, col);
  grid->addWidget(f_meanradientTemp_unit, row++, col);
  grid->addWidget(f_relativeHumidity_unit, row++, col);
  grid->addWidget(f_resperationAmbientTemp_unit, row, col);

  f_surroundings->addItem("Air");
  f_surroundings->addItem("water");
  
  f_airVelocity_unit->addItem(tr("m/s"));
  f_airVelocity_unit->addItem(tr("km/h"));
  f_airVelocity_unit->addItem(tr("mph"));

  f_ambientTemp_unit->addItem(tr("C"));
  f_ambientTemp_unit->addItem(tr("K"));
  f_ambientTemp_unit->addItem(tr("F"));

  f_atmoosphericPressure_unit->addItem(tr("mmHg"));

  f_clothing_unit->addItem(tr("Clo"));
  f_clothing_unit->addItem(tr("R"));

  f_surroundingEmissivity_unit->addItem(tr("k"));

  f_meanradientTemp_unit->addItem(tr("C"));
  f_meanradientTemp_unit->addItem(tr("K"));
  f_meanradientTemp_unit->addItem(tr("F"));

  f_relativeHumidity_unit->addItem(tr("%"));

  f_resperationAmbientTemp_unit->addItem(tr("C"));
  f_resperationAmbientTemp_unit->addItem(tr("K"));
  f_resperationAmbientTemp_unit->addItem(tr("F"));
}
//-------------------------------------------------------------------------------
EnvironmentConfigWidget::Implementation::Implementation(const Implementation& obj)

{
  *this = obj;
}
//-------------------------------------------------------------------------------
EnvironmentConfigWidget::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
EnvironmentConfigWidget::Implementation& EnvironmentConfigWidget::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
EnvironmentConfigWidget::Implementation& EnvironmentConfigWidget::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
EnvironmentConfigWidget::EnvironmentConfigWidget(QWidget* parent)
  : QWidget(parent)
  , _impl(this)
{
}
//-------------------------------------------------------------------------------
EnvironmentConfigWidget::~EnvironmentConfigWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto EnvironmentConfigWidget::create(QWidget* parent) -> EnvironmentConfigWidgetPtr
{
  return new EnvironmentConfigWidget(parent);
}
}