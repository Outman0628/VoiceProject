//
//  RunTimeMsgManager.m
//  ACM
//
//  Created by David on 2020/1/3.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
 #import<objc/runtime.h>
#import "RunTimeMsgManager.h"
#import "IACMCallBack.h"
#import "../Action/ActionManager.h"

#import "../Log/AcmLog.h"
#define RTMTAG  @"RTM"


static AgoraRtmKit *_kit = nil;
static id<IACMCallBack> acmCallBack = nil;
//static NSString *_userId = nil;
//static Boolean _loginStatus = false;
static RunTimeMsgManager *instance = nil;
static ActionManager *actionMgr = nil;

@interface RunTimeMsgManager ()  <AgoraRtmDelegate>
@end

@implementation RunTimeMsgManager

// 注册服务
+ (BOOL) init: ( nullable NSString *) appId  acmCallback:(id <IACMCallBack> _Nullable)delegate actionMgr:(nonnull ActionManager *)mgr{
    acmCallBack = delegate;
    if(_kit == nil)
    {
        instance = [RunTimeMsgManager alloc];
        _kit = [[AgoraRtmKit alloc] initWithAppId:appId delegate:instance];
        actionMgr = mgr;
    }
    
    if(_kit == nil)
    {
        ErrLog(RTMTAG,@"Error: Agora Rtm kit init returned nil");
        return NO;
    }
    else
    {
        InfoLog(RTMTAG,@"Agora Rtm kit init succeed!");
        return YES;
    }
}

// 登录RTM
+ (void) loginACM: ( nullable NSString *) userId  AppId:( nullable NSString *) appId  Token:(nullable NSString *) token  completion:(IACMLoginBlock _Nullable)completionBlock{
    
    _kit = nil;
    
    if(_kit == nil)
    {
        instance = [RunTimeMsgManager alloc];
        _kit = [[AgoraRtmKit alloc] initWithAppId:appId delegate:instance];
    }
    
    if(_kit == nil && completionBlock != nil)
    {
        ErrLog(RTMTAG,@"Err ACM not inited!");
        completionBlock(AcmRtmLoginErrorLoginNotInitialized);
        return;
    }
    
    [_kit loginByToken:token user:userId completion:^(AgoraRtmLoginErrorCode errorCode) {
        
        EventData eventData = {EventRTMLoginResult, errorCode,0,0,completionBlock};
        [actionMgr HandleEvent:eventData];
        
        
    }];
}

+ (void) loggedInCheck: ( nullable NSString *) userId completion:(LoginCheckBlock _Nullable)completionBlock{
    if(userId == nil)
    {
        if(completionBlock != nil)
        {
            completionBlock(false,AgoraRtmQueryPeersOnlineErrorInvalidArgument);
        }
        return;
    }
    

    
    if(_kit != nil && completionBlock != nil)
    {
        
        ActionManager *actionMgr = [ActionManager instance];
        
        if(actionMgr != nil && actionMgr.userId != nil){    // 已经登录
            [self CheckloggedIn:userId completion:completionBlock];
        }
        else{  // 未登录需要临时账号登录
            
            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval timestamp=[dat timeIntervalSince1970];
            NSNumber *asrTimeStamp = [NSNumber numberWithDouble:timestamp];
            
            NSString *tmpUid = [NSString stringWithFormat:@"%@", asrTimeStamp];
            
            [_kit loginByToken:nil user:tmpUid completion:^(AgoraRtmLoginErrorCode errorCode) {
                
                if(AgoraRtmLoginErrorOk == errorCode){
                    [RunTimeMsgManager CheckloggedIn:userId completion:^(BOOL alreadyLoggedin, AgoraRtmQueryPeersOnlineErrorCode errorCode) {
                        [RunTimeMsgManager logoutRtm];
                        completionBlock(alreadyLoggedin, errorCode);
                    }];
                }
            }];
        }
        
        
    }
    else if(_kit == nil && completionBlock != nil)
    {
        completionBlock(false,AgoraRtmQueryPeersOnlineErrorNotInitialized);
    }
}

