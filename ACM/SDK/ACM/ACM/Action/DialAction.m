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
#import "../RTC/RtcManager.h"
#import "MonitorAction.h"
#import "OnPhoneAction.h"
#import "../Message/HttpUtil.h"
#import "../Call/CallEventEnum.h"


static NSString *DialRobot = @"/dapi/call/robot";

#import "../Log/AcmLog.h"
#define DialTag  @"Dial"


@interface DialAction()

@property ActionManager* actionMgr;
@property NSString* userId;
@property NSString* channelId;
@property NSString* rtcToken;
@property BOOL robotMode;
@property AcmCall *curCall;
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
    
    DebugLog(DialTag,@"HandleEvent:%ld",(long)eventData.type);
    
    if(eventData.type == EventAudioDial)
    {
        [self RequestPhoneCallInfo:eventData];    // audio call step 1 向后台申请拨号
    }
    else if(eventData.type == EventVideoDial)
    {
        [self RequestPhoneCallInfo:eventData];    // video call step 1 向后台申请拨号
    }
    else if(eventData.type == EventBackendRequestDialSucceed)  // step 2 创建消息同步通道
    {
        [self JoinSyncChannel:eventData];
    }
    else if(eventData.type == EventJoinEventSyncChannelSucceed) // step 3 向用户列表发送通话消息
    {
        [self DispatchPhoneCallRequest:eventData];
    }
    else if(eventData.type == EventRtmAgreeAudioCall)       // step 4 接听方用户同意接听电话
    {
        [self prepareOnPhoneCall:eventData];
    }
    else if(eventData.type == EventRTMRobotAnswer)         //  step 5 接听方用户使用助手接听电话
    {
        [self prepareOnPhoneCall:eventData];
    }
    /*
    else if(eventData.type == EventDidJoinedOfUid)       // step 6 第一个用户进入通话通道
    {
        [self HandleEventDidJoinedOfUid:eventData];
    }
     */
    else if(eventData.type == EventDialRobotDemo)
    {
        [self RequestRobotCall];
    }
    
    else if(eventData.type == EventLeaveCall)
    {
        [self cancelDial:eventData];
    }
    
    else if(eventData.type == EventRtmRejectAudioCall)
    {
        [self HandleRemoteRejectcall:eventData];
    }
    /*
    else if(eventData.type == EventRtmLeaveCall)
    {
        [self remoteLeaveCall:eventData];
    }
     */
     
    else if(eventData.type == EventRtmDialFailed)
    {
        // todo 拨号RTM 拨号问题
    }
    else if(eventData.type == EventSelfInChannelSucceed)
    {
        // 拨号成功，有检测channel 中是否有人事件（EventDidJoinedOfUid）回调
    }


    else if(eventData.type == EventDidRtcOccurError)
    {
        [self handleRtcError:eventData];
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
    AcmCall *call = [[ActionManager instance].callMgr getActiveCall];
    
    [self quitDialingPhoneCall:call EndCode:AcmDialErrorJoinChannel EventCode:CallEventCallFailed_EndCall NeedSendNotification:YES];
    
    if(call != nil && call.callback != nil)
    {
        [call.callback didOccurError:eventData.param1];
    }
}

- (void) handleDialingTimeout: (EventData) eventData{
    AcmCall *call = eventData.param4;
    
    [self quitDialingPhoneCall:call EndCode:AcmDialingTimeout  EventCode:CallEventNoResponse_EndCall NeedSendNotification:NO];
}

- (void) prepareOnPhoneCall: (EventData) eventData{
    AcmCall *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    if(call != nil && call.role == Originator && call.stage == Dialing)
    {
        [call updateStage:PrepareOnphone];
        if(call.callback)
        {
            [call.callback didPhoneDialResult:AcmPrepareOnphoneStage];
        }
        if(call.callType == AudioCall){
            [RtcManager startAudioCall:call.appId user:call.selfId channel:call.channelId   rtcToken:call.token callInstance:call];
        }
        else if(call.callType == VideoCall){
            [RtcManager startVideoCall:call.appId callInstance:call];
        }
        
        [call updateStage:OnPhone];
        
        [self NoticeBackendEnterCall:call];
        
        if(call.callback)
        {
            [call.callback didPhoneDialResult:AcmDialSucced];
        }
        
        // 跳转到OnPhoneAction
        OnPhoneAction * action = [[OnPhoneAction alloc]init];
        
        [self.actionMgr actionChange:self destAction:action];
        
        EventData nextEvent = {EventOnPhoneCallFromDial,0,0,0,self.curCall};
        [self.actionMgr HandleEvent:nextEvent];
    }
}

