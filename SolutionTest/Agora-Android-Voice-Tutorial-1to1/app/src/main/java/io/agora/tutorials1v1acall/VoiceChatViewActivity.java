package io.agora.tutorials1v1acall;

import android.Manifest;
import android.content.pm.PackageManager;
import android.graphics.PorterDuff;
import android.nfc.Tag;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v7.app.AppCompatActivity;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.Toast;

import java.util.Locale;

import SoundWriteConverter.SWConverter;
import io.agora.rtc.Constants;
import io.agora.rtc.IAudioEffectManager;
import io.agora.rtc.IRtcEngineEventHandler;
import io.agora.rtc.RtcEngine;

/*
playEffect

soundId	指定音效的 ID。每个音效均有唯一的 ID。如果你已通过 preloadEffect 将音效加载至内存，确保这里的 soundID 与 preloadEffect 设置的 soundID 相同。
filePath	指定要播放的音效文件的绝对路径或 URL 地址
loopCount	设置音效循环播放的次数：
		0：播放音效一次
		1：播放音效两次
		-1：无限循环播放音效，直至调用 stopEffect 或 stopAllEffects 后停止。
pitch	设置音效的音调，取值范围为 [0.5, 2]。默认值为 1.0，表示不需要修改音调。取值越小，则音调越低。
pan	设置是否改变音效的空间位置。取值范围为 [-1.0, 1.0]：
	0.0：音效出现在正前方
	1.0：音效出现在右边
	-1.0：音效出现在左边
gain	设置是否改变单个音效的音量。取值范围为 [0.0, 100.0]。默认值为 100.0。取值越小，则音效的音量越低
publish	设置是否将音效传到远端：
	true：音效在本地播放的同时，会发布到 Agora 云上，因此远端用户也能听到该音效
	false：音效不会发布到 Agora 云上，因此只能在本地听到该音效



* */
public class VoiceChatViewActivity extends AppCompatActivity {

    private static final String LOG_TAG = VoiceChatViewActivity.class.getSimpleName();

    private static final int PERMISSION_REQ_ID_RECORD_AUDIO = 22;
    private VoiceMonitor voiceMonitor;

    private  SWConverter swConverter;

    IAudioEffectManager effectMgr = null;

    String effectFilePath = "/assets/effect.mp3";
    String effectUrlPath = "https://ec-sycdn.kuwo.cn/73b1bf0dc9805a61bfaf44f532dce272/5dfb08fd/resource/n1/47/14/671726578.mp3";

