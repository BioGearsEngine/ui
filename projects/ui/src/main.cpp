#include <main.h>

#include <QMainWindow>
#include <QApplication>
#include <QPushButton>
#include <QtCharts>
#include <ScenarioData.h>
#include <BioGearsChart.h>


int main( int argc, char * argv[] )
{

	QApplication app (argc, argv);

	QMainWindow *mainWin = new QMainWindow();
	mainWin->resize(1500, 750);
	
	//For now, specify which scenario you want.  We should let the user select this in the future.
	std::string basic = std::string("D:\\BioGears2\\core\\build-vc15\\runtime\\Scenarios\\Patient\\BasicStandardResults.csv"); 
	
	//Create a Scenario Data object--constructor requires the name of the file
	ScenarioData *dataContainer = new ScenarioData(basic);

	//Use getHeaders method to pull the column headers (i.e. HR, RR, etc) to put in a combo box (drop down menu)
	std::vector<std::string> stdHeaders = dataContainer->getHeaders();
	QStringList *qHeaders = new QStringList();

	//getHeaders method returns a std vector, but combobox wants a QtStringList
	//In the interest of not mixing Qt stuff everywhere, convert here (instead of in dataContainer class)
	for (auto str:stdHeaders)
	{
		qHeaders->push_back(QString::fromStdString(str));
	}

	QComboBox *plotOptions = new QComboBox();
	plotOptions->addItems(*qHeaders);

	//Create a BioGears chart object--constructor needs the dataContainer
	BioGearsChart *bgChart = new BioGearsChart(dataContainer);
	
	///ToDo:  Send string from combo box to UpdateBgChart based on signal when combo box value changes
	// Use heart rate as an example until signal is created
	std::string yHeader = std::string("HeartRate(1/min)");
	bgChart->UpdateBgChart(yHeader);

	//Put bgChart into QtCharview Object
	QChartView *scenarioView = new QChartView(bgChart);

	//Set basic layout
	QGridLayout *plotLayout = new QGridLayout();
	plotLayout->addWidget(plotOptions, 0, 1, 1, 1);
	plotLayout->addWidget(scenarioView, 1, 0, 3, 3);

	//Get fancy with tabs and keep the HelloWorld button in one tab with the plot in another
	QTabWidget *tabHandler = new QTabWidget();
	QWidget *plotTab = new QWidget();
	QWidget *buttonTab = new QWidget();
	
	//Button Steven made
	QPushButton *button = new QPushButton("Hello World!", buttonTab);
	button->setGeometry(0, 0, 100, 50);
	
	plotTab->setLayout(plotLayout);

	tabHandler->addTab(buttonTab, "Hello World");
	tabHandler->addTab(plotTab, "Plot Test");

	//Make the tab device the core widget of the UI
	mainWin->setCentralWidget(tabHandler);
	mainWin->show();

	return app.exec();
}

