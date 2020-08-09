#include "channelclientfactory.h"
#include "ipnetwork/networkcontroller.h"
#include "bluetooth/bluetoothcontroller.h"

//////////////////////////////////////////////////////////////////////////////////////////////////////////
ChannelClient::ChannelClient() {}

ChannelClient::~ChannelClient() {}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
class IPNetworkChannelClient : public ChannelClient {
public:
    IPNetworkChannelClient();
    virtual ~IPNetworkChannelClient() override;

    virtual void start() override {

    }
    virtual void connect(const std::string & host) override {

        rekb::NetworkController::instance().onStatus = [&](ChannelStatus statusType,const std::string &content) {
            if(this->onStatus) {
                this->onStatus(ChannelType::IPNetwork, statusType, content, nullptr);
            }
        };
        rekb::NetworkController::instance().setHost(host);
        rekb::NetworkController::instance().connect();
    }
    virtual void send(const std::string & type, const std::string & content) override {
        rekb::NetworkController::instance().send(type, content);
    }
    virtual void close() override {
        rekb::NetworkController::instance().close();
    }
};

IPNetworkChannelClient::IPNetworkChannelClient() {}

IPNetworkChannelClient::~IPNetworkChannelClient(){}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
class BluetoothChannelClient : public ChannelClient {
public:
    BluetoothChannelClient();
    virtual ~BluetoothChannelClient() override;

    virtual void start() override {
        BluetoothController::instance().onStatus = [&](ChannelStatus statusType,const std::string &content) {
            if(this->onStatus) {
                this->onStatus(ChannelType::BlueTooth, statusType, content, nullptr);
            }
        };

        BluetoothController::instance().onScanResult = [&](const std::list<std::string> &items) {
            if (this->onStatus) {
                this->onStatus(ChannelType::BlueTooth, ChannelStatus::BluetoothServerList, "", (void*) &items);
            }
        };
        BluetoothController::instance().start();
    }
    virtual void connect(const std::string & host) override {

        BluetoothController::instance().connectToDevice(QString::fromStdString(host));
    }
    virtual void send(const std::string & type, const std::string & content) override {
        BluetoothController::instance().sendToDevice(QString::fromStdString(type), QString::fromStdString(content));
    }
    virtual void close() override {
        BluetoothController::instance().close();
    }
};


BluetoothChannelClient::BluetoothChannelClient(){}

BluetoothChannelClient::~BluetoothChannelClient() {}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
std::shared_ptr<ChannelClient> ChannelClientFactory::create(ChannelType channelType)
{
    if (channelType == ChannelType::BlueTooth) {
        ChannelClient *ptr = new BluetoothChannelClient();
        return std::shared_ptr<ChannelClient>(ptr);
    }

    ChannelClient *ptr = new IPNetworkChannelClient();
    return std::shared_ptr<ChannelClient>(ptr);
}

