//
//  bifrost_file_server.hpp
//  bifrost-server
//
//  Created by everettjf on 2019/4/25.
//  Copyright © 2019 everettjf. All rights reserved.
//

#ifndef bifrost_file_server_hpp
#define bifrost_file_server_hpp

#include "../common/bifrost_config.hpp"
#include "../common/bifrost_file.hpp"
#include <ctime>
#include <iostream>
#include <string>
#include <boost/asio.hpp>
#include <fstream>
#include <sstream>


namespace bifrost {
    class file_server : public file_handler {
    private:
        std::shared_ptr<boost::asio::ip::tcp::socket> _socket;
        boost::asio::io_service io_service;

    private:
        void do_accept() {
            unsigned short tcp_port = config::value().file_client_connect_port;
            boost::asio::ip::tcp::acceptor acceptor(io_service, boost::asio::ip::tcp::endpoint(boost::asio::ip::tcp::v4(), tcp_port));
            
            _socket = std::make_shared<boost::asio::ip::tcp::socket>(io_service);
            acceptor.accept(*_socket);
        }
    public:
        
        void run() {
            do_accept();
        }
        
        bool recv_file(){
            return file_handler::recv_file(*_socket);
        }
        
        bool send_file(const std::list<std::string> & files) {
            return file_handler::send_file(*_socket,files);
        }
        
    };
}


#endif /* bifrost_file_server_hpp */
