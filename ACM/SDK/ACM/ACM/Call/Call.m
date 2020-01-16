//
//  Call.m
//  ACM
//
//  Created by David on 2020/1/9.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Call.h"
#import "../Action/ActionManager.h"

@interface Call()
@property NSTimer *dialTimer;      // 拨号，拨号应答超时器
@end

@implementation Call

-(id _Nullable )init
{
    if (self = [super init]) {
        self.localMuteState = false;
        self.remoteMuteState = false;
        self.subscriberList = [NSMutableArray array];
        self.dialTimer = nil;
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
   // self.stage = stage;
    _stage = stage;
    if(_stage == Dialing)
    {
        if(_dialTimer == nil)
        {
            _dialTimer = [NSTimer scheduledTimerWithTimeInterval:[ActionManager instance].dialingTimetout repeats:NO block:^(NSTimer * _Nonnull timer) {
                 [self dialringTimeout];
            }];
        }
    }
    else
    {
        if(_dialTimer != nil)
        {
            [_dialTimer invalidate];
        }
    }
}

-(void)dialringTimeout{
    EventData eventData = {EventDialingTimeout,0,0,0,self};
    [[ActionManager instance] HandleEvent:eventData];
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
