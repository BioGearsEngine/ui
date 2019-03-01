#include "main.h"

//System Inlcudes
#include <iostream>

//Project Inlcudes
#include "QPixmap"
#include "QSplashScreen"
#include "QThread"
#include "QTimer"
#include "QtUI.h"
#include "utils/StateManager.h"

#include <QMainWindow>
#include <biogears/cdm/CommonDataModel.h>
#include <biogears/cdm/engine/PhysiologyEngineTrack.h>
#include <biogears/cdm/utils/Logger.h>
#include <biogears/engine/BioGearsPhysiologyEngine.h>

int main(int argc, char* argv[])
{
  biogears_ui::QtUI ui(argc, argv);

  //Create and show splash screen
  QPixmap pixmap(":/img/biogears_BLKSymbol_Registered.png");
  //test if image doesn't load
  if (pixmap.isNull()) {
    pixmap = QPixmap(300, 300);
    pixmap.fill(Qt::magenta);
  }

  QSplashScreen splash(pixmap);
  splash.show();
  ui.processEvents(QEventLoop::AllEvents);

  //timing 
  std::clock_t start;
  double duration = 3.0;
  std::chrono::milliseconds timespan(1);
  start = std::clock();

  //render window for the duration
  while ((clock() - start) / CLOCKS_PER_SEC < duration) {
    std::this_thread::sleep_for(timespan);
    ui.processEvents(QEventLoop::AllEvents);
  }

  splash.finish(ui.activeWindow());
  ui.show();
  return ui.exec();
}
