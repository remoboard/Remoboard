//
//  bifrost_util.hpp
//  bifrost-server
//
//  Created by everettjf on 2019/4/27.
//  Copyright © 2019 everettjf. All rights reserved.
//

#ifndef bifrost_util_hpp
#define bifrost_util_hpp

#include <ctime>
#include <iostream>
#include <string>
#include <boost/asio.hpp>
#include <fstream>
#include <sstream>

namespace bifrost {

    inline std::string get_file_name_from_path(const std::string & file_path) {
        std::string filename;
        size_t pos = file_path.find_last_of('/');
        if (pos!=std::string::npos){
            filename = file_path.substr(pos+1);
        } else {
            filename = file_path;
        }
        return filename;
    }

}

#endif /* bifrost_util_hpp */
