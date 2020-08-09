package com.everettjf.remotekb.channel.bluetooth;

public interface BluetoothServerCallback {

    void onStartFailed(String error);

    void onStartSucceed();

    void onMessageReceived(String type, String data);
}
