//
//  httpserver.hpp
//  httpdemo
//
//  Created by everettjf on 2019/9/22.
//  Copyright © 2019 everettjf. All rights reserved.
//

#ifndef bifrosthttpserver_hpp
#define bifrosthttpserver_hpp

#include <memory>
#include <string>
#include <functional>

namespace bifrost {
    class HttpServer {
    public:
        static HttpServer & instance();
        
        std::function<void(const std::string&)> onMessage;
        
        void set_root_dir(const std::string & dir);
        void set_port(const std::string & port);
        
        void run();
        void close();
        
        void broadcast(const std::string & data);
        
        void _broadcast(void *pnc,const std::string & data);
        void _event_handler(void *pnc, int ev, void *ev_data);
        void _handle_api( void *nc,  void *hm);

    private:
        HttpServer();
        ~HttpServer();
        
        void internalRun();

    private:
        struct Impl;
        std::shared_ptr<Impl> _impl;
    };
}



#endif /* bifrosthttpserver_hpp */
