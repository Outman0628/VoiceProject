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

-( nonnull Call * )createReceveCall: (nonnull NSDictionary *)callReq
{
    Call *instance = [[Call alloc]init];
    instance.callType = AudioCall;
    instance.stage = Dialing;
    instance.role = Subscriber;
    instance.callerId = callReq[@"accountCaller"];
    instance.channelId = callReq[@"channel"];
    
    [self.activeCallList addObject:instance];
    
    return instance;
}
@end
