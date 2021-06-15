#include "Logger.h"
#include <biogears/io/io-manager.h>

#include <QDebug>
#include <QLoggingCategory>
#include <QString>

void QtLogForward::Debug(char const* msg) const
{
  messageReceived(QString("<font color=#ff0000ff>%1</font>\n").arg(msg));
}
//-------------------------------------------------------------------------------
void QtLogForward::Info(char const* msg) const
{
  messageReceived(QString("<color=#ffaaaaaa>%1</color>\n").arg(msg));
}
//-------------------------------------------------------------------------------
void QtLogForward::Warning(char const* msg) const
{
  messageReceived(QString("<color=#ffffff00>%1</color>\n").arg(msg));
}
//-------------------------------------------------------------------------------
void QtLogForward::Error(char const* msg) const
{

  messageReceived(QString("<color=#ffff0000>%1</color>\n").arg(msg));
}
//-------------------------------------------------------------------------------
void QtLogForward::Fatal(char const* msg) const
{
  messageReceived(QString("<color=#ffff66cc>%1</color>\n").arg(msg));
}
//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
QtLogForward::QtLogForward(QObject* parent)
  : QObject(parent)
  , _buffer()
  , _channel(&_buffer)
{
}

//-------------------------------------------------------------------------------
struct QtLogger::Implementation {
  QtLogForward Qt5LogStream;
};
//-------------------------------------------------------------------------------

QtLogger::QtLogger(const QString& logFilename, biogears::IOManager  iomanager)
  : biogears::Logger(logFilename.toStdString(), iomanager)
  , _pimpl(std::make_unique<Implementation>())
{
  biogears::Logger::SetForward(&_pimpl->Qt5LogStream);
}
//-------------------------------------------------------------------------------
QtLogger::~QtLogger()
{
  _pimpl = nullptr;
}

