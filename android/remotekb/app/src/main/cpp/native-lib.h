//
// Created by everettjf on 2019-06-23.
//

#ifndef REMOTEKB_NATIVE_LIB_H
#define REMOTEKB_NATIVE_LIB_H

#include <string>

void postSocketNotification(const std::string & type, const std::string & cmd, const std::string & data);
void postHttpNotification(const std::string & type, const std::string & cmd, const std::string & data);

#endif //REMOTEKB_NATIVE_LIB_H
