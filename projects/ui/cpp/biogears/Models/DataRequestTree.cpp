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
  //Initialize request string to be passed to builder and establish name of request for which we are searching
  QString request = "";
  std::string searchString = req->Substance().present() ? "SubstanceQuantity" : req->Name();  //There is no "SubstanceQuantity" name field in the DataRequest schema, so check if optional sub is present.  Otherwise, use request name
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
        if (searchString == compartmentNode->children()[j]->name().toStdString()) {
          compartmentNode->children()[j]->checked(true);
          request = dataPath(index(j, 0, compartmentIndex)) + QString("|"); //Format request using same function that stands up data requests created in scenario builder.  Append unit/precision info below
          request.append(compartmentNode->children()[j]->type() + QString("|")); //Pass the scalar type (e.g. MassPerVolume)
          break;
        }
      }
      break;
    }
  }
  if (req->Unit().present()) {
    request.append(QString::fromStdString("UNIT=" + req->Unit().get() + ";"));
  }
  if (req->Precision().present()) {
    request.append(QString::fromStdString("PRECISION=" + std::to_string(req->Precision().get())+";"));
  }
  if (req->Substance().present()) {
    request.append(QString::fromStdString("SUBSTANCE=" + req->Substance().get() + "," + req->Name() + ";"));    //Name will the substance quantity (e.g. Partial Pressure)
  }
  return request;
}
//------------------------------------------------------------------------------------
QString DataRequestTree::encode_liquid_compartment_request(CDM::LiquidCompartmentDataRequestData* req)
{
  //Initialize request string to be passed to builder and establish name of request for which we are searching
  QString request = "";
  std::string searchString = req->Substance().present() ? "SubstanceQuantity" : req->Name(); //There is no "SubstanceQuantity" name field in the DataRequest schema, so check if optional sub is present.  Otherwise, use request name
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
        if (searchString == compartmentNode->children()[j]->name().toStdString()) {
          compartmentNode->children()[j]->checked(true);
          request = dataPath(index(j, 0, compartmentIndex)) + QString("|"); //Format request using same function that stands up data requests created in scenario builder.  Append unit/precision info below
          request.append(compartmentNode->children()[j]->type() + QString("|")); //Pass the scalar type (e.g. MassPerVolume)
          break;
        }
      }
      break;
    }
  }
  if (req->Unit().present()) {
    request.append(QString::fromStdString("UNIT=" + req->Unit().get() + ";"));
  }
  if (req->Precision().present()) {
    request.append(QString::fromStdString("PRECISION=" + std::to_string(req->Precision().get())+";"));
  }
  if (req->Substance().present()) {
    request.append(QString::fromStdString("SUBSTANCE=" + req->Substance().get() + "," + req->Name() + ";")); //Name will the substance quantity (e.g. Partial Pressure)
  }
  return request;
}
//------------------------------------------------------------------------------------
QString DataRequestTree::encode_thermal_compartment_request(CDM::ThermalCompartmentDataRequestData* req)
{
  //Initialize request string to be passed to builder and establish name of request for which we are searching
  QString request = "";
  std::string searchString = req->Name();
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
        if (searchString == compartmentNode->children()[j]->name().toStdString()) {
          compartmentNode->children()[j]->checked(true);
          request = dataPath(index(j, 0, compartmentIndex)) + QString("|"); //Format request using same function that stands up data requests created in scenario builder.  Append unit/precision info below
          request.append(compartmentNode->children()[j]->type() + QString("|")); //Pass the scalar type (e.g. MassPerVolume)
          break;
        }
      }
      break;
    }
  }
  if (req->Unit().present()) {
    request.append(QString::fromStdString("UNIT=" + req->Unit().get() + ";"));
  }
  if (req->Precision().present()) {
    request.append(QString::fromStdString("PRECISION=" + std::to_string(req->Precision().get())));
  }
  return request;
}
//------------------------------------------------------------------------------------
QString DataRequestTree::encode_tissue_compartment_request(CDM::TissueCompartmentDataRequestData* req)
{
  //Initialize request string to be passed to builder and establish name of request for which we are searching
  QString request = "";
  std::string searchString = req->Name();
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
        if (searchString == compartmentNode->children()[j]->name().toStdString()) {
          compartmentNode->children()[j]->checked(true);
          request = dataPath(index(j, 0, compartmentIndex)) + QString("|");  //Format request using same function that stands up data requests created in scenario builder.  Append unit/precision info below
          request.append(compartmentNode->children()[j]->type() + QString("|")); //Pass the scalar type (e.g. MassPerVolume)
          break;
        }
      }
      break;
    }
  }
  if (req->Unit().present()) {
    request.append(QString::fromStdString("UNIT=" + req->Unit().get() + ";"));
  }
  if (req->Precision().present()) {
    request.append(QString::fromStdString("PRECISION=" + std::to_string(req->Precision().get())));
  }
  return request;
}
//------------------------------------------------------------------------------------
QString DataRequestTree::encode_environment_request(CDM::EnvironmentDataRequestData* req)
{
  //Initialize request string to be passed to builder and establish name of request for which we are searching
  QString request = "";
 
  return request;
}
//------------------------------------------------------------------------------------
QString DataRequestTree::encode_patient_request(CDM::PatientDataRequestData* req)
{
  //Initialize request string to be passed to builder and establish name of request for which we are searching
  QString request = "";
  std::string searchString = req->Name();
  //Set data in RequestModel so that when Scenario Builder is opened, the request menu will have the proper sub-menus opened and request options checked
  QModelIndex patientIndex = index(2, 0, QModelIndex()); //Patient branch is 2nd element inside top level
  DataRequestNode* patientNode = static_cast<DataRequestNode*>(patientIndex.internalPointer());
  patientNode->collapsed(false);
  for (int i = 0; i < patientNode->children().size(); ++i) {
    //Only one level of data beneath patient -- check which request we are calling
    if (searchString == patientNode->children()[i]->name().toStdString()) {
      patientNode->children()[i]->checked(true);
      request = dataPath(index(i, 0, patientIndex)) + QString("|");  //Format request using same function that stands up data requests created in scenario builder.  Append unit/precision info below
      request.append(patientNode->children()[i]->type() + QString("|"));   //Pass the scalar type (e.g. MassPerVolume)
      break;
    }
    break;
  }
  if (req->Unit().present()) {
    request.append(QString::fromStdString("UNIT=" + req->Unit().get() + ";"));
  }
  if (req->Precision().present()) {
    request.append(QString::fromStdString("PRECISION=" + std::to_string(req->Precision().get())));
  }
  return request;
}
//------------------------------------------------------------------------------------
QString DataRequestTree::encode_physiology_request(CDM::PhysiologyDataRequestData* req)
{
  //Initialize request string to be passed to builder and establish name of request for which we are searching
  QString request = "";
  std::string searchString = req->Name();
  //Set data in RequestModel so that when Scenario Builder is opened, the request menu will have the proper sub-menus opened and request options checked
  QModelIndex physiologyIndex = index(3, 0, QModelIndex()); //Physiology branch is 3rd element inside top level
  DataRequestNode* physiologyNode = static_cast<DataRequestNode*>(physiologyIndex.internalPointer());
  physiologyNode->collapsed(false);
  bool foundRequest = false;
  int section = 0;
  QModelIndex sectionIndex;
  DataRequestNode* sectionNode;
  while (!foundRequest && section < physiologyNode->children().size()) {
    //Data request model nests requests according to physiology type (Cardiovascular, Respiratory ,etc).  This structure is not present in the schema (everything is
    // under physiology).  So we need to search through each of our physiology sub-sections to find this request
    sectionIndex = index(section, 0, physiologyIndex);
    sectionNode = static_cast<DataRequestNode*>(sectionIndex.internalPointer()); //Physioloy sub-type (Cardiovascular, Respiratory, ...)
    for (int i = 0; i < sectionNode->children().size(); ++i) {
      //Search children within section (e.g. Cardiovacular->Heart Rate, Blood Pressure, ...)
      if (searchString == sectionNode->children()[i]->name().toStdString()) {
        sectionNode->collapsed(false); //Show physiology type in open view
        sectionNode->children()[i]->checked(true); //Request check box will be checked
        foundRequest = true; //Stop searching
        request = dataPath(index(i, 0, sectionIndex)) + QString("|");    //Format request using same function that stands up data requests created in scenario builder.  Append unit/precision info below
        request.append(sectionNode->children()[i]->type() + QString("|")); //Pass the scalar type (e.g. MassPerVolume)
        break;
      }
    }
    ++section;
  }
  if (req->Unit().present()) {
    request.append(QString::fromStdString("UNIT=" + req->Unit().get() + ";"));
  }
  if (req->Precision().present()) {
    request.append(QString::fromStdString("PRECISION=" + std::to_string(req->Precision().get())));
  }
  return request;
}
//------------------------------------------------------------------------------------
QString DataRequestTree::encode_substance_request(CDM::SubstanceDataRequestData* req)
{
  //Initialize request string to be passed to builder and establish name of request for which we are searching
  QString request = "";
  std::string searchString = req->Name();
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
        if (searchString == substanceNode->children()[j]->name().toStdString()) {
          substanceNode->children()[j]->checked(true);
          request = dataPath(index(j, 0, substanceIndex)) + QString("|"); //Format request using same function that stands up data requests created in scenario builder.  Append unit/precision info below
          request.append(substanceNode->children()[j]->type() + QString("|")); //Pass the scalar type (e.g. MassPerVolume)
          break;
        }
      }
      break;
    }
  }
  if (req->Unit().present()) {
    request.append(QString::fromStdString("UNIT=" + req->Unit().get() + ";"));
  }
  if (req->Precision().present()) {
    request.append(QString::fromStdString("PRECISION=" + std::to_string(req->Precision().get())));
  }
  return request;
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
    qMakePair(QString("SubstanceQuantity"), QString("")) };

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
    qMakePair(QString("SubstanceQuantity"), QString("")),
    qMakePair(QString("WaterVolumeFraction"), QString("")) };
  for (auto liquid : comps->GetLiquidCompartments()) {
    auto liquidNode = cLiquidTree->appendChild(QString::fromStdString(liquid->GetName()));
    auto propNode = liquidNode->appendChildren(cLiquidRequests);
  }
  //--Thermal subtree-- loop over thermal compartment names, add a node for each one and then nest available suboptions beneath them
  QList<QPair<QString, QString>> cThermalRequests = { qMakePair(QString("HeatTransferRateIn"), QString("Power")),
    qMakePair(QString("HeatTransferRateOut"), QString("Power")),
    qMakePair(QString("Temperature"), QString("Temperature")),
    qMakePair(QString("Heat"), QString("Energy")) };
  for (auto thermal : comps->GetThermalCompartments()) {
    auto thermalNode = cThermalTree->appendChild(QString::fromStdString(thermal->GetName()));
    auto propNode = thermalNode->appendChildren(cThermalRequests);
  }
  //--Tissue subtree-- loop over tissue compartment names, add a node for each one and then nest available suboptions beneath them
  QList<QPair<QString, QString>> cTissueRequests = {
    qMakePair(QString("AcidicPhospholipidConcentration"), QString("MassPerMass")),
    qMakePair(QString("MatrixVolume"), QString("Volume")),
    qMakePair(QString("MembranePotential"), QString("ElectricPotential")),
    qMakePair(QString("NeutralLipidsVolumeFraction"), QString("")),
    qMakePair(QString("NeutralPhospholipidsVolumeFraction"), QString("")),
    qMakePair(QString("ReflectionCoefficient"), QString("")),
    qMakePair(QString("TissueToPlasmaAlbuminRatio"), QString("")),
    qMakePair(QString("TissueToPlasmaAlpha-AcidGlycoproteinRatio"), QString("")),
    qMakePair(QString("TissueToPlasmaLipoproteinRatio"), QString("")),
    qMakePair(QString("Total Mass"), QString("Mass")),
  };
  for (auto tissue : comps->GetTissueCompartments()) {
    auto tissueNode = cTissueTree->appendChild(QString::fromStdString(tissue->GetName()));
    auto propNode = tissueNode->appendChildren(cTissueRequests);
  }
  //================  Environment Sub-Tree  =====================================================

  //================  Patient Sub-Tree  =========================================================
  auto pAge = patientTree->appendChild(QString("Age"), QString("Time"));
  auto pAlveoliSA = patientTree->appendChild(QString("AlveoliSurfaceArea"), QString("Area"));
  auto pBMR = patientTree->appendChild(QString("BasalMetabolicRate"), QString("Power"));
  auto pBloodVolumeBase = patientTree->appendChild(QString("BloodVolumeBaseline"), QString("Volume"));
  auto pBodyDensity = patientTree->appendChild(QString("BodyDensity"), QString("MassPerVolume"));
  auto pBodyFatFraction = patientTree->appendChild(QString("BodyFatFraction"));
  auto pDiastolicBase = patientTree->appendChild(QString("DiastolicArterialPressureBaseline"), QString("Pressure"));
  auto pExpiratoryReserve = patientTree->appendChild(QString("ExpiratoryReserveVolume"), QString("Volume"));
  auto pFunctionalCapacity = patientTree->appendChild(QString("FunctionalResidualCapacity"), QString("Volume"));
  auto pHeartRateBase = patientTree->appendChild(QString("HeartRateBaseline"), QString("Frequency"));
  auto pHeartRateMax = patientTree->appendChild(QString("HeartRateMaximum"), QString("Frequency"));
  auto pHeartRateMin = patientTree->appendChild(QString("HeartRateMinimum"), QString("Frequency"));
  auto pInspiratoryCapacity = patientTree->appendChild(QString("InspiratoryCapacity"), QString("Volume"));
  auto pInspiratoryReserve = patientTree->appendChild(QString("InspitatoryReserveVolume"), QString("Volume"));
  auto pLeanBodyMass = patientTree->appendChild(QString("LeanBodyMass"), QString("Mass"));
  auto pMaxWorkRate = patientTree->appendChild(QString("MaximumWorkRate"), QString("Power"));
  auto pMeanPressureBase = patientTree->appendChild(QString("MeanArterialPressureBaseline"), QString("Pressure"));
  auto pMuscleMass = patientTree->appendChild(QString("MuscleMass"), QString("Mass"));
  auto pPain = patientTree->appendChild(QString("PainSusceptibility"));
  auto pResidual = patientTree->appendChild(QString("ResidualVolume"), QString("Volume"));
  auto pRespiratoryBase = patientTree->appendChild(QString("RespirationRateBaseline"), QString("Frequency"));
  auto pRightLungRatio = patientTree->appendChild(QString("RightLungRatio"), QString(""));
  auto pSkinSA = patientTree->appendChild(QString("SkinSurface rea"), QString("Area"));
  auto pSystolicBase = patientTree->appendChild(QString("SystolicArterialPressureBaseline"), QString("Pressure"));
  auto pTidalBase = patientTree->appendChild(QString("TidalVolumeBaseline"), QString("Volume"));
  auto pTotalCapacity = patientTree->appendChild(QString("TotalLungCapacity"), QString("Volume"));
  auto pVentilationBase = patientTree->appendChild(QString("TotalVentilationBaseline"), QString("Volume"));
  auto pVital = patientTree->appendChild(QString("VitalCapacity"), QString("Volume"));

  //================  Physiology Sub-Tree  =========================================================
  //--Blood Chemistry Sub-tree
  auto phyBloodChemistry = physiologyTree->appendChild(QString("BloodChemistry"));
  auto bcArterialPH = phyBloodChemistry->appendChild(QString("ArterialBloodPH"));
  auto bcArterialCO2 = phyBloodChemistry->appendChild(QString("ArterialCarbonDioxidePressure"), QString("Pressure"));
  auto bcArterialO2 = phyBloodChemistry->appendChild(QString("ArterialOxygenPressure"), QString("Pressure"));
  auto bcBloodDensity = phyBloodChemistry->appendChild(QString("BloodDensity"), QString("MassPerVolume"));
  auto bcBloodHeat = phyBloodChemistry->appendChild(QString("BloodSpecificHeat"), QString("HeatCapacitancePerMass"));
  auto bcBloodUrea = phyBloodChemistry->appendChild(QString("BloodUreaNitrogenConcentration"), QString("MassPerVolume"));
  auto bcCO2Sat = phyBloodChemistry->appendChild(QString("CarbonDioxideSaturation"));
  auto bcCOSat = phyBloodChemistry->appendChild(QString("CarbonMonoxideSaturation"));
  auto bcHematocrit = phyBloodChemistry->appendChild(QString("Hematocrit"));
  auto bcHemoglobin = phyBloodChemistry->appendChild(QString("HemoglobinContent"), QString("Mass"));
  auto bcHemoglobinLost = phyBloodChemistry->appendChild(QString("HemoglobinLostToUrine"), QString("Mass"));
  auto bcInflammation = phyBloodChemistry->appendChild(QString("InflammatoryResponse"));
  //--Inflammation options
  auto inAutonomic = bcInflammation->appendChild(QString("AutonomicResponseLevel"));
  auto inBloodPathogen = bcInflammation->appendChild(QString("BloodPathogen"));
  auto inBloodCatecholamines = bcInflammation->appendChild(QString("Catecholamines"));
  auto inBloodcNOS = bcInflammation->appendChild(QString("ConstitutiveNOS"));
  auto inBloodNOS = bcInflammation->appendChild(QString("InducibleNOS"));
  auto inBloodPreNOS = bcInflammation->appendChild(QString("InducibleNOSPre"));
  auto inTime = bcInflammation->appendChild(QString("InflammationTime"));
  auto inBloodIL6 = bcInflammation->appendChild(QString("Interleukin6"));
  auto inBloodIL10 = bcInflammation->appendChild(QString("Interleukin10"));
  auto inBloodIL12 = bcInflammation->appendChild(QString("Interleukin12"));
  auto inLocalBarrier = bcInflammation->appendChild(QString("LocalBarrier"));
  auto inLocalMacropage = bcInflammation->appendChild(QString("LocalMacrophage"));
  auto inLocalNeutrophil = bcInflammation->appendChild(QString("LocalNeutrophil"));
  auto inLocalPathogen = bcInflammation->appendChild(QString("LocalPathogen"));
  auto inBloodActiveMacropage = bcInflammation->appendChild(QString("MacrophageActive"));
  auto inBloodRestingMacropage = bcInflammation->appendChild(QString("MacrophageResting"));
  auto inBloodActiveNeutrophil = bcInflammation->appendChild(QString("NeutrophilActive"));
  auto inBloodRestingNeutrophil = bcInflammation->appendChild(QString("NeutrophilResting"));
  auto inBloodNO3 = bcInflammation->appendChild(QString("Nitrate"));
  auto inBloodNO = bcInflammation->appendChild(QString("NitricOxide"));
  auto inTissueIntegrity = bcInflammation->appendChild(QString("TissueIntegrity"));
  auto inBloodTNF = bcInflammation->appendChild(QString("TumorNecrosisFactor"));
  //Resume blood chemistry sub-tree
  auto bcO2Sat = phyBloodChemistry->appendChild(QString("OxygenSaturation"));
  auto bcO2SatVen = phyBloodChemistry->appendChild(QString("OxygenVenousSaturation"));
  auto bcPhosphate = phyBloodChemistry->appendChild(QString("PhosphateConcentration"), QString("AmountPerVolume"));
  auto bcPlasma = phyBloodChemistry->appendChild(QString("PlasmaVolume"), QString("Volume"));
  auto bcPulmArterialCO2 = phyBloodChemistry->appendChild(QString("PulmonaryArterialCarbonDioxidePressure"), QString("Pressure"));
  auto bcPulmArterialO2 = phyBloodChemistry->appendChild(QString("PulmonaryArterialOxygenPressure"), QString("Pressure"));
  auto bcPulmVenousCO2 = phyBloodChemistry->appendChild(QString("PulmonaryVenousCarbonDioxidePressure"), QString("Pressure"));
  auto bcPulmVenousO2 = phyBloodChemistry->appendChild(QString("PulmonaryVenousOxygenPressure"), QString("Pressure"));
  auto bcPulseOx = phyBloodChemistry->appendChild(QString("PulseOximetry"), QString(""));
  auto bcRBCach = phyBloodChemistry->appendChild(QString("RedBloodCellAcetylcholinesterase"), QString("AmountPerVolume"));
  auto bcRBC = phyBloodChemistry->appendChild(QString("RedBloodCellCount"), QString("AmountPerVolume"));
  auto bcShunt = phyBloodChemistry->appendChild(QString("ShuntFraction"));
  auto bcSID = phyBloodChemistry->appendChild(QString("StrongIonDifference"), QString("AmountPerVolume"));
  auto bcBilirubin = phyBloodChemistry->appendChild(QString("TotalBilirubin"), QString("MassPerVolume"));
  auto bcTotalProtein = phyBloodChemistry->appendChild(QString("TotalProteinConcentration"), QString("MassPerVolume"));
  auto bcVenousCO2 = phyBloodChemistry->appendChild(QString("VenousCarbonDioxidePressure"), QString("Pressure"));
  auto bcVenousO2 = phyBloodChemistry->appendChild(QString("VenousOxygenPressure"), QString("Pressure"));
  auto bcLipid = phyBloodChemistry->appendChild(QString("VolumeFractionNeutralLipidsinPlasma"));
  auto bcPhospholipid = phyBloodChemistry->appendChild(QString("VolumeFractionNeutralPhospholipidsinPlasma"));
  auto bcWBC = phyBloodChemistry->appendChild(QString("WhiteBloodCellCount"), QString("AmountPerVolume"));
  //Cardiovascular sub-tree
  auto phyCardio = physiologyTree->appendChild(QString("Cardiovascular"));
  auto cvArterial = phyCardio->appendChild(QString("ArterialPressure"), QString("Pressure"));
  auto cvBloodVolume = phyCardio->appendChild(QString("BloodVolume"), QString("Volume"));
  auto cvCardiacOutput = phyCardio->appendChild(QString("CardiacOutput"), QString("VolumePerTime"));
  auto cvCVP = phyCardio->appendChild(QString("CentralVenousPressure"), QString("Pressure"));
  auto cvCBF = phyCardio->appendChild(QString("CerebralBloodFlow"), QString("VolumePerTime"));
  auto cvPerfusion = phyCardio->appendChild(QString("CerebralPerfusionPressure"), QString("Pressure"));
  auto cvDiastolic = phyCardio->appendChild(QString("DiastolicArterialPressure"), QString("Pressure"));
  auto cvEjectionFraction = phyCardio->appendChild(QString("HeartEjectionFraction"));
  auto cvHeartRate = phyCardio->appendChild(QString("HeartRate"), QString("Frequency"));
  auto cvHeartVolume = phyCardio->appendChild(QString("HeartStrokeVolume"), QString("Volume"));
  auto cvICP = phyCardio->appendChild(QString("IntracranialPressure"), QString("Pressure"));
  auto cvMAP = phyCardio->appendChild(QString("MeanArterialPressure"), QString("Pressure"));
  auto cvMeanCVP = phyCardio->appendChild(QString("MeanCentralVenousPressure"), QString("Pressure"));
  auto cvSkinFlow = phyCardio->appendChild(QString("MeanSkinBloodFlow"), QString("VolumePerTime"));
  auto cvPulmPressure = phyCardio->appendChild(QString("PulmonaryArterialPressure"), QString("Pressure"));
  auto cvPulmWedge = phyCardio->appendChild(QString("PulmonaryCapillariesWedgePressure"), QString("Pressure"));
  auto cvPulmDiastolic = phyCardio->appendChild(QString("PulmonaryDiastolicArterialPressure"), QString("Pressure"));
  auto cvPulmMAP = phyCardio->appendChild(QString("PulmonaryMeanArterialPressure"), QString("Pressure"));
  auto cvPulmCapFlow = phyCardio->appendChild(QString("PulmonaryMeanCapillaryFlow"), QString("VolumePerTime"));
  auto cvPulmShuntFlow = phyCardio->appendChild(QString("PulmonaryMeanShuntFlow"), QString("VolumePerTime"));
  auto cvPulmSystolic = phyCardio->appendChild(QString("PulmonarySystolicArterialPressure"), QString("Pressure"));
  auto cvPulmResistance = phyCardio->appendChild(QString("PulmonaryVascularResistance"), QString("FlowResistance"));
  auto cvPulmResistanceIndex = phyCardio->appendChild(QString("PulmonaryVascularResistanceIndex"), QString("PressureTimePerVolumeArea"));
  auto cvPulsePressure = phyCardio->appendChild(QString("PulsePressure"), QString("Pressure"));
  auto cvSVR = phyCardio->appendChild(QString("SystemicVascularResistance"), QString("FlowResistance"));
  auto cvSAP = phyCardio->appendChild(QString("SystolicArterialPressure"), QString("Pressure"));
  //--Drug sub-tree
  auto phyDrug = physiologyTree->appendChild(QString("Drugs"));
  auto drugAntibiotic = phyDrug->appendChild(QString("AntibioticActivity"));
  auto drugBronchodilation = phyDrug->appendChild(QString("BronchodilationLevel"));
  auto drugCNS = phyDrug->appendChild(QString("CentralNervousResponse"));
  auto drugFever = phyDrug->appendChild(QString("FeverChange"), QString("Temperature"));
  auto drugHeartRate = phyDrug->appendChild(QString("HeartRateChange"), QString("Frequency"));
  auto drugHemorrhage = phyDrug->appendChild(QString("HemorrhageReduction"));
  auto drugMAP = phyDrug->appendChild(QString("MeanBloodPressureChange"), QString("Pressure"));
  auto drugNeuro = phyDrug->appendChild(QString("NeurmuscularBlockLevel"));
  auto drugPain = phyDrug->appendChild(QString("PainToleranceChange"));
  auto drugPulse = phyDrug->appendChild(QString("PulsePressureChange"), QString("Pressure"));
  auto drugRespiration = phyDrug->appendChild(QString("RespirationRateChange"), QString("Frequency"));
  auto drugSedation = phyDrug->appendChild(QString("SedationLevel"));
  auto drugTidalVolume = phyDrug->appendChild(QString("TidalVolumeChange"), QString("Volume"));
  auto drugTubular = phyDrug->appendChild(QString("TubularPermeabilityChange"));
  //--Energy sub-tree
  auto phyEnergy = physiologyTree->appendChild(QString("Energy"));
  auto energyAchieved = phyEnergy->appendChild(QString("AchievedExerciseLevel"));
  auto energyChloride = phyEnergy->appendChild(QString("ChlorideLosttoSweat"), QString("Mass"));
  auto energyCore = phyEnergy->appendChild(QString("CoreTemperature"), QString("Temperature"));
  auto energyCreatinine = phyEnergy->appendChild(QString("CreatinineProductionRate"), QString("AmountPerTime"));
  auto energyDeficit = phyEnergy->appendChild(QString("EnergyDeficit"), QString("Power"));
  auto energyDemand = phyEnergy->appendChild(QString("ExerciseEnergyDemand"), QString("Power"));
  auto energyMapDelta = phyEnergy->appendChild(QString("ExerciseMeanArterialPressureDelta"), QString("Pressure"));
  auto energyFatigue = phyEnergy->appendChild(QString("FatigueLevel"));
  auto energyLactate = phyEnergy->appendChild(QString("LactateProductionRate"), QString("AmountPerTime"));
  auto energyPotassium = phyEnergy->appendChild(QString("PotassiumLosttoSweat"), QString("Mass"));
  auto energySkin = phyEnergy->appendChild(QString("SkinTemperature"), QString("Temperature"));
  auto energySodium = phyEnergy->appendChild(QString("SodiumLosttoSweat"), QString("Mass"));
  auto energyMetabolic = phyEnergy->appendChild(QString("TotalMetabolicRate"), QString("Power"));
  auto energyWorkRate = phyEnergy->appendChild(QString("TotalWorkFractionofMax"));
  //--Endocrine sub-tree
  auto phyEndo = physiologyTree->appendChild(QString("Endocrine"));
  auto endoGlucagon = phyEndo->appendChild(QString("GlucagonSynthesisRate"), QString("AmountPerTime"));
  auto endoInsulin = phyEndo->appendChild(QString("InsulinSynthesisRate"), QString("AmountPerTime"));
  //--Gastrointestinal sub-tree
  auto phyGI = physiologyTree->appendChild(QString("Gastrointestinal"));
  auto giChyme = phyGI->appendChild(QString("ChymeAbsorptionRate"), QString("VolumePerTime"));
  //--Stomachcontents sub-tree
  auto giStomach = phyGI->appendChild(QString("StomachContents"));
  auto calcium = giStomach->appendChild(QString("Calcium"), QString("Mass"));
  auto carbs = giStomach->appendChild(QString("Carbohydrate"), QString("Mass"));
  auto fat = giStomach->appendChild(QString("Fat"), QString("Mass"));
  auto protein = giStomach->appendChild(QString("Protein"), QString("Mass"));
  auto sodium = giStomach->appendChild(QString("Sodium"), QString("Mass"));
  auto water = giStomach->appendChild(QString("Water"), QString("Volume"));
  //--Hepatic sub-tree
  auto phyHep = physiologyTree->appendChild(QString("Hepatic"));
  auto hepGluc = phyHep->appendChild(QString("HepaticGluconeogenisisRate"), QString("MassPerTime"));
  auto hepKetones = phyHep->appendChild(QString("KetoneProductionRate"), QString("AmountPerTime"));
  //--Nervous sub-tree
  auto phyNervous = physiologyTree->appendChild(QString("Nervous"));
  auto nervousLapses = phyNervous->appendChild(QString("AttentionLapses"));
  auto nervousDebt = phyNervous->appendChild(QString("BiologicalDebt"));
  auto nervousCompliance = phyNervous->appendChild(QString("ComplianceScale"));
  auto nervousHeartElastance = phyNervous->appendChild(QString("HeartElastanceScale"));
  auto nervousHeartRate = phyNervous->appendChild(QString("HeartRateScale"));
  auto nervousLeftEye = phyNervous->appendChild(QString("LeftEyePupillaryResponse"));
  auto nervousPain = phyNervous->appendChild(QString("PainVisualAnalogueScale"));
  auto nervousrReactionTime = phyNervous->appendChild(QString("ReactionTime"), QString("Time"));
  auto nervousExtrasplanchnicRes = phyNervous->appendChild(QString("ResistanceScaleExtrasplanchnic"));
  auto nervousMuscleRes = phyNervous->appendChild(QString("ResistanceScaleMuscle"));
  auto nervousMyocardiumRes = phyNervous->appendChild(QString("ResistanceScaleMyocardium"));
  auto nervousSplanchnicRes = phyNervous->appendChild(QString("ResistanceScaleSplanchnic"));
  auto nervousRAS = phyNervous->appendChild(QString("RichmondAgitationSedationScale"));
  auto nervousRightEye = phyNervous->appendChild(QString("RightEyePupillaryResponse"));
  auto nervousSleepTime = phyNervous->appendChild(QString("SleepTime"), QString("Time"));
  auto nervousWakeTime = phyNervous->appendChild(QString("WakeTime"), QString("Time"));
  //--Renal sub-tree
  auto phyRenal = physiologyTree->appendChild(QString("Renal"));
  auto renalFiltration = phyRenal->appendChild(QString("FiltrationFraction"));
  auto renalGFR = phyRenal->appendChild(QString("GlomerularFiltrationRate"), QString("VolumePerTime"));
  auto renalLeftAfferentRes = phyRenal->appendChild(QString("LeftAfferentArterioleResistance"), QString("FlowResistance"));
  auto renalLeftBowmansHydro = phyRenal->appendChild(QString("LeftBowmansCapsuleHydrostaticPressure"), QString("Pressure"));
  auto renalLeftBowmansOsmotic = phyRenal->appendChild(QString("LeftBowmansCapsuleOsmoticPressure"), QString("Pressure"));
  auto renalLeftGlomHydro = phyRenal->appendChild(QString("LeftGlomerularCapillariesHydrostaticPressure"), QString("Pressure"));
  auto renalLeftGlomOsmotic = phyRenal->appendChild(QString("LeftGlomerularCapillariesOsmoticPressure"), QString("Pressure"));
  auto renalLeftGlomCoef = phyRenal->appendChild(QString("LeftGlomerularFiltrationCoefficient"), QString("VolumePerTimePressure"));
  auto renalLeftGlomRate = phyRenal->appendChild(QString("LeftGlomerularFiltrationRate"), QString("VolumePerTime"));
  auto renalLeftGlomSA = phyRenal->appendChild(QString("LeftGlomerularFiltrationSurfaceArea"), QString("Area"));
  auto renalLeftGlomPerm = phyRenal->appendChild(QString("LeftGlomerularFluidPermeability"), QString("VolumePerTimePressure"));
  auto renalLeftFraction = phyRenal->appendChild(QString("LeftFiltrationFraction"));
  auto renalLeftNetFraction = phyRenal->appendChild(QString("LeftNetFiltrationFraction"));
  auto renalLeftNetReabsorption = phyRenal->appendChild(QString("LeftNetReabsorptionPressure"), QString("Pressue"));
  auto renalLeftPeriHydro = phyRenal->appendChild(QString("LeftPeritubularCapillariesHydrostaticPressure"), QString("Pressure"));
  auto renalLeftPeriOsmotic = phyRenal->appendChild(QString("LeftPeritubularCapillariesOsmoticPressure"), QString("Pressure"));
  auto renalLeftReabsCoef = phyRenal->appendChild(QString("LeftReabsorptionFiltrationCoefficient"), QString("VolumePerTimePressure"));
  auto renalLeftReabsRate = phyRenal->appendChild(QString("LeftReabsorptionRate"), QString("VolumePerTime"));
  auto renalLeftTubularHydro = phyRenal->appendChild(QString("LeftTubularHydrostaticPressure"), QString("Pressure"));
  auto renalLeftTubularOsmotic = phyRenal->appendChild(QString("LeftTubularOsmoticPressure"), QString("Pressure"));
  auto renalLeftTubularSA = phyRenal->appendChild(QString("LeftTubularReabsorptionFiltrationSurfaceArea"), QString("Area"));
  auto renalLeftTubularPerm = phyRenal->appendChild(QString("LeftTubularReabsorptionFluidPermeability"), QString("VolumePerTimePressure"));
  auto renalMeanUrineOutput = phyRenal->appendChild(QString("MeaneUrineOutput"), QString("VolumePerTime"));
  auto renalBloodFlow = phyRenal->appendChild(QString("RenalBloodFlow"), QString("VolumePerTime"));
  auto renalPlasmaFlow = phyRenal->appendChild(QString("RenalPlasmaFlow"), QString("VolumePerTime"));
  auto renalResistance = phyRenal->appendChild(QString("RenalVascularResistance"), QString("FlowResistance"));
  auto renalRightAfferentRes = phyRenal->appendChild(QString("RightAfferentArterioleResistance"), QString("FlowResistance"));
  auto renalRightBowmansHydro = phyRenal->appendChild(QString("RightBowmansCapsuleHydrostaticPressure"), QString("Pressure"));
  auto renalRightBowmansOsmotic = phyRenal->appendChild(QString("RightBowmansCapsuleOsmoticPressure"), QString("Pressure"));
  auto renalRightGlomHydro = phyRenal->appendChild(QString("RightGlomerularCapillariesHydrostaticPressure"), QString("Pressure"));
  auto renalRightGlomOsmotic = phyRenal->appendChild(QString("RightGlomerularCapillariesOsmoticPressure"), QString("Pressure"));
  auto renalRightGlomCoef = phyRenal->appendChild(QString("RightGlomerularFiltrationCoefficient"), QString("VolumePerTimePressure"));
  auto renalRightGlomRate = phyRenal->appendChild(QString("RightGlomerularFiltrationRate"), QString("VolumePerTime"));
  auto renalRightGlomSA = phyRenal->appendChild(QString("RightGlomerularFiltrationSurfaceArea"), QString("Area"));
  auto renalRightGlomPerm = phyRenal->appendChild(QString("RightGlomerularFluidPermeability"), QString("VolumePerTimePressure"));
  auto renalRightFraction = phyRenal->appendChild(QString("RightFiltrationFraction"));
  auto renalRightNetFraction = phyRenal->appendChild(QString("RightNetFiltrationFraction"));
  auto renalRightNetReabsorption = phyRenal->appendChild(QString("RightNetReabsorptionPressure"), QString("Pressue"));
  auto renalRightPeriHydro = phyRenal->appendChild(QString("RightPeritubularCapillariesHydrostaticPressure"), QString("Pressure"));
  auto renalRightPeriOsmotic = phyRenal->appendChild(QString("RightPeritubularCapillariesOsmoticPressure"), QString("Pressure"));
  auto renalRightReabsCoef = phyRenal->appendChild(QString("RightReabsorptionFiltrationCoefficient"), QString("VolumePerTimePressure"));
  auto renalRightReabsRate = phyRenal->appendChild(QString("RightReabsorptionRate"), QString("VolumePerTime"));
  auto renalRightTubularHydro = phyRenal->appendChild(QString("RightTubularHydrostaticPressure"), QString("Pressure"));
  auto renalRightTubularOsmotic = phyRenal->appendChild(QString("RightTubularOsmoticPressure"), QString("Pressure"));
  auto renalRightTubularSA = phyRenal->appendChild(QString("RightTubularReabsorptionFiltrationSurfaceArea"), QString("Area"));
  auto renalRightTubularPerm = phyRenal->appendChild(QString("RightTubularReabsorptionFluidPermeability"), QString("VolumePerTimePressure"));
  auto renalUrineRate = phyRenal->appendChild(QString("UrinationRate"), QString("VolumePerTime"));
  auto renalUrineOsmoles = phyRenal->appendChild(QString("UrineOsmolality"), QString("Osmolality"));
  auto renalUrineOsmolars = phyRenal->appendChild(QString("UrineOsmolarity"), QString("Osmolarity"));
  auto renalUrineProduction = phyRenal->appendChild(QString("UrineProductionRate"), QString("VolumePerTime"));
  auto renalUrineSG = phyRenal->appendChild(QString("UrineSpecificGravity"));
  auto renalUrineVolume = phyRenal->appendChild(QString("UrineVolume"), QString("Volume"));
  auto renalUrineUrea = phyRenal->appendChild(QString("UrineUreaNitrogenConcentration"), QString("MassPerVolume"));
  //--Respiratory sub-tree
  auto phyResp = physiologyTree->appendChild(QString("Respiratory"));
  auto respAlveolarGradient = phyResp->appendChild(QString("AlveolarArterialGradient"), QString("Pressure"));
  auto respCarrico = phyResp->appendChild(QString("CarricoIndex"), QString("Pressure"));
  auto respEndCO2Frac = phyResp->appendChild(QString("EndTidalCarbonDioxideFraction"));
  auto respEndCO2Pressure = phyResp->appendChild(QString("EndTidalCarbonDioxidePressure"), QString("Pressure"));
  auto respExpiratory = phyResp->appendChild(QString("ExpiratoryFlow"), QString("VolumePerTime"));
  auto respIERatio = phyResp->appendChild(QString("InspiratoryExpiratoryRatio"));
  auto respInspiratory = phyResp->appendChild(QString("InspiratoryFlow"), QString("VolumePerTime"));
  auto respPleural = phyResp->appendChild(QString("MeanPleuralPressure"), QString("Pressure"));
  auto respCompliance = phyResp->appendChild(QString("PulmonaryCompliance"), QString("FlowCompliance"));
  auto respResistance = phyResp->appendChild(QString("PulmonaryResistance"), QString("FlowResistance"));
  auto respDriverFrequency = phyResp->appendChild(QString("RespirationDriverFrequency"), QString("Frequency"));
  auto respDriverPressure = phyResp->appendChild(QString("RespirationDriverPressure"), QString("Pressure"));
  auto respMusclePressure = phyResp->appendChild(QString("RespirationMusclePressure"), QString("Pressure"));
  auto respRate = phyResp->appendChild(QString("RespirationRate"), QString("Frequency"));
  auto respVent = phyResp->appendChild(QString("SpecificVentilation"));
  auto respTidal = phyResp->appendChild(QString("TidalVolume"), QString("Volume"));
  auto respAlveolarVent = phyResp->appendChild(QString("TotalAlveolarVentilation"), QString("VolumePerTime"));
  auto respDeadVent = phyResp->appendChild(QString("TotalDeadSpaceVentilation"), QString("VolumePerTime"));
  auto respTotalVolume = phyResp->appendChild(QString("TotalLungVolume"), QString("Volume"));
  auto respPulmonaryVent = phyResp->appendChild(QString("TotalPulmonaryVentilation"), QString("VolumePerTime"));
  auto respTranspulmonary = phyResp->appendChild(QString("TranspulmonaryPressure"), QString("Pressure"));
  //--Tissue sub-tree
  auto phyTissue = physiologyTree->appendChild(QString("Tissue"));
  auto tisCO2 = phyTissue->appendChild(QString("CarbonDioxideProductionRate"), QString("VolumePerTime"));
  auto tisDehydration = phyTissue->appendChild(QString("DehydrationFraction"));
  auto tisExtracellularVolume = phyTissue->appendChild(QString("ExtracellularFluidVolume"), QString("Volume"));
  auto tisExtravascularVolume = phyTissue->appendChild(QString("ExtravascularFluidVolume"), QString("Volume"));
  auto tisIntracellularPh = phyTissue->appendChild(QString("IntracellularFluidPH"));
  auto tisIntracellularVolume = phyTissue->appendChild(QString("IntracellularFluidVolume"), QString("Volume"));
  auto tisGlycogen = phyTissue->appendChild(QString("LiverGlycogen"), QString("Mass"));
  auto tisMuscle = phyTissue->appendChild(QString("MuscleGlycogen"), QString("Mass"));
  auto tisO2 = phyTissue->appendChild(QString("OxygenConsumptionRate"), QString("VolumePerTime"));
  auto tisRatio = phyTissue->appendChild(QString("RespiratoryExchangeRatio"));
  auto tisFat = phyTissue->appendChild(QString("StoredFat"), QString("Mass"));
  auto tisProtein = phyTissue->appendChild(QString("StoredProtein"), QString("Mass"));
  auto tisTotalFluid = phyTissue->appendChild(QString("TotalBodyFluidVolume"), QString("Volume"));
  //==================================SubstanceSub-Tree==================================================================================
  //Make common list of requests available to all substances. Then loop over substances, add substance to tree, and assign it to list of requests
  QList<QPair<QString, QString>> subRequests = { qMakePair(QString("AlveolarTransfer"), QString("VolumePerTime")),
    qMakePair(QString("AreaUnderCurve"), QString("TimeMassPerVolume")),
    qMakePair(QString("BloodConcentration"), QString("MassPerVolume")),
    qMakePair(QString("EndTidalFraction"), QString("Fraction")),
    qMakePair(QString("EndTidalPressure"), QString("Pressure")),
    qMakePair(QString("EffectSiteConcentration"), QString("MassPerVolume")),
    qMakePair(QString("MassInBody"), QString("Mass")),
    qMakePair(QString("MassInBlood"), QString("Mass")),
    qMakePair(QString("MassInTissue"), QString("Mass")),
    qMakePair(QString("PlasmaConcentration"), QString("MassPerVolume")),
    qMakePair(QString("SystemicMassCleared"), QString("Mass")),
    qMakePair(QString("TissueConcentration"), QString("MassPerVolume")) };

  for (auto sub : subs->GetSubstances()) {
    auto subEntry = substanceTree->appendChild(QString::fromStdString(sub->GetName()), QString(""));
    subEntry->appendChildren(subRequests);
  }
}