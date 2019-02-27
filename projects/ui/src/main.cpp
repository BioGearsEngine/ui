#include "main.h"

//System Inlcudes
#include <iostream>

//Project Inlcudes
#include "QTimer"
#include "QSplashScreen"
#include "QtUI.h"
#include "utils/StateManager.h"
#include "QThread"
#include "QPixmap"

#include <biogears/cdm/CommonDataModel.h>
#include <biogears/cdm/engine/PhysiologyEngineTrack.h>
#include <biogears/cdm/utils/Logger.h>
#include <biogears/engine/BioGearsPhysiologyEngine.h>
#include <QMainWindow>

int main(int argc, char* argv[])
{
  biogears_ui::QtUI ui(argc, argv);

  //Create and show splash screen
  QPixmap pixmap("D:/BioGears/gui/ui/projects/ui/src/img/biogears_BLKSymbol_Registered.png");

  //QPixmap pixmap(":/img/biogears_BLKSymbol_Registered.png");
  if (pixmap.isNull()) {
    pixmap = QPixmap(300, 300);
    pixmap.fill(Qt::magenta);
  }

  QSplashScreen splash(pixmap);
  splash.show();
  ui.processEvents(QEventLoop::AllEvents);
  //app.processEvents(QEventLoop::AllEvents);

  std::clock_t start;
  double duration;
  std::chrono::milliseconds timespan(1);
  start = std::clock();

  while ((clock() - start) / CLOCKS_PER_SEC < 1.0) {
    std::this_thread::sleep_for(timespan);
    ui.processEvents(QEventLoop::AllEvents);
    }

  splash.finish(ui.activeWindow());
  ui.show();
  return ui.exec();
}
