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
#import "../RTC/RtcManager.h"
#import "../Message/HttpUtil.h"
#import "../Call/CallEventEnum.h"

#import "../Log/AcmLog.h"
#define InComeDialTag  @"InComeDial"

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
    DebugLog(InComeDialTag,@"HandleEvent:%ld",(long)eventData.type);
    
    if(eventData.type == EventGotRtmCall){       // step 1 RTM 来电消息
        [self HandleRtmCallReq:eventData];
    }
    else if(eventData.type == EventGotApnsCall)   // step 1 APNS 来电消息
    {
        [self HandleApnsCallReq:eventData];
    }
    else if(eventData.type == EventAgreeCall)    // step 2 同意接听电话
    {
        [self RequestAcceptDial:eventData];
    }
    else if(eventData.type == EventBackendRequestAcceptDialSucceed)  // step 3 创建消息同步通道
    {
        [self ReadyForOnPhone:eventData];
    }
    /*
    else if(eventData.type == EventBackendRequestAcceptDialSucceed)  // step 3 创建消息同步通道
    {
        [self JoinSyncChannel:eventData];
    }
    else if(eventData.type == EventJoinEventSyncChannelSucceed){    // step 4 回复拨号者，并进入通话状态
        [self ReadyForOnPhone:eventData];
    }
     */
    else if(eventData.type == EventRejectAudioCall)
    {
        [self HandleRejectCall:eventData];
    }
    else if(eventData.type == EventRobotAnswerCall)    // 请求后台委托机器人接听
    {
        [self HandleRobotAnswerCall:eventData];
    }
    else if(eventData.type == EventRobotAnsweredCall)  // 委托机器人接听成功，发送广播消息，进入onphone state
    {
        [self HandleEventRobotAnsweredCall:eventData];
    }
    else if(eventData.type == EventDialingTimeout)
    {
        [self handleDialingTimeout:eventData];
    }
    else if(eventData.type == EventCallerEndDial)
    {
        [self callerEndDial:eventData];
    }
    else if(eventData.type == EventDidRtcOccurError)
    {
        [self handleRtcError:eventData];
    }
    else if(eventData.type == EventRtmLeaveCall){
        [self HandleLeaveCall:eventData];
    }
    else
    {
        [super HandleEvent:eventData];
    }
}

- (void) ReadyForOnPhone: (EventData) eventData{
    AcmCall *call = eventData.param4;
    
    if(call != nil){        
        //[RunTimeMsgManager agreePhoneCall:call.callerId userAccount:call.selfId channelID:call.channelId];
        
        [call broadcastAgreePhoneCall];
        
        // 通知后台开始通话
        NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, CallEventAPI];
        NSString *param = [NSString stringWithFormat:@"uid=%@&channel=%@&code=%ld", call.selfId, call.channelId,(long)CallEventStartCall];
        
        [HttpUtil HttpPost:stringUrl Param:param Callback:nil];
        
        EventData nextData = { EventBackendAgreeAudioCall,0,0,0,call };
        OnPhoneAction* onPhone = [[OnPhoneAction alloc]init];
        
        [[ActionManager instance] actionChange:self destAction:onPhone];
        
        [[ActionManager instance] HandleEvent:nextData];
        
    }
}

/*
- (void) JoinSyncChannel: (EventData ) eventData{
    AcmCall *call = eventData.param4;
    
    BOOL joinEventChannelRet = [call joinEventSyncChannel:^(AgoraRtmJoinChannelErrorCode errorCode) {
        if(AgoraRtmJoinChannelErrorOk == errorCode){
            EventData nextEvent = {EventJoinEventSyncChannelSucceed,0,0,0,call};
            [[ActionManager instance] HandleEvent:nextEvent];
        }
        else{
            NSLog(@"ACM Err: failed to join event channel:%ld", (long)errorCode);
            [self quitIncomeDialingPhoneCall:call];
            if(call != nil && call.callback != nil)
            {
                
                [call.callback didPhoneDialResult:AcmDialErrorJoinEventSyncChannel];
            }
        }
    }];
    
    if(joinEventChannelRet == NO){
        [self quitIncomeDialingPhoneCall:call];
        if(call != nil && call.callback != nil)
        {
            
            [call.callback didPhoneDialResult:AcmDialErrorJoinEventSyncChannel];
        }
    }
}
 */

