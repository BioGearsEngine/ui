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
//! \brief Derived from Timeline Entry class, handles drawing of scenario actions

#include "TimelineEvent.h"

namespace biogears_ui {

TimelineEvent::TimelineEvent(QWidget* parent)
  : TimelineEntry(parent)
{
}

TimelineEvent::~TimelineEvent()
{
}

void TimelineEvent::drawEntry(QWidget* timeline) const
{
  QPainter painter(timeline);
  painter.setPen(QPen(Qt::GlobalColor::darkRed, 3.0));
  painter.drawLine(0, timeline->rect().height(), timeline->rect().width(),0);
}

QSize TimelineEvent::minimumSizeHint() const
{
  return QSize(10, 10);
}

QSize TimelineEvent::sizeHint() const
{
  return QSize(25, 25);
}
//-----------------------------------------------------------------------------------------
}