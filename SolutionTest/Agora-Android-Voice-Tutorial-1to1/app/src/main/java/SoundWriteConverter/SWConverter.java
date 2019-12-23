package SoundWriteConverter;


import android.app.Activity;
import android.content.SharedPreferences;
import android.nfc.Tag;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;
import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.ErrorCode;
import com.iflytek.cloud.InitListener;
import com.iflytek.cloud.LexiconListener;
import com.iflytek.cloud.RecognizerListener;
import com.iflytek.cloud.RecognizerResult;
import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.SpeechError;
import com.iflytek.cloud.SpeechRecognizer;
import com.iflytek.cloud.ui.RecognizerDialog;
import com.iflytek.cloud.ui.RecognizerDialogListener;
import com.iflytek.cloud.util.ContactManager;
import com.iflytek.cloud.util.ContactManager.ContactListener;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import org.json.JSONException;
import org.json.JSONObject;

import io.agora.tutorials1v1acall.VoiceMonitor;

public class SWConverter {
    private static String TAG = "SWConverter";
    // 语音听写对象
    private SpeechRecognizer mIat;
    // 语音听写UI
   // private RecognizerDialog mIatDialog;
    // 用HashMap存储听写结果
    private HashMap<String, String> mIatResults = new LinkedHashMap<String, String>();


    private TextView languageText;
    private Toast mToast;
    private SharedPreferences mSharedPreferences;
    // 引擎类型
    private String mEngineType = SpeechConstant.TYPE_CLOUD;

    private String[] languageEntries ;
    private String[] languageValues;
    private String language="zh_cn";
    private int selectedNum=0;

    private String resultType = "json";

    private boolean cyclic = false;//音频流识别是否循环调用

    private StringBuffer buffer = new StringBuffer();

    private Activity activity;

    private  VoiceMonitor monitor;

    private boolean isFromAgora = true;

    int ret = 0; // 函数调用返回值
    private static int flg=0;

