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
    instance.callType = AudioCall;
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
                        [instance updateStage:Dialing];
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

-(void) ValidateIncomeCall: (AcmCall *_Nonnull)call IsApnsCall:(BOOL) isApnsCall{
    if([self IsActiveCall:call.channelId] == YES){
        if(isApnsCall){
            NSLog(@"Drop phone call:%@ from APNS as same call already exist!", call.channelId);
        }
        else{
            NSLog(@"Drop phone call:%@ from RTM as same call already exist!", call.channelId);
        }
        
        return;
    }
    
    [self.activeCallList addObject:call];
    
    [self  getBackendRecentActiveCall:[ActionManager instance].userId Block:^(NSArray * _Nullable activeCallList) {
        if(activeCallList != nil){
            for(int i = 0; i < activeCallList.count; i ++){
                if([call.channelId isEqualToString:activeCallList[i]]){
                    
                    ACMEventType type;
                    
                    if(isApnsCall){
                        type = EventGotApnsAudioCall;
                    }else{
                        type = EventGotRtmAudioCall;
                    }
                    
                    EventData eventData = {type, 0,0,0,call};
                    [[ActionManager instance] HandleEvent:eventData];
                }
            }
        }
    }];
}

@end
