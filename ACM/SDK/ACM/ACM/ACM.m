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
#import "RTC/RtcManager.h"
#import "Action/ActionManager.h"
#import "Action/EventData.h"
#import "Message/ApnsMessageManager.h"

#import "Log/AcmLog.h"
#define ACMTAG  @"ACM"

static ActionManager *actionMgr = nil;

@implementation  ACM



+ (void) initManager: (nullable NSString *)host apnsToken:(nullable NSString *)token acmCallback:(id <IACMCallBack> _Nullable)delegate completion:(IACMInitBlock _Nullable)completionBlock{
    
    InfoLog(ACMTAG,@"init manager");

    if(actionMgr == nil)
    {
        EventData eventData = {EventInitSDK, 0,0,0,delegate,host,token,completionBlock};
        actionMgr = [[ActionManager alloc]init];
        [actionMgr HandleEvent:eventData];
    }
}

+ (void) loginACM: ( nullable NSString *) userId completion:(IACMLoginBlock _Nullable)completionBlock{

    DebugLog(ACMTAG,@"login acm");
    if(actionMgr != nil)
    {
        EventData eventData = {EventLogin, 0,0,0,userId,completionBlock,nil};
        [actionMgr HandleEvent:eventData];
    }
}

/**
 检测账户是否已经在其他设备登录(放弃该接口，无法判断设备上次是从哪里登录)
 
 @param userId 本机用户ID
 @param completionBlock 登录结果回调
 */
