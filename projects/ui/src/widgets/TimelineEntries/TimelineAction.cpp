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
  //Create painter that draws on the timeline widget
  QPainter painter(timeline);
  //Create a path we will use to draw action "bubble"
  QPainterPath drawPath;
  //Scale path to current size of window
  int rHeight = 0.5 * windowHeight;
  int rWidth = 0.10 * windowWidth;
  //Create a rectangular boundary around draw area (center will be at event point on timeline)
  QRectF boundR(_x - 0.5 * rWidth, windowHeight / 2 - 0.5 * rHeight, rWidth, rHeight);
  //Start path event location on timeline
  drawPath.moveTo(center);
  //Move to upper left of bounding rectangle
  drawPath.lineTo(boundR.topLeft());
  //Draw arc to top right
  QPoint c(center.x(), center.y() - rHeight);
  drawPath.quadTo(c, boundR.topRight());
  //Return to starting point
  drawPath.lineTo(center);
  painter.setPen(QPen(Qt::GlobalColor::darkGreen, 1.0));
  QBrush fillBrush(Qt::GlobalColor::darkGreen);

  painter.fillPath(drawPath,fillBrush);
  //painter.drawLine(_x, 0, _x, timeline->rect().height());

  
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