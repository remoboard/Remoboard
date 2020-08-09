//
// Created by everettjf on 2019-09-29.
//

#include "httphandler.h"
#include "./dep/bifrost/http/httpserver.hpp"
#include "native-lib.h"
#include <stdio.h>

namespace rekb {
    struct HttpHandler::Impl {
        std::string rootDir = ".";
        std::string port = "7777";
    };

    HttpHandler::HttpHandler() : _imp(new Impl()) {

    }
    HttpHandler::~HttpHandler() {

    }

    void HttpHandler::setRootDir(const std::string & dir) {
        _imp->rootDir = dir;
    }

    void HttpHandler::setPort(const std::string & port) {
        _imp->port = port;
    }

    void HttpHandler::start() {
        stop();

        bifrost::HttpServer::instance().set_port(_imp->port);
        bifrost::HttpServer::instance().set_root_dir(_imp->rootDir);
        bifrost::HttpServer::instance().onMessage = [&](const std::string & msg) {

            std::string command;
            std::string content;
            bool res = deconstruct_message(msg, command, content);
            if (!res) {
                printf("error message : %s\n",msg.c_str());
                return;
            }

            postHttpNotification("message",command, content);
        };

        bifrost::HttpServer::instance().run();
    }

    void HttpHandler::stop() {
        bifrost::HttpServer::instance().close();
    }






}