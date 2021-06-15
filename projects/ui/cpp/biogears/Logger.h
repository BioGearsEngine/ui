#pragma once

#define WINDOWS_LEAN_AND_MEAN

#include <string>
#include <memory>

#include <QObject>
#include <QString>
#include <qtextstream.h>
#ifdef ERROR
#undef  ERROR 
#endif

#include <biogears/cdm/utils/Logger.h>
class QtLogForward : public QObject, public biogears::LoggerForward {
  Q_OBJECT

public:

  QtLogForward(QObject* parent = nullptr);
  ~QtLogForward() = default;
  void Debug(const char* msg) const final;
  void Info(const char* msg) const final;
  void Warning(const char* msg) const final;
  void Error(const char* msg) const final;
  void Fatal(const char* msg) const final;

signals:
  void messageReceived(QString message) const;


private:
  QString _buffer;
  QTextStream _channel;
};

class QtLogger : public biogears::Logger {
  friend biogears::Loggable;

public:
  QtLogger(const QString& logFilename, biogears::IOManager iomanager);
  virtual ~QtLogger();

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
