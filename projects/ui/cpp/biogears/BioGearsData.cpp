#include "BioGearsData.h"

#include <biogears/cdm/properties/SEScalarTime.h>
#include <biogears/cdm/substance/SESubstance.h>
#include <biogears/engine/Controller/BioGearsSubstances.h>

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
  case CARDIOVASCULAR:
    return _cardiovascular;
  case RESPIRATORY:
    return _respiratory;
  case BLOOD_CHEMISTRY:
    return _blood_chemistry;
  case ENERGY_AND_METABOLISM:
    return _energy_and_metabolism;
  case RENAL:
    return _renal;
  case SUBSTANCES:
    return _substances;
  case CUSTOM:
    return _customs;
  default:
    return nullptr;
  }
}

void BioGearsData::initialize(const biogears::BioGearsSubstances& bgSubstances)
{
  _vitals = new BioGearsData("Vitals", this);
  _cardiovascular = new BioGearsData("Cardiovascular", this);
  _respiratory = new BioGearsData("Respiratory", this);
  _blood_chemistry = new BioGearsData("Blood Chemistry", this);
  _energy_and_metabolism = new BioGearsData("Energy and Metabolism", this);
  _renal = new BioGearsData("Renal", this);
  _substances = new BioGearsData("Substances", this);
  _customs = new BioGearsData("Custom", this);

  //Append function takes prefix, request name, and display name. Request name must exactly match the
  // corresponding request name in Physiology.xsd for data request lookup from scenario to work correctly.
  // Display name will be shown in plots.  If display name not provided, it defaults to request name with spaces
  // inserted between words.
  _vitals->append(QString("Vitals"), QString("Arterial Pressure"));
  auto vital = _vitals->child(0); //default display blood pressure
  vital->enabled(true);
  {
    vital->nested(false);
    vital->append(QString("Vitals"), QString("SystolicArterialPressure"), QString("Systolic Pressure"));
    vital->append(QString("Vitals"), QString("DiastolicArterialPressure"), QString("Diastolic Pressure"));
    vital->append(QString("Vitals"), QString("MeanArterialPressure"), QString("Mean Pressure"));
  }
  _vitals->append(QString("Vitals"), QString("HeartRate"));
  _vitals->child(1)->enabled(true); //default display HR
  _vitals->append(QString("Vitals"), QString("RespirationRate"));
  _vitals->child(2)->enabled(true); //default display RR
  _vitals->append(QString("Vitals"), QString("OxygenSaturation"));
  _vitals->child(3)->enabled(true); //default display O2 sat
  _vitals->append(QString("Vitals"), QString("BloodVolume"));
  _vitals->append(QString("Vitals"), QString("CentralVenousPressure"));
  _vitals->append(QString("Vitals"), QString("CardiacOutput"));

  _cardiovascular->append(QString("Cardiovascular"), QString("CerebralPerfusionPressure"));
  _cardiovascular->append(QString("Cardiovascular"), QString("IntracranialPressure"));
  _cardiovascular->append(QString("Cardiovascular"), QString("SystemicVascularResistance"));
  _cardiovascular->append(QString("Cardiovascular"), QString("PulsePressure"));
  _cardiovascular->append(QString("Cardiovascular"), QString("HeartStrokeVolume"), QString("Stroke Volume"));
  _cardiovascular->append(QString("Cardiovascular"), QString("CardiacIndex"));
  _cardiovascular->append(QString("Cardiovascular"), QString("EjectionFraction"));
  _cardiovascular->append(QString("Cardiovascular"), QString("ExtravascularFluidVolume"), QString("Extravascular Volume"));
  _cardiovascular->append(QString("Cardiovascular"), QString("ExtracellularFluidVolume"), QString("Extracellular Volume"));
  _cardiovascular->append(QString("Cardiovascular"), QString("IntracellularFluidVolume"), QString("Intracellular Volume"));
  _cardiovascular->append(QString("Cardiovascular"), QString("TotalBodyFluidVolume"), QString("Total Body Volume"));

  _respiratory->append(QString("Respiratory"), QString("InspiratoryExpiratoryRatio"), QString("IE Ratio"));
  _respiratory->append(QString("Respiratory"), QString("TotalPulmonaryVentilation"), QString("Total Ventilation"));
  _respiratory->append(QString("Respiratory"), QString("TotalLungVolume"), QString("Lung Volume"));
  _respiratory->append(QString("Respiratory"), QString("TidalVolume"));
  _respiratory->append(QString("Respiratory"), QString("TotalAlveolarVentilation"), QString("Alveolar Ventilation"));
  _respiratory->append(QString("Respiratory"), QString("DeadSpaceVentlation"));
  _respiratory->append(QString("Respiratory"), QString("TranspulmonaryPressure"));

  _blood_chemistry->append(QString("Blood Chemistry"), QString("ArterialOxygenPressure"), QString("Arterial O2 Pressure"));
  _blood_chemistry->append(QString("Blood Chemistry"), QString("ArterialCarbonDioxidePressure"), QString("Arterial CO2 Pressure"));
  _blood_chemistry->append(QString("Blood Chemistry"), QString("OxygenSaturation"), QString("O2 Saturation"));
  _blood_chemistry->append(QString("Blood Chemistry"), QString("CarbonDioxideSaturation"), QString("CO2 Saturation"));
  _blood_chemistry->append(QString("Blood Chemistry"), QString("ArterialBloodPH"), QString("Blood pH"));
  _blood_chemistry->append(QString("Blood Chemistry"), QString("Hematocrit"));
  _blood_chemistry->append(QString("Blood Chemistry"), QString("LactateConcentration"));
  _blood_chemistry->append(QString("Blood Chemistry"), QString("StrongIonDifference"));

  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("CoreTemperature"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("SweatRate"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("SkinTemperature"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("TotalMetabolicRate"));
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
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("OxygenConsumptionRate"), QString("O2 Consumption"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("CarbonDioxideProductionRate"), QString("CO2 Production"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("DehydrationFraction"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("AmbientTemperature"));
  _energy_and_metabolism->append(QString("Energy and Metabolism"), QString("RelativeHumidity"));

  _renal->append(QString("Renal"), QString("MeanUrineOutput"));
  _renal->append(QString("Renal"), QString("UrineProductionRate"));
  _renal->child(1)->enabled(true);
  _renal->append(QString("Renal"), QString("GlomerularFiltrationRate"));
  _renal->child(2)->enabled(true);
  _renal->append(QString("Renal"), QString("UrineVolume"));
  _renal->append(QString("Renal"), QString("UrineOsmolality"));
  _renal->append(QString("Renal"), QString("UrineOsmolarity"));
  _renal->append(QString("Renal"), QString("RenalBloodFlow"));
  _renal->append(QString("Renal"), QString("LeftReabsorptionRate"));
  _renal->append(QString("Renal"), QString("RightReabsorptionRate"));

  //Add all substances from manager -- create nodes for appropriate fields (unit/scalar values default to nullptrs)
  //All this does is set up containers for sub data -- data will not be assigned to substance until it is active
  for (auto sub : bgSubstances.GetSubstances()) {
    auto subData = _substances->append(QString("Substances"), QString::fromStdString(sub->GetName()));
    subData->nested(true);
    subData->usable(false); //Set all substances to non-usable (will be set when substance is activated in Biogears)
    //Every substance should have blood concentration, mass in body, mass in blood, mass in tissue
    auto metric = subData->append(subData->name(), QString("BloodConcentration"));
    metric = subData->append(subData->name(), QString("MassInBody"));
    metric = subData->append(subData->name(), QString("MassInBlood"));
    metric = subData->append(subData->name(), QString("MassInTissue"));
    //Only subs that are dissolved gases need alveolar transfer and end tidal.  Use relative diffusion coefficient to filter
    if (sub->HasRelativeDiffusionCoefficient()) {
      metric = subData->append(subData->name(), QString("AlveolarTransfer"));
      metric = subData->append(subData->name(), QString("EndTidalFraction"));
    }
    //Only subs that have PK need effect site, plasma, AUC
    if (sub->HasPK()) {
      metric = subData->append(subData->name(), QString("EffectSiteConcentration"));
      metric = subData->append(subData->name(), QString("PlasmaConcentration"));
      metric = subData->append(subData->name(), QString("AreaUnderCurve"));
    }
    //Assign clearances, if applicable
    if (sub->HasClearance()) {
      if (sub->GetClearance().HasRenalClearance()) {
        metric = subData->append(subData->name(), QString("RenalClearance"));
      }
      if (sub->GetClearance().HasIntrinsicClearance()) {
        metric = subData->append(subData->name(), QString("IntrinsicClearance"));
      }
      if (sub->GetClearance().HasSystemicClearance()) {
        metric = subData->append(subData->name(), QString("SystemicClearance"));
      }
    }
  }

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
  //  _fluid_balance->deleteLater();
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
      } else if (_cardiovascular && _cardiovascular == index.internalPointer()) {
        return _cardiovascular->_rootRequest.rows();
      } else if (_respiratory && _respiratory == index.internalPointer()) {
        return _respiratory->_rootRequest.rows();
      } else if (_blood_chemistry && _blood_chemistry == index.internalPointer()) {
        return _blood_chemistry->_rootRequest.rows();
      } else if (_energy_and_metabolism && _energy_and_metabolism == index.internalPointer()) {
        return _energy_and_metabolism->_rootRequest.rows();
      } else if (_renal && _renal == index.internalPointer()) {
        return _renal->_rootRequest.rows();
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
    } else if (_cardiovascular == index.internalPointer()) {
      return _cardiovascular->_rootRequest.columns();
    } else if (_respiratory == index.internalPointer()) {
      return _respiratory->_rootRequest.columns();
    } else if (_blood_chemistry == index.internalPointer()) {
      return _blood_chemistry->_rootRequest.columns();
    } else if (_energy_and_metabolism == index.internalPointer()) {
      return _energy_and_metabolism->_rootRequest.columns();
    } else if (_renal == index.internalPointer()) {
      return _renal->_rootRequest.columns();
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
    } else if (_cardiovascular == index.internalPointer()) {
      return _cardiovascular->data(role);
    } else if (_respiratory == index.internalPointer()) {
      return _respiratory->data(role);
    } else if (_blood_chemistry == index.internalPointer()) {
      return _blood_chemistry->data(role);
    } else if (_energy_and_metabolism == index.internalPointer()) {
      return _energy_and_metabolism->data(role);
    } else if (_renal == index.internalPointer()) {
      return _renal->data(role);
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
    static_cast<PhysiologyRequest*>(index.internalPointer())->enabled(value.toBool());
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
      case CARDIOVASCULAR:
        childItem = _cardiovascular;
        break;
      case RESPIRATORY:
        childItem = _respiratory;
        break;
      case BLOOD_CHEMISTRY:
        childItem = _blood_chemistry;
        break;
      case ENERGY_AND_METABOLISM:
        childItem = _energy_and_metabolism;
        break;
      case RENAL:
        childItem = _renal;
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
  } else if (_cardiovascular && _cardiovascular == parent.internalPointer()) {
    return _cardiovascular->createIndex(row, column, _cardiovascular->child(row));
  } else if (_respiratory && _respiratory == parent.internalPointer()) {
    return _respiratory->createIndex(row, column, _respiratory->child(row));
  } else if (_blood_chemistry && _blood_chemistry == parent.internalPointer()) {
    return _blood_chemistry->createIndex(row, column, _blood_chemistry->child(row));
  } else if (_energy_and_metabolism && _energy_and_metabolism == parent.internalPointer()) {
    return _energy_and_metabolism->createIndex(row, column, _energy_and_metabolism->child(row));
  } else if (_renal && _renal == parent.internalPointer()) {
    return _renal->createIndex(row, column, _renal->child(row));
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
  } else if (_cardiovascular == model) {
    return createIndex(CARDIOVASCULAR, 0, _cardiovascular);
  } else if (_respiratory == model) {
    return createIndex(RESPIRATORY, 0, _respiratory);
  } else if (_blood_chemistry == model) {
    return createIndex(BLOOD_CHEMISTRY, 0, _blood_chemistry);
  } else if (_energy_and_metabolism == model) {
    return createIndex(ENERGY_AND_METABOLISM, 0, _energy_and_metabolism);
  } else if (_renal == model) {
    return createIndex(RENAL, 0, _renal);
  } else if (_substances == model) {
    return createIndex(SUBSTANCES, 0, _substances);
  } else if (_customs == model) {
    return createIndex(CUSTOM, 0, _customs);
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
void BioGearsData::clear()
{
  _rootRequest.clear();
}
//------------------------------------------------------------------------------------
PhysiologyRequest* BioGearsData::
  append(QString prefix, QString name, QString display)
{
  return _rootRequest.append(prefix, name, display);
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
void BioGearsData::enableFromScenario(CDM::ScenarioData* scenario)
{
  QVector<QString> searchKeys; //Use vector rather than QStringList because we can remove by index in vector
  QString requestName = "";
  //Get a list of all data request names in the scenario.  The Graph Area currently only holds physiology
  // and substance requests (no patient, compartment, enviroment), so we only cast to those types. Format sub
  // requests as "SubstanceName-RequestName"
  if (scenario->DataRequests().present()) {
    for (auto& req : scenario->DataRequests().get().DataRequest()) {
      //Graph area only holds physiology and substance data requests (no compartment or patient)
      if (auto physiologyReq = dynamic_cast<CDM::PhysiologyDataRequestData*>(&req)) {
        searchKeys.append(QString::fromStdString(physiologyReq->Name()));
      } else if (auto substanceReq = dynamic_cast<CDM::SubstanceDataRequestData*>(&req)) {
        searchKeys.append(QString::fromStdString(substanceReq->Substance() + "-" + substanceReq->Name()));
      }
    }
  }

  //Loop over all categories (Vitals, Cardiovascular, etc) and then all data requests in each section. Set enabled to "true" if we find that
  // request inside our searchkeys list.  Otherwise, set it to false.  Remove searchkey from list when found so that
  // we can cut down on number of iterations as we progress through requests.
  bool foundRequest = false;
  for (int i = 0; i < categories() - 1; ++i) {
    //i = enum corresponding to category.  Stopping 1 short because we are not doing custom category
    QModelIndex catIndex = index(i, 0, QModelIndex());
    BioGearsData* catData = category(i);
    //Substances category handled differently than others (need to find both Substance AND request)
    if (i == Categories::SUBSTANCES) {
      QString substanceName;
      QStringList subRequestPair;
      //Loop over substances inside Substance Category
      for (int j = 0; j < rowCount(catIndex); ++j) {
        substanceName = _substances->child(j)->name();
        foundRequest = false;
        for (int k = 0; k < searchKeys.length(); ++k) {
          subRequestPair = searchKeys[k].split('-');    //Subtance requests formatted as "Substance-Request"
          if (substanceName == subRequestPair[0]) {
            //Found the right substance, now search through that substances children to find matching request
            QModelIndex substanceIndex = index(j, 0, catIndex);
            PhysiologyRequest* substance = static_cast<PhysiologyRequest*>(substanceIndex.internalPointer());
            for (int m = 0; m < rowCount(substanceIndex); ++m) {
              requestName = substance->child(m)->name();
              if (requestName == subRequestPair[1]) {
                substance->child(m)->enabled(true);
                searchKeys.remove(k);
                --k;   //We're going to stay inside the search key loop to see if we match this same substance again, so update index after removal
                foundRequest = true;
                break;
              }
            }
          }
        }
      }
    } else {
      //Loop over requests inside category
      for (int j = 0; j < rowCount(catIndex); ++j) {
        foundRequest = false;
        //Does the request have children? (Like Arterial Pressure -> [Systolic, Diastolic]?
        if (catData->child(j)->data(PhysiologyRequestRoles::ChildrenRole) > 0) {
          //If children, search them for requests
          PhysiologyRequest* parent = static_cast<PhysiologyRequest*>(index(j, 0, catIndex).internalPointer());
          for (int k = 0; k < rowCount(index(j, 0, catIndex)); ++k) {
            requestName = parent->child(k)->name();
            for (int m = 0; m < searchKeys.length(); ++m) {
              if (requestName == searchKeys[m]) {
                catData->child(j)->enabled(true); //Assume that we want to enable all children of the parent
                searchKeys.remove(m);
                foundRequest = true;
                break;
              }
            }
            if (foundRequest) {
              break;
            }
          } 
        } else {
          requestName = catData->child(j)->name();
          for (int k = 0; k < searchKeys.length(); ++k) {
            if (requestName == searchKeys[k]) {
              catData->child(j)->enabled(true);
              searchKeys.remove(k);
              foundRequest = true;
              break;
            }
          }
        }//endIf
        if (!foundRequest) {
          catData->child(j)->enabled(false);
        }
      }//end for child in category
    }//endIf substance
  }//end for categories 
}
