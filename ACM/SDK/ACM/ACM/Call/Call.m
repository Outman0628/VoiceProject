//
//  Call.m
//  ACM
//
//  Created by David on 2020/1/9.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Call.h"

@interface Call()
@end

@implementation Call

-(id _Nullable )init
{
    if (self = [super init]) {
        self.localMuteState = false;
        self.remoteMuteState = false;
        self.subscriberList = [NSMutableArray array];
    }
    return self;
}

-(void)addSubscriber: (nonnull NSString *) subscriberId
{
    BOOL isDuplicate = NO;
    for (int i=0; i<[self.subscriberList count]; i++) {
        NSString *subId = self.subscriberList[i];
        if([subId isEqualToString:subscriberId])
        {
            isDuplicate = YES;
            break;
        }
        
    }
    
    if(isDuplicate == NO)
    {
        [self.subscriberList addObject:subscriberId];
    }
}

-(void)updateStage: (CallStage) stage{
    self.stage = stage;    
}

-(void)endObserverMode
{
    if(self.role == Observer)
    {
        if([self.selfId isEqualToString:self.callerId])
        {
            self.role = Originator;
        }
        else
        {
            self.role = Subscriber;
        }
    }
}

@end
