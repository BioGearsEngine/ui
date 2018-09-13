#ifndef BIOGEARSUI_WIDGETS_SIMULATION_ENVIRONMENT_CONFIG_WIDGET_H
#define BIOGEARSUI_WIDGETS_SIMULATION_ENVIRONMENT_CONFIG_WIDGET_H

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

//External Includes
#include <QToolBar>
//Project Includes
#include <biogears/framework/unique_propagate_const.h>
#include <biogears/math/units.h>

namespace biogears_ui {

struct AmbientGas {
  std::string name;
  double fraction;
};

enum class ESurrondings { Air,  Water };
class EnvironmentConfigWidget : public QWidget {
  Q_OBJECT
public:
  EnvironmentConfigWidget(QWidget* parent = nullptr);
  ~EnvironmentConfigWidget();

  using EnvironmentConfigWidgetPtr = EnvironmentConfigWidget*;

  static auto create(QWidget* parent = nullptr) -> EnvironmentConfigWidgetPtr;

  ESurrondings Surrondings() const;
  double AirVelocity() const;
  double AmbientTemperature() const;
  double ClothingResistance() const;
  double AtmosphericPressure() const;
  double SurroundingEmissivity() const;
  double MeanRadientTemperature() const;
  double RelativeHumidity() const;
  double ResperationAmbientTemperature() const;
  std::vector<AmbientGas> AmbientGasses() const;

  EnvironmentConfigWidget& Surrondings(ESurrondings);
  EnvironmentConfigWidget& AirVelocity( units::velocity::meters_per_second_t);
  EnvironmentConfigWidget& AmbientTemperature( units::temperature::celsius_t);
  EnvironmentConfigWidget& ClothingResistance(units::insulation::clo_t);
  EnvironmentConfigWidget& AtmosphericPressure( units::pressure::milimeters_of_mercury_t);
  EnvironmentConfigWidget& SurroundingEmissivity( double );
  EnvironmentConfigWidget& MeanRadientTemperature( units::temperature::celsius_t);
  EnvironmentConfigWidget& RelativeHumidity( double);
  EnvironmentConfigWidget& ResperationAmbientTemperature(units::temperature::celsius_t );
  EnvironmentConfigWidget& AmbientGasses( std::vector<AmbientGas>&& );

signals:
  void valueChanged();

private:
  struct Implementation;
  biogears::unique_propagate_const<Implementation> _impl;
};
}

#endif //BIOGEARSUI_WIDGETS_SIMULATION_ENVIRONMENT_CONFIG_WIDGET_H