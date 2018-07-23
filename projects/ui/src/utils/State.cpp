#include "State.h"

//! \file
//! \author Matt McDaniel
//! \date   2018-07-10
//! \brief  Struct for communicating program STATE through out the UI
//!

#include <string>
#include <vector>

namespace biogears_ui {

struct State::Implementation {
public:
  Implementation();
  Implementation(const Implementation&);
  Implementation(Implementation&&);
  Implementation(std::vector<std::string>);

  Implementation& operator=(const Implementation&);
  Implementation& operator=(Implementation&&);

  boost::filesystem::path input_path = "./logs";
  boost::filesystem::path output_path = "./output_path";
  boost::filesystem::path baseline_path = "./baselines";
};
//-------------------------------------------------------------------------------
State::Implementation::Implementation()
{
}
//-------------------------------------------------------------------------------
State::Implementation::Implementation(const Implementation& obj)

{
  *this = obj;
}
//-------------------------------------------------------------------------------
State::Implementation::Implementation(Implementation&& obj)
{
  *this = std::move(obj);
}
//-------------------------------------------------------------------------------
State::Implementation& State::Implementation::operator=(const Implementation& rhs)
{
  if (this != &rhs) {
    input_path = rhs.input_path;
    output_path = rhs.output_path;
    baseline_path = rhs.baseline_path;
  }
  return *this;
}
//-------------------------------------------------------------------------------
State::Implementation& State::Implementation::operator=(Implementation&& rhs)
{
  if (this != &rhs) {
    input_path = std::move(rhs.input_path);
    output_path = std::move(rhs.output_path);
    baseline_path = std::move(rhs.baseline_path);
  }
  return *this;
}
//-------------------------------------------------------------------------------
State::Implementation::Implementation(std::vector<std::string> vec)
{
  if (vec.size() >= 3) {
    input_path = vec[0];
    output_path = vec[1];
    baseline_path = vec[2];
  }
}
//-------------------------------------------------------------------------------
State::State(const boost::filesystem::path& configFile)
  : _impl()
{
  //TODO:Parse Config File
}

//-------------------------------------------------------------------------------
State::State()
  : _impl()
{
  auto j = 0;
  auto i = j + &_impl;
}
//-------------------------------------------------------------------------------
State::State(const State& obj)
  : _impl(*obj._impl)
{
}
//-------------------------------------------------------------------------------
State::State(State&& obj)
  : _impl(std::move(obj._impl))
{
}
//-------------------------------------------------------------------------------
State::~State()
{
  _impl = nullptr;
}
//-------------------------------------------------------------------------------
State& State::operator=(const State& rhs)
{
  if (this!=&rhs)
  {
    *_impl = *rhs._impl;
  }
  return *this;
}
//-------------------------------------------------------------------------------
State& State::operator=(State&& rhs)
{
  if (this != &rhs) {
    *_impl = std::move(*rhs._impl);
  }
  return *this;
}
//-------------------------------------------------------------------------------
const boost::filesystem::path& State::inputPath() const
{
  return _impl->input_path;
}
//-------------------------------------------------------------------------------
const boost::filesystem::path& State::outputPath() const
{
  return _impl->output_path;
}
//-------------------------------------------------------------------------------
const boost::filesystem::path& State::baselinePath() const
{
  return _impl->baseline_path;
}
//-------------------------------------------------------------------------------
State& State::inputPath(boost::filesystem::path p)
{
  _impl->input_path = p;
  return *this;
}
//-------------------------------------------------------------------------------
State& State::outputPath(boost::filesystem::path p)
{
  _impl->output_path = p;
  return *this;
}
//-------------------------------------------------------------------------------
State& State::baselinePath(boost::filesystem::path p)
{
  _impl->baseline_path = p;
  return *this;
}
//-------------------------------------------------------------------------------
}
