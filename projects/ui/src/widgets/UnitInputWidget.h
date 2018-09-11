#ifndef BIOGEARSUI_WIDGETS_UNIT_INPUT_WIDGET_WIDGET_H
#define BIOGEARSUI_WIDGETS_UNIT_INPUT_WIDGET_WIDGET_H

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
//! \date   Sept 10th 2018
//!
//!

//External Includes
#include <QComboBox>
//Project Includes
#include <biogears/framework/unique_propagate_const.h>

namespace biogears_ui {
class UnitInputWidget : public QWidget {
  Q_OBJECT
public:
  UnitInputWidget(QWidget* parent = nullptr);
  virtual ~UnitInputWidget();

  using UnitInputWidgetPtr = UnitInputWidget*;
  static auto create(QString label, double value, QString unit, QWidget* parent = nullptr) -> UnitInputWidgetPtr;

  double Value() const;
  void Value(double);

  QString Label() const;
  void Label(const QString&);

  QString UnitText() const;
  int UnitIndex() const;
  void addUnit(const QString&);

  std::vector<QString> getUnits();
  void setUnits(QStringList);
  void setUnits(QStringList&&);

  void setRange(double minimum, double maximum);
signals:
  void valueChanged();
  void unitChanged();

private:
  struct Implementation;
  biogears::unique_propagate_const<Implementation> _impl;
};
}

#endif //BIOGEARSUI_WIDGETS_UNIT_INPUT_WIDGET_WIDGET_H