package com.everettjf.remotekb;

import android.app.Application;
import android.content.res.Configuration;

import java.util.Locale;

public class MyApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        languageWork();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        languageWork();
    }

    private void languageWork() {
        Locale locale = LanguageUtil.getLocale(this);
        LanguageUtil.updateLocale(this, locale);
    }
}
