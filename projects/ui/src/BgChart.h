#pragma once
#include <QChart>
#include <ScenarioData.h>
#include <qlineseries.h>
#include <QtCharts/QValueAxis>

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

