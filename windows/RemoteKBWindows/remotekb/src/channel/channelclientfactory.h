#ifndef CHANNELCLIENTFACTORY_H
#define CHANNELCLIENTFACTORY_H

#include <functional>
#include <memory>
#include <string>
#include "channeldefine.h"

class ChannelClient {
public:
    ChannelClient();
    virtual ~ChannelClient();

    std::function<void(ChannelType channelType,ChannelStatus statusType,const std::string &content, void *data)> onStatus;

    virtual void start() = 0;
    virtual void connect(const std::string & host) = 0;
    virtual void send(const std::string & type, const std::string & content) = 0;
    virtual void close() = 0;
};

class ChannelClientFactory
{
public:
    static std::shared_ptr<ChannelClient> create(ChannelType type);
};

#endif // CHANNELCLIENTFACTORY_H
