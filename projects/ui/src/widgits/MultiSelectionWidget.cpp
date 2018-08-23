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
#include <QSpacerItem>

namespace biogears_ui {

struct MultiSelectionWidget::Implementation: public QObject {
public:
  Implementation();
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  QListWidget* choices = nullptr;
  QListWidget* selected = nullptr;
public slots: //QT5 Slots >(
  void clearAllPreferences();
  void moveSelectedLeft();
  void moveSelectedRight();
  void selectAllPreferences();
};
//-------------------------------------------------------------------------------
MultiSelectionWidget::Implementation::Implementation()
  : choices(new QListWidget)
  , selected(new QListWidget)
{
}
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
void MultiSelectionWidget::Implementation::clearAllPreferences()
{
  
}
//-------------------------------------------------------------------------------
void MultiSelectionWidget::Implementation::moveSelectedLeft()
{
  
}
//-------------------------------------------------------------------------------
void MultiSelectionWidget::Implementation::moveSelectedRight()
{
  
}
//-------------------------------------------------------------------------------
void MultiSelectionWidget::Implementation::selectAllPreferences()
{
  
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

  QPushButton* clearAllButton = new QPushButton("ClearAll");
  QPushButton* moveLeftButton = new QPushButton("<<");
  QPushButton* moveRightButton = new QPushButton(">>");
  QPushButton* selectAllButton = new QPushButton("Move all");
  //QSpacerItem* topSpacer = new QSpacerItem;

  connect(clearAllButton, &QPushButton::clicked, _impl.get(), &Implementation::clearAllPreferences);
  connect(moveLeftButton, &QPushButton::clicked, _impl.get(), &Implementation::moveSelectedLeft);
  connect(moveRightButton, &QPushButton::clicked, _impl.get(), &Implementation::moveSelectedRight);
  connect(selectAllButton, &QPushButton::clicked, _impl.get(), &Implementation::selectAllPreferences);

  hLayout->addWidget(physiologyDataList);
  vLayout->addWidget(clearAllButton);
  //vLayout->addWidget(topSpacer);
  vLayout->addWidget(moveRightButton);
  vLayout->addWidget(moveLeftButton);
  vLayout->addWidget(selectAllButton);
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