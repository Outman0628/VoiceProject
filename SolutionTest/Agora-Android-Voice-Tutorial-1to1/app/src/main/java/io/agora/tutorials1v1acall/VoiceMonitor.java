package io.agora.tutorials1v1acall;

import android.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.locks.ReentrantLock;

import io.agora.rtc.IAudioFrameObserver;

public class VoiceMonitor implements IAudioFrameObserver {

    String TAG = "VoiceMonitor";

    ArrayList<Byte> frameBuffer =new ArrayList<Byte>();
    ReentrantLock reentrantLock = new ReentrantLock();
    private int type = 1;

    //private AudioPlayer mAudioPlayer = null;

    /*

     AUDIO_FRAME_TYPE type;
     int samples;  // 该音频帧的帧数
     int bytesPerSample; // 每帧的字节数：2
            int channels; // 声道数；双声道则音频数据重叠
            int samplesPerSec; // 采样率
            void* buffer; // 音频数据 Buffer
            int64_t renderTimeMs; // 当前音频帧的时间戳

    * */

    /*
    *
    //List转数组
List byteList = new ArrayList();
Byte[] bytes = byteList.toArray(new Byte[byteList.size()]);
//数组转list
Byte[] bytes1 = new Byte[1024];
List byteList2 = Arrays.asList(bytes1);
    * */

    @Override
    public boolean onRecordFrame(byte[] samples, int numOfSamples, int bytesPerSample, int channels, int samplesPerSec)
    {
       // Log.i(TAG, "onRecordFrame:" + numOfSamples + ";bytesPerSample:" + bytesPerSample + ";channels:" + channels + "samplesPerSec:" + samplesPerSec);
        if(type == 0)
        {
            reentrantLock.lock();
            try {
                for (int i = 0; i < samples.length; i++) {
                    frameBuffer.add(samples[i]);
                }

                Log.i(TAG, "onRecordFrame buffer size:" + frameBuffer.size());
            }finally {
                reentrantLock.unlock();
            }
        }
        return true;
    }

    @Override
    public boolean onPlaybackFrame(byte[] samples, int numOfSamples, int bytesPerSample, int channels, int samplesPerSec)
    {
        if(type == 1) {
            reentrantLock.lock();
            try {
                for (int i = 0; i < samples.length; i++) {
                    frameBuffer.add(samples[i]);
                }

                Log.i(TAG, "onPlaybackFrame buffer size:" + frameBuffer.size());
            } finally {
                reentrantLock.unlock();
            }
        }
        //Log.i(TAG, "onPlaybackFrame:" + numOfSamples + ";bytesPerSample:" + bytesPerSample + ";channels:" + channels + "samplesPerSec:" + samplesPerSec);

        return true;
    }

    public byte[] getStreamBuffer() {
        byte[] ret = null;
        reentrantLock.lock();
        try{
            ret = new byte[frameBuffer.size()];
            for (int i = 0; i < frameBuffer.size(); i++)
            {
                ret[i] = frameBuffer.get(i);
            }

            // 取走后清空
            frameBuffer.clear();
            type = -1;
        }
        finally {
            reentrantLock.unlock();
            return ret;
        }
    }
}
