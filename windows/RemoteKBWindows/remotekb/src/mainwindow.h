#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QAction>
#include <vector>
#include <memory>
#include "mytextedit.h"
#include "channel/channelclientfactory.h"

class MainApp;
class ChannelClient;

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

    void set_app(MainApp* app){ _app = app;}

    void connectionStatusChanged(const QString &status);
    void showStatus(const QString & log);
    void showBluetoothList( QStringList names);

private:
    void loadChannelClient();
    void loadMenuState();

    void selectBluetooth();
    void selectIPNetwork();

    void connectIPNetwork();
    void connectBluetooth();

    void onIPNetworkStatus(ChannelStatus statusType,const std::string &content, void *data);
    void onBluetoothStatus(ChannelStatus statusType,const std::string &content, void *data);

    void openWebsite();

    void loadInputModeState();

signals:
    void showStatusSignal(const QString & log);
    void showBluetoothListSignal(QStringList names);

private slots:
    void showStatusSlot(QString log);
    void showBluetoothListSlot(QStringList names);

    bool myTextKeyPressed(MyTextEdit *textEdit, MyTextKeyType key);
    void on_pushButtonSendMultiline_clicked();
    void on_actionIP_Network_triggered(bool checked);
    void on_actionBluetooth_triggered(bool checked);
    void on_textEditFast_textChanged();
    void on_pushButtonConnect_clicked();

//    void on_toolButtonToggleMultiline_clicked();

    void on_actionAbout_triggered();

    void on_actionWeibo_triggered();

    void on_actionUsage_triggered();

    void on_actionInstallPhone_triggered();

    void on_actionMailFeedback_triggered();

    void on_actionWebsite_triggered();

    void on_actionFollowWechat_triggered();

    void on_actionCheckUpdate_triggered();

    void on_actionStandard_Input_Mode_triggered();

    void on_actionMultiline_Input_Mode_triggered();

    void on_actionImmediate_Input_Mode_triggered();

private:
    Ui::MainWindow *ui;
    MainApp *_app;

    std::shared_ptr<ChannelClient> _client;

    struct Impl;
    std::shared_ptr<Impl> _imp;
};

#endif // MAINWINDOW_H
