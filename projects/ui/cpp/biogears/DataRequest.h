#pragma once

#include <QVariant>
#include <QString>
#include <QVector>

#include <biogears/cdm/properties/SEScalar.h>
#include <biogears/cdm/properties/SEUnitScalar.h>

namespace bio {

enum Columns {
  PREFIX,
  NAME,
  VALUE,
  UNIT,
  FULLNAME,
  COLUMN_COUNT
};

class PhysiologyRequest {
public:
  explicit PhysiologyRequest(QString prefix, QString name, PhysiologyRequest* parent = nullptr);
  explicit PhysiologyRequest(QString prefix, QString name, const biogears::SEScalar* data, PhysiologyRequest* parent = nullptr);
  explicit PhysiologyRequest(QString prefix, QString name, const biogears::SEUnitScalar* data, PhysiologyRequest* parent = nullptr);
  ~PhysiologyRequest();

  bool operator==(const PhysiologyRequest& rhs)
  {
    return _name == rhs._name
      && _prefix == rhs._prefix;
  }
  bool operator!=(const PhysiologyRequest& rhs)
  {
    return !(*this == rhs);
  }
  void appendChild(PhysiologyRequest* child);
  void appendChild(std::unique_ptr<PhysiologyRequest>&& child);

  PhysiologyRequest* child(int row);
  PhysiologyRequest const * child(int row) const;
  int childCount() const;
  int columnCount() const;

  QVariant data(int column) const;

  int row() const;
  PhysiologyRequest* parentItem();

private:
  PhysiologyRequest* _parent;

  QVector<PhysiologyRequest*> _children;
  QVector<QVariant> _columns;

  QString _prefix;
  QString _name;
  biogears::SEScalar const *    _value;
  biogears::SEUnitScalar const* _unit;
};
}