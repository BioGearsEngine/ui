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
//! \date   Aug 24 2018
//!
//!
//! \brief Graphical timeline of scenario actions for BioGears UI


#include "TimelineWidget.h"
//External Includes
#include <QVector>

namespace biogears_ui {

struct TimelineWidget::Implementation : public QObject {
public:
  Implementation();
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  void processPaintEvent(TimelineWidget* timeline);
  QSize getMinimumSizeHint() const;
  QSize getSizeHint() const;

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  QVector<TimelineEntry*> timelineActions;
  QVector<TimelineEntry*> timelineEvents;

  int penWidth;
  QColor penColor;
  QBrush backgroundBrush;
  QSize minSizeHint;
  QSize sizeHint;
};

TimelineWidget::Implementation::Implementation()
{
  penWidth = 3;
  penColor = Qt::GlobalColor::darkBlue;
  backgroundBrush = QBrush(Qt::GlobalColor::white, Qt::BrushStyle::SolidPattern);
  minSizeHint = QSize(100, 100);
  sizeHint = QSize(400, 250);

  //Test out making a timeline action
  TimelineAction* sampleAction = new TimelineAction();
  TimelineEvent* sampleEvent = new TimelineEvent();
  timelineActions.push_back(sampleAction);
  timelineEvents.push_back(sampleEvent);
}
//-------------------------------------------------------------------------------
TimelineWidget::Implementation::Implementation(const Implementation& obj)

{
  *this = obj;
}
//-------------------------------------------------------------------------------
TimelineWidget::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
TimelineWidget::Implementation& TimelineWidget::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
TimelineWidget::Implementation& TimelineWidget::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//---------------------------------------------------------------------------------
void TimelineWidget::Implementation::processPaintEvent(TimelineWidget* timeline)
{
  QPainter painter(timeline);
  //Set up background
  painter.fillRect(timeline->rect(), backgroundBrush);
  //Draw a line
  painter.setPen(QPen(penColor, penWidth));
  painter.drawLine(0, timeline->rect().height() / 2, timeline->rect().width(), timeline->rect().height() / 2);

  for (auto entry : timelineActions)
  {
    entry->drawEntry(timeline);
  }
  for (auto entry : timelineEvents) {
    entry->drawEntry(timeline);
  }
}
//----------------------------------------------------------------------------------
QSize TimelineWidget::Implementation::getMinimumSizeHint() const
{
  return minSizeHint;
}
//----------------------------------------------------------------------------------
QSize TimelineWidget::Implementation::getSizeHint() const
{
  return sizeHint;
}
//--------------------------------------------------------------------------------
TimelineWidget::TimelineWidget(QWidget* parent)
  : QWidget(parent)
  , _impl()
{
}
//---------------------------------------------------------------------------------
TimelineWidget::~TimelineWidget()
{
  _impl = nullptr;
}

void TimelineWidget::paintEvent(QPaintEvent* event)
{
  _impl->processPaintEvent(this);
}

QSize TimelineWidget::minimumSizeHint() const
{
  return _impl->getMinimumSizeHint();
}

QSize TimelineWidget::sizeHint() const
{
  return _impl->getSizeHint();
}
void TimelineWidget::addAction(TimelineAction* bgAction)
{
  _impl->timelineActions.push_back(bgAction);
  update();
}
void TimelineWidget::addEvent(TimelineEvent* bgEvent)
{
  _impl->timelineEvents.push_back(bgEvent);
  update();
}
void TimelineWidget::actionAdded()
{

}
  //----------------------------------------------------------------------------------
auto TimelineWidget::create() -> TimelineWidgetPtr
{
  return new TimelineWidget;
}
//----------------------------------------------------------------------------------
}
