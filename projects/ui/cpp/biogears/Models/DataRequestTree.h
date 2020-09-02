#pragma once

#include <memory>

#include <QAbstractItemModel>
#include <QObject>
#include <QString>
#include <QVariant>

#include "DataRequestNode.h"
#include "biogears/engine/Controller/BioGearsSubstances.h"

class DataRequestTree : public QAbstractItemModel {
  Q_OBJECT

public:
  enum DataRequestNodeRoles {

  };

  explicit DataRequestTree();
  explicit DataRequestTree(QString name, QObject* parent);
  ~DataRequestTree() override;


  QHash<int, QByteArray> roleNames() const
  {
    QHash<int, QByteArray> roles;
    roles[Qt::DisplayRole] = "name";
    
    return roles;
  }


};
