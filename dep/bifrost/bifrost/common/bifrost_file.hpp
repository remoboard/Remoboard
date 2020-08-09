//
//  bifrost_file.hpp
//  bifrost-server
//
//  Created by everettjf on 2019/4/27.
//  Copyright © 2019 everettjf. All rights reserved.
//

#ifndef bifrost_file_hpp
#define bifrost_file_hpp

#include <ctime>
#include <iostream>
#include <string>
#include <boost/asio.hpp>
#include <fstream>
#include <sstream>
#include "bifrost_protocol.hpp"


namespace bifrost {

    
    class file_handler {
    public:
        std::function<void(const file_message::file_info & file_info, std::string& local_savepath)> on_receive_file_info;

        bool recv_file(boost::asio::ip::tcp::socket &socket) {
            try{
                buffer_type buf;
                
                // read file header
                file_message file_header;
                if(!file_header.read_from(socket)) {
                    std::cout << "invalid file message magic string" << std::endl;
                    return false;
                }
                
                if (file_header.count == 0) {
                    std::cout << "file count zero" << std::endl;
                    return false;
                }
                
                std::cout << "file count : " << file_header.count << std::endl;
                for(auto & file_info : file_header.files) {
                    std::cout << file_info.size << " - " << file_info.path << std::endl;
                }
                
                for(auto & file_info : file_header.files){
                    // save path
                    std::string local_savepath;
                    on_receive_file_info(file_info,local_savepath);
                    if (local_savepath.empty()) {
                        std::cout << "empty local save path" << std::endl;
                        return false;
                    }
                    
                    // open output file
                    std::cout << "open for write " << local_savepath << " file size " << file_info.size << std::endl;

                    std::ofstream output_file(local_savepath.c_str(), std::ios_base::binary);
                    if (!output_file){
                        std::cout << "failed to open " << local_savepath << std::endl;
                        return false;
                    }
                    
                    // write bytes to file
                    size_t left_file_size = file_info.size;
                    boost::system::error_code error;
                    while(left_file_size > 0){
                        size_t len = socket.read_some(boost::asio::buffer(buf), error);
//                        std::cout << "read some len = " << len << std::endl;

                        if (len == 0){
                            break;
                        }
                        
                        size_t write_len = 0;
                        if (left_file_size < len) {
                            write_len = left_file_size;
//                            std::cout << "got " << len << " but need " << left_file_size << std::endl;
                        } else {
                            write_len = len;
                        }
                        output_file.write(buf.data(), (std::streamsize)write_len);
               
                        left_file_size -= write_len;
                    }
                    
                    if(left_file_size != 0){
                        std::cout << "left_file_size should be zero now " << left_file_size << std::endl;
                    }
                    
                    if (output_file.tellp() == (std::fstream::pos_type)(std::streamsize)file_info.size) {
                        std::cout << "done" << std::endl;
                    }
                    std::cout << "received " << output_file.tellp() << " bytes.\n";
                    
                }
            }catch (std::exception& e){
                std::cerr << "recv file exception : " << e.what() << std::endl;
                return false;
            }
            return true;
        }
        
        bool send_file(boost::asio::ip::tcp::socket & socket,const std::list<std::string>& files) {
            if(files.empty()){
                return false;
            }
            
            try
            {
                buffer_type buf;
                
                file_message file_header;
                file_header.count = files.size();
                for(auto& filepath : files){
                    std::ifstream source_file(filepath, std::ios_base::binary | std::ios_base::ate);
                    if (!source_file){
                        std::cout << "failed to open " << filepath << std::endl;
                        return false;
                    }
                    
                    file_message::file_info info;
                    info.path = filepath;
                    info.size = source_file.tellg();
                    
                    if(info.size == 0){
                        std::cout << "file size is zero : " << filepath << std::endl;
                        return false;
                    }
                    
                    file_header.files.push_back(info);
                }
                
                file_header.write_to(socket);
                
                std::cout << "files will be sent : "<<"\n";
                int index = 0;
                for(auto& file_info : file_header.files){
                    std::cout << index << ". " << file_info.path << "\n";
                    ++index;
                }

                for(auto& file_info : file_header.files){
                    std::cout << "start send file " << file_info.path << "\n";

                    std::ifstream source_file(file_info.path, std::ios_base::binary | std::ios_base::ate);
                    if (!source_file){
                        std::cout << "failed to open " << file_info.path << std::endl;
                        return false;
                    }
                    
                    if (file_info.size != source_file.tellg()){
                        std::cout << "file size changed : " << file_info.path << std::endl;
                        return false;
                    }
                    
                    source_file.seekg(0);
                    
                    while(true){
                        if (source_file.eof()){
                            break;
                        }
                        
                        source_file.read(buf.data(), (std::streamsize)buf.size());
                        
                        if (source_file.gcount() <= 0){
                            std::cout << "file read complete : source_file.gcount() <= 0" << std::endl;
                            break;
                        }
                        
                        boost::system::error_code error = boost::asio::error::host_not_found;
                        boost::asio::write(socket, boost::asio::buffer(buf.data(),buf.size()),boost::asio::transfer_all(), error);
                        if (error){
                            std::cout << "send error:" << error << std::endl;
                            return false;
                        }
                    }
                    
                    std::cout << "send file " << file_info.path << " completed successfully.\n";
                }
                
            }catch (std::exception& e){
                std::cerr << "exception : " << e.what() << std::endl;
                return false;
            }
            
            return true;
        }
    };
}

#endif /* bifrost_file_hpp */
