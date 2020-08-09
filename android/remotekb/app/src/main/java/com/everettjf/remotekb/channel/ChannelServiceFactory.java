package com.everettjf.remotekb.channel;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiManager;
import android.os.Environment;
import android.util.Log;

import com.everettjf.remotekb.R;
import com.everettjf.remotekb.channel.bluetooth.BluetoothServerCallback;
import com.everettjf.remotekb.channel.bluetooth.BluetoothServerManager;
import com.everettjf.remotekb.channel.network.NetworkServerManager;
import com.everettjf.remotekb.logic.Util;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

import static android.content.ContentValues.TAG;

public class ChannelServiceFactory {
    public static class BluetoothChannelService implements ChannelService {
        Context mContext;
        @Override
        public void init(Context context) {
            mContext = context;
            BluetoothServerManager.getInstance().context = context;
        }

        private String getstr(int resourceId) {
            return mContext.getResources().getString(resourceId);
        }

        @Override
        public void start(final Callback callback) {
            BluetoothServerManager.getInstance().callback = new BluetoothServerCallback() {
                @Override
                public void onStartFailed(String error) {
                    callback.onStartFailed(error);
                }

                @Override
                public void onStartSucceed() {
                    callback.onStartSucceed(getstr(R.string.ble_messageaccesspoint) + " : Remoboard");
                }

                @Override
                public void onMessageReceived(String type, String data) {
                    callback.onMessageReceived(type,data);
                }
            };

            BluetoothServerManager.getInstance().stop();
            BluetoothServerManager.getInstance().start();
        }
    }

    public static class IPNetworkChannelService implements ChannelService {
        private static final String TAG = "IPNetworkChannelService";

        Context mContext;

        private String getstr(int resourceId) {
            return mContext.getResources().getString(resourceId);
        }

        private boolean isWifiOpened() {
            WifiManager wifiManager = (WifiManager) mContext.getSystemService(Context.WIFI_SERVICE);
            return wifiManager.isWifiEnabled();
        }
        private boolean isWifiConnected() {
            ConnectivityManager connectivityManager = (ConnectivityManager)mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo wifiNetworkInfo = connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
            return wifiNetworkInfo.isConnected();
        }

        @Override
        public void init(Context context) {
            mContext = context;
            NetworkServerManager.init();
        }

        @Override
        public void start(final Callback callback) {
            if (!isWifiOpened()) {
                callback.onStartFailed(getstr(R.string.msg_wifi_not_enabled));
                return;
            }

            if (!isWifiConnected()) {
                callback.onStartFailed(getstr(R.string.msg_wifi_not_connected));
                return;
            }

            String connCode;
            String ipAddress = Util.getIpAddress(mContext);
            if (ipAddress == null) {
                connCode = getstr(R.string.wifi_wifinotconnected);
                callback.onStartFailed(connCode);
                return;
            }
            String code = NetworkServerManager.ip2code(ipAddress);
            connCode = getstr(R.string.wifi_connectioncode) + ": " + code +"\n"
            + getstr(R.string.wifi_ipaddress) + ": " + ipAddress + "\n"
            + getstr(R.string.wifi_waitingforconnection) + "..."
            ;
            callback.onStartSucceed(connCode);


            NetworkServerManager.mListener = new NetworkServerManager.OnChatEventListener() {
                @Override
                public void onMessage(String mode, String type, String cmd, String data) {
                    if (!mode.equals("socket")) {
                        return;
                    }

                    Log.d(TAG, "onMessage: " + type + ", cmd=" + cmd + ", data=" + data);
                    if(type.equals("status")) {
                        if (cmd.equals("connected")) {
                            callback.onClientConnected();
                        } else if (cmd.equals("disconnected")) {
                            callback.onClientDisconnected();
                        }
                    } else if (type.equals("message")) {
                        callback.onMessageReceived(cmd,data);
                    } else {
                        Log.d(TAG, "onMessage: unknown type:" + type);
                    }
                }
            };

            NetworkServerManager.socketServerStart();
        }
    }

