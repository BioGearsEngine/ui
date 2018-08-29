#ifndef BIOGEARSUI_WIDGETS_TIMELINE_EVENT_H
#define BIOGEARSUI_WIDGETS_TIMELINE_EVENT_H

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
//! \author Matt McDaniel
//! \date   Aug 29 2018
//!
//! \brief Derived from Timeline Entry class, handles drawing of patient events flagged during scenario

#include "TimelineEntry.h"

namespace biogears_ui {
class TimelineEvent : public TimelineEntry {

public:
  TimelineEvent(QWidget* parent = 0);
  ~TimelineEvent();

  void drawEntry(TimelineWidget* timeline) const override;
  QSize minimumSizeHint() const override;
  QSize sizeHint() const override;
};
}
#endif