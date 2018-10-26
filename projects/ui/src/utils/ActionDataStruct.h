#ifndef BIOGEARSUI_UTILS_ACTION_DATA_STRUCT_H
#define BIOGEARSUI_UTILS_ACTION_DATA_STRUCT_H

//-------------------------------------------------------------------------------------------
//- Copyright 2018 Applied Research Associates, Inc.
//- Licensed under the Apache License, Version 2.0 (the "License"); you may not use
//- this file except in compliance with the License. You may obtain a copy of the License
//- at:
//- http://www.apache.org/licenses/LICENSE-2.0
//- Unless required by applicable law or agreed to in writing, software distributed under
//- the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//- CONDITIONS OF ANY KIND, either express or implied. See the License for the
//-  specific language governing permissions and limitations under the License.
//-------------------------------------------------------------------------------------------

//!
//! \author Matthew McDaniel
//! \date   August 31st 2018
//!
//!

// \brief A structure to hold data pertaining to BioGears actions that is accessible to widgets that need access to
// (i.e. TimelineConfigWidget, TimelineWidget)

//External Includes
#include <biogears/string-exports.h>

namespace biogears_ui {

struct ActionData {
public:
  ActionData(const std::string& name, double time)
    : name(name)
    , at(time){};

  std::string name;
  double at;

  inline bool operator==(const std::string& rhs) const;
  inline bool operator!=(const std::string& rhs) const;
  inline bool operator==(const ActionData& rhs) const;
  inline bool operator!=(const ActionData& rhs) const;
  inline bool operator<(const ActionData& rhs) const;
  inline bool operator>(const ActionData& rhs) const;
  inline bool operator<=(const ActionData& rhs) const;
  inline bool operator>=(const ActionData& rhs) const;
};

bool ActionData::operator==(const std::string& rhs) const
{
  return name == rhs ? true : false;
};
//-------------------------------------------------------
bool ActionData::operator!=(const std::string& rhs) const
{
  return !(*this == rhs);
};
//-------------------------------------------------------
bool ActionData::operator==(const ActionData& rhs) const
{
  return name == rhs.name
    && at == rhs.at;
};
//-------------------------------------------------------
bool ActionData::operator!=(const ActionData& rhs) const
{
  return !(*this == rhs);
};
//-------------------------------------------------------
bool ActionData::operator<(const ActionData& rhs) const
{
  return name < rhs.name;
};
//-------------------------------------------------------
bool ActionData::operator>(const ActionData& rhs) const
{
  return name > rhs.name;
};
//-------------------------------------------------------
bool ActionData::operator<=(const ActionData& rhs) const
{
  return name <= rhs.name;
};
//-------------------------------------------------------
bool ActionData::operator>=(const ActionData& rhs) const
{
  return name >= rhs.name;
};
}
#endif