// 拨号过程中遇到问题结束拨号
- (void) handleRtcError: (EventData) eventData{
    AcmCall *call = [[ActionManager instance].callMgr getActiveCall];
    
    [self quitIncomeDialingPhoneCall:call EventCode:CallEventCallFailed_EndCall ];
    
    if(call != nil && call.callback != nil)
    {
        
        [call.callback didPhoneDialResult:AcmDialErrorJoinChannel];
        
        [call.callback didOccurError:eventData.param1];
    }
}

- (void) callerEndDial: (EventData) eventData{

    
    AcmCall *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    
    if(call != nil && call.role == Subscriber && call.stage == Dialing)
    {
        id<IACMCallBack> callBack =  [ActionManager instance].icmCallBack;
        if(callBack != nil)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [callBack onCallEnd:call endCode:AcmMsgDialEndByCaller];
            });
        }
    }
    
    [self quitIncomeDialingPhoneCall:call EventCode:CallEventCallerCancel_EndCall];
}

- (void) handleDialingTimeout: (EventData) eventData{
    AcmCall *call = eventData.param4;
    if(call != nil && call.stage == Dialing && call.role == Subscriber)
    {
        [call updateStage:Finished];
        [self JumpBackToMonitorAction];
        
        id<IACMCallBack> callBack =  [ActionManager instance].icmCallBack;
        if(callBack != nil)
        {
            dispatch_async(dispatch_get_main_queue(),^{
                [callBack onCallEnd:call endCode:AcmMsgDialEndTimeout];
            });
        }
    }
}

-(void) HandleRtmCallReq: (EventData) eventData{
    AcmCall *call = eventData.param4;
    id<IACMCallBack> callBack =  [ActionManager instance].icmCallBack;
    if(callBack != nil)
    {
        [callBack onCallReceived:call MemberList:[call getMemberList:YES]];
    }
}
-(void) HandleApnsCallReq: (EventData) eventData{
    id<IACMCallBack> callBack =  [ActionManager instance].icmCallBack;
    AcmCall *call = eventData.param4;
    
    if(callBack != nil)
    {
        [callBack onCallReceived:call MemberList:[call getMemberList:YES]];
    }
}


- (void) RequestAcceptDial: (EventData) eventData{
    AcmCall *call = eventData.param4;
    if(call == nil && call.role != Subscriber)
    {
        // todo callback return error
        return;
    }
    
    
    // 请求后台应答参数
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, GetRtcTokenApi];
    NSString *param =  [NSString stringWithFormat:@"uid=%@&channel=%@",call.selfId,call.channelId];
    
    [HttpUtil HttpPost:stringUrl Param:param Callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            BOOL ret = dic[@"success"];
            
            DebugLog(InComeDialTag,@"RequestAcceptDial Response:%@", dic);
            
            if(ret == YES)
            {
                NSDictionary *data = dic[@"data"];
                if(data != nil)
                {
                    call.appId = data[@"appID"];
                    call.channelId = data[@"channel"];
                    call.token = data[@"token"];
                }
                
                EventData eventData = {EventBackendRequestAcceptDialSucceed,0,0,0,call};
                dispatch_async(dispatch_get_main_queue(),^{
                    [[ActionManager instance] HandleEvent:eventData];
                });
            }
            else
            {
                // 通知错误发生
                [call updateStage:Finished];
                
                dispatch_async(dispatch_get_main_queue(),^{
                    [call.callback didPhoneDialResult: AcmDialErrorWrongApplyAnswerCallResponse];
                });
                
                // 跳转到Monitor 状态
                [self JumpBackToMonitorAction];
                
            }
        }else{
            // 通知错误发生
            [call updateStage:Finished];
            
            dispatch_async(dispatch_get_main_queue(),^{
                [call.callback didPhoneDialResult: AcmDialErrorApplyAnswerCall];
            });
            
            // 跳转到Monitor 状态
            [self JumpBackToMonitorAction];
        }
    }];
}

- (void) HandleEventRobotAnsweredCall: (EventData) eventData{
    AcmCall *call = eventData.param4;

    // step 1 广播代接事件
    [call broadcastRobotAnswerPhoneCall];
    
    // step 2 跳转到onphone state
    OnPhoneAction* onPhone = [[OnPhoneAction alloc]init];
    
    [[ActionManager instance] actionChange:self destAction:onPhone];
    
    EventData nextEventdata = {EventRobotAnsweredCall,0,0,0,call};
    
    [[ActionManager instance] HandleEvent:nextEventdata];
    
    dispatch_async(dispatch_get_main_queue(),^{
        
        [call.callback didPhoneDialResult: AcmDialRobotAnswered];
    });
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, CallEventAPI];
    NSString *param = [NSString stringWithFormat:@"uid=%@&channel=%@&code=%ld", call.selfId, call.channelId,(long)CallEventRecieverAskRobtAnswer];
    [HttpUtil HttpPost:stringUrl Param:param Callback:nil];
    
}

