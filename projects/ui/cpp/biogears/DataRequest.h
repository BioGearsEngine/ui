#pragma once

#include <QVariant>
#include <QString>
#include <QVector>

#include <biogears/cdm/properties/SEScalar.h>
#include <biogears/cdm/properties/SEUnitScalar.h>

namespace bio {
class DataRequest {
public:
  explicit DataRequest(QString prefix, QString name, DataRequest* parent = nullptr);
  explicit DataRequest(QString prefix, QString name, const biogears::SEScalar* data, DataRequest* parent = nullptr);
  explicit DataRequest(QString prefix, QString name, const biogears::SEUnitScalar* data, DataRequest* parent = nullptr);
  ~DataRequest();

  void appendChild(DataRequest* child);

  DataRequest* child(int row);
  int childCount() const;
  int columnCount() const;
  QVariant data(int column) const;
  int row() const;
  DataRequest* parentItem();

private:
  DataRequest* _parent;
  QVector<DataRequest*> _children;
  QString _prefix;
  QString _name;
  biogears::SEScalar const *    _value;
  biogears::SEUnitScalar const* _unit;
};
}