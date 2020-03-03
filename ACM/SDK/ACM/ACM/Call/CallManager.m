//
//  CallManager.m
//  ACM
//
//  Created by David on 2020/1/9.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallManager.h"
#import "../Action/ActionManager.h"
#import "../Message/HttpUtil.h"

@interface CallManager()
@property NSMutableArray * _Nullable validateCallList;  // 校验电话
@end


@implementation CallManager

/*
+( nonnull Call * )prepareDialCall: (nonnull NSString *)peerId ircmCallback:(id <IRTCCallBack> _Nullable)delegate
{
    Call *instance = [[Call alloc]init];
    instance.callType = AudioCall;
    [instance updateStage:Dialing];
    instance.role = Originator;
    instance.callback = delegate;
    [instance addSubscriber:peerId];
    return instance;
}
 */

+( nonnull AcmCall * )prepareDialCall: (nonnull NSArray *)peerList Type:(CallType)type ircmCallback:(id <IRTCCallBack> _Nullable)delegate
{
    if(peerList != nil && peerList.count > 0){
        AcmCall *instance = [[AcmCall alloc]init];
        instance.callType = type;
        [instance updateStage:Dialing];
        instance.role = Originator;
        instance.callback = delegate;
        for(int i = 0; i < peerList.count; i++){
            [instance addSubscriber:peerList[i]];
        }
        return instance;
    }
    
    return nil;
}

-(id _Nullable )init
{
    if (self = [super init]) {
        
        self.activeCallList = [NSMutableArray array];
        self.validateCallList =[NSMutableArray array];
    }
    return self;
}

/*
 检测通话是否已经存在
 
 @param channelId 通话 channel
 @return YES 通话已经存在，No 通话不存在
 */
-(BOOL )IsActiveCall: (nonnull NSString *)channelId
{
    BOOL ret = NO;
    
    for (int i=0; i<[self.activeCallList count]; i++) {
        AcmCall *call =self.activeCallList[i];
        if([call.channelId isEqualToString:channelId])
        {
            ret = TRUE;
            break;
        }
    }
    
    return ret;
}

/*
 检测通话是否已经校验
 
 @param channelId 通话 channel
 @return YES 通话已经存在，No 通话不存在
 */
-(BOOL )IsValidatedCall: (nonnull NSString *)channelId
{
    BOOL ret = NO;
    
    for (int i=0; i<[self.validateCallList count]; i++) {
        if([self.validateCallList[i] isEqualToString:channelId])
        {
            ret = TRUE;
            break;
        }
    }
    
    return ret;
}

-( nonnull AcmCall * )createReceveCall: (nonnull NSDictionary *)callReq userAccount:(nonnull NSString *)userId
{
    AcmCall *instance = [[AcmCall alloc]init];
    instance.callType = AudioCall;
    [instance updateStage:Dialing];
    instance.role = Subscriber;
    instance.callerId = callReq[@"accountCaller"];
    instance.channelId = callReq[@"channel"];
    //instance.subscriberList = callReq[@"subscribers"];
    instance.selfId = userId;
    
    
    
    return instance;
}

-( nonnull AcmCall * )updateDialCall: (nonnull NSDictionary *)callInfo selfUid:(nonnull NSString*)uid ircmCallback:(id <IRTCCallBack> _Nullable)delegate  preInstance:(nonnull AcmCall *)call;
{
    AcmCall *instance = call;
    //instance.callType = AudioCall;
    [instance updateStage:Dialing];
    instance.role = Originator;
   
    instance.callerId = callInfo[@"uid"];;
    instance.channelId = callInfo[@"channel"];
    instance.token =callInfo[@"token"];
    instance.appId =callInfo[@"appID"];
    instance.selfId = uid;
    instance.callback = delegate;
    
    [self.activeCallList addObject:instance];
    
    return instance;
}

-( nullable AcmCall * )getCall: (nullable NSString*)channelId
{
    AcmCall *instance = nil;
    
    for (int i=0; i<[self.activeCallList count]; i++) {
        AcmCall *call =self.activeCallList[i];
        if([call.channelId isEqualToString:channelId])
        {
            instance = self.activeCallList[i];
            break;
        }
    }
    return instance;
}

-( nullable AcmCall * )getActiveCall{
    AcmCall *instance = nil;
    
    if(self.activeCallList.count > 0){
        instance = self.activeCallList[self.activeCallList.count - 1];
    }
    
    if(instance != nil && instance.stage != Finished){
        return instance;
    }
        
    return nil;
}

/*
 从后台服务器获取用户最近时间内的有效通话
 */
