#include "PhysiologyRequest.h"

#include "../BioGearsData.h"

#include <QDebug>
#include <QVariant>

PhysiologyRequest::PhysiologyRequest()
{
}
//------------------------------------------------------------------------------------
PhysiologyRequest::PhysiologyRequest(QString prefix, QString name, bool active, PhysiologyRequest* parent)
  : _parent(parent)
  , _name(name)
  , _active(active)
  , _prefix(prefix)
{
}
//------------------------------------------------------------------------------------
PhysiologyRequest::~PhysiologyRequest()
{
  _children.clear();
}
//------------------------------------------------------------------------------------
QString PhysiologyRequest::name() const
{
  return _name;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::name(const QString& value)
{
  _name = value;
}
//------------------------------------------------------------------------------------
bool PhysiologyRequest::active() const
{
  return _active;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::active(bool value)
{
  _active = value;
}
//------------------------------------------------------------------------------------
int PhysiologyRequest::rate() const
{
  return _refresh_rate;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::rate(int value)
{
  _refresh_rate = value;
}
//------------------------------------------------------------------------------------
int PhysiologyRequest::nested() const
{
  return _nested;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::nested(int value)
{
  _nested = value;
}
//------------------------------------------------------------------------------------
int PhysiologyRequest::rows() const
{
  return _children.size();
}
//------------------------------------------------------------------------------------
int PhysiologyRequest::columns() const
{
  return 5;
}
bool PhysiologyRequest::enabled() const
{
  return _active;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::enabled(bool value)
{
  _active = value;
}
//------------------------------------------------------------------------------------
bool PhysiologyRequest::custom() const
{
  return _custom;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::custom(std::function<double(void)>&& value, std::function<QString(void)>&& unit)
{
  _custom = true;
  _customValueFunc = value;
  _customUnitFunc = unit;
}
//------------------------------------------------------------------------------------
biogears::SEUnitScalar const* PhysiologyRequest::unit_scalar() const
{
  return _unit;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::unit_scalar(biogears::SEUnitScalar* value)
{
  _unit = value;
}
//------------------------------------------------------------------------------------
biogears::SEScalar const* PhysiologyRequest::scalar() const
{
  return _value;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::scalar(biogears::SEScalar* value)
{
  _value = value;
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
  case 5:
    return "Refresh Rate";
    break;
  case 6:
    return "Nested";
    break;
  default:
    return "";
  }
}
//------------------------------------------------------------------------------------
PhysiologyRequest* PhysiologyRequest::append(QString prefix, QString name, bool active)
{
  PhysiologyRequest request;
  request._prefix = prefix;
  request._name = name;
  request._parent = this;
  request._active = active;
  _children.append(request);
  return &_children.back();
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
void PhysiologyRequest::modify(int row, int refreshRate)
{
  if (0 <= row && row < _children.size()) {
    _children[row]._refresh_rate = refreshRate;
  }
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::modify(int row, bool enabled)
{
  if (0 <= row && row < _children.size()) {
    _children[row]._active = enabled;
  }
}
//------------------------------------------------------------------------------------
#pragma optimize("", off)
QVariant PhysiologyRequest::data(int role) const
{
  switch (role) {
  case BioGearsData::PrefixRole:
    return QVariant(_prefix); // PREFIX ROLE
  case BioGearsData::RequestRole:
  case Qt::DisplayRole:
    return QVariant(_name);
  case BioGearsData::ValueRole: //VALUE ROLE
    if (_custom) {
      return _customValueFunc();
    } else {
      try {
        return (_unit) ? QVariant(_unit->GetValue()) : (_value) ? QVariant(_value->GetValue()) : QVariant(0.0);
      } catch (biogears::CommonDataModelException e) {
        return "NaN";
      }
    }
  case BioGearsData::UnitRole: //UNIT ROLE
    if (_custom) {
      return _customUnitFunc();
    } else {
      return (_unit) ? QVariant(_unit->GetUnit()->GetString()) : (_value) ? QVariant("") : QVariant("");
    }
  case BioGearsData::EnabledRole:
    return _active;
  case BioGearsData::RowRole:
    return _children.size();
  case BioGearsData::RateRole:
    return _refresh_rate;
  case BioGearsData::NestedRole:
    return _nested;
  case BioGearsData::ChildrenRole:
    return _children.size();
  case BioGearsData::ColumnRole:
    return 4;
  default:
    return QVariant();
  }
}
#pragma optimize("", on)
//------------------------------------------------------------------------------------
