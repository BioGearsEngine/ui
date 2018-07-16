#pragma once
#include <boost/filesystem.hpp>

class State
{
public:
	State(boost::filesystem::path p);
	State(int argc, char * argv[]);
	~State();

	boost::filesystem::path& GetLog() const;
	boost::filesystem::path& GetScenario() const;
	boost::filesystem::path& GetBaselineDirectory() const;
private:
	boost::filesystem::path *log_path_;
	boost::filesystem::path *scenario_path_;
	boost::filesystem::path *baseline_dir_;

};
