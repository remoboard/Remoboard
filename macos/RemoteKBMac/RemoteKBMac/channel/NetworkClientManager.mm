#include "NetworkClientManager.h"
#include "../../dep/bifrost/client/bifrost_client.hpp"
#include "../../dep/bifrost/client/bifrost_file_client.hpp"
#include "../../dep/logic/json.hpp"
#include "../../dep/logic/logic.hpp"
#include "../../dep/logic/tinyformat.h"
#include "../../dep/logic/logic.hpp"
#include <thread>
#include "util.h"

template <typename T>
void mlog(T&& t){
    std::cout << t << std::endl;
}

namespace rekb {

    struct NetworkClientManager::Impl {
        std::shared_ptr<bifrost::client> client;
        std::thread network_thread;
        bool manual_stop_network = false;
        bool connect_failed = false;

        rekb::DeviceInfo device_info;
        std::string host;
    };

    NetworkClientManager &NetworkClientManager::instance()
    {
        static NetworkClientManager o;
        return o;
    }

    NetworkClientManager::NetworkClientManager() : _imp(std::make_shared<Impl>())
    {
    }
    
    NetworkClientManager::~NetworkClientManager()
    {
        stopNetwork();
    }

    void NetworkClientManager::setHost(const std::string &host)
    {
        _imp->host = host;

        bifrost::config::value().client_connect_host = host;
    }

    void NetworkClientManager::connect()
    {
        stopNetwork();
        
        bifrost::config::value().chat_server_listen_port = 6999;
        bifrost::config::value().chat_client_connect_port = 6999;

        startNetwork();
    }

    void NetworkClientManager::close()
    {
        stopNetwork();
    }
    
    void NetworkClientManager::startNetwork()
    {
        _imp->manual_stop_network = false;

        _imp->network_thread = std::thread([this]() {
            while(true) {
                if (onStatus) {
                    onStatus(ChannelClientStatus_ConnectStart,"");
                }
                usleep(1 * 1000 * 1000);

                if (_imp->manual_stop_network){
                    printf("break out loop\n");
                    if (onStatus) {
                        onStatus(ChannelClientStatus_ConnectClose,"");
                    }
                    break;
                }

                _imp->client = std::make_shared<bifrost::client>();

                configMessage();

                _imp->client->run();
                printf("running chat client\n");

                _imp->client->wait();
                printf("chat client stopped !!!\n");
                
                if (_imp->connect_failed) {
                    printf("connect failed , break out\n");
                    break;
                }
            }
        });
    }

    void NetworkClientManager::stopNetwork()
    {
        _imp->manual_stop_network = true;
        if (_imp->client){
            _imp->client->close();
        }
        if(_imp->network_thread.joinable()){
            _imp->network_thread.join();
        }
    }
    void NetworkClientManager::send(const std::string & command, const std::string & content)
    {
        if(!_imp->client){
            return;
        }
        _imp->client->send(bifrost::chat_message(construct_message(command, content)));
    }

    void NetworkClientManager::configMessage()
    {
        if(!_imp->client){
            return;
        }
        
        _imp->client->on_connect = [this](bifrost::chat_client_handler *client, bool is_succeed, const std::string & error) {
            if (is_succeed) {
                _imp->connect_failed = false;
                if (onStatus) {
                    onStatus(ChannelClientStatus_ConnectStartConnected,"");
                }
            } else {
                _imp->connect_failed = true;
                if (onStatus) {
                    onStatus(ChannelClientStatus_ConnectFailed,"");
                }
            }
        };
        
        _imp->client->on_receive_message = [this](const bifrost::chat_message& msg, bifrost::chat_client_handler *client){
            std::string message = msg.get_string();
            std::cout << "receive: " << message << std::endl;

            std::string command;
            std::string content;
            if(! deconstruct_message(message, command, content)) {
                std::cout << "failed to deconstruct message" << std::endl;
                return;
            }
            std::cout << "command: " << command << std::endl;
            std::cout << "content: " << content << std::endl;

            processMessage(client,command,content);
        };
        
    }

    void NetworkClientManager::processMessage(void *peer,const std::string & command, const std::string & content)
    {
        bifrost::chat_client_handler *client = (bifrost::chat_client_handler *)peer;

        if (command == "hello"){
            if (onStatus) {
                onStatus(ChannelClientStatus_ConnectStartShakeHands,"");
            }
            client->send(bifrost::chat_message(construct_message("hello", "")));
            
        } else if (command == "device-info") {
            _imp->device_info.from_json(content);
            auto & dev = _imp->device_info;
            std::string msg = tfm::format("Connected to %s", dev.dev_name);
            
            if (onStatus) {
                onStatus(ChannelClientStatus_ConnectReady,msg);
            }
        } else {
            // other messages
            if (onMessage) {
                onMessage(command, content);
            }
        }
    }

}
