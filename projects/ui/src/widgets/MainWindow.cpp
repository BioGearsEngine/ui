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
#include <QtWidgets>
#include <QTabWidget>
#include <biogears/string-exports.h>
//Project Includes
#include "../phys/PhysiologyDriver.h"
#include "MultiSelectionWidget.h"
#include "ScenarioToolbar.h"
#include "PatientConfigWidget.h"
#include "EnvironmentConfigWidget.h"
#include "TimelineConfigWidget.h"
namespace biogears_ui {

struct MainWindow::Implementation : public QObject {
public: //Functions
  Implementation();
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

public slots: //QT5 Slots >(
  void handlePatientChange(int index);
  void handleEnvironmentChange(int index);
  void handleTimelineChange(int index);
  void loadPatient();
  void loadEnvironment();
  void loadTimeline();

public: //Data
  std::vector<PhysiologyDriver> drivers;

  MultiSelectionWidget* physiologySelection = nullptr;
  ScenarioToolbar* runToolbar = nullptr;
  PatientConfigWidget* patient_widget = nullptr;
  EnvironmentConfigWidget* envrionment_widget = nullptr;
  TimelineConfigWidget* timeline_widget= nullptr;
};
//-------------------------------------------------------------------------------
MainWindow::Implementation::Implementation()
  : physiologySelection(MultiSelectionWidget::create())
  , runToolbar(ScenarioToolbar::create())
  , patient_widget(PatientConfigWidget::create())
  , envrionment_widget(EnvironmentConfigWidget::create())
  , timeline_widget(TimelineConfigWidget::create())
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
void MainWindow::Implementation::handlePatientChange(int index)
{
  if (0 == index) {
    drivers[0].clearPatient();
  } else if (1 == index) {
    drivers[0].clearPatient();
  } else if (runToolbar->patientListSize() == index + 1) {
    loadPatient();
  } else {
    //TODO:sawhite:Load Patient from Selection
  }
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::handleEnvironmentChange(int index)
{
  if (0 == index) {
    drivers[0].clearEnvironment();
  } else if (1 == index) {
    drivers[0].clearEnvironment();
    //New Environment;
  }
  if (runToolbar->envrionmentListSize() == index + 1) {
    loadEnvironment();
  } else {
    //TODO:sawhite:Load Environment From Selection
  }
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::handleTimelineChange(int index)
{
  if (0 == index) {
    drivers[0].clearTimeline();
  } else if (1 == index) {
    drivers[0].clearTimeline();
    //New Timeline;
  } else if (runToolbar->timelineListSize() == index + 1) {
    loadTimeline();
  } else {
    //TODO:sawhite:Load Timeline From Selection
  }
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::loadPatient()
{
  QString fileName = QFileDialog::getOpenFileName(nullptr,
  tr("Load Environment file"), ".", tr("Biogears Environment files (*.xml)"));
  drivers[0].patient(fileName.toStdString());
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::loadEnvironment()
{
  QString fileName = QFileDialog::getOpenFileName(nullptr,
    tr("Load Environment file"), ".", tr("Biogears Environment files (*.xml)"));
  drivers[0].environment(fileName.toStdString());
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::loadTimeline()
{
  QString fileName = QFileDialog::getOpenFileName(nullptr,
    tr("Load Environment file"), ".", tr("Biogears Environment files (*.xml)"));
  drivers[0].timeline(fileName.toStdString());
}
//-------------------------------------------------------------------------------
MainWindow::MainWindow()
{
  //setCentralWidget(textEdit);
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
  tabs->addTab(_impl->envrionment_widget, "Environment");
  tabs->addTab(_impl->timeline_widget, "Timeline");
  setCentralWidget(tabs);

  connect(_impl->runToolbar, &ScenarioToolbar::patientChanged, _impl.get(), &Implementation::handlePatientChange);
  connect(_impl->runToolbar, &ScenarioToolbar::envonmentChanged, _impl.get(), &Implementation::handleEnvironmentChange);
  connect(_impl->runToolbar, &ScenarioToolbar::timelineChanged, _impl.get(), &Implementation::handleTimelineChange);
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
