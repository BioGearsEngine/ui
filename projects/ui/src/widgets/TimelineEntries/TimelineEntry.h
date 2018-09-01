#ifndef BIOGEARSUI_WIDGETS_TIMELINE_ENTRY_H
#define BIOGEARSUI_WIDGETS_TIMELINE_ENTRY_H

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
//! \brief Base class for elements that are drawn on to timeline (scenario actions and patient events)

//Project Includes

//External Includes
#include <QWidget>
#include <QtGui>
//Project Includes
#include <biogears/framework/unique_propagate_const.h>

namespace biogears_ui {
class TimelineEntry : public QWidget {
  Q_OBJECT
public:
  TimelineEntry(QWidget* parent)
    : QWidget(parent){};
  virtual ~TimelineEntry(){};

  virtual void drawEntry(QWidget* timeline) const = 0;
  virtual QSize minimumSizeHint() const = 0;
  virtual QSize sizeHint() const = 0;

  double X() const { return _x; };
  double Y() const { return _y; };
  double Width() const { return _width; };
  double Height() const { return _height; };

  TimelineEntry& X(double x)
  {
    _x = x;
    return *this;
  };
  TimelineEntry& Y(double y)
  {
    _y = y;
    return *this;
  };


protected:
  double _x;
  double _y;
  double _height;
  double _width;
};
}
#endif