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

static NSString *AuthorityApi = @"/dapi/quit/robot";

// 电话响铃Action
@interface OnPhoneAction ()
@property AcmCall *curCall;
@property NSTimer *timer;
@end

@implementation OnPhoneAction

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
        [self JoinToChannelCall:eventData];
    }
    else if(eventData.type == EventLeaveCall)
    {
        [self.timer invalidate];
        [self leaveCall:eventData];
    }
    else if(eventData.type == EventNoMemberEndCall)
    {
        [self.timer invalidate];
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
    else if(eventData.type == EventRemoeAsrResult)
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
        
        [_curCall.callback onRemoteText:msgDic[@"asrData"] remoteAccount:msgDic[@"accountSender"] timeStamp:astTimestamp.doubleValue msgStamp:msgTimestamp.doubleValue isFinished:isFinished];
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
        [self setupLocalVideo:call];
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
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.timeoutInterval = 5.0;
    
    request.HTTPMethod = @"POST";
    
    NSString *bodyString = [NSString stringWithFormat:@"channel=%@", call.channelId]; //带一个参数key传给服务器
    
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
    }] resume];
}

// 跳转回Monitor Action
- (void) JumpBackToMonitorAction{
    // 跳转到Monitor 状态
    MonitorAction * monitorAction = [[MonitorAction alloc]init:[ActionManager instance]];
    
    [[ActionManager instance] actionChange:self destAction:monitorAction];

}

- (void) quitOnPhoneCall: (AcmCall *) call {
    
    if(call != nil && call.stage == OnPhone){
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
