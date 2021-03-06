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
#import "../RTC/RtcManager.h"
#import "../Message/RunTimeMsgManager.h"
#import "../Message/HttpUtil.h"
#import "../Call/CallEventEnum.h"

#import "../Log/AcmLog.h"
#define OnPhoneTag  @"OnPhone"


// 电话响铃Action
@interface OnPhoneAction ()
@property AcmCall *curCall;
@end

@implementation OnPhoneAction

-(id _Nullable )init{
    if (self = [super init]) {
        self.type = ActionOnPhone;
    }
    return self;
}

-(void)dealloc{
}


- (void) HandleEvent: (EventData) eventData
{
    DebugLog(OnPhoneTag,@"HandleEvent:%ld",(long)eventData.type);
    if(eventData.type == EventBackendAgreeAudioCall)
    {
        [self JoinToChannelCall:eventData];
    }
    else if(eventData.type == EventLeaveCall)
    {
        [self leaveCall:eventData];
    }
    else if(eventData.type == EventNoMemberEndCall)
    {
        [self handleEventNoMemberEndCall:eventData];
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
    else if(eventData.type == EventRemoteAsrResult)
    {
        [self handleRemoteAsrResult:eventData];
    }
    else if(eventData.type == EventGetAuthority)
    {
        [self handleEventGetAuthority:eventData];
    }
    else if(eventData.type == EventDidRtcOccurError)
    {
        [self handleRtcError:eventData];
    }
    else if(eventData.type == EventRTCUserLeaveChannel)
    {
        [self handleRemoteUserLeaveChannel:eventData];
    }
    else if(eventData.type == EventDidJoinedOfUid)
    {
        [self HandleEventDidJoinedOfUid:eventData];
    }
    else if(eventData.type == EventFirstRemoteVideoDecodedOfUid){
        [self HandleFirstRemoteVideoDecoded:eventData];
    }
    else
    {
        [super HandleEvent:eventData];
    }
}

- (void) HandleFirstRemoteVideoDecoded: (EventData) eventData{
    //firstRemoteVideoDecodedOfUid
    AcmCall *call = [[ActionManager instance].callMgr getActiveCall];
    if(call != nil  && call.stage == OnPhone && call.callback != nil)
    {
        NSNumber *widthNum = eventData.param5;
        NSNumber *heightNum = eventData.param6;
        
        CGSize size  ={[widthNum floatValue],[heightNum floatValue]};
        
        AgoraRtcVideoCanvas *canvas = [call.callback firstRemoteVideoDecodedOfUid:eventData.param4 size:size elapsed:eventData.param2];
        canvas.uid = eventData.param1;
        
        if(canvas != nil){
            [RtcManager setupRemoteVideo:canvas];            
        }
    }
}

- (void) HandleEventDidJoinedOfUid: (EventData) eventData{
    AcmCall *call = [[ActionManager instance].callMgr getActiveCall];
    
    if(call != nil  && call.stage == OnPhone)
    {
        [call updateOnlineMember:eventData.param4 Online:YES];
    }
    if( call.callback != nil ){
        [call.callback onlineMemberUpdated:[call getOnlineMembers]];
    }
}

- (void) handleRemoteUserLeaveChannel: (EventData) eventData{
    AcmCall *call = [[ActionManager instance].callMgr getActiveCall];
    
    if(call != nil  && call.stage == OnPhone)
    {
        [call updateOnlineMember:eventData.param4 Online:NO];
        
        if( call.callback != nil ){
            [call.callback onlineMemberUpdated:[call getOnlineMembers]];
        }
        
        // 人数为0时退出通话，多人通话时由APP处理
        if( call.getOnlineMembers.count == 0 ){
            EventData data = {EventNoMemberEndCall,0,0,0,call};
            [[ActionManager instance] HandleEvent:data];
        }
    }
    
}

// 通话过程中遇到问题结束拨号，通知UI层错误，通话结束由
- (void) handleRtcError: (EventData) eventData{
   
    AcmCall *call = [[ActionManager instance].callMgr getActiveCall];
    
    if(call != nil && call.callback != nil && call.stage == OnPhone)
    {
        [call.callback didOccurError:eventData.param1];
    }
}

- (void) handleRemoteAsrResult: (EventData) eventData{
    if(_curCall != nil)
    {
        NSDictionary *msgDic = eventData.param4;
        BOOL isFinished = [msgDic[@"isFinished"] isEqualToString:@"true"] ? TRUE: FALSE;
        NSNumber *astTimestamp = msgDic[@"timeStamp"];
        NSNumber *msgTimestamp = msgDic[@"msgTimeStamp"];
        NSString *uid = msgDic[@"proxUid"];
        
        if(uid == nil){
            uid = msgDic[@"accountSender"];
        }
        
        
        [_curCall.callback onRemoteText:msgDic[@"asrData"] remoteAccount:uid timeStamp:astTimestamp.doubleValue msgStamp:msgTimestamp.doubleValue isFinished:isFinished];
    }
}

- (void) handleAsrRealTimeResult: (EventData) eventData{
    if(_curCall != nil)
    {
        [_curCall.callback onLocalText:eventData.param4  timeStamp:eventData.param3 isFinished:NO];
        
        NSString *remoteUid = nil;
        // todo 多人时小时过于频繁，会有问题
        if(_curCall.role == Originator)
        {
            remoteUid = _curCall.subscriberList[0];
        }
        else{
            remoteUid = _curCall.callerId;
        }
        
        //[RunTimeMsgManager syncAsrData:remoteUid userAccount:_curCall.selfId channelID:_curCall.channelId asrData:eventData.param4 timeStamp:eventData.param3 isFinished:NO];
        
       [_curCall broadcastAsrData:eventData.param4 timeStamp:eventData.param3 isFinished:NO];
       
    }
}

- (void) reportAsrResult: (EventData) eventData Call:(AcmCall *)call{
    NSDate *startTime=[NSDate dateWithTimeIntervalSince1970:eventData.param3];
    NSDate *stopTime=[NSDate dateWithTimeIntervalSince1970:eventData.param9];
    
    /*
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger interval = [zone secondsFromGMTForDate: startTime];
    //返回以当前NSDate对象为基准，偏移多少秒后得到的新NSDate对象
    startTime = [startTime dateByAddingTimeInterval: interval];
    stopTime = [stopTime dateByAddingTimeInterval: interval];
    */
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, CallEventAPI];
    
    NSDateFormatter*dateFormatter=[[NSDateFormatter alloc]init];
    
    //设置时区
    /*
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0000"];
    [dateFormatter setTimeZone:timeZone];
    */
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDictionary * desp =@{@"content":eventData.param4,
                           @"start": [dateFormatter stringFromDate:startTime],
                           @"end": [dateFormatter stringFromDate:stopTime],
                           };
    
    NSError *error;
    NSData *despData = [NSJSONSerialization dataWithJSONObject:desp options:NSJSONWritingPrettyPrinted error:&error];
    NSString *despStr = [[NSString alloc]initWithData:despData encoding:NSUTF8StringEncoding];
    
    NSDictionary * reportData =
    @{@"uid":call.selfId,
      @"channel": call.channelId,
      @"code":[NSString stringWithFormat:@"%ld",(long)SubTitleEvent],
      @"desp":despStr
      };
    
   
    NSData *data = [NSJSONSerialization dataWithJSONObject:reportData options:NSJSONWritingPrettyPrinted error:&error];
    NSString *param = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    [HttpUtil HttpPost:stringUrl Param:param Callback:nil];
    
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
        
        //[RunTimeMsgManager syncAsrData:remoteUid userAccount:_curCall.selfId channelID:_curCall.channelId asrData:eventData.param4 timeStamp:eventData.param3 isFinished:YES];
        
        [_curCall broadcastAsrData:eventData.param4 timeStamp:eventData.param3 isFinished:YES];
        [self reportAsrResult:eventData Call:_curCall];
    }
    
}


