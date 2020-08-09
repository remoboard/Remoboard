#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "mainapp.h"
#include <QMessageBox>
#include "kbsetting.h"
#include <QDebug>
#include "util/util.h"
#include <QDesktopServices>

struct MainWindow::Impl {

};

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow),
    _imp(std::make_shared<Impl>())
{
    ui->setupUi(this);

    setWindowTitle(tr("Remoboard"));

    connect(this, SIGNAL(showStatusSignal(QString)), this, SLOT(showStatusSlot(QString)));
    connect(this, SIGNAL(showBluetoothListSignal(QStringList)), this, SLOT(showBluetoothListSlot(QStringList)));

    connect(ui->textEditStandard,SIGNAL(myTextKeyPressed(MyTextEdit *,MyTextKeyType)),this,SLOT(myTextKeyPressed(MyTextEdit *, MyTextKeyType)));
    connect(ui->textEditFast,SIGNAL(myTextKeyPressed(MyTextEdit *,MyTextKeyType)),this,SLOT(myTextKeyPressed(MyTextEdit *, MyTextKeyType)));
    connect(ui->textEditMultiline,SIGNAL(myTextKeyPressed(MyTextEdit *,MyTextKeyType)),this,SLOT(myTextKeyPressed(MyTextEdit *, MyTextKeyType)));

    ui->actionIP_Network->setChecked(true);
    ui->actionBluetooth->setChecked(false);

    loadChannelClient();
    loadMenuState();

    QString connCode = KBSetting::instance().readSavedConnCode();
    if (connCode.length() > 0) {
        ui->plainTextEditConnCode->setPlainText(connCode);
    }

    loadInputModeState();

    if (KBSetting::instance().isBluetooth()) {
        ui->stackedWidgetChannel->setCurrentIndex(1);
    } else {
        ui->stackedWidgetChannel->setCurrentIndex(0);
    }
}

MainWindow::~MainWindow()
{
    if (_client) {
        _client->close();
        _client.reset();
    }

    delete ui;
}

void MainWindow::showStatus(const QString &log)
{
    emit showStatusSlot(log);
}

void MainWindow::showBluetoothList(QStringList names)
{
    emit showBluetoothListSignal(names);
}

void MainWindow::showStatusSlot(QString log)
{
    ui->labelStatus->setText(log);
}

void MainWindow::showBluetoothListSlot(QStringList names)
{
    ui->comboBoxBluetoothList->clear();
    ui->comboBoxBluetoothList->addItems(names);
}

bool MainWindow::myTextKeyPressed(MyTextEdit *textEdit, MyTextKeyType key)
{
    if (textEdit == ui->textEditStandard) {
        // Standard Input Mode
        if (textEdit->toPlainText().length() == 0) {
            switch (key) {
                case MyTextKeyType::Return: {
                    _client->send("input","\n");
                    return true; // ignore
                }
                case MyTextKeyType::Delete: {
                    _client->send("input-delete","");
                    break;
                }
                case MyTextKeyType::Left: {
                    _client->send("move-left","");
                    break;
                }
                case MyTextKeyType::Right: {
                    _client->send("move-right","");
                    break;
                }
                case MyTextKeyType::Up: {
                    _client->send("move-up","");
                    break;
                }
                case MyTextKeyType::Down: {
                    _client->send("move-down","");
                    break;
                }
            }
        } else {
            switch (key) {
                case MyTextKeyType::Return: {
                    _client->send("input",textEdit->toPlainText().toStdString());
                    textEdit->setPlainText("");
                    return true; // ignore
                }
            }
        }


    } else if (textEdit == ui->textEditFast) {
        // Immediate Input Mode
        switch (key) {
            case MyTextKeyType::Return: {
                _client->send("input","\n");
                break;
            }
            case MyTextKeyType::Delete: {
                _client->send("input-delete","");
                break;
            }
            case MyTextKeyType::Left: {
                _client->send("move-left","");
                break;
            }
            case MyTextKeyType::Right: {
                _client->send("move-right","");
                break;
            }
            case MyTextKeyType::Up: {
                _client->send("move-up","");
                break;
            }
            case MyTextKeyType::Down: {
                _client->send("move-down","");
                break;
            }
        }

    } else {
        // Multiline Input Mode
        switch (key) {
            case MyTextKeyType::Delete: {
                if (ui->textEditMultiline->toPlainText().isEmpty()) {
                    _client->send("input-delete","");
                }
                break;
            }
            case MyTextKeyType::Left: {
                if (ui->textEditMultiline->toPlainText().isEmpty()) {
                    _client->send("move-left","");
                }
                break;
            }
            case MyTextKeyType::Right: {
                if (ui->textEditMultiline->toPlainText().isEmpty()) {
                    _client->send("move-right","");
                }
                break;
            }
            case MyTextKeyType::Up: {
                if (ui->textEditMultiline->toPlainText().isEmpty()) {
                    _client->send("move-up","");
                }
                break;
            }
            case MyTextKeyType::Down: {
                if (ui->textEditMultiline->toPlainText().isEmpty()) {
                    _client->send("move-down","");
                }
                break;
            }
        }
    }

    // default to DO NOT IGNORE
    return false;
}

