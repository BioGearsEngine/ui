#ifndef BIOGEARSUI_BGCHART_DRIVER_H
#define BIOGEARSUI_BGCHART_DRIVER_H

#include <QtCharts>
#include <ScenarioData.h>
#include <BgChart.h>

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
class BgChartDriver
{
public: 
	BgChartDriver();
	~BgChartDriver();

	QWidget* DisplayBgChart();
	void SetBgChartDataSeries(std::string &y_name);
	void SetBgChartProperties(std::string &file_name);

private:
	void SetBgChartOptions();
	BgChart *bg_chart_;
	QChartView *bg_view_;
	QComboBox *bg_plot_options_;
	QGridLayout *bg_plot_layout_;
	QStringList *q_headers_;
	QWidget *bg_widget_;
	ScenarioData *data_container_;
	std::string y_header_;
};
}
#endif //BIOGEARSUI_BGCHART_DRIVER_H