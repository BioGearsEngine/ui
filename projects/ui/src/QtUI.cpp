#include "QtUI.h"

//External Includes
#include <boost/filesystem.hpp>

//Project Includes
#include <utils/State.h>
#include <utils/StateManager.h>

namespace biogears_ui {

  static int g_argc = 1;
  static char* g_argv[] = {"biogears_ui"};
  //!
//! \brief Data Implementation of the QtUI class
//!
struct QtUI::Implementation {
public:
  Implementation();
  Implementation( const Implementation&) = default;
  Implementation( Implementation&&) = default;
  Implementation(std::vector<std::string>);

  State application_state;
};
QtUI::Implementation::Implementation()
  : application_state()
  {
  
}
//---------------------------------------------------------------------------
QtUI::Implementation::Implementation(std::vector<std::string>)
  : application_state()
{
}
//---------------------------------------------------------------------------
QtUI::QtUI()
  : QApplication(g_argc,g_argv)
  , _impl()
{
}
  //---------------------------------------------------------------------------
QtUI::QtUI(int argc, char* argv[])
  : QApplication(argc, argv)
  , _impl()
{
  //TODO Parse with argc,argv and pass to the correct class
}

//---------------------------------------------------------------------------
QtUI ::~QtUI()
{
  _impl = nullptr;
}
//---------------------------------------------------------------------------
void QtUI::show()
{
}
//---------------------------------------------------------------------------
int QtUI::run()
{
  return 0;
}
//---------------------------------------------------------------------------
}