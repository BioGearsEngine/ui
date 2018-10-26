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
#include <algorithm>
#include <iostream>
#include <regex>
//External Includes
#include <QTabWidget>
#include <QtWidgets>

#include <biogears/exports.h>

#include <units.h>
//Project Includes
#include "../phys/PhysiologyDriver.h"
#include "../phys/PhysiologyThread.h"

#include "ScenarioConfigWidget.h"
#include "ScenarioResultsWidget.h"
#include "ScenarioToolbar.h"

#include <xercesc/dom/DOMDocument.hpp>

using namespace biogears;
namespace biogears_ui {

enum class OpMode { CONFIG, RESULTS };

struct MainWindow::Implementation : public QObject {
public: //Functions
  Implementation(QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  ~Implementation();

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

public slots: //QT5 Slots >(

  void switchToResultsMode(QMainWindow* mainwindow);
  void switchToConfigMode(QMainWindow* mainwindow);

  void createActions(QMainWindow* window);
  void createStatusBar(QMainWindow* window);
  void about();
public: //Data
  ScenarioConfigWidget*  config_widget  = nullptr;
  ScenarioResultsWidget* results_widget = nullptr;
  ScenarioToolbar*       scenario_toolbar = nullptr;
  OpMode    mode = OpMode::CONFIG;
};
//-------------------------------------------------------------------------------
MainWindow::Implementation::~Implementation()
{

}
//-------------------------------------------------------------------------------
MainWindow::Implementation::Implementation(QWidget* parent)
  : config_widget(ScenarioConfigWidget::create(parent))
  , scenario_toolbar(config_widget->getScenarioToolbar())

{
  config_widget->setPhysiologyDriver(std::make_unique<PhysiologyDriver>("BioGearsGUI") );
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
void MainWindow::resume()
{
  std::cout << "Resuming\n";
  _impl->switchToResultsMode(this);
  //if( thread->paused() )
  {
    //thread->paused(false);
  }
  //thread->run();
}
//-------------------------------------------------------------------------------
void MainWindow::pause()
{
  std::cout << "Pausing\n";
  _impl->switchToConfigMode(this);
  //thread->paused(true);
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::about()
{
  QMessageBox::about(nullptr, tr("About Application"),
    tr("The <b>Application</b> example demonstrates how to "
       "write modern GUI applications using Qt, with a menu bar, "
       "toolbars, and a status bar."));
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::switchToResultsMode(QMainWindow* window)
{
  if ( OpMode::CONFIG == mode )
  {
    config_widget = dynamic_cast<ScenarioConfigWidget*>(window->takeCentralWidget());
    if ( nullptr == results_widget)
    {
      results_widget = ScenarioResultsWidget::create(window);
    }

    results_widget->setPhysiologyDriver(config_widget->getPhysiologyDriver());
    results_widget->populateTimelineWidget();
    results_widget->setSimulationTime(0);
    window->setCentralWidget(results_widget);
  }
  results_widget->lock();
  mode = OpMode::RESULTS;
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::switchToConfigMode(QMainWindow* window)
{
  if (OpMode::RESULTS == mode)
  {
    results_widget = dynamic_cast<ScenarioResultsWidget*>(window->takeCentralWidget());
    if (nullptr == config_widget)
    {
      config_widget = ScenarioConfigWidget::create(window);
    }
    config_widget->setPhysiologyDriver(results_widget->getPhysiologyDriver());
    window->setCentralWidget(config_widget);
  }
  scenario_toolbar->unlock();
  mode = OpMode::CONFIG;
}
//-------------------------------------------------------------------------------
MainWindow::MainWindow(QWidget* parent)
  : QMainWindow(parent)
  , _impl(this)
{
  _impl->createActions(this);
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
void MainWindow::Implementation::createActions(QMainWindow* mainWindow)
{
  //-- Create Header Menu
  QMenu* entry = nullptr;
  QAction* action = nullptr;

  auto window = dynamic_cast<MainWindow*>(mainWindow);

  //Simualtion
  entry = mainWindow->menuBar()->addMenu(tr("&Simulation"));
  //Simulation -> Launch
  QIcon launchIcon = QIcon::fromTheme("Launch", QIcon(":/img/play.png"));
  QAction* launch = action = new QAction(launchIcon, tr("&Launch"), mainWindow);
  action->setStatusTip(tr("Run current simulation"));
  connect(action, &QAction::triggered, window, &MainWindow::resume);
  entry->addAction(action);

  //Simulation -> Load Patient
  action = new QAction(tr("&Load Patient"), this);
  action->setStatusTip(tr("Load an existing patient file."));
  connect(action, &QAction::triggered, config_widget, &ScenarioConfigWidget::loadPatient);
  entry->addAction(action);
  //Simulation -> Load Environment
  action = new QAction(tr("&Load Environment"), this);
  action->setStatusTip(tr("Load an existing environment file."));
  connect(action, &QAction::triggered, config_widget, &ScenarioConfigWidget::loadEnvironment);
  entry->addAction(action);
  //Simulation -> Load timeline
  action = new QAction(tr("&Load Timeline"), this);
  action->setStatusTip(tr("Load an existing timeline file."));
  connect(action, &QAction::triggered, config_widget, &ScenarioConfigWidget::loadTimeline);
  entry->addAction(action);
  //Simulation -> Exit
  entry->addSeparator();
  const QIcon exitIcon = QIcon::fromTheme("application-exit");
  QAction* exitAct = entry->addAction(exitIcon, tr("E&xit"), mainWindow, &QWidget::close);
  exitAct->setShortcuts(QKeySequence::Quit);
  exitAct->setStatusTip(tr("Exit the application"));

  //Help
  entry = mainWindow->menuBar()->addMenu(tr("&Help"));
  //Help -> Help
  action = entry->addAction(tr("&About"), this, &Implementation::about);
  action->setStatusTip(tr("Show the application's About box"));
  //Help -> About
  action = entry->addAction(tr("About &Qt"), qApp, &QApplication::aboutQt);
  action->setStatusTip(tr("Show the Qt library's About box"));

  mainWindow->addToolBar(scenario_toolbar);
  mainWindow->setCentralWidget(config_widget);

  connect(scenario_toolbar, &ScenarioToolbar::patientChanged, config_widget, &ScenarioConfigWidget::handlePatientFileChange);
  connect(scenario_toolbar, &ScenarioToolbar::envonmentChanged, config_widget, &ScenarioConfigWidget::handleEnvironmentFileChange);
  connect(scenario_toolbar, &ScenarioToolbar::timelineChanged, config_widget, &ScenarioConfigWidget::handleTimelineFileChange);
  connect(scenario_toolbar, &ScenarioToolbar::resumeSimulation, window, &MainWindow::resume);
  connect(scenario_toolbar, &ScenarioToolbar::pauseSimulation, window, &MainWindow::pause);
}
//-------------------------------------------------------------------------------
void MainWindow::Implementation::createStatusBar(QMainWindow* window)
{
  window->statusBar()->showMessage(tr("Ready"));
}
}
