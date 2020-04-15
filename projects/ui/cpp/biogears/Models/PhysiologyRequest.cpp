#include "PhysiologyRequest.h"

#include <QVariant>

PhysiologyRequest::PhysiologyRequest()
{
}
//------------------------------------------------------------------------------------
PhysiologyRequest::PhysiologyRequest(QString prefix, QString name, PhysiologyRequest* parent)
  : _parent(parent)
{
}
//------------------------------------------------------------------------------------
PhysiologyRequest::~PhysiologyRequest()
{
  _children.clear();
}
//------------------------------------------------------------------------------------
int PhysiologyRequest::rows() const
{
  return _children.size();
}
//------------------------------------------------------------------------------------
int PhysiologyRequest::columns() const
{
  return COLUMN_COUNT;
}
//------------------------------------------------------------------------------------
PhysiologyRequest const* PhysiologyRequest::parent() const
{
  return _parent;
}
//------------------------------------------------------------------------------------
PhysiologyRequest* PhysiologyRequest::parent()
{
  return _parent;
}
//------------------------------------------------------------------------------------
PhysiologyRequest* PhysiologyRequest::child(int index)
{
  if (0 <= index && index <= _children.size()) {
    return &_children[index];
  }
  return nullptr;
}
//------------------------------------------------------------------------------------
PhysiologyRequest const* PhysiologyRequest::child(int index) const
{
  if (0 <= index && index <= _children.size()) {
    return &_children[index];
  }
  return nullptr;
}
//------------------------------------------------------------------------------------
auto PhysiologyRequest::header(int section) const -> QString
{
  switch (section) {
  case 0:
    return "Prefix";
    break;
  case 1:
    return "Request";
    break;
  case 2:
    return "Value";
    break;
  case 3:
    return "Unit";
    break;
  case 4:
    return "Full Name";
    break;
  default:
    return "";
  }
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::append(QString prefix, QString name)
{
  PhysiologyRequest request;
  request._prefix = prefix;
  request._name = name;
  _children.append(request);
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::modify(int row, const biogears::SEUnitScalar* data)
{
  if (0 <= row && row < _children.size()) {
    _children[row]._unit = data;
  }
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::modify(int row, const biogears::SEScalar* data)
{
  if (0 <= row && row < _children.size()) {
    _children[row]._value = data;
  }
}
//------------------------------------------------------------------------------------
QVariant PhysiologyRequest::data(int role) const
{
  switch (role) {
  case PREFIX:
    return QVariant(_prefix); // PREFIX ROLE
  case NAME:
    return QVariant(_name);
  case VALUE: //VALUE ROLE
    try {
      return (_unit) ? QVariant(_unit->GetValue()) : (_value) ? QVariant(_value) : QVariant();
    } catch (biogears::CommonDataModelException e) {
      return "NaN";
    }
  case UNIT: //UNIT ROLE
    return (_unit) ? QVariant(_unit->GetUnit()->GetString()) : (_value) ? QVariant("") : QVariant();
  default:
    return QVariant(QString("%s_%s").arg(_prefix).arg(_name));
  }
}
//------------------------------------------------------------------------------------
