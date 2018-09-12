#ifndef BIOGEARSUI_UTILS_RESOURCES
#define BIOGEARSUI_UTILS_RESOURCES
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
#include <biogears/string-exports.h>
//!
//! \author Steven A White
//! \date   Sept 12th 2018
//!
//!
//! \brief Helper functions for the locating of files and resources

#include <vector>
namespace biogears_ui {
namespace Resources {
  std::vector<std::string> list_directory(std::string path, std::string pattern = "*");
}
}

#endif //BIOGEARSUI_UTILS_RESOURCES
