#ifndef UTIL_H
#define UTIL_H

#include <QString>

class Util
{
public:

    static QString connectionCode2IpAddress(const QString &code);
    static QString decimal2IpAddress(long code);
};

#endif // UTIL_H
