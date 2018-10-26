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
public:
};

//-------------------------------------------------------------------------------
TimelineConfigWidget::Implementation::Implementation(QWidget* parent)
  : timeWidget(TimelineWidget::create(parent))
{
  QVBoxLayout* layout = new QVBoxLayout();
  parent->setLayout(layout);

  layout->addWidget(new QLabel("Timeline"));
  layout->addWidget(timeWidget);
  layout->addStretch(1);
  ;
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

  _impl->timeWidget->ScenarioLength(30.0);

}
//-------------------------------------------------------------------------------
TimelineConfigWidget::~TimelineConfigWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
void TimelineConfigWidget::Actions(std::vector<ActionData> actions)
{
  _impl->timeWidget->Actions(actions);
  repaint();
  QWidget::update();
}
//-------------------------------------------------------------------------------
void TimelineConfigWidget::addTimelineAction(const std::string& name, double time)
{
  _impl->timeWidget->addActionData( { name, time } );
}
//-------------------------------------------------------------------------------
bool TimelineConfigWidget::removeTimelineAction(const std::string& name, double time)
{
  return _impl->timeWidget->removeActionData( { name, time } );
}
//-------------------------------------------------------------------------------
void TimelineConfigWidget::clear()
{
  _impl->timeWidget->clear();
}
//-------------------------------------------------------------------------------
void TimelineConfigWidget::ScenarioTime(double time)
{
  _impl->timeWidget->ScenarioLength(time);
}
//-------------------------------------------------------------------------------
double TimelineConfigWidget::ScenarioTime()
{
  return _impl->timeWidget->ScenarioLength();
}
//This is only to test functionality.  In practice, we should increment time as we add AdvanceTime actions to action struct
void TimelineConfigWidget::CurrentTime(double time)
{
  _impl->timeWidget->CurrentTime(time);
}
//-------------------------------------------------------------------------------
double TimelineConfigWidget::CurrentTime()
{
  return _impl->timeWidget->CurrentTime();
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto TimelineConfigWidget::create(QWidget* parent) -> TimelineConfigWidgetPtr
{
  return new TimelineConfigWidget(parent);
}
//-------------------------------------------------------------------------------
void TimelineConfigWidget::lock()
{
  _impl->timeWidget->lock();
}
//-------------------------------------------------------------------------------
void TimelineConfigWidget::unlock()
{
  _impl->timeWidget->unlock();
}
}