void MainWindow::loadChannelClient()
{
    if (_client.get()) {
        _client->close();
        _client.reset();
    }

    if (KBSetting::instance().isBluetooth()) {
        _client = ChannelClientFactory::create(ChannelType::BlueTooth);
    } else {
        _client = ChannelClientFactory::create(ChannelType::IPNetwork);
    }
    _client->onStatus = [&](ChannelType channelType,ChannelStatus statusType,const std::string &content, void *data) {
        qDebug() << "channelType:" << (int)channelType << ",statusType:" << (int)statusType << ",content:" << content.c_str() ;

        if (channelType == ChannelType::IPNetwork) {
            this->onIPNetworkStatus(statusType,content,data);
        } else {
            this->onBluetoothStatus(statusType,content,data);
        }
    };
    _client->start();

}


void MainWindow::selectBluetooth() {

    ui->actionIP_Network->setChecked(false);
    ui->actionBluetooth->setChecked(true);

    KBSetting::instance().setBluetooth(true);
    ui->stackedWidgetChannel->setCurrentIndex(1);

    loadChannelClient();
}

void MainWindow::selectIPNetwork() {

    ui->actionIP_Network->setChecked(true);
    ui->actionBluetooth->setChecked(false);

    KBSetting::instance().setBluetooth(false);

    ui->stackedWidgetChannel->setCurrentIndex(0);

    loadChannelClient();
}


void MainWindow::loadMenuState()
{
    if (KBSetting::instance().isBluetooth()) {
        selectBluetooth();
    } else {
        selectIPNetwork();
    }
}


void MainWindow::on_pushButtonSendMultiline_clicked()
{
    QString text = ui->textEditMultiline->toPlainText();
    if (text.isEmpty()) {
        return;
    }

    const int kPartLength = 56;
    int times = text.length() / kPartLength;
    int meta = text.length() % kPartLength;

    for (int idx = 0; idx < times + 1; ++idx) {

        if (meta != 0 && idx == times) {
            QString curText = text.mid(idx * kPartLength, meta);
            if(_client){
                _client->send("input",curText.toStdString());
            }
        } else {
            QString curText = text.mid(idx * kPartLength, kPartLength);
            if(_client){
                _client->send("input",curText.toStdString());
            }
        }
    }

    // todo check send succeed
    ui->textEditMultiline->setPlainText("");
}

void MainWindow::on_actionIP_Network_triggered(bool checked)
{
    selectIPNetwork();
}

void MainWindow::on_actionBluetooth_triggered(bool checked)
{
    selectBluetooth();
}

void MainWindow::on_textEditFast_textChanged()
{
    QString text = ui->textEditFast->toPlainText();
    if (text.isEmpty()) {
        return;
    }

    if(_client){
        _client->send("input",text.toStdString());
    }

    ui->textEditFast->setPlainText("");
}

void MainWindow::on_pushButtonConnect_clicked()
{
    if (KBSetting::instance().isBluetooth()) {
        connectBluetooth();
    } else  {
        connectIPNetwork();
    }
}

void MainWindow::connectIPNetwork()
{
    QString host = ui->plainTextEditConnCode->toPlainText();
    if (host.isEmpty()) {
        return;
    }

    QString ipAddress;
    if (host.indexOf(".") != -1) {
        // may be ipaddress
        QStringList parts = host.split(".");
        if (parts.length() != 4) {
            // incorrect ip address
            QMessageBox::warning(this,tr("Tip"),tr("Incorrect IP Address"));
            return;
        }

        // Yes , it is ip address
        KBSetting::instance().saveConnCode(host);
        ipAddress = host;
    } else {
        // may be conn code
        ipAddress = Util::connectionCode2IpAddress(host);
        if (ipAddress.length() == 0) {
            QMessageBox::warning(this,tr("Tip"),tr("Incorrect Connection Code"));
            return;
        }
        KBSetting::instance().saveConnCode(host);
    }

    if(_client){
        _client->connect(ipAddress.toStdString());
    }
}

void MainWindow::connectBluetooth()
{
    QString currentDeviceName = ui->comboBoxBluetoothList->currentText();
    if (currentDeviceName.isEmpty()) {
        return;
    }

    if(_client){
        _client->connect(currentDeviceName.toStdString());
    }
}

void MainWindow::onIPNetworkStatus(ChannelStatus statusType, const std::string &content, void *data)
{
    switch(statusType) {
    case ChannelStatus::ConnectStart : {
        showStatus(tr("Connecting"));
        break;
    }
    case ChannelStatus::ConnectConnected : {
        showStatus(tr("Connecting."));
        break;
    }
    case ChannelStatus::ConnectShakeHands : {
        showStatus(tr("Connecting.."));
        break;
    }
    case ChannelStatus::ConnectReady : {
        showStatus(tr("Connected, Enjoy Typing :)"));
        break;
    }
    case ChannelStatus::ConnectFailed : {
        showStatus(tr("Connect Failed"));
        break;
    }
    case ChannelStatus::ConnectClose : {
        showStatus(tr("Connection Close"));
        break;
    }
    }
}

