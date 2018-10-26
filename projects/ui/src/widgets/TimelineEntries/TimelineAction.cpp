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
//-----------------------------------------------------------------------------------------
TimelineAction::~TimelineAction()
{
}
//-----------------------------------------------------------------------------------------
void TimelineAction::drawAtFullDetail(::QPainter& painter) const
{
  //Draws a 1/16th of an inch green line 
  //Draws a 1/8th inch blue circle above the line
  //Labels Marker with name
  
  int windowWidth  = painter.device()->width();
  int windowHeight = painter.device()->height();
  
  QPoint center(_x, windowHeight / 2);
  QPoint upper(center.x(), center.y() - 0.25 * windowHeight);
  QPoint label(center.x(), center.y() - 0.30 * windowHeight);

  QPen pen(Qt::GlobalColor::darkGreen, 1.0);
  QBrush fillBrush(Qt::GlobalColor::darkGreen);
  QPainterPath drawPath;
  drawPath.moveTo(center);
  drawPath.addEllipse(center, 5, 5);
  painter.drawLine(center, upper);
  drawPath.moveTo(upper);
  drawPath.addEllipse(upper, 5, 5);
  painter.fillPath(drawPath, fillBrush);

  QString name = QString(_data.name.c_str());
  painter.drawText(label, name);
}
//-----------------------------------------------------------------------------------------
void TimelineAction::drawAtSimpleDetail(::QPainter& painter) const
{
  //Draws a 1/16th of an inch green line 
  //Draws a 1/8th inch blue circle above the line
  //Labels Marker with name

  int windowWidth = painter.device()->width();
  int windowHeight = painter.device()->height();

  QPoint center(_x, windowHeight / 2);
  QPoint upper(center.x(), center.y() - 0.25 * windowHeight);

  QPen pen(Qt::GlobalColor::darkGreen, 1.0);
  QBrush fillBrush(Qt::GlobalColor::darkGreen);
  QPainterPath drawPath;
  drawPath.moveTo(center);
  drawPath.addEllipse(center, 5, 5);
  painter.drawLine(center, upper);
  drawPath.moveTo(upper);
  drawPath.addEllipse(upper, 5, 5);
  painter.fillPath(drawPath, fillBrush);

}
//-----------------------------------------------------------------------------------------
void TimelineAction::drawAtMinmapDetail(::QPainter& painter, double ratio) const
{
  int windowWidth = painter.device()->width();
  int windowHeight = painter.device()->height();

  QPoint base(_x*ratio, windowHeight );
  QPoint top( _x*ratio, static_cast<int>(windowHeight/4.0));
  
  painter.setPen({ Qt::GlobalColor::darkGreen, 2.0 });
  painter.drawLine(base, top);

}
//-----------------------------------------------------------------------------------------
QSize TimelineAction::minimumSizeHint() const
{
  return QSize(10, 10);
}
//-----------------------------------------------------------------------------------------
QSize TimelineAction::sizeHint() const
{
  return QSize(25, 25);
}
//-----------------------------------------------------------------------------------------
}