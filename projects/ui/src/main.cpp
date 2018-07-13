#include <main.h>

#include <QMainWindow>
#include <QApplication>
#include <QPushButton>
#include <QtCharts>
#include <ScenarioData.h>
#include <BgChartDriver.h>


int main( int argc, char * argv[] )
{

	QApplication app (argc, argv);

	QMainWindow *mainWin = new QMainWindow();
	mainWin->resize(1500, 750);

	//Set up a chart driver to display graph.  Right now everything is set in the driver constructor since we
	//aren't doing anything dynamically and this is just an example.  The default is plotting the Heart Rate in
	//BasicStandard
	BgChartDriver *chartDriver = new BgChartDriver();
	mainWin->setCentralWidget(chartDriver->DisplayBgChart());
	mainWin->show();

	return app.exec();
}

