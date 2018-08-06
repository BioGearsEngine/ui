#ifndef BIOGEARSUI_SCENARIO_DATA_H
#define BIOGEARSUI_SCENARIO_DATA_H
//-------------------------------------------------------------------------------------------
//- Copyright 2018 Applied Research Associates, Inc.
//- Licensed under the Apache License, Version 2.0 (the "License"); you may not use
//- this file except in compliance with the License. You may obtain a copy of the License
//- at:
//- http://www.apache.org/licenses/LICENSE-2.0
//- Unless required by applicable law or agreed to in writing, software distributed under
//- the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//- CONDITIONS OF ANY KIND, either express or implied. See the License for the
//-  specific language governing permissions and limitations under the License.
//-------------------------------------------------------------------------------------------
#include <biogears/string-exports.h>
#include <string>
#include <fstream>
#include <iostream>
#include <vector>
#include <boost/algorithm/string/split.hpp>
#include <boost/algorithm/string/classification.hpp>

namespace biogears_ui {
class ScenarioData
{
public:
	ScenarioData();
	~ScenarioData();

	std::vector<std::string>& getHeaders();
	void setHeaders();
	void setDataSeries(std::string &y_header);
	void setScenario(std::string &file_name);
	std::vector<double>& getXSeries();
	std::vector<double>& getYSeries();

private:
	std::string file_name_;
	std::vector<std::string> headers_vector_;
	std::vector<double> x_data_;
	std::vector<double> y_data_;
};
}
#endif //BIOGEARSUI_SCENARIO_DATA_H