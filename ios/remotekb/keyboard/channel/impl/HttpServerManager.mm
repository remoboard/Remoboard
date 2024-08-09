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
    
    NSMutableDictionary *ipv4Addresses = [NSMutableDictionary dictionaryWithCapacity:6];
    NSDictionary *allAddress = [Util getAllIPAddress];
    NSMutableSet *validAddressSet = [NSMutableSet set];
    for (NSString *key in allAddress) {
        NSString *value = allAddress[key];
        if ([key hasSuffix:@"/ipv4"]) {
            [ipv4Addresses setObject:value forKey:key];
            [validAddressSet addObject:value];
        }
    }
    [validAddressSet removeObject:@"127.0.0.1"];
    
    NSLog(@"all ipv4 addresses :");
    for ( NSString *key in ipv4Addresses) {
        NSLog(@"- %@ : %@", key, ipv4Addresses[key]);
    }
    
    
#define MAIN_IP_TYPE        @"en0/ipv4"
#define BACKUP_IP_TYPE      @"pdp_ip0/ipv4"
    
    // wifi ip
    NSString *defaultAddress = ipv4Addresses[MAIN_IP_TYPE] ?:@"";
    
    // celular ip
    if (defaultAddress.length == 0) {
        defaultAddress = ipv4Addresses[BACKUP_IP_TYPE] ?:@"";
    }
    
    // try others
    if (defaultAddress.length == 0) {
        if ([validAddressSet count] > 0) {
            defaultAddress = [validAddressSet anyObject];
        }
    }
    
    // print
    NSMutableSet *backupAddressSet = [validAddressSet mutableCopy];
    if (defaultAddress.length > 0) {
        [backupAddressSet removeObject:defaultAddress];
    }
    
    
    /*
     - ipsec6/ipv4 : 192.0.0.6
     - ipsec4/ipv4 : 192.0.0.6
     - ipsec0/ipv4 : 192.0.0.6
     - pdp_ip0/ipv4 : 10.11.12.129
     - en2/ipv4 : 169.254.188.175
     - lo0/ipv4 : 127.0.0.1
     - bridge100/ipv4 : 172.20.10.1
     */
    
    
    if (defaultAddress.length == 0) {
        if(onStatus) {
            onStatus("message","Wi-Fi not connected and failed to find valid IP address");
        }
    } else {
        NSString *defaultUrl = [NSString stringWithFormat:@"http://%@:%s",defaultAddress,httpPort];
        NSMutableString *backupUrls = [NSMutableString string];
        for (NSString *key in backupAddressSet) {
            [backupUrls appendFormat: @"http://%@:%s , ",key,httpPort];
        }
        
        NSString *message = [NSString stringWithFormat:@"Main: %@\nBackup: %@", defaultUrl, backupUrls];
        NSLog(@"message = %@", message);
        
        if(onStatus) {
            onStatus("message",message.UTF8String);
            onStatus("copy-content",defaultUrl.UTF8String);
            onStatus("handoff-content",defaultUrl.UTF8String);
        }
    }
     
    bifrost::HttpServer::instance().run();
}

void HttpServerManager::close() {
    bifrost::HttpServer::instance().close();
}

}
