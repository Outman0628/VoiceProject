//
//  OnPhoneAction.m
//  ACM
//
//  Created by David on 2020/1/10.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OnPhoneAction.h"
#import "MonitorAction.h"
#import "../Call/Call.h"
#import "ActionManager.h"
#import "../RTC/AudioCallManager.h"
#import "../Message/RunTimeMsgManager.h"

// 电话响铃Action
@interface OnPhoneAction ()
@end

@implementation OnPhoneAction
-(id _Nullable )init{
    if (self = [super init]) {
        self.type = ActionOnPhone;
    }
    return self;
}


- (void) HandleEvent: (EventData) eventData
{
    if(eventData.type == EventAgreeAudioCall)
    {
        [self HandleAnswerCall:eventData];
    }
    else if(eventData.type == EventLeaveCall)
    {
        [self leaveCall:eventData];
    }
    else if(eventData.type == EventRtmLeaveCall)
    {
        [self remoteLeaveCall:eventData];
    }
}

- (void) remoteLeaveCall: (EventData) eventData{
    
    [AudioCallManager endAudioCall];
    
    Call *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    if(call != nil)
    {
        [call updateStage:Finished];
        if(call.callback != nil)
        {
            [call.callback didPhoneCallResult:AcmPhoneCallCodeRemoteEnd];
        }
        [self JumpBackToMonitorAction];
    }
     
}

- (void) HandleAnswerCall: (EventData) eventData{
    /*
    [AudioCallManager startAudioCall:eventData.param4 user:eventData.param5 channel:eventData.param6 rtcToken:nil rtcCallback:eventData.param7];
     */
    Call *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    if(call != nil)
    {
        //+ (void) startAudioCall: ( nullable NSString *) appId  user:(nullable NSString *)userID  channel:(nullable NSString *)channelId rtcToken:(nullable NSString *)token callInstance:(nonnull Call*) call;
        call.callback = eventData.param5;
        [AudioCallManager startAudioCall:[ActionManager instance].appId user:call.selfId channel:call.channelId rtcToken:nil callInstance:call];
        
        
        [call updateStage:OnPhone];
        
    }
}

- (void) leaveCall: (EventData) eventData{
    Call *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    if(call != nil){
        [RunTimeMsgManager leaveCall:call.callerId userAccount:call.selfId channelID:call.channelId];
        [AudioCallManager endAudioCall];
        [call updateStage:Finished];
        [self JumpBackToMonitorAction];
    }
}

// 跳转回Monitor Action
- (void) JumpBackToMonitorAction{
    // 跳转到Monitor 状态
    MonitorAction * monitorAction = [[MonitorAction alloc]init:[ActionManager instance]];
    
    [[ActionManager instance] actionChange:self destAction:monitorAction];

}

@end
