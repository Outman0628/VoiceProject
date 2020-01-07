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


static AgoraRtmKit *_kit = nil;
static id<IACMCallBack> acmCallBack = nil;
static NSString *_userId = nil;
static Boolean _loginStatus = false;
static RunTimeMsgManager *instance = nil;

@interface RunTimeMsgManager ()  <AgoraRtmDelegate>
@end

@implementation RunTimeMsgManager

// 注册服务
+ (void) init: ( nullable NSString *) appId  acmCallback:(id <IACMCallBack> _Nullable)delegate{
    acmCallBack = delegate;
    if(_kit == nil)
    {
        instance = [RunTimeMsgManager alloc];
        _kit = [[AgoraRtmKit alloc] initWithAppId:appId delegate:instance];        
    }
    
    if(_kit == nil)
    {
        NSLog(@"Agora Rtm kit init returned nil");
    }
    else
    {
        NSLog(@"Agora Rtm kit init succeed!");
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
        
        if (errorCode != AgoraRtmLoginErrorOk) {
          
            NSLog(@"ACM Login failed:%ld", errorCode);
             if(completionBlock != nil)
             {
                 completionBlock(errorCode);
             }
        }
        else{
            _userId = userId;
            _loginStatus = true;
            NSLog(@"ACM Login succeeed!");
            if(completionBlock != nil)
            {
                completionBlock(errorCode);
            }
        }
    }];
}

// 发送消息
+ (void)sendP2PMessage: (nullable NSString *)msg remoteUid:( nullable NSString *)peerId completion:(IACMSendPeerMessageBlock _Nullable)completionBlock{
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
      @"accountCaller": _userId,
      @"accountRemote":peerId,
      @"channel":  [NSString stringWithFormat:@"%@%@", _userId, peerId],
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
+ (nullable NSString *)invitePhoneCall: (nullable NSString *)remoteUid{
    NSDictionary * rtmNotifyBean =
    @{@"title":@"audiocall",
      @"accountCaller": _userId,
      @"accountRemote":remoteUid,
      @"channel":  [NSString stringWithFormat:@"%@%@", _userId, remoteUid]
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
        
        if(acmCallBack != nil){
            [acmCallBack messageReceived:dic[@"data"] fromPeer:peerId];
        }
    }
    else if( [title isEqualToString:@"audiocall"] )
    {
        //- (void)onCallReceived:(NSString * _Nonnull)channel fromPeer:(NSString * _Nonnull)peerId;
        NSLog(@"audio call from:%@", peerId );
        if(acmCallBack != nil){
            [acmCallBack onCallReceived:dic[@"channel"] fromPeer:peerId];
        }
    }
}



@end
