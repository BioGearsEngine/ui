#include "BioGearsData.h"

/// BioGearsData Model
///
BioGearsData::BioGearsData()
  : QAbstractItemModel(nullptr)
  , _rootRequest("", "", nullptr)
{
    
}

BioGearsData::BioGearsData(QString n, QObject* p)
  : QAbstractItemModel(p)
  , _rootRequest("", n, nullptr)
  , _name(n)
{
}

BioGearsData::BioGearsData(QString n, BioGearsData* p)
  : QAbstractItemModel(p)
  , _rootModel(p)
  , _name(n)
  , _rootRequest("", n, nullptr)
{
}

int BioGearsData::categories()
{
  return TOTAL_CATEGORIES;
}

BioGearsData* BioGearsData::category(Categories category)
{
  switch (category)
  {
  case VITALS:
    return _vitals;
  case CARDIOPULMONARY:
    return _cardiopulmonary;
  case BLOOD_CHEMISTRY:
    return _blood_chemistry;
  case RENAL:
    return _renal;
  case ENERGY_AND_METABOLISM:
    return _energy_and_metabolism;
  case FLUID_BALANCE:
    return _fluid_balance;
  case DRUGS:
    return _drugs;
  case SUBSTANCES:
    return _substances;
  case PANELS:
    return _panels;
  default:
    return nullptr;
  }
}

