package com.everettjf.remotekb.channel.bluetooth;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattServer;
import android.bluetooth.BluetoothGattServerCallback;
import android.bluetooth.BluetoothGattService;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.AdvertiseCallback;
import android.bluetooth.le.AdvertiseData;
import android.bluetooth.le.AdvertiseSettings;
import android.bluetooth.le.BluetoothLeAdvertiser;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.ParcelUuid;
import android.util.Log;

import java.util.UUID;

import static android.content.Context.BLUETOOTH_SERVICE;

public class BluetoothServerManager {
    private static final String TAG = "BluetoothServerManager";

    private static final String UUID_Service = "81DA3FD1-7E10-41C1-B16F-4430B506CDE8";
    private static final String UUID_Characteristic = "71DA3FD1-7E10-41C1-B16F-4430B506CDE7";

    private static BluetoothServerManager manager;
    public static synchronized BluetoothServerManager getInstance() {
        if (manager == null) {
            manager = new BluetoothServerManager();
        }
        return manager;
    }

    public Context context;
    public BluetoothServerCallback callback;

    private BluetoothManager bluetoothManager;
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothLeAdvertiser bluetoothLeAdvertiser;
    private BluetoothGattServer bluetoothGattServer;

    public void start() {

        if (!context.getPackageManager().hasSystemFeature(PackageManager.FEATURE_BLUETOOTH_LE)) {
            callback.onStartFailed("Bluetooth Unsupported");
            return;
        }

        bluetoothManager = (BluetoothManager) context.getSystemService(BLUETOOTH_SERVICE);
        bluetoothAdapter = bluetoothManager.getAdapter();
        if (bluetoothAdapter == null) {
            callback.onStartFailed("Bluetooth LE Unsupported");
            return;
        }

        bluetoothLeAdvertiser = bluetoothAdapter.getBluetoothLeAdvertiser();
        if (bluetoothLeAdvertiser == null) {
            callback.onStartFailed("Bluetooth Advertise Unsupported");
            return;
        }

        callback.onStartSucceed();

        AdvertiseSettings.Builder settingBuilder = new AdvertiseSettings.Builder();
        settingBuilder.setConnectable(true);
        settingBuilder.setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_POWER);
        settingBuilder.setTimeout(0); //我填过别的，但是不能广播。后来我就坚定的0了
        settingBuilder.setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH);
        AdvertiseSettings settings = settingBuilder.build();

        bluetoothAdapter.setName("Remoboard");

        AdvertiseData.Builder dataBuilder = new AdvertiseData.Builder();
        dataBuilder.setIncludeDeviceName(true);
        dataBuilder.setIncludeTxPowerLevel(true);
        dataBuilder.addServiceUuid(ParcelUuid.fromString(UUID_Service)); //可自定义UUID，看看官方有没有定义哦
        AdvertiseData data = dataBuilder.build();

        bluetoothLeAdvertiser.startAdvertising(settings, data, new AdvertiseCallback() {
            @Override
            public void onStartSuccess(AdvertiseSettings settingsInEffect) {
                super.onStartSuccess(settingsInEffect);
                Log.d(TAG, "onStartSuccess: ");

                bluetoothGattServer = bluetoothManager.openGattServer(context, bluetoothGattServerCallback);

                BluetoothGattService service = new BluetoothGattService(UUID.fromString(UUID_Service), BluetoothGattService.SERVICE_TYPE_PRIMARY);
                BluetoothGattCharacteristic characteristicWrite = new BluetoothGattCharacteristic(UUID.fromString(UUID_Characteristic),
                        BluetoothGattCharacteristic.PROPERTY_WRITE | BluetoothGattCharacteristic.PROPERTY_READ | BluetoothGattCharacteristic.PROPERTY_NOTIFY,
                        BluetoothGattCharacteristic.PERMISSION_WRITE);
                service.addCharacteristic(characteristicWrite);
                bluetoothGattServer.addService(service);
            }

            @Override
            public void onStartFailure(int errorCode) {
                super.onStartFailure(errorCode);
                callback.onStartFailed("Start Failure Code : " + errorCode);
            }
        });
    }

    private BluetoothGattServerCallback bluetoothGattServerCallback = new BluetoothGattServerCallback() {
        @Override
        public void onServiceAdded(int status, BluetoothGattService service) {
            super.onServiceAdded(status, service);

            final String info = service.getUuid().toString();
            Log.d(TAG, "onServiceAdded: " + info);

            callback.onStartSucceed();
        }

        @Override
        public void onConnectionStateChange(BluetoothDevice device, int status, int newState) {
            super.onConnectionStateChange(device, status, newState);
            final String info = device.getAddress() + "|" + status + "->" + newState;
            Log.d(TAG, "onConnectionStateChange: " + info);
        }

        @Override
        public void onCharacteristicWriteRequest(BluetoothDevice device, int requestId, BluetoothGattCharacteristic characteristic, boolean preparedWrite, boolean responseNeeded, int offset, byte[] value) {
            super.onCharacteristicWriteRequest(device, requestId, characteristic, preparedWrite, responseNeeded, offset, value);
            String message = new String(value);

            StringBuilder type = new StringBuilder();
            StringBuilder data = new StringBuilder();

            parseMessage(message, type, data);

            Log.d(TAG, "onCharacteristicWriteRequest: message=" + message + ",type=" + type.toString() + ",data=" + data.toString());
            bluetoothGattServer.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, offset, value);

            callback.onMessageReceived(type.toString(),data.toString());
        }
    };

    public void stop() {

    }


    private static final String kProtocolSeparator = "##rkb-1l0v3y0u3000##";
    private static boolean parseMessage(String message, StringBuilder type, StringBuilder data) {

        int pos = message.indexOf(kProtocolSeparator);
        if (pos == -1) {
            return false;
        }

        type.append(message.substring(0,pos));
        data.append(message.substring(pos + kProtocolSeparator.length()));
        return true;
    }

}
