#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQuickControls2/QQuickStyle>

#include "biogears/PatientConditions.h"
#include "biogears/PatientMetrics.h"
#include "biogears/PatientState.h"
#include "biogears/Scenario.h"
#include "version.h"

int main(int argc, char* argv[])
{
  QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QGuiApplication app(argc, argv);

  QQuickStyle::setStyle("Material");

  QQmlApplicationEngine engine;

  qmlRegisterType<bio::Scenario>("com.biogearsengine.ui.scenario", 1, 0, "Scenario");
  qmlRegisterType<bio::SystemInformation>("com.biogearsengine.ui.scenario", 1, 0, "Info");

  qRegisterMetaType<PatientState>();
  QMetaType::registerEqualsComparator<PatientState>();
  qmlRegisterUncreatableType<PatientState>("com.biogearsengine.ui.scenario", 1, 0, "PatientState", "State of the Patient");
  qRegisterMetaType<PatientConditions>();
  QMetaType::registerEqualsComparator<PatientConditions>();
  qRegisterMetaType<PatientMetrics>();
  QMetaType::registerEqualsComparator<PatientMetrics>();

  engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));

  return app.exec();
}
