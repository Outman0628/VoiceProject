//
//  InComeDialAction.m
//  ACM
//
//  Created by David on 2020/1/10.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InComeDialAction.h"
#import "../Call/Call.h"
#import "ActionManager.h"
#import "OnPhoneAction.h"
#import "../Message/RunTimeMsgManager.h"
#import "MonitorAction.h"

// 电话响铃Action
@interface InComeDialAction ()
@end

@implementation InComeDialAction

-(id _Nullable )init{
    if (self = [super init]) {
        self.type = ActionInComeDial;
    }
    return self;
}


- (void) HandleEvent: (EventData) eventData
{
    if(eventData.type == EventGotRtmAudioCall){
        [self HandleRtmCallReq:eventData];
    }
    else if(eventData.type == EventGotApnsAudioCall)
    {
        [self HandleApnsCallReq:eventData];
    }
    else if(eventData.type == EventAgreeAudioCall)
    {
        [self HandleAnswerCall:eventData];
    }
    else if(eventData.type == EventRejectAudioCall)
    {
        [self HandleRejectCall:eventData];
    }
}

-(void) HandleRtmCallReq: (EventData) eventData{
    /*
     if(acmCallBack != nil){
     [acmCallBack onCallReceived:dic[@"channel"] fromPeer:peerId];
     }
     */
    
    //EventData eventData = {EventGotRtmAudioCall, 0,0,0,dic[@"channel"],peerId,acmCallBack};
    Call *call = eventData.param4;
    id<IACMCallBack> callBack =  [ActionManager instance].icmCallBack;
    if(callBack != nil)
    {
        [callBack onCallReceived:call];
    }
}
-(void) HandleApnsCallReq: (EventData) eventData{
    id<IACMCallBack> callBack =  [ActionManager instance].icmCallBack;
    Call *call = eventData.param4;
    
    if(callBack != nil)
    {
        [callBack onCallReceived:call];
    }
}
- (void) HandleAnswerCall: (EventData) eventData{
    
    OnPhoneAction* onPhone = [[OnPhoneAction alloc]init];
    
    [[ActionManager instance] actionChange:self destAction:onPhone];
    
   [[ActionManager instance] HandleEvent:eventData];
}

- (void) HandleRejectCall: (EventData) eventData{
       
    Call *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    if(call != nil)
    {
        [call updateStage:Finished];
    }
    
    [RunTimeMsgManager rejectPhoneCall:call.callerId userAccount:call.selfId channelID:call.channelId];
    
    [self JumpBackToMonitorAction];
}

// 跳转回Monitor Action
- (void) JumpBackToMonitorAction{
    // 跳转到Monitor 状态
    MonitorAction * monitorAction = [[MonitorAction alloc]init:[ActionManager instance]];
    
    [[ActionManager instance] actionChange:self destAction:monitorAction];
    
}

@end
