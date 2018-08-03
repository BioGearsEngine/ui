#include "main.h"

//System Inlcudes
#include <iostream>

//Project Inlcudes
#include "QtUI.h"
#include "utils/StateManager.h"

#include <biogears/cdm/CommonDataModel.h>
#include <biogears/engine/BioGearsPhysiologyEngine.h>
#include <biogears/cdm/engine/PhysiologyEngineTrack.h>
#include <biogears/cdm/utils/Logger.h>
int main(int argc, char* argv[])
{
  biogears_ui::QtUI ui(argc,argv);
  ui.show();
  return ui.exec();
}
