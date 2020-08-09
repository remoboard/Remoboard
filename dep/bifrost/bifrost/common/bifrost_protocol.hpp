//
//  bifrost_protocol.hpp
//  bifrost-client
//
//  Created by everettjf on 2019/4/25.
//  Copyright © 2019 everettjf. All rights reserved.
//

#ifndef bifrost_protocol_hpp
#define bifrost_protocol_hpp

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <list>
#include <sstream>

#define kBifrostProtocolMagic "MESSIER"

namespace bifrost {
    
    using buffer_type = std::array<char, 2048>;
    
    class chat_message
    {
    public:
        enum { header_length = 16 };
        enum { max_body_length = 2048 };
        
        chat_message(): body_length_(0){
        }
        
        chat_message(const std::string & str){
            set_string(str);
        }
        chat_message(const char * str){
            set_string(std::string(str));
        }
        
        const char* data() const{
            return data_;
        }
        
        char* data(){
            return data_;
        }
        
        std::size_t length() const{
            return header_length + body_length_;
        }
        
        const char* body() const{
            return data_ + header_length;
        }
        
        char* body(){
            return data_ + header_length;
        }
        
        std::size_t body_length() const{
            return body_length_;
        }
        
        void body_length(std::size_t new_length){
            body_length_ = new_length;
            if (body_length_ > max_body_length)
                body_length_ = max_body_length;
        }
        
        bool decode_header(){
            char magic_part[header_length + 1] = "";
            std::strncat(magic_part, data_, std::strlen(kBifrostProtocolMagic));
            if(strncmp(magic_part, kBifrostProtocolMagic, std::strlen(kBifrostProtocolMagic)) != 0){
                std::cout << "error: header magic incorrect:" << magic_part << std::endl;
                return false;
            }

            char size_part[header_length + 1] = "";
            std::strncat(size_part, data_ + std::strlen(kBifrostProtocolMagic), header_length - std::strlen(kBifrostProtocolMagic));
            body_length_ = std::atoi(size_part);
            if (body_length_ > max_body_length){
                body_length_ = 0;
                std::cout << "error: body length in header too large:" << body_length_ << std::endl;
                return false;
            }
            return true;
        }
        
        void encode_header(){
            char header[header_length + 1] = "";
            std::sprintf(header, "%s%8d", kBifrostProtocolMagic, static_cast<int>(body_length_));
            std::memcpy(data_, header, header_length);
        }
        
        // helper
        void set_string(const std::string & str){
            body_length(str.length());
            std::memcpy(body(), str.data(), body_length());
            encode_header();
        }
        std::string get_string() const{
            std::string str;
            str.assign(body(),body_length());
            str += ""; // add trailing zero
            return str;
        }
        
    private:
        char data_[header_length + max_body_length];
        std::size_t body_length_;
    };

    class file_message {
    private:
        const std::string k_end_flag = "\n\nfile\n\n";
    public:
        class file_info {
        public:
            std::string path;
            size_t size;
        };
        
    public:
        size_t count;
        std::list<file_info> files;
        
        void clear(){
            count = 0;
            files.clear();
        }
        
        bool read_from(boost::asio::ip::tcp::socket &socket) {
            clear();
            
            boost::asio::streambuf request_buf;
            boost::asio::read_until(socket, request_buf, k_end_flag);
            std::istream request_stream(&request_buf);
            
            buffer_type buf;
            
            // magic string
            std::string magic_string;
            request_stream >> magic_string;
            if (magic_string != "/bifrost_file_message/") {
                return false;
            }
            // count
            request_stream >> count;
            
            // files
            for (int i=0;i<count;++i){
                file_info info;
                request_stream >> info.path;
                request_stream >> info.size;
                files.push_back(info);
            }
            
            // trailing
            request_stream.read(buf.data(), k_end_flag.size() + 1); // eat the k_end_flag + last char
            
            return true;
        }
        
        void write_to(boost::asio::ip::tcp::socket &socket){
            
            boost::asio::streambuf request;
            std::ostream request_stream(&request);
            
            request_stream
            << "/bifrost_file_message/" << "\n"
            << count << "\n";
            
            for(auto &info : files){
                request_stream
                << info.path << "\n"
                << info.size << "\n"
                ;
            }
            
            request_stream << k_end_flag;
            
            boost::asio::write(socket, request);
        }
    };
    
    
}


#endif /* bifrost_protocol_hpp */
