//
//  bifrost_server.hpp
//  bifrost-server
//
//  Created by everettjf on 2019/4/25.
//  Copyright © 2019 everettjf. All rights reserved.
//

#ifndef bifrost_server_hpp
#define bifrost_server_hpp

#include "bifrost_chat_server.hpp"
#include "../common/bifrost_config.hpp"

namespace bifrost {
    
    class server {
    private:
        std::thread _thread;
        boost::asio::io_context io_context;
        std::vector<chat_server> _servers;
    public:
        on_server_receive_message_callback on_receive_message;
        on_server_chat_session_created_callback on_session_created;
        on_server_chat_session_closed_callback on_session_closed;

        bool run(std::string & error_info) {
            try{
                std::vector<int> ports{config::value().chat_server_listen_port};
                for (auto port : ports) {
                    tcp::endpoint endpoint(tcp::v4(), port);
                    _servers.emplace_back(io_context, endpoint);
                }
                
                for (auto &server : _servers) {
                    server.on_receive_message = on_receive_message;
                    server.on_session_created = on_session_created;
                    server.on_session_closed = on_session_closed;
                    server.listen();
                }
                
                _thread = std::thread([this](){
                    this->io_context.restart();
                    this->io_context.run();
                });
            }catch (std::exception& e){
                error_info = e.what();
                std::cerr << "Exception: " << e.what() << "\n";
                return false;
            }
            return true;
        }
        
        bool run() {
            std::string error_info;
            return run(error_info);
        }
        
        void close() {
            for (auto& server : _servers) {
                server.close();
            }
            io_context.stop();
        }
        
        void wait() {
            if (_thread.joinable()){
                _thread.join();
            }
        }
    };
    
    
}


#endif /* bifrost_server_hpp */