+ (void) loggedInCheck: ( nullable NSString *) userId completion:(LoginCheckBlock _Nullable)completionBlock{
    if(actionMgr != nil)
    {
        EventData eventData = {EventLoggedinCheck, 0,0,0,userId,completionBlock,nil};
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
    /*
    EventData eventData = {EventInputStreamTest};
    [actionMgr HandleEvent:eventData];
     */
}

+ (AcmError) agreeCall: ( nullable NSString *)channelId ircmCallback:(id <IRTCCallBack> _Nullable)delegate VideoCallParam:(VideoParam *_Nullable) videoParam{
    //[AudioCallManager startAudioCall:AppId user:UserId channel:channelId rtcCallback:nil];
    if(actionMgr != nil)
    {
        AcmCall *call = [[ActionManager instance].callMgr getCall:channelId];
        if(call != nil){
            
            if(call.callType == VideoCall){
                if(videoParam == nil){
                    return AcmErrorInvalidParam;
                }
                call.videoCallParam = (*videoParam);
            }
            
            
            call.callback = delegate;
            EventData eventData = {EventAgreeCall, 0,0,0,call};
            [actionMgr HandleEvent:eventData];
            
            return AcmErrorOk;
        }
        
        return AcmErrorInvalidParam;
    }
    
    return AcmErrorNotInited;
}

+ (void) rejectCall: ( nullable NSString * )channel{
    if(actionMgr != nil)
    {
        EventData eventData = {EventRejectAudioCall, 0,0,0,channel};
        [actionMgr HandleEvent:eventData];
    }
}

+ (void) leaveCall: ( nullable Call *)call{
    if(actionMgr != nil)
    {
        EventData eventData = {EventLeaveCall, 0,0,0,call};
        [actionMgr HandleEvent:eventData];
    }
   // [AudioCallManager endAudioCall];
}

+ (nullable Call *) ringAudioCall: (nullable NSString *)peerId ircmCallback:(id <IRTCCallBack> _Nullable)delegate{
    /*
    NSString *channelId = [RunTimeMsgManager invitePhoneCall:peerId acountRemote:actionMgr.userId];
    [AudioCallManager startAudioCall:actionMgr.appId user:actionMgr.userId channel:channelId rtcCallback:nil];
    return channelId;
     */
    
    if(actionMgr != nil && peerId != nil && peerId.length > 0)
    {
        //EventData eventData = {EventDial, 0,0,0,peerId};
        
        NSArray *peerList = [[NSArray alloc] initWithObjects:peerId, nil];
        
        Call *call = [CallManager prepareDialCall:peerList Type:AudioCall ircmCallback:delegate];
        EventData eventData = {EventAudioDial, 0,0,0,nil,delegate,call};
        [actionMgr HandleEvent:eventData];
        return call;
    }
    
    return nil;
}

+ (nullable Call *) ringGroupAudioCall: (nonnull NSArray *)peerList ircmCallback:(id <IRTCCallBack> _Nullable)delegate GroupId:(NSInteger) groupId{
    if(actionMgr != nil)
    {
        //EventData eventData = {EventDial, 0,0,0,peerId};
        Call *call = [CallManager prepareDialCall:peerList Type:AudioCall ircmCallback:delegate];
        EventData eventData = {EventAudioDial, (int)groupId,0,0,nil,delegate,call};
        [actionMgr HandleEvent:eventData];
        return call;
    }
    
    return nil;
}

+ (nullable Call *) ringVideoCall: (nonnull NSArray *)peerList VideoCallParam:(VideoParam) videoParam ircmCallback:(id <IRTCCallBack> _Nullable)delegate{
    if(actionMgr != nil)
    {
        //EventData eventData = {EventDial, 0,0,0,peerId};
        Call *call = [CallManager prepareDialCall:peerList Type:VideoCall ircmCallback:delegate];
        call.videoCallParam = videoParam;
        EventData eventData = {EventVideoDial, 0,0,0,nil,delegate,call};
        [actionMgr HandleEvent:eventData];
        return call;
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
        ret = [ApnsMessageManager handleApnsMessage:message actionManager:actionMgr];
       
    }
    
    return ret;
}

+ (BOOL) robotAnswerCall: ( nullable NSString *)channelId ircmCallback:(id <IRTCCallBack> _Nullable)delegate
{
    BOOL ret = NO;
    if(actionMgr != nil)
    {
        EventData eventData = {EventRobotAnswerCall, 0,0,0,channelId, delegate};
        [actionMgr HandleEvent:eventData];
        ret = YES;
    }
    
    return ret;
}

+ (BOOL) updateMuteState: ( nonnull Call *)call
{
    BOOL ret = NO;
    
    if(call != nil && call.channelId != nil)
    {
        Call *instance = [actionMgr.callMgr getCall:call.channelId];
        if(instance != nil && call.stage != Finished)
        {
            ret = true;
            
            EventData eventData = {EventUpdateMuteState, 0,0,0,instance};
            [actionMgr HandleEvent:eventData];
        }
    }
    
    return ret;
}

+ (void) getPhoneAuthority: ( nullable NSString *)channelId completion:(IRTCAGetAuthorityBlock _Nullable)completionBlock
{
    if(actionMgr != nil)
    {
        EventData eventData = {EventGetAuthority,0,0,0,channelId,completionBlock};
        [actionMgr HandleEvent:eventData];
        
    }
    else if(completionBlock != nil)
    {
        completionBlock(AcmPhoneCallErrorNoAuthority);
    }
}

+ (void) updateDialingTimer: ( NSInteger )dialingTimer
{
    if(actionMgr != nil)
    {
        EventData eventData = {EventUpdateDialingTimer,(int)dialingTimer};
        [actionMgr HandleEvent:eventData];
        
    }
}

+ (int)setEnableSpeakerphone:(BOOL)enableSpeaker{
    if(actionMgr != nil)
    {
        int value = 0;
        if(enableSpeaker){
            value = 1;
        }
        EventData eventData = {EnableSpeakerphone,value};
        [actionMgr HandleEvent:eventData];
        return 0;
    }else{
        return -1;
    }
}

+ (void) setAcmLogConfig:(AcmLogLevel) logLevel{
    [LogManager setAcmLogConfig:logLevel];
}


@end
