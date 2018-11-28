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
//! \date   Aug 24th 2017
//!
//!  Abstract Model for string a biogears::Tree<T>  of underlying data
//!

#include "DataRequestModel.h"

#include <QFont>
#include <regex>

#include <biogears/container/Tree.tci.h>
#include <iostream>

namespace biogears_ui {
void print_model_node(biogears::Tree<DataRequest>& node, size_t level = 0)
{
  if (0 < level) {
    auto count = level;
    while (count--) {
      std::cout << "  ";
    }
  }
  std::cout << node.value().name << " | " << node.value().key << '\n';
  for (auto& child : node.children()) {
    print_model_node(child, level + 1);
  }
}
void setup_parent_pointers(std::vector<biogears::Tree<DataRequest>>& children, biogears::Tree<DataRequest>* p)
{
  for (auto itr = children.begin(); itr != children.end(); ++itr) {
    auto& value = itr->value();
    value.parent = p;
    if (!itr->children().empty()) {
      setup_parent_pointers(itr->children(), &*itr);
    }
  }
}
//-----------------------------------------------------------------------------
DataRequestModel::DataRequestModel(QObject* parent)
  : QAbstractItemModel(parent)
{
}
//-----------------------------------------------------------------------------
DataRequestModel::DataRequestModel(const biogears::Tree<DataRequest>& model, QObject* parent)
  : QAbstractItemModel(parent)
  , _data(model)
{
  setup_parent_pointers(_data.children(), nullptr);
  print_model_node(_data);
}
//-----------------------------------------------------------------------------
DataRequestModel::DataRequestModel(biogears::Tree<DataRequest>&& model, QObject* parent)
  : QAbstractItemModel(parent)
  , _data(std::move(model))
{
}
//-----------------------------------------------------------------------------
QModelIndex DataRequestModel::index(int row, int column,
  const QModelIndex& parent) const
{
  if (!hasIndex(row, column, parent))
    return QModelIndex();

  biogears::Tree<DataRequest> const* parentItem;

  if (!parent.isValid())
    parentItem = &_data;
  else
    parentItem = static_cast<biogears::Tree<DataRequest> const*>(parent.internalPointer());

  ;
  if (row < parentItem->children().size()) {
    return createIndex(row, column, static_cast<void*>(const_cast<biogears::Tree<DataRequest>*>(&parentItem->children()[row])));
  } else {
    return QModelIndex();
  }
}
//-----------------------------------------------------------------------------
QModelIndex DataRequestModel::parent(const QModelIndex& index) const
{
  if (!index.isValid())
    return QModelIndex();

  auto item = static_cast<biogears::Tree<DataRequest>*>(index.internalPointer());

  biogears::Tree<DataRequest>* parent = item->value().parent;

  if (nullptr == parent || nullptr == &_data) {
    return QModelIndex();
  }

  auto& children = parent->children();
  auto begin = children.begin();
  auto end = children.end();
  auto pos = std::find(begin, end, *item) - begin;
  return createIndex(pos, 0, static_cast<void*>(parent));
}
//-----------------------------------------------------------------------------
int DataRequestModel::rowCount(const QModelIndex& parent) const
{
  biogears::Tree<DataRequest> const * parentItem;

  if (!parent.isValid())
    parentItem = &_data;
  else
    parentItem = static_cast<biogears::Tree<DataRequest>*>(parent.internalPointer());

  return parentItem->children().size();
}
//-----------------------------------------------------------------------------

int DataRequestModel::columnCount(const QModelIndex& parent) const
{
  return 1;
}
//-----------------------------------------------------------------------------

QVariant DataRequestModel::data(const QModelIndex& index, int role) const
{
  auto item = static_cast<biogears::Tree<DataRequest> const*>(index.internalPointer());
  auto parent = item->value().parent;
  if ( nullptr != parent && parent->children().size() < index.row() ) {
    return QVariant();
  }

  switch (role) {
  case Qt::DisplayRole:
    return QString("%1").arg(item->value().name.c_str());
  case Qt::FontRole: {
    QFont font;

    if (item->children().empty()) {
      font.setBold(false);
    } else {
      font.setBold(true);
    }
    return font;
  } break;
  case Qt::BackgroundRole:
    break;
  case Qt::TextAlignmentRole:
    break;
  case Qt::CheckStateRole:
    break;
  default:
    break;
  }
  return QVariant();
}
//-----------------------------------------------------------------------------
std::string break_camel_case(const std::string& s)
{
  static std::regex regExp1{ R"((.)([A-Z][a-z]+))" };
  static std::regex regExp2{ R"(([a-z0-9])([A-Z]))" };

  auto result = std::regex_replace(s, regExp1, R"($1 $2)");
  result = std::regex_replace(result, regExp2, R"($1 $2)");

  return result;
}
//-----------------------------------------------------------------------------
std::string to_camel_case(const std::string& s)
{
  static std::regex rx{ '_' };
  auto result = std::regex_replace(s, rx, "");
  return result;
}
//-----------------------------------------------------------------------------
biogears::Tree<DataRequest> process_child(std::string prefix, biogears::Tree<std::string> subtree)
{
  biogears::Tree<DataRequest> model;
  model.value().name = break_camel_case(subtree.value());
  model.value().key = prefix;
  model.value().selected = false;
  for (auto& node : subtree) {
    if (node.children().empty()) {
      model.emplace_back(break_camel_case(node.value()), prefix + '_' + node.value(), false);
    } else {
      model.emplace_back(process_child(prefix + '_' + node.value(), node));
    }
  }
  return model;
}
//-----------------------------------------------------------------------------
std::unique_ptr<DataRequestModel> create_DataRequestModel(biogears::Tree<std::string> source)
{

  biogears::Tree<DataRequest> model;
  model.value().name = "Data Request";
  model.value().key = "DataRequest";
  for (auto& node : source) {
    if (node.children().empty()) {
      model.emplace_back(break_camel_case(node.value()), node.value(), false);
    } else {
      model.emplace_back(process_child(node.value(), node));
    }
  }
  auto drm = std::make_unique<DataRequestModel>(model);

  return drm;
}
//-----------------------------------------------------------------------------

} //namespace biogears_u