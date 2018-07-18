#include <StateManager.h>


StateManager::StateManager(int argc, char *argv[])
{
	namespace bpo = boost::program_options;
	namespace ph = std::placeholders;
	bpo::options_description ops_desc_("Options");
	num_flags_ = 0;
	ops_desc_.add_options()
		("config", bpo::value<std::string>()->notifier(std::bind(&StateManager::ProcessFlag, this, ph::_1, true)), "Path to BioGears Configuration File")
		("input", bpo::value<std::string>()->notifier(std::bind(&StateManager::ProcessFlag, this, ph::_1, false)), "Overwrite input file generated from config")
		("output", bpo::value<std::string>()->notifier(std::bind(&StateManager::ProcessFlag, this, ph::_1, false)), "Overwrite output location generated from config")
		("baseline", bpo::value<std::string>()->notifier(std::bind(&StateManager::ProcessFlag, this, ph::_1, false)), "Overwrite baseline data directory generated from config");
	try
	{
		bpo::store(bpo::parse_command_line(argc, argv, ops_desc_), var_map_);
		bpo::notify(var_map_);
	}
	catch (bpo::error& err) {
		std::cerr << err.what() << std::endl;
		std::cout << "\n";
		std::cout << ops_desc_ << std::endl;
		std::exit(EXIT_FAILURE);
	}
}

StateManager::~StateManager()
{
	var_map_.clear();
	num_flags_ = 0;
}

State& StateManager::GenerateState()
{
	namespace bpo = boost::program_options;
	namespace bfs = boost::filesystem;

	auto current_dir = bfs::current_path();
	//Default config path
	auto config_path = current_dir / "biogears-us.config";
	std::string info = "Using default config file : " + config_path.string();
	
	if(var_map_.count("config")){
		config_path = bfs::path(var_map_["config"].as<std::string>());
		info = "Using user specified config file : " + config_path.string();
	}
	std::cout << info << std::endl;

	State *stateFromConfig = new State(config_path);

	if(num_flags_==0){
		return *stateFromConfig;
	}

	auto input_path = (var_map_.count("input")) ? bfs::path(var_map_["input"].as<std::string>()) : stateFromConfig->GetInputPath();
	auto output_path = (var_map_.count("output")) ? bfs::path(var_map_["output"].as<std::string>()) : stateFromConfig->GetOutputPath();
	auto base_path = (var_map_.count("baseline")) ? bfs::path(var_map_["baseline"].as<std::string>()) : stateFromConfig->GetBaselinePath();

	State *stateFromArgs = new State(input_path, output_path, base_path);
	return *stateFromArgs;
	
}

void StateManager::ProcessFlag(const std::string& flag, const bool isConfig)
{
	auto test_path = boost::filesystem::path(flag);
	if(!exists(test_path)){
		std::string err = "Could not find location : " + flag;
		throw boost::program_options::error(err);	
	}
	if (!isConfig) {
		num_flags_++;
	}
}