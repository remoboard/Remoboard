//
//  HttpServerManager.m
//  keyboard
//
//  Created by everettjf on 2019/9/29.
//  Copyright © 2019 everettjf. All rights reserved.
//

#import "HttpServerManager.h"
#import <Foundation/Foundation.h>
#include "../../../dep/bifrost/http/httpserver.hpp"
#include <thread>
#include "../../util/Util.h"
#include "../../../dep/logic/logic.hpp"

namespace rekb {


struct HttpServerManager::Impl {
    
};

HttpServerManager::HttpServerManager() :_imp(new Impl()){
    
}

HttpServerManager::~HttpServerManager() {
    
}

void HttpServerManager::start() {
    close();
    
    NSString *siteRoot = [[NSBundle mainBundle] pathForResource:@"site" ofType:@"bundle"];
    NSLog(@"site root = %@\n",siteRoot);

    const char *httpPort = "7777";
    
    bifrost::HttpServer::instance().set_port(httpPort);
    bifrost::HttpServer::instance().set_root_dir(siteRoot.UTF8String);
    bifrost::HttpServer::instance().onMessage = [&](const std::string & msg) {
        
        std::string command;
        std::string content;
        bool res = deconstruct_message(msg, command, content);
        if (!res) {
            printf("error message : %s\n",msg.c_str());
            return;
        }
        
        if (onMessage) {
            onMessage(command,content);
        }
    };
    
    NSString *ipAddress = [Util currentIPAddress];
    if (ipAddress.length == 0) {
        if(onStatus) {
            onStatus("message","Wi-Fi not connected");
        }
    } else {
        NSString *httpUrl = [NSString stringWithFormat:@"http://%@:%s",ipAddress,httpPort];
        if(onStatus) {
            onStatus("message",httpUrl.UTF8String);
            onStatus("copy-content",httpUrl.UTF8String);
            onStatus("handoff-content",httpUrl.UTF8String);
        }
    }
     
    bifrost::HttpServer::instance().run();
}

void HttpServerManager::close() {
    bifrost::HttpServer::instance().close();
}

}
