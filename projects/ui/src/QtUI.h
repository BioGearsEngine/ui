#ifndef BIOGEARSUI_QtUI_H
#define BIOGEARSUI_QtUI_H

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

#include <biogears/framework/unique_propagate_const.h>

//! \file
//! \author Steven A WHite
//! \date 2018-07-18
//! \brief Main Application class for Qt GUI

//Standard Includes
#include <string>
#include <vector>

//External Includes
#include <QApplication>
namespace biogears_ui {
class QtUI : public QApplication {
//Q_OBJECT
public:
  QtUI();
  QtUI(int& argc, char* argv[]);

  ~QtUI();
  
  void show();

  static constexpr const char* BIOGEARS_VERSION = "7.0.0";
  static constexpr const char* BIOGEARS_UI_VERSION = "1.0.0";
  
  private:
  struct Implementation;
  biogears::unique_propagate_const<Implementation> _impl;
};
}
#endif //BIOGEARSUI_BOGEARSQTUI_H