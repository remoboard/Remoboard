//
//  main.cpp
//  bifrost-client
//
//  Created by everettjf on 2019/4/25.
//  Copyright © 2019 everettjf. All rights reserved.
//

#include <iostream>
#include "../../bifrost/client/bifrost_client.hpp"
#include "../../bifrost/client/bifrost_file_client.hpp"
#include "../../bifrost/common/bifrost_util.hpp"


int main(int argc, const char * argv[]) {
    

//    while(true){
    
    bifrost::config::value().chat_client_connect_port = 6999;
    bifrost::config::value().client_connect_host = "192.168.31.13";
//    bifrost::config::value().client_connect_host = "192.168.31.131";

    bifrost::client client;
    client.on_receive_message = [](const bifrost::chat_message& msg, bifrost::chat_client_handler *client){
        std::cout<< "receive:"<< msg.get_string() << std::endl;
    };
    client.run();
    std::cout << "running" << std::endl;
    std::cout << "input : "<<std::endl;
    client.input_loop();
    
//    client.send(bifrost::chat_message("hi hi hi"));
    client.wait();
    std::cout << "stopped" << std::endl;
        
//        usleep(2000*1000);
//    }
    
//    std::thread t = std::thread([]() {
//
//        for(int i = 0; i< 1; i++){
//            bifrost::file_client file_client;
//            file_client.run();
//
//            file_client.on_receive_file_info = [](const bifrost::file_message::file_info & file_info, std::string& local_savepath) {
//                local_savepath = "/Users/everettjf/tmp/recv/" + bifrost::get_file_name_from_path(file_info.path);
//            };
//
//            file_client.recv_file();
//
////
////            file_client.send_file({
////                "/Users/everettjf/tmp/client.cpp",
////                "/Users/everettjf/tmp/enwik8.txt",
////                "/Users/everettjf/tmp/send.txt",
////                "/Users/everettjf/tmp/server.cpp",
////                "/Users/everettjf/tmp/enwik8copy.txt",
////                "/Users/everettjf/tmp/enwik8copy2.txt",
////                "/Users/everettjf/tmp/enwik8.txt.gz"
////            });
//
////            file_client.close();
//
//            sleep(2);
//        }
//    });
//    t.join();
    
    return 0;
}
