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
//! \date   August 21st 2018
//!
//!
//! \brief Primary window of BioGears UI

#include "MultiSelectionWidget.h"
//External Includes
#include <QtWidgets>


namespace biogears_ui {

struct MultiSelectionWidget::Implementation {
public:
  Implementation();
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  QListWidget* choices  = nullptr;
  QListWidget* selected = nullptr;
};
//-------------------------------------------------------------------------------
MultiSelectionWidget::Implementation::Implementation()
  : choices(new QListWidget)
  , selected(new QListWidget)
{ }
//-------------------------------------------------------------------------------
MultiSelectionWidget::Implementation::Implementation(const Implementation& obj)

{
  *this = obj;
}
//-------------------------------------------------------------------------------
MultiSelectionWidget::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
MultiSelectionWidget::Implementation& MultiSelectionWidget::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
MultiSelectionWidget::Implementation& MultiSelectionWidget::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
MultiSelectionWidget::MultiSelectionWidget()
  : _impl()
{
  QHBoxLayout* hLayout = new QHBoxLayout;
  QVBoxLayout* vLayout = new QVBoxLayout;

  QListWidget* physiologyDataList = new QListWidget;
  physiologyDataList->addItem("HeartRate");
  physiologyDataList->addItem("Blood Pressure");
  physiologyDataList->addItem("Breaths per Minute");
  physiologyDataList->addItem("Tidal Volume");
  physiologyDataList->addItem("Blood Surger Concentration");
  QListWidget* preferenceDataList = new QListWidget;

  QWidget* buttonWidget = new QWidget;

  QPushButton* moveLeftButton = new QPushButton("<<");
  QPushButton* moveRightButton = new QPushButton(">>");

  hLayout->addWidget(physiologyDataList);
  vLayout->addWidget(moveRightButton);
  vLayout->addWidget(moveLeftButton);
  hLayout->addWidget(buttonWidget);
  hLayout->addWidget(preferenceDataList);

  setLayout(hLayout);
  buttonWidget->setLayout(vLayout);
}
//-------------------------------------------------------------------------------
MultiSelectionWidget::~MultiSelectionWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a MultiSelectionWidget* which it retains no ownership of
//!        the caller is responsible for all memory management

auto MultiSelectionWidget::create() -> MultiSelectionWidgetPtr
{
  return new MultiSelectionWidget;
}
//-------------------------------------------------------------------------------
}