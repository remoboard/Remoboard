#ifndef KBSETTING_H
#define KBSETTING_H

#include <QString>

class KBSetting
{
public:
    KBSetting();

    static KBSetting & instance();
    bool isBluetooth();
    void setBluetooth(bool enable);

    int inputMode();
    void setInputMode(int mode);

    QString readSavedConnCode();
    void saveConnCode(const QString& code);
};

#endif // KBSETTING_H
