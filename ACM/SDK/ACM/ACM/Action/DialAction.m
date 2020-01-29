//
//  DialAction.m
//  ACM
//
//  Created by David on 2020/1/8.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Foundation/Foundation.h>
#import "DialAction.h"
#import "../Message/RunTimeMsgManager.h"
#import "ActionManager.h"
#import "IACMCallBack.h"
#import "../RTC/AudioCallManager.h"
#import "MonitorAction.h"
#import "OnPhoneAction.h"
#import "../Message/HttpUtil.h"

static NSString *DialApi = @"/dapi/call/user";
static NSString *DialRobot = @"/dapi/call/robot";


@interface DialAction()

@property ActionManager* actionMgr;
@property NSString* userId;
@property NSString* channelId;
@property NSString* rtcToken;
@property BOOL robotMode;
@property Call *curCall;
@end

@implementation DialAction

-(id _Nullable )init: (nonnull ActionManager *) mgr userAcount:(nonnull NSString *)userId{
    if (self = [super init]) {
        
        self.type = ActionDial;
        self.actionMgr = mgr;
        self.userId = userId;        
    }
    return self;
}

- (void) HandleEvent: (EventData) eventData{
    if(eventData.type == EventDial)
    {
        
        [self HanleDialWorkFlow:eventData];
    }
    else if(eventData.type == EventDialRobotDemo)
    {
        [self RequestRobotCall];
    }
    
    else if(eventData.type == EventLeaveCall)
    {
        [self leaveCall:eventData];
    }
    
    else if(eventData.type == EventRtmRejectAudioCall)
    {
        [self HandleRemoteRejectcall:eventData];
    }
    
    else if(eventData.type == EventRtmLeaveCall)
    {
        [self remoteLeaveCall:eventData];
    }
     
    else if(eventData.type == EventRtmDialFailed)
    {
        // todo 拨号RTM 拨号问题
    }
    else if(eventData.type == EventSelfInChannelSucceed)
    {
        // 拨号成功，有检测channel 中是否有人事件（EventDidJoinedOfUid）回调
    }
    else if(eventData.type == EventDidJoinedOfUid)
    {
        [self HandleEventDidJoinedOfUid:eventData];
    }

    else if(eventData.type == EventDidRtcOccurError)
    {
        [self handleRtcError:eventData];
    }
    else if(eventData.type == EventRtmAgreeAudioCall)
    {
        [self prepareOnPhoneCall:eventData];
    }
    else if(eventData.type == EventRTMRobotAnser)
    {
         [self prepareOnPhoneCall:eventData];
    }
    else if(eventData.type == EventDialingTimeout)
    {
        [self handleDialingTimeout:eventData];
    }
    else
    {
        [super HandleEvent:eventData];
    }
}

// 拨号过程中遇到问题结束拨号，并通知远端
- (void) handleRtcError: (EventData) eventData{
    Call *call = [[ActionManager instance].callMgr getActiveCall];
    
    [self quitDialingPhoneCall:call EndCode:AcmDialErrorJoinChannel];
    
    if(call != nil && call.callback != nil)
    {
        [call.callback didOccurError:eventData.param1];
    }
}

- (void) handleDialingTimeout: (EventData) eventData{
    Call *call = eventData.param4;
    
    /*
    if(call != nil && call.stage == Dialing)
    {
        [call updateStage:Finished];
        [self JumpBackToMonitorAction];
        if(call.callback != nil)
        {
            dispatch_async(dispatch_get_main_queue(),^{
            [call.callback didPhoneDialResult:AcmDialingTimeout];
            });
        }
        
    }
     */
    [self quitDialingPhoneCall:call EndCode:AcmDialingTimeout];
}

- (void) prepareOnPhoneCall: (EventData) eventData{
    Call *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    if(call != nil && call.role == Originator && call.stage == Dialing)
    {       
        [call updateStage:PrepareOnphone];
        if(call.callback)
        {
            [call.callback didPhoneDialResult:AcmPrepareOnphoneStage];
        }
        [AudioCallManager startAudioCall:call.appId user:call.selfId channel:call.channelId   rtcToken:call.token callInstance:call];
    }
}

- (void) HandleEventDidJoinedOfUid: (EventData) eventData{
    if(self.curCall != nil && self.curCall.callback != nil)
    {
        [self.curCall updateOnlineMember:eventData.param4 Online:YES];
        [self.curCall.callback didPhoneDialResult:AcmDialSucced];
    }
    
    [self.curCall updateStage:OnPhone];
    // 跳转到OnPhoneAction
    OnPhoneAction * action = [[OnPhoneAction alloc]init];
    
    [self.actionMgr actionChange:self destAction:action];
    
    EventData nextEvent = {EventOnPhoneCallFromDial,0,0,0,self.curCall};
    [self.actionMgr HandleEvent:nextEvent];
    
}

