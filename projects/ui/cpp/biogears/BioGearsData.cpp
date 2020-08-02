#include "BioGearsData.h"

#include <biogears/engine/Controller/BioGearsSubstances.h>
#include <biogears/cdm/properties/SEScalarTime.h>

/// BioGearsData Model
///
BioGearsData::BioGearsData()
  : QAbstractItemModel(nullptr)
  , _rootRequest("", "", false, nullptr)
{
}

BioGearsData::BioGearsData(QString n, QObject* p)
  : QAbstractItemModel(p)
  , _rootRequest("", n, false, nullptr)
  , _name(n)
{
}

BioGearsData::BioGearsData(QString n, BioGearsData* p)
  : QAbstractItemModel(p)
  , _rootModel(p)
  , _name(n)
  , _rootRequest("", n, false, nullptr)
{
}

int BioGearsData::categories()
{
  return TOTAL_CATEGORIES;
}

BioGearsData* BioGearsData::category(int category)
{
  switch (category) {
  case VITALS:
    return _vitals;
  case CARDIOPULMONARY:
    return _cardiopulmonary;
  case BLOOD_CHEMISTRY:
    return _blood_chemistry;
  case ENERGY_AND_METABOLISM:
    return _energy_and_metabolism;
  case RENAL_FLUID_BALANCE:
    return _renal_fluid_balance;
  case SUBSTANCES:
    return _substances;
  case CUSTOM:
    return _customs;
  default:
    return nullptr;
  }
}

