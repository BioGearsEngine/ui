#ifndef BIOGEARSUI_BGCHART_H
#define BIOGEARSUI_BGCHART_H

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

#include <QChart>
#include <ScenarioData.h>
#include <qlineseries.h>
#include <QtCharts/QValueAxis>
namespace biogears_ui {
class BgChart : public QtCharts::QChart
{
public:
	BgChart();
	~BgChart();
	void SetQSeries(ScenarioData *data, std::string &y_header);
	void UpdateBgChart(ScenarioData *data, std::string &y_header);
private:
	QtCharts::QLineSeries *bg_series_;
	QtCharts::QValueAxis *axis_x_;
	QtCharts::QValueAxis *axis_y_;
};
}
#endif //BIOGEARSUI_BGCHART_H