#ifndef BLUETOOTHCONTROLLER_H
#define BLUETOOTHCONTROLLER_H

#include <QObject>
#include <QBluetoothDeviceDiscoveryAgent>
#include <QBluetoothDeviceInfo>
#include <QBluetoothUuid>
#include <QBluetoothServiceInfo>
#include <QLowEnergyController>
#include <QLowEnergyService>
#include <QLowEnergyDescriptor>
#include <list>
#include <map>
#include <string>
#include <functional>
#include "../channeldefine.h"


class BluetoothController : public QObject
{
    Q_OBJECT
public:
    explicit BluetoothController(QObject *parent = nullptr);

    static BluetoothController &instance();

    std::function<void(const std::list<std::string> &items)> onScanResult;
    std::function<void(ChannelStatus statusType,const std::string &content)> onStatus;

    void start();
    void close();

    void connectToDevice(const QString & host);
    void sendToDevice(const QString & type, const QString & content);

signals:

public slots:    
    void scanDeviceDiscovered(const QBluetoothDeviceInfo &info);
    void scanFinished();
    void scanError(QBluetoothDeviceDiscoveryAgent::Error error);
    void scanCanceled();

    void serviceDiscovered(const QBluetoothUuid &newService);
    void serviceDiscoveryFinished();

    void serviceStateChanged(QLowEnergyService::ServiceState newState);
    void serviceCharacteristicChanged(const QLowEnergyCharacteristic &info,const QByteArray &value);
    void serviceCharacteristicWritten(const QLowEnergyCharacteristic &info,const QByteArray &value);
private:
    std::map<std::string,QBluetoothDeviceInfo> device_map;  //存放搜索到到蓝牙设备列表
    QBluetoothDeviceDiscoveryAgent *m_deviceDiscoveryAgent;  //设备搜索对象
    QLowEnergyController *m_control;   //单个蓝牙设备控制器
    QLowEnergyService *m_service; //服务对象实例
    QLowEnergyCharacteristic m_characteristic;
    bool m_foundService = false;;
    bool m_closed = false;
};

#endif // BLUETOOTHCONTROLLER_H
