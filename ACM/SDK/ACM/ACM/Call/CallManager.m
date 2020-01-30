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
    instance.selfId = userId;
    
    [self.activeCallList addObject:instance];
    
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

@end
