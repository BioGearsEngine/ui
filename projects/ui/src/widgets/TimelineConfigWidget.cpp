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

namespace biogears_ui {

struct TimelineConfigWidget::Implementation : QObject {

public:
  Implementation();
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

public:
};
//-------------------------------------------------------------------------------
TimelineConfigWidget::Implementation::Implementation()

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
TimelineConfigWidget::TimelineConfigWidget()
  : QWidget()
  , _impl()
{
}
//-------------------------------------------------------------------------------
TimelineConfigWidget::~TimelineConfigWidget()
{
  _impl = nullptr;
}
////-------------------------------------------------------------------------------
//!
//! \brief returns a ScenarioToolbar* which it retains no ownership of
//!        the caller is responsible for all memory management
auto TimelineConfigWidget::create() -> TimelineConfigWidgetPtr
{
  return new TimelineConfigWidget;
}
}