#include "BgChart.h"



BgChart::BgChart() : bg_series_(nullptr), axis_x_(nullptr), axis_y_(nullptr)
{
	
}


BgChart::~BgChart()
{
}

void BgChart::SetQSeries(ScenarioData *data, std::string &y_header)
{
	std::vector<double> xSeries = data->getXSeries();
	std::vector<double> ySeries = data->getYSeries();

	QVector<QPointF> *tempSeries = new QVector<QPointF>;

	for (unsigned int i = 0; i < xSeries.size(); i++)
	{
		QPointF holder;
		holder.setX(xSeries[i]);
		holder.setY(ySeries[i]);
		tempSeries->push_back(holder);
	}
	if(bg_series_==nullptr)
	{
		bg_series_ = new QtCharts::QLineSeries();
		bg_series_->append(tempSeries->toList());
	}
	else
	{
		//Documentation says this is faster than clear/append
		bg_series_->replace(*tempSeries);
	}
	bg_series_->setName(QString::fromStdString(y_header));
}

void BgChart::UpdateBgChart(ScenarioData *data, std::string &y_header)
{
	this->SetQSeries(data, y_header);
	this->addSeries(bg_series_);
	if (axis_x_ == nullptr)
		axis_x_ = new QtCharts::QValueAxis();
	if (axis_y_ == nullptr)
		axis_y_ = new QtCharts::QValueAxis();

	axis_x_->setMin(0.0);
	axis_x_->setMax(data->getXSeries().back());
	auto y_scale = std::minmax_element(data->getYSeries().begin(), data->getYSeries().end());   //return pair with min and max elements
	double y_range = *y_scale.second - *y_scale.first;
	double y_min = (*y_scale.first > 0.0 ? 0.0 : *y_scale.first - 0.25*y_range);
	double y_max = (*y_scale.second > 0.0 ? 1.25 * (*y_scale.second) : *y_scale.second + 0.25 * y_range);
	axis_y_->setMin(y_min);
	axis_y_->setMax(y_max);

	axis_x_->setTitleText("Time(s)");
	axis_y_->setTitleText(QString::fromStdString(y_header));

	this->setAxisX(axis_x_, bg_series_);
	this->setAxisY(axis_y_, bg_series_);
	this->legend()->setVisible(true);

}
