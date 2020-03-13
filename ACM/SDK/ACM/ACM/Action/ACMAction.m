//
//  ACMAction.m
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACMAction.h"
#import "../IRTCCallBack.h"
#import "../RTC/RtcManager.h"
#import "LoginAction.h"
#import "ActionManager.h"

#import "../Log/AcmLog.h"
#define ActionTag  @"Action"

@implementation  ACMAction
/**
 进入Action 时处理事宜
 */
- (void) EnterEntry{
    
}

/**
 Action 退出
 */
- (void) ExitEntry{
    
}
/**
 Action 事件处理
 */
- (void) HandleEvent: (EventData) eventData{
    DebugLog(ActionTag,@"HandleEvent:%ld",(long)eventData.type);
    if(eventData.type == EventGetAuthority)
    {
        [self handleBaseEventGetAuthority:eventData];
    }
    else if(eventData.type == EventRTMConnectionStateChange)
    {
        [self handleRTMConnectionStateChanged:eventData];
    }
    else if(eventData.type == EventDidRtcOccurWarning)
    {
        [self handleRTCWarning:eventData];
    }
}

- (void)handleRTCWarning: (EventData)eventData{
    ActionManager *actionMgr = [ActionManager instance];
    AcmCall *call = nil;
    if(actionMgr != nil)
    {
        call = [actionMgr.callMgr getActiveCall];
    }
    
    if(call != nil && call.callback != nil){
        [call.callback  didPhonecallOccurWarning:eventData.param1];
    }
}

- (void)handleRTMConnectionStateChanged: (EventData)eventData{
    AgoraRtmConnectionState state = (AgoraRtmConnectionState)eventData.param1;
    
    if(state == AgoraRtmConnectionStateAborted)
    {
        [RtcManager endAudioCall];
        LoginAction *nextAction = [[LoginAction alloc]init:[ActionManager instance] apnsToken:[ActionManager instance].apnsToken];
        [[ActionManager instance] actionChange:self destAction:nextAction];
    }
    
   
}

- (void) handleBaseEventGetAuthority: (EventData) eventData{
    IRTCAGetAuthorityBlock callback = eventData.param5;
    if( callback != nil )
    {
        callback(AcmPhoneCallErrorNoAuthority);
    }
}

@end