/*
-(void)getBackendRecentActiveCall:(NSString *_Nonnull)uid Block:(void(^_Nullable)(NSArray *_Nullable activeCallList))block{
    
    if(uid == nil){
        if(block != nil){
            block(nil);
        }
        
        return;
    }
    
    
    
        NSMutableArray *activeCalls = [NSMutableArray array];
        AcmCall *instance = [[AcmCall alloc]init];

        
        
        instance.callType = AudioCall;
        
        instance.callerId = @"98087081204514816";
        
        
        instance.role = Subscriber;
        instance.channelId = @"ch_9S6125zD30";
        NSMutableArray *list = [NSMutableArray array];
        [list addObject:@"511"];
        instance.subscriberList = list;
        instance.selfId = [ActionManager instance].userId;
        
        [activeCalls addObject:instance];
    
    
    if(block != nil){
        dispatch_async(dispatch_get_main_queue(),^{
            block(activeCalls);
        });
    }
}
*/

-(void)getBackendRecentActiveCall:(NSString *_Nonnull)uid Block:(void(^_Nullable)(NSArray *_Nullable activeCallList))block{
    
    if(uid == nil){
        if(block != nil){
            block(nil);
        }
  
        return;
    }
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, ActiveCallApi];
    
    
    NSDictionary * phoneCallParam =
    @{@"uid": uid,
      };
    
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:phoneCallParam options:NSJSONWritingPrettyPrinted error:&error];
    NSString *param = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    [HttpUtil HttpPost:stringUrl Param:param Callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            BOOL ret = dic[@"success"];
            
            if(ret == YES)
            {
                
                NSMutableArray *activeCalls = [NSMutableArray array];
                NSArray *data = dic[@"data"];
                
                if(data != nil && data.count > 0){
                    for(int i = 0; i < data.count; i++){
                        @try{
                            AcmCall *instance = [[AcmCall alloc]init];
                            NSString *extrMsg = data[i][@"extra_msg"];
                            if(extrMsg == nil)
                            {
                                NSLog(@"ACM error, no extra msg for call!");
                                continue;
                            }
                            NSError *errTest;
                            NSData *extraJsonData = [extrMsg dataUsingEncoding:NSUTF8StringEncoding];
                            NSDictionary *extraDic = [NSJSONSerialization JSONObjectWithData:extraJsonData options:NSJSONReadingMutableContainers error:&errTest];
                            
                       
                            instance.callType = ((NSNumber *)extraDic[@"Type"]).integerValue;
                            
                            instance.callerId = extraDic[@"CallerId"];
                            // 如果是拨号者，放弃通话
                            if([instance.callerId isEqualToString:[ActionManager instance].userId])
                            {
                                continue;
                            }
                            
                            instance.role = Subscriber;
                            instance.channelId = data[i][@"channel"];
                            instance.subscriberList = extraDic[@"Subscribers"];
                            instance.selfId = [ActionManager instance].userId;
                            
                            [activeCalls addObject:instance];
                        } @catch (NSException *exc){
                            continue;
                        }
                    }
                    
                    if(block != nil){
                        dispatch_async(dispatch_get_main_queue(),^{
                            block(activeCalls);
                        });
                    }
                }else{
                    if(block != nil){
                        block(nil);
                    }
                }
            }
            else
            {
                if(block != nil){
                    block(nil);
                }
            }
        }
        else{
            if(block != nil){
                block(nil);
            }
        }
    }];
}
 

-(void) ValidateIncomeCall: (NSString *_Nonnull)channelId IsApnsCall:(BOOL) isApnsCall{
    
    if([self IsValidatedCall:channelId] == YES){
        if(isApnsCall){
            NSLog(@"Drop phone call:%@ from APNS as same call already exist!", channelId);
        }
        else{
            NSLog(@"Drop phone call:%@ from RTM as same call already exist!", channelId);
        }
        
        return;
    }
    
    
    [self.validateCallList addObject:channelId];
    
    
    [self  getBackendRecentActiveCall:[ActionManager instance].userId Block:^(NSArray * _Nullable activeCallList) {
        //[[ActionManager instance].icmCallBack debugInfo: [NSString stringWithFormat:@"got backend active call response" ]];
        if(activeCallList != nil){
            for(int i = 0; i < activeCallList.count; i ++){
                AcmCall *itemCall = activeCallList[i];
                if([channelId isEqualToString:itemCall.channelId]){
                    
                    ACMEventType type;
                    
                    if(isApnsCall){
                        type = EventGotApnsCall;
                    }else{
                        type = EventGotRtmCall;
                    }
                    
                    
                    [itemCall updateStage:Validating];
                    
                    // 加入eventChannel
                    [itemCall joinEventSyncChannel:^(AgoraRtmJoinChannelErrorCode errorCode) {
                        if(errorCode != AgoraRtmJoinChannelErrorOk && errorCode != AgoraRtmJoinChannelErrorAlreadyJoined){
                            NSLog(@"ACC error: failed to joinEventSyncChannel:%ld",errorCode );
                            [itemCall updateStage:Finished];
                        }
                    }];

                    return;
                }
            }
        }
    }];
}

-(void) AddValidatedIncomeCall: (AcmCall *_Nonnull) call{
    if(call != nil){
        if([self IsActiveCall:call.channelId] == NO){
            [_activeCallList addObject:call];
        }
    }
}

@end