- (void) HandleRobotAnswerCall: (EventData) eventData{
    AcmCall *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    if(call == nil && call.role != Subscriber)
    {
        // todo callback return error
        return;
    }
    
    call.callback = eventData.param5;
    
    // 请求后台机器人应答
    
    NSString *stringUrl =  [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, RobotAnserApi];
    
    /*
    NSString *param = [NSString stringWithFormat:@"uid=%@&channel=%@",call.selfId,call.channelId];
     
     */
    
    NSDictionary * phoneCallParam =
    @{@"uid": call.selfId,
      @"channel":call.channelId,
      };
    
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:phoneCallParam options:NSJSONWritingPrettyPrinted error:&error];
    NSString *param = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    [HttpUtil HttpPost:stringUrl Param:param Callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            BOOL ret = dic[@"success"];
            
           DebugLog(InComeDialTag,@"HandleRobotAnswerCall Response:%@", dic);
            
            if(ret == YES)
            {
                NSDictionary *data = dic[@"data"];
                if(data != nil)
                {
                    call.appId = data[@"appID"];
                    call.channelId = data[@"channel"];
                    call.token = data[@"token"];
                }
                
                EventData nextEventdata = {EventRobotAnsweredCall,0,0,0,call};
                [[ActionManager instance] HandleEvent:nextEventdata];
            }
            else
            {
                // 通知错误发生
                [call updateStage:Finished];
                
                dispatch_async(dispatch_get_main_queue(),^{
                    [call.callback didPhoneDialResult: AcmDialErrorWrongApplyAnswerCallResponse];
                });
                
                // 跳转到Monitor 状态
                [self JumpBackToMonitorAction];
                
            }
        }else{
            // 通知错误发生
            [call updateStage:Finished];
            
            dispatch_async(dispatch_get_main_queue(),^{
                [call.callback didPhoneDialResult: AcmDialErrorApplyAnswerCall];
            });
            
            // 跳转到Monitor 状态
            [self JumpBackToMonitorAction];
        }
    }];
}

- (void) HandleRejectCall: (EventData) eventData{
    
    AcmCall *call = [[ActionManager instance].callMgr getCall:eventData.param4];    
    [call broadcastRejectDial];
    
    [self quitIncomeDialingPhoneCall:call EventCode:CallEventSelfReject_EndCall];
    if(call != nil && call.callback != nil)
    {
        
        [call.callback didPhoneDialResult:AcmSelfCancelDial];
    }
    
}

- (void) HandleLeaveCall: (EventData) eventData{
    AcmCall *call = eventData.param5;
    [call broadcastLeaveCall];
    
    id<IACMCallBack> callBack =  [ActionManager instance].icmCallBack;
    if(callBack != nil)
    {
        dispatch_async(dispatch_get_main_queue(),^{
            [callBack onCallEnd:call endCode:AcmMsgDialEndByCaller];
        });
    }
}

// 跳转回Monitor Action
- (void) JumpBackToMonitorAction{
    // 跳转到Monitor 状态
    MonitorAction * monitorAction = [[MonitorAction alloc]init:[ActionManager instance]];
    
    [[ActionManager instance] actionChange:self destAction:monitorAction];
    
}

- (void) quitIncomeDialingPhoneCall: (AcmCall *) call EventCode:(CallEventCode) eventCode{
    DebugLog(InComeDialTag,@"quitIncomeDialingPhoneCall");
    if(call != nil && call.stage == Dialing){
        [call updateStage:Finished];
        if(call.channelId != nil)
        {
            [RtcManager endAudioCall];
            
            NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, CallEventAPI];
            NSString *param = [NSString stringWithFormat:@"uid=%@&channel=%@&code=%ld", call.selfId, call.channelId,(long)eventCode]; //带一个参数key传给服务器
            
            [HttpUtil HttpPost:stringUrl Param:param Callback:nil];
        }

        [self JumpBackToMonitorAction];
    }
}

@end
