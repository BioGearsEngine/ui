#ifndef BIOGEARSUI_QtUI_H
#define BIOGEARSUI_QtUI_H

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
  QtUI(int argc, char* argv[]);

  ~QtUI();
  void show();

protected:
private:
  struct Implementation;
  biogears::unique_propagate_const<Implementation> _impl;
  //std::unique_ptr<Implementation> _impl;
};
}
#endif //BIOGEARSUI_BOGEARSQTUI_H