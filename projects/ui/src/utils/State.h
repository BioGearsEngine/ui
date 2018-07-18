#ifndef BIOGEARSUI_UTILS_STATE_H
#define BIOGEARSUI_UTILS_STATE_H

//! \file
//! \author Matt McDaniel
//! \date   2018-07-10
//! \brief  Struct for communicating program STATE through out the UI
//!

//External Includes
#include <boost/filesystem.hpp>
//Project Includes
#include <biogears/framework/const_propagation_pointers.h>

namespace biogears_ui {
class State {
public:
  State(const boost::filesystem::path& configFile);

  State();
  State(const State&);
  State(State&&);
  ~State();

	const boost::filesystem::path& inputPath() const;
  const boost::filesystem::path& outputPath() const;
  const boost::filesystem::path& baselinePath() const;

  State& inputPath(boost::filesystem::path);
  State& outputPath(boost::filesystem::path);
  State& baselinePath(boost::filesystem::path);


private:
  struct Implementation;
  biogears::Unique_Prop_Ptr<Implementation> _impl;
};
}

#endif //BIOGEARSUI_UTILS_STATE_H
