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
    if(eventData.type == EventBackendAgreeAudioCall)
    {
        [self JoinAudioCall:eventData];
    }
    else if(eventData.type == EventLeaveCall)
    {
        [self leaveCall:eventData];
    }
    else if(eventData.type == EventRtmLeaveCall)
    {
        [self remoteLeaveCall:eventData];
    }
    else if(eventData.type == EventRobotAnsweredCall)
    {
        [self HandleRobotAnsweredCall:eventData];
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

- (void) JoinAudioCall: (EventData) eventData{
    /*
    [AudioCallManager startAudioCall:eventData.param4 user:eventData.param5 channel:eventData.param6 rtcToken:nil rtcCallback:eventData.param7];
     */
    Call *call = eventData.param4;
    if(call != nil)
    {
        
        [AudioCallManager startAudioCall:call.appId user:call.selfId channel:call.channelId rtcToken:call.token callInstance:call];
        
        [AudioCallManager muteLocalAudioStream:false];
        
        [call updateStage:OnPhone];
        
    }
}

- (void) HandleRobotAnsweredCall: (EventData) eventData{
    /*
     [AudioCallManager startAudioCall:eventData.param4 user:eventData.param5 channel:eventData.param6 rtcToken:nil rtcCallback:eventData.param7];
     */
    Call *call = eventData.param4;
    call.role = Observer;

        [AudioCallManager startAudioCall:call.appId user:call.selfId channel:call.channelId rtcToken:call.token callInstance:call];
    
    [AudioCallManager muteLocalAudioStream:true];
        
    [call updateStage:OnPhone];
        
   
}

- (void) leaveCall: (EventData) eventData{
    Call *paramCall = eventData.param4;
    Call *call = nil;
    if(paramCall != nil)
    {
        call =  [[ActionManager instance].callMgr getCall:paramCall.channelId];
    }
    
    if(call != nil){
        if(call.role == Subscriber)  // 如果是观察者模式，不用给发起者发消息通知
        {
            [RunTimeMsgManager leaveCall:call.callerId userAccount:call.selfId channelID:call.channelId];
        }
        else if(call.role == Originator)
        {
            // todo 多人列表
            [RunTimeMsgManager leaveCall:call.subscriberList[0] userAccount:call.selfId channelID:call.channelId];
        }
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
