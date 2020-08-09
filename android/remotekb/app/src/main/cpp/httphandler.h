//
// Created by everettjf on 2019-09-29.
//

#ifndef REMOTEKB_HTTPHANDLER_H
#define REMOTEKB_HTTPHANDLER_H

#include <memory>
#include <string>
#include "./dep/logic/logic.hpp"


namespace rekb {

class HttpHandler {
private:
    struct Impl;
    std::shared_ptr<Impl> _imp;
public:
    static HttpHandler & instance() {
        static HttpHandler o;
        return o;
    }
    HttpHandler();
    ~HttpHandler();

    void setRootDir(const std::string & dir);
    void setPort(const std::string & port);

    void start();
    void stop();

};

}


#endif //REMOTEKB_HTTPHANDLER_H
