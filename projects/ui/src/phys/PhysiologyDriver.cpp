#include "PhysiologyDriver.h"

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

//Standard Includes
#include <memory>

//External Includes
#include <biogears/string-exports.h>
#include <biogears/engine/BioGearsPhysiologyEngine.h>

namespace biogears_ui {
struct PhysiologyDriver::Implementation {
public:
  Implementation(const std::string&);
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  std::unique_ptr<PhysiologyEngine> phy;
};
//-------------------------------------------------------------------------------
PhysiologyDriver::Implementation::Implementation(const std::string& scenario)
: phy( CreateBioGearsEngine( scenario + ".log" ) )
{

}
//-------------------------------------------------------------------------------
PhysiologyDriver::Implementation::Implementation(const Implementation& obj)

{
  *this = obj;
}
//-------------------------------------------------------------------------------
PhysiologyDriver::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
PhysiologyDriver::Implementation& PhysiologyDriver::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
PhysiologyDriver::Implementation& PhysiologyDriver::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
PhysiologyDriver::PhysiologyDriver( const std::string& scenario )
:_impl(scenario)
{

}
//-------------------------------------------------------------------------------
PhysiologyDriver::~PhysiologyDriver()
{
  _impl = nullptr;
}
}