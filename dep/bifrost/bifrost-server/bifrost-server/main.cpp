//
//  main.cpp
//  bifrost-server
//
//  Created by everettjf on 2019/4/25.
//  Copyright © 2019 everettjf. All rights reserved.
//

#include <iostream>
#include "../../bifrost/server/bifrost_server.hpp"
#include "../../bifrost/server/bifrost_file_server.hpp"
#include "../../bifrost/common/bifrost_util.hpp"

int main(int argc, const char * argv[]) {
    
    bifrost::config::value().chat_server_listen_port = 6999;
    
    bifrost::server server;
    server.on_session_created  = [&server](bifrost::chat_session_handler *session) {
        
    };
    server.on_receive_message = [&server](const bifrost::chat_message& msg, bifrost::chat_session_handler *session) {
        std::cout<< "receive:" << msg.get_string() << std::endl;

        session->send(bifrost::chat_message("hello am server"));
    };
    server.run();
    server.wait();
    
    
//    std::thread t = std::thread([&]() {
//
//        bifrost::file_server file_server;
//        file_server.on_receive_file_info = [](const bifrost::file_message::file_info & file_info, std::string& local_savepath) {
//            local_savepath = "/Users/everettjf/tmp/recv/" + bifrost::get_file_name_from_path(file_info.path);
//        };
//        file_server.run();
//
////        file_server.recv_file();
//
//        file_server.send_file({
//            "/Users/everettjf/tmp/client.cpp",
//            "/Users/everettjf/tmp/enwik8.txt",
//            "/Users/everettjf/tmp/send.txt",
//            "/Users/everettjf/tmp/server.cpp",
//            "/Users/everettjf/tmp/enwik8copy.txt",
//            "/Users/everettjf/tmp/enwik8copy2.txt",
//            "/Users/everettjf/tmp/enwik8.txt.gz"
//        });
//    });
//    t.join();
    
    return 0;
}
