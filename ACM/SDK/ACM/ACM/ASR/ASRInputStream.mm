//
//  AudioInputStream.m
//

#import "ASRInputStream.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioSession.h>
#include "AudioDataQueue.hpp"
#include "AsrManager.h"
#include "../Action/ActionManager.h"

@interface ASRInputStream () <AudioStreamPushDelegate>
{
    BOOL                        isRecording;
    AudioDataQueue              *audioData;
}
// Developer should set the status depens on your data flow.
@property (nonatomic, assign) NSStreamStatus status;

@property (nonatomic, assign) NSInteger sampleRate;
@property (nonatomic, assign) float packageDuration;

@end

@implementation ASRInputStream

@synthesize delegate;

- (instancetype)init
{
    if (self = [super init]) {
        _status = NSStreamStatusNotOpen;
        _sampleRate = 16000;
        _packageDuration = 0.08;
        isRecording = false;
        
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

#pragma mark - Custom

- (BOOL)hasBytesAvailable;
{
    return YES;
}

- (NSStreamStatus)streamStatus;
{
    return self.status;
}

- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    @synchronized (self) {
        if(audioData != NULL)
        {
            return audioData->dequeSamples(buffer, (int)len, true);
        }
        else
        {
            return 0;
        }
    }
}

- (BOOL)getBuffer:(uint8_t * _Nullable *)buffer length:(NSUInteger *)len
{
    return NO;
}

#pragma mark - Data Source

- (void)stopRecorder
{
    if (!isRecording) {
        return;
    }
    isRecording = false;
    
    [AudioStreamMgr  unsubscribeAudioStream:self];
    
    @synchronized(self) {
        delete audioData;
        audioData = nil;
    }
}

- (void)startRecording
{
    [AudioStreamMgr  subscribeAudioStream:self];
    [self clearupRecording];
    
    isRecording = YES;
}

- (void)recvRecorderData:(AudioQueueRef)inAQ inBuffer:(AudioQueueBufferRef)inBuffer inNumPackages:(UInt32)inNumPackages
{
    @synchronized (self) {
        if (inNumPackages > 0) {
            audioData->queueAudio((const uint8_t *)inBuffer->mAudioData, inBuffer->mAudioDataByteSize);
        }
        
        if (isRecording) {
            AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
        }
    }
}

- (void)didCaptureData:(unsigned char *_Nullable)data bytesLength:(int)bytesLength
{
    @synchronized (self) {
       if(isRecording && audioData != nil)
       {
           audioData->queueAudio(data,bytesLength);
       }
        
    }
}

-(void) pushCaptureData:(unsigned char *)data bytesLength:(int)bytesLength{
    @synchronized (self) {
       
        if(audioData != nil && isRecording)
            audioData->queueAudio(data, bytesLength);
        
    }
}

- (void)clearupRecording
{
    audioData = new AudioDataQueue(16000*2*2);
    audioData->reset();
}

@end