+ (void) CheckloggedIn: ( nullable NSString *) userId completion:(LoginCheckBlock _Nullable)completionBlock{
    NSArray *array = [[NSArray alloc] initWithObjects:userId, nil];
    [_kit queryPeersOnlineStatus:array completion:^(NSArray<AgoraRtmPeerOnlineStatus *> *peerOnlineStatus, AgoraRtmQueryPeersOnlineErrorCode errorCode) {
        if(errorCode == AgoraRtmQueryPeersOnlineErrorOk)
        {
            if(peerOnlineStatus != nil && peerOnlineStatus.count == 1)
            {
                AgoraRtmPeerOnlineStatus *status = peerOnlineStatus[0];
                if(status.isOnline)
                {
                    completionBlock(true, errorCode);
                }
                else
                {
                    completionBlock(false, errorCode);
                }
            }
            else
            {
                completionBlock(false, AgoraRtmQueryPeersOnlineErrorInvalidArgument);
            }
        }
        else
        {
            completionBlock(false, errorCode);
        }
    }];
}

// 登出RTM
+ (void) logoutRtm{
    if(_kit != nil)
    {
        InfoLog(RTMTAG,@"Logout rtm!");
        [_kit logoutWithCompletion:nil];
    }else{
        WarnLog(RTMTAG,@"Logout rtm failed, it's not inited!");
    }
}

// 发送消息
+ (void)sendP2PMessage: (nullable NSString *)msg  userAccount:( nullable NSString *)userId remoteUid:( nullable NSString *)peerId completion:(IACMSendPeerMessageBlock _Nullable)completionBlock{
    if(_kit == nil || peerId == nil || msg == nil || peerId.length == 0 || msg.length == 0)
    {
        ErrLog(RTMTAG,@"Error send msg Invalid parameters");
        if(completionBlock != nil){
            completionBlock(AgoraRtmSendPeerMessageErrorFailure);
        }
        
        return;
    }
    
    NSDictionary * rtmNotifyBean =
    @{@"title":@"textmsg",
      @"accountCaller": userId,
      @"accountRemote":peerId,
      @"channel":  [NSString stringWithFormat:@"%@%@", userId, peerId],
      @"data": msg
      };
    
    NSError *error;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:rtmNotifyBean options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:jsonStr];
    
    [_kit sendMessage:rtmMessage toPeer:peerId
     
           completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
               
               if(completionBlock != nil){
                   completionBlock(errorCode);
               }
               
               DebugLog(RTMTAG,@"Info Send msg result:%d" , (int)errorCode);
               
           }];
}

+ (void)invitePhoneCall: (nonnull AcmCall*) call
{
    for (int i=0; i<[call.subscriberList count]; i++) {
        NSString *peerId = call.subscriberList[i];
        [RunTimeMsgManager inviteSinglePhoneCall:peerId accountUser:call.callerId channelInfo:call.channelId call:call];
    }
    
    
}

// 发起邀请
+ (void)inviteSinglePhoneCall: (nonnull NSString *)remoteUid accountUser:(nullable NSString *)userId channelInfo:(nullable NSString *)channelId call:(nonnull AcmCall*)callInstance{
    NSDictionary * rtmNotifyBean =
    @{@"title":@"audiocall",
      @"accountCaller": userId,
      @"accountRemote":remoteUid,
      //@"subscribers": callInstance.subscriberList,
      @"channel":  channelId,
      };
    
    NSError *error;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:rtmNotifyBean options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:jsonStr];
    
    [_kit sendMessage:rtmMessage toPeer:remoteUid
     
           completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
               
               //sent((int)errorCode);
               if(errorCode == AgoraRtmSendPeerMessageErrorOk)
               {
                   // [self showAlert: @"消息已发送!"];
                   InfoLog(RTMTAG,@"Send phone call succeed!");

               }
               else
               {
                   NSString *errNote =  [[NSString alloc] initWithString:[NSString stringWithFormat:@"inviteSinglePhoneCall phone call failed:%d", (int)errorCode]];
                   
                   ErrLog(RTMTAG,@"Send phone call failed:%@", errNote);
                   
                   EventData eventData = {EventRtmDialFailed, errorCode,0,0,remoteUid,callInstance};
                   [actionMgr HandleEvent:eventData];
               }
           }];
}

// 拒绝邀请
+ (void)rejectPhoneCall: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID{
    NSDictionary * rtmNotifyBean =
    @{@"title":@"reject",
      @"accountCaller": userID,
      @"accountRemote":remoteUid,
      @"channel":  channelID,
      };
    
    NSError *error;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:rtmNotifyBean options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:jsonStr];
    
    [_kit sendMessage:rtmMessage toPeer:remoteUid
     
           completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
               
               //sent((int)errorCode);
               if(errorCode == AgoraRtmSendPeerMessageErrorOk)
               {
                   InfoLog(RTMTAG,@"Send reject phone call succeed!");
               }
               else
               {
                   NSString *errNote =  [[NSString alloc] initWithString:[NSString stringWithFormat:@"Send phone call failed:%d", (int)errorCode]];
                   //[self showAlert: errNote];
                   ErrLog(RTMTAG,@"Send reject phone call failed:%@", errNote);
               }
           }];
}

