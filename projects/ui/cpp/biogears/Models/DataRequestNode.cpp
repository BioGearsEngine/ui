#include "DataRequestNode.h"

#include "DataRequestTree.h"

#include <QDebug>
#include <QVariant>

DataRequestNode::DataRequestNode()
{
}
//------------------------------------------------------------------------------------
DataRequestNode::DataRequestNode(QString name, int checked, bool collapsed, QString type, DataRequestNode* parent)
  : _parent(parent)
  , _name(name)
  , _checked(checked)
  , _collapsed(collapsed)
  , _type(type)
{
}
//------------------------------------------------------------------------------------
DataRequestNode::~DataRequestNode()
{
  _children.clear();
}
//------------------------------------------------------------------------------------
QString DataRequestNode::name() const
{
  return _name;
}
//------------------------------------------------------------------------------------
void DataRequestNode::name(const QString& value)
{
  _name = value;
}
//------------------------------------------------------------------------------------
int DataRequestNode::checked() const
{
  return _checked;
}
//------------------------------------------------------------------------------------
void DataRequestNode::checked(int value)
{
  _checked = value;
}
//------------------------------------------------------------------------------------
bool DataRequestNode::collapsed() const
{
  return _collapsed;
}
//------------------------------------------------------------------------------------
void DataRequestNode::collapsed(bool value)
{
  _collapsed = value;
}
//------------------------------------------------------------------------------------
QString DataRequestNode::type() const
{
  return _type;
}
//------------------------------------------------------------------------------------
void DataRequestNode::type(QString& value)
{
  _type = value;
}
//------------------------------------------------------------------------------------
int DataRequestNode::rows() const
{
  return _children.size();
}
//------------------------------------------------------------------------------------
int DataRequestNode::rowInParent() const
{
  if (_parent != nullptr) {
    return _parent->children().indexOf(const_cast<DataRequestNode*>(this));
  } else {
    return 0;
  }
}
//------------------------------------------------------------------------------------
DataRequestNode const* DataRequestNode::parent() const
{
  return _parent;
}
//------------------------------------------------------------------------------------
DataRequestNode* DataRequestNode::parent()
{
  return _parent;
}
//------------------------------------------------------------------------------------
DataRequestNode* DataRequestNode::child(int index)
{
  if (0 <= index && index < _children.size()) {
    return _children[index];
  }
  return nullptr;
}
//------------------------------------------------------------------------------------
DataRequestNode const* DataRequestNode::child(int index) const
{
  if (0 <= index && index <= _children.size()) {
    return _children[index];
  }
  return nullptr;
}
//------------------------------------------------------------------------------------
QVector<DataRequestNode*> DataRequestNode::children() const
{
  return _children;
}
//------------------------------------------------------------------------------------
QVariant DataRequestNode::data(int role) const
{
  switch (role) {
  case Qt::DisplayRole:
    return QVariant(_name);
  case Qt::CheckStateRole:
    return QVariant(_checked);
  case DataRequestTree::CollapsedRole:
    return QVariant(_collapsed);
  case DataRequestTree::TypeRole:
    return QVariant(_type);
  default:
    return QVariant();
  }
}
//------------------------------------------------------------------------------------
DataRequestNode* DataRequestNode::appendChild(QString name, QString type)
{
  DataRequestNode* newNode = new DataRequestNode();
  newNode->_name = name;
  newNode->_checked = 0;
  newNode->_collapsed = true;
  newNode->_type = type;
  newNode->_parent = this;
  _children.append(newNode);
  return _children.back();
}
//------------------------------------------------------------------------------------
DataRequestNode* DataRequestNode::appendChildren(QList<QPair<QString, QString>> nameTypePairs)
{
  QList<QPair<QString, QString>>::const_iterator nodeIt;
  for (nodeIt = nameTypePairs.constBegin(); nodeIt != nameTypePairs.constEnd(); ++nodeIt) {
    DataRequestNode* childNode = new DataRequestNode((*nodeIt).first, 0, true, (*nodeIt).second, this);
    _children.append(childNode);
  }
  return _children.back();
}
//------------------------------------------------------------------------------------
void DataRequestNode::reset()
{
  collapsed(true);
  checked(0);
  if (_children.size() > 0) {
    for (auto child : _children) {
      child->reset();
    }
  }
}