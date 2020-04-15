#pragma once

#include <QAbstractItemModel>
#include <QString>
#include <QVariant>
#include <QVector>

#include <biogears/cdm/properties/SEScalar.h>
#include <biogears/cdm/properties/SEUnitScalar.h>


class PhysiologyRequest {
public:
  enum Columns {
    PREFIX = Qt::UserRole + 1,
    NAME,
    VALUE,
    UNIT,
    FULLNAME,
    COLUMN_COUNT
  };
  enum PhysiologyRequestRoles {
    PrefixRole = Qt::UserRole + 1,
    RequestRole,
    ValueRole,
    UnitRole,
    FullNameRole
  };
  QHash<int, QByteArray> roleNames() const
  {
    QHash<int, QByteArray> roles;
    roles[PrefixRole] = "prefix";
    roles[RequestRole] = "request";
    roles[ValueRole] = "value";
    roles[UnitRole] = "unit";
    roles[FullNameRole] = "fullname";
    return roles;
  }

  PhysiologyRequest();
  PhysiologyRequest(QString prefix, QString name, PhysiologyRequest* parent = nullptr);
  ~PhysiologyRequest();

  int rows() const;
  int columns() const;
  PhysiologyRequest const* parent() const;
  PhysiologyRequest* parent();
  PhysiologyRequest* child( int row);
  PhysiologyRequest const* child(int row) const;

  QString header(int col) const;
  void append(QString prefix, QString name);
  void modify(int row, const biogears::SEUnitScalar* data);
  void modify(int row, const biogears::SEScalar* data);

  QVariant data(int role) const;

  bool operator==(const PhysiologyRequest& rhs)
  {
    return _name == rhs._name
      && _prefix == rhs._prefix;
  }
  bool operator!=(const PhysiologyRequest& rhs)
  {
    return !(*this == rhs);
  }
  void scalar(biogears::SEScalar const* given)
  {
    _value = given;
    _unit = nullptr;
  };
  void unit_scalar(biogears::SEUnitScalar const* given)
  {
    _unit = given;
    _value = nullptr;
  };

private:
  PhysiologyRequest* _parent = nullptr;

  QVector<PhysiologyRequest> _children;
  QString _prefix;
  QString _name;

  biogears::SEScalar const* _value = nullptr;
  biogears::SEUnitScalar const* _unit = nullptr;

};
