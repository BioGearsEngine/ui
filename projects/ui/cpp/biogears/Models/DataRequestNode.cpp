#include "DataRequestNode.h"

#include "DataRequestTree.h"

#include <QDebug>
#include <QVariant>

DataRequestNode::DataRequestNode()
{
}
//------------------------------------------------------------------------------------
DataRequestNode::DataRequestNode(QString prefix, QString name, bool checked, bool collapsed, bool grandchildren, DataRequestNode* parent)
  : _parent(parent)
  , _name(name)
  , _checked(checked)
  , _collapsed(collapsed)
  , _grandchildren(grandchildren)
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
bool DataRequestNode::checked() const
{
  return _checked;
}
//------------------------------------------------------------------------------------
void DataRequestNode::checked(bool value)
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
bool DataRequestNode::grandchildren() const
{
  return _grandchildren;
}
//------------------------------------------------------------------------------------
void DataRequestNode::grandchildren(bool value)
{
  _grandchildren = value;
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


