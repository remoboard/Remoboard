#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <memory>
#include <string>
#include <functional>
#include "../channeldefine.h"

namespace rekb {

class NetworkController
{
private:
    struct Impl;
    std::shared_ptr<Impl> _imp;
public:
    NetworkController();
    ~NetworkController();

    static NetworkController & instance();

    std::function<void(ChannelStatus statusType,const std::string &content)> onStatus;
    std::function<void(const std::string & type, const std::string & data)> onMessage;

    void setHost(const std::string & host);

    void connect();
    void close();

    void send(const std::string & command, const std::string & content);

private:
    void startNetwork();
    void stopNetwork();
private:
    void configMessage();
    void processMessage(void *peer,const std::string & command, const std::string & content);
};

}

#endif // CONTROLLER_H