- (void) handleEventNoMemberEndCall: (EventData) eventData{
    
    AcmCall *call = eventData.param4;
    
    
    
    if(call != nil  && call.stage == OnPhone)
    {
       
        if(call.callback != nil)
        {
            [call.callback didPhoneCallResult:AcmPhoneCallCodeRemoteEnd];
        }
        
    }
    
    [self quitOnPhoneCall:call];
     
}

- (void) JoinToChannelCall: (EventData) eventData{

    /*
    AcmCall *call = eventData.param4;
    self.curCall = call;
    if(call != nil)
    {
        
        [RtcManager startAudioCall:call.appId user:call.selfId channel:call.channelId rtcToken:call.token callInstance:call];
        
        [RtcManager muteLocalAudioStream:false];
        
        [call updateStage:OnPhone];
        
    }
     */
     AcmCall *call = eventData.param4;
    
    if(call.callType == AudioCall){
        [self JoinAudioChannel:call];
    }else if(call.callType == VideoCall)
    {
        //[self setupLocalVideo:call];
        [self JoinVideoChannel:call];
    }
}

- (void) JoinAudioChannel: (AcmCall *) call{
    self.curCall = call;
    if(call != nil)
    {
        
        [RtcManager startAudioCall:call.appId user:call.selfId channel:call.channelId rtcToken:call.token callInstance:call];
        
        [RtcManager muteLocalAudioStream:false];
        
        [call updateStage:OnPhone];
        
    }
}

/*
- (void)setupLocalVideo :(AcmCall *) call{
    
    if(call.videoCallParam.localView != nil){
        AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
        videoCanvas.uid = 0;
        // UID = 0 means we let Agora pick a UID for us
        
        videoCanvas.view = call.videoCallParam.localView;
        videoCanvas.renderMode = call.videoCallParam.renderMode;
        
        // Bind local video stream to view
        [RtcManager setupLocalVideo:videoCanvas];
    }
}
 */

- (void) JoinVideoChannel: (AcmCall *) call {
    
    if(call != nil)
    {
        
        [RtcManager startVideoCall:call.appId callInstance:call];
        
        [RtcManager muteLocalAudioStream:false];
        
        [call updateStage:OnPhone];
        
    }
}

