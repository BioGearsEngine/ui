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

#include <QtWidgets>

#include "MainWindow.h"

namespace biogears_ui {

struct MainWindow::Implementation {
public:
  Implementation();
  Implementation(const Implementation&);
  Implementation(Implementation&&);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

};
//-------------------------------------------------------------------------------
MainWindow::Implementation::Implementation()
{
}
//-------------------------------------------------------------------------------
MainWindow::Implementation::Implementation(const Implementation& obj)

{
  *this = obj;
}
//-------------------------------------------------------------------------------
MainWindow::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
MainWindow::Implementation& MainWindow::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
MainWindow::Implementation& MainWindow::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
  }
  return *this;
}
//-------------------------------------------------------------------------------
MainWindow::MainWindow()
{
  //setCentralWidget(textEdit);
  createActions();
  createStatusBar();
  readSettings();
  setUnifiedTitleAndToolBarOnMac(true);
}
//-------------------------------------------------------------------------------
MainWindow::~MainWindow()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
void MainWindow::closeEvent(QCloseEvent* event)
{
    event->accept();
}
//-------------------------------------------------------------------------------
void MainWindow::about()
{
  QMessageBox::about(this, tr("About Application"),
    tr("The <b>Application</b> example demonstrates how to "
       "write modern GUI applications using Qt, with a menu bar, "
       "toolbars, and a status bar."));
}
void MainWindow::run()
{
  QMessageBox::about(this, tr("About Application"),
    tr("The <b>Application</b> example demonstrates how to "
       "write modern GUI applications using Qt, with a menu bar, "
       "toolbars, and a status bar."));
}
//-------------------------------------------------------------------------------
void MainWindow::createActions()
{

  //--Scenario MENU --//
  QMenu* fileMenu = menuBar()->addMenu(tr("&Simulation"));
  QToolBar* fileToolBar = addToolBar(tr("Simulation"));
  const QIcon newIcon = QIcon::fromTheme("Run", QIcon(":/img/play.png"));
  QAction* newAct = new QAction(newIcon, tr("&Run"), this);
  // newAct->setShortcuts(QKeySequence::New);
  newAct->setStatusTip(tr("Run current simulation"));
  connect(newAct, &QAction::triggered, this, &MainWindow::run);
  fileMenu->addAction(newAct);
  fileToolBar->addAction(newAct);

  fileMenu->addSeparator();

  const QIcon exitIcon = QIcon::fromTheme("application-exit");
  QAction* exitAct = fileMenu->addAction(exitIcon, tr("E&xit"), this, &QWidget::close);
  exitAct->setShortcuts(QKeySequence::Quit);
  exitAct->setStatusTip(tr("Exit the application"));

  //--HELP MENU --//

  QMenu* helpMenu = menuBar()->addMenu(tr("&Help"));
  QAction* aboutAct = helpMenu->addAction(tr("&About"), this, &MainWindow::about);
  aboutAct->setStatusTip(tr("Show the application's About box"));

  QAction* aboutQtAct = helpMenu->addAction(tr("About &Qt"), qApp, &QApplication::aboutQt);
  aboutQtAct->setStatusTip(tr("Show the Qt library's About box"));

}
//-------------------------------------------------------------------------------
void MainWindow::createStatusBar()
{
  statusBar()->showMessage(tr("Ready"));
}
//-------------------------------------------------------------------------------
void MainWindow::readSettings()
{
  QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName());
  const QByteArray geometry = settings.value("geometry", QByteArray()).toByteArray();
  if (geometry.isEmpty()) {
    const QRect availableGeometry = QApplication::desktop()->availableGeometry(this);
    resize(availableGeometry.width() / 3, availableGeometry.height() / 2);
    move((availableGeometry.width() - width()) / 2,
      (availableGeometry.height() - height()) / 2);
  } else {
    restoreGeometry(geometry);
  }
}
//-------------------------------------------------------------------------------
void MainWindow::writeSettings()
{
  QSettings settings(QCoreApplication::organizationName(), QCoreApplication::applicationName());
  settings.setValue("geometry", saveGeometry());
}
}
