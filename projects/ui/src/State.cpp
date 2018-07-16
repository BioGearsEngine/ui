#include <State.h>

State::State(boost::filesystem::path p)
{
	
}

State::State(int argc, char * argv[])
{
	
}

State::~State()
{
	
}

boost::filesystem::path& State::GetBaselineDirectory() const
{
	return *baseline_dir_;
}
boost::filesystem::path& State::GetLog() const
{
	return *log_path_;
}

boost::filesystem::path& State::GetScenario() const
{
	return *scenario_path_;
}