void BioGearsData::initialize()
{
  _vitals = new BioGearsData("Vitals", this);
  _cardiopulmonary = new BioGearsData("Cardiopulmonary", this);
  _blood_chemistry = new BioGearsData("Blood Chemistry", this);
  _energy_and_metabolism = new BioGearsData("Energy and Metabolism", this);
  _renal_fluid_balance = new BioGearsData("Renal Fluid Balance", this);
  _substances = new BioGearsData("Substances", this);
  _customs = new BioGearsData("Custom", this);

  _vitals->append(QString("Vitals"), QString("Arterial Pressure"));
  auto vital = _vitals->child(0);
  {
    vital->nested(false);
    vital->append(QString("Vitals"), QString("Systolic Pressure"));
    vital->append(QString("Vitals"), QString("Diastolic Pressure"));
  }
  _vitals->append(QString("Vitals"), QString("Respiration Rate"));
  _vitals->append(QString("Vitals"), QString("Oxygen Saturation"));
  _vitals->append(QString("Vitals"), QString("Blood Volume"));
  _vitals->append(QString("Vitals"), QString("Central Venous Pressure"));

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

  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("Core Temperature"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("Sweat Rate"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("Skin Temperature"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("Total Metabolic Rate"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("Stomach Contents"));
  auto stomach_contents = _energy_and_metabolism->child(4);
  {
    stomach_contents->nested(false);
    stomach_contents->append(QString("Stomach Contents"), QString("Calcium"));
    stomach_contents->append(QString("Stomach Contents"), QString("Carbohydrates"));
    stomach_contents->append(QString("Stomach Contents"), QString("Fat"));
    stomach_contents->append(QString("Stomach Contents"), QString("Protein"));
    stomach_contents->append(QString("Stomach Contents"), QString("Sodium"));
    stomach_contents->append(QString("Stomach Contents"), QString("Water"));
  }
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("Oxygen Consumption Rate"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("CO2 Production Rate"));

  _renal_fluid_balance->append(QString("Renal"), QString("Mean Urine Output"));
  _renal_fluid_balance->append(QString("Renal"), QString("Urine ProductionRate"));
  _renal_fluid_balance->append(QString("Renal"), QString("Urine Volume"));
  _renal_fluid_balance->append(QString("Renal"), QString("Urine Osmolality"));
  _renal_fluid_balance->append(QString("Renal"), QString("Urine Osmolarity"));
  _renal_fluid_balance->append(QString("Renal"), QString("Glomerular Filtration Rate"));
  _renal_fluid_balance->append(QString("Renal"), QString("Renal Blood Flow"));
  _renal_fluid_balance->append(QString("Fluid Balance"), QString("Total Body Fluid"));
  _renal_fluid_balance->append(QString("Fluid Balance"), QString("ExtracellularFluidVolume"));
  _renal_fluid_balance->append(QString("Fluid Balance"), QString("IntracellularFluidVolume"));
  _renal_fluid_balance->append(QString("Fluid Balance"), QString("ExtravascularFluidVolume"));

  _customs->append(QString("Plots"), QString("Respiratory PV Curve"));
  auto custom = _customs->child(0);
  {
    custom->append(QString("Respiratory PV Curve"), QString("Lung Pressure"));
    custom->append(QString("Respiratory PV Curve"), QString("Lung Volume"));
    custom->append(QString("Respiratory PV Curve"), QString("Cycle Start"));
    custom->rate(10);
  }

  _customs->append(QString("Panels"), QString("Renal"));
  {
    //TODO: Implement Renal Panel on 1/5Hz Update Rate
  }
  _customs->append(QString("Panels"), QString("Metabolic"));
  {
    //TODO: Implement Metabolic Panel on 1/5Hz Update Rate
  }
  _customs->append(QString("Panels"), QString("Pulmonary Function Test"));
  {
    //TODO: Implement Pulmonary Function Test 1/5Hz Update Rate
  }
}

//------------------------------------------------------------------------------------
BioGearsData::~BioGearsData()
{
//  _vitals->deleteLater();
//  _cardiopulmonary->deleteLater();
//  _blood_chemistry->deleteLater();
//  _energy_and_metabolism->deleteLater();
//  _renal_fluid_balance->deleteLater();
//  _substances->deleteLater();
//  _customs->deleteLater();
}
//------------------------------------------------------------------------------------
int BioGearsData::rowCount(const QModelIndex& index) const
{
  if (!_rootModel) {
    if (!index.internalPointer()) {
      return TOTAL_CATEGORIES;
    } else {
      if (_vitals && _vitals == index.internalPointer()) {
        return _vitals->_rootRequest.rows();
      } else if (_cardiopulmonary && _cardiopulmonary == index.internalPointer()) {
        return _cardiopulmonary->_rootRequest.rows();
      } else if (_blood_chemistry && _blood_chemistry == index.internalPointer()) {
        return _blood_chemistry->_rootRequest.rows();
      } else if (_energy_and_metabolism && _energy_and_metabolism == index.internalPointer()) {
        return _energy_and_metabolism->_rootRequest.rows();
      } else if (_renal_fluid_balance && _renal_fluid_balance == index.internalPointer()) {
        return _renal_fluid_balance->_rootRequest.rows();
      } else if (_substances && _substances == index.internalPointer()) {
        return _substances->_rootRequest.rows();
      } else if (_customs && _customs == index.internalPointer()) {
        return _customs->_rootRequest.rows();
      }
    }
  } else if (!index.internalPointer()) {
    return _rootRequest.rows();
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
    } else if (_energy_and_metabolism == index.internalPointer()) {
      return _energy_and_metabolism->_rootRequest.columns();
    } else if (_renal_fluid_balance == index.internalPointer()) {
      return _renal_fluid_balance->_rootRequest.columns();
    } else if (_substances == index.internalPointer()) {
      return _substances->_rootRequest.columns();
    } else if (_customs == index.internalPointer()) {
      return _customs->_rootRequest.columns();
    }
  }
  return static_cast<PhysiologyRequest*>(index.internalPointer())->columns();
}
//------------------------------------------------------------------------------------
QVariant BioGearsData::data(int role) const

{

  switch (role) {
  case Qt::DisplayRole:
  case RequestRole:
    return QVariant(_name);
  case FullNameRole:
    return _name;
  default:
    return QVariant();
  }
}
//------------------------------------------------------------------------------------
#pragma optimize("", off)
QVariant BioGearsData::data(const QModelIndex& index, int role) const
{
  if (!index.isValid()) {
    return QVariant();
  }
  if (index.internalPointer()) {
    if (_vitals == index.internalPointer()) {
      return _vitals->data(role);
    } else if (_cardiopulmonary == index.internalPointer()) {
      return _cardiopulmonary->data(role);
    } else if (_blood_chemistry == index.internalPointer()) {
      return _blood_chemistry->data(role);
    } else if (_energy_and_metabolism == index.internalPointer()) {
      return _energy_and_metabolism->data(role);
    } else if (_renal_fluid_balance == index.internalPointer()) {
      return _renal_fluid_balance->data(role);
    } else if (_substances == index.internalPointer()) {
      return _substances->data(role);
    } else if (_customs == index.internalPointer()) {
      return _customs->data(role);
    } else {
      return static_cast<PhysiologyRequest*>(index.internalPointer())->data(role);
    }
  }
  return QVariant();
}
#pragma optimize("", on)
//------------------------------------------------------------------------------------
bool BioGearsData::setData(const QModelIndex& index, const QVariant& value, int role)
{
  if (role == EnabledRole && index.internalPointer()) {
    static_cast<PhysiologyRequest*>(index.internalPointer())->active(value.toBool());
    return true;
  } else if (role == RateRole && index.internalPointer()) {
    static_cast<PhysiologyRequest*>(index.internalPointer())->rate(value.toInt());
    return true;
  }
  return false;
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
#pragma optimize("", off)
QModelIndex BioGearsData::index(int row, int column, const QModelIndex& parent) const
{
  if (!hasIndex(row, column, parent)) {
    return QModelIndex();
  }
  if (!parent.isValid()) {
    BioGearsData* childItem;
    if (!_rootModel) {
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
      case ENERGY_AND_METABOLISM:
        childItem = _energy_and_metabolism;
        break;
      case RENAL_FLUID_BALANCE:
        childItem = _renal_fluid_balance;
        break;
      case SUBSTANCES:
        childItem = _substances;
        break;
      case CUSTOM:
        childItem = _customs;
        break;
      }
      return createIndex(row, column, childItem);
    } else {
      return createIndex(row, column, const_cast<PhysiologyRequest*>(_rootRequest.child(row)));
    }
  } else if (_vitals && _vitals == parent.internalPointer()) {
    return _vitals->createIndex(row, column, _vitals->child(row));
  } else if (_cardiopulmonary && _cardiopulmonary == parent.internalPointer()) {
    return _cardiopulmonary->createIndex(row, column, _cardiopulmonary->child(row));
  } else if (_blood_chemistry && _blood_chemistry == parent.internalPointer()) {
    return _blood_chemistry->createIndex(row, column, _blood_chemistry->child(row));
  } else if (_energy_and_metabolism && _energy_and_metabolism == parent.internalPointer()) {
    return _energy_and_metabolism->createIndex(row, column, _energy_and_metabolism->child(row));
  } else if (_renal_fluid_balance && _renal_fluid_balance == parent.internalPointer()) {
    return _renal_fluid_balance->createIndex(row, column, _renal_fluid_balance->child(row));
  } else if (_substances && _substances == parent.internalPointer()) {
    return _substances->createIndex(row, column, _substances->child(row));
  } else if (_customs && _customs == parent.internalPointer()) {
    return _customs->createIndex(row, column, _customs->child(row));
  } else {
    return createIndex(row, column, static_cast<PhysiologyRequest*>(parent.internalPointer())->child(row));
  }
  return QModelIndex();
}
#pragma optimize("", on)
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
  } else if (_energy_and_metabolism == model) {
    return createIndex(ENERGY_AND_METABOLISM, 0, _energy_and_metabolism);
  } else if (_renal_fluid_balance == model) {
    return createIndex(RENAL_FLUID_BALANCE, 0, _renal_fluid_balance);
  } else if (_substances == model) {
    return createIndex(SUBSTANCES, 0, _substances);
  } else if (_customs == model) {
    return createIndex(CUSTOM, 0, _renal_fluid_balance);
  } else {
    return QModelIndex();
  }
}
//------------------------------------------------------------------------------------
double BioGearsData::getSimulationTime()
{
  return _simulation_time_s;
}
//------------------------------------------------------------------------------------
void BioGearsData::setSimulationTime(double time_s)
{
    _simulation_time_s = time_s;
  emit timeAdvanced(_simulation_time_s);

}
//------------------------------------------------------------------------------------
PhysiologyRequest* BioGearsData::
  append(QString prefix, QString name)
{
  return _rootRequest.append(prefix, name);
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