- (void) HanleDialWorkFlow: (EventData) eventData{
    [self RequestPhoneCallInfo:eventData];
}

- (void) RequestPhoneCallInfo:(EventData) eventData{
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",self.actionMgr.host, DialApi];
    NSString *bodyString = [NSString stringWithFormat:@"src_uid=%@&dst_uid=%@", [ActionManager instance].userId,eventData.param4]; //带一个参数key传给服务器
    
    [HttpUtil HttpPost:stringUrl Param:bodyString Callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            BOOL ret = dic[@"success"];
            
            if(ret == YES)
            {
                NSDictionary *data = dic[@"data"];
                if(data != nil && data[@"channel"] != nil && data[@"token"] != nil)
                {
                    Call *instance = [self.actionMgr.callMgr updateDialCall:data selfUid:self.actionMgr.userId remoteUser:eventData.param4 ircmCallback:eventData.param5 preInstance:eventData.param6];
                    
                    
                    
                    [RunTimeMsgManager invitePhoneCall:instance];
                    
                    //[AudioCallManager startAudioCall:instance.appId user:instance.selfId channel:instance.channelId   rtcToken:instance.token callInstance:instance];
                    
                    self.curCall = instance;
                    
                    dispatch_async(dispatch_get_main_queue(),^{
                        [instance.callback didPhoneDialResult:AcmDialRequestSendSucceed];
                    });
                    
                }
                else
                {
                    // 通知错误发生
                    id <IRTCCallBack> delegate = eventData.param5;
                    dispatch_async(dispatch_get_main_queue(),^{
                        [delegate didPhoneDialResult: AcmDialErrorWrongApplyCallResponse];
                    });
                    
                    
                    // 跳转到Monitor 状态
                    [self JumpBackToMonitorAction];
                }
            }
            else
            {
                // 通知错误发生
                id <IRTCCallBack> delegate = eventData.param5;
                dispatch_async(dispatch_get_main_queue(),^{
                    [delegate didPhoneDialResult: AcmDialErrorWrongApplyCallResponse];
                });
                
                
                // 跳转到Monitor 状态
                [self JumpBackToMonitorAction];
                
            }
        }
        else{
            // 通知错误发生
            id <IRTCCallBack> delegate = eventData.param5;
            
            dispatch_async(dispatch_get_main_queue(),^{
                [delegate didPhoneDialResult: AcmDialErrorApplyCall];
            });
            
            // 跳转到Monitor 状态
            [self JumpBackToMonitorAction];
        }
    }];
    
    /*
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",self.actionMgr.host, DialApi];
    NSString *bodyString = [NSString stringWithFormat:@"src_uid=%@&dst_uid=%@", [ActionManager instance].userId,eventData.param4]; //带一个参数key传给服务器
    
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.timeoutInterval = 5.0;
    
    request.HTTPMethod = @"POST";
    
    
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger code = [(NSHTTPURLResponse *)response statusCode];
        NSLog(@"response code:%ldd", (long)code);
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            BOOL ret = dic[@"success"];
           
            
            if(ret == YES)
            {
                NSDictionary *data = dic[@"data"];
                if(data != nil && data[@"channel"] != nil && data[@"token"] != nil)
                {
                    Call *instance = [self.actionMgr.callMgr updateDialCall:data selfUid:self.actionMgr.userId remoteUser:eventData.param4 ircmCallback:eventData.param5 preInstance:eventData.param6];
                    
                    
                    
                    [RunTimeMsgManager invitePhoneCall:instance];
                    
                    //[AudioCallManager startAudioCall:instance.appId user:instance.selfId channel:instance.channelId   rtcToken:instance.token callInstance:instance];
                    
                    self.curCall = instance;
                    
                    dispatch_async(dispatch_get_main_queue(),^{
                        [instance.callback didPhoneDialResult:AcmDialRequestSendSucceed];
                    });
                    
                }
                else
                {
                    // 通知错误发生
                    id <IRTCCallBack> delegate = eventData.param5;
                    dispatch_async(dispatch_get_main_queue(),^{
                        [delegate didPhoneDialResult: AcmDialErrorWrongApplyCallResponse];
                    });
                    
                    
                    // 跳转到Monitor 状态
                    [self JumpBackToMonitorAction];
                }
            }
            else
            {
                // 通知错误发生
                id <IRTCCallBack> delegate = eventData.param5;
                dispatch_async(dispatch_get_main_queue(),^{
                    [delegate didPhoneDialResult: AcmDialErrorWrongApplyCallResponse];
                });
                
                
                // 跳转到Monitor 状态
                [self JumpBackToMonitorAction];
                
            }
        }
        else{
            // 通知错误发生
            id <IRTCCallBack> delegate = eventData.param5;
            
            dispatch_async(dispatch_get_main_queue(),^{
                [delegate didPhoneDialResult: AcmDialErrorApplyCall];
            });
            
            // 跳转到Monitor 状态
            [self JumpBackToMonitorAction];
        }
    }] resume];
     */
}

