#include "mainapp.h"
#include <QDesktopWidget>
#include <QTextCodec>
#include <thread>
#include <QStyle>
#include <QTranslator>
#include <QLocale>
#include <QDebug>

MainApp::MainApp(int argc,char *argv[])
: QApplication(argc,argv){
    setApplicationName("Remoboard");
    setOrganizationName("everettjf");
    setOrganizationDomain("remoboard.app");
    setApplicationVersion("1.2");
    setWindowIcon(QIcon(":remotekb.icns"));

    QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));


    qDebug() << QLocale::system().name();

    QString translationName;
    if (QLocale::system().name().contains("zh")) {
        translationName = "zh.qm";
    } else  {
        translationName = "en.qm";
    }

    QTranslator translator;
    if (translator.load(translationName, ":/translations")) {
        installTranslator(&translator);
    }

    _window = std::make_shared<MainWindow>();
    _window->set_app(this);
    _window->show();

    _tracker = std::make_shared<GAnalytics>("UA-139398409-5");
    QObject::connect(_tracker.get(), SIGNAL(isSendingChanged(bool)), this, SLOT(onAnalyticsIsSendingChanged(bool)));

    _tracker->setSendInterval(5 * 1000);
    trackAppEvent("app-start");

    _window->setGeometry(
        QStyle::alignedRect(
            Qt::LeftToRight,
            Qt::AlignCenter,
            _window->size(),
            this->desktop()->availableGeometry()
        )
    );
}


MainApp::~MainApp(){

}

void MainApp::onAnalyticsIsSendingChanged(bool sending)
{
    if (sending){
        return;
    }

    printf("analytics sent\n");
}

void MainApp::trackAppEvent(const QString &action)
{
    if(!_tracker){
        return;
    }
    _tracker->sendEvent("app",action);
}
