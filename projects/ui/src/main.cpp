#include "main.h"

//System Inlcudes
#include <iostream>

//Project Inlcudes
#include "QtUI.h"
#include "utils/StateManager.h"

int main(int argc, char* argv[])
{
  biogears_ui::QtUI ui(argc,argv);
  ui.show();
  return ui.exec();
}
