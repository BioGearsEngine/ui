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

#include "TimelineConfigWidget.h"
#include "TimelineWidget.h"
//External Includes
#include <QtWidgets>
#include <biogears/string-exports.h>

namespace biogears_ui {


struct TimelineConfigWidget::Implementation : QObject {

public:
  Implementation(QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  TimelineWidget* timeWidget = nullptr;
  std::vector<ActionData> timelineSeries;

public:
};

//-------------------------------------------------------------------------------
TimelineConfigWidget::Implementation::Implementation(QWidget* parent)
  : timeWidget(TimelineWidget::create(parent))
  , timelineSeries()
{
  QGridLayout* grid = new QGridLayout();
  parent->setLayout(grid);

  grid->addWidget(new QLabel("Test Area"), 0, 0);
  grid->addWidget(timeWidget, 1, 0);
}
//-------------------------------------------------------------------------------
TimelineConfigWidget::Implementation::Implementation(const Implementation& obj)

{
  *this = obj;
}
//-------------------------------------------------------------------------------
TimelineConfigWidget::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
TimelineConfigWidget::Implementation& TimelineConfigWidget::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
TimelineConfigWidget::Implementation& TimelineConfigWidget::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
TimelineConfigWidget::TimelineConfigWidget(QWidget* parent)
  : QWidget(parent)
  , _impl(this)
{

  _impl->timeWidget->ScenarioTime(30.0);
  connect(this, &TimelineConfigWidget::actionAdded, _impl->timeWidget, &TimelineWidget::addAction);

    addAction(std::string("Sample"), 5.0);
}
//-------------------------------------------------------------------------------
TimelineConfigWidget::~TimelineConfigWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
void TimelineConfigWidget::addAction(std::string& name, double time)
{
  _impl->timelineSeries.emplace_back(name, time);
  emit actionAdded(_impl->timelineSeries.back());
}

//-------------------------------------------------------------------------------
bool TimelineConfigWidget::removeAction(const std::string& name)
{
  auto it = std::find(_impl->timelineSeries.begin(), _impl->timelineSeries.end(), name);
  if (it != _impl->timelineSeries.end()) {
    _impl->timelineSeries.erase(it);
    return true;
  } else {
    return false;
  }
}
//-------------------------------------------------------------------------------
//This is only to test functionality.  In practice, we should increment time as we add AdvanceTime actions to action struct
void TimelineConfigWidget::ScenarioTime(double time)
{
  _impl->timeWidget->ScenarioTime(time);
}
//-------------------------------------------------------------------------------
double TimelineConfigWidget::ScenarioTime()
{
  return _impl->timeWidget->ScenarioTime();
}
//-------------------------------------------------------------------------------
std::vector<ActionData> TimelineConfigWidget::Actions() const
{
  return _impl->timelineSeries;

}
//-------------------------------------------------------------------------------
void TimelineConfigWidget::Actions(std::vector<ActionData> actions)
{
  _impl->timelineSeries = actions;
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto TimelineConfigWidget::create(QWidget* parent) -> TimelineConfigWidgetPtr
{
  return new TimelineConfigWidget(parent);
}

}
