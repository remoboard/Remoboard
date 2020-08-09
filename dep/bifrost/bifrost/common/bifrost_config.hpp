//
//  bifrost_config.hpp
//  bifrost-server
//
//  Created by everettjf on 2019/4/26.
//  Copyright © 2019 everettjf. All rights reserved.
//

#ifndef bifrost_config_hpp
#define bifrost_config_hpp

#include <stdio.h>
#include <string>

namespace bifrost {
    class config {
    public:
        std::string client_connect_host = "localhost";

        int chat_server_listen_port = 2999;
        int chat_client_connect_port = chat_server_listen_port;

        int file_server_listen_port = 2998;
        int file_client_connect_port = file_server_listen_port;
        
        static config & value(){
            static config o;
            return o;
        }
    };
    
}

#endif /* bifrost_config_hpp */
