#include "Logger.h"

#include <QString>
#include <QDebug>
#include <QLoggingCategory>


void QtLogForward::ForwardDebug(const std::string& msg, const std::string& origin)
{
  qDebug() << QString("[%s]: %s").arg(origin.c_str()).arg(msg.c_str());
}
//-------------------------------------------------------------------------------
void QtLogForward::ForwardInfo(const std::string& msg, const std::string& origin)
{
  qInfo() << QString("[%s]: %s").arg(origin.c_str()).arg(msg.c_str());
}
//-------------------------------------------------------------------------------
void QtLogForward::ForwardWarning(const std::string& msg, const std::string& origin)
{
  qWarning() << QString("[%s]: %s").arg(origin.c_str()).arg(msg.c_str());
}
//-------------------------------------------------------------------------------
void QtLogForward::ForwardError(const std::string& msg, const std::string& origin)
{
  qCritical() << QString("[%s]: %s").arg(origin.c_str()).arg(msg.c_str());
}
//-------------------------------------------------------------------------------
void QtLogForward::ForwardFatal(const std::string& msg, const std::string& origin)
{
  qFatal("[%s]: %s", origin.c_str(), msg.c_str());
}
//-------------------------------------------------------------------------------
struct QtLogger::Implementation
{
	QtLogForward UE4LogStream;
};
//-------------------------------------------------------------------------------

QtLogger::QtLogger(const QString& logFilename, const QString& working_dir)
	:biogears::Logger(logFilename.toStdString(), working_dir.toStdString())
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
//-------------------------------------------------------------------------------
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
//-------------------------------------------------------------------------------
