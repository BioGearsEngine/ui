#ifndef BIOGEARSUI_WIDGETS_UNIT_BOX_WIDGET_WIDGET_H
#define BIOGEARSUI_WIDGETS_UNIT_BOX_WIDGET_WIDGET_H

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
class UnitComboBox : public QComboBox {
  Q_OBJECT
public:
  UnitComboBox(QWidget* parent = nullptr);
  virtual ~UnitComboBox();

  using UnitComboBoxPtr = UnitComboBox*;
  static auto create(QWidget* parent = nullptr) -> UnitComboBoxPtr;

  QString GetPreviousText() { return _previousText; }
  int GetPreviousIndex() { return _previousIndex; }

protected:
  void mousePressEvent(QMouseEvent* e) override;

private:
  QString _previousText = "";
  int _previousIndex = 0;
};
}

#endif //BIOGEARSUI_WIDGETS_UNIT_BOX_WIDGET_WIDGET_H