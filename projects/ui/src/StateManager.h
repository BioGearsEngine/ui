#pragma once
#include <iostream>
#include <boost/program_options.hpp>
#include <State.h>

class StateManager
{
public:
	StateManager(int argc, char *argv[]);
	~StateManager();
	State& GenerateState();
	void ProcessFlag(const std::string& flag, const bool isConfig);

private:
	boost::program_options::options_description ops_desc_;
	boost::program_options::variables_map var_map_;
	int num_flags_;
};