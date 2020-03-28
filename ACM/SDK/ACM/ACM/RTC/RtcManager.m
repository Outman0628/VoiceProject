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
#import "../Log/AcmLog.h"
#define RTCTAG  @"RTC"

static AgoraRtcEngineKit *_rtcKit = nil;
static RtcManager *instance = nil;
static BOOL localMuteState = NO;

@interface RtcManager ()  <AgoraRtcEngineDelegate, AudioStreamPushDelegate>
@property NSMutableDictionary *channelMemberList;
@end

@implementation RtcManager

+ (void) startAudioCall: ( nullable NSString *) appId  user:(nullable NSString *)userID  channel:(nullable NSString *)channelId rtcToken:(nullable NSString *)token callInstance:(nonnull AcmCall *) call{
    
    InfoLog(RTCTAG,@"RTC start audio call. appID:%@  user:%@  channel:%@  rtcToken:%@", appId, userID, channelId, token);
    
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
    
    
    [_rtcKit joinChannelByUserAccount:userID token:token channelId:channelId joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {  InfoLog(RTCTAG,@"Succeed to join RTC channel");
        
        int retValue = [_rtcKit setEnableSpeakerphone:[ActionManager instance].isSpeakerphoneEnabled];
        DebugLog(RTCTAG,@"setEnableSpeakerphone %d",retValue);
        
        if(!localMuteState){
            [AudioStreamMgr startWork];
            [[ActionManager instance].asrMgr startAsr];
        }
        
        EventData eventData = {EventSelfInChannelSucceed, 0,0,0,call};
        [[ActionManager instance]  HandleEvent:eventData];
    }];
     
    
    
    /* test code
    
    [_rtcKit setChannelProfile:AgoraChannelProfileCommunication];
    [_rtcKit setAudioProfile:AgoraAudioProfileDefault scenario:AgoraAudioScenarioDefault];
    [_rtcKit setClientRole:AgoraClientRoleBroadcaster];
    
    
    [_rtcKit joinChannelByUserAccount:userID token:token channelId:channelId joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {  InfoLog(RTCTAG,@"Succeed to join RTC channel");
        
        int retValue = [_rtcKit setEnableSpeakerphone:[ActionManager instance].isSpeakerphoneEnabled];
        DebugLog(RTCTAG,@"setEnableSpeakerphone routing value:%d, ret value:%d",[ActionManager instance].isSpeakerphoneEnabled,retValue);
        
        if(!localMuteState){
            [AudioStreamMgr startWork];
            [[ActionManager instance].asrMgr startAsr];
        }
        
        EventData eventData = {EventSelfInChannelSucceed, 0,0,0,call};
        [[ActionManager instance]  HandleEvent:eventData];
    }];
     test end */
    

}

+ (void) startVideoCall: ( nullable NSString *) appId  callInstance:(nonnull AcmCall *) call{
    InfoLog(RTCTAG,@"start video call");
    if(_rtcKit == nil)
    {
        instance = [RtcManager alloc];
        instance.channelMemberList = [[NSMutableDictionary alloc]init];
        _rtcKit = [AgoraRtcEngineKit sharedEngineWithAppId:appId delegate:instance];
        [instance subScribeAudioStream];
    }
    
    if(_rtcKit == nil)
        return;
    
    [_rtcKit enableVideo];
    [_rtcKit enableAudio];
    
    [RtcManager setupLocalVideo:call];
    
    AgoraVideoEncoderConfiguration *encoderConfiguration =

    [[AgoraVideoEncoderConfiguration alloc] initWithSize:call.videoCallParam.size
                                               frameRate:call.videoCallParam.frameRate
                                                 bitrate:call.videoCallParam.bitrate
                                         orientationMode:call.videoCallParam.orientationMode];
    
    [_rtcKit setVideoEncoderConfiguration:encoderConfiguration];
    
    
    [_rtcKit enableExternalAudioSourceWithSampleRate:16000 channelsPerFrame:1];
    
    [instance.channelMemberList removeAllObjects];
    
    [_rtcKit joinChannelByUserAccount:call.selfId token:call.token channelId:call.channelId joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
        InfoLog(RTCTAG,@"Succeed to join RTC video channel");
        
        int retValue = [_rtcKit setEnableSpeakerphone:[ActionManager instance].isSpeakerphoneEnabled];
        DebugLog(RTCTAG,@"setEnableSpeakerphone %d",retValue);
        
        if(!localMuteState){
            [AudioStreamMgr startWork];
            [[ActionManager instance].asrMgr startAsr];
        }
        
        EventData eventData = {EventSelfInChannelSucceed, 0,0,0,call};
        [[ActionManager instance]  HandleEvent:eventData];
    }];
    
    [_rtcKit setEnableSpeakerphone:YES];
    
}

