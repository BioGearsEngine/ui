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
  DataRequestNode(QString name, int checked = 0, bool collapsed = true, QString type = "", DataRequestNode* parent = nullptr);
  ~DataRequestNode();

  struct NodeInput {
    QString name;
    QString type;
  };

  QString name() const;
  void name(const QString& value);

  int checked() const;
  void checked(int value);

  bool collapsed() const;
  void collapsed(bool value);

  QString type() const;
  void type(QString& value);

  int rows() const;
  int rowInParent() const;

  QVariant data(int role) const;

  DataRequestNode const* parent() const;
  DataRequestNode* parent();
  DataRequestNode* child(int row);
  DataRequestNode const* child(int row) const;
  QVector<DataRequestNode*> children() const;
  DataRequestNode* appendChild(QString name, QString type = "");
  DataRequestNode* appendChildren(QList<QPair<QString, QString>> nameTypePairs);
  void reset();

private:
  DataRequestNode* _parent = nullptr;

  QVector<DataRequestNode*> _children;
  QString _name;
  int _checked = 0;
  bool _collapsed = true;
  QString _type = "";
};
