package com.everettjf.remotekb;

import android.content.Intent;
import android.inputmethodservice.InputMethodService;
import android.os.Handler;
import android.os.Looper;
import android.os.PowerManager;
import android.util.Log;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.ExtractedText;
import android.view.inputmethod.ExtractedTextRequest;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.everettjf.remotekb.channel.ChannelService;
import com.everettjf.remotekb.channel.ChannelServiceFactory;
import com.everettjf.remotekb.logic.KBSetting;

public class KeyboardIME extends InputMethodService {
    private static final String TAG = "KeyboardIME";

    private TextView mTextViewMessage;

    private Handler handler = new Handler(Looper.getMainLooper());
    private ChannelService channelService;

    private PowerManager.WakeLock mWakeLock;

    private void screenLock() {
        if (mWakeLock != null && !mWakeLock.isHeld()) {
            mWakeLock.acquire();
            return;
        }
        mWakeLock = ((PowerManager)getSystemService(POWER_SERVICE)).newWakeLock(PowerManager.SCREEN_BRIGHT_WAKE_LOCK | PowerManager.ON_AFTER_RELEASE, "everettjf:remoboard");
        if (mWakeLock != null) {
            mWakeLock.acquire();
        }
    }
    private void screenUnlock() {
        if (mWakeLock != null) {
            mWakeLock.release();
            mWakeLock = null;
        }
    }

    @Override
    public void onCreate() {
        super.onCreate();

    }


    @Override
    public void onDestroy() {
        super.onDestroy();

    }

    @Override
    public void onFinishInput() {
        super.onFinishInput();

        screenUnlock();
    }

    @Override
    public void onStartInput(EditorInfo attribute, boolean restarting) {
        super.onStartInput(attribute, restarting);

    }

    @Override
    public void updateInputViewShown() {
        super.updateInputViewShown();

        if (isInputViewShown()) {
            screenLock();
        }
    }

    @Override
    public View onCreateInputView() {
        LinearLayout inputView = (LinearLayout) getLayoutInflater().inflate(R.layout.keyboard_view, null);
        mTextViewMessage = inputView.findViewById(R.id.textview_message);

        Button buttonReturn = inputView.findViewById(R.id.button_return);
        buttonReturn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                InputConnection ic = getCurrentInputConnection();
                ic.commitText("\n", 1);
            }
        });

        Button buttonHelp = inputView.findViewById(R.id.button_help);
        buttonHelp.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent launchIntent = getPackageManager().getLaunchIntentForPackage("com.everettjf.remoboard");
                launchIntent.putExtra("goto", "help");
                if (launchIntent != null) {
                    startActivity(launchIntent);
                }
            }
        });

        Button buttonSwitch = inputView.findViewById(R.id.button_switch);
        buttonSwitch.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                InputMethodManager imm = (InputMethodManager) getSystemService(INPUT_METHOD_SERVICE);
                imm.showInputMethodPicker();
            }
        });

        Button buttonReset = inputView.findViewById(R.id.button_reset);
        buttonReset.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                recreateChannel();
            }
        });

        return inputView;
    }

    @Override
    public void onStartInputView(EditorInfo info, boolean restarting) {
        super.onStartInputView(info, restarting);

        mTextViewMessage.setText("Listening...");

        recreateChannel();
    }

    private void recreateChannel() {
        int connectMode = KBSetting.getInstance().getConnectMode(this);

        if (connectMode == KBSetting.ConnectModeHTTP) {
            channelService = ChannelServiceFactory.createChannel(ChannelService.ChannelServiceType_Http);
        } else if (connectMode == KBSetting.ConnectModeBLE) {
            channelService = ChannelServiceFactory.createChannel(ChannelService.ChannelServiceType_Bluetooth);
        } else {
            channelService = ChannelServiceFactory.createChannel(ChannelService.ChannelServiceType_IPNetwork);
        }
        channelService.init(this);
        channelService.start(new ChannelService.Callback() {
            @Override
            public void onStartFailed(final String error) {
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        mTextViewMessage.setText(error);
                    }
                });
            }

            @Override
            public void onStartSucceed(final String info) {

                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        mTextViewMessage.setText(info);
                    }
                });
            }

            @Override
            public void onClientConnected() {
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        mTextViewMessage.setText(getstr(R.string.msg_connected));
                    }
                });
            }

            @Override
            public void onClientDisconnected() {
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        mTextViewMessage.setText(getstr(R.string.msg_disconnected));
                    }
                });
            }

            @Override
            public void onMessageReceived(final String type, final String data) {
                handler.post(new Runnable() {
                    @Override
                    public void run() {
                        onProcessReceiveMessageInUIThread(type,data);
                    }
                });
            }
        });
    }

    public void onProcessReceiveMessageInUIThread(String cmd, String data) {
        Log.d(TAG, "onMessage: cmd="+cmd + ",data="+data);

        if (cmd.equals("input")) {
            InputConnection ic = getCurrentInputConnection();
            ic.commitText(data, 1);
        } else if (cmd.equals("input-delete")) {
            InputConnection ic = getCurrentInputConnection();
            ic.deleteSurroundingText(1, 0);
        } else if (cmd.equals("move-left")) {
            moveCursor(-1);
        } else if (cmd.equals("move-right")) {
            moveCursor(1);
        } else if (cmd.equals("move-up")) {
            moveCursor(-10);
        } else if (cmd.equals("move-down")) {
            moveCursor(10);
        } else {
            Log.d(TAG, "onRemoteMessage: unknown cmd = " + cmd);
        }
    }


    @Override
    public boolean onEvaluateFullscreenMode() {
        return super.onEvaluateFullscreenMode();
    }

    private void moveCursor(int step) {
        InputConnection ic = getCurrentInputConnection();
        ExtractedText extractedText = ic.getExtractedText(new ExtractedTextRequest(), 0);
        int startIndex = extractedText.startOffset + extractedText.selectionStart;
        int toIndex = startIndex + step;
        ic.setSelection(toIndex,toIndex);
    }


    private String getstr(int resourceId) {
        return getResources().getString(resourceId);
    }

}
