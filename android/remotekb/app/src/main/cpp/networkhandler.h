//
// Created by everettjf on 2019-06-22.
//

#ifndef REMOTEKB_NETWORKHANDLER_H
#define REMOTEKB_NETWORKHANDLER_H

#include <memory>
#include <string>
#include "./dep/logic/logic.hpp"

namespace rekb {
    class NetworkHandler {
    private:
        struct Impl;
        std::shared_ptr<Impl> _imp;
        rekb::DeviceInfo _device_info;
    public:
        static NetworkHandler & instance() {
            static NetworkHandler o;
            return o;
        }
        NetworkHandler();
        ~NetworkHandler();

        void start();
        void stop();


    private:
        void configMessage();
        void processMessage(void * handler,const std::string & command, const std::string & content);

    };
}

#endif //REMOTEKB_NETWORKHANDLER_H
