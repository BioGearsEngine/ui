#include "main.h"

//System Inlcudes
#include <iostream>

//Project Inlcudes
#include "QtUI.h"
#include "Utils/StateManager.h"

int main(int argc, char* argv[])
{
  using biogears_ui::StateManager;
  using biogears_ui::State;;

  StateManager mgr = StateManager(argc, argv);
  State scenario = mgr.state();
  std::cout << "State Information : " << std::endl;
  std::cout << "Input File = " << scenario.inputPath().string() << std::endl;
  std::cout << "Output File = " << scenario.outputPath().string() << std::endl;
  std::cout << "Baseline File = " << scenario.baselinePath().string() << std::endl;

  biogears_ui::QtUI ui;
  ui.show();
  return ui.run();
}
