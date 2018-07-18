#include <State.h>
#include <iostream>

State::State(const boost::filesystem::path& configFile)
{
	input_path_ = new boost::filesystem::path("Input from config");
	output_path_ = new boost::filesystem::path("Output from config");
	baseline_path_ = new boost::filesystem::path("Baseline from config");
}

State::State(const boost::filesystem::path& input, const boost::filesystem::path& output, const boost::filesystem::path& baseline)
{
	input_path_ = new boost::filesystem::path(input);
	output_path_ = new boost::filesystem::path(output);
	baseline_path_ = new boost::filesystem::path(baseline);
}

State::State(const State& copy) : input_path_(copy.input_path_), output_path_(copy.output_path_), baseline_path_(copy.baseline_path_)
{
}

State::~State()
{
	input_path_ = nullptr;
	output_path_ = nullptr;
	baseline_path_ = nullptr;
}

boost::filesystem::path State::GetBaselinePath() const
{
	return *baseline_path_;
}
boost::filesystem::path State::GetInputPath() const
{
	return *input_path_;
}

boost::filesystem::path State::GetOutputPath() const
{
	return *output_path_;
}