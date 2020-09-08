#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQuickControls2/QQuickStyle>

#include "biogears/Logger.h"
#include "biogears/PatientConditions.h"
#include "biogears/PatientMetrics.h"
#include "biogears/PatientState.h"
#include "biogears/BioGearsData.h"
#include "biogears/Scenario.h"
#include "version.h"

#include "biogears/EventTree.h"

int main(int argc, char* argv[])
{
  QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QApplication app(argc, argv);
  app.setOrganizationDomain("Applied Research Associates");
  app.setOrganizationName("https://biogearsengine.com");

  QQuickStyle::setStyle("Material");

  QQmlApplicationEngine engine;

  qmlRegisterType<bio::Scenario>("com.biogearsengine.ui.scenario", 1, 0, "Scenario");
  qmlRegisterType<PatientMetrics>("com.biogearsengine.ui.scenario", 1, 0, "PatientMetrics");
  qmlRegisterType<bio::SystemInformation>("com.biogearsengine.ui.scenario", 1, 0, "Info");
  qmlRegisterType<BioGearsData>("com.biogearsengine.ui.scenario", 1, 0, "PhysiologyModel");
  qmlRegisterType<QtLogForward>("com.biogearsengine.ui.scenario", 1, 0, "LogForward");
  qmlRegisterType<Urinalysis>("com.biogearsengine.ui.scenario", 1, 0, "Urinalysis");
  qmlRegisterType<DataRequestTree>("com.biogearsengine.ui.scenario", 1, 0, "DataRequestModel");
  qmlRegisterType<bio::EventTree>("com.biogearsengine.ui.scenario", 1, 0, "EventModel");
  qRegisterMetaType<PatientState>();
  QMetaType::registerEqualsComparator<PatientState>();
  qmlRegisterUncreatableType<PatientState>("com.biogearsengine.ui.scenario", 1, 0, "PatientState", "State of the Patient");

  qRegisterMetaType<PatientConditions>();
  QMetaType::registerEqualsComparator<PatientConditions>();
  qmlRegisterUncreatableType<PatientConditions>("com.biogearsengine.ui.scenario", 1,  0, "PatientConditions", "Conditions of the Patient");

  engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));


    return app.exec();

  
}