- (void) NoticeBackendEnterCall: (AcmCall *) call{
    // 通知后台拨号方已进入通话
    /*
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, CallerEnterApi];
    NSString *param =  [NSString stringWithFormat:@"uid=%@&channel=%@",call.selfId,call.channelId];
    */
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, CallEventAPI];
    NSString *param = [NSString stringWithFormat:@"uid=%@&channel=%@&code=%ld", call.selfId, call.channelId,(long)CallEventStartCall]; 
    
    [HttpUtil HttpPost:stringUrl Param:param Callback:nil];
}

/*
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
 */

- (void) JoinSyncChannel: (EventData ) eventData{
    AcmCall *call = eventData.param4;
    
    /*
    BOOL joinEventChannelRet = [call joinEventSyncChannel:^(AgoraRtmJoinChannelErrorCode errorCode) {
        if(AgoraRtmJoinChannelErrorOk == errorCode){
            EventData nextEvent = {EventJoinEventSyncChannelSucceed,0,0,0,call};
            [[ActionManager instance] HandleEvent:nextEvent];
        }
        else{
            NSLog(@"ACM Err: failed to join event channel:%ld", (long)errorCode);
            [self quitDialingPhoneCall:call EndCode:AcmDialErrorJoinEventSyncChannel NeedSendNotification:YES];
        }
    }];
    
    if(joinEventChannelRet == NO){
        [self quitDialingPhoneCall:call EndCode:AcmDialErrorJoinEventSyncChannel NeedSendNotification:YES];
    }
     */
    if(call.callType == AudioCall){
        [self JoinAudioChannel:call];
    }else if(call.callType == VideoCall)
    {
        [self JoinVideoChannel:call];
    }
}

- (void) JoinAudioChannel: (AcmCall *) call{
    BOOL joinEventChannelRet = [call joinEventSyncChannel:^(AgoraRtmJoinChannelErrorCode errorCode) {
        if(AgoraRtmJoinChannelErrorOk == errorCode){
            EventData nextEvent = {EventJoinEventSyncChannelSucceed,0,0,0,call};
            [[ActionManager instance] HandleEvent:nextEvent];
        }
        else{
            ErrLog(DialTag,@"Err: failed to join audio call event channel:%ld", (long)errorCode);
            [self quitDialingPhoneCall:call EndCode:AcmDialErrorJoinEventSyncChannel EventCode:CallEventCallFailed_EndCall NeedSendNotification:YES];
        }
    }];
    
    if(joinEventChannelRet == NO){
        [self quitDialingPhoneCall:call EndCode:AcmDialErrorJoinEventSyncChannel EventCode:CallEventCallFailed_EndCall NeedSendNotification:YES];
    }
}

- (void) JoinVideoChannel: (AcmCall *) call {
    
    BOOL joinEventChannelRet = [call joinEventSyncChannel:^(AgoraRtmJoinChannelErrorCode errorCode) {
        if(AgoraRtmJoinChannelErrorOk == errorCode){
            EventData nextEvent = {EventJoinEventSyncChannelSucceed,0,0,0,call};
            [[ActionManager instance] HandleEvent:nextEvent];
        }
        else{
            ErrLog(DialTag,@"Err: failed to join video call event channel:%ld", (long)errorCode);
            [self quitDialingPhoneCall:call EndCode:AcmDialErrorJoinEventSyncChannel EventCode:CallEventCallFailed_EndCall NeedSendNotification:YES];
        }
    }];
    
    if(joinEventChannelRet == NO){
        [self quitDialingPhoneCall:call EndCode:AcmDialErrorJoinEventSyncChannel EventCode:CallEventCallFailed_EndCall NeedSendNotification:YES];
    }
}

- (void) DispatchPhoneCallRequest: (EventData ) eventData{
    AcmCall *call = eventData.param4;
    
    
    // 发送消息后，等待第一个握手回复后进入通话频道
    [RunTimeMsgManager invitePhoneCall:call];

    self.curCall = call;

    dispatch_async(dispatch_get_main_queue(),^{
    [call.callback didPhoneDialResult:AcmDialRequestSendSucceed];
});
    
    // 拨号事件上传
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, CallEventAPI];
    NSString *param = [NSString stringWithFormat:@"uid=%@&channel=%@&code=%ld", call.selfId, call.channelId,(long)CallEventCallerDial];
    [HttpUtil HttpPost:stringUrl Param:param Callback:nil];
}

