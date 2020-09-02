#include "DataRequestTree.h"

#include <biogears/engine/Controller/BioGearsSubstances.h>
#include <biogears/cdm/properties/SEScalarTime.h>

/// DataRequestTree Model

DataRequestTree::DataRequestTree()
  : QAbstractItemModel(nullptr)
{
}

DataRequestTree::DataRequestTree(QString n, QObject* p)
  : QAbstractItemModel(p)
{
}

//------------------------------------------------------------------------------------
DataRequestTree::~DataRequestTree()
{
}

