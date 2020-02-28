#pragma once
#include <biogears/cdm/utils/Logger.h>
#include <string>

#include <QObject>
#include <QString>
#include <qtextstream.h>

class QtLogForward : public QObject, public biogears::LoggerForward {
  Q_OBJECT

public:

  QtLogForward(QObject* parent = nullptr);
  ~QtLogForward() = default;
  void ForwardDebug(const std::string& msg, const std::string& origin) final;
  void ForwardInfo(const std::string& msg, const std::string& origin) final;
  void ForwardWarning(const std::string& msg, const std::string& origin) final;
  void ForwardError(const std::string& msg, const std::string& origin) final;
  void ForwardFatal(const std::string& msg, const std::string& origin) final;

signals:
  void messageReceived(QString message);


private:
  QString _buffer;
  QTextStream _channel;
};

class QtLogger : public biogears::Logger {
  friend biogears::Loggable;

public:
  QtLogger(const QString& logFilename, const QString& working_dir);
  virtual ~QtLogger();

  void Debug(const QString& msg, const QString& origin = TEXT(""));
  void Info(const QString& msg, const QString& origin = TEXT(""));
  void Warning(const QString& msg, const QString& origin = TEXT(""));
  void Error(const QString& msg, const QString& origin = TEXT(""));
  void Fatal(const QString& msg, const QString& origin = TEXT(""));

protected:
  using biogears::Logger::HasForward;
  using biogears::Logger::SetForward;

  using biogears::Logger::Debug;
  using biogears::Logger::Error;
  using biogears::Logger::Fatal;
  using biogears::Logger::Info;
  using biogears::Logger::Warning;

private:
  struct Implementation;
  std::unique_ptr<Implementation> _pimpl;
};
