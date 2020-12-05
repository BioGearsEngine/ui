#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQuickControls2/QQuickStyle>

#include "version.h"
#include <biogears/BioGearsData.h>
#include <biogears/EventTree.h>
#include <biogears/Logger.h>
#include <biogears/PatientConditions.h>
#include <biogears/PatientMetrics.h>
#include <biogears/PatientState.h>
#include <biogears/Scenario.h>
#include <biogears/engine/BioGearsPhysiologyEngine.h>
#include <biogears/version.h>

#include <QDIR>
#include <QStandardPaths>
void syncronize_runtime_directory(QDir source_directory, QDir destination_directory)
{
  qInfo() << "Installation Path : " << source_directory.absoluteFilePath(".");
  QDir installation_data_directory = source_directory.absoluteFilePath(QString("../runtime/%1").arg(bgui::rev_tag()));
  if (!installation_data_directory.exists()) {
    installation_data_directory = source_directory.absoluteFilePath(QString("../../runtime"));
    if (!installation_data_directory.exists()) {
      QMessageBox msgBox;
      msgBox.setText("Unable to find runtime directory. Installation may be corrupted!");
      msgBox.setIcon(QMessageBox::Critical);
      msgBox.exec();
      exit(1);
    }
  }
  QDirIterator it(installation_data_directory.absoluteFilePath("."), QStringList() << "*.csv" << "*.xml" << "*.xsd", QDir::Files, QDirIterator::Subdirectories);
  while (it.hasNext()) {
    QFileInfo current = it.next();
    auto relative_filepath = installation_data_directory.relativeFilePath(it.filePath());
    QDir relative_fragment = installation_data_directory.relativeFilePath(it.filePath()+"/..");
    // qInfo() << "Relative filepath : " << relative_filepath;
    // qInfo() << "Destination dirname : " << destination_directory.absoluteFilePath(relative_fragment.path());
    if (!destination_directory.exists(relative_fragment.path()))
    {
      // qInfo() << "Creating : " << destination_directory.filePath(relative_fragment.path());
      destination_directory.mkpath(relative_fragment.path());
    }
    if (current.isFile()) {
      // qInfo() << QString("Copying : %1 -> %2").arg(current.absoluteFilePath()).arg(destination_directory.filePath(relative_filepath));
      QFile::copy(current.absoluteFilePath(), destination_directory.filePath(relative_filepath));
    }
  }
}
int main(int argc, char* argv[])
{
  QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QApplication app(argc, argv);
  app.setOrganizationDomain("Applied Research Associates");
  app.setOrganizationName("https://biogearsengine.com");

  QQuickStyle::setStyle("Material");

  QDir installation_dir{ QCoreApplication::applicationDirPath() };
  QString app_directory = QString("Biogears/%1").arg(biogears::rev_tag_str());
  QDir runtime_directory{ QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) };

#ifdef BIOGEARS_EXPLORER_RELEASE_BUNDLE
  if (!runtime_directory.exists(app_directory)) {
    // qInfo() << "Absolute Path : " << runtime_directory.absoluteFilePath(app_directory);
    if (runtime_directory.mkpath(app_directory)) {
      syncronize_runtime_directory(installation_dir, runtime_directory.absoluteFilePath(app_directory));
    }
  } else {
    syncronize_runtime_directory(installation_dir, runtime_directory.absoluteFilePath(app_directory));
  }
  qInfo() << "Runtime Directory will be : " << runtime_directory.absoluteFilePath(app_directory);
  QDir::setCurrent(runtime_directory.absoluteFilePath(app_directory));
  try {
    auto test_engine = biogears::CreateBioGearsEngine("TestRun.log");
    if ( !test_engine->LoadState("states/DefaultMale@0s.xml") ) {
      runtime_directory.removeRecursively();
      runtime_directory.mkpath(app_directory);
      syncronize_runtime_directory(installation_dir, runtime_directory.absoluteFilePath(app_directory));
    }
    if (!test_engine->LoadState("states/DefaultMale@0s.xml")) {
      QMessageBox msgBox;
      msgBox.setText("Unable to restore runtime directory. Installation corrupted!");
      msgBox.setIcon(QMessageBox::Critical);
      msgBox.exec();
      exit(1);
    }
  } catch (...) {
    runtime_directory.removeRecursively();
    runtime_directory.mkpath(app_directory);
    syncronize_runtime_directory(installation_dir, runtime_directory.absoluteFilePath(app_directory));

    QMessageBox msgBox;
    msgBox.setText("Unknown exception. Restart application or reinstall application!");
    msgBox.setIcon(QMessageBox::Critical);
    msgBox.exec();
    exit(1);
  }
#endif

  QQmlApplicationEngine engine;

  qmlRegisterType<bgui::Scenario>("com.biogearsengine.ui.scenario", 1, 0, "Scenario");
  qmlRegisterType<PatientMetrics>("com.biogearsengine.ui.scenario", 1, 0, "PatientMetrics");
  qmlRegisterType<bgui::SystemInformation>("com.biogearsengine.ui.scenario", 1, 0, "Info");
  qmlRegisterType<BioGearsData>("com.biogearsengine.ui.scenario", 1, 0, "PhysiologyModel");
  qmlRegisterType<QtLogForward>("com.biogearsengine.ui.scenario", 1, 0, "LogForward");
  qmlRegisterType<Urinalysis>("com.biogearsengine.ui.scenario", 1, 0, "Urinalysis");
  qmlRegisterType<DataRequestTree>("com.biogearsengine.ui.scenario", 1, 0, "DataRequestModel");
  qmlRegisterType<bgui::EventTree>("com.biogearsengine.ui.scenario", 1, 0, "EventModel");
  qRegisterMetaType<PatientState>();
  QMetaType::registerEqualsComparator<PatientState>();
  qmlRegisterUncreatableType<PatientState>("com.biogearsengine.ui.scenario", 1, 0, "PatientState", "State of the Patient");
  qRegisterMetaType<Event>();
  qRegisterMetaType<PatientConditions>();
  QMetaType::registerEqualsComparator<PatientConditions>();
  qmlRegisterUncreatableType<PatientConditions>("com.biogearsengine.ui.scenario", 1, 0, "PatientConditions", "Conditions of the Patient");

  engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));

  return app.exec();
}
