package com.everettjf.remotekb.logic;

import android.content.Context;
import android.content.SharedPreferences;

public class KBSetting {
    private static final String Key_ConnectMode = "connect-mode";

    public static final int ConnectModeHTTP = 0;
    public static final int ConnectModeIP = 1;
    public static final int ConnectModeBLE = 2;

    private static KBSetting mInstance = null;
    public synchronized static KBSetting getInstance() {
        if (mInstance == null) {
            mInstance = new KBSetting();
        }
        return mInstance;
    }

    public void setConnectMode(Context context, int mode) {
        SharedPreferences preferences = context.getSharedPreferences("global", Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.putInt(Key_ConnectMode, mode);
        editor.commit();
    }

    public int getConnectMode(Context context) {
        SharedPreferences preferences = context.getSharedPreferences("global", Context.MODE_PRIVATE);
        return preferences.getInt(Key_ConnectMode,0);
    }


}
