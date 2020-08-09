#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <memory>
#include <string>
#import <Cocoa/Cocoa.h>
#import "ChanelClientDefine.h"


namespace rekb {

class NetworkClientManager
{
private:
    struct Impl;
    std::shared_ptr<Impl> _imp;
public:
    NetworkClientManager();
    ~NetworkClientManager();

    static NetworkClientManager & instance();
    
    void (^onStatus)(ChannelClientStatus type, const std::string & data);
    void (^onMessage)(const std::string & type, const std::string & data);

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
