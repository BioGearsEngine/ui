#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQuickControls2/QQuickStyle>

#include "biogears/Logger.h"
#include "biogears/PatientConditions.h"
#include "biogears/PatientMetrics.h"
#include "biogears/PatientState.h"
#include "biogears/BioGearsData.h"
#include "biogears/Scenario.h"
#include "biogears/Substance.h"
#include "version.h"

#include "biogears/Timeline.h"
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
  qmlRegisterType<bio::Substance>("com.biogearsengine.ui.scenario", 1, 0, "Substance");
  qmlRegisterType<BioGearsData>("com.biogearsengine.ui.scenario", 1, 0, "PhysiologyModel");
  qmlRegisterType<QtLogForward>("com.biogearsengine.ui.scenario", 1, 0, "LogForward");

  qRegisterMetaType<PatientState>();
  QMetaType::registerEqualsComparator<PatientState>();
  qmlRegisterUncreatableType<PatientState>("com.biogearsengine.ui.scenario", 1, 0, "PatientState", "State of the Patient");

  qRegisterMetaType<PatientConditions>();
  QMetaType::registerEqualsComparator<PatientConditions>();
  qmlRegisterUncreatableType<PatientConditions>("com.biogearsengine.ui.scenario", 1,  0, "PatientConditions", "Conditions of the Patient");

  bio::Timeline timeline{ "Scenarios/Showcase", "AsthmaAttack.xml" };
  exit(0);
  engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));

    return app.exec();

  
}
