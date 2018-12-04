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
#include <biogears/exports.h>
#include <iostream>

//Project Includes
#include "../phys/DataRequestModel.h"
#include "MultiSelectionWidget.h"
#include "TimelineConfigWidget.h"
#include "TimelineWidget.h"

//External Includes
#include <QtAlgorithms>
#include <QtWidgets>

namespace biogears_ui {

struct MultiSelectionWidget::Implementation : public QObject {
public:
  Implementation(QWidget* parent = nullptr);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  QTreeView* choices = nullptr;
  QTreeView* selected = nullptr;
  DataRequestModel* data_requests = nullptr;

public slots: //QT5 Slots >(
  void clearAllPreferences();
  void moveSelectedLeft();
  void moveSelectedRight();
  void selectAllPreferences();
};
//-------------------------------------------------------------------------------
MultiSelectionWidget::Implementation::Implementation(QWidget* parent)
  : choices(new QTreeView(parent))
  , selected(new QTreeView(parent))
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
  auto model = selected->model();
  auto index = model->index(0, 0);
  model->setData(index, false, Qt::UserRole + 1);
  choices->reset();
  selected->reset();
}
//-------------------------------------------------------------------------------
void MultiSelectionWidget::Implementation::moveSelectedLeft()
{
  auto remianing = selected->selectionModel()->selectedIndexes();
  for (auto& index : remianing) {
    selected->model()->setData(index, false, Qt::UserRole);
  }
}
//-------------------------------------------------------------------------------
void MultiSelectionWidget::Implementation::moveSelectedRight()
{
  auto remianing = choices->selectionModel()->selectedIndexes();
  for (auto& index : remianing) {
    choices->model()->setData(index, true, Qt::UserRole);
  }
}

//-------------------------------------------------------------------------------
void MultiSelectionWidget::Implementation::selectAllPreferences()
{
  auto model = selected->model();
  auto index = model->index(0, 0);
  model->setData(index, true, Qt::UserRole + 1);
  choices->reset();
  selected->reset();
}
//-------------------------------------------------------------------------------
MultiSelectionWidget::MultiSelectionWidget(QWidget* parent)
  : QWidget(parent)
  , _impl(this)
{
  QHBoxLayout* hLayout = new QHBoxLayout;
  QVBoxLayout* vLayout = new QVBoxLayout;

  QVBoxLayout* combinedLayout = new QVBoxLayout;

  QWidget* buttonWidget = new QWidget;

  QPushButton* clearAllButton = new QPushButton("ClearAll");
  QPushButton* moveLeftButton = new QPushButton("<<");
  QPushButton* moveRightButton = new QPushButton(">>");
  QPushButton* selectAllButton = new QPushButton("Move all");

  connect(clearAllButton, &QPushButton::clicked, _impl.get(), &Implementation::clearAllPreferences);
  connect(moveLeftButton, &QPushButton::clicked, _impl.get(), &Implementation::moveSelectedLeft);
  connect(moveRightButton, &QPushButton::clicked, _impl.get(), &Implementation::moveSelectedRight);
  connect(selectAllButton, &QPushButton::clicked, _impl.get(), &Implementation::selectAllPreferences);

  _impl->choices->setSelectionMode(QAbstractItemView::SelectionMode::ExtendedSelection);
  _impl->selected->setSelectionMode(QAbstractItemView::SelectionMode::ExtendedSelection);

  _impl->choices->setHeaderHidden(true);
  _impl->selected->setHeaderHidden(true);

  hLayout->addWidget(_impl->choices);
  vLayout->addWidget(clearAllButton);
  vLayout->insertStretch(1);
  vLayout->addWidget(moveRightButton);
  vLayout->addWidget(moveLeftButton);
  vLayout->insertStretch(4);
  vLayout->addWidget(selectAllButton);
  hLayout->addWidget(buttonWidget);
  hLayout->addWidget(_impl->selected);

  setLayout(hLayout);
  buttonWidget->setLayout(vLayout);
}
//-------------------------------------------------------------------------------
MultiSelectionWidget::~MultiSelectionWidget()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
void MultiSelectionWidget::setOptions(QAbstractItemModel* model)
{
  auto lproxy = new LeftSideDataRequestFilter(model);
  auto rproxy = new RightSideDataRequestFilter(model);

  connect(model, &QAbstractItemModel::dataChanged, lproxy, &QSortFilterProxyModel::invalidate);
  connect(model, &QAbstractItemModel::dataChanged, rproxy, &QSortFilterProxyModel::invalidate);

  _impl->choices->setModel(lproxy);
  _impl->selected->setModel(rproxy);
}
//-------------------------------------------------------------------------------
//!
//! \brief returns a MultiSelectionWidget* which it retains no ownership of
//!        the caller is responsible for all memory management

auto MultiSelectionWidget::create(QWidget* parent) -> MultiSelectionWidgetPtr
{
  return new MultiSelectionWidget(parent);
}
//-------------------------------------------------------------------------------
}