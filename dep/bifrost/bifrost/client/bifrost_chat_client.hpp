//
//  bifrost_message_client.hpp
//  bifrost-server
//
//  Created by everettjf on 2019/4/25.
//  Copyright © 2019 everettjf. All rights reserved.
//

#ifndef bifrost_chat_client_hpp
#define bifrost_chat_client_hpp



#include <cstdlib>
#include <deque>
#include <iostream>
#include <thread>
#include <boost/asio.hpp>
#include "../common/bifrost_protocol.hpp"

using boost::asio::ip::tcp;

namespace bifrost {
    
    class chat_client_handler {
    public:
        virtual void send(const chat_message& msg) = 0;
    };
    
    using on_client_receive_message_callback = std::function<void(const chat_message& msg, chat_client_handler *client)>;
    using on_client_connect_callback = std::function<void(chat_client_handler *client, bool is_succeed, const std::string & error)>;

    class chat_client : public chat_client_handler
    {
    public:
        chat_client(boost::asio::io_context& io_context)
        : io_context_(io_context),socket_(io_context)
        {

          
        }
        
        on_client_receive_message_callback on_receive_message;
        on_client_connect_callback on_connect;
        
        void connect(const tcp::resolver::results_type& endpoints) {
            do_connect(endpoints);
        }
        
        virtual void send(const chat_message& msg) override
        {
            boost::asio::post(io_context_,
                              [this, msg]()
                              {
                                  bool write_in_progress = !write_msgs_.empty();
                                  write_msgs_.push_back(msg);
                                  if (!write_in_progress)
                                  {
                                      do_write();
                                  }
                              });
        }
        
        void close()
        {
            boost::asio::post(io_context_, [this]() { socket_.close(); });
        }
        
    private:
        void do_connect(const tcp::resolver::results_type& endpoints)
        {
            boost::asio::async_connect(socket_, endpoints,
                                       [this](boost::system::error_code ec, tcp::endpoint ep)
                                       {
                                           if (ec) {
                                               // connect error
                                               std::cout << "connect error " << ec.message() << std::endl;
                                               if(on_connect) on_connect(this,false,ec.message());
                                           } else {
                                               std::cout << "connect succeed = " << ep << std::endl;
                                               if(on_connect) on_connect(this,true,"");

                                               do_read_header();
                                           }
                                       });
        }
        
        void do_read_header()
        {
            boost::asio::async_read(socket_,
                                    boost::asio::buffer(read_msg_.data(), chat_message::header_length),
                                    [this](boost::system::error_code ec, std::size_t /*length*/)
                                    {
                                        if (ec){
                                            std::cout << "read header error " << ec << std::endl;
                                            socket_.close();
                                            return;
                                        }
                                        
                                        if (!read_msg_.decode_header()){
                                            std::cout << "decode header error " << std::endl;
                                            socket_.close();
                                            return;
                                        }

                                        do_read_body();
                                    });
        }
        
        void do_read_body()
        {
            boost::asio::async_read(socket_,
                                    boost::asio::buffer(read_msg_.body(), read_msg_.body_length()),
                                    [this](boost::system::error_code ec, std::size_t /*length*/)
                                    {
                                        if (ec) {
                                            std::cout << "read body error " << ec << std::endl;
                                            socket_.close();
                                            return;
                                        }
                                        
                                        if (this->on_receive_message) {
                                            this->on_receive_message(read_msg_,this);
                                        }
                                        do_read_header();
                                    });
        }
        
        void do_write()
        {
            boost::asio::async_write(socket_,
                                     boost::asio::buffer(write_msgs_.front().data(),
                                                         write_msgs_.front().length()),
                                     [this](boost::system::error_code ec, std::size_t /*length*/)
                                     {
                                         if (ec) {
                                             std::cout << "write error " << ec << std::endl;
                                             socket_.close();
                                             return;
                                         }
                                         
                                         write_msgs_.pop_front();
                                         if (!write_msgs_.empty())
                                         {
                                             do_write();
                                         }
                                     });
        }
        
    private:
        boost::asio::io_context& io_context_;
        tcp::socket socket_;
        chat_message read_msg_;
        
        using chat_message_queue = std::deque<chat_message>;
        chat_message_queue write_msgs_;
    };

}
#endif /* bifrost_chat_client_hpp */
