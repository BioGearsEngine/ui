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

#include "MainWindow.h"
//Standard Includes
#include <iostream>
//External Includes
#include <QTabWidget>
#include <QtWidgets>
#include <biogears/cdm/properties/SEScalars.h>
#include <biogears/cdm/system/environment/SEEnvironmentalConditions.h>
#include <biogears/cdm/system/environment/conditions/SEEnvironmentCondition.h>
#include <biogears/string-exports.h>
#include <units.h>
//Project Includes
#include "../phys/PhysiologyDriver.h"
#include "EnvironmentConfigWidget.h"
#include "MultiSelectionWidget.h"
#include "PatientConfigWidget.h"
#include "ScenarioToolbar.h"
#include "TimelineConfigWidget.h"

namespace biogears_ui {

struct MainWindow::Implementation : public QObject {
public: //Functions
  Implementation(QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

public slots: //QT5 Slots >(
  void handlePatientFileChange(int index);
  void handleEnvironmentFileChange(int index);
  void handleTimelineFileChange(int index);
  void handlePatientValueChange();
  void handleEnvironmentValueChange();
  void handleTimelineValueChange();
  void loadPatient();
  void loadEnvironment();
  void loadTimeline();

  void populatePatientWidget();
  void populateEnvironmentWidget();
  void populateTimelineWidget();

public: //Data
  std::vector<PhysiologyDriver> drivers;

  MultiSelectionWidget* physiologySelection = nullptr;
  ScenarioToolbar* runToolbar = nullptr;
  PatientConfigWidget* patient_widget = nullptr;
  EnvironmentConfigWidget* environment_widget = nullptr;
  TimelineConfigWidget* timeline_widget = nullptr;
};
//-------------------------------------------------------------------------------
MainWindow::Implementation::Implementation(QWidget* parent)
  : physiologySelection(MultiSelectionWidget::create(parent))
  , runToolbar(ScenarioToolbar::create(parent))
  , patient_widget(PatientConfigWidget::create(parent))
  , environment_widget(EnvironmentConfigWidget::create(parent))
  , timeline_widget(TimelineConfigWidget::create(parent))
{
  PhysiologyDriver driver("BiogearsGUI");
  drivers.push_back(std::move(driver));
}
//-------------------------------------------------------------------------------
MainWindow::Implementation::Implementation(const Implementation& obj)
{
  *this = obj;
}
//-------------------------------------------------------------------------------
MainWindow::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
MainWindow::Implementation& MainWindow::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
MainWindow::Implementation& MainWindow::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::handlePatientFileChange(int index)
{
  if (0 == index) {
    drivers[0].clearPatient();
  } else if (runToolbar->patientListSize() == index + 1) {
    loadPatient();
  } else if (1 == index) {
    drivers[0].clearPatient();
  } else {
    drivers[0].loadPatient(runToolbar->Patient());
  }
  populatePatientWidget();
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::handleEnvironmentFileChange(int index)
{
  if (0 == index) {
    drivers[0].clearEnvironment();
  } else if (runToolbar->envrionmentListSize() == index + 1) {
    loadEnvironment();
  } else if (1 == index) {
    drivers[0].clearEnvironment();
    //New Environment;
  } else {
    drivers[0].loadEnvironment(runToolbar->Environment());
  }
  populateEnvironmentWidget();
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::handleTimelineFileChange(int index)
{
  if (0 == index) {
    drivers[0].clearTimeline();
  } else if (runToolbar->timelineListSize() == index + 1) {
    loadTimeline();
  } else if (1 == index) {
    drivers[0].clearTimeline();
  } else {
    drivers[0].loadTimeline(runToolbar->Timeline());
  }
  populateTimelineWidget();
}

//-------------------------------------------------------------------------------
void MainWindow::Implementation::handlePatientValueChange()
{
  SEPatient& patient = drivers[0].Patient();
  patient.SetName(patient_widget->Name().toStdString());
  patient.SetGender((patient_widget->Gender() == EGender::Male) ? CDM::enumSex::Male : CDM::enumSex::Female);
  patient.GetAge().SetValue(patient_widget->Age(), TimeUnit::s);
  patient.GetWeight().SetValue(patient_widget->Weight(), MassUnit::kg);
  patient.GetHeight().SetValue(patient_widget->Height(), LengthUnit::m);
  patient.GetBodyFatFraction().SetValue(patient_widget->BodyFatPercentage() / 100.0);
  patient.GetHeartRateBaseline().SetValue(patient_widget->HeartRate(), FrequencyUnit::Hz);
  patient.GetRespirationRateBaseline().SetValue(patient_widget->RespritoryRate(), FrequencyUnit::Hz);
  patient.GetDiastolicArterialPressureBaseline().SetValue(patient_widget->DiastolicPressureBaseline(), PressureUnit::mmHg);
  patient.GetSystolicArterialPressureBaseline().SetValue(patient_widget->SystolicPresureBaseline(), PressureUnit::mmHg);
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::handleEnvironmentValueChange()
{
  SEEnvironment& environment = drivers[0].Environment();
  SEEnvironmentalConditions& conditions = environment.GetConditions();

  //Surrounding Type
  conditions.SetSurroundingType(environment_widget->Surrondings() == ESurrondings::Air ? CDM::enumSurroundingType::Air
                                                                                       : CDM::enumSurroundingType::Air);
  conditions.GetAirVelocity().SetValue(environment_widget->AirVelocity(), LengthPerTimeUnit::m_Per_s);
  conditions.GetAmbientTemperature().SetValue(environment_widget->AmbientTemperature(), TemperatureUnit::C);
  conditions.GetAtmosphericPressure().SetValue(environment_widget->AtmosphericPressure(), PressureUnit::mmHg);
  conditions.GetClothingResistance().SetValue(environment_widget->ClothingResistance(), HeatResistanceAreaUnit::clo);
  conditions.GetEmissivity().SetValue(environment_widget->SurroundingEmissivity(), NoUnit::unitless);
  conditions.GetMeanRadiantTemperature().SetValue(environment_widget->MeanRadientTemperature(), TemperatureUnit::C);
  conditions.GetRelativeHumidity().SetValue(environment_widget->RelativeHumidity(), NoUnit::unitless);
  conditions.GetRespirationAmbientTemperature().SetValue(environment_widget->ResperationAmbientTemperature(), TemperatureUnit::C);
  //TODO:sawhite:SetAmbientGas
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::populatePatientWidget()
{
  SEPatient& patient = drivers[0].Patient();

  bool oldState = patient_widget->blockSignals(true);
  patient_widget->Name(patient.GetName().c_str())
    .Gender((patient.GetGender() == CDM::enumSex::Male) ? EGender::Male : EGender::Female)
    .Age(units::time::year_t(patient.GetAge(TimeUnit::yr)))
    .Weight(units::mass::kilogram_t(patient.GetWeight().GetValue(MassUnit::kg)))
    .Height(units::length::meter_t(patient.GetHeight().GetValue(LengthUnit::m)))
    .BodyFatPercentage(patient.GetBodyFatFraction().GetValue() * 100.0)
    .HeartRate(units::frequency::hertz_t(patient.GetHeartRateBaseline().GetValue(FrequencyUnit::Hz)))
    .RespritoryRate(units::frequency::hertz_t(patient.GetRespirationRateBaseline().GetValue(FrequencyUnit::Hz)))
    .DiastolicPressureBaseline(units::pressure::milimeters_of_mercury_t(patient.GetDiastolicArterialPressureBaseline().GetValue(PressureUnit::mmHg)))
    .SystolicPresureBaseline(units::pressure::milimeters_of_mercury_t(patient.GetSystolicArterialPressureBaseline().GetValue(PressureUnit::mmHg)));
  patient_widget->blockSignals(oldState);
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::populateEnvironmentWidget()
{
  SEEnvironment& environment = drivers[0].Environment();
  SEEnvironmentalConditions& conditions = environment.GetConditions();

  //Surrounding Type
  bool oldState = environment_widget->blockSignals(true);
  environment_widget->Surrondings((conditions.GetSurroundingType() == CDM::enumSurroundingType::Air) ? ESurrondings::Air : ESurrondings::Water);
  environment_widget->AirVelocity(units::velocity::meters_per_second_t(conditions.GetAirVelocity().GetValue(LengthPerTimeUnit::m_Per_s)));
  environment_widget->AmbientTemperature(units::temperature::celsius_t(conditions.GetAmbientTemperature().GetValue(TemperatureUnit::C)));
  environment_widget->AtmosphericPressure(units::pressure::milimeters_of_mercury_t(conditions.GetAtmosphericPressure().GetValue(PressureUnit::mmHg)));
  environment_widget->ClothingResistance(units::insulation::clo_t(conditions.GetClothingResistance().GetValue(HeatResistanceAreaUnit::clo)));
  environment_widget->SurroundingEmissivity(conditions.GetEmissivity().GetValue(NoUnit::unitless));
  environment_widget->MeanRadientTemperature(units::temperature::celsius_t(conditions.GetMeanRadiantTemperature().GetValue(TemperatureUnit::C)));
  environment_widget->RelativeHumidity(conditions.GetRelativeHumidity().GetValue(NoUnit::unitless));
  environment_widget->ResperationAmbientTemperature(units::temperature::celsius_t(conditions.GetRespirationAmbientTemperature().GetValue(TemperatureUnit::C)));
  //TODO:sawhite:SetAmbientGas
  environment_widget->blockSignals(oldState);
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::populateTimelineWidget()
{
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::handleTimelineValueChange()
{
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::loadPatient()
{
  QString fileName = QFileDialog::getOpenFileName(nullptr,
    tr("Load Environment file"), ".", tr("Biogears Environment files (*.xml)"));
  drivers[0].loadPatient(fileName.toStdString());
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::loadEnvironment()
{
  QString fileName = QFileDialog::getOpenFileName(nullptr,
    tr("Load Environment file"), ".", tr("Biogears Environment files (*.xml)"));
  drivers[0].loadEnvironment(fileName.toStdString());
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::loadTimeline()
{
  QString fileName = QFileDialog::getOpenFileName(nullptr,
    tr("Load Environment file"), ".", tr("Biogears Environment files (*.xml)"));
  drivers[0].loadTimeline(fileName.toStdString());
}
//-------------------------------------------------------------------------------
MainWindow::MainWindow(QWidget* parent)
  : QMainWindow(parent)
  , _impl(parent)
{
  createActions();
  createStatusBar();
  readSettings();
  setUnifiedTitleAndToolBarOnMac(true);
}
//-------------------------------------------------------------------------------
MainWindow::~MainWindow()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
void MainWindow::closeEvent(QCloseEvent* event)
{
  event->accept();
}
//-------------------------------------------------------------------------------
void MainWindow::about()
{
  QMessageBox::about(this, tr("About Application"),
    tr("The <b>Application</b> example demonstrates how to "
       "write modern GUI applications using Qt, with a menu bar, "
       "toolbars, and a status bar."));
}
void MainWindow::run()
{
  QMessageBox::about(this, tr("About Application"),
    tr("The <b>Application</b> example demonstrates how to "
       "write modern GUI applications using Qt, with a menu bar, "
       "toolbars, and a status bar."));
}
//-------------------------------------------------------------------------------
void MainWindow::createActions()
{
  //-- Create Header Menu
  QMenu* entry = nullptr;
  QToolBar* toolbar = nullptr;
  QAction* action = nullptr;
  QTabWidget* tabs = nullptr;
  //Simualtion
  entry = menuBar()->addMenu(tr("&Simulation"));
  //Simulation -> Launch
  QIcon launchIcon = QIcon::fromTheme("Launch", QIcon(":/img/play.png"));
  QAction* launch = action = new QAction(launchIcon, tr("&Launch"), this);
  action->setStatusTip(tr("Run current simulation"));
  connect(action, &QAction::triggered, this, &MainWindow::run);
  entry->addAction(action);

  //Simulation -> Load Patient
  action = new QAction(tr("&Load Patient"), this);
  action->setStatusTip(tr("Load an existing patient file."));
  connect(action, &QAction::triggered, _impl.get(), &MainWindow::Implementation::loadPatient);
  entry->addAction(action);
  //Simulation -> Load Environment
  action = new QAction(tr("&Load Environment"), this);
  action->setStatusTip(tr("Load an existing environment file."));
  connect(action, &QAction::triggered, _impl.get(), &MainWindow::Implementation::loadEnvironment);
  entry->addAction(action);
  //Simulation -> Load timeline
  action = new QAction(tr("&Load Timeline"), this);
  action->setStatusTip(tr("Load an existing timeline file."));
  connect(action, &QAction::triggered, _impl.get(), &MainWindow::Implementation::loadTimeline);
  entry->addAction(action);
  //Simulation -> Exit
  entry->addSeparator();
  const QIcon exitIcon = QIcon::fromTheme("application-exit");
  QAction* exitAct = entry->addAction(exitIcon, tr("E&xit"), this, &QWidget::close);
  exitAct->setShortcuts(QKeySequence::Quit);
  exitAct->setStatusTip(tr("Exit the application"));

  //Help
  entry = menuBar()->addMenu(tr("&Help"));
  //Help -> Help
  action = entry->addAction(tr("&About"), this, &MainWindow::about);
  action->setStatusTip(tr("Show the application's About box"));
  //Help -> About
  action = entry->addAction(tr("About &Qt"), qApp, &QApplication::aboutQt);
  action->setStatusTip(tr("Show the Qt library's About box"));

  addToolBar(_impl->runToolbar);

  tabs = new QTabWidget();

  tabs->addTab(_impl->physiologySelection, "Outputs");
  tabs->addTab(_impl->patient_widget, "Patient");
  tabs->addTab(_impl->environment_widget, "Environment");
  tabs->addTab(_impl->timeline_widget, "Timeline");
  setCentralWidget(tabs);

  connect(_impl->runToolbar, &ScenarioToolbar::patientChanged, _impl.get(), &Implementation::handlePatientFileChange);
  connect(_impl->runToolbar, &ScenarioToolbar::envonmentChanged, _impl.get(), &Implementation::handleEnvironmentFileChange);
  connect(_impl->runToolbar, &ScenarioToolbar::timelineChanged, _impl.get(), &Implementation::handleTimelineFileChange);

  connect(_impl->patient_widget, &PatientConfigWidget::valueChanged, _impl.get(), &Implementation::handlePatientValueChange);
  connect(_impl->environment_widget, &EnvironmentConfigWidget::valueChanged, _impl.get(), &Implementation::handleEnvironmentValueChange);
  connect(_impl->timeline_widget, &TimelineConfigWidget::valueChanged, _impl.get(), &Implementation::handleTimelineValueChange);
}
//-------------------------------------------------------------------------------
void MainWindow::createStatusBar()
{
  statusBar()->showMessage(tr("Ready"));
}
//-------------------------------------------------------------------------------
void MainWindow::readSettings()
{
  QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName());
  const QByteArray geometry = settings.value("geometry", QByteArray()).toByteArray();
  if (geometry.isEmpty()) {
    const QRect availableGeometry = QApplication::desktop()->availableGeometry(this);
    resize(availableGeometry.width() / 3, availableGeometry.height() / 2);
    move((availableGeometry.width() - width()) / 2,
      (availableGeometry.height() - height()) / 2);
  } else {
    restoreGeometry(geometry);
  }
}
//-------------------------------------------------------------------------------
void MainWindow::writeSettings()
{
  QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName());
  settings.setValue("geometry", saveGeometry());
}
}
