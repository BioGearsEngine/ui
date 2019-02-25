#include "main.h"

//System Inlcudes
#include <iostream>

//Project Inlcudes
#include "QTimer"
#include "QSplashScreen"
#include "QtUI.h"
#include "utils/StateManager.h"

#include <biogears/cdm/CommonDataModel.h>
#include <biogears/cdm/engine/PhysiologyEngineTrack.h>
#include <biogears/cdm/utils/Logger.h>
#include <biogears/engine/BioGearsPhysiologyEngine.h>
int main(int argc, char* argv[])
{
  biogears_ui::QtUI ui(argc, argv);

  //Create and show splash screen
  QSplashScreen* splash = new QSplashScreen;
  splash->setPixmap(QPixmap(":/images/BioGears_White Logo.png"));
  splash->show();

  QTimer::singleShot(250000, splash, SLOT(close()));
  //QTimer::singleShot(2500, &ui, SLOT(show()));

  ui.show();
  return ui.exec();
}