- (void) RequestPhoneCallInfo:(EventData) eventData{
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",self.actionMgr.host, DialApi];
    AcmCall *call = eventData.param6;
    
    NSMutableDictionary *extra_info = [[NSMutableDictionary alloc] initWithObjects:@[[ActionManager instance].userId, [NSNumber numberWithInteger:call.callType], call.subscriberList] forKeys:@[@"CallerId", @"Type", @"Subscribers"]];
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:extra_info options:0 error:&err];
    
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSNumber *groupId = [NSNumber numberWithInt:eventData.param1];
    
    NSDictionary * phoneCallParam =
    @{@"src_uid": [ActionManager instance].userId,
      @"dst_uid": call.subscriberList,
      @"call_group":groupId,
      @"extra_msg": jsonString,
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
            
            if(ret == YES)
            {
                NSDictionary *data = dic[@"data"];
                if(data != nil && data[@"channel"] != nil && data[@"token"] != nil)
                {
                    AcmCall *instance = [self.actionMgr.callMgr updateDialCall:data selfUid:self.actionMgr.userId ircmCallback:eventData.param5 preInstance:eventData.param6];
                    
                    EventData eventData = {EventBackendRequestDialSucceed,0,0,0,instance};
                    dispatch_async(dispatch_get_main_queue(),^{
                        [[ActionManager instance] HandleEvent:eventData];
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
            
                    
                    DebugLog(DialTag,@"Join to Robot channel:%@", self.channelId);
                    
                    [RtcManager startAudioCall:data[@"appID"] user:self.userId channel:self.channelId   rtcToken:data[@"token"] callInstance:nil];
                    
                }
                else
                {
                    // deal with err
                    ErrLog(DialTag,@"ACM incorrect robot param");
                    
                }
            }
            else
            {
                self.userId = nil;
                
                // todo deal with failed
                 ErrLog(DialTag,@"ACM incorrect robot request response");
            }
            
            
            
        }
        else{
            // todo deal with failed
            ErrLog(DialTag,@"ACM robot request error. state:%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        }
    }] resume];
}
- (void) cancelDial: (EventData) eventData{
    AcmCall * call = eventData.param4;
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
    
    [self quitDialingPhoneCall:call EndCode:AcmSelfCancelDial EventCode:CallEventSelfCancel_EndCall NeedSendNotification:YES];
    
}
 

- (void) HandleRemoteRejectcall: (EventData) eventData{

    
    AcmCall *call = [self.actionMgr.callMgr getCall:eventData.param4];
    
    
    /*
    if(call != nil && call.callback != nil)
    {
        [call.callback didPhoneDialResult:AcmDialRemoteReject];
        [call updateStage:Finished];
    }
    
    
    // 跳转到Monitor 状态
    [self JumpBackToMonitorAction];
    */
    
    // 所有人通话对象挂断来电结束通话
    if(call.rejectDialSubscriberList.count == call.subscriberList.count){
        [self quitDialingPhoneCall:call EndCode:AcmDialRemoteReject EventCode:CallEventSubsriberRejected_EndCall NeedSendNotification:NO];
    }
}

// 远端退出通话在onphone 中处理
/*
- (void) remoteLeaveCall: (EventData) eventData{
    AcmCall *call = [[ActionManager instance].callMgr getCall:eventData.param4];
 
    [self quitDialingPhoneCall:call EndCode:AcmDialRemoteReject NeedSendNotification:YES];
}
*/
 

- (void) handleEventDidRTCJoinChannel: (EventData) eventData{
    AcmCall *call = [self.actionMgr.callMgr getCall:eventData.param4];
    if(call != nil && call.callback != nil)
    {
        [call.callback didPhoneDialResult:AcmDialSucced];
        [call updateStage:OnPhone];
        
        // todo 跳转到onphone action
    }
    
}
    
- (void) quitDialingPhoneCall: (AcmCall *) call EndCode:(AcmDialCode) code  EventCode:(CallEventCode) eventCode NeedSendNotification:(BOOL) isNeedSendNotification{
    
    DebugLog(DialTag,@"quitDialingPhoneCall");
    
    if(call != nil && ( call.stage == Dialing || call.stage == PrepareOnphone )){
        [call updateStage:Finished];
        if(call.channelId != nil)
        {
            [RtcManager endAudioCall];
            
            
            // 拨号间断退出时，发送p2p 消息取消电话
            if(isNeedSendNotification)
            {
                [RunTimeMsgManager dispatchEndDial:call.subscriberList  userAccount:self.actionMgr.userId  channelID:call.channelId];
            }
           
            
            NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, CallEventAPI];
            NSString *param = [NSString stringWithFormat:@"uid=%@&channel=%@&code=%ld&desp=%ld", call.selfId, call.channelId,(long)eventCode,(long)code]; //带一个参数key传给服务器
            
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
