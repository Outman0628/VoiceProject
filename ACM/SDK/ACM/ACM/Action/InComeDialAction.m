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

static NSString *RobotAnserApi = @"/dapi/invite/robot";
static NSString *AnswerApi = @"/dapi/call/recieve";

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
    
    [self quitIncomeDialingPhoneCall:call ];
    
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
    
    [self quitIncomeDialingPhoneCall:call];
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
        [callBack onCallReceived:call];
    }
}
-(void) HandleApnsCallReq: (EventData) eventData{
    id<IACMCallBack> callBack =  [ActionManager instance].icmCallBack;
    AcmCall *call = eventData.param4;
    
    if(callBack != nil)
    {
        [callBack onCallReceived:call];
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
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, AnswerApi];
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.timeoutInterval = 5.0;
    
    request.HTTPMethod = @"POST";
    
    NSString *bodyString = [NSString stringWithFormat:@"uid=%@&channel=%@",call.selfId,call.channelId];
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //NSLog(@"response code:%@d", [(NSHTTPURLResponse *)response statusCode]);
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            BOOL ret = dic[@"success"];
            
            NSLog(@"Response:%@", dic);
            
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
    }] resume];
}

- (void) HandleEventRobotAnsweredCall: (EventData) eventData{
    AcmCall *call = eventData.param4;
    
    // step 1 加入事件频道
    BOOL joinEventChannelRet = [call joinEventSyncChannel:^(AgoraRtmJoinChannelErrorCode errorCode) {
        if(AgoraRtmJoinChannelErrorOk == errorCode){
            
            // step 2 广播代接事件
            [call broadcastRobotAnswerPhoneCall];
            
            // step 3 跳转到onphone state
            OnPhoneAction* onPhone = [[OnPhoneAction alloc]init];

            [[ActionManager instance] actionChange:self destAction:onPhone];
            
            EventData nextEventdata = {EventRobotAnsweredCall,0,0,0,call};
            
            [[ActionManager instance] HandleEvent:nextEventdata];
            
            dispatch_async(dispatch_get_main_queue(),^{
                
                [call.callback didPhoneDialResult: AcmDialRobotAnswered];
            });
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

- (void) HandleRobotAnswerCall: (EventData) eventData{
    AcmCall *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    if(call == nil && call.role != Subscriber)
    {
        // todo callback return error
        return;
    }
    
    call.callback = eventData.param5;
    
    // 请求后台机器人应答
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, RobotAnserApi];
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.timeoutInterval = 5.0;
    
    request.HTTPMethod = @"POST";
    
    NSString *bodyString = [NSString stringWithFormat:@"uid=%@&channel=%@",call.selfId,call.channelId]; //带一个参数key传给服务器
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    //NSLog(@"response code:%@d", [(NSHTTPURLResponse *)response statusCode]);
    if([(NSHTTPURLResponse *)response statusCode] == 200){
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        
        BOOL ret = dic[@"success"];
        
        NSLog(@"Response:%@", dic);
        
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
    }] resume];
}

- (void) HandleRejectCall: (EventData) eventData{
    
    /*
    AcmCall *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    if(call != nil){
        [RunTimeMsgManager rejectPhoneCall:call.callerId userAccount:call.selfId channelID:call.channelId];
    }
    
    [self quitIncomeDialingPhoneCall:call];
    
    if(call != nil && call.callback != nil)
    {
        
        [call.callback didPhoneDialResult:AcmSelfCancelDial];
    }
     */
    
    
    /*
    AcmCall *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    
    // step 1 进入事件频道
    BOOL joinEventChannelRet = [call joinEventSyncChannel:^(AgoraRtmJoinChannelErrorCode errorCode) {
        if(AgoraRtmJoinChannelErrorOk == errorCode){
            // step 2 广播拒接消息
            [call broadcastRejectDial];
        }
        else{
            NSLog(@"ACM Err: failed to join event channel:%ld", (long)errorCode);
            
        }
        [self quitIncomeDialingPhoneCall:call];
        if(call != nil && call.callback != nil)
        {
            
            [call.callback didPhoneDialResult:AcmSelfCancelDial];
        }
    }];
    
    if(joinEventChannelRet == NO){
        [self quitIncomeDialingPhoneCall:call];
        if(call != nil && call.callback != nil)
        {
            
            [call.callback didPhoneDialResult:AcmDialErrorJoinEventSyncChannel];
        }
    }
    */
    
    AcmCall *call = [[ActionManager instance].callMgr getCall:eventData.param4];    
    [call broadcastRejectDial];
    
    [self quitIncomeDialingPhoneCall:call];
    if(call != nil && call.callback != nil)
    {
        
        [call.callback didPhoneDialResult:AcmSelfCancelDial];
    }
    
}

// 跳转回Monitor Action
- (void) JumpBackToMonitorAction{
    // 跳转到Monitor 状态
    MonitorAction * monitorAction = [[MonitorAction alloc]init:[ActionManager instance]];
    
    [[ActionManager instance] actionChange:self destAction:monitorAction];
    
}

- (void) quitIncomeDialingPhoneCall: (AcmCall *) call {
    
    if(call != nil && call.stage == Dialing){
        [call updateStage:Finished];
        if(call.channelId != nil)
        {
            [RtcManager endAudioCall];
            
            NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, EndCallApi];
            NSString *param = [NSString stringWithFormat:@"uid=%@&channel=%@", call.selfId, call.channelId]; //带一个参数key传给服务器
            
            [HttpUtil HttpPost:stringUrl Param:param Callback:nil];
        }

        [self JumpBackToMonitorAction];
    }
}

@end
