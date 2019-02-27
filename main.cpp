#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QCursor>

#include "appstate.h"
#include "qimageproxy.h"

int main(int argc, char *argv[])
{
  QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
  QGuiApplication app(argc, argv);

  // Start LED Matrix on its own QThread
  RenderThread thread;
  // Instantiate state to provide it as global variable in QML
  AppState appState(nullptr, &thread);

  // Remove cursor
  QCursor cursor(Qt::BlankCursor);
  QGuiApplication::setOverrideCursor(cursor);

  // Below is if you want to instantiate the object _in_ QML.
  // See: http://doc.qt.io/qt-5/qtqml-cppintegration-definetypes.html
  // qmlRegisterType<AppState>("com.leonardsouza", 1, 0, "AppState");
  qmlRegisterType<QImageProxy>("LeonardSouza", 1, 0, "QImageProxy");
  qmlRegisterUncreatableMetaObject(Brush::staticMetaObject, "LeonardSouza", 1, 0, "Brushes", "Access to enums & flags only");

  QQmlApplicationEngine engine;
  // See: http://doc.qt.io/qt-5/qtqml-cppintegration-contextproperties.html
  engine.rootContext()->setContextProperty("AppState", &appState);
  // Load up the QML
  engine.addImportPath(":/imports");
  engine.addImportPath(":/content");
  engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

  if (engine.rootObjects().isEmpty())
    return -1;

  return QGuiApplication::exec();
}
