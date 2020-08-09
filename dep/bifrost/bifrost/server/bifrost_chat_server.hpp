//
//  bifrost_message_server.hpp
//  bifrost-server
//
//  Created by everettjf on 2019/4/25.
//  Copyright © 2019 everettjf. All rights reserved.
//

#ifndef bifrost_chat_server_hpp
#define bifrost_chat_server_hpp

#include <cstdlib>
#include <deque>
#include <iostream>
#include <list>
#include <memory>
#include <set>
#include <utility>
#include <boost/asio.hpp>
#include "../common/bifrost_protocol.hpp"

using boost::asio::ip::tcp;


namespace bifrost {
    
    class chat_session_handler {
    public:
        virtual void send(const chat_message& msg) = 0;
    };
    
    using on_server_receive_message_callback = std::function<void(const chat_message& msg, chat_session_handler *session)>;
    using on_server_chat_session_created_callback = std::function<void(chat_session_handler *session)>;
    using on_server_chat_session_closed_callback = std::function<void(chat_session_handler *session)>;


    class chat_session : public chat_session_handler, public std::enable_shared_from_this<chat_session>
    {
    public:
        chat_session(tcp::socket socket): socket_(std::move(socket)){
        }
        
        on_server_receive_message_callback on_receive_message;
        on_server_chat_session_created_callback on_session_created;
        on_server_chat_session_closed_callback on_session_closed;
        
        void start(){
            on_session_created(this);
            do_read_header();
        }
        
        virtual void send(const chat_message& msg) override{
            bool write_in_progress = !write_msgs_.empty();
            write_msgs_.push_back(msg);
            if (!write_in_progress){
                do_write();
            }
        }
        void close(){
            on_session_closed(this);
            socket_.close();
        }
        
    private:
        void do_read_header()
        {
            auto self(shared_from_this());
            boost::asio::async_read(socket_,
                                    boost::asio::buffer(read_msg_.data(), chat_message::header_length),
                                    [this, self](boost::system::error_code ec, std::size_t /*length*/)
                                    {
                                        if(ec){
                                            std::cout<< "read header error : "<< ec <<std::endl;
                                            close();
                                            return;
                                        }
                                        
                                        if (read_msg_.decode_header()){
                                            do_read_body();
                                        } else {
                                            std::cout<< "failed to decode header" <<std::endl;
                                        }
                                        
                                    });
        }
        
        void do_read_body()
        {
            auto self(shared_from_this());
            boost::asio::async_read(socket_,
                                    boost::asio::buffer(read_msg_.body(), read_msg_.body_length()),
                                    [this, self](boost::system::error_code ec, std::size_t /*length*/){
                                        if(ec){
                                            std::cout<< "read body error : "<< ec <<std::endl;
                                            close();
                                            return;
                                        }
                                        // deal with read_msg_
                                        if (on_receive_message) {
                                            on_receive_message(read_msg_, this);
                                        }
                                        
                                        // read next message
                                        do_read_header();
                                    });
        }
        
        void do_write()
        {
            auto self(shared_from_this());
            boost::asio::async_write(socket_,
                                     boost::asio::buffer(write_msgs_.front().data(),
                                                         write_msgs_.front().length()),
                                     [this, self](boost::system::error_code ec, std::size_t /*length*/){
                                         if(ec){
                                             std::cout<< "write error : "<< ec <<std::endl;
                                             return;
                                         }
                                         write_msgs_.pop_front();
                                         if (!write_msgs_.empty()){
                                             do_write();
                                         }
                                     });
        }
        
        
        tcp::socket socket_;
        chat_message read_msg_;
        
        using chat_message_queue = std::deque<chat_message>;
        chat_message_queue write_msgs_;
    };
    
    //----------------------------------------------------------------------
    
    class chat_server
    {
    public:
        chat_server(boost::asio::io_context& io_context,const tcp::endpoint& endpoint)
        : acceptor_(io_context, endpoint){
        }
        
        on_server_receive_message_callback on_receive_message;
        on_server_chat_session_created_callback on_session_created;
        on_server_chat_session_closed_callback on_session_closed;
        

        void listen() {
            do_accept();
        }
        
        void close() {
            acceptor_.close();
            
            for (auto & weak_session: sessions_) {
                try {
                    std::shared_ptr<chat_session> session(weak_session);
                    if(session.get()){
                        session->close();
                    }
                } catch(const std::bad_weak_ptr &e) {
                }
            }
        }
        
    private:
        void do_accept(){
            acceptor_.async_accept([this](boost::system::error_code ec, tcp::socket socket){
                if (!ec){
                    auto session = std::make_shared<chat_session>(std::move(socket));
                    session->on_receive_message = on_receive_message;
                    session->on_session_created = on_session_created;
                    session->on_session_closed = on_session_closed;
                    
                    std::weak_ptr<chat_session> weak_session = session;
                    sessions_.push_back(weak_session);
                    session->start();
                }

                // next accept
                do_accept();
            });
        }
        
        tcp::acceptor acceptor_;
        std::list<std::weak_ptr<chat_session>> sessions_;
    };
    
}

#endif /* bifrost_chat_server_hpp */
