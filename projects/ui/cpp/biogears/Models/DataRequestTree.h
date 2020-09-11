#pragma once

#include <memory>

#include <QAbstractItemModel>
#include <QObject>
#include <QString>
#include <QVariant>

#include "DataRequestNode.h"
#include "biogears/cdm/substance/SESubstanceManager.h"
#include "biogears/cdm/compartment/SECompartmentManager.h"
#include "biogears/cdm/scenario/requests/SEDataRequestManager.h"
#include <biogears/cdm/scenario/requests/SEPhysiologyDataRequest.h>

class DataRequestTree : public QAbstractItemModel {
  Q_OBJECT

public:
  enum DataRequestRoles {
    CollapsedRole = Qt::UserRole + 1,
    TypeRole
  };
  Q_ENUMS(DataRequestRoles)

  explicit DataRequestTree(QObject* parent = nullptr);
  ~DataRequestTree() override;

  Q_INVOKABLE QVariant data(const QModelIndex& index, int role) const override;
  Q_INVOKABLE QString dataPath(const QModelIndex& index);
  Q_INVOKABLE void resetData();
  bool setData(const QModelIndex& index, const QVariant& value, int role = Qt::EditRole);
  Qt::ItemFlags flags(const QModelIndex& index) const override;
  QModelIndex parent(const QModelIndex& index) const override;
  int rowCount(const QModelIndex& parent = QModelIndex()) const override;
  int columnCount(const QModelIndex& parent = QModelIndex()) const override;
  QModelIndex index(int row, int column, const QModelIndex& parent = QModelIndex()) const override;
  DataRequestNode* appendChild(QString name, QString type = "");
  DataRequestNode* appendChildren(QList<QPair<QString, QString>> nameUnitPairs);
  CDM::DataRequestData* decode_request(QString request);
  void initialize(biogears::SECompartmentManager* comps, biogears::SESubstanceManager* subs);

  QHash<int, QByteArray> roleNames() const
  {
    QHash<int, QByteArray> roles;
    roles[Qt::DisplayRole] = "name";
    roles[Qt::CheckStateRole] = "checked";
    roles[CollapsedRole] = "collapsed";
    roles[TypeRole] = "type";
    return roles;
  }

  private:

  CDM::CompartmentDataRequestData* decode_compartment_request(int type, std::vector<std::string> & args);
  CDM::EnvironmentDataRequestData* decode_environment_request(std::vector<std::string>& args);
  CDM::PatientDataRequestData* decode_patient_request(std::vector<std::string>& args);
  CDM::PhysiologyDataRequestData* decode_physiology_request(std::vector<std::string>& args);
  CDM::SubstanceDataRequestData* decode_substance_request(std::vector<std::string>& args);

  DataRequestNode* _root;

};
