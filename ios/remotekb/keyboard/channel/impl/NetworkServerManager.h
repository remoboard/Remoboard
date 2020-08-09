//
//  handler.hpp
//  keyboard
//
//  Created by everettjf on 2019/6/20.
//  Copyright © 2019 everettjf. All rights reserved.
//

#ifndef handler_hpp
#define handler_hpp

#import <Foundation/Foundation.h>

#include <memory>
#include <string>
#include <functional>
#include "../../../dep/logic/logic.hpp"

namespace rekb {
    class NetworkServerManager {
    private:
        struct Impl;
        std::shared_ptr<Impl> _imp;
        
        DeviceInfo _device_info;
    public:
        static NetworkServerManager & instance() {
            static NetworkServerManager o;
            return o;
        }
        NetworkServerManager();
        ~NetworkServerManager();
        
        void (^onConnectionCode)(const std::string & code, const std::string & ip);
        void (^onStatus)(const std::string & type, const std::string & data);
        void (^onMessage)(const std::string & type, const std::string & data);

        void start();
        void close();
        
        DeviceInfo & device_info() { return _device_info;}
        
    private:
        void showConnectionCode();
        void configMessage();
        void processMessage(void * handler,const std::string & command, const std::string & content);
        
    };
}
#endif /* handler_hpp */
