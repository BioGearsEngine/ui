#include "QtUI.h"

//Standard Includes
#include <iostream>

//External Includes
#include <boost/filesystem.hpp>

//Project Includes
#include <utils/State.h>
#include <utils/StateManager.h>
#include <widgets/MainWindow.h>

namespace biogears_ui {

static int g_argc = 1;
static char * g_argv[] = { "biogears_ui" };
//!
//! \brief Data Implementation of the QtUI class
//!
struct QtUI::Implementation {
public:
  Implementation();
  Implementation(const Implementation&) = delete;
  Implementation(Implementation&&) = default;
  Implementation(std::vector<std::string>);

  State application_state;
  MainWindow main_window;
};
QtUI::Implementation::Implementation()
  : application_state()
  , main_window(nullptr)
{
}
//---------------------------------------------------------------------------


QtUI::Implementation::Implementation(std::vector<std::string>)
  : application_state()
  , main_window(nullptr)
{
}
//---------------------------------------------------------------------------
//! Constructor for QtUI -- Passes QApplication g_argc and g_argv
//! Is defined mostly because of the PIMPL implementation and should not be used
//! \see QApplication(argc,argv)
QtUI::QtUI()
  : QApplication(g_argc, g_argv)
  , _impl()
{
}
//---------------------------------------------------------------------------
//! Constructor for QtUI -- Inheriting from QApplicaiton is not normally done
//!                      -- Much like QApplication only one of these should exist
//!                      -- per application
//!
//! \param int  [IN] Number of arguments contained in ARGV.  Assumed argc > 0
//! \param char** [IN] An array of cstrings such that argv[0] is the executable name and argv[i] i>0 is the number of arguments passed to the executable
QtUI::QtUI(int& argc, char* argv[])
  : QApplication(argc, argv)
  , _impl()
{
  using biogears_ui::State;
  using biogears_ui::StateManager;

  QCoreApplication::setOrganizationName("BioGears");
  QCoreApplication::setApplicationName("BioGears Simulation UI");
  QCoreApplication::setApplicationVersion(BIOGEARS_UI_VERSION);

  StateManager mgr = StateManager(argc, argv);
  _impl->application_state = mgr.state();

  auto& scenario = _impl->application_state;
  std::cout << "State Information : " << std::endl;
  std::cout << "Input File = " << scenario.inputPath().string() << std::endl;
  std::cout << "Output File = " << scenario.outputPath().string() << std::endl;
  std::cout << "Baseline File = " << scenario.baselinePath().string() << std::endl;
}

//---------------------------------------------------------------------------
QtUI ::~QtUI()
{
  _impl = nullptr;
}
//---------------------------------------------------------------------------
void QtUI::show()
{
  _impl->main_window.show();
}
//---------------------------------------------------------------------------
}
