#include "Logger.h"

#include <QDebug>
#include <QLoggingCategory>
#include <QString>

void QtLogForward::ForwardDebug(const std::string& msg, const std::string& origin)
{
  messageReceived(QString("<font color=#ff0000ff>%1</font>\n").arg(msg.c_str()));
}
//-------------------------------------------------------------------------------
void QtLogForward::ForwardInfo(const std::string& msg, const std::string& origin)
{
  messageReceived(QString("<color=#ffaaaaaa>%1</color>\n").arg(msg.c_str()));
}
//-------------------------------------------------------------------------------
void QtLogForward::ForwardWarning(const std::string& msg, const std::string& origin)
{
  messageReceived(QString("<color=#ffffff00>%1</color>\n").arg(msg.c_str()));
}
//-------------------------------------------------------------------------------
void QtLogForward::ForwardError(const std::string& msg, const std::string& origin)
{

  messageReceived(QString("<color=#ffff0000>%1</color>\n").arg(msg.c_str()));
}
//-------------------------------------------------------------------------------
void QtLogForward::ForwardFatal(const std::string& msg, const std::string& origin)
{
  messageReceived(QString("<color=#ffff66cc>%1</color>\n").arg(msg.c_str()));
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

QtLogger::QtLogger(const QString& logFilename, const QString& working_dir)
  : biogears::Logger(logFilename.toStdString(), working_dir.toStdString())
  , _pimpl(std::make_unique<Implementation>())
{
  biogears::Logger::SetForward(&_pimpl->Qt5LogStream);
}
//-------------------------------------------------------------------------------
QtLogger::~QtLogger()
{
  _pimpl = nullptr;
}

