//
//  Call.m
//  ACM
//
//  Created by David on 2020/1/9.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AcmCall.h"
#import "../Action/ActionManager.h"
#import "AcmCall.h"


@interface Call()
@property NSTimer *dialTimer;      // 拨号，拨号应答超时器
// 在线人员列表
@property NSMutableArray *  _Nonnull onlineMemberList;
@end

@implementation Call

-(id _Nullable )init
{
    if (self = [super init]) {
        self.localMuteState = false;
        self.remoteMuteState = false;
        self.subscriberList = [NSMutableArray array];
        self.onlineMemberList = [NSMutableArray array];
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

-(void)dialringTimeout{
    EventData eventData = {EventDialingTimeout,0,0,0,self};
    [[ActionManager instance] HandleEvent:eventData];
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
    
    if(_stage == Finished)
    {
        AcmCall *sonCall = (AcmCall *)self;
        [sonCall CallEnd];
    }
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

-(void)updateOnlineMember: (nonnull NSString *)uid Online:(BOOL)isOnline{
    for(int i = 0; i < _onlineMemberList.count ; i++){
        
        if([uid isEqualToString:_onlineMemberList[i]]){
            
            if(isOnline){
                    return;
                }
            else{
                [_onlineMemberList removeObjectAtIndex:i];
                return;
            }
        }
    }
    
    if(isOnline){
        [_onlineMemberList addObject:uid];
    }
        
}

- (NSArray *_Nonnull)getOnlineMembers{
    return _onlineMemberList;
}
@end
