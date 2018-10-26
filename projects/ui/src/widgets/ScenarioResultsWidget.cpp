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
#include <QFutureWatcher>
#include <QTabWidget>
#include <QtConcurrent/QtConcurrentMap>
#include <QtConcurrent/QtConcurrent>
#include <QtWidgets>

#include <biogears/exports.h>

#include <biogears/cdm/properties/SEScalarTime.h>
#include <biogears/cdm/properties/SEScalarTypes.h>
#include <biogears/cdm/scenario/SEAdvanceTime.h>
#include <biogears/cdm/system/environment/SEEnvironmentalConditions.h>
#include <biogears/cdm/system/environment/conditions/SEEnvironmentCondition.h>

#include <units.h>
//Project Includes
#include "../phys/PhysiologyDriver.h"
#include "../phys/PhysiologyThread.h"

#include "EnvironmentConfigWidget.h"
#include "MultiSelectionWidget.h"
#include "PatientConfigWidget.h"
#include "ScenarioToolbar.h"
#include "TimelineConfigWidget.h"

#include <xercesc/dom/DOMDocument.hpp>

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
{
  QHBoxLayout* layout = new QHBoxLayout;
  setLayout(layout);
  layout->addWidget(_timeline_widget);
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
  return std::move(_driver);
}
//-------------------------------------------------------------------------------
void ScenarioResultsWidget::setPhysiologyDriver(std::unique_ptr<PhysiologyDriver>&& driver)
{
  _driver = std::move(driver);
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
  }
}
}
