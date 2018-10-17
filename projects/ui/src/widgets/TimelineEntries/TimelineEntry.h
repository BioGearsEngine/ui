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


//External Includes
#include <QWidget>
#include <QtGui>
//Project Includes
#include <biogears/framework/unique_propagate_const.h>
#include "../../utils/ActionDataStruct.h"

namespace biogears_ui {
class TimelineEntry : public QWidget {
  Q_OBJECT
public:
  TimelineEntry(QWidget* parent)
    : QWidget(parent)
  {};
  virtual ~TimelineEntry(){};

  virtual void drawAtFullDetail(QPainter& painter)   const = 0;
  virtual void drawAtSimpleDetail(QPainter& painter) const = 0;
  virtual void drawAtMinmapDetail(QPainter& painter, double size_ratio) const = 0;

  virtual QSize minimumSizeHint() const = 0;
  virtual QSize sizeHint() const = 0;

  double Dpi() const { return _dpi; }
  double Scale() const { return _scale; }
  double X() const { return _x; };
  double Y() const { return _y; };
  double Width() const { return _width; };
  double Height() const { return _height; };
  ActionData Data() const { return _data; }

  inline TimelineEntry& X(double x);
  inline TimelineEntry& Y(double y);
  inline TimelineEntry& dpi(double dpi);
  
protected:
  double _x      = 0.0;
  double _y      = 0.0;
  double _height = 1.0;     
  double _width  = 1.0;
  double _dpi   = 200;
  double _scale = 1.0;

  ActionData _data {"Uninitialized", 0.0};
};

TimelineEntry& TimelineEntry::X(double x)
{
  _x = x;
  return *this;
};
TimelineEntry& TimelineEntry::Y(double y)
{
  _y = y;
  return *this;
};

TimelineEntry& TimelineEntry::dpi(double dpi)
{
  _dpi = dpi;
  return *this;
}

}
#endif