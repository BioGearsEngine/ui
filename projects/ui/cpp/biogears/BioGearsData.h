#pragma once

#include <memory>

#include <QAbstractItemModel>
#include <QObject>
#include <QString>
#include <QVariant>

#include "Models/PhysiologyRequest.h"

class BioGearsData : public QAbstractItemModel {
  Q_OBJECT

public:
  enum Categories {
    VITALS = 0,
    CARDIOPULMONARY,
    BLOOD_CHEMISTRY,
    RENAL,
    ENERGY_AND_METABOLISM,
    FLUID_BALANCE,
    DRUGS,
    SUBSTANCES,
    PANELS,
    TOTAL_CATEGORIES
  };

  explicit BioGearsData();
  explicit BioGearsData(QString name, QObject* parent);
  explicit BioGearsData(QString name, BioGearsData* parent);
  ~BioGearsData() override;
  void initialize();

  enum PhysiologyRequestRoles {
    PrefixRole = Qt::UserRole + 1,
    RequestRole,
    ValueRole,
    UnitRole,
    FullNameRole
  };

  Q_INVOKABLE int categories();
  Q_INVOKABLE BioGearsData* category(int category);

  QVariant data(int role) const;
  QVariant data(const QModelIndex& index, int role) const override;
  Qt::ItemFlags flags(const QModelIndex& index) const override;
  QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
  QModelIndex index(int row, int column, const QModelIndex& parent = QModelIndex()) const override;
  QModelIndex parent(const QModelIndex& index) const override;
  int rowCount(const QModelIndex& parent = QModelIndex()) const override;
  int columnCount(const QModelIndex& parent = QModelIndex()) const override;

  QModelIndex index(QAbstractItemModel const* model) const;

  QHash<int, QByteArray> roleNames() const
  {
    QHash<int, QByteArray> roles;
    roles[Qt::DisplayRole] = "name";
    roles[PrefixRole] = "prefix";
    roles[RequestRole] = "request";
    roles[ValueRole] = "value";
    roles[UnitRole] = "unit";
    roles[FullNameRole] = "fullname";
    return roles;
  }

  void append(QString prefix, QString name);
  PhysiologyRequest const* child(int row) const;
  PhysiologyRequest* child(int row);

private:
  QString _name;

  BioGearsData* _rootModel = nullptr;
  PhysiologyRequest _rootRequest;

  BioGearsData* _vitals = nullptr;
  BioGearsData* _cardiopulmonary = nullptr;
  BioGearsData* _blood_chemistry = nullptr;
  BioGearsData* _renal = nullptr;
  BioGearsData* _energy_and_metabolism = nullptr;
  BioGearsData* _fluid_balance = nullptr;
  BioGearsData* _drugs = nullptr;
  BioGearsData* _substances = nullptr;
  BioGearsData* _panels = nullptr;
};