- (void) HandleRobotAnsweredCall: (EventData) eventData{
    /*
     [AudioCallManager startAudioCall:eventData.param4 user:eventData.param5 channel:eventData.param6 rtcToken:nil rtcCallback:eventData.param7];
     */
    AcmCall *call = eventData.param4;
    call.role = Observer;
    self.curCall = call;

        [RtcManager startAudioCall:call.appId user:call.selfId channel:call.channelId rtcToken:call.token callInstance:call];
    
    [RtcManager muteLocalAudioStream:true];
    [RtcManager muteAllRemoteAudioStreams:true];
    call.localMuteState = true;
    call.remoteMuteState = true;
        
    [call updateStage:OnPhone];
        
   
}

- (void) leaveCall: (EventData) eventData{
    AcmCall *paramCall = eventData.param4;
    AcmCall *call = nil;
    if(paramCall != nil)
    {
        call =  [[ActionManager instance].callMgr getCall:paramCall.channelId];
    }
    
    if(call != nil && call.stage == OnPhone){
        /*
        if(call.role == Subscriber  || ![call.selfId isEqualToString:call.callerId])
        {
            [RunTimeMsgManager leaveCall:call.callerId userAccount:call.selfId channelID:call.channelId];
        }
        else if(call.role == Originator || [call.selfId isEqualToString:call.callerId])
        {
            // todo 多人列表
            [RunTimeMsgManager leaveCall:call.subscriberList[0] userAccount:call.selfId channelID:call.channelId];
        }
         */
        [call broadcastLeaveCall];
        
        [self quitOnPhoneCall:call];
    }
}

- (void) handleEventGetAuthority: (EventData) eventData{
    
    IRTCAGetAuthorityBlock callback = eventData.param5;
    
    AcmCall *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    if(call != nil)
    {
        if(call.stage != OnPhone && call.role != Observer)
        {
            callback(AcmPhoneCallErrorNoAuthority);
            return;
        }
        
        [self requestAuthority:call completion:callback];
        
    }
    else if( callback != nil )
    {
        callback(AcmPhoneCallErrorNoAuthority);
    }
}

- (void) requestAuthority: (nonnull AcmCall *)call completion:(IRTCAGetAuthorityBlock _Nullable)completionBlock
{
   NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, AuthorityApi];
    NSString *param = [NSString stringWithFormat:@"channel=%@&uid=%@", call.channelId, call.selfId]; //带一个参数key传给服务器
    
    [HttpUtil HttpPost:stringUrl Param:param Callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSInteger code = [(NSHTTPURLResponse *)response statusCode];
        NSLog(@"response code:%ldd", (long)code);
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            BOOL ret = dic[@"success"];
            
            
            if(ret == YES)
            {
                [RtcManager muteLocalAudioStream:false];
                [RtcManager muteAllRemoteAudioStreams:false];
                [call endObserverMode];
                if(completionBlock != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),^{
                        completionBlock(AcmPhoneCallOK);
                    });
                }
            }
            else
            {
                if(completionBlock != nil)
                {
                    dispatch_async(dispatch_get_main_queue(),^{
                        completionBlock(AcmPhoneCallErrorApplyAuthorityResponse);
                    });
                }
                
            }
        }
        else{
            if(completionBlock != nil)
            {
                dispatch_async(dispatch_get_main_queue(),^{
                    completionBlock(AcmPhoneCallErrorApplyAuthority);
                });
            }
        }
    }];
}

- (void) requestQuitRobot: (nonnull AcmCall *)call
{
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, AuthorityApi];
    NSString *param = [NSString stringWithFormat:@"channel=%@&uid=%@", call.channelId, call.selfId]; //带一个参数key传给服务器
    
    [HttpUtil HttpPost:stringUrl Param:param Callback:nil];
}

// 跳转回Monitor Action
- (void) JumpBackToMonitorAction{
    // 跳转到Monitor 状态
    MonitorAction * monitorAction = [[MonitorAction alloc]init:[ActionManager instance]];
    
    [[ActionManager instance] actionChange:self destAction:monitorAction];

}

- (void) quitOnPhoneCall: (AcmCall *) call {
    
    DebugLog(OnPhoneTag,@"quitOnPhoneCall");
    if(call != nil && call.stage == OnPhone){
        
        [call updateStage:Finished];
        if(call.channelId != nil)
        {
            [self requestQuitRobot:call];
            [RtcManager endAudioCall];
            
            /*
            NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, EndCallApi];
            NSString *param = [NSString stringWithFormat:@"uid=%@&channel=%@", call.selfId, call.channelId]; //带一个参数key传给服务器
            
            [HttpUtil HttpPost:stringUrl Param:param Callback:nil];
             */
            
            // 通知后台开始通话
            NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, CallEventAPI];
            NSString *param = [NSString stringWithFormat:@"uid=%@&channel=%@&code=%ld", call.selfId, call.channelId,(long)CallEventEndCall];
            
            [HttpUtil HttpPost:stringUrl Param:param Callback:nil];
        }
        
        [self JumpBackToMonitorAction];
    }
}

@end
