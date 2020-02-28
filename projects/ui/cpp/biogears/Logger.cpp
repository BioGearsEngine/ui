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
  QtLogForward UE4LogStream;
};
//-------------------------------------------------------------------------------

QtLogger::QtLogger(const QString& logFilename, const QString& working_dir)
  : biogears::Logger(logFilename.toStdString(), working_dir.toStdString())
  , _pimpl(std::make_unique<Implementation>())
{
  biogears::Logger::SetForward(&_pimpl->UE4LogStream);
}
//-------------------------------------------------------------------------------
QtLogger::~QtLogger()
{
  _pimpl = nullptr;
}

//-------------------------------------------------------------------------------
void QtLogger::Debug(const QString& msg, const QString& origin)
{
  biogears::Logger::Debug(msg.toStdString(), origin.toStdString());
}
//-------------------------------------Sc------------------------------------------
void QtLogger::Info(const QString& msg, const QString& origin)
{
  biogears::Logger::Info(msg.toStdString(), origin.toStdString());
}
//-------------------------------------------------------------------------------
void QtLogger::Warning(const QString& msg, const QString& origin)
{
  biogears::Logger::Warning(msg.toStdString(), origin.toStdString());
}
//-------------------------------------------------------------------------------
void QtLogger::Error(const QString& msg, const QString& origin)
{
  biogears::Logger::Error(msg.toStdString(), origin.toStdString());
}
//-------------------------------------------------------------------------------
void QtLogger::Fatal(const QString& msg, const QString& origin)
{
  biogears::Logger::Fatal(msg.toStdString(), origin.toStdString());
}
