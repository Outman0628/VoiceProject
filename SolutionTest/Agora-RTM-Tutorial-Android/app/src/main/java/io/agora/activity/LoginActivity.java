package io.agora.activity;


import android.app.Activity;
import android.content.Intent;
import android.nfc.Tag;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import java.util.Date;

import io.agora.communication.Communication;
import io.agora.communication.RetData;
import io.agora.communication.TokenData;
import io.agora.rtm.ErrorInfo;
import io.agora.rtm.ResultCallback;
import io.agora.rtm.RtmClient;
import io.agora.rtmtutorial.AGApplication;
import io.agora.rtmtutorial.R;
import io.agora.rtmtutorial.ChatManager;
import io.agora.utils.MessageUtil;


public class LoginActivity extends Activity {
    private final String TAG = LoginActivity.class.getSimpleName();

    private TextView mLoginBtn;
    private EditText mUserIdEditText;
    private String mUserId;

    private ChatManager mChatManager;
    private RtmClient mRtmClient;
    private boolean mIsInChat = false;
    private static TokenData tokenData = null;
    private static boolean TmpTockenMode = false;
    private static Activity activity = null;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        activity = this;
        setContentView(R.layout.activity_login);

        mUserIdEditText = findViewById(R.id.user_id);
        mUserIdEditText.setEnabled(false);

        InitTockenData();

        mLoginBtn = findViewById(R.id.button_login);

        //mChatManager = AGApplication.the().getChatManager();
        //mRtmClient = mChatManager.getRtmClient();
    }

    public void initChatMgr()
    {
        String appId = "";
        if(TmpTockenMode)
        {
            appId = this.getString(R.string.agora_app_id);
        }
        else
        {
            appId = tokenData.appID;
        }

        Log.i(TAG, "initChatMgr app id:" + appId);
        AGApplication.the().InitChatMgr(appId);

        mChatManager = AGApplication.the().getChatManager();
        mRtmClient = mChatManager.getRtmClient();
    }

    public void onClickLogin(View v) {
        mUserId = mUserIdEditText.getText().toString();
        if (mUserId.equals("")) {
            showToast(getString(R.string.account_empty));
        } else if (mUserId.length() > MessageUtil.MAX_INPUT_NAME_LENGTH) {
            showToast(getString(R.string.account_too_long));
        } else if (mUserId.startsWith(" ")) {
            showToast(getString(R.string.account_starts_with_space));
        } else if (mUserId.equals("null")) {
            showToast(getString(R.string.account_literal_null));
        } else {
            mLoginBtn.setEnabled(false);
            doLogin();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        mLoginBtn.setEnabled(true);
        if (mIsInChat) {
            doLogout();
        }
    }

    private void InitTockenData()
    {
        if(TmpTockenMode)
        {
            TokenData data = new TokenData();
            Date dt = new Date();
            Integer time = (int) (dt.getTime());
            data.uid = time.toString();
            data.channel = "chanelone";
            data.appID = getString(R.string.agora_app_id);
            data.token = null;

            tokenData = data;

            mUserIdEditText.setText(data.uid.toString());
            //initEngineAndJoinChannel(data);
            initChatMgr();
            return;
        }

        if(tokenData == null) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    Date dt = new Date();
                    Integer time = (int) (dt.getTime());
                    String req = "http://voice.enjoyst.com/dapi/agora/rtm-option?uid=";
                    //req += "chanelone";
                    req += "&uid=" + time.toString();
                    Log.i(TAG, "http req:" + req);
                    Communication communication = new Communication();
                    String ret = communication.doGet(req);
                    Log.i(TAG, "http ret:" + ret);

                    if (ret != null && ret.length() > 0) {
                        RetData data = RetData.FromJson(ret);
                        tokenData = data.data;
                        Log.i(TAG, "ret tocken" + data.data.token);

                        activity.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                //initAd(aActivity);
                                mUserIdEditText.setText(tokenData.uid.toString());
                                initChatMgr();
                            }
                        });
                    }


                }
            }).start();
        }
        else {
            TokenData data = new TokenData();
            Date dt = new Date();
            Integer time = (int) (dt.getTime());
            data.uid = time.toString();
            data.channel = "chanelone";
            data.appID = getString(R.string.agora_app_id);
            data.token = null;

            mUserIdEditText.setText(data.uid.toString());
            initChatMgr();
        }

    }

    /**
     * API CALL: login RTM server
     */
    private void doLogin() {
        mIsInChat = true;
        Log.i(TAG, "log in token data:" + tokenData.token + " ; user id:" + mUserId);
        mRtmClient.login(tokenData.token, mUserId, new ResultCallback<Void>() {
            @Override
            public void onSuccess(Void responseInfo) {
                Log.i(TAG, "login success");
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Intent intent = new Intent(LoginActivity.this, SelectionActivity.class);
                        intent.putExtra(MessageUtil.INTENT_EXTRA_USER_ID, mUserId);
                        startActivity(intent);
                    }
                });
            }

            @Override
            public void onFailure(ErrorInfo errorInfo) {
                Log.i(TAG, "login failed: " + errorInfo.getErrorCode());
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        mLoginBtn.setEnabled(true);
                        mIsInChat = false;
                        showToast(getString(R.string.login_failed));
                    }
                });
            }
        });
    }

    /**
     * API CALL: logout from RTM server
     */
    private void doLogout() {
        mRtmClient.logout(null);
        MessageUtil.cleanMessageListBeanList();
    }

    private void showToast(String text) {
        Toast.makeText(this, text, Toast.LENGTH_SHORT).show();
    }
}
