#include "DataRequestModel.h"

namespace bio {
/// DataRequestModel Model

DataRequestModel::DataRequestModel(std::unique_ptr<DataRequest>&& model, QObject* parent)
  : QAbstractItemModel(parent)
  , _root(model.release())
{
}

DataRequestModel::~DataRequestModel()
{
  delete _root;
}

int DataRequestModel::columnCount(const QModelIndex& parent) const
{
  if (parent.isValid()) {
    return static_cast<DataRequest*>(parent.internalPointer())->columnCount();
  }
  return _root->columnCount();
}

QVariant DataRequestModel::data(const QModelIndex& index, int role) const
{
  if (!index.isValid()) {
    return QVariant();
  }

  if (role != Qt::DisplayRole) {
  return QVariant();
  }

  DataRequest* item = static_cast<DataRequest*>(index.internalPointer());

  return item->data(index.column());
}

Qt::ItemFlags DataRequestModel::flags(const QModelIndex& index) const
{
  if (!index.isValid()) {
    return Qt::NoItemFlags;
  }

  return QAbstractItemModel::flags(index);
}

QVariant DataRequestModel::headerData(int section, Qt::Orientation orientation, int role) const
{
  if (orientation == Qt::Horizontal && role == Qt::DisplayRole) {
    return _root->data(section);
  }

  return QVariant();
}

QModelIndex DataRequestModel::index(int row, int column, const QModelIndex& parent) const
{
  if (!hasIndex(row, column, parent))
    return QModelIndex();

  DataRequest* parentItem;

  if (!parent.isValid()) {
    parentItem = _root;
  } else {
    parentItem = static_cast<DataRequest*>(parent.internalPointer());
  }

  DataRequest* childItem = parentItem->child(row);
  if (childItem) {
    return createIndex(row, column, childItem);
  }
  return QModelIndex();
}

QModelIndex DataRequestModel::parent(const QModelIndex& index) const
{
  if (!index.isValid()) {
    return QModelIndex();
  }

  DataRequest* childItem = static_cast<DataRequest*>(index.internalPointer());
  DataRequest* parentItem = childItem->parentItem();

  if (parentItem == _root) {
    return QModelIndex();
  }

  return createIndex(parentItem->row(), 0, parentItem);
}

int DataRequestModel::rowCount(const QModelIndex& parent) const
{
  DataRequest* parentItem;
  if (parent.column() > 0) {
    return 0;
  }

  if (!parent.isValid()) {
    parentItem = _root;
  } else {
    parentItem = static_cast<DataRequest*>(parent.internalPointer());
  }

  return parentItem->childCount();
}


}