#pragma once
#include <boost/filesystem.hpp>

class State
{
public:
	State(const boost::filesystem::path& configFile);
	State(const boost::filesystem::path& input, const boost::filesystem::path& output, const boost::filesystem::path& base_dir);
	State(const State& copy);
	~State();

	boost::filesystem::path GetInputPath() const;
	boost::filesystem::path GetOutputPath() const;
	boost::filesystem::path GetBaselinePath() const;
private:
	boost::filesystem::path *input_path_;
	boost::filesystem::path *output_path_;
	boost::filesystem::path *baseline_path_;
};
