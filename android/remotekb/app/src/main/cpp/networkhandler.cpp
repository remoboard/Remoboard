//
// Created by everettjf on 2019-06-22.
//

#include "networkhandler.h"
#include "syslog.h"

#include "networkhandler.h"
#include <thread>
#include "./dep/bifrost/server/bifrost_server.hpp"
#include "./dep/bifrost/server/bifrost_file_server.hpp"
#include "./dep/logic/json.hpp"
#include <boost/algorithm/string/predicate.hpp>
#include <boost/lexical_cast.hpp>
#include <iostream>
#include "native-lib.h"

namespace rekb {

    void sendMessage(bifrost::chat_session_handler *session, const std::string & command, const std::string & content) {
        if (!session){
            return;
        }

        session->send(bifrost::chat_message(rekb::construct_message(command,content)));
    }

    struct NetworkHandler::Impl {
        std::shared_ptr<bifrost::server> server;
        std::thread thread;
    };


    NetworkHandler::NetworkHandler(): _imp(std::make_shared<Impl>()){

    }

    NetworkHandler::~NetworkHandler(){

    }

    void NetworkHandler::start() {
        stop();

        // port
        bifrost::config::value().chat_server_listen_port = 6999;
        bifrost::config::value().chat_client_connect_port = 6999;

        _imp->server = std::make_shared<bifrost::server>();

        // config user defined message
        configMessage();

        // run server
        if (_imp->thread.joinable()) {
            _imp->thread.join();
        }
        _imp->thread = std::thread([this]() {
            std::string error_info;
            if(!_imp->server->run(error_info)){
                LOGD("--------------------------RKB Error------------------------------");
                std::string error_str = "server start failed : " +  error_info;
                LOGD("%s",error_str.c_str());
                LOGD("---------------------------------------------------------------------");
                return;
            }

            LOGD("server running");

            _imp->server->wait();

            LOGD("server stopped");
        });

        LOGD("server started");
    }

    void NetworkHandler::stop() {
        if (_imp->server) {
            _imp->server->close();
        }

        if (_imp->thread.joinable()) {
            _imp->thread.join();
        }
    }

    void NetworkHandler::configMessage() {
        _imp->server->on_session_created =  [this](bifrost::chat_session_handler *session) {
            session->send(bifrost::chat_message(rekb::construct_message("hello", "")));
            postSocketNotification("status", "connected", "");
        };
        _imp->server->on_session_closed =  [this](bifrost::chat_session_handler *session) {
            postSocketNotification("status", "disconnected", "");
        };

        _imp->server->on_receive_message = [this](const bifrost::chat_message& msg, bifrost::chat_session_handler *session) {
            std::string message = msg.get_string();

            LOGD("receive:%s", message.c_str());

            std::string command;
            std::string content;
            if(! rekb::deconstruct_message(message, command, content)) {
                LOGD("failed to deconstruct message");
                return;
            }

            LOGD("command : %s", command.c_str());
            LOGD("content : %s", content.c_str());

            processMessage(session,command,content);

        };
    }

    void NetworkHandler::processMessage(void * handler,const std::string & command, const std::string & content)
    {
        bifrost::chat_session_handler *session = static_cast<bifrost::chat_session_handler *>(handler);

        if (command == "hello"){
            LOGD("connected to desktop");
            session->send(bifrost::chat_message(rekb::construct_message("device-info", _device_info.to_json())));
            postSocketNotification("message", "connected", "");
        } else if (command == "ping") {
            session->send(bifrost::chat_message(rekb::construct_message("pong", "")));
        } else {
            postSocketNotification("message", command.c_str(), content.c_str());
        }
    }

}
