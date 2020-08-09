package com.everettjf.remotekb;

import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.provider.Settings;
import android.support.v7.app.AlertDialog;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.ListView;

import com.everettjf.remotekb.logic.KBSetting;
import com.everettjf.remotekb.logic.RowAdapter;
import com.everettjf.remotekb.logic.RowItem;

import java.util.ArrayList;
import java.util.List;

public class LabActivity extends AppCompatActivity {
    private List<RowItem> rowList = new ArrayList<>();
    private static final String TAG = "LabActivity";

    private Context mContext;

    private String getstr(int resourceId) {
        return getResources().getString(resourceId);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_lab);

        mContext = this;

        rowList.add(new RowItem(getstr(R.string.title_general),true));
        rowList.add(new RowItem(R.drawable.usage, getstr(R.string.title_whatislab), new RowItem.TapCallback() {
            @Override
            public void onClicked() {
                openLabSite();
            }
        }));
        rowList.add(new RowItem(R.drawable.desktop, getstr(R.string.title_downloaddesktop), new RowItem.TapCallback() {

            @Override
            public void onClicked() {
                openLabSite();
            }
        }));

        rowList.add(new RowItem(getstr(R.string.title_labconfig), true));

        rowList.add(new RowItem(R.drawable.auth, getstr(R.string.title_connectionmode), new RowItem.TapCallback() {
            @Override
            public void onClicked() {
                chooseConnectionMode();
            }
        }));

        RowAdapter adapter = new RowAdapter(LabActivity.this,R.layout.row_item, rowList);
        ListView listView = findViewById(R.id.lab_list_view);
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

    private void openLabSite() {
        if (isZhcn()) {
            openUrl("https://remoboard.app/zhcn/lab");
        } else {
            openUrl("https://remoboard.app/lab");
        }
    }

    private boolean isZhcn() {
        String lang = LanguageUtil.getCurrentLocale(this).getLanguage();
        return lang.contains("zh");
    }


    public void chooseConnectionMode() {
        final Context context = this;

        String itemNameHttp = getstr(R.string.title_connectbyhttp);
        String itemNameBluetooth = getstr(R.string.title_connectbybluetooth);
        String itemNameIP = getstr(R.string.title_connectbyip);

        int mode = KBSetting.getInstance().getConnectMode(this);
        if (mode == KBSetting.ConnectModeHTTP) {
            // HTTP
            itemNameHttp = "■ " + itemNameHttp;
            itemNameBluetooth = "□ " + itemNameBluetooth;
            itemNameIP = "□ " + itemNameIP;

        } else if (mode == KBSetting.ConnectModeIP) {
            // IP
            itemNameHttp = "□ " + itemNameHttp;
            itemNameBluetooth = "□ " + itemNameBluetooth;
            itemNameIP = "■ " + itemNameIP;

        } else if (mode == KBSetting.ConnectModeBLE) {
            // Bluetooth
            itemNameHttp = "□ " + itemNameHttp;
            itemNameBluetooth = "■ " + itemNameBluetooth;
            itemNameIP = "□ " + itemNameIP;
        }


        final CharSequence[] items = {itemNameHttp, itemNameBluetooth, itemNameIP};

        AlertDialog.Builder builder = new AlertDialog.Builder(mContext);
        builder.setTitle(getstr(R.string.title_chooseconnectionmode));
        builder.setCancelable(true);

        builder.setItems(items, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                if (which == 0) {
                    KBSetting.getInstance().setConnectMode(context, KBSetting.ConnectModeHTTP);
                } else if (which == 1) {
                    KBSetting.getInstance().setConnectMode(context, KBSetting.ConnectModeBLE);
                } else if (which == 2) {
                    KBSetting.getInstance().setConnectMode(context, KBSetting.ConnectModeIP);
                }

                dialog.dismiss();
            }
        });

        AlertDialog alert = builder.create();
        alert.show();
    }

}
