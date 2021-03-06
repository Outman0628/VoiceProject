//
//  ActionManager.m
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionManager.h"
#import "ACMAction.h"
#import "SDKInitAction.h"
#import "LoginAction.h"
#import "MonitorAction.h"
#import "../Message/RunTimeMsgManager.h"
#import "../Call/CallManager.h"
#import "../RTC/RtcManager.h"
#import "../ASR/ACMAudioInputStream.h"
#import "../ASR/ExternalAudio.h"

#import "../Log/AcmLog.h"
#define ActionMgrTag  @"ActionMgr"


static ActionManager* actionMgrInstance = nil;

@interface ActionManager()
// 当前Action
@property  ACMAction *activeAction;
@property ACMAudioInputStream *inputStream;
@property ExternalAudio *extAudio;

@end

@implementation ActionManager

+(ActionManager *_Nullable)instance
{
    return actionMgrInstance;
}

-(id _Nullable )init
{
    if (self = [super init]) {
        actionMgrInstance = self;
        self.callMgr = [[CallManager alloc]init];
        self.dialingTimetout = 60;
        self.isConnected = NO;
        self.onPhoneHeartInterval = 31;
        self.isSpeakerphoneEnabled = NO;
    }
    return self;
}

-(void) initBaiduAI{
    self.asrMgr = [[AsrManager alloc]init];
}

- (void) HandleEvent: (EventData) eventData{
    DebugLog(ActionMgrTag,@"HandleEvent:%ld",(long)eventData.type);
    if(eventData.type == EventInitSDK && _activeAction == nil)
    {
        self.icmCallBack = eventData.param4;
        self.host = eventData.param5;
        self.apnsToken = eventData.param6;
        
        self.activeAction = [[SDKInitAction alloc]init:self];
        
        [self.activeAction HandleEvent:eventData];        
    }
    else if(eventData.type == EventSendMsg)
    {
        // todo 后续添加sendmgs action
        // EventData eventData = {EventSendMsg, 0,0,0,msg,peerId,completionBlock};
        [RunTimeMsgManager sendP2PMessage:eventData.param4  userAccount:self.userId remoteUid:eventData.param5 completion:eventData.param6];
    }
    else if(eventData.type == EventGotRtmTextMsg)
    {
        // todo 后续是否需要移到Action 中？
        id<IACMCallBack> callBack = eventData.param6;
        if(callBack != nil)
        {
            [callBack messageReceived:eventData.param4 fromPeer:eventData.param5];
        }
    }
    else if(eventData.type == EventUpdateMuteState)
    {
        [self handleMuteEvent:eventData];
    }
    else if(eventData.type == EventInputStreamTest)
    {
        [self handleInputStreamTestEvent2:eventData];
    }
    else if(eventData.type == EventUpdateDialingTimer)
    {
        _dialingTimetout = eventData.param1;
    }
    else if(eventData.type == EventRTMConnectionStateChange)
    {
        [self handleRTMConnectionStateChanged:eventData];
    }
    else if(eventData.type == EventLoggedinCheck)
    {
        [self handleLoggedinCheck:eventData];
    }
    else if(eventData.type == EnableSpeakerphone){
        [self handleEventEnableSpeakerphone:eventData];
    }
    else
    {
        [self.activeAction HandleEvent:eventData];
    }
    
    
}

- (void)handleEventEnableSpeakerphone: (EventData)eventData{
    BOOL value = (eventData.param1 == 1);
    self.isSpeakerphoneEnabled = value;
    [RtcManager setEnableSpeakerphone:value];
}

- (void)handleLoggedinCheck: (EventData)eventData{
    [RunTimeMsgManager loggedInCheck:eventData.param4 completion:eventData.param5];
}

- (void)handleRTMConnectionStateChanged: (EventData)eventData{
    AgoraRtmConnectionState state = (AgoraRtmConnectionState)eventData.param1;
    //AgoraRtmConnectionChangeReason reason = (AgoraRtmConnectionChangeReason)eventData.param2;
    
    switch (state) {
        case AgoraRtmConnectionStateDisconnected:
        case AgoraRtmConnectionStateConnecting:
        case AgoraRtmConnectionStateReconnecting:
            _isConnected = false;
            break;
        case AgoraRtmConnectionStateAborted:
            [RunTimeMsgManager logoutRtm];
            _isConnected = false;
            break;
        case AgoraRtmConnectionStateConnected:
            _isConnected = true;
            break;
        default:
            break;
    }
    
    [self.activeAction HandleEvent:eventData];
}

- (void)handleMuteEvent:(EventData) eventData
{
    AcmCall *call = eventData.param4;
    if(call.stage != Finished)
    {
        [RtcManager muteLocalAudioStream:call.localMuteState];
        [RtcManager muteAllRemoteAudioStreams:call.remoteMuteState];
    }
}

- (void)handleInputStreamTestEvent:(EventData) eventData
{
    if(self.inputStream == nil)
    {
        self.inputStream = [[ACMAudioInputStream alloc] init];
        [self.inputStream open];
    }
}

- (void)handleInputStreamTestEvent2:(EventData) eventData
{
    if(self.extAudio == nil)
    {
        self.extAudio = [ExternalAudio sharedExternalAudio];
        [self.extAudio setupExternalAudioWithAgoraKit:nil sampleRate:16000 channels:1 audioCRMode:AudioCRModeExterCaptureSDKRender IOType:IOUnitTypeRemoteIO];
        [self.extAudio startWork];
    }
}

- (void)setUserId:(nullable NSString *)uid
{
    _userId = uid;
}

///////////// Action Delegate

- (void)actionDone:(nullable ACMAction *)action
{
    ACMAction *nextAction = nil;
    if(action.type == ActionSDKInit)
    {
        nextAction = [[LoginAction alloc]init:self apnsToken:self.apnsToken];

    }
    else if(action.type == ActionLogin)
    {
        nextAction = [[MonitorAction alloc]init:self];
    }
    
    
    [action ExitEntry];
    
    if(nextAction != nil)
    {
        [nextAction EnterEntry];
    }
    self.activeAction = nextAction;
}

/*
 处理Action 跳转
 @param EventData 事件数据
 */
- (void)actionChange:(nullable ACMAction *)curAction destAction:(nullable ACMAction *)nextAction{
    [curAction ExitEntry];
    [nextAction EnterEntry];
    if(curAction == self.activeAction)
    {
        self.activeAction = nextAction;
    }
}

- (void)actionFailed:(nullable ACMAction *)action
{
    
}
@end
