package com.everettjf.remotekb;

import android.app.Activity;
import android.content.DialogInterface;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.net.Uri;
import android.os.Build;
import android.os.LocaleList;
import android.support.annotation.RequiresApi;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.content.Context;
import android.content.Intent;
import android.provider.Settings;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ListView;

import com.everettjf.remotekb.logic.RowAdapter;
import com.everettjf.remotekb.logic.RowItem;
import com.everettjf.remotekb.logic.Util;

import com.microsoft.appcenter.AppCenter;
import com.microsoft.appcenter.analytics.Analytics;
import com.microsoft.appcenter.crashes.Crashes;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {
    private List<RowItem> rowList = new ArrayList<>();

    private static final String TAG = "MainActivity";

    private Context mContext;

    private String getstr(int resourceId) {
        return getResources().getString(resourceId);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        mContext = this;

        AppCenter.start(getApplication(), "e485213a-ade0-49a1-9ce8-75d1466ccc44",
                Analytics.class, Crashes.class);

        rowList.add(new RowItem(getstr(R.string.title_general),true));
        rowList.add(new RowItem(R.drawable.usage, getstr(R.string.title_howtouse), new RowItem.TapCallback() {
            @Override
            public void onClicked() {
                openSite();
            }
        }));

        rowList.add(new RowItem(getstr(R.string.title_quickconfig), true));
        rowList.add(new RowItem(R.drawable.setup, getstr(R.string.title_enablekeyboard), new RowItem.TapCallback() {
            @Override
            public void onClicked() {
                Intent enableIntent = new Intent(Settings.ACTION_INPUT_METHOD_SETTINGS);
                enableIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                MainActivity.this.startActivity(enableIntent);
            }
        }));
        rowList.add(new RowItem(R.drawable.switchkb, getstr(R.string.title_switchkeyboard), new RowItem.TapCallback() {
            @Override
            public void onClicked() {
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.showInputMethodPicker();
            }
        }));

        rowList.add(new RowItem(R.drawable.test, getstr(R.string.title_testinput), new RowItem.TapCallback() {
            @Override
            public void onClicked() {
                Intent intent = new Intent(MainActivity.this, TestInputActivity.class);
                startActivity(intent);
            }
        }));

        rowList.add(new RowItem(getstr(R.string.title_feedback), true));
        rowList.add(new RowItem(R.drawable.face, getstr(R.string.title_email), new RowItem.TapCallback() {
            @Override
            public void onClicked() {
                openUrl("mailto:everettjf@live.com?subject=Remoboard_Android");
            }
        }));
        rowList.add(new RowItem(R.drawable.weibo, getstr(R.string.title_weibo), new RowItem.TapCallback() {
            @Override
            public void onClicked() {
                openUrl("https://weibo.com/everettjf");
            }
        }));
        rowList.add(new RowItem(R.drawable.wechat, getstr(R.string.title_wechat), new RowItem.TapCallback() {
            @Override
            public void onClicked() {
                openUrl("https://everettjf.github.io/bukuzao/");
            }
        }));

        if (isZhcn()) {
            rowList.add(new RowItem(R.drawable.qq, getstr(R.string.title_qqgroup), new RowItem.TapCallback() {
                @Override
                public void onClicked() {
                    joinQQGroup();
                }
            }));
        } else {
            rowList.add(new RowItem(R.drawable.telegram, getstr(R.string.title_telegram), new RowItem.TapCallback() {
                @Override
                public void onClicked() {
                    openUrl("https://t.me/remoboard");
                }
            }));
        }

        rowList.add(new RowItem(getstr(R.string.title_more), true));
        rowList.add(new RowItem(R.drawable.lab, getstr(R.string.title_lab), new RowItem.TapCallback() {
            @Override
            public void onClicked() {
                Intent intent = new Intent(MainActivity.this, LabActivity.class);
                startActivity(intent);
            }
        }));
        rowList.add(new RowItem(R.drawable.app, getstr(R.string.title_appversion) + " " + getAppVersion(), new RowItem.TapCallback() {
            @Override
            public void onClicked() {
            }
        }));
        rowList.add(new RowItem(R.drawable.language, getstr(R.string.title_language), new RowItem.TapCallback() {
            @Override
            public void onClicked() {
                chooseLanguage();
            }
        }));

        RowAdapter adapter = new RowAdapter(MainActivity.this,R.layout.row_item, rowList);
        ListView listView = findViewById(R.id.list_view);
        listView.setAdapter(adapter);
        listView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                RowItem row = rowList.get(position);

                if (row.getTapCallback() != null) {
                    row.getTapCallback().onClicked();
                }
            }
        });
    }

    private void openUrl(String url) {
        Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        startActivity(browserIntent);
    }

    private void openSite() {
        if (isZhcn()) {
            openUrl("https://remoboard.app/zhcn/");
        } else {
            openUrl("https://remoboard.app/");
        }
    }

    @Override
    protected void attachBaseContext(Context newBase) {
        Context context = languageWork(newBase);
        super.attachBaseContext(context);

    }

    private Context languageWork(Context context) {
        // 8.0及以上使用createConfigurationContext设置configuration
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return updateResources(context);
        } else {
            return context;
        }
    }

    @RequiresApi(api = Build.VERSION_CODES.O)
    private Context updateResources(Context context) {
        Resources resources = context.getResources();
        Locale locale = LanguageUtil.getLocale(context);
        if (locale==null) {
            return context;
        }
        Configuration configuration = resources.getConfiguration();
        configuration.setLocale(locale);
        configuration.setLocales(new LocaleList(locale));
        return context.createConfigurationContext(configuration);
    }


    private void chooseLanguage() {
        final CharSequence[] items = {"English", "简体中文"};

        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
        builder.setTitle(getstr(R.string.title_chooselanguage));
        builder.setCancelable(true);

        final Activity parent = this;
        builder.setItems(items, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                boolean need = false;
                if (which == 0) {
                    // English
                    need = LanguageUtil.updateLocale(parent, LanguageUtil.LOCALE_ENGLISH);
                } else {
                    // 简体中文
                    need = LanguageUtil.updateLocale(parent, LanguageUtil.LOCALE_CHINESE);
                }

                if (need) {
                    ActivityManager.getInstance().recreateAllOtherActivity(parent);
                    parent.recreate();
                }

                dialog.dismiss();
            }
        });

        AlertDialog alert = builder.create();
        alert.show();
    }

    private boolean isZhcn() {
        String lang = LanguageUtil.getCurrentLocale(this).getLanguage();
        return lang.contains("zh");
    }
    private String getAppVersion() {
        return Util.getAppVersion(this);
    }

    /****************
     *
     * 发起添加群流程。群号：远程输入法Remoboard(486615112) 的 key 为： izj5WPLcGbqj7yoTG5-iL_75jrgUzxQJ
     * 调用 joinQQGroup(izj5WPLcGbqj7yoTG5-iL_75jrgUzxQJ) 即可发起手Q客户端申请加群 远程输入法Remoboard(486615112)
     *
     * @param key 由官网生成的key
     * @return 返回true表示呼起手Q成功，返回fals表示呼起失败
     ******************/
    public boolean joinQQGroup() {
        String key = "izj5WPLcGbqj7yoTG5-iL_75jrgUzxQJ";
        Intent intent = new Intent();
        intent.setData(Uri.parse("mqqopensdkapi://bizAgent/qm/qr?url=http%3A%2F%2Fqm.qq.com%2Fcgi-bin%2Fqm%2Fqr%3Ffrom%3Dapp%26p%3Dandroid%26k%3D" + key));
        // 此Flag可根据具体产品需要自定义，如设置，则在加群界面按返回，返回手Q主界面，不设置，按返回会返回到呼起产品界面    //intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            startActivity(intent);
            return true;
        } catch (Exception e) {
            // 未安装手Q或安装的版本不支持
            return false;
        }
    }


}