+ (void)agreePhoneCall: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID{
    NSDictionary * rtmNotifyBean =
    @{@"title":@"agreeCall",
      @"accountCaller": userID,
      @"accountRemote":remoteUid,
      @"channel":  channelID,
      };
    
    NSError *error;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:rtmNotifyBean options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:jsonStr];
    
    [_kit sendMessage:rtmMessage toPeer:remoteUid
     
           completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
               
               //sent((int)errorCode);
               if(errorCode == AgoraRtmSendPeerMessageErrorOk)
               {
                   // [self showAlert: @"消息已发送!"];
                  
                   InfoLog(RTMTAG,@"Send agree phone call succeed!");
               }
               else
               {
                   NSString *errNote =  [[NSString alloc] initWithString:[NSString stringWithFormat:@"Send phone call failed:%d", (int)errorCode]];
                   //[self showAlert: errNote];
                  ErrLog(RTMTAG,@"Send agree phone call failed:%@", errNote);
               }
           }];
    
}

+ (void)robotAnswerPhoneCall: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID{
    NSDictionary * rtmNotifyBean =
    @{@"title":@"robotAnswerCall",
      @"accountCaller": userID,
      @"accountRemote":remoteUid,
      @"channel":  channelID,
      };
    
    NSError *error;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:rtmNotifyBean options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:jsonStr];
    
    [_kit sendMessage:rtmMessage toPeer:remoteUid
     
           completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
               
               //sent((int)errorCode);
               if(errorCode == AgoraRtmSendPeerMessageErrorOk)
               {
                   // [self showAlert: @"消息已发送!"];
                   InfoLog(RTMTAG,@"Send robotAnswerCall succeed!");
               }
               else
               {
                   NSString *errNote =  [[NSString alloc] initWithString:[NSString stringWithFormat:@"Send phone call failed:%d", (int)errorCode]];
                   
                   ErrLog(RTMTAG,@"Send robotAnswerCall failed:%@", errNote);
               }
           }];
    
}

+ (void) dispatchEndDial: (nullable NSArray *)uidList userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID
{
    for(int i = 0; i < uidList.count; i++){
        [RunTimeMsgManager callerEndDial:uidList[i] userAccount:userID channelID:channelID];
    }
}

// 结束通话
+ (void) callerEndDial: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID{
    NSDictionary * rtmNotifyBean =
    @{@"title":@"callerEndDial",
      @"accountSender": userID,
      @"accountRemote":remoteUid,
      @"channel":  channelID,
      };
    
    NSError *error;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:rtmNotifyBean options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:jsonStr];
    
    [_kit sendMessage:rtmMessage toPeer:remoteUid
     
           completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
               
               //sent((int)errorCode);
               if(errorCode == AgoraRtmSendPeerMessageErrorOk)
               {
                   // [self showAlert: @"消息已发送!"];
                  
                   InfoLog(RTMTAG,@"Send callerEndDial succeed!");
               }
               else
               {
                   NSString *errNote =  [[NSString alloc] initWithString:[NSString stringWithFormat:@"Send phone call failed:%d", (int)errorCode]];
                   
                   ErrLog(RTMTAG,@"Send callerEndDial failed:%@", errNote);
               }
           }];
}