    Handler han = new Handler(){

        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            if (msg.what == 0x001) {
                executeStream();
            }
        }
    };


    public void Init(Activity aActivity, VoiceMonitor aVoiceMonitor)
    {
        monitor = aVoiceMonitor;
        activity = aActivity;
        //url = new URI(BASE_URL + getHandShakeParams(APPID, SECRET_KEY));
        mIat = SpeechRecognizer.createRecognizer(activity, mInitListener);

        if( null == mIat ){
            // 创建单例失败，与 21001 错误为同样原因，参考 http://bbs.xfyun.cn/forum.php?mod=viewthread&tid=9688
            Log.e(TAG, "创建对象失败，请确认 libmsc.so 放置正确，且有调用 createUtility 进行初始化" );
            return;
        }
        else
        {
            Log.i(TAG,"创建对象成功！");
        }

        mSharedPreferences = aActivity.getSharedPreferences(IatSettings.PREFER_NAME,
                Activity.MODE_PRIVATE);

    }

    /**
     * 初始化监听器。
     */
    private InitListener mInitListener = new InitListener() {

        @Override
        public void onInit(int code) {
            Log.d(TAG, "SpeechRecognizer init() code = " + code);
            if (code != ErrorCode.SUCCESS) {
                Log.e(TAG,"初始化失败，错误码：" + code+",请点击网址https://www.xfyun.cn/document/error-code查询解决方案");
            }
        }
    };

    //执行音频流识别操作
    public void executeStream() {
        buffer.setLength(0);
        //mResultText.setText(null);// 清空显示内容
        mIatResults.clear();
        // 设置参数
        setParam();
        // 设置音频来源为外部文件
        mIat.setParameter(SpeechConstant.AUDIO_SOURCE, "-1");
        // 也可以像以下这样直接设置音频文件路径识别（要求设置文件在sdcard上的全路径）：
        // mIat.setParameter(SpeechConstant.AUDIO_SOURCE, "-2");
        //mIat.setParameter(SpeechConstant.ASR_SOURCE_PATH, "sdcard/XXX/XXX.pcm");
        ret = mIat.startListening(mRecognizerListener);
        if (ret != ErrorCode.SUCCESS) {
            Log.i(TAG,"识别失败,错误码：" + ret+",请点击网址https://www.xfyun.cn/document/error-code查询解决方案");
        } else {
            byte[] audioData = FucUtil.readAudioFile(activity, "iattest.wav");

            if (null != audioData) {
                //showTip(getString(R.string.text_begin_recognizer));
                Log.i(TAG,"开始记录");
                // 一次（也可以分多次）写入音频文件数据，数据格式必须是采样率为8KHz或16KHz（本地识别只支持16K采样率，云端都支持），
                // 位长16bit，单声道的wav或者pcm
                // 写入8KHz采样的音频时，必须先调用setParameter(SpeechConstant.SAMPLE_RATE, "8000")设置正确的采样率
                // 注：当音频过长，静音部分时长超过VAD_EOS将导致静音后面部分不能识别。

                if(!isFromAgora) {
                    ArrayList<byte[]> bytes = FucUtil.splitBuffer(audioData, audioData.length, audioData.length / 3);
                    for (int i = 0; i < bytes.size(); i++) {
                        mIat.writeAudio(bytes.get(i), 0, bytes.get(i).length);

                        try {
                            Thread.sleep(1000);
                        } catch (Exception e) {

                        }
                    }
                }
                else {
                    //while (true)
                    {
                        byte[] buffer = monitor.getStreamBuffer();

                        mIat.writeAudio(buffer, 0, buffer.length);

                        try {
                            Thread.sleep(1000);
                        } catch (Exception e) {
                           // break;
                        }
                    }
                }
                mIat.stopListening();
				/*mIat.writeAudio(audioData, 0, audioData.length );
				mIat.stopListening();*/
            } else {
                mIat.cancel();
                //showTip("读取音频流失败");
                Log.i(TAG,"读取音频流失败");
            }
        }
    }

    /**
     * 参数设置
     *
     * @return
     */
    private void setParam() {
        // 清空参数
        mIat.setParameter(SpeechConstant.PARAMS, null);

        // 设置听写引擎
        mIat.setParameter(SpeechConstant.ENGINE_TYPE, mEngineType);
        // 设置返回结果格式
        mIat.setParameter(SpeechConstant.RESULT_TYPE, resultType);


        if(language.equals("zh_cn")) {
            String lag = mSharedPreferences.getString("iat_language_preference",
                    "mandarin");
            Log.e(TAG,"language:"+language);// 设置语言
            mIat.setParameter(SpeechConstant.LANGUAGE, "zh_cn");
            // 设置语言区域
            mIat.setParameter(SpeechConstant.ACCENT, lag);
        }else {

            mIat.setParameter(SpeechConstant.LANGUAGE, language);
        }
        Log.e(TAG,"last language:"+mIat.getParameter(SpeechConstant.LANGUAGE));

        //此处用于设置dialog中不显示错误码信息
        //mIat.setParameter("view_tips_plain","false");

        // 设置语音前端点:静音超时时间，即用户多长时间不说话则当做超时处理
        mIat.setParameter(SpeechConstant.VAD_BOS, mSharedPreferences.getString("iat_vadbos_preference", "4000"));

        // 设置语音后端点:后端点静音检测时间，即用户停止说话多长时间内即认为不再输入， 自动停止录音
        mIat.setParameter(SpeechConstant.VAD_EOS, mSharedPreferences.getString("iat_vadeos_preference", "1000"));

        // 设置标点符号,设置为"0"返回结果无标点,设置为"1"返回结果有标点
        mIat.setParameter(SpeechConstant.ASR_PTT, mSharedPreferences.getString("iat_punc_preference", "1"));

        // 设置音频保存路径，保存音频格式支持pcm、wav，设置路径为sd卡请注意WRITE_EXTERNAL_STORAGE权限
        mIat.setParameter(SpeechConstant.AUDIO_FORMAT,"wav");
        mIat.setParameter(SpeechConstant.ASR_AUDIO_PATH, Environment.getExternalStorageDirectory()+"/msc/iat.wav");
    }

    /**
     * 听写监听器。
     */
    private RecognizerListener mRecognizerListener = new RecognizerListener() {

        @Override
        public void onBeginOfSpeech() {
            // 此回调表示：sdk内部录音机已经准备好了，用户可以开始语音输入
            Log.i(TAG,"开始说话");
        }

        @Override
        public void onError(SpeechError error) {
            // Tips：
            // 错误码：10118(您没有说话)，可能是录音机权限被禁，需要提示用户打开应用的录音权限。

            Log.i(TAG, "error:" + error.getPlainDescription(true));

        }

        @Override
        public void onEndOfSpeech() {
            // 此回调表示：检测到了语音的尾端点，已经进入识别过程，不再接受语音输入
            Log.i(TAG,"结束说话");
        }

        @Override
        public void onResult(RecognizerResult results, boolean isLast) {
            Log.d(TAG, results.getResultString());
            System.out.println(flg++);
            if (resultType.equals("json")) {

                printResult(results);

            }else if(resultType.equals("plain")) {
                buffer.append(results.getResultString());
                /*
                mResultText.setText(buffer.toString());
                mResultText.setSelection(mResultText.length());
                */
                Log.i(TAG, "SWResult:" + results.getResultString());
            }

            if (isLast & cyclic) {
                // TODO 最后的结果
                Message message = Message.obtain();
                message.what = 0x001;
                han.sendMessageDelayed(message,100);
            }
        }

        @Override
        public void onVolumeChanged(int volume, byte[] data) {
            //showTip("当前正在说话，音量大小：" + volume);
            Log.d(TAG, "当前正在说话，音量大小：" + volume + ";返回音频数据："+data.length);
        }


        @Override
        public void onEvent(int eventType, int arg1, int arg2, Bundle obj) {
            // 以下代码用于获取与云端的会话id，当业务出错时将会话id提供给技术支持人员，可用于查询会话日志，定位出错原因
            // 若使用本地能力，会话id为null
            //	if (SpeechEvent.EVENT_SESSION_ID == eventType) {
            //		String sid = obj.getString(SpeechEvent.KEY_EVENT_SESSION_ID);
            //		Log.d(TAG, "session id =" + sid);
            //	}
        }

    };

    private void printResult(RecognizerResult results) {
        String text = JsonParser.parseIatResult(results.getResultString());

        String sn = null;
        // 读取json结果中的sn字段
        try {
            JSONObject resultJson = new JSONObject(results.getResultString());
            sn = resultJson.optString("sn");
        } catch (JSONException e) {
            e.printStackTrace();
        }

        mIatResults.put(sn, text);

        StringBuffer resultBuffer = new StringBuffer();
        for (String key : mIatResults.keySet()) {
            resultBuffer.append(mIatResults.get(key));
        }

        /*
        mResultText.setText(resultBuffer.toString());
        mResultText.setSelection(mResultText.length());
        */
        Log.i(TAG, "SWResult:" + resultBuffer.toString());
    }


}
