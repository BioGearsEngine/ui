#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQuickControls2/QQuickStyle>

#include "biogears/Scenario.h"
#include "biogears/Gadgets.h"

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    QQuickStyle::setStyle("Material");

    QQmlApplicationEngine engine;

    qmlRegisterType<bio::Scenario>("com.biogearsengine.ui.scenario", 1, 0, "Scenario");

    qRegisterMetaType<bio::State>();
    QMetaType::registerEqualsComparator<bio::State>();
    qRegisterMetaType<bio::Conditions>();
    QMetaType::registerEqualsComparator<bio::Conditions>();
    qRegisterMetaType<bio::Metrics>();
    QMetaType::registerEqualsComparator<bio::Metrics>();

    engine.load(QUrl(QStringLiteral("qrc:/Main.qml")));

    return app.exec();
}
