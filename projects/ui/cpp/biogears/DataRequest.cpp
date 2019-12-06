#include "DataRequest.h"

#include "QVariant"

namespace bio {
DataRequest::DataRequest(QString prefix, QString name, DataRequest* parent)
  : _parent(parent)
  , _prefix(prefix)
  , _name(name)
  , _value(nullptr)
  , _unit(nullptr)
{
}
DataRequest::DataRequest(QString prefix, QString name, const biogears::SEScalar* data, DataRequest* parent)
  : _parent(parent)
  , _prefix(prefix)
  , _name(name)
  , _value(data)
  , _unit(nullptr)
{
}
DataRequest::DataRequest(QString prefix, QString name, const biogears::SEUnitScalar* data, DataRequest* parent)
  : _parent(parent)
  , _prefix(prefix)
  , _name(name)
  , _value(nullptr)
  , _unit(data)
{
}
DataRequest::~DataRequest()
{
  qDeleteAll(_children);
}
void DataRequest::appendChild(DataRequest* item)
{
  _children.append(item);
}
DataRequest* DataRequest::child(int row)
{
  if (row < 0 || row >= _children.size()) {
    return nullptr;
  }
  return _children.at(row);
}
int DataRequest::childCount() const
{
  return _children.count();
}
int DataRequest::columnCount() const
{
  return 4;
}
QVariant DataRequest::data(int column) const
{
  if (column < 0 || column >= 4) {
    return QVariant();
  }
  switch(column) {
  case 0:
    return QVariant(_prefix); // PREFIX ROLE
  case 1:
    return QVariant(_name);   // NAME ROLE
  case 2:  //VALUE ROLE
    try {
      return (_unit) ? QVariant(_unit->GetValue()) : (_value)? QVariant(_value) : QVariant();
    } catch (biogears::CommonDataModelException e){
      return "NaN";
    }
  case 3:  //UNIT ROLE
    return (_unit) ? QVariant(_unit->GetUnit()->GetString()) : (_value) ? QVariant("") : QVariant();
  default:
    return QVariant(QString("%s_%s").arg(_prefix).arg(_name));
  }
}
DataRequest* DataRequest::parentItem()
{
  return _parent;
}
int DataRequest::row() const
{
  if (_parent) {
    return _parent->_children.indexOf(const_cast<DataRequest*>(this));
  }

  return 0;
}
} //namespace ui