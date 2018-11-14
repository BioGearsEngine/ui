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
//! \date   June 24th 2018
//!
//!
//! \brief Primary window of BioGears UI

#include "ScenarioConfigWidget.h"

//External Includes
#include <QTabWidget>
#include <QtWidgets>

#include <biogears/cdm/properties/SEScalarTime.h>
#include <biogears/cdm/properties/SEScalarTypes.h>
#include <biogears/cdm/scenario/SEAdvanceTime.h>
#include <biogears/cdm/system/environment/SEEnvironmentalConditions.h>
#include <biogears/cdm/system/environment/conditions/SEEnvironmentCondition.h>
#include <biogears/exports.h>

#include <units.h>
//Project Includes
#include "../phys/PhysiologyDriver.h"

#include "EnvironmentConfigWidget.h"
#include "MultiSelectionWidget.h"
#include "PatientConfigWidget.h"
#include "ScenarioToolbar.h"
#include "TimelineConfigWidget.h"

using namespace biogears;
namespace biogears_ui {
//-------------------------------------------------------------------------------
void ScenarioConfigWidget::handlePatientFileChange(int index)
{
  if (0 == index) {
    _driver->clearPatient();
  } else if (_scenario_toolbar->patientListSize() == index + 1) {
    loadPatient();
  } else if (1 == index) {
    _driver->clearPatient();
  } else {
    _driver->loadPatient(_scenario_toolbar->Patient());
  }
  populatePatientWidget();
}
//-------------------------------------------------------------------------------
void ScenarioConfigWidget::handleEnvironmentFileChange(int index)
{
  if (0 == index) {
    _driver->clearEnvironment();
  } else if (_scenario_toolbar->envrionmentListSize() == index + 1) {
    loadEnvironment();
  } else if (1 == index) {
    _driver->clearEnvironment();
    //New Environment;
  } else {
    _driver->loadEnvironment(_scenario_toolbar->Environment());
  }
  populateEnvironmentWidget();
}
//-------------------------------------------------------------------------------
void ScenarioConfigWidget::handleTimelineFileChange(int index)
{
  if (0 == index) {
    _driver->clearTimeline();
  } else if (_scenario_toolbar->timelineListSize() == index + 1) {
    loadTimeline();
  } else if (1 == index) {
    _driver->clearTimeline();
  } else {
    _driver->loadTimeline(_scenario_toolbar->Timeline());
  }
  populateTimelineWidget();
}

//-------------------------------------------------------------------------------
void ScenarioConfigWidget::handlePatientValueChange()
{
  SEPatient& patient = _driver->Patient();
  patient.SetName(_patient_widget->Name().toStdString());
  patient.SetGender((_patient_widget->Gender() == EGender::Male) ? CDM::enumSex::Male : CDM::enumSex::Female);
  patient.GetAge().SetValue(_patient_widget->Age(), TimeUnit::s);
  patient.GetWeight().SetValue(_patient_widget->Weight(), MassUnit::kg);
  patient.GetHeight().SetValue(_patient_widget->Height(), LengthUnit::m);
  patient.GetBodyFatFraction().SetValue(_patient_widget->BodyFatPercentage() / 100.0);
  patient.GetHeartRateBaseline().SetValue(_patient_widget->HeartRate(), FrequencyUnit::Hz);
  patient.GetRespirationRateBaseline().SetValue(_patient_widget->RespritoryRate(), FrequencyUnit::Hz);
  patient.GetDiastolicArterialPressureBaseline().SetValue(_patient_widget->DiastolicPressureBaseline(), PressureUnit::mmHg);
  patient.GetSystolicArterialPressureBaseline().SetValue(_patient_widget->SystolicPresureBaseline(), PressureUnit::mmHg);
}
//-------------------------------------------------------------------------------
void ScenarioConfigWidget::handleEnvironmentValueChange()
{
  SEEnvironment& environment = _driver->Environment();
  SEEnvironmentalConditions& conditions = environment.GetConditions();

  //Surrounding Type
  conditions.SetSurroundingType(_environment_widget->Surrondings() == ESurrondings::Air ? CDM::enumSurroundingType::Air
                                                                                        : CDM::enumSurroundingType::Air);
  conditions.GetAirVelocity().SetValue(_environment_widget->AirVelocity(), LengthPerTimeUnit::m_Per_s);
  conditions.GetAmbientTemperature().SetValue(_environment_widget->AmbientTemperature(), TemperatureUnit::C);
  conditions.GetAtmosphericPressure().SetValue(_environment_widget->AtmosphericPressure(), PressureUnit::mmHg);
  conditions.GetClothingResistance().SetValue(_environment_widget->ClothingResistance(), HeatResistanceAreaUnit::clo);
  conditions.GetEmissivity().SetValue(_environment_widget->SurroundingEmissivity(), NoUnit::unitless);
  conditions.GetMeanRadiantTemperature().SetValue(_environment_widget->MeanRadientTemperature(), TemperatureUnit::C);
  conditions.GetRelativeHumidity().SetValue(_environment_widget->RelativeHumidity(), NoUnit::unitless);
  conditions.GetRespirationAmbientTemperature().SetValue(_environment_widget->ResperationAmbientTemperature(), TemperatureUnit::C);
  //TODO:sawhite:SetAmbientGas
}
//-------------------------------------------------------------------------------
void ScenarioConfigWidget::populatePatientWidget()
{
  SEPatient& patient = _driver->Patient();

  bool oldState = _patient_widget->blockSignals(true);
  try {
    _patient_widget->Name(patient.GetName().c_str())
      .Gender((patient.GetGender() == CDM::enumSex::Male) ? EGender::Male : EGender::Female)
      .Age(units::time::year_t(patient.GetAge(TimeUnit::yr)))
      .Weight(units::mass::kilogram_t(patient.GetWeight().GetValue(MassUnit::kg)))
      .Height(units::length::meter_t(patient.GetHeight().GetValue(LengthUnit::m)))
      .BodyFatPercentage(patient.GetBodyFatFraction().GetValue() * 100.0)
      .HeartRate(units::frequency::hertz_t(patient.GetHeartRateBaseline().GetValue(FrequencyUnit::Hz)))
      .RespritoryRate(units::frequency::hertz_t(patient.GetRespirationRateBaseline().GetValue(FrequencyUnit::Hz)))
      .DiastolicPressureBaseline(units::pressure::milimeters_of_mercury_t(patient.GetDiastolicArterialPressureBaseline().GetValue(PressureUnit::mmHg)))
      .SystolicPresureBaseline(units::pressure::milimeters_of_mercury_t(patient.GetSystolicArterialPressureBaseline().GetValue(PressureUnit::mmHg)));
  } catch (std::exception e) {
    //TODO:Log Unable to load file
    //TODO:Red Notifcation Bannor on UI
  }
  _patient_widget->blockSignals(oldState);
}
//-------------------------------------------------------------------------------
void ScenarioConfigWidget::populateEnvironmentWidget()
{
  SEEnvironment& environment = _driver->Environment();
  SEEnvironmentalConditions& conditions = environment.GetConditions();

  //Surrounding Type
  bool oldState = _environment_widget->blockSignals(true);
  _environment_widget->Surrondings((conditions.GetSurroundingType() == CDM::enumSurroundingType::Air) ? ESurrondings::Air : ESurrondings::Water);
  _environment_widget->AirVelocity(units::velocity::meters_per_second_t(conditions.GetAirVelocity().GetValue(LengthPerTimeUnit::m_Per_s)));
  _environment_widget->AmbientTemperature(units::temperature::celsius_t(conditions.GetAmbientTemperature().GetValue(TemperatureUnit::C)));
  _environment_widget->AtmosphericPressure(units::pressure::milimeters_of_mercury_t(conditions.GetAtmosphericPressure().GetValue(PressureUnit::mmHg)));
  _environment_widget->ClothingResistance(units::insulation::clo_t(conditions.GetClothingResistance().GetValue(HeatResistanceAreaUnit::clo)));
  _environment_widget->SurroundingEmissivity(conditions.GetEmissivity().GetValue(NoUnit::unitless));
  _environment_widget->MeanRadientTemperature(units::temperature::celsius_t(conditions.GetMeanRadiantTemperature().GetValue(TemperatureUnit::C)));
  _environment_widget->RelativeHumidity(conditions.GetRelativeHumidity().GetValue(NoUnit::unitless));
  _environment_widget->ResperationAmbientTemperature(units::temperature::celsius_t(conditions.GetRespirationAmbientTemperature().GetValue(TemperatureUnit::C)));
  //TODO:sawhite:SetAmbientGas
  _environment_widget->blockSignals(oldState);
}
//-------------------------------------------------------------------------------
void ScenarioConfigWidget::populateTimelineWidget()
{
  auto actions = _driver->GetActions();
  double time = 0;
  std::string name;

  std::vector<ActionData> timeline;
  //for (auto action : actions) {
  //  name = action->classname();

  //  timeline.emplace_back(name, time);
  //  if (std::strcmp(action->classname(), biogears::SEAdvanceTime::TypeTag()) == 0) {
  //    auto delta = dynamic_cast<SEAdvanceTime*>(action);
  //    time += delta->GetTime().GetValue(TimeUnit::s);
  //  }
  //}
  _timeline_widget->Actions(timeline);
  _timeline_widget->ScenarioTime(time);
}
//-------------------------------------------------------------------------------
void ScenarioConfigWidget::handleTimelineValueChange()
{
}
//-------------------------------------------------------------------------------
void ScenarioConfigWidget::loadPatient()
{
  QString fileName = QFileDialog::getOpenFileName(nullptr,
    tr("Load Environment file"), ".", tr("Biogears Environment files (*.xml)"));
  _driver->loadPatient(fileName.toStdString());
}
//-------------------------------------------------------------------------------
void ScenarioConfigWidget::loadEnvironment()
{
  QString fileName = QFileDialog::getOpenFileName(nullptr,
    tr("Load Environment file"), ".", tr("Biogears Environment files (*.xml)"));
  _driver->loadEnvironment(fileName.toStdString());
}
//-------------------------------------------------------------------------------
void ScenarioConfigWidget::loadTimeline()
{
  QString fileName = QFileDialog::getOpenFileName(nullptr,
    tr("Load Environment file"), ".", tr("Biogears Environment files (*.xml)"));
  _driver->loadTimeline(fileName.toStdString());
}
//-------------------------------------------------------------------------------
ScenarioConfigWidget::ScenarioConfigWidget(QWidget* parent)
  : QWidget(parent)
  , _physiologySelection(MultiSelectionWidget::create(this))
  , _patient_widget(PatientConfigWidget::create(this))
  , _environment_widget(EnvironmentConfigWidget::create(this))
  , _timeline_widget(TimelineConfigWidget::create(this))
  , _scenario_toolbar(ScenarioToolbar::create())
{
  QTabWidget* tabs = new QTabWidget();

  tabs->addTab(_timeline_widget, "Timeline");
  tabs->addTab(_patient_widget, "Patient");
  tabs->addTab(_environment_widget, "Environment");
  tabs->addTab(_physiologySelection, "Outputs");
    
  QHBoxLayout* layout = new QHBoxLayout;
  setLayout(layout);
  layout->addWidget(tabs);


  connect(_patient_widget, &PatientConfigWidget::valueChanged, this, &ScenarioConfigWidget::handlePatientValueChange);
  connect(_environment_widget, &EnvironmentConfigWidget::valueChanged, this, &ScenarioConfigWidget::handleEnvironmentValueChange);
  connect(_timeline_widget, &TimelineConfigWidget::timeChanged, this, &ScenarioConfigWidget::handleTimelineValueChange);
}
//-------------------------------------------------------------------------------
ScenarioConfigWidget::~ScenarioConfigWidget()
{
}

//-------------------------------------------------------------------------------
auto ScenarioConfigWidget::create(QWidget* parent) -> ScenarioConfigWidgetPtr
{
  return new ScenarioConfigWidget(parent);
}
//-------------------------------------------------------------------------------
std::unique_ptr<PhysiologyDriver> ScenarioConfigWidget::getPhysiologyDriver()
{
  return std::move(_driver);
}
//-------------------------------------------------------------------------------
void  ScenarioConfigWidget::setPhysiologyDriver(std::unique_ptr<PhysiologyDriver>&& driver)
{
  _driver = std::move(driver);
}
//-------------------------------------------------------------------------------
ScenarioToolbar* ScenarioConfigWidget::getScenarioToolbar()
{
  return _scenario_toolbar;
}
}
