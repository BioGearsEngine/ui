#pragma once
#include <iostream>
#include <boost/program_options.hpp>

class StateManager
{
public:
	StateManager(int argc, char * argv[]);
	~StateManager();



private:
	int arg_c_;
	char **arg_v_;
	boost::program_options::options_description ops_desc_;
	boost::program_options::variables_map var_map_;
};