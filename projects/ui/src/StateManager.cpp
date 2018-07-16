#include <StateManager.h>


StateManager::StateManager(int argc, char * argv[]) : arg_c_(argc),arg_v_(argv)
{
	std::cout << "State Manager constructed with : " << std::endl;
	std::cout << "Num args = " << arg_c_ << std::endl;
	for (int i = 0; i < arg_c_; i++) {
		std::cout << "Input " << i << " = " << arg_v_[i] << std::endl;
	}

}
