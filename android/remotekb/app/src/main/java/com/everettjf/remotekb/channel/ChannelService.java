package com.everettjf.remotekb.channel;

import android.content.Context;

public interface ChannelService {
    int ChannelServiceType_Http = 0;
    int ChannelServiceType_IPNetwork = 1;
    int ChannelServiceType_Bluetooth = 2;

    interface Callback {

        void onStartFailed(String error);

        void onStartSucceed(String info);

        void onClientConnected();

        void onClientDisconnected();

        void onMessageReceived(String type, String data);

    }

    /**
     * called once after channel created
     */
    void init(Context context);

    /**
     * may called multiple times after channel created
     * @param callback
     */
    void start(Callback callback);
}
