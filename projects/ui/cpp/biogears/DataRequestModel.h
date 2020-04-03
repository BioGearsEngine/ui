#pragma once

#include <memory>

#include <QVariant>
#include <QString>
#include <QObject>
#include <QAbstractItemModel>

#include "DataRequest.h"

namespace bio {

class PhysiologyModel : public QAbstractItemModel {
  Q_OBJECT

public:
  explicit PhysiologyModel(QString name = "Unknown Patient", QObject* parent = nullptr);
  ~PhysiologyModel();

  enum  PhysiologyRequestRoles {
    PrefixRole = Qt::UserRole + 1,
    RequestRole,
    ValueRole,
    UnitRole,
    FullNameRole
  };

  PhysiologyModel& add_category(QString name);

  QVariant data(const QModelIndex& index, int role) const override;
  Qt::ItemFlags flags(const QModelIndex& index) const override;
  QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
  QModelIndex index(int row, int column, const QModelIndex& parent = QModelIndex()) const override;
  QModelIndex parent(const QModelIndex& indkoex) const override;
  int rowCount(const QModelIndex& parent = QModelIndex()) const override;
  int columnCount(const QModelIndex& parent = QModelIndex()) const override;

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


private:
  
  PhysiologyRequest _root;
};
}