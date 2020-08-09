#include "networkcontroller.h"
#include "bifrost/bifrost/client/bifrost_client.hpp"
#include "bifrost/bifrost/client/bifrost_file_client.hpp"
#include "logic/logic.hpp"
#include "logic/json.hpp"
#include "logic/logic.hpp"
#include "logic/tinyformat.h"
#include "../../mainwindow.h"
#include <QString>
#include "../../util/util.h"
#include <QDateTime>
#include <thread>
#include <chrono>

template <typename T>
void mlog(T&& t){
    std::cout << t << std::endl;
}

namespace rekb {

    struct NetworkController::Impl {
        std::shared_ptr<bifrost::client> client;
        std::thread network_thread;
        bool manual_stop_network = false;
        bool connect_failed = false;

        rekb::DeviceInfo device_info;
        std::string host;
    };

    NetworkController &NetworkController::instance()
    {
        static NetworkController o;
        return o;
    }

    NetworkController::NetworkController() : _imp(std::make_shared<Impl>())
    {
    }

    NetworkController::~NetworkController()
    {
        stopNetwork();
    }

    void NetworkController::setHost(const std::string &host)
    {
        _imp->host = host;

        bifrost::config::value().client_connect_host = host;
    }

    void NetworkController::connect()
    {
        stopNetwork();

        bifrost::config::value().chat_server_listen_port = 6999;
        bifrost::config::value().chat_client_connect_port = 6999;

        startNetwork();
    }

    void NetworkController::close()
    {
        stopNetwork();
    }

    void NetworkController::startNetwork()
    {
        _imp->manual_stop_network = false;

        _imp->network_thread = std::thread([this]() {
            while(true) {
                if (onStatus) {
                    onStatus(ChannelStatus::ConnectStart,"");
                }

                std::this_thread::sleep_for(std::chrono::milliseconds(1000));

                if (_imp->manual_stop_network){
                    printf("break out loop\n");
                    if (onStatus) {
                        onStatus(ChannelStatus::ConnectClose,"");
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

    void NetworkController::stopNetwork()
    {
        _imp->manual_stop_network = true;
        if (_imp->client){
            _imp->client->close();
        }
        if(_imp->network_thread.joinable()){
            _imp->network_thread.join();
        }
    }
    void NetworkController::send(const std::string & command, const std::string & content)
    {
        if(!_imp->client){
            return;
        }
        _imp->client->send(bifrost::chat_message(construct_message(command, content)));
    }

    void NetworkController::configMessage()
    {
        if(!_imp->client){
            return;
        }

        _imp->client->on_connect = [this](bifrost::chat_client_handler *client, bool is_succeed, const std::string & error) {
            if (is_succeed) {
                _imp->connect_failed = false;
                if (onStatus) {
                    onStatus(ChannelStatus::ConnectConnected,"");
                }
            } else {
                _imp->connect_failed = true;
                if (onStatus) {
                    onStatus(ChannelStatus::ConnectFailed,"");
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

    void NetworkController::processMessage(void *peer,const std::string & command, const std::string & content)
    {
        bifrost::chat_client_handler *client = (bifrost::chat_client_handler *)peer;

        if (command == "hello"){
            if (onStatus) {
                onStatus(ChannelStatus::ConnectShakeHands,"");
            }
            client->send(bifrost::chat_message(construct_message("hello", "")));

        } else if (command == "device-info") {
            _imp->device_info.from_json(content);
            auto & dev = _imp->device_info;
            std::string msg = tfm::format("Connected to %s", dev.dev_name);

            if (onStatus) {
                onStatus(ChannelStatus::ConnectReady,msg);
            }
        } else {
            // other messages
            if (onMessage) {
                onMessage(command, content);
            }
        }
    }

}

