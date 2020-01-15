//
//  AudioCallManager.m
//  ACM
//
//  Created by David on 2020/1/3.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioCallManager.h"
#import "../Action/ActionManager.h"
#import "../ASR/AudioStreamMgr.h"

static AgoraRtcEngineKit *_rtcKit = nil;
static AudioCallManager *instance = nil;

@interface AudioCallManager ()  <AgoraRtcEngineDelegate, AudioStreamPushDelegate>
@end

@implementation AudioCallManager

+ (void) startAudioCall: ( nullable NSString *) appId  user:(nullable NSString *)userID  channel:(nullable NSString *)channelId rtcToken:(nullable NSString *)token callInstance:(nonnull Call*) call{
    
    NSLog(@"RTC start audio call. appID:%@  user:%@  channel:%@  rtcToken:%@", appId, userID, channelId, token);
    
    if(_rtcKit == nil)
    {
        instance = [AudioCallManager alloc];
         _rtcKit = [AgoraRtcEngineKit sharedEngineWithAppId:appId delegate:instance];
        [instance subScribeAudioStream];
    }
    
    if(_rtcKit == nil)
        return;
    
    [_rtcKit disableVideo];
    [_rtcKit enableAudio];
    
    AgoraVideoEncoderConfiguration *encoderConfiguration =
    [[AgoraVideoEncoderConfiguration alloc] initWithSize:AgoraVideoDimension640x360
                                               frameRate:AgoraVideoFrameRateFps15
                                                 bitrate:AgoraVideoBitrateStandard
                                         orientationMode:AgoraVideoOutputOrientationModeAdaptative];
    [_rtcKit setVideoEncoderConfiguration:encoderConfiguration];
    
    /*
    [_rtcKit joinChannelByToken:token channelId:channelId info:nil uid:userInfo.uid joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        NSLog(@"Succeed to join RTC channel");
    }];
     */
    
    [_rtcKit enableExternalAudioSourceWithSampleRate:16000 channelsPerFrame:1];
    
    [_rtcKit joinChannelByUserAccount:userID token:token channelId:channelId joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        NSLog(@"Succeed to join RTC channel");
        EventData eventData = {EventSelfInChannelSucceed, 0,0,0,call};
        [[ActionManager instance]  HandleEvent:eventData];
    }];
    
    [_rtcKit setEnableSpeakerphone:YES];
}

+ (int)muteLocalAudioStream:(BOOL)mute
{
    if(_rtcKit != nil)
    {
        return [_rtcKit muteLocalAudioStream:mute];
    }
    
    return -1;
}

+ (int)muteAllRemoteAudioStreams:(BOOL)mute
{
    if(_rtcKit != nil)
    {
        return [_rtcKit muteAllRemoteAudioStreams:mute];
    }
    
    return -1;
}


+ (void) endAudioCall{
    [AudioStreamMgr stopWork];
    [[ActionManager instance].asrMgr stopAsr];
    if(_rtcKit != nil)
    {
        [_rtcKit leaveChannel:^(AgoraChannelStats * _Nonnull stat) {
            
        }];
        
        [_rtcKit muteAllRemoteAudioStreams:false];
        [_rtcKit muteLocalAudioStream:false];
    }
}

//倒入音频流 todo drop

+ (BOOL)pushExternalAudioFrameRawData:(void * _Nonnull)data
                            samplenum:(NSUInteger)sampleNum
                         timestampnum:(NSTimeInterval)timeStamp
{
    if(_rtcKit != nil)
    {
        return [_rtcKit pushExternalAudioFrameRawData:data samples:sampleNum timestamp:timeStamp];
    }
    return false;
}


- (void)subScribeAudioStream{
    [AudioStreamMgr subscribeAudioStream:self];
}

//////////////// delegate from AudioStreamPushDelegate
- (void)didCaptureData:(unsigned char *_Nullable)data bytesLength:(int)bytesLength
{
    if(_rtcKit != nil)
    {
        [_rtcKit pushExternalAudioFrameRawData:data samples:bytesLength/2 timestamp:0];
    }
}

//////////////// delegate from AgoraRtcEngineDelegate

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didOccurWarning:(AgoraWarningCode)warningCode
{
    EventData eventData = {EventDidRtcOccurWarning, warningCode};
    [[ActionManager instance]  HandleEvent:eventData];
    NSLog(@"RTC warning:%ld", (long)warningCode);
}
- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didOccurError:(AgoraErrorCode)errorCode
{
    EventData eventData = {EventDidRtcOccurError, errorCode};
    [[ActionManager instance]  HandleEvent:eventData];
    NSLog(@"RTC error:%ld", (long)errorCode);
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didJoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed
{
    //NSLog(@"RTC didJoinChannel:channel%@, userID:%@, elapsed:%ld", channel,uid,(long)elapsed);
    //EventData eventData = {EventDidRTCJoinChannel, uid,elapsed,0,channel};
    //[[ActionManager instance]  HandleEvent:eventData];
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed
{
    [AudioStreamMgr startWork];
    [[ActionManager instance].asrMgr startAsr];
    EventData eventData = {EventDidJoinedOfUid, uid,elapsed,0,nil};
    [[ActionManager instance]  HandleEvent:eventData];
}

@end
