#ifndef BIOGEARSUI_WIDGETS_MAIN_WINDOW_H
#define BIOGEARSUI_WIDGETS_MAIN_WINDOW_H

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
//! \author Steven A White
//! \date   June 24th 2018
//!
//!  
//! \brief Primary window of BioGears UI

//External Includes
#include <QMainWindow>
//Project Includes
#include <biogears/framework/unique_propagate_const.h>

namespace biogears_ui {
class MainWindow : public QMainWindow {
  Q_OBJECT

public:
  MainWindow();
  ~MainWindow();

  void loadFile(const QString& fileName);
  
protected:
  void closeEvent(QCloseEvent* event) override;

private slots:
  void about();
  void run();
private:
  void createActions();
  void createStatusBar();
  void readSettings();
  void writeSettings();

  struct Implementation;
  biogears::unique_propagate_const<Implementation> _impl;
  
};
}

#endif //MAIN_WINDOW