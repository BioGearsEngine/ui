#include "DataRequestTree.h"

#include <biogears/cdm/compartment/fluid/SELiquidCompartment.h>
#include <biogears/cdm/properties/SEDecimalFormat.h>
#include <biogears/cdm/scenario/requests/SEDataRequestManager.h>
#include <biogears/cdm/scenario/requests/SEPhysiologyDataRequest.h>
#include <biogears/string/manipulation.h>

// DataRequestTree Model

DataRequestTree::DataRequestTree(QObject* parent)
  : QAbstractItemModel(nullptr)
{
  _root = new DataRequestNode();
}
//------------------------------------------------------------------------------------
DataRequestTree::~DataRequestTree()
{
  delete _root;
}
//------------------------------------------------------------------------------------
Qt::ItemFlags DataRequestTree::flags(const QModelIndex& index) const
{
  if (!index.isValid()) {
    return Qt::NoItemFlags;
  }
  return QAbstractItemModel::flags(index);
}
//------------------------------------------------------------------------------------
int DataRequestTree::rowCount(const QModelIndex& parent) const
{
  if (parent.isValid()) {
    return static_cast<DataRequestNode*>(parent.internalPointer())->rows();
  } else {
    return _root->rows();
  }
}
//------------------------------------------------------------------------------------
int DataRequestTree::columnCount(const QModelIndex& parent) const
{
  return 1;
}
//------------------------------------------------------------------------------------
QModelIndex DataRequestTree::index(const int row, const int column, const QModelIndex& parent) const
{
  if (!hasIndex(row, column, parent)) {
    return QModelIndex();
  }

  DataRequestNode* parentNode = parent.isValid() ? static_cast<DataRequestNode*>(parent.internalPointer()) : _root;
  DataRequestNode* childNode = parentNode->child(row);
  if (childNode) {
    return createIndex(row, column, childNode);
  }
  return QModelIndex();
}
//------------------------------------------------------------------------------------
QModelIndex DataRequestTree::parent(const QModelIndex& childIndex) const
{
  if (!childIndex.isValid()) {
    return QModelIndex();
  }

  DataRequestNode* parentNode = static_cast<DataRequestNode*>(childIndex.internalPointer())->parent();
  if (parentNode == _root) {
    return QModelIndex();
  } else {
    return createIndex(parentNode->rowInParent(), 0, parentNode);
  }
}
//------------------------------------------------------------------------------------
QVariant DataRequestTree::data(const QModelIndex& index, const int role) const
{
  if (!index.isValid()) {
    return QVariant();
  }
  DataRequestNode* node = static_cast<DataRequestNode*>(index.internalPointer());
  return node->data(role);
}
//------------------------------------------------------------------------------------
bool DataRequestTree::setData(const QModelIndex& index, const QVariant& value, int role)
{
  if (role == Qt::CheckStateRole && index.internalPointer()) {
    static_cast<DataRequestNode*>(index.internalPointer())->checked(value.toInt());
    return true;
  } else if (role == CollapsedRole && index.internalPointer()) {
    static_cast<DataRequestNode*>(index.internalPointer())->collapsed(value.toBool());
    return true;
  }
  return false;
}
//------------------------------------------------------------------------------------
QString DataRequestTree::dataPath(const QModelIndex& index)
{
  QString fullPath = data(index, Qt::DisplayRole).toString();
  QModelIndex tempIndex = index;
  while (parent(tempIndex) != QModelIndex()) {
    QModelIndex parentIndex = parent(tempIndex);
    QString nodeName = (data(parentIndex, Qt::DisplayRole).toString() + ";");
    fullPath.prepend(nodeName);
    tempIndex = parentIndex;
  }
  fullPath.replace(" ", "");
  return fullPath;
}
//------------------------------------------------------------------------------------
void DataRequestTree::resetData()
{
  for (auto child : _root->children()) {
    child->reset();
  }
}
//------------------------------------------------------------------------------------
DataRequestNode* DataRequestTree::appendChild(QString name, QString type)
{
  return _root->appendChild(name, type);
}
//------------------------------------------------------------------------------------
DataRequestNode* DataRequestTree::appendChildren(QList<QPair<QString, QString>> nameUnitPairs)
{
  return _root->appendChildren(nameUnitPairs);
}
//------------------------------------------------------------------------------------
QVariantList DataRequestTree::encode_requests(CDM::ScenarioData* scenario)
{
  QVariantList requests;
  QString request;
  DataRequestNode* compartmentNode = static_cast<DataRequestNode*>(index(0, 0, QModelIndex()).internalPointer());
  compartmentNode->collapsed(false);
  if (scenario->DataRequests().present()) {
    for (auto& req : scenario->DataRequests().get().DataRequest()) {
      if (auto gasCompartmentReq = dynamic_cast<CDM::GasCompartmentDataRequestData*>(&req)) {
        request = encode_gas_compartment_request(gasCompartmentReq);
      } else if (auto liquidCompartmentReq = dynamic_cast<CDM::LiquidCompartmentDataRequestData*>(&req)) {
        request = encode_liquid_compartment_request(liquidCompartmentReq);
      } else if (auto thermalCompartmentReq = dynamic_cast<CDM::ThermalCompartmentDataRequestData*>(&req)) {
        request = encode_thermal_compartment_request(thermalCompartmentReq);
      } else if (auto tissueCompartmentReq = dynamic_cast<CDM::TissueCompartmentDataRequestData*>(&req)) {
        request = encode_tissue_compartment_request(tissueCompartmentReq);
      } else if (auto environmentReq = dynamic_cast<CDM::EnvironmentDataRequestData*>(&req)) {
        request = encode_environment_request(environmentReq);
      } else if (auto patientReq = dynamic_cast<CDM::PatientDataRequestData*>(&req)) {
        request = encode_patient_request(patientReq);
      } else if (auto physiologyReq = dynamic_cast<CDM::PhysiologyDataRequestData*>(&req)) {
        request = encode_physiology_request(physiologyReq);
      } else if (auto substanceReq = dynamic_cast<CDM::SubstanceDataRequestData*>(&req)) {
        request = encode_substance_request(substanceReq);
      }
      if (!request.isEmpty()) {
        requests.push_back(request);
      }
      request.clear();
    }
  }
  return requests;
}
//------------------------------------------------------------------------------------
QString DataRequestTree::encode_gas_compartment_request(CDM::GasCompartmentDataRequestData* req)
{
  //Format request string that will be used to create Request Component in Scenario Builder
  std::string request = "TYPE=GasCompartment";
  request += ("NAME=" + req->Compartment() + "," + req->Name() + ";");
  if (req->Unit().present()) {
    request += ("UNIT=" + req->Unit().get() + ";");
  }
  if (req->Precision().present()) {
    request += ("PRECISION=" + std::to_string(req->Precision().get()));
  }
  if (req->Substance().present()) {
    request += ("SUBSTANCE=" + req->Substance().get() + ";");
  }
  //Set data in RequestModel so that when Scenario Builder is opened, the request menu will have the proper sub-menus opened and request options checked
  QModelIndex gasIndex = index(0, 0, index(0, 0, QModelIndex())); //Gas branch is 0th element inside the Compartment branch  (0th element of top level)
  DataRequestNode* gasNode = static_cast<DataRequestNode*>(gasIndex.internalPointer());
  gasNode->collapsed(false);
  for (int i = 0; i < gasNode->children().size(); ++i) {
    //Next level is gas compartment name -- figure out which compartment we are in
    if (gasNode->children()[i]->name().toStdString() == req->Compartment()) {
      QModelIndex compartmentIndex = index(i, 0, gasIndex);
      DataRequestNode* compartmentNode = static_cast<DataRequestNode*>(compartmentIndex.internalPointer());
      compartmentNode->collapsed(false);
      for (int j = 0; j < compartmentNode->children().size(); ++j) {
        //Now that we know compartment, figure out the name of the data request
        if (req->Name() == compartmentNode->children()[j]->name().toStdString()) {
          compartmentNode->children()[j]->checked(true);
          break;
        }
      }
      break;
    }
  }

  return QString::fromStdString(request);
}
//------------------------------------------------------------------------------------
QString DataRequestTree::encode_liquid_compartment_request(CDM::LiquidCompartmentDataRequestData* req)
{
  //Format request string that will be used to create Request Component in Scenario Builder
  std::string request = "TYPE=LiquidCompartment;";
  request += ("NAME=" + req->Compartment() + "," + req->Name() + ";");
  if (req->Unit().present()) {
    request += ("UNIT=" + req->Unit().get() + ";");
  }
  if (req->Precision().present()) {
    request += ("PRECISION=" + std::to_string(req->Precision().get()) + ";");
  }
  if (req->Substance().present()) {
    request += ("SUBSTANCE=" + req->Substance().get() + ";");
  }
  //Set data in RequestModel so that when Scenario Builder is opened, the request menu will have the proper sub-menus opened and request options checked
  QModelIndex liquidIndex = index(1, 0, index(0, 0, QModelIndex())); //Liquid branch is 1st element inside the Compartment branch  (0th element of top level)
  DataRequestNode* liquidNode = static_cast<DataRequestNode*>(liquidIndex.internalPointer());
  liquidNode->collapsed(false);
  for (int i = 0; i < liquidNode->children().size(); ++i) {
    //Next level is liquid compartment name -- figure out which compartment we are in
    if (liquidNode->children()[i]->name().toStdString() == req->Compartment()) {
      QModelIndex compartmentIndex = index(i, 0, liquidIndex);
      DataRequestNode* compartmentNode = static_cast<DataRequestNode*>(compartmentIndex.internalPointer());
      compartmentNode->collapsed(false);
      for (int j = 0; j < compartmentNode->children().size(); ++j) {
        //Now that we know compartment, figure out the name of the data request
        if (req->Name() == compartmentNode->children()[j]->name().toStdString()) {
          compartmentNode->children()[j]->checked(true);
          break;
        }
      }
      break;
    }
  }
  return QString::fromStdString(request);
}
//------------------------------------------------------------------------------------
QString DataRequestTree::encode_thermal_compartment_request(CDM::ThermalCompartmentDataRequestData* req)
{
  //Format request string that will be used to create Request Component in Scenario Builder
  std::string request = "TYPE=ThermalCompartment";
  request += ("NAME=" + req->Compartment() + "," + req->Name() + ";");
  if (req->Unit().present()) {
    request += ("UNIT=" + req->Unit().get() + ";");
  }
  if (req->Precision().present()) {
    request += ("PRECISION=" + std::to_string(req->Precision().get()));
  }
  //Set data in RequestModel so that when Scenario Builder is opened, the request menu will have the proper sub-menus opened and request options checked
  QModelIndex thermalIndex = index(2, 0, index(0, 0, QModelIndex())); //Thermal branch is 2nd element inside the Compartment branch  (0th element of top level)
  DataRequestNode* thermalNode = static_cast<DataRequestNode*>(thermalIndex.internalPointer());
  thermalNode->collapsed(false);
  for (int i = 0; i < thermalNode->children().size(); ++i) {
    //Next level is thermal compartment name -- figure out which compartment we are in
    if (thermalNode->children()[i]->name().toStdString() == req->Compartment()) {
      QModelIndex compartmentIndex = index(i, 0, thermalIndex);
      DataRequestNode* compartmentNode = static_cast<DataRequestNode*>(compartmentIndex.internalPointer());
      compartmentNode->collapsed(false);
      for (int j = 0; j < compartmentNode->children().size(); ++j) {
        //Now that we know compartment, figure out the name of the data request
        if (req->Name() == compartmentNode->children()[j]->name().toStdString()) {
          compartmentNode->children()[j]->checked(true);
          break;
        }
      }
      break;
    }
  }
  return QString::fromStdString(request);
}
//------------------------------------------------------------------------------------
QString DataRequestTree::encode_tissue_compartment_request(CDM::TissueCompartmentDataRequestData* req)
{
  //Format request string that will be used to create Request Component in Scenario Builder
  std::string request = "TYPE=TissueCompartment";
  request += ("NAME=" + req->Compartment() + "," + req->Name() + ";");
  if (req->Unit().present()) {
    request += ("UNIT=" + req->Unit().get() + ";");
  }
  if (req->Precision().present()) {
    request += ("PRECISION=" + std::to_string(req->Precision().get()));
  }
  //Set data in RequestModel so that when Scenario Builder is opened, the request menu will have the proper sub-menus opened and request options checked
  QModelIndex tissueIndex = index(3, 0, index(0, 0, QModelIndex())); //Tissue branch is 3rd element inside the Compartment branch  (0th element of top level)
  DataRequestNode* tissueNode = static_cast<DataRequestNode*>(tissueIndex.internalPointer());
  tissueNode->collapsed(false);
  for (int i = 0; i < tissueNode->children().size(); ++i) {
    //Next level is tissue compartment name -- figure out which compartment we are in
    if (tissueNode->children()[i]->name().toStdString() == req->Compartment()) {
      QModelIndex compartmentIndex = index(i, 0, tissueIndex);
      DataRequestNode* compartmentNode = static_cast<DataRequestNode*>(compartmentIndex.internalPointer());
      compartmentNode->collapsed(false);
      for (int j = 0; j < compartmentNode->children().size(); ++j) {
        //Now that we know compartment, figure out the name of the data request
        if (req->Name() == compartmentNode->children()[j]->name().toStdString()) {
          compartmentNode->children()[j]->checked(true);
          break;
        }
      }
      break;
    }
  }
  return QString::fromStdString(request);
}
//------------------------------------------------------------------------------------
QString DataRequestTree::encode_environment_request(CDM::EnvironmentDataRequestData* req)
{
  //Format request string that will be used to create Request Component in Scenario Builder
  std::string request = "TYPE=Environment";
  request += ("NAME=" + req->Name() + ";");
  if (req->Unit().present()) {
    request += ("UNIT=" + req->Unit().get() + ";");
  }
  if (req->Precision().present()) {
    request += ("PRECISION=" + std::to_string(req->Precision().get()));
  }
  return QString::fromStdString(request);
}
//------------------------------------------------------------------------------------
QString DataRequestTree::encode_patient_request(CDM::PatientDataRequestData* req)
{
  //Format request string that will be used to create Request Component in Scenario Builder
  std::string request = "TYPE=Patient";
  request += ("NAME=" + req->Name() + ";");
  if (req->Unit().present()) {
    request += ("UNIT=" + req->Unit().get() + ";");
  }
  if (req->Precision().present()) {
    request += ("PRECISION=" + std::to_string(req->Precision().get()));
  }
  //Set data in RequestModel so that when Scenario Builder is opened, the request menu will have the proper sub-menus opened and request options checked
  QModelIndex patientIndex = index(2, 0, QModelIndex()); //Patient branch is 2nd element inside top level
  DataRequestNode* patientNode = static_cast<DataRequestNode*>(patientIndex.internalPointer());
  patientNode->collapsed(false);
  for (int i = 0; i < patientNode->children().size(); ++i) {
    //Only one level of data beneath patient -- check which request we are calling
    if (patientNode->children()[i]->name().toStdString() == req->Name()) {
      patientNode->children()[i]->checked(true);
      break;
    }
    break;
  }
  return QString::fromStdString(request);
}
//------------------------------------------------------------------------------------
QString DataRequestTree::encode_physiology_request(CDM::PhysiologyDataRequestData* req)
{
  //Format request string that will be used to create Request Component in Scenario Builder
  std::string request = "TYPE=Physiology";
  request += ("NAME=" + req->Name() + ";");
  if (req->Unit().present()) {
    request += ("UNIT=" + req->Unit().get() + ";");
  }
  if (req->Precision().present()) {
    request += ("PRECISION=" + std::to_string(req->Precision().get()));
  }
  //Set data in RequestModel so that when Scenario Builder is opened, the request menu will have the proper sub-menus opened and request options checked
  QModelIndex physiologyIndex = index(3, 0, QModelIndex()); //Physiology branch is 3rd element inside top level
  DataRequestNode* physiologyNode = static_cast<DataRequestNode*>(physiologyIndex.internalPointer());
  physiologyNode->collapsed(false);
  bool foundRequest = false;
  int childIndex = 0;
  DataRequestNode* childNode;
  while (!foundRequest && childIndex < physiologyNode->children().size()) {
    //Data request model nests requests according to physiology type (Cardiovascular, Respiratory ,etc).  This structure is not present in the schema (everything is
    // under physiology).  So we need to search through each of our physiology sub-sections to find this request
    childNode = static_cast<DataRequestNode*>(index(childIndex, 0, physiologyIndex).internalPointer());   //Physioloy sub-type (Cardiovascular, Respiratory, ...)
    for (int i = 0; i < childNode->children().size(); ++i) {
      //Search children within sub-type (e.g. Cardiovacular->Heart Rate, Blood Pressure, ...)
      if (childNode->children()[i]->name().toStdString() == req->Name()) {
        childNode->collapsed(false);    //Show physiology type in open view
        childNode->children()[i]->checked(true);    //Request check box will be checked
        foundRequest = true;  //Stop searching
        break;
      }
    }
    ++childIndex;
  }
  return QString::fromStdString(request);
}
//------------------------------------------------------------------------------------
QString DataRequestTree::encode_substance_request(CDM::SubstanceDataRequestData* req)
{
  //Format request string that will be used to create Request Component in Scenario Builder
  std::string request = "TYPE=Substance";
  request += ("NAME=" + req->Substance() + "," + req->Name() + ";");
  if (req->Unit().present()) {
    request += ("UNIT=" + req->Unit().get() + ";");
  }
  if (req->Precision().present()) {
    request += ("PRECISION=" + std::to_string(req->Precision().get()));
  }
  //Set data in RequestModel so that when Scenario Builder is opened, the request menu will have the proper sub-menus opened and request options checked
  QModelIndex substanceGroupIndex = index(4, 0, QModelIndex()); //substance branch is 4th element inside top level
  DataRequestNode* substanceGroupNode = static_cast<DataRequestNode*>(substanceGroupIndex.internalPointer());
  substanceGroupNode->collapsed(false);
  for (int i = 0; i < substanceGroupNode->children().size(); ++i) {
    //Next level is substance name -- figure out which substance we are requesting
    if (substanceGroupNode->children()[i]->name().toStdString() == req->Substance()) {
      QModelIndex substanceIndex = index(i, 0, substanceGroupIndex);
      DataRequestNode* substanceNode = static_cast<DataRequestNode*>(substanceIndex.internalPointer());
      substanceNode->collapsed(false);
      for (int j = 0; j < substanceNode->children().size(); ++j) {
        //Now that we know compartment, figure out the name of the data request
        if (req->Name() == substanceNode->children()[j]->name().toStdString()) {
          substanceNode->children()[j]->checked(true);
          break;
        }
      }
      break;
    }
  }
  return QString::fromStdString(request);
}
//------------------------------------------------------------------------------------
CDM::DataRequestData* DataRequestTree::decode_request(QString request)
{
  CDM::DataRequestData* bgRequest = nullptr;
  std::vector<std::string> inputs = biogears::split(request.toStdString(), ';');
  std::string requestType = biogears::split(inputs[0], '=')[1]; // Extract type from "TYPE=type"
  if (requestType == "GasCompartment") {
    bgRequest = decode_compartment_request(0, inputs);
  } else if (requestType == "LiquidCompartment") {
    bgRequest = decode_compartment_request(1, inputs);
  } else if (requestType == "ThermalCompartment") {
    bgRequest = decode_compartment_request(2, inputs);
  } else if (requestType == "TissueCompartment") {
    bgRequest = decode_compartment_request(3, inputs);
  } else if (requestType == "Environment") {

  } else if (requestType == "Patient") {
    bgRequest = decode_patient_request(inputs);
  } else if (requestType == "Physiology") {
    bgRequest = decode_physiology_request(inputs);
  } else if (requestType == "Substance") {
    bgRequest = decode_substance_request(inputs);
  }
  return bgRequest;
}
//------------------------------------------------------------------------------------
CDM::CompartmentDataRequestData* DataRequestTree::decode_compartment_request(int type, std::vector<std::string>& args)
{
  std::vector<std::string> inputSplit;
  std::vector<std::string> nameSplit;
  //0 = Gas, 1 = Liquid, 2 = Thermal, 3 = Tissue
  switch (type) {
  case 0: {
    CDM::GasCompartmentDataRequestData* gRequest = new CDM::GasCompartmentDataRequestData();
    for (int i = 1; i < args.size(); ++i) {
      inputSplit = biogears::split(args[i], '=');
      if (inputSplit[0] == "NAME") {
        nameSplit = biogears::split(inputSplit[1], ','); //sub request name formatted as "NAME=Compartment,value name"
        gRequest->Compartment(nameSplit[0]);
        gRequest->Name(nameSplit[1]);
      } else if (inputSplit[0] == "UNIT") {
        gRequest->Unit(inputSplit[1]);
      } else if (inputSplit[0] == "PRECISION") {
        gRequest->Precision(std::stoi(inputSplit[1]));
      } else if (inputSplit[0] == "SUBSTANCE") {
        gRequest->Substance(inputSplit[1]);
      }
    }
    return gRequest;
  }
  case 1: {
    CDM::LiquidCompartmentDataRequestData* lRequest = new CDM::LiquidCompartmentDataRequestData();
    for (int i = 1; i < args.size(); ++i) {
      inputSplit = biogears::split(args[i], '=');
      if (inputSplit[0] == "NAME") {
        nameSplit = biogears::split(inputSplit[1], ','); //sub request name formatted as "NAME=Compartment,value name"
        lRequest->Compartment(nameSplit[0]);
        lRequest->Name(nameSplit[1]);
      } else if (inputSplit[0] == "UNIT") {
        lRequest->Unit(inputSplit[1]);
      } else if (inputSplit[0] == "PRECISION") {
        lRequest->Precision(std::stoi(inputSplit[1]));
      } else if (inputSplit[0] == "SUBSTANCE") {
        lRequest->Substance(inputSplit[1]);
      }
    }
    return lRequest;
  }
  case 2: {
    CDM::ThermalCompartmentDataRequestData* thRequest = new CDM::ThermalCompartmentDataRequestData();
    for (int i = 1; i < args.size(); ++i) {
      inputSplit = biogears::split(args[i], '=');
      if (inputSplit[0] == "NAME") {
        nameSplit = biogears::split(inputSplit[1], ','); //sub request name formatted as "NAME=Compartment,value name"
        thRequest->Compartment(nameSplit[0]);
        thRequest->Name(nameSplit[1]);
      } else if (inputSplit[0] == "UNIT") {
        thRequest->Unit(inputSplit[1]);
      } else if (inputSplit[0] == "PRECISION") {
        thRequest->Precision(std::stoi(inputSplit[1]));
      }
    }
    return thRequest;
  }
  case 3: {
    CDM::TissueCompartmentDataRequestData* tisRequest = new CDM::TissueCompartmentDataRequestData();
    for (int i = 1; i < args.size(); ++i) {
      inputSplit = biogears::split(args[i], '=');
      if (inputSplit[0] == "NAME") {
        nameSplit = biogears::split(inputSplit[1], ','); //sub request name formatted as "NAME=Compartment,value name"
        tisRequest->Compartment(nameSplit[0]);
        tisRequest->Name(nameSplit[1]);
      } else if (inputSplit[0] == "UNIT") {
        tisRequest->Unit(inputSplit[1]);
      } else if (inputSplit[0] == "PRECISION") {
        tisRequest->Precision(std::stoi(inputSplit[1]));
      }
    }
    return tisRequest;
  }
  default:
    return nullptr;
  }
}
//------------------------------------------------------------------------------------
CDM::EnvironmentDataRequestData* DataRequestTree::decode_environment_request(std::vector<std::string>& args)
{
  return nullptr;
}
//------------------------------------------------------------------------------------
CDM::PatientDataRequestData* DataRequestTree::decode_patient_request(std::vector<std::string>& args)
{
  CDM::PatientDataRequestData* pRequest = new CDM::PatientDataRequestData();
  std::vector<std::string> inputSplit;
  //Start at index 1 (TYPE was stored in index 0)
  for (int i = 1; i < args.size(); ++i) {
    inputSplit = biogears::split(args[i], '=');
    if (inputSplit[0] == "NAME") {
      pRequest->Name(inputSplit[1]);
    } else if (inputSplit[0] == "UNIT") {
      pRequest->Unit(inputSplit[1]);
    } else if (inputSplit[0] == "PRECISION") {
      pRequest->Precision(std::stoi(inputSplit[1]));
    }
  }
  return pRequest;
}
//------------------------------------------------------------------------------------
CDM::PhysiologyDataRequestData* DataRequestTree::decode_physiology_request(std::vector<std::string>& args)
{
  CDM::PhysiologyDataRequestData* phyRequest = new CDM::PhysiologyDataRequestData();
  std::vector<std::string> inputSplit;
  //Start at index 1 (TYPE was stored in index 0)
  for (int i = 1; i < args.size(); ++i) {
    inputSplit = biogears::split(args[i], '=');
    if (inputSplit[0] == "NAME") {
      phyRequest->Name(inputSplit[1]);
    } else if (inputSplit[0] == "UNIT") {
      phyRequest->Unit(inputSplit[1]);
    } else if (inputSplit[0] == "PRECISION") {
      phyRequest->Precision(std::stoi(inputSplit[1]));
    }
  }
  return phyRequest;
}
//------------------------------------------------------------------------------------
CDM::SubstanceDataRequestData* DataRequestTree::decode_substance_request(std::vector<std::string>& args)
{
  CDM::SubstanceDataRequestData* subRequest = new CDM::SubstanceDataRequestData();
  std::vector<std::string> inputSplit;
  //Start at index 1 (TYPE was stored in index 0)
  for (int i = 1; i < args.size(); ++i) {
    inputSplit = biogears::split(args[i], '=');
    if (inputSplit[0] == "NAME") {
      std::vector<std::string> subNameSplit = biogears::split(inputSplit[1], ','); //sub request name formatted as "NAME=Substance,value name"
      subRequest->Substance(subNameSplit[0]);
      subRequest->Name(subNameSplit[1]);
    } else if (inputSplit[0] == "UNIT") {
      subRequest->Unit(inputSplit[1]);
    } else if (inputSplit[0] == "PRECISION") {
      subRequest->Precision(std::stoi(inputSplit[1]));
    }
  }
  return subRequest;
}
//------------------------------------------------------------------------------------
void DataRequestTree::initialize(biogears::SECompartmentManager* comps, biogears::SESubstanceManager* subs)
{
  //============== Top Level Data =================================================
  auto compartmentTree = appendChild(QString("Compartment"));
  auto environmentTree = appendChild(QString("Environment"));
  auto patientTree = appendChild(QString("Patient"));
  auto physiologyTree = appendChild(QString("Physiology"));
  auto substanceTree = appendChild(QString("Substance"));
  //============= Compartment Sub-Tree ===============================================
  auto cGasTree = compartmentTree->appendChild(QString("Gas"));
  auto cLiquidTree = compartmentTree->appendChild(QString("Liquid"));
  auto cThermalTree = compartmentTree->appendChild(QString("Thermal"));
  auto cTissueTree = compartmentTree->appendChild(QString("Tissue"));
  //--Gas subtree -- loop over gas compartment names, add a node for each one and then nest available suboptions beneath them
  QList<QPair<QString, QString>> cGasRequests = { qMakePair(QString("InFlow"), QString("VolumePerTime")),
    qMakePair(QString("OutFlow"), QString("VolumePerTime")),
    qMakePair(QString("Pressure"), QString("Pressure")),
    qMakePair(QString("Volume"), QString("Volume")),
    qMakePair(QString("Substance Quantity"), QString("")) };

  for (auto gas : comps->GetGasCompartments()) {
    auto gasNode = cGasTree->appendChild(QString::fromStdString(gas->GetName()));
    auto propNode = gasNode->appendChildren(cGasRequests);
  }
  //--Liquid subtree-- loop over liquid compartment names, add a node for each one and then nest available suboptions beneath them
  QList<QPair<QString, QString>> cLiquidRequests = { qMakePair(QString("InFlow"), QString("VolumePerTime")),
    qMakePair(QString("OutFlow"), QString("VolumePerTime")),
    qMakePair(QString("pH"), QString("")),
    qMakePair(QString("Pressure"), QString("Pressure")),
    qMakePair(QString("Volume"), QString("Volume")),
    qMakePair(QString("Substance Quantity"), QString("")),
    qMakePair(QString("Water Volume Fraction"), QString("")) };
  for (auto liquid : comps->GetLiquidCompartments()) {
    auto liquidNode = cLiquidTree->appendChild(QString::fromStdString(liquid->GetName()));
    auto propNode = liquidNode->appendChildren(cLiquidRequests);
  }
  //--Thermal subtree-- loop over thermal compartment names, add a node for each one and then nest available suboptions beneath them
  QList<QPair<QString, QString>> cThermalRequests = { qMakePair(QString("Heat Transfer Rate In"), QString("Power")),
    qMakePair(QString("Heat Transfer Rate Out"), QString("Power")),
    qMakePair(QString("Temperature"), QString("Temperature")),
    qMakePair(QString("Heat"), QString("Energy")) };
  for (auto thermal : comps->GetThermalCompartments()) {
    auto thermalNode = cThermalTree->appendChild(QString::fromStdString(thermal->GetName()));
    auto propNode = thermalNode->appendChildren(cThermalRequests);
  }
  //--Tissue subtree-- loop over tissue compartment names, add a node for each one and then nest available suboptions beneath them
  QList<QPair<QString, QString>> cTissueRequests = {
    qMakePair(QString("Acidic Phospholipid Concentration"), QString("MassPerMass")),
    qMakePair(QString("Matrix Volume"), QString("Volume")),
    qMakePair(QString("Membrane Potential"), QString("ElectricPotential")),
    qMakePair(QString("Neutral Lipids Volume Fraction"), QString("")),
    qMakePair(QString("Neutral Phospholipids Volume Fraction"), QString("")),
    qMakePair(QString("Reflection Coefficient"), QString("")),
    qMakePair(QString("Tissue To Plasma Albumin Ratio"), QString("")),
    qMakePair(QString("Tissue To Plasma Alpha-Acid Glycoprotein Ratio"), QString("")),
    qMakePair(QString("Tissue To Plasma Lipoprotein Ratio"), QString("")),
    qMakePair(QString("Total Mass"), QString("Mass")),
  };
  for (auto tissue : comps->GetTissueCompartments()) {
    auto tissueNode = cTissueTree->appendChild(QString::fromStdString(tissue->GetName()));
    auto propNode = tissueNode->appendChildren(cTissueRequests);
  }
  //================  Environment Sub-Tree  =====================================================

  //================  Patient Sub-Tree  =========================================================
  auto pAge = patientTree->appendChild(QString("Age"), QString("Time"));
  auto pAlveoliSA = patientTree->appendChild(QString("Alveoli Surface Area"), QString("Area"));
  auto pBMR = patientTree->appendChild(QString("Basal Metabolic Rate"), QString("Power"));
  auto pBloodVolumeBase = patientTree->appendChild(QString("Blood Volume Baseline"), QString("Volume"));
  auto pBodyDensity = patientTree->appendChild(QString("Body Density"), QString("MassPerVolume"));
  auto pBodyFatFraction = patientTree->appendChild(QString("Body Fat Fraction"));
  auto pDiastolicBase = patientTree->appendChild(QString("Diastolic Arterial Pressure Baseline"), QString("Pressure"));
  auto pExpiratoryReserve = patientTree->appendChild(QString("Expiratory Reserve Volume"), QString("Volume"));
  auto pFunctionalCapacity = patientTree->appendChild(QString("Functional Residual Capacity"), QString("Volume"));
  auto pHeartRateBase = patientTree->appendChild(QString("Heart Rate Baseline"), QString("Frequency"));
  auto pHeartRateMax = patientTree->appendChild(QString("Heart Rate Maximum"), QString("Frequency"));
  auto pHeartRateMin = patientTree->appendChild(QString("Heart Rate Minimum"), QString("Frequency"));
  auto pInspiratoryCapacity = patientTree->appendChild(QString("Inspiratory Capacity"), QString("Volume"));
  auto pInspiratoryReserve = patientTree->appendChild(QString("Inspitatory Reserve Volume"), QString("Volume"));
  auto pLeanBodyMass = patientTree->appendChild(QString("Lean Body Mass"), QString("Mass"));
  auto pMaxWorkRate = patientTree->appendChild(QString("Maximum Work Rate"), QString("Power"));
  auto pMeanPressureBase = patientTree->appendChild(QString("Mean Arterial Pressure Baseline"), QString("Pressure"));
  auto pMuscleMass = patientTree->appendChild(QString("Muscle Mass"), QString("Mass"));
  auto pPain = patientTree->appendChild(QString("Pain Susceptibility"));
  auto pResidual = patientTree->appendChild(QString("Residual Volume"), QString("Volume"));
  auto pRespiratoryBase = patientTree->appendChild(QString("Respiration Rate Baseline"), QString("Frequency"));
  auto pRightLungRatio = patientTree->appendChild(QString("Right Lung Ratio"), QString(""));
  auto pSkinSA = patientTree->appendChild(QString("Skin Surface Area"), QString("Area"));
  auto pSystolicBase = patientTree->appendChild(QString("Systolic Arterial Pressure Baseline"), QString("Pressure"));
  auto pTidalBase = patientTree->appendChild(QString("Tidal Volume Baseline"), QString("Volume"));
  auto pTotalCapacity = patientTree->appendChild(QString("Total Lung Capacity"), QString("Volume"));
  auto pVentilationBase = patientTree->appendChild(QString("Total Ventilation Baseline"), QString("Volume"));
  auto pVital = patientTree->appendChild(QString("Vital Capacity"), QString("Volume"));

  //================  Physiology Sub-Tree  =========================================================
  //--Blood Chemistry Sub-tree
  auto phyBloodChemistry = physiologyTree->appendChild(QString("Blood Chemistry"));
  auto bcArterialPH = phyBloodChemistry->appendChild(QString("Arterial Blood pH"));
  auto bcArterialCO2 = phyBloodChemistry->appendChild(QString("Arterial Carbon Dioxide Pressure"), QString("Pressure"));
  auto bcArterialO2 = phyBloodChemistry->appendChild(QString("Arterial Oxygen Pressure"), QString("Pressure"));
  auto bcBloodDensity = phyBloodChemistry->appendChild(QString("Blood Density"), QString("MassPerVolume"));
  auto bcBloodHeat = phyBloodChemistry->appendChild(QString("Blood Specific Heat"), QString("HeatCapacitancePerMass"));
  auto bcBloodUrea = phyBloodChemistry->appendChild(QString("Blood Urea Nitrogen Concentration"), QString("MassPerVolume"));
  auto bcCO2Sat = phyBloodChemistry->appendChild(QString("Carbon Dioxide Saturation"));
  auto bcCOSat = phyBloodChemistry->appendChild(QString("Carbon Monoxide Saturation"));
  auto bcHematocrit = phyBloodChemistry->appendChild(QString("Hematocrit"));
  auto bcHemoglobin = phyBloodChemistry->appendChild(QString("Hemoglobin Content"), QString("Mass"));
  auto bcHemoglobinLost = phyBloodChemistry->appendChild(QString("Hemoglobin Lost to Urine"), QString("Mass"));
  auto bcInflammation = phyBloodChemistry->appendChild(QString("Inflammatory Response"));
  //--Inflammation options
  auto inAutonomic = bcInflammation->appendChild(QString("Autonomic Response Level"));
  auto inBloodPathogen = bcInflammation->appendChild(QString("Blood Pathogen"));
  auto inBloodCatecholamines = bcInflammation->appendChild(QString("Catecholamines"));
  auto inBloodcNOS = bcInflammation->appendChild(QString("Constitutive NOS"));
  auto inBloodNOS = bcInflammation->appendChild(QString("Inducible NOS"));
  auto inBloodPreNOS = bcInflammation->appendChild(QString("Inducible NOSPre"));
  auto inTime = bcInflammation->appendChild(QString("Inflammation Time"));
  auto inBloodIL6 = bcInflammation->appendChild(QString("Interleukin 6"));
  auto inBloodIL10 = bcInflammation->appendChild(QString("Interleukin 10"));
  auto inBloodIL12 = bcInflammation->appendChild(QString("Interleukin 12"));
  auto inLocalBarrier = bcInflammation->appendChild(QString("Local Barrier"));
  auto inLocalMacropage = bcInflammation->appendChild(QString("Local Macrophage"));
  auto inLocalNeutrophil = bcInflammation->appendChild(QString("Local Neutrophil"));
  auto inLocalPathogen = bcInflammation->appendChild(QString("Local Pathogen"));
  auto inBloodActiveMacropage = bcInflammation->appendChild(QString("Macrophage Active"));
  auto inBloodRestingMacropage = bcInflammation->appendChild(QString("Macrophage Resting"));
  auto inBloodActiveNeutrophil = bcInflammation->appendChild(QString("Neutrophil Active"));
  auto inBloodRestingNeutrophil = bcInflammation->appendChild(QString("Neutrophil Resting"));
  auto inBloodNO3 = bcInflammation->appendChild(QString("Nitrate"));
  auto inBloodNO = bcInflammation->appendChild(QString("Nitric Oxide"));
  auto inTissueIntegrity = bcInflammation->appendChild(QString("Tissue Integrity"));
  auto inBloodTNF = bcInflammation->appendChild(QString("Tumor Necrosis Factor"));
  //Resume blood chemistry sub-tree
  auto bcO2Sat = phyBloodChemistry->appendChild(QString("Oxygen Arterial Saturation"));
  auto bcO2SatVen = phyBloodChemistry->appendChild(QString("Oxygen Venous Saturation"));
  auto bcPhosphate = phyBloodChemistry->appendChild(QString("Phosphate Concentration"), QString("AmountPerVolume"));
  auto bcPlasma = phyBloodChemistry->appendChild(QString("Plasma Volume"), QString("Volume"));
  auto bcPulmArterialCO2 = phyBloodChemistry->appendChild(QString("Pulmonary Arterial Carbon Dioxide Pressure"), QString("Pressure"));
  auto bcPulmArterialO2 = phyBloodChemistry->appendChild(QString("Pulmonary Arterial Oxygen Pressure"), QString("Pressure"));
  auto bcPulmVenousCO2 = phyBloodChemistry->appendChild(QString("Pulmonary Venous Carbon Dioxide Pressure"), QString("Pressure"));
  auto bcPulmVenousO2 = phyBloodChemistry->appendChild(QString("Pulmonary Venous Oxygen Pressure"), QString("Pressure"));
  auto bcPulseOx = phyBloodChemistry->appendChild(QString("Pulse Oximetry"), QString(""));
  auto bcRBCach = phyBloodChemistry->appendChild(QString("Red Blood Cell Acetylcholinesterase"), QString("AmountPerVolume"));
  auto bcRBC = phyBloodChemistry->appendChild(QString("Red Blood Cell Count"), QString("AmountPerVolume"));
  auto bcShunt = phyBloodChemistry->appendChild(QString("Shunt Fraction"));
  auto bcSID = phyBloodChemistry->appendChild(QString("Strong Ion Difference"), QString("AmountPerVolume"));
  auto bcBilirubin = phyBloodChemistry->appendChild(QString("Total Bilirubin"), QString("MassPerVolume"));
  auto bcTotalProtein = phyBloodChemistry->appendChild(QString("Total Protein Concentration"), QString("MassPerVolume"));
  auto bcVenousCO2 = phyBloodChemistry->appendChild(QString("Venous Carbon Dioxide Pressure"), QString("Pressure"));
  auto bcVenousO2 = phyBloodChemistry->appendChild(QString("Venous Oxygen Pressure"), QString("Pressure"));
  auto bcLipid = phyBloodChemistry->appendChild(QString("Volume Fraction Neutral Lipids in Plasma"));
  auto bcPhospholipid = phyBloodChemistry->appendChild(QString("Volume Fraction Neutral Phospholipids in Plasma"));
  auto bcWBC = phyBloodChemistry->appendChild(QString("White Blood Cell Count"), QString("AmountPerVolume"));
  //Cardiovascular sub-tree
  auto phyCardio = physiologyTree->appendChild(QString("Cardiovascular"));
  auto cvArterial = phyCardio->appendChild(QString("Arterial Pressure"), QString("Pressure"));
  auto cvBloodVolume = phyCardio->appendChild(QString("Blood Volume"), QString("Volume"));
  auto cvCardiacOutput = phyCardio->appendChild(QString("Cardiac Output"), QString("VolumePerTime"));
  auto cvCVP = phyCardio->appendChild(QString("Central Venous Pressure"), QString("Pressure"));
  auto cvCBF = phyCardio->appendChild(QString("Cerebral Blood Flow"), QString("VolumePerTime"));
  auto cvPerfusion = phyCardio->appendChild(QString("Cerebral Perfusion Pressure"), QString("Pressure"));
  auto cvDiastolic = phyCardio->appendChild(QString("Diastolic Arterial Pressure"), QString("Pressure"));
  auto cvEjectionFraction = phyCardio->appendChild(QString("Heart Ejection Fraction"));
  auto cvHeartRate = phyCardio->appendChild(QString("Heart Rate"), QString("Frequency"));
  auto cvHeartVolume = phyCardio->appendChild(QString("Heart Stroke Volume"), QString("Volume"));
  auto cvICP = phyCardio->appendChild(QString("Intracranial Pressure"), QString("Pressure"));
  auto cvMAP = phyCardio->appendChild(QString("Mean Arterial Pressure"), QString("Pressure"));
  auto cvMeanCVP = phyCardio->appendChild(QString("Mean Central Venous Pressure"), QString("Pressure"));
  auto cvSkinFlow = phyCardio->appendChild(QString("Mean Skin Blood Flow"), QString("VolumePerTime"));
  auto cvPulmPressure = phyCardio->appendChild(QString("Pulmonary Arterial Pressure"), QString("Pressure"));
  auto cvPulmWedge = phyCardio->appendChild(QString("Pulmonary Capillaries Wedge Pressure"), QString("Pressure"));
  auto cvPulmDiastolic = phyCardio->appendChild(QString("Pulmonary Diastolic Arterial Pressure"), QString("Pressure"));
  auto cvPulmMAP = phyCardio->appendChild(QString("Pulmonary Mean Arterial Pressure"), QString("Pressure"));
  auto cvPulmCapFlow = phyCardio->appendChild(QString("Pulmonary Mean Capillaries Flow"), QString("VolumePerTime"));
  auto cvPulmShuntFlow = phyCardio->appendChild(QString("Pulmonary Mean Shunt Flow"), QString("VolumePerTime"));
  auto cvPulmSystolic = phyCardio->appendChild(QString("Pulmonary Systolic Arterial Pressure"), QString("Pressure"));
  auto cvPulmResistance = phyCardio->appendChild(QString("Pulmonary Vascular Resistance"), QString("FlowResistance"));
  auto cvPulmResistanceIndex = phyCardio->appendChild(QString("Pulmonary Vascular Resistance Index"), QString("PressureTimePerVolumeArea"));
  auto cvPulsePressure = phyCardio->appendChild(QString("Pulse Pressure"), QString("Pressure"));
  auto cvSVR = phyCardio->appendChild(QString("Systemic Vascular Resistance"), QString("FlowResistance"));
  auto cvSAP = phyCardio->appendChild(QString("Systolic Arterial Pressure"), QString("Pressure"));
  //--Drug sub-tree
  auto phyDrug = physiologyTree->appendChild(QString("Drugs"));
  auto drugAntibiotic = phyDrug->appendChild(QString("Antibiotic Activity"));
  auto drugBronchodilation = phyDrug->appendChild(QString("Bronchodilation Level"));
  auto drugCNS = phyDrug->appendChild(QString("Central Nervous Response"));
  auto drugFever = phyDrug->appendChild(QString("Fever Change"), QString("Temperature"));
  auto drugHeartRate = phyDrug->appendChild(QString("Heart Rate Change"), QString("Frequency"));
  auto drugHemorrhage = phyDrug->appendChild(QString("Hemorrhage Reduction"));
  auto drugMAP = phyDrug->appendChild(QString("Mean Blood Pressure Change"), QString("Pressure"));
  auto drugNeuro = phyDrug->appendChild(QString("Neurmuscular Block Level"));
  auto drugPain = phyDrug->appendChild(QString("Pain Tolerance Change"));
  auto drugPulse = phyDrug->appendChild(QString("Pulse Pressure Change"), QString("Pressure"));
  auto drugRespiration = phyDrug->appendChild(QString("Respiration Rate Change"), QString("Frequency"));
  auto drugSedation = phyDrug->appendChild(QString("Sedation Level"));
  auto drugTidalVolume = phyDrug->appendChild(QString("Tidal Volume Change"), QString("Volume"));
  auto drugTubular = phyDrug->appendChild(QString("Tubular Permeability Change"));
  //--Energy sub-tree
  auto phyEnergy = physiologyTree->appendChild(QString("Energy"));
  auto energyAchieved = phyEnergy->appendChild(QString("Achieved Exercise Level"));
  auto energyChloride = phyEnergy->appendChild(QString("Chloride Lost to Sweat"), QString("Mass"));
  auto energyCore = phyEnergy->appendChild(QString("Core Temperature"), QString("Temperature"));
  auto energyCreatinine = phyEnergy->appendChild(QString("Creatinine Production Rate"), QString("AmountPerTime"));
  auto energyDeficit = phyEnergy->appendChild(QString("Energy Deficit"), QString("Power"));
  auto energyDemand = phyEnergy->appendChild(QString("Exercise Energy Demand"), QString("Power"));
  auto energyMapDelta = phyEnergy->appendChild(QString("Exercise Mean Arterial Pressure Delta"), QString("Pressure"));
  auto energyFatigue = phyEnergy->appendChild(QString("Fatigue Level"));
  auto energyLactate = phyEnergy->appendChild(QString("Lactate Production Rate"), QString("AmountPerTime"));
  auto energyPotassium = phyEnergy->appendChild(QString("Potassium Lost to Sweat"), QString("Mass"));
  auto energySkin = phyEnergy->appendChild(QString("Skin Temperature"), QString("Temperature"));
  auto energySodium = phyEnergy->appendChild(QString("Sodium Lost to Sweat"), QString("Mass"));
  auto energyMetabolic = phyEnergy->appendChild(QString("Total Metabolic Rate"), QString("Power"));
  auto energyWorkRate = phyEnergy->appendChild(QString("Total Work Fraction of Max"));
  //--Endocrine sub-tree
  auto phyEndo = physiologyTree->appendChild(QString("Endocrine"));
  auto endoGlucagon = phyEndo->appendChild(QString("Glucagon Synthesis Rate"), QString("AmountPerTime"));
  auto endoInsulin = phyEndo->appendChild(QString("Insulin Synthesis Rate"), QString("AmountPerTime"));
  //--Gastrointestinal sub-tree
  auto phyGI = physiologyTree->appendChild(QString("Gastrointestinal"));
  auto giChyme = phyGI->appendChild(QString("Chyme Absorption Rate"), QString("VolumePerTime"));
  //--Stomach contents sub-tree
  auto giStomach = phyGI->appendChild(QString("Stomach Contents"));
  auto calcium = giStomach->appendChild(QString("Calcium"), QString("Mass"));
  auto carbs = giStomach->appendChild(QString("Carbohydrate"), QString("Mass"));
  auto fat = giStomach->appendChild(QString("Fat"), QString("Mass"));
  auto protein = giStomach->appendChild(QString("Protein"), QString("Mass"));
  auto sodium = giStomach->appendChild(QString("Sodium"), QString("Mass"));
  auto water = giStomach->appendChild(QString("Water"), QString("Volume"));
  //--Hepatic sub-tree
  auto phyHep = physiologyTree->appendChild(QString("Hepatic"));
  auto hepGluc = phyHep->appendChild(QString("Hepatic Gluconeogenisis Rate"), QString("MassPerTime"));
  auto hepKetones = phyHep->appendChild(QString("Ketone Production Rate"), QString("AmountPerTime"));
  //--Nervous sub-tree
  auto phyNervous = physiologyTree->appendChild(QString("Nervous"));
  auto nervousLapses = phyNervous->appendChild(QString("Attention Lapses"));
  auto nervousDebt = phyNervous->appendChild(QString("Biological Debt"));
  auto nervousCompliance = phyNervous->appendChild(QString("Compliance Scale"));
  auto nervousHeartElastance = phyNervous->appendChild(QString("Heart Elastance Scale"));
  auto nervousHeartRate = phyNervous->appendChild(QString("Heart Rate Scale"));
  auto nervousLeftEye = phyNervous->appendChild(QString("Left Eye Pupillary Response"));
  auto nervousPain = phyNervous->appendChild(QString("Pain Visual Analogue Scale"));
  auto nervousrReactionTime = phyNervous->appendChild(QString("Reaction Time"), QString("Time"));
  auto nervousExtrasplanchnicRes = phyNervous->appendChild(QString("Resistance Scale Extrasplanchnic"));
  auto nervousMuscleRes = phyNervous->appendChild(QString("Resistance Scale Muscle"));
  auto nervousMyocardiumRes = phyNervous->appendChild(QString("Resistance Scale Myocardium"));
  auto nervousSplanchnicRes = phyNervous->appendChild(QString("Resistance Scale Splanchnic"));
  auto nervousRAS = phyNervous->appendChild(QString("Richmond Agitation Sedation Scale"));
  auto nervousRightEye = phyNervous->appendChild(QString("Right Eye Pupillary Response"));
  auto nervousSleepTime = phyNervous->appendChild(QString("Sleep Time"), QString("Time"));
  auto nervousWakeTime = phyNervous->appendChild(QString("Wake Time"), QString("Time"));
  //--Renal sub-tree
  auto phyRenal = physiologyTree->appendChild(QString("Renal"));
  auto renalFiltration = phyRenal->appendChild(QString("Filtration Fraction"));
  auto renalGFR = phyRenal->appendChild(QString("Glomerular Filtration Rate"), QString("VolumePerTime"));
  auto renalLeftAfferentRes = phyRenal->appendChild(QString("Left Afferent Arteriole Resistance"), QString("FlowResistance"));
  auto renalLeftBowmansHydro = phyRenal->appendChild(QString("Left Bowmans Capsule Hydrostatic Pressure"), QString("Pressure"));
  auto renalLeftBowmansOsmotic = phyRenal->appendChild(QString("Left Bowmans Capsule Osmotic Pressure"), QString("Pressure"));
  auto renalLeftGlomHydro = phyRenal->appendChild(QString("Left Glomerular Capillaries Hydrostatic Pressure"), QString("Pressure"));
  auto renalLeftGlomOsmotic = phyRenal->appendChild(QString("Left Glomerular Capillaries Osmotic Pressure"), QString("Pressure"));
  auto renalLeftGlomCoef = phyRenal->appendChild(QString("Left Glomerular Filtration Coefficient"), QString("VolumePerTimePressure"));
  auto renalLeftGlomRate = phyRenal->appendChild(QString("Left Glomerular Filtration Rate"), QString("VolumePerTime"));
  auto renalLeftGlomSA = phyRenal->appendChild(QString("Left Glomerular Filtration Surface Area"), QString("Area"));
  auto renalLeftGlomPerm = phyRenal->appendChild(QString("Left Glomerular Fluid Permeability"), QString("VolumePerTimePressure"));
  auto renalLeftFraction = phyRenal->appendChild(QString("Left Filtration Fraction"));
  auto renalLeftNetFraction = phyRenal->appendChild(QString("Left Net Filtration Fraction"));
  auto renalLeftNetReabsorption = phyRenal->appendChild(QString("Left Net Reabsorption Pressure"), QString("Pressue"));
  auto renalLeftPeriHydro = phyRenal->appendChild(QString("Left Peritubular Capillaries Hydrostatic Pressure"), QString("Pressure"));
  auto renalLeftPeriOsmotic = phyRenal->appendChild(QString("Left Peritubular Capillaries Osmotic Pressure"), QString("Pressure"));
  auto renalLeftReabsCoef = phyRenal->appendChild(QString("Left Reabsorption Filtration Coefficient"), QString("VolumePerTimePressure"));
  auto renalLeftReabsRate = phyRenal->appendChild(QString("Left Reabsorption Rate"), QString("VolumePerTime"));
  auto renalLeftTubularHydro = phyRenal->appendChild(QString("Left Tubular Hydrostatic Pressure"), QString("Pressure"));
  auto renalLeftTubularOsmotic = phyRenal->appendChild(QString("Left Tubular Osmotic Pressure"), QString("Pressure"));
  auto renalLeftTubularSA = phyRenal->appendChild(QString("Left Tubular Reabsorption Filtration Surface Area"), QString("Area"));
  auto renalLeftTubularPerm = phyRenal->appendChild(QString("Left Tubular Reabsorption Fluid Permeability"), QString("VolumePerTimePressure"));
  auto renalMeanUrineOutput = phyRenal->appendChild(QString("Meane Urine Output"), QString("VolumePerTime"));
  auto renalBloodFlow = phyRenal->appendChild(QString("Renal Blood Flow"), QString("VolumePerTime"));
  auto renalPlasmaFlow = phyRenal->appendChild(QString("Renal Plasma Flow"), QString("VolumePerTime"));
  auto renalResistance = phyRenal->appendChild(QString("Renal Vascular Resistance"), QString("FlowResistance"));
  auto renalRightAfferentRes = phyRenal->appendChild(QString("Right Afferent Arteriole Resistance"), QString("FlowResistance"));
  auto renalRightBowmansHydro = phyRenal->appendChild(QString("Right Bowmans Capsule Hydrostatic Pressure"), QString("Pressure"));
  auto renalRightBowmansOsmotic = phyRenal->appendChild(QString("Right Bowmans Capsule Osmotic Pressure"), QString("Pressure"));
  auto renalRightGlomHydro = phyRenal->appendChild(QString("Right Glomerular Capillaries Hydrostatic Pressure"), QString("Pressure"));
  auto renalRightGlomOsmotic = phyRenal->appendChild(QString("Right Glomerular Capillaries Osmotic Pressure"), QString("Pressure"));
  auto renalRightGlomCoef = phyRenal->appendChild(QString("Right Glomerular Filtration Coefficient"), QString("VolumePerTimePressure"));
  auto renalRightGlomRate = phyRenal->appendChild(QString("Right Glomerular Filtration Rate"), QString("VolumePerTime"));
  auto renalRightGlomSA = phyRenal->appendChild(QString("Right Glomerular Filtration Surface Area"), QString("Area"));
  auto renalRightGlomPerm = phyRenal->appendChild(QString("Right Glomerular Fluid Permeability"), QString("VolumePerTimePressure"));
  auto renalRightFraction = phyRenal->appendChild(QString("Right Filtration Fraction"));
  auto renalRightNetFraction = phyRenal->appendChild(QString("Right Net Filtration Fraction"));
  auto renalRightNetReabsorption = phyRenal->appendChild(QString("Right Net Reabsorption Pressure"), QString("Pressue"));
  auto renalRightPeriHydro = phyRenal->appendChild(QString("Right Peritubular Capillaries Hydrostatic Pressure"), QString("Pressure"));
  auto renalRightPeriOsmotic = phyRenal->appendChild(QString("Right Peritubular Capillaries Osmotic Pressure"), QString("Pressure"));
  auto renalRightReabsCoef = phyRenal->appendChild(QString("Right Reabsorption Filtration Coefficient"), QString("VolumePerTimePressure"));
  auto renalRightReabsRate = phyRenal->appendChild(QString("Right Reabsorption Rate"), QString("VolumePerTime"));
  auto renalRightTubularHydro = phyRenal->appendChild(QString("Right Tubular Hydrostatic Pressure"), QString("Pressure"));
  auto renalRightTubularOsmotic = phyRenal->appendChild(QString("Right Tubular Osmotic Pressure"), QString("Pressure"));
  auto renalRightTubularSA = phyRenal->appendChild(QString("Right Tubular Reabsorption Filtration Surface Area"), QString("Area"));
  auto renalRightTubularPerm = phyRenal->appendChild(QString("Right Tubular Reabsorption Fluid Permeability"), QString("VolumePerTimePressure"));
  auto renalUrineRate = phyRenal->appendChild(QString("Urination Rate"), QString("VolumePerTime"));
  auto renalUrineOsmoles = phyRenal->appendChild(QString("Urine Osmolality"), QString("Osmolality"));
  auto renalUrineOsmolars = phyRenal->appendChild(QString("Urine Osmolarity"), QString("Osmolarity"));
  auto renalUrineProduction = phyRenal->appendChild(QString("Urine Production Rate"), QString("VolumePerTime"));
  auto renalUrineSG = phyRenal->appendChild(QString("Urine Specific Gravity"));
  auto renalUrineVolume = phyRenal->appendChild(QString("Urine Volume"), QString("Volume"));
  auto renalUrineUrea = phyRenal->appendChild(QString("Urine Urea Nitrogen Concentration"), QString("MassPerVolume"));
  //--Respiratory sub-tree
  auto phyResp = physiologyTree->appendChild(QString("Respiratory"));
  auto respAlveolarGradient = phyResp->appendChild(QString("Alveolar Arterial Gradient"), QString("Pressure"));
  auto respCarrico = phyResp->appendChild(QString("Carrico Index"), QString("Pressure"));
  auto respEndCO2Frac = phyResp->appendChild(QString("End Tidal Carbon Dioxide Fraction"));
  auto respEndCO2Pressure = phyResp->appendChild(QString("End Tidal Carbon Dioxide Pressure"), QString("Pressure"));
  auto respExpiratory = phyResp->appendChild(QString("Expiratory Flow"), QString("VolumePerTime"));
  auto respIERatio = phyResp->appendChild(QString("Inspiratory Expiratory Ratio"));
  auto respInspiratory = phyResp->appendChild(QString("Inspiratory Flow"), QString("VolumePerTime"));
  auto respPleural = phyResp->appendChild(QString("Mean Pleural Pressure"), QString("Pressure"));
  auto respCompliance = phyResp->appendChild(QString("Pulmonary Compliance"), QString("FlowCompliance"));
  auto respResistance = phyResp->appendChild(QString("Pulmonary Resistance"), QString("FlowResistance"));
  auto respDriverFrequency = phyResp->appendChild(QString("Respiration Driver Frequency"), QString("Frequency"));
  auto respDriverPressure = phyResp->appendChild(QString("Respiration Driver Pressure"), QString("Pressure"));
  auto respMusclePressure = phyResp->appendChild(QString("Respiration Muscle Pressure"), QString("Pressure"));
  auto respRate = phyResp->appendChild(QString("Respiration Rate"), QString("Frequency"));
  auto respVent = phyResp->appendChild(QString("Specific Ventilation"));
  auto respTidal = phyResp->appendChild(QString("Tidal Volume"), QString("Volume"));
  auto respAlveolarVent = phyResp->appendChild(QString("Total Alveolar Ventilation"), QString("VolumePerTime"));
  auto respDeadVent = phyResp->appendChild(QString("Total Dead Space Ventilation"), QString("VolumePerTime"));
  auto respTotalVolume = phyResp->appendChild(QString("Total Lung Volume"), QString("Volume"));
  auto respPulmonaryVent = phyResp->appendChild(QString("Total Pulmonary Ventilation"), QString("VolumePerTime"));
  auto respTranspulmonary = phyResp->appendChild(QString("Transpulmonary Pressure"), QString("Pressure"));
  //--Tissue sub-tree
  auto phyTissue = physiologyTree->appendChild(QString("Tissue"));
  auto tisCO2 = phyTissue->appendChild(QString("Carbon Dioxide Production Rate"), QString("VolumePerTime"));
  auto tisDehydration = phyTissue->appendChild(QString("Dehydration Fraction"));
  auto tisExtracellularVolume = phyTissue->appendChild(QString("Extracellular Fluid Volume"), QString("Volume"));
  auto tisExtravascularVolume = phyTissue->appendChild(QString("Extravascular Fluid Volume"), QString("Volume"));
  auto tisIntracellularPh = phyTissue->appendChild(QString("Intracellular Fluid PH"));
  auto tisIntracellularVolume = phyTissue->appendChild(QString("Intracellular Fluid Volume"), QString("Volume"));
  auto tisGlycogen = phyTissue->appendChild(QString("Liver Glycogen"), QString("Mass"));
  auto tisMuscle = phyTissue->appendChild(QString("Muscle Glycogen"), QString("Mass"));
  auto tisO2 = phyTissue->appendChild(QString("Oxygen Consumption Rate"), QString("VolumePerTime"));
  auto tisRatio = phyTissue->appendChild(QString("Respiratory Exchange Ratio"));
  auto tisFat = phyTissue->appendChild(QString("Stored Fat"), QString("Mass"));
  auto tisProtein = phyTissue->appendChild(QString("Stored Protein"), QString("Mass"));
  auto tisTotalFluid = phyTissue->appendChild(QString("Total Body Fluid Volume"), QString("Volume"));
  //================  Substance Sub-Tree  =========================================================
  // Make common list available to all substances.  Then loop over substances, add substance to tree, and assign it list of requets
  QList<QPair<QString, QString>> subRequests = { qMakePair(QString("Alveolar Transfer"), QString("VolumePerTime")),
    qMakePair(QString("Area Under Curve"), QString("TimeMassPerVolume")),
    qMakePair(QString("Blood Concentration"), QString("MassPerVolume")),
    qMakePair(QString("End Tidal Fraction"), QString("Fraction")),
    qMakePair(QString("End Tidal Pressure"), QString("Pressure")),
    qMakePair(QString("Effect Site Concentration"), QString("MassPerVolume")),
    qMakePair(QString("Mass in Body"), QString("Mass")),
    qMakePair(QString("Mass in Blood"), QString("Mass")),
    qMakePair(QString("Mass in Tissue"), QString("Mass")),
    qMakePair(QString("Plasma Concentration"), QString("MassPerVolume")),
    qMakePair(QString("Systemic Mass Cleared"), QString("Mass")),
    qMakePair(QString("Tissue Concentration"), QString("MassPerVolume")) };

  for (auto sub : subs->GetSubstances()) {
    auto subEntry = substanceTree->appendChild(QString::fromStdString(sub->GetName()), QString(""));
    subEntry->appendChildren(subRequests);
  }
}