void MainWindow::onBluetoothStatus(ChannelStatus statusType, const std::string &content, void *data)
{
    switch(statusType) {
    case ChannelStatus::ConnectStart : {
        showStatus(tr("Connecting"));
        break;
    }
    case ChannelStatus::ConnectConnected : {
        showStatus(tr("Connecting."));
        break;
    }
    case ChannelStatus::ConnectShakeHands : {
        showStatus(tr("Connecting.."));
        break;
    }
    case ChannelStatus::ConnectReady : {
        showStatus(tr("Connected, Enjoy Typing :)"));

        ui->textEditFast->setFocus();
        break;
    }
    case ChannelStatus::ConnectFailed : {
        showStatus(tr("Connect Failed"));
        break;
    }
    case ChannelStatus::ConnectClose : {
        showStatus(tr("Connection Close"));
        break;
    }
    case ChannelStatus::BluetoothUnsupported : {
        showStatus(tr("Bluetooth Unsupported"));
        break;
    }
    case ChannelStatus::BluetoothPowerOff : {
        showStatus(tr("Bluetooth PowerOff"));
        break;
    }
    case ChannelStatus::BluetoothScanning : {
        showStatus(tr("Bluetooth Scanning"));
        break;
    }
    case ChannelStatus::BluetoothServerList : {
        std::list<std::string> *items = static_cast<std::list<std::string>*>(data);

        QStringList names;
        for(auto & item : *items) {
            names.push_back(QString::fromStdString(item));
        }

        showBluetoothList(names);

        break;
    }
    }
}

void MainWindow::openWebsite()
{
    QDesktopServices::openUrl(QUrl("https://remoboard.app"));

}

void MainWindow::loadInputModeState()
{
    switch (KBSetting::instance().inputMode()) {
    case 0: {
        // Standard
        ui->stackedWidgetInputMode->setCurrentIndex(0);
        ui->actionStandard_Input_Mode->setChecked(true);
        ui->actionMultiline_Input_Mode->setChecked(false);
        ui->actionImmediate_Input_Mode->setChecked(false);

        QRect cur = this->geometry();
        this->setGeometry(cur.x(),cur.y(),cur.width(),120);
        break;
    }
    case 1:{
        // Multiline
        ui->stackedWidgetInputMode->setCurrentIndex(1);
        ui->actionStandard_Input_Mode->setChecked(false);
        ui->actionMultiline_Input_Mode->setChecked(true);
        ui->actionImmediate_Input_Mode->setChecked(false);

        QRect cur = this->geometry();
        this->setGeometry(cur.x(),cur.y(),cur.width(),180);
        break;
    }
    default: {
        // Immediate (2 or more)
        ui->stackedWidgetInputMode->setCurrentIndex(2);
        ui->actionStandard_Input_Mode->setChecked(false);
        ui->actionMultiline_Input_Mode->setChecked(false);
        ui->actionImmediate_Input_Mode->setChecked(true);

        QRect cur = this->geometry();
        this->setGeometry(cur.x(),cur.y(),cur.width(),120);
        break;
    }
    }

}


void MainWindow::on_actionAbout_triggered()
{
    QString info = QString("%1 (Remote Keyboard)\n\n"
                               "v%2\n\n"
                                "Written by everettjf\n\n"
                               "Copyright © 2019 everettjf. All rights reserved."
                               )
            .arg(_app->applicationName())
            .arg(_app->applicationVersion());

        QMessageBox::information(this,tr("About"),info);
}

void MainWindow::on_actionWeibo_triggered()
{
    QDesktopServices::openUrl(QUrl("https://weibo.com/everettjf"));
}

void MainWindow::on_actionUsage_triggered()
{
    openWebsite();
}

void MainWindow::on_actionInstallPhone_triggered()
{
    openWebsite();
}

void MainWindow::on_actionMailFeedback_triggered()
{
    QDesktopServices::openUrl(QUrl("mailto:everettjf@live.com?subject=RemoboardWindows", QUrl::TolerantMode));
}

void MainWindow::on_actionWebsite_triggered()
{
    openWebsite();
}

void MainWindow::on_actionFollowWechat_triggered()
{
    QDesktopServices::openUrl(QUrl("https://everettjf.github.io/bukuzao"));
}

void MainWindow::on_actionCheckUpdate_triggered()
{
    QDesktopServices::openUrl(QUrl("https://github.com/remoboard/remoboard.github.io/releases"));
}

void MainWindow::on_actionStandard_Input_Mode_triggered()
{
    KBSetting::instance().setInputMode(0);
    loadInputModeState();
}

void MainWindow::on_actionMultiline_Input_Mode_triggered()
{
    KBSetting::instance().setInputMode(1);
    loadInputModeState();
}

void MainWindow::on_actionImmediate_Input_Mode_triggered()
{
    KBSetting::instance().setInputMode(2);
    loadInputModeState();
}
