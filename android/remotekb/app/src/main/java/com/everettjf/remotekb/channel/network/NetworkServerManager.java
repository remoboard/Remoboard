package com.everettjf.remotekb.channel.network;

import android.util.Log;


/**
 * Two Connect Mode JNI Bridge
 * - Socket Mode
 * - Http Mode
 */
public class NetworkServerManager {
    private static final String TAG = "NetworkServerManager";

    // Used to load the 'native-lib' library on application startup.
    static {
        System.loadLibrary("native-lib");
    }

    // Called before all methods below
    public static native void init();

    // Utility
    public static native String getVersion();
    public static native String ip2code(String ip);

    // Socket Mode
    public static native void socketServerStart();
    public static native void socketServerStop();

    // Http Mode
    public static native void httpServerStart(String rootDir, String port);
    public static native void httpServerStop();

    public interface OnChatEventListener {
        /**
         * callback
         * @param connectMode socket | http
         * @param type
         * @param cmd
         * @param data
         */
        void onMessage(String connectMode,String type, String cmd, String data);
    }

    public static OnChatEventListener mListener;

    public static void onMessage(String connectMode, String type, String cmd, String data) {
        Log.d(TAG, "onMessage: connectMode=" + connectMode + ", type=" + type + ",cmd=" + cmd + ",data=" + data);

        mListener.onMessage(connectMode, type,cmd,data);
    }

}