// 跳转回Monitor Action
- (void) JumpBackToMonitorAction{
    // 跳转到Monitor 状态
    MonitorAction * monitorAction = [[MonitorAction alloc]init:self.actionMgr];
    
    [self.actionMgr actionChange:self destAction:monitorAction];
    
    
}

- (void) RequestRobotCall{
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",self.actionMgr.host, DialRobot];
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.timeoutInterval = 5.0;
    
    request.HTTPMethod = @"POST";
    
    NSString *bodyString = [NSString stringWithFormat:@"src_uid=%@", self.userId]; //带一个参数key传给服务器
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            BOOL ret = dic[@"success"];
            
            
            if(ret == YES)
            {
                NSDictionary *data = dic[@"data"];
                if(data != nil && data[@"channel"] != nil && data[@"token"] != nil)
                {
                    self.channelId = data[@"channel"];
                    self.rtcToken = data[@"token"];
            
                    
                    NSLog(@"Join to Robot channel:%@", self.channelId);
                    
                    [AudioCallManager startAudioCall:data[@"appID"] user:self.userId channel:self.channelId   rtcToken:data[@"token"] callInstance:nil];
                    
                }
                else
                {
                    // deal with err
                    NSLog(@"ACM incorrect robot param");
                    
                }
            }
            else
            {
                self.userId = nil;
                
                // todo deal with failed
                 NSLog(@"ACM incorrect robot request response");
            }
            
            
            
        }
        else{
            // todo deal with failed
            NSLog(@"ACM robot request error. state:%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        }
    }] resume];
}
// 以后更新为Cancel call
- (void) leaveCall: (EventData) eventData{
    Call * call = eventData.param4;
    /*
    if(call.role == Originator)
    {
        //+ (void) leaveCall: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID{
        if(call.channelId != nil)
        {
            [RunTimeMsgManager leaveCall:call.subscriberList[0]  userAccount:self.actionMgr.userId  channelID:call.channelId];
            [AudioCallManager endAudioCall];
            [call updateStage:Finished];
        }
        [self JumpBackToMonitorAction];
    }
     */
    
    [self quitDialingPhoneCall:call EndCode:AcmSelfCancelDial];
    
}
 

- (void) HandleRemoteRejectcall: (EventData) eventData{

    
    Call *call = [self.actionMgr.callMgr getCall:eventData.param4];
    
    
    /*
    if(call != nil && call.callback != nil)
    {
        [call.callback didPhoneDialResult:AcmDialRemoteReject];
        [call updateStage:Finished];
    }
    
    
    // 跳转到Monitor 状态
    [self JumpBackToMonitorAction];
    */
    
    [self quitDialingPhoneCall:call EndCode:AcmDialRemoteReject];
}

// change to cancel call
- (void) remoteLeaveCall: (EventData) eventData{
    Call *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    
    /*
    if(call != nil)
    {
        [call updateStage:Finished];
        if(call.callback != nil)
        {
            [call.callback didPhoneCallResult:AcmPhoneCallCodeRemoteEnd];
        }
        [self JumpBackToMonitorAction];
    }
     */
    [self quitDialingPhoneCall:call EndCode:AcmDialRemoteReject];
}
 

- (void) handleEventDidRTCJoinChannel: (EventData) eventData{
    Call *call = [self.actionMgr.callMgr getCall:eventData.param4];
    if(call != nil && call.callback != nil)
    {
        [call.callback didPhoneDialResult:AcmDialSucced];
        [call updateStage:OnPhone];
        
        // todo 跳转到onphone action
    }
    
}
    
- (void) quitDialingPhoneCall: (Call *) call EndCode:(AcmDialCode) code{
    
    if(call != nil && ( call.stage == Dialing || call.stage == PrepareOnphone )){
        [call updateStage:Finished];
        if(call.channelId != nil)
        {
            [AudioCallManager endAudioCall];
            [RunTimeMsgManager leaveCall:call.subscriberList[0]  userAccount:self.actionMgr.userId  channelID:call.channelId];
            
            NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, EndCallApi];
            NSString *param = [NSString stringWithFormat:@"uid=%@&channel=%@", call.selfId, call.channelId]; //带一个参数key传给服务器
            
            [HttpUtil HttpPost:stringUrl Param:param Callback:nil];
        }
        if(call.callback != nil)
        {
            [call.callback didPhoneDialResult:code];
        }
        [self JumpBackToMonitorAction];
        

    }
}

@end
