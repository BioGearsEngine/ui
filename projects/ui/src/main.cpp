#include <main.h>

#include <QCoreApplication>
#include <QApplication>
#include <QPushButton>

#include <QDebug>

int main( int argc, char * argv[] )
{
 QApplication app (argc, argv);

 QPushButton button ("Hello world !");
 button.show();

 return app.exec();
}

