#pragma once
#include <QtCharts>
#include <ScenarioData.h>
#include <BgChart.h>

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