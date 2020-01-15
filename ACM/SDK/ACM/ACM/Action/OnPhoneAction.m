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
@property Call *curCall;
@property NSTimer *timer;
@end

@implementation OnPhoneAction

static BOOL turn = NO;

-(id _Nullable )init{
    if (self = [super init]) {
        self.type = ActionOnPhone;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
           // [self CreateSubtitle];
        }];
    }
    return self;
}

-(void)dealloc{
    [self.timer invalidate];
}

- (void) CreateSubtitle{
    /*
    if(_curCall != nil)
    {
        NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval timestamp=[dat timeIntervalSince1970];
        
       
        if(turn)
        {
            [_curCall.callback onSubTitleReceived:@"这是来自于拨号方的通话内容" userId:_curCall.callerId timeStamp:timestamp];
        }
        else
        {
            [_curCall.callback onSubTitleReceived:@"接听方的内容是这样的..." userId:_curCall.subscriberList[0] timeStamp:timestamp];
        }
        
        turn = !turn;
    }
     */
}


- (void) HandleEvent: (EventData) eventData
{
    if(eventData.type == EventBackendAgreeAudioCall)
    {
        [self JoinAudioCall:eventData];
    }
    else if(eventData.type == EventLeaveCall)
    {
        [self.timer invalidate];
        [self leaveCall:eventData];
    }
    else if(eventData.type == EventRtmLeaveCall)
    {
        [self.timer invalidate];
        [self remoteLeaveCall:eventData];
    }
    else if(eventData.type == EventRobotAnsweredCall)
    {
        [self HandleRobotAnsweredCall:eventData];
    }
    else if(eventData.type == EventOnPhoneCallFromDial)
    {
        self.curCall = eventData.param4;
    }
    else if(eventData.type == EventASRFinalResult)
    {
        [self handleAsrFinalResult:eventData];
    }
    else if(eventData.type == EventASRRealTimeResult)
    {
        [self handleAsrRealTimeResult:eventData];
    }
    else if(eventData.type == EventRemoeAsrResult)
    {
        [self handleRemoteAsrResult:eventData];
    }
}

- (void) handleRemoteAsrResult: (EventData) eventData{
    if(_curCall != nil)
    {
        NSDictionary *msgDic = eventData.param4;
        BOOL isFinished = [msgDic[@"isFinished"] isEqualToString:@"true"] ? TRUE: FALSE;
        NSNumber *astTimestamp = msgDic[@"timeStamp"];
        NSNumber *msgTimestamp = msgDic[@"msgTimeStamp"];
        
        [_curCall.callback onRemoteText:msgDic[@"asrData"] remoteAccount:msgDic[@"accountSender"] timeStamp:astTimestamp.doubleValue msgStamp:msgTimestamp.doubleValue isFinished:isFinished];
    }
}

- (void) handleAsrRealTimeResult: (EventData) eventData{
    if(_curCall != nil)
    {
        [_curCall.callback onLocalText:eventData.param4  timeStamp:eventData.param3 isFinished:NO];
        //+ (void)syncAsrData: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID asrData(nonnull NSString *)text timeStamp:(NSTimeInterval)startTime isFinished:(BOOL) finished{
        NSString *remoteUid = nil;
        // todo 多人时小时过于频繁，会有问题
        if(_curCall.role == Originator)
        {
            remoteUid = _curCall.subscriberList[0];
        }
        else{
            remoteUid = _curCall.callerId;
        }
        
        [RunTimeMsgManager syncAsrData:remoteUid userAccount:_curCall.selfId channelID:_curCall.channelId asrData:eventData.param4 timeStamp:eventData.param3 isFinished:NO];
        
       
    }
}

- (void) handleAsrFinalResult: (EventData) eventData{
    if(_curCall != nil)
    {
        [_curCall.callback onLocalText:eventData.param4  timeStamp:eventData.param3 isFinished:YES];
        
        NSString *remoteUid = nil;
        // todo 多人时小时过于频繁，会有问题
        if(_curCall.role == Originator)
        {
            remoteUid = _curCall.subscriberList[0];
        }
        else{
            remoteUid = _curCall.callerId;
        }
        
        [RunTimeMsgManager syncAsrData:remoteUid userAccount:_curCall.selfId channelID:_curCall.channelId asrData:eventData.param4 timeStamp:eventData.param3 isFinished:YES];
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
    self.curCall = call;
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
    self.curCall = call;

        [AudioCallManager startAudioCall:call.appId user:call.selfId channel:call.channelId rtcToken:call.token callInstance:call];
    
    [AudioCallManager muteLocalAudioStream:true];
    [AudioCallManager muteAllRemoteAudioStreams:true];
    call.localMuteState = true;
    call.remoteMuteState = true;
        
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
