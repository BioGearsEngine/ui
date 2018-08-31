#ifndef BIOGEARSUI_WIDGETS_TIMELINE_WIDGET_H
#define BIOGEARSUI_WIDGETS_TIMELINE_WIDGET_H

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
//! \brief Graphical timeline of scenario actions

#include "TimelineEntries/TimelineAction.h"
#include "TimelineEntries/TimelineEvent.h"
//External Includes
#include <QWidget>
#include <QtGui>
//Project Includes
#include <biogears/framework/unique_propagate_const.h>

namespace biogears_ui {
class TimelineWidget : public QWidget {
  Q_OBJECT
public:
  TimelineWidget(QWidget* parent = 0);
  ~TimelineWidget();

  void addAction(TimelineAction* bgAction);
  void addEvent(TimelineEvent* bgEvent);
  QSize minimumSizeHint() const;
  QSize sizeHint() const;

  using TimelineWidgetPtr = TimelineWidget*;
  static auto create() -> TimelineWidgetPtr;

public slots:
  void actionAdded();

protected:
  void paintEvent(QPaintEvent* event) override;

private:
  struct Implementation;
  biogears::unique_propagate_const<Implementation> _impl;
};
}

#endif