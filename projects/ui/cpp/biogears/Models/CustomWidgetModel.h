#pragma once

#include <QVariant>
#include <QString>
#include <QVector>
#include <QAbstractItemModel>

#include <biogears/cdm/properties/SEScalar.h>
#include <biogears/cdm/properties/SEUnitScalar.h>

namespace bio {


class CustomWidgetModel : public QAbstractItemModel {
public:

  enum Columns {
    PREFIX,
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

  CustomWidgetModel(QString prefix, QString name, QAbstractItemModel* parent = nullptr);
  ~CustomWidgetModel() override;

  QVariant data(const QModelIndex& index, int role) const override;
  Qt::ItemFlags flags(const QModelIndex& index) const override;
  QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
  QModelIndex index(int row, int column, const QModelIndex& parent = QModelIndex()) const override;
  QModelIndex parent(const QModelIndex& indkoex) const override;
  int rowCount(const QModelIndex& parent = QModelIndex()) const override;
  int columnCount(const QModelIndex& parent = QModelIndex()) const override;

  void append(QString prefix, QString name, const biogears::SEScalar* data = nullptr);
  void append(QString prefix, QString name, const biogears::SEUnitScalar* data = nullptr);

  void modify(int row, const biogears::SEUnitScalar* data);
  void modify(int row, const biogears::SEScalar* data);

private:
  QAbstractItemModel* _parent;

  struct PhysiologyRequest {
    QString prefix;
    QString name;

    biogears::SEScalar const* value = nullptr;
    biogears::SEUnitScalar const* unit = nullptr;

    bool operator==(const PhysiologyRequest& rhs)
    {
      return name == rhs.name
        && prefix == rhs.prefix;
    }
    bool operator!=(const PhysiologyRequest& rhs)
    {
      return !(*this == rhs);
    }
    void scalar(biogears::SEScalar const* given)
    {
      value = given;
      unit = nullptr;
    };
    void unit_scalar(biogears::SEUnitScalar const* given)
    {
      unit = given;
      value = nullptr;
    };
  };

  QVector<PhysiologyRequest> _children;
  QVector<QVariant> _columns;
};
}