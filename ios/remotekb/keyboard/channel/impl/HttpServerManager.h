//
//  HttpServerManager.h
//  keyboard
//
//  Created by everettjf on 2019/9/29.
//  Copyright © 2019 everettjf. All rights reserved.
//


#ifndef httphandler_hpp
#define httphandler_hpp


#include <memory>
#include <string>
#include <functional>
#include "../../../dep/logic/logic.hpp"


namespace rekb {
class HttpServerManager {
private:
    struct Impl;
    std::shared_ptr<Impl> _imp;
public:
    static HttpServerManager & instance() {
        static HttpServerManager o;
        return o;
    }
    
    HttpServerManager();
    ~HttpServerManager();
    
    void (^onStatus)(const std::string & type, const std::string & data);
    void (^onMessage)(const std::string & type, const std::string & data);

    void start();
    void close();
};

}


#endif
