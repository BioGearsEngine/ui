#ifndef BIOGEARSUI_WIDGETS_TEXT_EDIT_WINDOW_H
#define BIOGEARSUI_WIDGETS_TEXT_EDIT_WINDOW_H

#include <QMainWindow>

class QAction;
class QMenu;
class QPlainTextEdit;
class QSessionManager;


namespace biogears_ui {
class TextEditWindow : public QMainWindow {
  Q_OBJECT

public:
  TextEditWindow();

  void loadFile(const QString& fileName);
  
protected:
  void closeEvent(QCloseEvent* event) override;

private slots:
  void newFile();
  void open();
  bool save();
  bool saveAs();
  void about();
  void documentWasModified();
#ifndef QT_NO_SESSIONMANAGER
  void commitData(QSessionManager&);
#endif

private:
  void createActions();
  void createStatusBar();
  void readSettings();
  void writeSettings();
  bool maybeSave();
  bool saveFile(const QString& fileName);
  void setCurrentFile(const QString& fileName);
  QString strippedName(const QString& fullFileName);

  QPlainTextEdit* textEdit;
  QString curFile;
};
} //namespace biogears_ui

#endif //TEXT_EDIT_WINDOW
