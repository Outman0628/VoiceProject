//
//  CallManager.m
//  ACM
//
//  Created by David on 2020/1/9.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CallManager.h"

@interface CallManager()

@end

@implementation CallManager

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

-(id _Nullable )init
{
    if (self = [super init]) {
        
        self.activeCallList = [NSMutableArray array];
    }
    return self;
}

-(BOOL )IsActiveCall: (nonnull NSString *)channelId
{
    BOOL ret = NO;
    
    for (int i=0; i<[self.activeCallList count]; i++) {
        Call *call =self.activeCallList[i];
        if([call.channelId isEqualToString:channelId])
        {
            ret = TRUE;
            break;
        }
    }
    
    return ret;
}

-( nonnull Call * )createReceveCall: (nonnull NSDictionary *)callReq userAccount:(nonnull NSString *)userId
{
    Call *instance = [[Call alloc]init];
    instance.callType = AudioCall;
    [instance updateStage:Dialing];
    instance.role = Subscriber;
    instance.callerId = callReq[@"accountCaller"];
    instance.channelId = callReq[@"channel"];
    instance.selfId = userId;
    
    [self.activeCallList addObject:instance];
    
    return instance;
}

-( nonnull Call * )updateDialCall: (nonnull NSDictionary *)callInfo selfUid:(nonnull NSString*)uid remoteUser:(nonnull NSString *)peerId ircmCallback:(id <IRTCCallBack> _Nullable)delegate  preInstance:(nonnull Call *)call;
{
    Call *instance = call;
    instance.callType = AudioCall;
    [instance updateStage:Dialing];
    instance.role = Originator;
   
    instance.callerId = callInfo[@"uid"];;
    instance.channelId = callInfo[@"channel"];
    instance.token =callInfo[@"token"];
    instance.appId =callInfo[@"appID"];
    instance.selfId = uid;
    instance.callback = delegate;
    [instance addSubscriber:peerId];
    
    [self.activeCallList addObject:instance];
    
    return instance;
}

-( nullable Call * )getCall: (nullable NSString*)channelId
{
    Call *instance = nil;
    
    for (int i=0; i<[self.activeCallList count]; i++) {
        Call *call =self.activeCallList[i];
        if([call.channelId isEqualToString:channelId])
        {
            instance = self.activeCallList[i];
            break;
        }
    }
    return instance;
}

@end
