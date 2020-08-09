//
//  messier_logic_hpp
//  messier_logic
//
//  Created by everettjf on 2019/4/27.
//  Copyright © 2019 everettjf. All rights reserved.
//

#ifndef messier_logic_hpp
#define messier_logic_hpp

#include <ctime>
#include <iostream>
#include <string>
#include <fstream>
#include <sstream>
#include <vector>
#include <boost/algorithm/string.hpp>
#include <boost/algorithm/string/predicate.hpp>
#include <boost/lexical_cast.hpp>
#include "json.hpp"

#define kRKBCommandSeparator "##rkb-1l0v3y0u3000##"
#define kRKBVersion "0.1"

namespace rekb {
    
    struct DeviceInfo{
        std::string rkb_version;

        std::string app_id;
        std::string app_version;
        std::string app_build;
        
        std::string dev_name;
        std::string dev_system_name;
        std::string dev_system_version;
        std::string dev_model;
        
        std::string to_json() {
            nlohmann::json j;
            j["rkb_version"] = rkb_version;

            j["app_id"] = app_id;
            j["app_version"] = app_version;
            j["app_build"] = app_build;
            
            j["dev_name"] = dev_name;
            j["dev_system_name"] = dev_system_name;
            j["dev_system_version"] = dev_system_version;
            j["dev_model"] = dev_model;

            return j.dump();
        }
        
        void from_json(const std::string & str) {
            auto j = nlohmann::json::parse(str);
            rkb_version = j["rkb_version"];
            app_id = j["app_id"];
            app_version = j["app_version"];
            app_build = j["app_build"];
            
            dev_name = j["dev_name"];
            dev_system_name = j["dev_system_name"];
            dev_system_version = j["dev_system_version"];
            dev_model = j["dev_model"];
        }
    };
    

    inline std::string construct_message(const std::string & command, const std::string & content) {
        return command + kRKBCommandSeparator + content;
    }

    inline bool deconstruct_message(const std::string & message, std::string & command, std::string & content) {
        size_t pos = message.find(kRKBCommandSeparator);
        if (pos == std::string::npos) {
            return false;
        }
        
        command = message.substr(0,pos);
        content = message.substr(pos + std::strlen(kRKBCommandSeparator),
                                 message.length() - pos - std::strlen(kRKBCommandSeparator));
        return true;
    }

}




#endif /* messier_logic_hpp */