    private RtcEngine mRtcEngine; // Tutorial Step 1
    private final IRtcEngineEventHandler mRtcEventHandler = new IRtcEngineEventHandler() { // Tutorial Step 1

        @Override
        public void onUserOffline(final int uid, final int reason) { // Tutorial Step 4
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Log.i("agora","onUserJoined, uid: " + (uid & 0xFFFFFFFFL));
                    onRemoteUserLeft(uid, reason);
                }
            });
        }

        @Override
        public void onUserMuteAudio(final int uid, final boolean muted) { // Tutorial Step 6
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    onRemoteUserVoiceMuted(uid, muted);
                }
            });
        }

        @Override
        public void onUserJoined(int uid, int elapsed) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Log.i("agora","onUserJoined, uid: " + (uid & 0xFFFFFFFFL));
                }
            });
        }


        @Override
        // 注册 onJoinChannelSuccess 回调。
        // 本地用户成功加入频道时，会触发该回调。
        public void onJoinChannelSuccess(String channel, final int uid, int elapsed) {
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    Log.i("agora","Join channel success, uid: " + (uid & 0xFFFFFFFFL));
                }
            });
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_voice_chat_view);

        if (checkSelfPermission(Manifest.permission.RECORD_AUDIO, PERMISSION_REQ_ID_RECORD_AUDIO)) {
            initAgoraEngineAndJoinChannel();
        }

        // init converter
        swConverter = new SWConverter();
        swConverter.Init(this, voiceMonitor);


        Button effectBtn = findViewById(R.id.effectBtn);

        effectBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Log.i("agora", "effect btn clicked!");
                //effectMgr.playEffect(0,effectFilePath,1,1.0,0.0,100.0,true);
                //effectMgr.playEffect(0,effectUrlPath,1,1.0,0.0,100.0,true);
                effectMgr.playEffect(0,effectFilePath,1,1.0,0.0,100.0,false);
            }
        });

        Button mixBtn = findViewById(R.id.mixBtn);

        mixBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Log.i("agora", "mix btn clicked!");
                //mRtcEngine.startAudioMixing(effectFilePath,false,true,1);
                mRtcEngine.startAudioMixing(effectUrlPath,false,true,1);
            }
        });

        Button convertBtn = findViewById(R.id.convertBtn);
        convertBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Log.i("agora", "convertBtn  btn clicked!");
                //mRtcEngine.startAudioMixing(effectFilePath,false,true,1);
                swConverter.executeStream();
            }
        });

    }

    private void initAgoraEngineAndJoinChannel() {
        initializeAgoraEngine();     // Tutorial Step 1
        joinChannel();               // Tutorial Step 2
    }

    public boolean checkSelfPermission(String permission, int requestCode) {
        Log.i(LOG_TAG, "checkSelfPermission " + permission + " " + requestCode);
        if (ContextCompat.checkSelfPermission(this,
                permission)
                != PackageManager.PERMISSION_GRANTED) {

            ActivityCompat.requestPermissions(this,
                    new String[]{permission},
                    requestCode);
            return false;
        }
        return true;
    }

    @Override
    public void onRequestPermissionsResult(int requestCode,
                                           @NonNull String permissions[], @NonNull int[] grantResults) {
        Log.i(LOG_TAG, "onRequestPermissionsResult " + grantResults[0] + " " + requestCode);

        switch (requestCode) {
            case PERMISSION_REQ_ID_RECORD_AUDIO: {
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    initAgoraEngineAndJoinChannel();
                } else {
                    showLongToast("No permission for " + Manifest.permission.RECORD_AUDIO);
                    finish();
                }
                break;
            }
        }
    }

    public final void showLongToast(final String msg) {
        this.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(getApplicationContext(), msg, Toast.LENGTH_LONG).show();
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        leaveChannel();
        RtcEngine.destroy();
        mRtcEngine = null;
    }

    // Tutorial Step 7
    public void onLocalAudioMuteClicked(View view) {
        ImageView iv = (ImageView) view;
        if (iv.isSelected()) {
            iv.setSelected(false);
            iv.clearColorFilter();
        } else {
            iv.setSelected(true);
            iv.setColorFilter(getResources().getColor(R.color.colorPrimary), PorterDuff.Mode.MULTIPLY);
        }

        mRtcEngine.muteLocalAudioStream(iv.isSelected());
    }

    // Tutorial Step 5
    public void onSwitchSpeakerphoneClicked(View view) {
        ImageView iv = (ImageView) view;
        if (iv.isSelected()) {
            iv.setSelected(false);
            iv.clearColorFilter();
        } else {
            iv.setSelected(true);
            iv.setColorFilter(getResources().getColor(R.color.colorPrimary), PorterDuff.Mode.MULTIPLY);
        }

        mRtcEngine.setEnableSpeakerphone(view.isSelected());
    }

    // Tutorial Step 3
    public void onEncCallClicked(View view) {
        finish();
    }

    // Tutorial Step 1
    private void initializeAgoraEngine() {
        try {
            mRtcEngine = RtcEngine.create(getBaseContext(), getString(R.string.agora_app_id), mRtcEventHandler);
            mRtcEngine.setChannelProfile(Constants.CHANNEL_PROFILE_COMMUNICATION);
            Log.i("VoiceMonitor","Regist VoiceMonitor");
            voiceMonitor = new VoiceMonitor();
            mRtcEngine.registerAudioFrameObserver(voiceMonitor);

            int ret = mRtcEngine.setPlaybackAudioFrameParameters(16000,1,0,160);
            Log.i("VoiceMonitor","setPlaybackAudioFrameParameters ret:" + ret);

            ret = mRtcEngine.setRecordingAudioFrameParameters(16000,1,0,160);

            Log.i("VoiceMonitor","setRecordingAudioFrameParameters ret:" + ret);
            initEffenctMgr();
        } catch (Exception e) {
            Log.e(LOG_TAG, Log.getStackTraceString(e));

            throw new RuntimeException("NEED TO check rtc sdk init fatal error\n" + Log.getStackTraceString(e));
        }
    }

    private  void initEffenctMgr(){

        Log.i("agora", "initEffenctMgr:" + effectFilePath);

        effectMgr = mRtcEngine.getAudioEffectManager();
        //effectMgr.preloadEffect(0, effectFilePath);
    }

    private  void initExternalSouce(){}

    // Tutorial Step 2
    private void joinChannel() {
        String accessToken = getString(R.string.agora_access_token);
        if (TextUtils.equals(accessToken, "") || TextUtils.equals(accessToken, "#YOUR ACCESS TOKEN#")) {
            accessToken = null; // default, no token
        }

        mRtcEngine.joinChannel(accessToken, "demo", "Extra Optional Data", 0); // if you do not specify the uid, we will generate the uid for you
    }

    // Tutorial Step 3
    private void leaveChannel() {
        mRtcEngine.leaveChannel();
    }

    // Tutorial Step 4
    private void onRemoteUserLeft(int uid, int reason) {
        showLongToast(String.format(Locale.US, "user %d left %d", (uid & 0xFFFFFFFFL), reason));
        View tipMsg = findViewById(R.id.quick_tips_when_use_agora_sdk); // optional UI
        tipMsg.setVisibility(View.VISIBLE);
    }

    // Tutorial Step 6
    private void onRemoteUserVoiceMuted(int uid, boolean muted) {
        showLongToast(String.format(Locale.US, "user %d muted or unmuted %b", (uid & 0xFFFFFFFFL), muted));
    }
}
