#include "kbsetting.h"
#include <QSettings>

KBSetting::KBSetting()
{

}

KBSetting &KBSetting::instance()
{
    static KBSetting o;
    return o;
}

bool KBSetting::isBluetooth()
{
    QSettings setting;
    return setting.value("bluetooth",false).toBool();
}

void KBSetting::setBluetooth(bool enable)
{
    QSettings setting;
    setting.setValue("bluetooth",enable);
}
int KBSetting::inputMode()
{
    QSettings setting;
    return setting.value("inputmode",false).toInt();
}

void KBSetting::setInputMode(int mode)
{
    QSettings setting;
    setting.setValue("inputmode",mode);
}

QString KBSetting::readSavedConnCode()
{
    QSettings setting;
    return setting.value("conncode").toString();
}

void KBSetting::saveConnCode(const QString &code)
{
    QSettings setting;
    setting.setValue("conncode",code);
}
