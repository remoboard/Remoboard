#include "bluetoothcontroller.h"
#include <QDebug>
#include "logic/bledef.h"
#include "logic/logic.hpp"

BluetoothController::BluetoothController(QObject *parent) : QObject(parent)
{

}

BluetoothController &BluetoothController::instance()
{
    static BluetoothController o;
    return o;
}

void BluetoothController::start()
{
    m_closed = false;

    m_deviceDiscoveryAgent = new QBluetoothDeviceDiscoveryAgent(this);
    m_deviceDiscoveryAgent->setLowEnergyDiscoveryTimeout(5000);

    connect(m_deviceDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::deviceDiscovered, this, &BluetoothController::scanDeviceDiscovered);
    connect(m_deviceDiscoveryAgent, static_cast<void (QBluetoothDeviceDiscoveryAgent::*)(QBluetoothDeviceDiscoveryAgent::Error)>(&QBluetoothDeviceDiscoveryAgent::error),this, &BluetoothController::scanError);

    connect(m_deviceDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::finished, this, &BluetoothController::scanFinished);
    connect(m_deviceDiscoveryAgent, &QBluetoothDeviceDiscoveryAgent::canceled, this, &BluetoothController::scanCanceled);

    m_deviceDiscoveryAgent->start(QBluetoothDeviceDiscoveryAgent::LowEnergyMethod);
}

void BluetoothController::close()
{
    m_closed = true;
}

void BluetoothController::connectToDevice(const QString &host)
{
    // find device by host
    QBluetoothDeviceInfo targetDevice;
    bool found = false;
    auto item = device_map.find(host.toStdString());
    if (item != device_map.end()) {
        targetDevice = item->second;
        found = true;
    }

    if (!found) {
        qDebug() << "Not found target device by bluetooth name";

        if (onStatus) {
            onStatus(ChannelStatus::ConnectFailed,"");
        }
        return;
    }

    m_control = QLowEnergyController::createCentral(targetDevice, this);
    connect(m_control, &QLowEnergyController::serviceDiscovered,this, &BluetoothController::serviceDiscovered);
    connect(m_control, &QLowEnergyController::discoveryFinished,this, &BluetoothController::serviceDiscoveryFinished);

    connect(m_control, static_cast<void (QLowEnergyController::*)(QLowEnergyController::Error)>(&QLowEnergyController::error),this, [this](QLowEnergyController::Error error) {
        qDebug() << "control error: " << error;

        if (onStatus) {
            onStatus(ChannelStatus::ConnectFailed,"");
        }
    });
    connect(m_control, &QLowEnergyController::connected, this, [this]() {
        qDebug() << "connected , start search services";

        if (onStatus) {
            onStatus(ChannelStatus::ConnectConnected,"");
        }
        m_control->discoverServices();
    });
    connect(m_control, &QLowEnergyController::disconnected, this, [this]() {
        qDebug() << "disconnected";
    });

    // Connect
    m_control->connectToDevice();
}

void BluetoothController::sendToDevice(const QString &type, const QString &content)
{
    if (!m_service) {
        return;
    }

    std::string msg = rekb::construct_message(type.toStdString(), content.toStdString());
    QString qmsg = QString::fromStdString(msg);

    m_service->writeCharacteristic(m_characteristic,qmsg.toUtf8());
}


void BluetoothController::scanDeviceDiscovered(const QBluetoothDeviceInfo &device)
{
    if (onStatus) {
        onStatus(ChannelStatus::BluetoothScanning,"");
    }
    if (device.coreConfigurations() & QBluetoothDeviceInfo::LowEnergyCoreConfiguration) {
        if (device.name().isEmpty()) {
            return;
        }

        if (device.name().contains(":")) {
            return;
        }

        qDebug() << "found device : " << device.name() << ",uuid=" << device.deviceUuid() << ",address:" << device.address() << ",isCached:"<< device.isCached() << ",valid:"<< device.isValid();

        std::string deviceName = device.name().toStdString();
        device_map[deviceName] = device;

        std::list<std::string> deviceNames;
        for(auto & item : device_map) {
            deviceNames.push_back(item.first);
        }

        if (onScanResult) {
            onScanResult(deviceNames);
        }
    }
}

void BluetoothController::scanFinished()
{
    qDebug()<< "scan finished";

    if (onStatus) {
        onStatus(ChannelStatus::BluetoothScanFinished,"");
    }
}

void BluetoothController::scanError(QBluetoothDeviceDiscoveryAgent::Error error)
{
    qDebug()<< "scan error" << error;
}

void BluetoothController::scanCanceled()
{
    qDebug() << "scan cannceled";
}

void BluetoothController::serviceDiscovered(const QBluetoothUuid &gatt)
{
    qDebug() << "service discovered : " << gatt.toString();

    if (gatt.toString() == QString(MYBLE_SERVICE_UUID_C)) {
        qDebug() << "found my service";

        m_foundService = true;
        // stop scan
        m_deviceDiscoveryAgent->stop();

        if (onStatus) {
            onStatus(ChannelStatus::ConnectShakeHands,"");
        }
    }
}

void BluetoothController::serviceDiscoveryFinished()
{
    qDebug() << "service discovery finished";
    if (m_foundService) {
        m_service = m_control->createServiceObject(QBluetoothUuid(QString(MYBLE_SERVICE_UUID_C)), this);
    }

    if (!m_service) {
        return;
    }

    connect(m_service, &QLowEnergyService::stateChanged, this, &BluetoothController::serviceStateChanged);
    connect(m_service, &QLowEnergyService::characteristicWritten, this, &BluetoothController::serviceCharacteristicWritten);
    connect(m_service, &QLowEnergyService::characteristicChanged, this, &BluetoothController::serviceCharacteristicChanged);
    m_service->discoverDetails();
}

void BluetoothController::serviceStateChanged(QLowEnergyService::ServiceState newState)
{
    qDebug() << "serviceStateChanged:" << newState;

    switch (newState) {
    case QLowEnergyService::DiscoveringServices:{
        break;
    }
    case QLowEnergyService::ServiceDiscovered: {
        QList<QLowEnergyCharacteristic> chars = m_service->characteristics();
        for( auto & item : chars) {
            qDebug() << "char item : " << item.uuid();
        }
        const QLowEnergyCharacteristic hrChar = m_service->characteristic(QBluetoothUuid(QString(MYBLE_CHARACTERISTIC_UUID_C)));
        if (hrChar.isValid()) {
            qDebug() << "valid characteristic";
            m_characteristic = hrChar;

            if (onStatus) {
                onStatus(ChannelStatus::ConnectReady,"");
            }
        }
        break;
    }
    default: {
        break;
    }
    }
}

void BluetoothController::serviceCharacteristicWritten(const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    qDebug() << "serviceCharacteristicWritten:"<< info.uuid();
}

void BluetoothController::serviceCharacteristicChanged(const QLowEnergyCharacteristic &info, const QByteArray &value)
{
    qDebug() << "serviceCharacteristicChanged:" << info.uuid();
}
