#ifndef CHANNELDEFINE_H
#define CHANNELDEFINE_H

enum class ChannelType : int {
    IPNetwork,
    BlueTooth
};

enum class ChannelStatus : int {
    // Common
    ConnectStart,
    ConnectConnected,
    ConnectShakeHands,
    ConnectReady,
    ConnectFailed,
    ConnectClose,

    // Bluetooth Specific
    BluetoothUnsupported,
    BluetoothPowerOff,
    BluetoothScanning,
    BluetoothScanFinished,
    BluetoothServerList,
};

#endif // CHANNELDEFINE_H
