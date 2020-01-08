//
//  AudioCallManager.m
//  ACM
//
//  Created by David on 2020/1/3.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AudioCallManager.h"

static AgoraRtcEngineKit *_rtcKit = nil;
static AudioCallManager *instance = nil;

@interface AudioCallManager ()  <AgoraRtcEngineDelegate>
@end

@implementation AudioCallManager

+ (void) startAudioCall: ( nullable NSString *) appId  user:(nullable NSString *)userID  channel:(nullable NSString *)channelId rtcCallback:(id <IRTCCallBack> _Nullable)delegate{
    
    if(_rtcKit == nil)
    {
        instance = [AudioCallManager alloc];
         _rtcKit = [AgoraRtcEngineKit sharedEngineWithAppId:appId delegate:instance];
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
    
    [_rtcKit joinChannelByToken:nil channelId:channelId info:nil uid:0 joinSuccess:^(NSString *channel, NSUInteger uid, NSInteger elapsed) {
        NSLog(@"Succeed to join RTC channel");
    }];
    
    [_rtcKit setEnableSpeakerphone:YES];
}


+ (void) endAudioCall{
    if(_rtcKit != nil)
    {
        [_rtcKit leaveChannel:^(AgoraChannelStats * _Nonnull stat) {
            
        }];
    }
}

//////////////// delegate

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didOccurWarning:(AgoraWarningCode)warningCode
{
    NSLog(@"RTC warning:%ld", (long)warningCode);
}
- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didOccurError:(AgoraErrorCode)errorCode
{
    NSLog(@"RTC error:%ld", (long)errorCode);
}

- (void)rtcEngine:(AgoraRtcEngineKit * _Nonnull)engine didJoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed
{
    NSLog(@"RTC didJoinChannel:channel%@, userID:%@, elapsed:%ld", channel,uid,(long)elapsed);
}

@end
