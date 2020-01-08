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


static AgoraRtmKit *_kit = nil;
static id<IACMCallBack> acmCallBack = nil;
//static NSString *_userId = nil;
static Boolean _loginStatus = false;
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
        NSLog(@"Error: Agora Rtm kit init returned nil");
        return NO;
    }
    else
    {
        NSLog(@"Agora Rtm kit init succeed!");
        return YES;
    }
}

// 登录RTM
+ (void) loginACM: ( nullable NSString *) userId completion:(IACMLoginBlock _Nullable)completionBlock{
    
    if(_kit == nil && completionBlock != nil)
    {
        NSLog(@"Err ACM not inited!");
        completionBlock(AgoraRtmLoginErrorUnknown);
        return;
    }
    
    [_kit loginByToken:nil user:userId completion:^(AgoraRtmLoginErrorCode errorCode) {
        
        EventData eventData = {EventRTMLoginResult, errorCode,0,0,completionBlock};
        [actionMgr HandleEvent:eventData];
        
        
        
    }];
}

// 发送消息
+ (void)sendP2PMessage: (nullable NSString *)msg  userAccount:( nullable NSString *)userId remoteUid:( nullable NSString *)peerId completion:(IACMSendPeerMessageBlock _Nullable)completionBlock{
    if(_kit == nil || peerId == nil || msg == nil || peerId.length == 0 || msg.length == 0)
    {
        NSLog(@"Error send msg Invalid parameters");
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
               
               NSLog(@"Info Send msg result:%d" , (int)errorCode);
               
           }];
}

// 发起邀请
+ (nullable NSString *)invitePhoneCall: (nullable NSString *)remoteUid acountRemote:(nullable NSString *)userId{
    NSDictionary * rtmNotifyBean =
    @{@"title":@"audiocall",
      @"accountCaller": userId,
      @"accountRemote":remoteUid,
      @"channel":  [NSString stringWithFormat:@"%@%@", userId, remoteUid]
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
                   NSLog(@"Send phone call succeed!");
               }
               else
               {
                   NSString *errNote =  [[NSString alloc] initWithString:[NSString stringWithFormat:@"Send phone call failed:%d", (int)errorCode]];
                   //[self showAlert: errNote];
                   NSLog(@"%@",errNote);
               }
           }];
    
    return rtmNotifyBean[@"channel"];
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
                   // [self showAlert: @"消息已发送!"];
                   NSLog(@"Send phone call succeed!");
               }
               else
               {
                   NSString *errNote =  [[NSString alloc] initWithString:[NSString stringWithFormat:@"Send phone call failed:%d", (int)errorCode]];
                   //[self showAlert: errNote];
                   NSLog(@"%@",errNote);
               }
           }];
}

// 结束通话
+ (void) leaveCall: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID{
    NSDictionary * rtmNotifyBean =
    @{@"title":@"leave",
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
                   NSLog(@"Send phone call succeed!");
               }
               else
               {
                   NSString *errNote =  [[NSString alloc] initWithString:[NSString stringWithFormat:@"Send phone call failed:%d", (int)errorCode]];
                   //[self showAlert: errNote];
                   NSLog(@"%@",errNote);
               }
           }];
}


#pragma mark - AgoraRtmDelegate
- (void)rtmKit:(AgoraRtmKit *)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason {
    NSString *message = [NSString stringWithFormat:@"connection state changed: %ld", state];
    NSLog(@"%@", message);
    
    if(acmCallBack != nil)
    {
        [acmCallBack connectionStateChanged:state reason:reason];
    }
    
}

- (void)rtmKit:(AgoraRtmKit *)kit messageReceived:(AgoraRtmMessage *)message fromPeer:(NSString *)peerId
{
    /*
     [dic[@"data"] stringValue]
     NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
     NSDictionary *resultDic1 = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
     */
    NSLog(@"Message received from %@: %@", message.text, peerId);
    NSData *jsonData = [message.text dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    NSString *title = dic[@"title"];
    /*
     @param peerId The user ID of the sender.
     
    - (void)messageReceived:(AgoraRtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId;
     */
    if( [title isEqualToString:@"textmsg"])
    {
        NSLog( @"%@",dic[@"data"]);
        
        /*
        if(acmCallBack != nil){
            [acmCallBack messageReceived:dic[@"data"] fromPeer:peerId];
        }
         */
        
        EventData eventData = {EventGotRtmTextMsg, 0,0,0,dic[@"data"],peerId,acmCallBack};
        [actionMgr HandleEvent:eventData];
    }
    else if( [title isEqualToString:@"audiocall"] )
    {
        //- (void)onCallReceived:(NSString * _Nonnull)channel fromPeer:(NSString * _Nonnull)peerId;
        NSLog(@"audio call from:%@", peerId );
        /*
        if(acmCallBack != nil){
            [acmCallBack onCallReceived:dic[@"channel"] fromPeer:peerId];
        }
         */
        
        EventData eventData = {EventGotRtmAudioCall, 0,0,0,dic[@"channel"],peerId,acmCallBack};
        [actionMgr HandleEvent:eventData];
    }
    else if( [title isEqualToString:@"reject"] )
    {
        EventData eventData = {EventRtmRejectAudioCall, 0,0,0,dic[@"channel"],peerId,acmCallBack};
        [actionMgr HandleEvent:eventData];
    }
    else if( [title isEqualToString:@"leave"] )
    {
        EventData eventData = {EventRtmLeaveCall, 0,0,0,dic[@"channel"],peerId,acmCallBack};
        [actionMgr HandleEvent:eventData];
    }
}



@end
