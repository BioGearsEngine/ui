#ifndef BIOGEARSUI_WIDGETS_DURATION_WIDGET_WIDGET_H
#define BIOGEARSUI_WIDGETS_DURATION_WIDGET_WIDGET_H

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
//! \date   Sept 11th 2018
//!
//! \brief This class is an input field for a Duration value. The return of Value will always be in the model unit of seconds (s)
//!        passed in at construction. Additionally you can view and input rates in minutes,hours, and years
//!        you can retrieve the current view using ViewUnit();

//External Includes
#include <QComboBox>
#include <units.h>
//Project Includes
#include <biogears/framework/unique_propagate_const.h>

namespace biogears_ui {
enum class Duration { Seconds,Minutes, Hours, Years};
class DurationInputWidget : public QObject {
  Q_OBJECT
public:
  DurationInputWidget(QWidget* parent = nullptr);
  DurationInputWidget(QString label, double value, QWidget* parent = nullptr);
  virtual ~DurationInputWidget();

  using DurationInputWidgetPtr = DurationInputWidget*;
  static auto create(QString label, double value, QWidget* parent = nullptr) -> DurationInputWidgetPtr;
  static auto create(QString label, units::time::second_t value, QWidget* parent = nullptr) -> DurationInputWidgetPtr;

  double Value() const;
  void Value(units::time::second_t);

  QString Label() const;
  void Label(const QString&);

  QString ViewUnitText() const;
  void setUnitView(Duration);

  QWidget* Widget();

  void setRange(double, double);
  void setSingleStep(double);

signals:
  void valueChanged();

private:
  struct Implementation;
  biogears::unique_propagate_const<Implementation> _impl;
};
}

#endif //BIOGEARSUI_WIDGETS_DURATION_WIDGET_WIDGET_H