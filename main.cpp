// main.cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include "SerialReader.h"
#include <QIcon>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Material");


    // Create and register application name and organization
    app.setApplicationName("Drone Simulator");
    app.setOrganizationName("PFA2");
    app.setWindowIcon(QIcon(":/icons/drone.png"));


    // Create and expose SerialReader to QML
    SerialReader serialReader;

    QQmlApplicationEngine engine;

    // Register C++ types to QML
    engine.rootContext()->setContextProperty("serialReader", &serialReader);

    const QUrl url(QStringLiteral("qrc:/qml/DashboardWindow.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