void BioGearsData::initialize()
{
  _vitals = new BioGearsData("Vitals", this);
  _cardiopulmonary = new BioGearsData("Cardiopulmonary", this);
  _blood_chemistry = new BioGearsData("Blood Chemistry", this);
  _renal = new BioGearsData("Renal", this);
  _energy_and_metabolism = new BioGearsData("Energy and Metabolism", this);
  _fluid_balance = new BioGearsData("Fluid Balance", this);
  _drugs = new BioGearsData("Drugs", this);
  _substances = new BioGearsData("Substances", this);
  _panels = new BioGearsData("Panels", this);

  _vitals->append(QString("Vitals"), QString("SystolicArterialPressure"));
  _vitals->append(QString("Vitals"), QString("DiastolicArterialPressure"));
  _vitals->append(QString("Vitals"), QString("RespirationRate"));
  _vitals->append(QString("Vitals"), QString("OxygenSaturation"));
  _vitals->append(QString("Vitals"), QString("BloodVolume"));
  _vitals->append(QString("Vitals"), QString("CentralVenousPressure"));

  _cardiopulmonary->append(QString("Cardiopulmonary"), QString("Cerebral Perfusion Pressure"));
  _cardiopulmonary->append(QString("Cardiopulmonary"), QString("Intracranial Pressure"));
  _cardiopulmonary->append(QString("Cardiopulmonary"), QString("Systemic Vascular Resistance"));
  _cardiopulmonary->append(QString("Cardiopulmonary"), QString("Pulse Pressure"));
  _cardiopulmonary->append(QString("Cardiopulmonary"), QString("IE Ratio"));
  _cardiopulmonary->append(QString("Cardiopulmonary"), QString("Total Pulmonary Ventilation"));
  _cardiopulmonary->append(QString("Cardiopulmonary"), QString("Lung Volume"));
  _cardiopulmonary->append(QString("Cardiopulmonary"), QString("Tidal Volume"));
  _cardiopulmonary->append(QString("Cardiopulmonary"), QString("Alveolar Ventilation"));
  _cardiopulmonary->append(QString("Cardiopulmonary"), QString("Dead Space Ventlation"));
  _cardiopulmonary->append(QString("Cardiopulmonary"), QString("Transpulmonary Pressure"));

  _blood_chemistry->append(QString("Blood Chemistry"), QString("Carbon Dioxide Saturation"));
  _blood_chemistry->append(QString("Blood Chemistry"), QString("Carbon Monoxide Saturation"));
  _blood_chemistry->append(QString("Blood Chemistry"), QString("Oxygen Saturation"));
  _blood_chemistry->append(QString("Blood Chemistry"), QString("Blood PH"));
  _blood_chemistry->append(QString("Blood Chemistry"), QString("Hematocrit"));
  _blood_chemistry->append(QString("Blood Chemistry"), QString("Strong Ion Difference"));

  _renal->append(QString("Renal"), QString("Mean Urine Output"));
  _renal->append(QString("Renal"), QString("Urine ProductionRate"));
  _renal->append(QString("Renal"), QString("Urine Volume"));
  _renal->append(QString("Renal"), QString("Urine Osmolality"));
  _renal->append(QString("Renal"), QString("Urine Osmolarity"));
  _renal->append(QString("Renal"), QString("Glomerular Filtration Rate"));
  _renal->append(QString("Renal"), QString("Renal Blood Flow"));

  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("Core Temperature"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("Sweat Rate"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("Skin Temperature"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("Total Metabolic Rate"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("Stomach Contents"));
  auto stomach_contents = _energy_and_metabolism->child(4);
  {
    stomach_contents->append(QString("Stomach Contents"), QString("Calcium"));
    stomach_contents->append(QString("Stomach Contents"), QString("Carbohydrates"));
    stomach_contents->append(QString("Stomach Contents"), QString("Fat"));
    stomach_contents->append(QString("Stomach Contents"), QString("Protein"));
    stomach_contents->append(QString("Stomach Contents"), QString("Sodium"));
    stomach_contents->append(QString("Stomach Contents"), QString("Water"));
  }
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("Oxygen Consumption Rate"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("CO2 Production Rate"));

  _fluid_balance->append(QString("Fluid Balance"), QString("Total Body Fluid"));
  _fluid_balance->append(QString("Fluid Balance"), QString("ExtracellularFluidVolume"));
  _fluid_balance->append(QString("Fluid Balance"), QString("IntracellularFluidVolume"));
  _fluid_balance->append(QString("Fluid Balance"), QString("ExtravascularFluidVolume"));

  _drugs->append(QString("Drugs"), QString("Cerebral Perfusion Pressure"));

  _substances->append(QString("Substances"), QString("Cerebral Perfusion Pressure"));

  _panels->append(QString("Panels"), QString("Renal"));
  _panels->append(QString("Panels"), QString("Metabolic"));
  _panels->append(QString("Panels"), QString("Pulmonary Function Test"));
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
  _panels->deleteLater();
}
//------------------------------------------------------------------------------------
int BioGearsData::rowCount(const QModelIndex& index) const
{
  if (!index.isValid()) {
    return TOTAL_CATEGORIES;
  } else {
    if (_vitals == index.internalPointer()) {
      return _vitals->_rootRequest.rows();
    } else if (_cardiopulmonary == index.internalPointer()) {
      return _cardiopulmonary->_rootRequest.rows();
    } else if (_blood_chemistry == index.internalPointer()) {
      return _blood_chemistry->_rootRequest.rows();
    } else if (_renal == index.internalPointer()) {
      return _renal->_rootRequest.rows();
    } else if (_energy_and_metabolism == index.internalPointer()) {
      return _energy_and_metabolism->_rootRequest.rows();
    } else if (_fluid_balance == index.internalPointer()) {
      return _fluid_balance->_rootRequest.rows();
    } else if (_drugs == index.internalPointer()) {
      return _drugs->_rootRequest.rows();
    } else if (_substances == index.internalPointer()) {
      return _substances->_rootRequest.rows();
    } else if (_panels == index.internalPointer()) {
      return _panels->_rootRequest.rows();
    }
  }
  return static_cast<PhysiologyRequest*>(index.internalPointer())->rows();
}
//------------------------------------------------------------------------------------
int BioGearsData::columnCount(const QModelIndex& index) const
{
  if (!index.isValid()) {
    return 1;
  } else {
    if (_vitals == index.internalPointer()) {
      return _vitals->_rootRequest.columns();
    } else if (_cardiopulmonary == index.internalPointer()) {
      return _cardiopulmonary->_rootRequest.columns();
    } else if (_blood_chemistry == index.internalPointer()) {
      return _blood_chemistry->_rootRequest.columns();
    } else if (_renal == index.internalPointer()) {
      return _renal->_rootRequest.columns();
    } else if (_energy_and_metabolism == index.internalPointer()) {
      return _energy_and_metabolism->_rootRequest.columns();
    } else if (_fluid_balance == index.internalPointer()) {
      return _fluid_balance->_rootRequest.columns();
    } else if (_drugs == index.internalPointer()) {
      return _drugs->_rootRequest.columns();
    } else if (_substances == index.internalPointer()) {
      return _substances->_rootRequest.columns();
    } else if (_panels == index.internalPointer()) {
      return _panels->_rootRequest.columns();
    }
  }
  return static_cast<PhysiologyRequest*>(index.internalPointer())->columns();
}

//------------------------------------------------------------------------------------
QVariant BioGearsData::data(const QModelIndex& index, int role) const
{
  if (!index.isValid()) {
    return QVariant();
  }

  if (index.internalPointer() == this && role == Qt::DisplayRole) {
    auto* item = static_cast<PhysiologyRequest*>(index.internalPointer());

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
  } else if (_vitals == index.internalPointer()) {
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
  } else if (_panels == index.internalPointer()) {
    return _panels->data(index, role);
  } else {
    return static_cast<PhysiologyRequest*>(index.internalPointer())->data(role);
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
  BioGearsData* childItem;
  if (!parent.isValid() && !_rootModel) {
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
      childItem = _panels;
      break;
    }
    return createIndex(row, column, childItem);
  } else if (_vitals == parent.internalPointer()) {
    return _vitals->createIndex(row, column, _vitals->child(row));
  } else if (_cardiopulmonary == parent.internalPointer()) {
    return _cardiopulmonary->createIndex(row, column, _vitals->child(row));
  } else if (_blood_chemistry == parent.internalPointer()) {
    return _blood_chemistry->createIndex(row, column, _vitals->child(row));
  } else if (_renal == parent.internalPointer()) {
    return _renal->createIndex(row, column, _vitals->child(row));
  } else if (_energy_and_metabolism == parent.internalPointer()) {
    return _energy_and_metabolism->createIndex(row, column, _vitals->child(row));
  } else if (_fluid_balance == parent.internalPointer()) {
    return _fluid_balance->createIndex(row, column, _vitals->child(row));
  } else if (_drugs == parent.internalPointer()) {
    return _drugs->createIndex(row, column, _vitals->child(row));
  } else if (_substances == parent.internalPointer()) {
    return _substances->createIndex(row, column, _vitals->child(row));
  } else if (_panels == parent.internalPointer()) {
    return _panels->createIndex(row, column, _vitals->child(row));
  } else {
    return createIndex(row, column, static_cast<PhysiologyRequest*>(parent.internalPointer())->child(row));
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
    return createIndex(VITALS, 0, _vitals);
  } else if (_cardiopulmonary == model) {
    return createIndex(CARDIOPULMONARY, 0, _cardiopulmonary);
  } else if (_blood_chemistry == model) {
    return createIndex(BLOOD_CHEMISTRY, 0, _blood_chemistry);
  } else if (_renal == model) {
    return createIndex(RENAL, 0, _renal);
  } else if (_energy_and_metabolism == model) {
    return createIndex(ENERGY_AND_METABOLISM, 0, _energy_and_metabolism);
  } else if (_fluid_balance == model) {
    return createIndex(FLUID_BALANCE, 0, _fluid_balance);
  } else if (_drugs == model) {
    return createIndex(DRUGS, 0, _drugs);
  } else if (_substances == model) {
    return createIndex(SUBSTANCES, 0, _substances);
  } else if (_panels == model) {
    return createIndex(PANELS, 0, _panels);
  } else {
    return QModelIndex();
  }
}
//------------------------------------------------------------------------------------
void BioGearsData::append(QString prefix, QString name)
{
  _rootRequest.append(prefix, name);
}
//------------------------------------------------------------------------------------
PhysiologyRequest const* BioGearsData::child(int row) const
{
  return _rootRequest.child(row);
}
//------------------------------------------------------------------------------------
PhysiologyRequest* BioGearsData::child(int row)
{
  return _rootRequest.child(row);
}
//------------------------------------------------------------------------------------
