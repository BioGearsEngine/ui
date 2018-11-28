#ifndef BIOGEARSUI_PHYS_DATA_REQUEST_MODEL_H
#define BIOGEARSUI_PHYS_DATA_REQUEST_MODEL_H

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
#include <string>
#include <QAbstractItemModel>

#include <biogears/container/Tree.h>
namespace biogears_ui
{
  struct DataRequest
  {
    DataRequest() = default;
    DataRequest(const DataRequest&) = default;
    DataRequest(DataRequest&&) = default;
    DataRequest(std::string n, std::string k, bool s, biogears::Tree<DataRequest>* p = nullptr)
      : name(n),key(k),selected(s),parent(p)
    {}

    std::string name;
    std::string key;
    bool selected;
    biogears::Tree<DataRequest>* parent;

    bool operator==(const DataRequest& rhs) const
    {
      return name == rhs.name
        && key == rhs.key
        && selected == selected
        && &*parent == &*parent;
    }
    bool operator!=(const DataRequest& rhs) const
    {
      return !(*this == rhs);
    }
  };

  class DataRequestModel : public QAbstractItemModel {
    Q_OBJECT
  public:

    DataRequestModel(QObject *parent = nullptr);
    DataRequestModel(const biogears::Tree<DataRequest>& model, QObject *parent = nullptr);
    DataRequestModel(biogears::Tree<DataRequest>&& model, QObject *parent = nullptr);
    
    QModelIndex index(int row, int column,
      const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &child) const override;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
  private:
    biogears::Tree<DataRequest> _data;
  };

  std::unique_ptr<DataRequestModel> create_DataRequestModel(biogears::Tree<std::string>);
} //namespace biogears_ui

#endif //BIOGEARSUI_PHYS_DATA_REQUEST_MODEL_H