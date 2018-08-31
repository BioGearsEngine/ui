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
//External Includes
#include <QtWidgets>
#include <biogears/string-exports.h>


namespace biogears_ui {


struct TimelineConfigWidget::TimelineData {
public:
  TimelineData(const std::string&, double);
  std::string dataName;
  double timelineLocation;

  bool operator==(const std::string&);
};

struct TimelineConfigWidget::Implementation : QObject {

public:
  Implementation(QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  std::vector<TimelineData> timelineSeries;
  double scenarioTime;

public:
};
//------------------------------------------------------------------------------
TimelineConfigWidget::TimelineData::TimelineData(const std::string& name, double time)
  : dataName(name)
  , timelineLocation(time)
{

}
//-------------------------------------------------------------------------------
//This equality operator works for testing, but will need to get more specific since we can have multiple scenarios of the same
//type in a single timeline (e.g. multiple substance boluses)
bool TimelineConfigWidget::TimelineData::operator==(const std::string& rhs)
{
  if (this->dataName.compare(rhs) == 0) {
    return true;
  } else {
    return false;
  }
}
//-------------------------------------------------------------------------------
TimelineConfigWidget::Implementation::Implementation(QWidget* parent)
  : timelineSeries()
  , scenarioTime(0)
{
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
}
//-------------------------------------------------------------------------------
TimelineConfigWidget::~TimelineConfigWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
void TimelineConfigWidget::addAction(const std::string& name, double time)
{
  _impl->timelineSeries.emplace_back(name, time);
}

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
//This is only to test functionality.  In practice, we should increment time as we add AdvanceTime actions to action struct
void TimelineConfigWidget::ScenarioTime(double time)
{
  _impl->scenarioTime = time;
}
double TimelineConfigWidget::ScenarioTime()
{
  return _impl->scenarioTime;
}
////-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto TimelineConfigWidget::create(QWidget* parent) -> TimelineConfigWidgetPtr
{
  return new TimelineConfigWidget(parent);
}
}
