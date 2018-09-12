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
#include <Units.h>
//Project Includes
#include "ThermalResistanceInputWidget.h"
#include "TemperatureInputWidget.h"
#include "UnitInputWidget.h"
#include "VelocityInputWidget.h"
#include "PressureInputWidget.h"
namespace biogears_ui {
struct AmbientGasWidget : public QObject {
};

struct EnvironmentConfigWidget::Implementation : public QObject {

public:
  Implementation(QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

public:
  QComboBox* f_surroundings = nullptr;
  VelocityInputWidget* airVelocity = nullptr;
  TemperatureInputWidget* ambientTemp = nullptr;
  PressureInputWidget* atmosphericPressure = nullptr;
  ThermalResistanceInputWidget* clothing = nullptr;
  UnitInputWidget* surroundingEmissivity = nullptr;
  TemperatureInputWidget* meanradientTemp = nullptr;
  UnitInputWidget* relativeHumidity = nullptr;
  TemperatureInputWidget* resperationAmbientTemp = nullptr;

  QPushButton* b_addAmbientGas = nullptr;
  QLabel* l_ambientGas = nullptr;
  QVBoxLayout* gasses = nullptr;
};
//-------------------------------------------------------------------------------
EnvironmentConfigWidget::Implementation::Implementation(QWidget* parent)
  : f_surroundings(new QComboBox(parent))
  , airVelocity(VelocityInputWidget::create(tr("Air Velocity"), 12.0, parent))
  , ambientTemp(TemperatureInputWidget::create(tr("Ambient Temperature"), 27.0, parent))
  , clothing(ThermalResistanceInputWidget::create(tr("Clothing Resitance"), 0.61 , parent))
  , atmosphericPressure(PressureInputWidget::create(tr("Atmospheric Pressure"), 760.0, parent))
  , surroundingEmissivity(UnitInputWidget::create(tr("Emissivity"), 0.0, "k", parent))
  , meanradientTemp(TemperatureInputWidget::create(tr("Mean Radient Temperature"), 25.0, parent))
  , relativeHumidity(UnitInputWidget::create(tr("Relative Humidity"), 0.0, "%", parent))
  , resperationAmbientTemp(TemperatureInputWidget::create(tr("Resperation Ambient Temperature"), 27.0, parent))
  , b_addAmbientGas(new QPushButton(tr("Add"), parent))
  , l_ambientGas(new QLabel(tr("Ambient Gases")))
  , gasses(new QVBoxLayout())
{

  f_surroundings->addItem("Air");
  f_surroundings->addItem("water");

  QGridLayout* grid = new QGridLayout;
  parent->setLayout(grid);

  //Labels
  int row = 0, col = 0;
  grid->setSpacing(0);
  grid->setVerticalSpacing(0);
  //grid->setContentsMargins(0, 0, 0, 0);
  parent->setSizePolicy(QSizePolicy::Fixed, QSizePolicy::Fixed);
  grid->addWidget(new QLabel(tr("Surrounding Substance") + ":", parent), row, col);
  grid->addWidget(f_surroundings, row++, col + 1);
  grid->addWidget(airVelocity->Widget(), row++, col, 1, 3);
  grid->addWidget(ambientTemp->Widget(), row++, col, 1, 3);
  grid->addWidget(clothing->Widget(), row++, col, 1, 3);
  grid->addWidget(atmosphericPressure->Widget(), row++, col, 1, 3);
  grid->addWidget(surroundingEmissivity, row++, col, 1, 3);
  grid->addWidget(meanradientTemp->Widget(), row++, col, 1, 3);
  grid->addWidget(relativeHumidity, row++, col, 1, 3);
  grid->addWidget(resperationAmbientTemp->Widget(), row++, col, 1, 3);
  grid->addWidget(l_ambientGas, row, col);
  grid->addWidget(b_addAmbientGas, row, col + 2);
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