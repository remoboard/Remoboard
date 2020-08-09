#ifndef MAINAPP_H
#define MAINAPP_H

#include <QApplication>
#include "mainwindow.h"
#include "util/ganalytics.h"

class MainApp : public QApplication
{
    Q_OBJECT
public:
    MainApp(int argc,char *argv[]);
    virtual ~MainApp();

    void trackAppEvent(const QString &action);

private slots:
    void onAnalyticsIsSendingChanged(bool sending);

private:
    std::shared_ptr<MainWindow> _window;
    std::shared_ptr<GAnalytics> _tracker;
};


#endif // MAINAPP_H
