//
//  AudioCallManager.m
//  ACM
//
//  Created by David on 2020/1/3.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RtcManager.h"
#import "../Action/ActionManager.h"
#import "../ASR/AudioStreamMgr.h"

static AgoraRtcEngineKit *_rtcKit = nil;
static RtcManager *instance = nil;

@interface RtcManager ()  <AgoraRtcEngineDelegate, AudioStreamPushDelegate>
@property NSMutableDictionary *channelMemberList;
@end

@implementation RtcManager

+ (void) startAudioCall: ( nullable NSString *) appId  user:(nullable NSString *)userID  channel:(nullable NSString *)channelId rtcToken:(nullable NSString *)token callInstance:(nonnull AcmCall *) call{
    
    NSLog(@"RTC start audio call. appID:%@  user:%@  channel:%@  rtcToken:%@", appId, userID, channelId, token);
    
    if(_rtcKit == nil)
    {
        instance = [RtcManager alloc];
        instance.channelMemberList = [[NSMutableDictionary alloc]init];
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
    
    [instance.channelMemberList removeAllObjects];
    
    [_rtcKit joinChannelByUserAccount:userID token:token channelId:channelId joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        NSLog(@"Succeed to join RTC channel");
        EventData eventData = {EventSelfInChannelSucceed, 0,0,0,call};
        [[ActionManager instance]  HandleEvent:eventData];
    }];
    
    [_rtcKit setEnableSpeakerphone:YES];
}

+ (void) startVideoCall: ( nullable NSString *) appId  callInstance:(nonnull AcmCall *) call{
    
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

+ (int)setupLocalVideo:(AgoraRtcVideoCanvas * _Nullable)local{
    if(_rtcKit != nil){
        return [_rtcKit setupLocalVideo:local];
    }
    return -1;
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
    NSNumber *num = [NSNumber numberWithInteger:uid];
    NSString *userAccount = [_channelMemberList objectForKey:num];
    
    if(userAccount == nil ){     //didUpdatedUserInfo 可能会在 didJoinedOfUid 之后调用，当没有记录userAccount 时先行保存
        [_channelMemberList setObject:@"" forKey: [NSNumber numberWithInteger:uid]];
    }
    else if(userAccount != nil && userAccount.length > 0){
        EventData eventData = {EventDidJoinedOfUid, (int)uid,(int)elapsed,0,userAccount};
        [[ActionManager instance]  HandleEvent:eventData];
    }
}


- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didRegisteredLocalUser:(NSString * _Nonnull)userAccount withUid:(NSUInteger)uid{
    NSLog(@"didRegisteredLocalUser userAccount:%@  uid:%lu", userAccount, (unsigned long)uid);
}


- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didUpdatedUserInfo:(AgoraUserInfo * _Nonnull)userInfo withUid:(NSUInteger)uid{
    NSLog(@"didUpdatedUserInfo userAccount:%@  uid:%lu", userInfo.userAccount, (unsigned long)userInfo.uid);
    NSNumber *num = [NSNumber numberWithInteger:userInfo.uid];
    NSString *userAccount = [_channelMemberList objectForKey:num];
    
    [_channelMemberList setObject:userInfo.userAccount forKey: [NSNumber numberWithInteger:userInfo.uid]];
    
    if(userAccount != nil && userAccount.length == 0)  // didJoinedOfUid 先调用场景
    {
        EventData eventData = {EventDidJoinedOfUid, (int)userInfo.uid,0,0,userInfo.userAccount};
        [[ActionManager instance]  HandleEvent:eventData];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason{
    NSLog(@"didOfflineOfUid userAccount:%lu  reason:%lu", (unsigned long)uid , reason);
    NSNumber *num = [NSNumber numberWithInteger:uid];
    NSString *userAccount = [_channelMemberList objectForKey:num];
    
    EventData eventData = {EventRTCUserLeaveChannel, (int)uid,0,0,userAccount};
    [[ActionManager instance]  HandleEvent:eventData];
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didRejoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed{
    NSNumber *num = [NSNumber numberWithInteger:uid];
    NSString *userAccount = [_channelMemberList objectForKey:num];
    if(userAccount != nil){
        EventData eventData = {EventDidJoinedOfUid, (int)uid,(int)elapsed,0,userAccount};
        [[ActionManager instance]  HandleEvent:eventData];
    }
}

@end