// ASR 数据同步
+ (void)syncAsrData: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID asrData:(nonnull NSString *)text timeStamp:(NSTimeInterval)startTime isFinished:(BOOL) finished{
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval msgStamp=[dat timeIntervalSince1970];
    NSNumber *asrTimeStamp = [NSNumber numberWithDouble:startTime];
    NSNumber *msgTimeStamp = [NSNumber numberWithDouble:msgStamp];
    
    NSDictionary * rtmNotifyBean =
    @{@"title":@"ASRSync",
      @"accountSender": userID,
      @"accountRemote":remoteUid,
      @"channel":  channelID,
      @"asrData": text,
      @"timeStamp": asrTimeStamp,
      @"isFinished": (finished == TRUE ? @"true" : @"false"),
      @"msgTimeStamp": msgTimeStamp,
      };
    
    NSError *error;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:rtmNotifyBean options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    AgoraRtmMessage *rtmMessage = [[AgoraRtmMessage alloc] initWithText:jsonStr];
    
    [_kit sendMessage:rtmMessage toPeer:remoteUid
     
           completion:^(AgoraRtmSendPeerMessageErrorCode errorCode) {
               
               //sent((int)errorCode);
               if(errorCode == AgoraRtmSendPeerMessageErrorOk)
               {
                   // [self showAlert: @"消息已发送!"];
                   InfoLog(RTMTAG,@"Send ASRSync succeed!");
               }
               else
               {
                   NSString *errNote =  [[NSString alloc] initWithString:[NSString stringWithFormat:@"Send asr data failed:%d", (int)errorCode]];
                   
                   ErrLog(RTMTAG,@"Send ASRSync failed:%@", errNote);
               }
           }];
}

+ (AgoraRtmChannel * _Nullable)createChannel:(NSString * _Nonnull)channelId
                                          Delegate:(id <AgoraRtmChannelDelegate> _Nullable)delegate{
    if(_kit != nil){
        return [_kit createChannelWithId:channelId delegate:delegate];
    }
    
    
    return nil;
}

+ (void) destroyChannelWithId:(NSString * _Nonnull) channelId{
    if(_kit != nil){
        [_kit destroyChannelWithId:channelId];
    }
}


#pragma mark - AgoraRtmDelegate
- (void)rtmKit:(AgoraRtmKit *)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    DebugLog(RTMTAG,@"connection state changed: %ld", state);
    
    
    EventData eventData = {EventRTMConnectionStateChange, (int)state,(int)reason,0};
    [actionMgr HandleEvent:eventData];
    
    if(acmCallBack != nil)
    {
        [acmCallBack connectionStateChanged:state reason:reason];
    }
    
}

- (void)rtmKit:(AgoraRtmKit *)kit messageReceived:(AgoraRtmMessage *)message fromPeer:(NSString *)peerId
{

    DebugLog(RTMTAG,@"P2P Message received from %@: %@", message.text, peerId);
    NSData *jsonData = [message.text dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    NSString *title = dic[@"title"];

    if( [title isEqualToString:@"textmsg"])
    {
        
        
        EventData eventData = {EventGotRtmTextMsg, 0,0,0,dic[@"data"],peerId,acmCallBack};
        [actionMgr HandleEvent:eventData];
    }
    else if( [title isEqualToString:@"audiocall"] )
    {
        
        InfoLog(RTMTAG,@"audio call from:%@, %channel:%@", peerId, dic[@"channel"]);
       
        [actionMgr.callMgr ValidateIncomeCall:dic[@"channel"] IsApnsCall:NO];
    }
    else if( [title isEqualToString:@"callerEndDial"] )
    {
        InfoLog(RTMTAG,@"callerEndDial call from:%@, %channel:%@", peerId, dic[@"channel"]);
        EventData eventData = {EventCallerEndDial, 0,0,0,dic[@"channel"]};
        [actionMgr HandleEvent:eventData];
    }
    else if( [title isEqualToString:@"reject"] )
    {
        InfoLog(RTMTAG,@"reject call from:%@, %channel:%@", peerId, dic[@"channel"]);
        EventData eventData = {EventRtmRejectAudioCall, 0,0,0,dic[@"channel"],peerId,acmCallBack};
        [actionMgr HandleEvent:eventData];
    }
    
    else if([title isEqualToString:@"ASRSync"])
    {
        DebugLog(RTMTAG,@"ASRSync from:%@, %channel:%@", peerId, dic[@"channel"]);
        EventData eventData = {  EventRemoteAsrResult, 0,0,0,dic};
        [actionMgr HandleEvent:eventData];
    }
    else if([title isEqualToString:@"agreeCall"])
    {
        InfoLog(RTMTAG,@"agreeCall from:%@, %channel:%@", peerId, dic[@"channel"]);
        EventData eventData = {EventRtmAgreeAudioCall, 0,0,0,dic[@"channel"]};
        [actionMgr HandleEvent:eventData];
    }
    else if([title isEqualToString:@"robotAnswerCall"])
    {
        InfoLog(RTMTAG,@"robotAnswerCall from:%@, %channel:%@", peerId, dic[@"channel"]);
        EventData eventData = {EventRTMRobotAnswer, 0,0,0,dic[@"channel"]};
        [actionMgr HandleEvent:eventData];
    }
}



@end