+ (void)setupLocalVideo :(AcmCall *) call{
    
    if(call.videoCallParam.localView != nil){
        AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
        videoCanvas.uid = 0;
        // UID = 0 means we let Agora pick a UID for us
        
        videoCanvas.view = call.videoCallParam.localView;
        videoCanvas.renderMode = call.videoCallParam.renderMode;
        
        // Bind local video stream to view
        [_rtcKit setupLocalVideo:videoCanvas];        
    }
}

+ (int)muteLocalAudioStream:(BOOL)mute
{
    localMuteState = mute;
    if(mute)
    {
        [AudioStreamMgr stopWork];
         [[ActionManager instance].asrMgr stopAsr];
    }
    else{
        [AudioStreamMgr startWork];
        [[ActionManager instance].asrMgr startAsr];
    }
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


+ (int)setupRemoteVideo:(AgoraRtcVideoCanvas * _Nonnull)remote{
    if(remote != nil && _rtcKit != nil){
        return [_rtcKit setupRemoteVideo:remote];
    }
    return -1;
}

+ (int)setEnableSpeakerphone:(BOOL)enableSpeaker{
    if(_rtcKit != nil){
        return [_rtcKit setEnableSpeakerphone:enableSpeaker];
    }else{
        return -1;
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
    WarnLog(RTCTAG,@"RTC warning:%ld", (long)warningCode);
}
- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didOccurError:(AgoraErrorCode)errorCode
{
    EventData eventData = {EventDidRtcOccurError, errorCode};
    [[ActionManager instance]  HandleEvent:eventData];
    ErrLog(RTCTAG,@"RTC error:%ld", (long)errorCode);
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didJoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed
{
    //NSLog(@"RTC didJoinChannel:channel%@, userID:%@, elapsed:%ld", channel,uid,(long)elapsed);
    //EventData eventData = {EventDidRTCJoinChannel, uid,elapsed,0,channel};
    //[[ActionManager instance]  HandleEvent:eventData];
    

}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didAudioRouteChanged:(AgoraAudioOutputRouting)routing{
    InfoLog(RTCTAG,@"RTC didAudioRouteChanged:%ld",(long)routing);
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed
{
    InfoLog(RTCTAG,@"RTC didJoinedOfUid: userID:%lu, elapsed:%ld", (unsigned long)uid,(long)elapsed);
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
    InfoLog(RTCTAG,@"didRegisteredLocalUser userAccount:%@  uid:%lu", userAccount, (unsigned long)uid);
}


- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didUpdatedUserInfo:(AgoraUserInfo * _Nonnull)userInfo withUid:(NSUInteger)uid{
    InfoLog(RTCTAG,@"didUpdatedUserInfo userAccount:%@  uid:%lu", userInfo.userAccount, (unsigned long)userInfo.uid);
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
    InfoLog(RTCTAG,@"didOfflineOfUid userAccount:%lu  reason:%lu", (unsigned long)uid , reason);
    NSNumber *num = [NSNumber numberWithInteger:uid];
    NSString *userAccount = [_channelMemberList objectForKey:num];
    
    EventData eventData = {EventRTCUserLeaveChannel, (int)uid,0,0,userAccount};
    [[ActionManager instance]  HandleEvent:eventData];
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didRejoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed{
    InfoLog(RTCTAG,@"didRejoinChannel userAccount:%lu ", (unsigned long)uid );
    NSNumber *num = [NSNumber numberWithInteger:uid];
    NSString *userAccount = [_channelMemberList objectForKey:num];
    if(userAccount != nil){
        EventData eventData = {EventDidJoinedOfUid, (int)uid,(int)elapsed,0,userAccount};
        [[ActionManager instance]  HandleEvent:eventData];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size: (CGSize)size elapsed:(NSInteger)elapsed {
    InfoLog(RTCTAG,@"firstRemoteVideoDecodedOfUid userAccount:%lu ", (unsigned long)uid );
    NSNumber *num = [NSNumber numberWithInteger:uid];
    NSString *userAccount = [_channelMemberList objectForKey:num];
    
    
    if(userAccount != nil){
        EventData eventData = {EventFirstRemoteVideoDecodedOfUid, (int)uid,(int)elapsed,0,userAccount,[NSNumber numberWithFloat:size.width],[NSNumber numberWithFloat:size.height]};
        [[ActionManager instance]  HandleEvent:eventData];
    }else{
       
        WarnLog(RTCTAG,@"RTC first remote video user account not cached:%lu", (unsigned long)uid );
    }
}

@end
