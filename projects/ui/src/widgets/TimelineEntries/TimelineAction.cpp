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

#include "TimelineAction.h"

namespace biogears_ui {

TimelineAction::TimelineAction(QWidget* parent)
  : TimelineEntry(parent)
{
}

TimelineAction::~TimelineAction()
{
}

void TimelineAction::drawEntry(QWidget* timeline) const
{
  int windowWidth = timeline->rect().width();
  int windowHeight = timeline->rect().height();

  QPoint center(_x, windowHeight / 2);
  QPoint upper(center.x(), center.y() - 0.25 * windowHeight);
  //Create painter that draws on the timeline widget, as well as a pen and fill brush
  QPainter painter(timeline);
  QPen pen(Qt::GlobalColor::darkGreen, 1.0);
  QBrush fillBrush(Qt::GlobalColor::darkGreen);
  //Create a path we will use to outline circles (one on timeline, one above)
  QPainterPath drawPath;
  //Start the path at the event location on timeline
  drawPath.moveTo(center);
  //Draw circle
  drawPath.addEllipse(center, 5, 5);
  //Use painter to draw line to upper bound--path only fills in a closed object (i.e. not a line)
  painter.drawLine(center, upper);
  //Move draw path to upper bound
  drawPath.moveTo(upper);
  //Add circle to upper bound
  drawPath.addEllipse(upper, 5, 5);
  //Use defined brush to fill in closed subpaths created by path object
  painter.fillPath(drawPath, fillBrush);

}

QSize TimelineAction::minimumSizeHint() const
{
  return QSize(10, 10);
}

QSize TimelineAction::sizeHint() const
{
  return QSize(25, 25);
}
//-----------------------------------------------------------------------------------------
}