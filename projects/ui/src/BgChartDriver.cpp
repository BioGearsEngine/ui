#include <BgChartDriver.h>

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

//!
//! \author Matt McDaniel
//! \date   June 24th 2018
//!
//!  
//! \brief Primary window of BioGears UI
namespace biogears_ui {
BgChartDriver::BgChartDriver()
{
	bg_chart_ = new BgChart();
	bg_view_ = new QChartView();
	bg_plot_options_ = new QComboBox();
	bg_plot_layout_ = new QGridLayout();
	bg_widget_ = new QWidget();
	q_headers_ = new QStringList();
	data_container_ = new ScenarioData();
	std::string basic = std::string("D:\\BioGears2\\core\\build-vc15\\runtime\\Scenarios\\Patient\\BasicStandardResults.csv");
	std::string input = std::string("HeartRate(1/min)");
	SetBgChartProperties(basic);
	SetBgChartDataSeries(input);
}

BgChartDriver::~BgChartDriver()
{
	
}

void BgChartDriver::SetBgChartOptions()
{
	//This method takes the std::vector of headers and changes it to a Qvector.  This is done to keep the Qt implementation separate from the DataContainer
	//Use getHeaders method to pull the column headers (i.e. HR, RR, etc) to put in a combo box (drop down menu)
	std::vector<std::string> stdHeaders = data_container_->getHeaders();

	//getHeaders method returns a std vector, but combobox wants a QtStringList
	for (auto str : stdHeaders)
	{
		q_headers_->push_back(QString::fromStdString(str));
	}
	bg_plot_options_->clear();
	bg_plot_options_->addItems(*q_headers_);
}

void BgChartDriver::SetBgChartDataSeries(std::string &y_name)
{
	//Check headers vector to make sure option is viable (skip first entry since this is "Please select a property" entry)
	if (std::find(data_container_->getHeaders().begin() + 1, data_container_->getHeaders().end(), y_name) == data_container_->getHeaders().end())
	{
		std::cout << "Error : Invalid property" << std::endl;
		return;
	}
	y_header_ = y_name;
	data_container_->setDataSeries(y_header_);
	bg_chart_->UpdateBgChart(data_container_,y_header_);

}
void BgChartDriver::SetBgChartProperties(std::string &file_name)
{
	data_container_->setScenario(file_name);
	SetBgChartOptions();
}

QWidget* BgChartDriver::DisplayBgChart()
{
	bg_view_->setChart(bg_chart_);
	bg_plot_layout_->addWidget(bg_plot_options_, 0, 1, 1, 1);
	bg_plot_layout_->addWidget(bg_view_, 1, 0, 3, 3);
	bg_widget_->setLayout(bg_plot_layout_);
	return bg_widget_;
}
}