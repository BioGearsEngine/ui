#pragma once
#include <QChart>
#include <ScenarioData.h>
#include <qlineseries.h>
#include <QtCharts/QValueAxis>

class BioGearsChart : public QtCharts::QChart
{
public:
	BioGearsChart(ScenarioData *bgData);
	~BioGearsChart();
	void SetQSeries();
	void UpdateBgChart(std::string &new_header);
private:
	ScenarioData *bg_data_;
	QtCharts::QLineSeries *bg_series_;
	std::string y_header_;

	QtCharts::QValueAxis *axis_x_;
	QtCharts::QValueAxis *axis_y_;
};

