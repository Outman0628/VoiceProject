//
//  ACM.m
//  ACM
//
//  Created by David on 2020/1/2.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACM.h"

#import <AgoraRtmKit/AgoraRtmKit.h>
#import "RTM/RunTimeMsgManager.h"
#import "RTC/AudioCallManager.h"

static NSString *AppId = nil;
static NSString *UserId = nil;

@implementation  ACM



+ (void) initManager: ( nullable NSString *) appId  acmCallback:(id <IACMCallBack> _Nullable)delegate{
     NSLog(@"init manager3");
    AppId = appId;
    [RunTimeMsgManager init:appId acmCallback:delegate];
}

+ (void) loginACM: ( nullable NSString *) userId completion:(IACMLoginBlock _Nullable)completionBlock{
    UserId = userId;
    [RunTimeMsgManager loginACM:userId completion:completionBlock];
}

+ (void) sendP2PMessage: (nullable NSString *)msg peerId:( nullable NSString *)peerId completion:(IACMSendPeerMessageBlock _Nullable)completionBlock{
    [RunTimeMsgManager sendP2PMessage:msg  remoteUid:peerId completion:completionBlock];
}

+ (void) agreeCall: ( nullable NSString *)channelId{
    [AudioCallManager startAudioCall:AppId user:UserId channel:channelId rtcCallback:nil];
}

+ (void) leaveCall: ( nullable NSString *)channelId{
    [AudioCallManager endAudioCall];
}

+ (void) ringAudioCall: ( nullable NSString *)peerId{
    NSString *channelId = [RunTimeMsgManager invitePhoneCall:peerId];
    [AudioCallManager startAudioCall:AppId user:UserId channel:channelId rtcCallback:nil];
}


@end
