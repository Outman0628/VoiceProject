//
//  SDKInitAction.m
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDKInitAction.h"
#import "../Message/RunTimeMsgManager.h"
#import "ActionManager.h"
#import "../ASR/AudioStreamMgr.h"

@interface SDKInitAction()

@property ActionManager* actionMgr;

@end

@implementation SDKInitAction



-(id _Nullable)init: (nullable ActionManager *) mgr{
    if (self = [super init]) {
        
        self.type = ActionSDKInit;
        self.actionMgr = mgr;
    }
    return self;
}

- (void) HandleEvent: (EventData) eventData
{
    if(eventData.type == EventInitSDK)
    {
        [AudioStreamMgr initMgr];
        
        BOOL rtmResult = [RunTimeMsgManager init:eventData.param4 acmCallback:eventData.param5 actionMgr:self.actionMgr];
        
        if(rtmResult == YES)
        {
            [self.actionMgr actionDone:self];
        }
        
       
    }
    else{
        [super HandleEvent:eventData];
    }
}
@end
