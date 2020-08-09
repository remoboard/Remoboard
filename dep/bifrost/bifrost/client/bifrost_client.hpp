//
//  bifrost_client.hpp
//  bifrost-client
//
//  Created by everettjf on 2019/4/25.
//  Copyright © 2019 everettjf. All rights reserved.
//

#ifndef bifrost_client_hpp
#define bifrost_client_hpp

#include "bifrost_chat_client.hpp"
#include "../common/bifrost_config.hpp"

namespace bifrost {
    
    class client {
    private:
        std::thread _thread;
        std::shared_ptr<chat_client> _chat_client;
        boost::asio::io_context io_context;

    public:
        on_client_receive_message_callback on_receive_message;
        on_client_connect_callback on_connect;

        void run() {
            try
            {
                // endpoint
                tcp::resolver resolver(io_context);
                auto endpoints = resolver.resolve(config::value().client_connect_host,
                                                  std::to_string(config::value().chat_client_connect_port));
                
                // connect
                _chat_client = std::make_shared<chat_client>(io_context);
                _chat_client->on_receive_message = on_receive_message;
                _chat_client->on_connect = on_connect;
                _chat_client->connect(endpoints);
                
                // loop
                _thread = std::thread([this](){ this->io_context.run(); });
            }
            catch (std::exception& e)
            {
                std::cerr << "Exception: " << e.what() << "\n";
            }
        }
        
        void send(const chat_message& msg)
        {
            if (!_chat_client) {
                std::cerr << "null chat_client" <<std::endl;
                return;
            }
            _chat_client->send(msg);
        }

        void input_loop() {
            if (!_chat_client) {
                return;
            }
            
            char line[chat_message::max_body_length + 1];
            while (std::cin.getline(line, chat_message::max_body_length + 1)){
                send(chat_message(line));
            }
        }
        
        void close() {
            if (_chat_client) {
                _chat_client->close();
            }
        }
        void wait() {
            if(_thread.joinable()){
                _thread.join();
            }
        }
    };
}

#endif /* bifrost_client_hpp */
