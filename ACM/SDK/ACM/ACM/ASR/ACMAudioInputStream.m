//
//  ACMAudioInputStream.m
//  ACM
//
//  Created by David on 2020/1/13.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACMAudioInputStream.h"
#import <AudioToolbox/AudioToolbox.h>
//#import <AVFoundation/AVAudioSession.h>
#import "../RTC/AudioCallManager.h"

const int kk_recorder_buffers_number         = 3;
const int kk_recorder_channels_per_frame     = 1;
const int kk_recorder_bits_per_channel       = 16;
const int kk_recorder_frames_per_package     = 1;

@interface ACMAudioInputStream ()
{
    AudioQueueRef               audioQueue;
    AudioQueueBufferRef         aqBuffers[kk_recorder_buffers_number];
    BOOL                        isRecording;
}
@property (nonatomic, assign) NSStreamStatus status;
@property (nonatomic, assign) NSInteger sampleRate;
@property (nonatomic, assign) float packageDuration;
@property (nonatomic, assign) NSInteger bufferFrameSize;

@end

@implementation ACMAudioInputStream

- (instancetype)init
{
    if (self = [super init]) {
        _status = NSStreamStatusNotOpen;
        _sampleRate = 16000;
        isRecording = false;
        _bufferFrameSize = 1;
        _packageDuration = 0.01;
    }
    return self;
}

- (void)open
{
    /*
     ** any operation to open data source, do it here.
     */
    [self startRecording];
}

- (void)close
{
    /*
     ** clean up the data source.
     */
    [self stopRecorder];
}


- (void)stopRecorder
{
    if (!isRecording) {
        return;
    }
    isRecording = false;
    
    if (audioQueue) {
        AudioQueueRef tmpQueue = audioQueue;
        audioQueue = nil;
        [self stopAudioQueue:tmpQueue];
    }
}


- (void)startRecording
{
   // [self clearupRecording];
    
    AudioStreamBasicDescription recorderFormat;
    [self setupRecorderFormat:&recorderFormat formatID:kAudioFormatLinearPCM];
    
    OSStatus ret = AudioQueueNewInput(&recorderFormat,
                                      input_buffer_handler,
                                      (__bridge void*)self, /* user data */
                                      NULL,                 /* run loop */
                                      NULL,                 /* run loop mode */
                                      0,                    /* flags */
                                      &audioQueue);
    
    int bufferByteSize = [self computeRecordBufferSizeWithFormat:&recorderFormat];
    for (int i = 0; i < kk_recorder_buffers_number; ++i) {
        ret = AudioQueueAllocateBuffer(audioQueue, bufferByteSize, &aqBuffers[i]);
        ret = AudioQueueEnqueueBuffer(audioQueue, aqBuffers[i], 0, NULL);
    }
    
    
    ret = AudioQueueStart(audioQueue, NULL);
    if (ret) {
        ret = AudioQueueStart(audioQueue, NULL);
    }
    
    isRecording = YES;
}

- (void)stopAudioQueue:(AudioQueueRef)audioQueueRef
{
    OSStatus ret = AudioQueueStop(audioQueueRef, true);
    ret = AudioQueueDispose(audioQueueRef, false);
}

- (int)computeRecordBufferSizeWithFormat:(AudioStreamBasicDescription*)format
{
    if (format == NULL) {
        return 0;
    }
    
    int packets, frames, bytes = 0;
    
    //frames = self.bufferFrameSize;
    frames = (int)ceil(self.packageDuration * format->mSampleRate);
    if (format->mBytesPerFrame > 0) {
        bytes = frames * format->mBytesPerFrame;
    } else {
        UInt32 maxPacketSize;
        if (format->mBytesPerPacket > 0) {
            maxPacketSize = format->mBytesPerPacket;    // constant packet size
        } else {
            UInt32 propertySize = sizeof(maxPacketSize);
            AudioQueueGetProperty(audioQueue, kAudioQueueProperty_MaximumOutputPacketSize, &maxPacketSize,
                                  &propertySize);
        }
        
        if (format->mFramesPerPacket > 0) {
            packets = frames / format->mFramesPerPacket;
        } else {
            packets = frames;   // worst-case scenario: 1 frame in a packet
        }
        
        if (packets == 0) { // sanity check
            packets = 1;
        }
        
        bytes = packets * maxPacketSize;
    }
    
    return bytes;
}

- (void)setupRecorderFormat:(AudioStreamBasicDescription*)format formatID:(UInt32)formatID
{
    if (format == NULL) {
        return;
    }
    
    bzero((void*)format, sizeof(*format));
    format->mFormatID = formatID;
    format->mSampleRate = self.sampleRate;
    format->mChannelsPerFrame = kk_recorder_channels_per_frame;
    
    if (formatID == kAudioFormatLinearPCM) {
        format->mBitsPerChannel = kk_recorder_bits_per_channel;
        format->mFramesPerPacket = kk_recorder_frames_per_package;
        format->mBytesPerPacket = format->mBytesPerFrame = (format->mBitsPerChannel / 8) * format->mChannelsPerFrame;
        format->mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    } else if (formatID == kAudioFormatULaw || formatID == kAudioFormatALaw) {
        format->mBitsPerChannel = kk_recorder_bits_per_channel;
        format->mFramesPerPacket = kk_recorder_frames_per_package;
        format->mBytesPerPacket = format->mBytesPerFrame = (format->mBitsPerChannel / 8) * format->mChannelsPerFrame;
    }
}

- (void)recvRecorderData:(AudioQueueRef)inAQ inBuffer:(AudioQueueBufferRef)inBuffer inNumPackages:(UInt32)inNumPackages
{
    @synchronized (self) {
        /*
        if (inNumPackages > 0) {
            audioData->queueAudio((const uint8_t *)inBuffer->mAudioData, inBuffer->mAudioDataByteSize);
        }
         */
        NSLog(@"Got record data len:%d", inBuffer->mAudioDataByteSize);
        //NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        
        
        //NSTimeInterval timestamp=[dat timeIntervalSince1970];
        
        //[AudioCallManager pushExternalAudioFrameRawData:inBuffer->mAudioData samplenum:inBuffer->mAudioDataByteSize timestampnum:timestamp];
         
       
        
        [AudioCallManager pushExternalAudioFrameRawData:inBuffer->mAudioData samplenum:inBuffer->mAudioDataByteSize timestampnum:0];
        if (isRecording) {
            AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
        }
    }
}




#pragma mark - Static callback

static void input_buffer_handler(void *                                inUserData,
                                 AudioQueueRef                         inAQ,
                                 AudioQueueBufferRef                   inBuffer,
                                 const AudioTimeStamp *                inStartTime,
                                 UInt32                                inNumPackets,
                                 const AudioStreamPacketDescription*   inPacketDesc) {
    ACMAudioInputStream* recorder = (__bridge ACMAudioInputStream*)inUserData;
    if (recorder != nil) {
        [recorder recvRecorderData:inAQ inBuffer:inBuffer inNumPackages:inNumPackets];
    }
}

@end
