#pragma once

#include <memory>

#include <QVariant>
#include <QString>
#include <QObject>
#include <QAbstractItemModel>

#include "Models/PhysiologyRequestModel.h"
#include "Models/SubstanceModel.h"
#include "Models/CustomWidgetModel.h"

namespace bio {

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

  explicit BioGearsData(QString name = "Unknown Patient", QObject* parent = nullptr);
  ~BioGearsData() override;

  enum  PhysiologyRequestRoles {
    PrefixRole = Qt::UserRole + 1,
    RequestRole,
    ValueRole,
    UnitRole,
    FullNameRole
  };

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


private:
  
    PhysiologyRequestModel* _vitals;
    PhysiologyRequestModel* _cardiopulmonary;
    PhysiologyRequestModel* _blood_chemistry;
    PhysiologyRequestModel* _renal;
    PhysiologyRequestModel* _energy_and_metabolism;
    PhysiologyRequestModel* _fluid_balance;
    SubstanceModel* _drugs;
    SubstanceModel* _substances;
    CustomWidgetModel* _panel;
};
}
