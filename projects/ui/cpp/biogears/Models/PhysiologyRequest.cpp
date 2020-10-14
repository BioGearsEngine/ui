#include "PhysiologyRequest.h"

#include "../BioGearsData.h"

#include <QDebug>
#include <QVariant>
#include <QRegularExpression>

PhysiologyRequest::PhysiologyRequest()
{
}
//------------------------------------------------------------------------------------
PhysiologyRequest::PhysiologyRequest(QString prefix, QString name, bool enabled, PhysiologyRequest* parent)
  : _parent(parent)
  , _name(name)
  , _enabled(enabled)
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
QString PhysiologyRequest::display_name() const
{
  return _display_name;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::display_name(const QString& value)
{
  _display_name = value;
}
//------------------------------------------------------------------------------------
bool PhysiologyRequest::usable() const
{
  return _usable;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::usable(bool value)
{
  _usable = value;
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
//------------------------------------------------------------------------------------
bool PhysiologyRequest::enabled() const
{
  return _enabled;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::enabled(bool value)
{
  _enabled = value;
}
//------------------------------------------------------------------------------------
bool PhysiologyRequest::auto_scale() const
{
  return _auto_scale;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::auto_scale(bool value)
{
  _auto_scale = value;
}
//------------------------------------------------------------------------------------
double PhysiologyRequest::y_max() const
{
  return _y_max;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::y_max(double value)
{
  _y_max = value;
}
//------------------------------------------------------------------------------------
double PhysiologyRequest::y_min() const
{
  return _y_min;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::y_min(double value)
{
  _y_min = value;
}
//------------------------------------------------------------------------------------
double PhysiologyRequest::x_interval() const
{
  return _x_interval;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::x_interval(double value)
{
  _x_interval = value;
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
  return _unit_scalar;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::unit_scalar(biogears::SEUnitScalar* value)
{
  _unit_scalar = value;
  if (_unit_scalar->GetUnit()) {
    _unit = _unit_scalar->GetUnit()->GetString();
    _unit_override = false;
  }
  
}
//------------------------------------------------------------------------------------
QString PhysiologyRequest::unit() const
{
  return _unit;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::unit(QString u)
{
  if (_unit_scalar) {
    _unit = u;
    if (_unit != _unit_scalar->GetUnit()->GetString()) {
      _unit_override = true;
    }
  }
}
//------------------------------------------------------------------------------------
biogears::SEScalar const* PhysiologyRequest::scalar() const
{
  return _scalar;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::scalar(biogears::SEScalar* value)
{
  _scalar = value;
  _unit = "";
  _unit_override = false;
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::clear()
{
  _children.clear();
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
  case 7:
    return "Auto Scale";
    break;
  case 8:
    return "Y Max";
    break;
  case 9:
    return "Y Min";
    break;
  case 10:
    return "X Interval";
    break;
  default:
    return "";
  }
}
//------------------------------------------------------------------------------------
PhysiologyRequest* PhysiologyRequest::append(QString prefix, QString name, QString display, bool enabled, bool usable)
{
  PhysiologyRequest request;
  request._prefix = prefix;
  request._name = name;
  if (display.isEmpty()) {
    QString temp = request._name;
    request._display_name = temp.replace(QRegularExpression("([a-z])([A-Z])"), "\\1 \\2");
  } else {
    request._display_name = display;
  }
  request._parent = this;
  request._enabled = enabled;
  request._usable = usable;
  _children.append(request);
  return &_children.back();
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::modify(int row, const biogears::SEUnitScalar* data)
{
  if (0 <= row && row < _children.size()) {
    _children[row]._unit_scalar = data;
  }
}
//------------------------------------------------------------------------------------
void PhysiologyRequest::modify(int row, const biogears::SEScalar* data)
{
  if (0 <= row && row < _children.size()) {
    _children[row]._scalar = data;
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
    _children[row]._enabled = enabled;
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
    return QVariant(_name);
  case Qt::DisplayRole:
    return QVariant(_display_name);
  case BioGearsData::ValueRole: //VALUE ROLE
    if (_custom) {
      return _customValueFunc();
    } else {
      try {
        if (_unit_scalar) {
          if (_unit_override) {
            return QVariant(biogears::Convert(_unit_scalar->GetValue(), _unit_scalar->GetUnit()->GetString(), biogears::CCompoundUnit(_unit.toStdString())));
          } else {
            return QVariant(_unit_scalar->GetValue());
          }
        } else if (_scalar) {
          return QVariant(_scalar->GetValue());
        } else {
          return QVariant(0.0);
        }
      } catch (biogears::CommonDataModelException e) {
        return "NaN";
      }
    }
  case BioGearsData::UnitRole: //UNIT ROLE
    if (_custom) {
      return _customUnitFunc();
    } else {
      return (_unit_scalar) ? QVariant(_unit) : QVariant("");
    }
  case BioGearsData::UsableRole:
    return _usable;
  case BioGearsData::EnabledRole:
    return _enabled;
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
  case BioGearsData::AutoScaleRole:
    return _auto_scale;
  case BioGearsData::YMaxRole:
    return _y_max;
  case BioGearsData::YMinRole:
    return _y_min;
  case BioGearsData::XIntervalRole:
    return _x_interval;
  default:
    return QVariant();
  }
}
#pragma optimize("", on)
//------------------------------------------------------------------------------------
