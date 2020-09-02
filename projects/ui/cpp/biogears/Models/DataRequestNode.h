#pragma once

#include <QAbstractItemModel>
#include <QString>
#include <QVariant>
#include <QVector>

#include <biogears/cdm/properties/SEScalar.h>
#include <biogears/cdm/properties/SEUnitScalar.h>

class DataRequestNode {
public:
  DataRequestNode();
  DataRequestNode(QString prefix, QString name, bool checked = false, bool collapsed = true, bool grandchildren = false, DataRequestNode* parent = nullptr);
  ~DataRequestNode();

  QString name() const;
  void name(const QString&);

  bool checked() const;
  void checked(bool value);

  bool collapsed() const;
  void collapsed(bool value);

  bool grandchildren() const;
  void grandchildren(bool value);

  QVector<DataRequestNode> children();
  


  DataRequestNode const* parent() const;
  DataRequestNode* parent();

private:
  DataRequestNode* _parent = nullptr;

  QVector<DataRequestNode> _children;
  QString _name;
  bool _checked = false;
  bool _collapsed = true;
  bool _grandchildren = true;
};
