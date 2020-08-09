//
//  handler.cpp
//  keyboard
//
//  Created by everettjf on 2019/6/20.
//  Copyright © 2019 everettjf. All rights reserved.
//

#include "NetworkServerManager.h"
#include <thread>
#include "../../../dep/bifrost/server/bifrost_server.hpp"
#include "../../../dep/bifrost/server/bifrost_file_server.hpp"
#include "../../../dep/logic/json.hpp"
#include <boost/algorithm/string/predicate.hpp>
#include <boost/lexical_cast.hpp>
#include <iostream>
#include "../../util/Util.h"

void oclog(const char *str) {
    if(!str){
        return;
    }
    NSLog(@"%s",str);
}

namespace rekb {
    
    void sendMessage(bifrost::chat_session_handler *session, const std::string & command, const std::string & content) {
        if (!session){
            return;
        }
        
        session->send(bifrost::chat_message(construct_message(command,content)));
    }
    
    struct NetworkServerManager::Impl {
        std::shared_ptr<bifrost::server> server;
        std::thread thread;
        std::string connection_code;
        std::string ip_address;
    };
    
    
    NetworkServerManager::NetworkServerManager(): _imp(std::make_shared<Impl>()){
        
    }
    
    NetworkServerManager::~NetworkServerManager(){
        
    }
    
    void NetworkServerManager::start() {
        close();
        
        // new server
        _imp->server = std::make_shared<bifrost::server>();
        
        // port
        bifrost::config::value().chat_server_listen_port = 6999;

        // config user defined message
        configMessage();
        
        
        NSString *ip = [Util currentIPAddress];
        NSString *code = [Util ipAddress2ConnectionCode:ip];
        if (ip.length > 0) {
            _imp->connection_code = code.UTF8String;
            _imp->ip_address = ip.UTF8String;
            
            showConnectionCode();
        } else {
            if(onStatus){
                onStatus("waiting","Wi-Fi not connected");
            }
        }
        
        // run server
        if (_imp->thread.joinable()) {
            _imp->thread.join();
        }
        _imp->thread = std::thread([this]() {
            std::string error_info;
            if(!_imp->server->run(error_info)){
                oclog("--------------------------Remoboard Error------------------------------");
                std::string error_str = "server start failed : " +  error_info;
                oclog(error_str.c_str());
                oclog("---------------------------------------------------------------------");
                return;
            }
            
            std::cout << "server running" << std::endl;
            
            _imp->server->wait();
            
            std::cout << "server stopped" << std::endl;
        });
    }
    
    void NetworkServerManager::showConnectionCode() {
        if (onConnectionCode) {
            onConnectionCode(_imp->connection_code, _imp->ip_address);
        }
    }
    
    void NetworkServerManager::close() {
        if (_imp->server) {
            _imp->server->close();
            if (_imp->thread.joinable()) {
                _imp->thread.join();
            }
        }
    }
    
    void NetworkServerManager::configMessage() {
        _imp->server->on_session_created =  [this](bifrost::chat_session_handler *session) {
            session->send(bifrost::chat_message(construct_message("hello", "")));
        };
        _imp->server->on_session_closed =  [this](bifrost::chat_session_handler *session) {
            
            if(onStatus){
                onStatus("disconnected","");
            }
            showConnectionCode();
        };
        
        _imp->server->on_receive_message = [this](const bifrost::chat_message& msg, bifrost::chat_session_handler *session) {
            std::string message = msg.get_string();
            std::cout<< "receive:" << message << std::endl;
            
            std::string command;
            std::string content;
            if(! deconstruct_message(message, command, content)) {
                std::cout << "failed to deconstruct message" << std::endl;
                return;
            }
            std::cout << "command: " << command << std::endl;
            std::cout << "content: " << content << std::endl;
            
            processMessage(session,command,content);
            
        };
    }
    
    void NetworkServerManager::processMessage(void * handler,const std::string & command, const std::string & content)
    {
        bifrost::chat_session_handler *session = static_cast<bifrost::chat_session_handler *>(handler);
        
        if (command == "hello"){
            printf("connected to desktop\n");
            session->send(bifrost::chat_message(construct_message("device-info", _device_info.to_json())));
            if(onStatus){
                onStatus("connected","");
            }
        } else if (command == "ping") {
            session->send(bifrost::chat_message(construct_message("pong", "")));
        } else {
            if(onMessage) {
                onMessage(command,content);
            }
        }
    }
    
    
}
