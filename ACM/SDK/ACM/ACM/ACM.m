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
#import "Message/RunTimeMsgManager.h"
#import "RTC/AudioCallManager.h"
#import "Action/ActionManager.h"
#import "Action/EventData.h"
#import "Message/ApnsMessageManager.h"

//static NSString *AppId = nil;
//static NSString *UserId = nil;
static ActionManager *actionMgr = nil;

@implementation  ACM



+ (void) initManager: ( nullable NSString *) appId backendHost:(nullable NSString *)host apnsToken:(nullable NSString *)token acmCallback:(id <IACMCallBack> _Nullable)delegate{
     NSLog(@"init manager4");
    /*
    AppId = appId;
    [RunTimeMsgManager init:appId acmCallback:delegate];
     */
    if(actionMgr == nil)
    {
        EventData eventData = {EventInitSDK, 0,0,0,appId,delegate,host,token};
        actionMgr = [[ActionManager alloc]init];
        [actionMgr HandleEvent:eventData];
    }
}

+ (void) loginACM: ( nullable NSString *) userId completion:(IACMLoginBlock _Nullable)completionBlock{
    /*
    UserId = userId;
    [RunTimeMsgManager loginACM:userId completion:completionBlock];
     */
    if(actionMgr != nil)
    {
        EventData eventData = {EventLogin, 0,0,0,userId,completionBlock,nil};
        [actionMgr HandleEvent:eventData];
    }
}

+ (void) sendP2PMessage: (nullable NSString *)msg peerId:( nullable NSString *)peerId completion:(IACMSendPeerMessageBlock _Nullable)completionBlock{
    //[RunTimeMsgManager sendP2PMessage:msg  remoteUid:peerId completion:completionBlock];
    
    if(actionMgr != nil)
    {
        EventData eventData = {EventSendMsg, 0,0,0,msg,peerId,completionBlock};
        [actionMgr HandleEvent:eventData];
    }
}

+ (void) agreeCall: ( nullable NSString *)channelId{
    //[AudioCallManager startAudioCall:AppId user:UserId channel:channelId rtcCallback:nil];
    if(actionMgr != nil)
    {
        EventData eventData = {EventAgreeAudioCall, 0,0,0,actionMgr.appId,actionMgr.userId,channelId,nil};
        [actionMgr HandleEvent:eventData];
    }
}

+ (void) rejectCall: ( nullable NSString * )channel fromPeer:( nullable NSString *)peerId{
    if(actionMgr != nil)
    {
        EventData eventData = {EventRejectAudioCall, 0,0,0,peerId,channel,nil};
        [actionMgr HandleEvent:eventData];
    }
}

+ (void) leaveCall: ( nullable NSString *)channel fromPeer:( nullable NSString * )peerId{
    if(actionMgr != nil)
    {
        EventData eventData = {EventLeaveCall, 0,0,0,peerId,channel,nil};
        [actionMgr HandleEvent:eventData];
    }
   // [AudioCallManager endAudioCall];
}

+ (nullable NSString*) ringAudioCall: ( nullable NSString *)peerId{
    /*
    NSString *channelId = [RunTimeMsgManager invitePhoneCall:peerId acountRemote:actionMgr.userId];
    [AudioCallManager startAudioCall:actionMgr.appId user:actionMgr.userId channel:channelId rtcCallback:nil];
    return channelId;
     */
    
    if(actionMgr != nil)
    {
        //EventData eventData = {EventDial, 0,0,0,peerId};
        
        EventData eventData = {EventDial, 0,0,0,peerId};
        [actionMgr HandleEvent:eventData];
    }
    return nil;
}

+ (void) ringRobotAudioCall
{
    if(actionMgr != nil)
    {
        EventData eventData = {EventDialRobotDemo, 0,0,0,nil};
        [actionMgr HandleEvent:eventData];
    }    
}

+ (BOOL) handleApnsMessage:(nonnull NSDictionary *)message{
    
    BOOL ret = NO;
    if(actionMgr != nil)
    {
        [ApnsMessageManager handleApnsMessage:message actionManager:actionMgr];
        ret = YES;
    }
    
    return ret;
}


@end
