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

#include "ScenarioResultsWidget.h"
//Standard Includes
#include <algorithm>
#include <iostream>
#include <regex>
//External Includes
#include <QtConcurrent/QtConcurrent>
#include <QtWidgets>

#include <biogears/exports.h>

#include <biogears/cdm/properties/SEScalarTime.h>
#include <biogears/cdm/properties/SEScalarTypes.h>
#include <biogears/cdm/scenario/SEAdvanceTime.h>

#include <units.h>
//Project Includes
#include "../phys/PhysiologyDriver.h"


#include "EnvironmentConfigWidget.h"
#include "TimelineConfigWidget.h"

using namespace biogears;
namespace biogears_ui {
//-------------------------------------------------------------------------------
void ScenarioResultsWidget::populateTimelineWidget()
{
  auto actions = _driver->GetActions();
  double time = 0;
  std::string name;

  std::vector<ActionData> timeline;
  for (auto action : actions) {
    name = action->classname();

    timeline.emplace_back(name, time);
    if (std::strcmp(action->classname(), biogears::SEAdvanceTime::TypeTag()) == 0) {
      auto delta = dynamic_cast<SEAdvanceTime*>(action);
      time += delta->GetTime().GetValue(TimeUnit::s);
    }
  }
  _timeline_widget->Actions(timeline);
  _timeline_widget->ScenarioTime(time);
}
//-------------------------------------------------------------------------------
ScenarioResultsWidget::ScenarioResultsWidget(QWidget* parent)
  : QWidget(parent)
  , _timeline_widget(TimelineConfigWidget::create(parent))
  , _heartRate(new QLineSeries())
  , _bloodPressure(new QLineSeries())
{
  QVBoxLayout* vLayout = new QVBoxLayout;
  //QHBoxLayout* hlayout = new QHBoxLayout;
  setLayout(vLayout);
  vLayout->addWidget(_timeline_widget);

  _heartRatePlot = new QChart();
  _heartRatePlot->setTitle("Heart Rate");
  _heartRatePlot->addSeries(_heartRate);
  _heartRatePlot->createDefaultAxes();
  vLayout->addWidget(new QChartView(_heartRatePlot));

  _bloodPressurePlot = new QChart();
  _bloodPressurePlot->setTitle("Blood Pressure");
  _bloodPressurePlot->addSeries(_bloodPressure);
  _bloodPressurePlot->createDefaultAxes();
  vLayout->addWidget(new QChartView(_bloodPressurePlot));

}
//-------------------------------------------------------------------------------
ScenarioResultsWidget::~ScenarioResultsWidget()
{
}
//-------------------------------------------------------------------------------
auto ScenarioResultsWidget::create(QWidget* parent) -> ScenarioResultsWidgetPtr
{
  return new ScenarioResultsWidget(parent);
}
//-------------------------------------------------------------------------------
std::unique_ptr<PhysiologyDriver> ScenarioResultsWidget::getPhysiologyDriver()
{
  _updateTimer->stop();
  return std::move(_driver);
}
//-------------------------------------------------------------------------------
void ScenarioResultsWidget::setPhysiologyDriver(std::unique_ptr<PhysiologyDriver>&& driver)
{
  _driver = std::move(driver);

  _updateTimer = new QTimer(this);
  connect(_updateTimer, &QTimer::timeout, this, &ScenarioResultsWidget::updateDataTracks );
  _updateTimer->start(1000);

}
//--------------------------------------------------------------------------------
void ScenarioResultsWidget::setSimulationTime(double time)
{
  _timeline_widget->CurrentTime(time);
}
//--------------------------------------------------------------------------------
void ScenarioResultsWidget::lock()
{
  _timeline_widget->lock();
}
//--------------------------------------------------------------------------------
void ScenarioResultsWidget::unlock()
{
  _timeline_widget->unlock();
}
//---------------------------------------------------------------------------------
void ScenarioResultsWidget::initalize()
{
  if (_not_initialized) {
    QProgressDialog progress(this);
    progress.setWindowModality(Qt::WindowModal);
    progress.setLabelText("Initializing Engine...");
    progress.setCancelButton(0);
    progress.setRange(0, 0);
    progress.setMinimumDuration(0);
    progress.show();

    QFutureWatcher<void> futureWatcher;
    QObject::connect(&futureWatcher, &QFutureWatcher<void>::finished, &progress, &QProgressDialog::reset);
    QObject::connect(&progress, &QProgressDialog::canceled, &futureWatcher, &QFutureWatcher<void>::cancel);
    QObject::connect(&futureWatcher, &QFutureWatcher<void>::progressRangeChanged, &progress, &QProgressDialog::setRange);
    QObject::connect(&futureWatcher, &QFutureWatcher<void>::progressValueChanged, &progress, &QProgressDialog::setValue);

    std::function<void(void)> init = [&](void) {
      _not_initialized = !_driver->initialize();
    };
    QFuture<void> future = QtConcurrent::run(init);
    futureWatcher.setFuture(future);
    progress.exec();
    futureWatcher.waitForFinished();

    //TODO::SetupPhysiologyRequest
    //TODO::SetupCinoartnebtRequest

    _driver->async_start();
  }
}
//---------------------------------------------------------------------------------
void ScenarioResultsWidget::updateDataTracks()
{
  static double timer = 0.0;
  if(_driver && _driver->isRunning())
  {
    PhysiologyDriver::DataTrackMap tracks  = _driver->dataRequests();
    auto time = _driver->timeline();

    double HR = tracks["HeartRate(1/min)"];
    double MAP = tracks["MeanArterialPressure(mmHg)"];
    _heartRate->append(timer, HR);
    _bloodPressure->append(timer++, MAP);

    _heartRatePlot->axisX()->setRange(timer-20, timer);
    _heartRatePlot->axisY()->setRange(0, 90);

    _bloodPressurePlot->axisX()->setRange(timer - 20, timer);
    _bloodPressurePlot->axisY()->setRange(0, 100);

  }
}
}
