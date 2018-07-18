#ifndef BIOGEARSUI_UTILS_STATEMANAGER_H
#define BIOGEARSUI_UTILS_STATEMANAGER_H

//! \file
//! \author Matt McDaniel
//! \date   2018-07-10
//! \brief  Stil deciding on a Manager/Factory construct
//!         Responsible for creating states and distributing them

//Standard includes
#include <string>
//External includes
#include <boost/program_options.hpp>
//Project includes
#include "State.h"
namespace biogears_ui {
class StateManager {
public:
  StateManager(int argc, char* argv[]);
  ~StateManager();

  State state() const;
  void  process_flag(const std::string& flag, const bool isConfig);

private:
	boost::program_options::options_description ops_desc_;
	boost::program_options::variables_map var_map_;
	int num_flags_;
};
}

#endif //BIOGEARSUI_UTILS_STATEMANAGER_H
