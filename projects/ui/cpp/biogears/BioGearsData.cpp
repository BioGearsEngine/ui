#include "BioGearsData.h"

namespace bio {

/// BioGearsData Model
BioGearsData::BioGearsData(QString name, QObject* parent)
  : QAbstractItemModel(parent)
  , _vitals(new PhysiologyRequestModel("", "Vitals", this))
  , _cardiopulmonary(new PhysiologyRequestModel("", "Cardiopulmonary", this))
  , _blood_chemistry(new PhysiologyRequestModel("", "Blood Chemistry", this))
  , _renal(new PhysiologyRequestModel("", "Renal", this))
  , _energy_and_metabolism(new PhysiologyRequestModel("", "Energy and Metabolism", this))
  , _fluid_balance(new PhysiologyRequestModel("", "Fluid Balance", this))
  , _drugs(new SubstanceModel("", "Drigs", this))
  , _substances(new SubstanceModel("", "Substances", this))
  , _panel(new CustomWidgetModel("", "Panel", this))
{
}
//------------------------------------------------------------------------------------
BioGearsData::~BioGearsData()
{
  _vitals->deleteLater();
  _cardiopulmonary->deleteLater();
  _blood_chemistry->deleteLater();
  _renal->deleteLater();
  _energy_and_metabolism->deleteLater();
  _fluid_balance->deleteLater();
  _drugs->deleteLater();
  _substances->deleteLater();
  _panel->deleteLater();
}
//------------------------------------------------------------------------------------
int BioGearsData::rowCount(const QModelIndex& parent) const
{
  QAbstractItemModel const* parentItem;
  if (!parent.isValid()) {
    return TOTAL_CATEGORIES;
  } else {
    parentItem = static_cast<QAbstractItemModel*>(parent.internalPointer());
  }

  return parentItem->rowCount();
}
//------------------------------------------------------------------------------------
int BioGearsData::columnCount(const QModelIndex& index) const
{
  if (!index.isValid()) {
    return 0;
  } else {
    auto parent = static_cast<QAbstractItemModel*>(index.internalPointer());
    if (parent->parent(index).internalPointer() == this) {
      switch ( index.row() ) {
      default:
        return 0;
      case VITALS:
        return _vitals->columnCount();
      case CARDIOPULMONARY:
        return _cardiopulmonary->columnCount();
      case BLOOD_CHEMISTRY:
        return _blood_chemistry->columnCount();
      case RENAL:
        return _renal->columnCount();
      case ENERGY_AND_METABOLISM:
        return _energy_and_metabolism->columnCount();
      case FLUID_BALANCE:
        return _fluid_balance->columnCount();
      case DRUGS:
        return _drugs->columnCount();
      case SUBSTANCES:
        return _substances->columnCount();
      case PANELS:
        return _panel->columnCount();
      }
    }
  }
  return 0;
}

//------------------------------------------------------------------------------------
QVariant BioGearsData::data(const QModelIndex& index, int role) const
{
  if (!index.isValid()) {
    return QVariant();
  }

  if (index.internalPointer() == this && role == Qt::DisplayRole) {
    auto* item = static_cast<PhysiologyRequestModel*>(index.internalPointer());

    switch (index.row()) {
    case VITALS:
      return "Vitals";
    case CARDIOPULMONARY:
      return "Cardiopulmonary";
    case BLOOD_CHEMISTRY:
      return "Blood Chemistry";
    case RENAL:
      return "Renal";
    case ENERGY_AND_METABOLISM:
      return "Energy and Metabolism";
    case FLUID_BALANCE:
      return "Fluid Balance";
    case DRUGS:
      return "Drugs";
    case SUBSTANCES:
      return "Substances";
    case PANELS:
      return "Panels";
    }
  } else {
    if (_vitals == index.internalPointer()) {
      return _vitals->data(index, role);
    } else if (_cardiopulmonary == index.internalPointer()) {
      return _cardiopulmonary->data(index, role);
    } else if (_blood_chemistry == index.internalPointer()) {
      return _blood_chemistry->data(index, role);
    } else if (_renal == index.internalPointer()) {
      return _renal->data(index, role);
    } else if (_energy_and_metabolism == index.internalPointer()) {
      return _energy_and_metabolism->data(index, role);
    } else if (_fluid_balance == index.internalPointer()) {
      return _fluid_balance->data(index, role);
    } else if (_drugs == index.internalPointer()) {
      return _drugs->data(index, role);
    } else if (_substances == index.internalPointer()) {
      return _substances->data(index, role);
    } else if (_panel == index.internalPointer()) {
      return _panel->data(index, role);
    }
  }
  return QVariant();
}

//------------------------------------------------------------------------------------
Qt::ItemFlags BioGearsData::flags(const QModelIndex& index) const
{
  if (!index.isValid()) {
    return Qt::NoItemFlags;
  }

  return QAbstractItemModel::flags(index);
}
//------------------------------------------------------------------------------------
QVariant BioGearsData::headerData(int section, Qt::Orientation orientation, int role) const
{
  if (orientation == Qt::Horizontal && role == Qt::DisplayRole) {
    switch (section) {
    default:
    case 0:
      return "Category";
    }
  }

  return QVariant();
}
//------------------------------------------------------------------------------------
QModelIndex BioGearsData::index(int row, int column, const QModelIndex& parent) const
{
  if (!hasIndex(row, column, parent)) {
    return QModelIndex();
  }

  QAbstractItemModel const* childItem;

  if (!parent.isValid()) {
    switch (row) {
    case VITALS:
      childItem = _vitals;
      break;
    case CARDIOPULMONARY:
      childItem = _cardiopulmonary;
      break;
    case BLOOD_CHEMISTRY:
      childItem = _blood_chemistry;
      break;
    case RENAL:
      childItem = _renal;
      break;
    case ENERGY_AND_METABOLISM:
      childItem = _energy_and_metabolism;
      break;
    case FLUID_BALANCE:
      childItem = _fluid_balance;
      break;
    case DRUGS:
      childItem = _drugs;
      break;
    case SUBSTANCES:
      childItem = _substances;
      break;
    case PANELS:
      childItem = _panel;
      break;
    }
  } else {
    auto parentItem = static_cast<QAbstractItemModel*>(parent.internalPointer());

    //TODO: Review this approach?
    if (auto category = dynamic_cast<PhysiologyRequestModel*>(parentItem)) {
      return category->index(row, column, parent);
    } else if (auto substance = dynamic_cast<SubstanceModel*>(parentItem)) {
      return substance->index(row, column, parent);
    } else if (auto widgets = dynamic_cast<CustomWidgetModel*>(parentItem)) {
      return widgets->index(row, column, parent);
    }
  }

  if (childItem) {
    return createIndex(row, column, const_cast<QAbstractItemModel*>(childItem));
  }
  return QModelIndex();
}
//------------------------------------------------------------------------------------
QModelIndex BioGearsData::parent(const QModelIndex& index) const
{
  if (!index.isValid()) {
    return QModelIndex();
  }

  QAbstractItemModel* child = static_cast<QAbstractItemModel*>(index.internalPointer());
  if (child == this) {
    QModelIndex();
  }
  return child->parent(index);
}
//------------------------------------------------------------------------------------
QModelIndex BioGearsData::index(QAbstractItemModel const* model) const
{
  if (_vitals == model) {
    return createIndex(0, 0, _vitals);
  } else if (_cardiopulmonary == model) {
    return createIndex(0, 0, _cardiopulmonary);
  }
  if (_blood_chemistry == model) {
    return createIndex(0, 0, _blood_chemistry);
  }
  if (_renal == model) {
    return createIndex(0, 0, _renal);
  }
  if (_energy_and_metabolism == model) {
    return createIndex(0, 0, _energy_and_metabolism);
  }
  if (_fluid_balance == model) {
    return createIndex(0, 0, _fluid_balance);
  }
  if (_drugs == model) {
    return createIndex(0, 0, _drugs);
  }
  if (_substances == model) {
    return createIndex(0, 0, _substances);
  }
  if (_panel == model) {
    return createIndex(0, 0, _panel);
  } else
    return QModelIndex();
}
}