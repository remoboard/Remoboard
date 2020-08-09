#include "util.h"
#include "../dep/logic/anybase.h"

QString Util::connectionCode2IpAddress(const QString &code)
{
    if (code.length() == 0) {
        return "";
    }

    QString lowerCode = code.toLower();

    if (lowerCode.at(0) == "x") {
        // x??
        // ->
        // 192.168.?.?

        QString rightPart = lowerCode.right(lowerCode.length() - 1);
        long decimalCode = anybase::AnyBase2Decimal(rightPart.toStdString(), 32);
        if (decimalCode == -1) {
            return "";
        }
        long p3 = (decimalCode >> 8) & 0xff;
        long p4 = (decimalCode) & 0xff;
        return QString("192.168.%1.%2").arg(p3).arg(p4);
    } else {

        long decimalCode = anybase::AnyBase2Decimal(lowerCode.toStdString(), 32);
        if (decimalCode == -1) {
            return "";
        }
        return Util::decimal2IpAddress(decimalCode);
    }
}

QString Util::decimal2IpAddress(long code)
{
    long p1 = (code >> 24) & 0xff;
    long p2 = (code >> 16) & 0xff;
    long p3 = (code >> 8) & 0xff;
    long p4 = (code) & 0xff;
    return QString("%1.%2.%3.%4").arg(p1).arg(p2).arg(p3).arg(p4);
}
