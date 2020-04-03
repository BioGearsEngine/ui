#include "DataRequestModel.h"

namespace bio {

PhysiologyModel& PhysiologyModel::add_category(QString name)
{
  auto  category = std::make_unique<PhysiologyRequest>( QString(""), name );
  _root.appendChild(category.release());
  return *this;
}
/// PhysiologyModel Model
PhysiologyModel::PhysiologyModel(QString name, QObject* parent)
  : QAbstractItemModel(parent)
  , _root("", name)
{
}
//------------------------------------------------------------------------------------
PhysiologyModel::~PhysiologyModel()
{
}
//------------------------------------------------------------------------------------
int PhysiologyModel::columnCount(const QModelIndex& parent) const
{
  if (parent.isValid()) {
    return static_cast<PhysiologyRequest*>(parent.internalPointer())->columnCount();
  }
  return _root.columnCount();
}
//------------------------------------------------------------------------------------
QVariant PhysiologyModel::data(const QModelIndex& index, int role) const
{
  if (!index.isValid()) {
    return QVariant();
  }

  if (role != Qt::DisplayRole) {
    return QVariant();
  }

  PhysiologyRequest* item = static_cast<PhysiologyRequest*>(index.internalPointer());
  switch (role) {
  case RequestRole:
    return static_cast<PhysiologyRequest*>(index.internalPointer())->data(Columns::NAME);
  case ValueRole:
    return static_cast<PhysiologyRequest*>(index.internalPointer())->data(Columns::VALUE);
  case UnitRole:
    return static_cast<PhysiologyRequest*>(index.internalPointer())->data(Columns::UNIT);
  case FullNameRole:
    return static_cast<PhysiologyRequest*>(index.internalPointer())->data(Columns::FULLNAME);
  }
  return item->data(index.column());
}
//------------------------------------------------------------------------------------
Qt::ItemFlags PhysiologyModel::flags(const QModelIndex& index) const
{
  if (!index.isValid()) {
    return Qt::NoItemFlags;
  }

  return QAbstractItemModel::flags(index);
}
//------------------------------------------------------------------------------------
QVariant PhysiologyModel::headerData(int section, Qt::Orientation orientation, int role) const
{
  if (orientation == Qt::Horizontal && role == Qt::DisplayRole) {
    return _root.data(section);
  }

  return QVariant();
}
//------------------------------------------------------------------------------------
QModelIndex PhysiologyModel::index(int row, int column, const QModelIndex& parent) const
{
  if (!hasIndex(row, column, parent)) {
    return QModelIndex();
  }

  PhysiologyRequest const* parentItem;

  if (!parent.isValid()) {
    parentItem = &_root;
  } else {
    parentItem = static_cast<PhysiologyRequest*>(parent.internalPointer());
  }

  PhysiologyRequest* childItem = const_cast<PhysiologyRequest*>(parentItem->child(row));
  if (childItem) {
    return createIndex(row, column, childItem);
  }
  return QModelIndex();
}
//------------------------------------------------------------------------------------
QModelIndex PhysiologyModel::parent(const QModelIndex& index) const
{
  if (!index.isValid()) {
    return QModelIndex();
  }

  PhysiologyRequest* childItem = static_cast<PhysiologyRequest*>(index.internalPointer());
  PhysiologyRequest* parentItem = childItem->parentItem();

  if (parentItem == &_root) {
    return QModelIndex();
  }

  return createIndex(parentItem->row(), 0, parentItem);
}
//------------------------------------------------------------------------------------
int PhysiologyModel::rowCount(const QModelIndex& parent) const
{
  PhysiologyRequest const * parentItem;
  if (parent.column() > 0) {
    return 0;
  }

  if (!parent.isValid()) {
    parentItem = &_root;
  } else {
    parentItem = static_cast<PhysiologyRequest*>(parent.internalPointer());
  }

  return parentItem->childCount();
}

}