    public static class HttpChannelService implements ChannelService {
        Context mContext;

        private String getstr(int resourceId) {
            return mContext.getResources().getString(resourceId);
        }

        private boolean isWifiOpened() {
            WifiManager wifiManager = (WifiManager) mContext.getSystemService(Context.WIFI_SERVICE);
            return wifiManager.isWifiEnabled();
        }
        private boolean isWifiConnected() {
            ConnectivityManager connectivityManager = (ConnectivityManager)mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
            NetworkInfo wifiNetworkInfo = connectivityManager.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
            return wifiNetworkInfo.isConnected();
        }

        @Override
        public void init(Context context) {
            mContext = context;

            NetworkServerManager.init();
        }

        @Override
        public void start(final Callback callback) {
            if (!isWifiOpened()) {
                callback.onStartFailed(getstr(R.string.msg_wifi_not_enabled));
                return;
            }

            if (!isWifiConnected()) {
                callback.onStartFailed(getstr(R.string.msg_wifi_not_connected));
                return;
            }

            String ipAddress = Util.getIpAddress(mContext);
            if (ipAddress == null) {
                callback.onStartFailed(getstr(R.string.wifi_wifinotconnected));
                return;
            }
            String urlMessage = "http://" + ipAddress + ":7777";
            callback.onStartSucceed(urlMessage);

            NetworkServerManager.mListener = new NetworkServerManager.OnChatEventListener() {
                @Override
                public void onMessage(String mode, String type, String cmd, String data) {
                    if (!mode.equals("http")) {
                        return;
                    }
                    Log.d(TAG, "onMessage: " + type + ", cmd=" + cmd + ", data=" + data);
                    if (type.equals("message")) {
                        callback.onMessageReceived(cmd,data);
                    } else {
                        Log.d(TAG, "onMessage: unknown type:" + type);
                    }
                }
            };

            // Prepare site files
            checkSyncSiteFiles();

            String rootDir = mContext.getFilesDir().getAbsolutePath() + "/site";
            String port = "7777";
            NetworkServerManager.httpServerStart(rootDir, port);
        }

        private void checkSyncSiteFiles() {

            String rootDir = mContext.getFilesDir().getAbsolutePath() + "/site";

            File siteDir = new File(rootDir);
            if (!siteDir.exists()) {
                siteDir.mkdir();
            }

            // Check if already copied
            String appVersion = Util.getAppVersion(mContext);
            String fileVersionPath = rootDir + "/appversion.txt";
            String fileVersion = Util.readFileContent(fileVersionPath);
            if (! fileVersion.isEmpty()) {
                if (appVersion.equals(fileVersion)) {
                    // Already copied
                    return;
                }
            }

            Map<String, Integer> files = new HashMap<>();
            files.put("index.html", R.raw.index);
            files.put("favicon.ico", R.raw.favicon);

            boolean hasError = false;
            for (Map.Entry<String, Integer> entry: files.entrySet() ) {
                String fileName = entry.getKey();
                Integer resourceId = entry.getValue();

                if (!Util.copyFileFromRaw(rootDir + "/" + fileName, mContext, resourceId) ) {
                    Log.d(TAG, "start: copy site files failed");
                    hasError = true;
                }
            }

            // mark finished
            if (!hasError) {
                Util.writeFileContent(fileVersionPath, appVersion);
            }
        }
    }


    public static ChannelService createChannel(int channelServiceType) {
        if (channelServiceType == ChannelService.ChannelServiceType_Http) {
            return new HttpChannelService();
        } else if (channelServiceType == ChannelService.ChannelServiceType_IPNetwork) {
            return new IPNetworkChannelService();
        } else if (channelServiceType == ChannelService.ChannelServiceType_Bluetooth) {
            return new BluetoothChannelService();
        } else {
            return null;
        }
    }
}
