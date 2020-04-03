#include "DataRequest.h"

#include "QVariant"

namespace bio {
PhysiologyRequest::PhysiologyRequest(QString prefix, QString name, PhysiologyRequest* parent)
  : _parent(parent)
  , _prefix(prefix)
  , _name(name)
  , _value(nullptr)
  , _unit(nullptr)
{
}
PhysiologyRequest::PhysiologyRequest(QString prefix, QString name, const biogears::SEScalar* data, PhysiologyRequest* parent)
  : _parent(parent)
  , _prefix(prefix)
  , _name(name)
  , _value(data)
  , _unit(nullptr)
{
}
PhysiologyRequest::PhysiologyRequest(QString prefix, QString name, const biogears::SEUnitScalar* data, PhysiologyRequest* parent)
  : _parent(parent)
  , _prefix(prefix)
  , _name(name)
  , _value(nullptr)
  , _unit(data)
{
}
PhysiologyRequest::~PhysiologyRequest()
{
  qDeleteAll(_children);
}

void PhysiologyRequest::appendChild(PhysiologyRequest* item)
{
  _children.append(item);
}

void PhysiologyRequest::appendChild(std::unique_ptr<PhysiologyRequest>&& item)
{
  _children.append(item.release());
}

PhysiologyRequest const * PhysiologyRequest::child(int row) const
{
  if (row < 0 || row >= _children.size()) {
    return nullptr;
  }
  return _children.at(row);
}
PhysiologyRequest* PhysiologyRequest::child(int row)
{
  if (row < 0 || row >= _children.size()) {
    return nullptr;
  }
  return _children.at(row);
}
int PhysiologyRequest::childCount() const
{
  return _children.count();
}
int PhysiologyRequest::columnCount() const
{
  return Columns::COLUMN_COUNT;
}
QVariant PhysiologyRequest::data(int column) const
{
  if (column < 0 || column >= 4) {
    return QVariant();
  }
  switch(column) {
  case PREFIX:
    return QVariant(_prefix); // PREFIX ROLE
  case NAME:
    return QVariant(_name);   // NAME ROLE
  case VALUE:  //VALUE ROLE
    try {
      return (_unit) ? QVariant(_unit->GetValue()) : (_value)? QVariant(_value) : QVariant();
    } catch (biogears::CommonDataModelException e){
      return "NaN";
    }
  case UNIT:  //UNIT ROLE
    return (_unit) ? QVariant(_unit->GetUnit()->GetString()) : (_value) ? QVariant("") : QVariant();
  default:
    return QVariant(QString("%s_%s").arg(_prefix).arg(_name));
  }
}
PhysiologyRequest* PhysiologyRequest::parentItem()
{
  return _parent;
}
int PhysiologyRequest::row() const
{
  if (_parent) {
    return _parent->_children.indexOf(const_cast<PhysiologyRequest*>(this));
  }

  return 0;
}
} //namespace bio