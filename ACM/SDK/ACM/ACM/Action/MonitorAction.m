//
//  MonitorAction.m
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MonitorAction.h"
#import "DialAction.h"
#import "../Message/RunTimeMsgManager.h"
#import "ActionManager.h"
#import "IACMCallBack.h"
#import "../RTC/AudioCallManager.h"

@interface MonitorAction()

@property ActionManager* actionMgr;
@property NSString* channelID;
@end

@implementation MonitorAction



-(id _Nullable)init: (nullable ActionManager *) mgr{
    if (self = [super init]) {
        
        self.type = ActionMonitor;
        self.actionMgr = mgr;
    }
    return self;
}

- (void) HandleEvent: (EventData) eventData
{
    //EventData eventData = {EventLogin, 0,0,0,userId,completionBlock,nil};
    
    if(eventData.type == EventGotRtmAudioCall){
        [self HandleRtmCallReq:eventData];
    }
    else if(eventData.type == EventAgreeAudioCall)
    {
         [self HandleAnswerCall:eventData];
    }
    else if(eventData.type == EventRejectAudioCall)
    {
        [self HandleRejectCall:eventData];
    }
    else if(eventData.type == EventRtmRejectAudioCall)
    {
        [self HandleRemoteRejectcall:eventData];
    }
    else if(eventData.type == EventLeaveCall)
    {
        [self leaveCall:eventData];
    }
    else if(eventData.type == EventRtmLeaveCall)
    {
        [self remoteLeaveCall:eventData];
    }
    else if(eventData.type == EventDial)
    {
        [self dialPhoneCall:eventData];
    }
    else if(eventData.type == EventDialRobotDemo)
    {
        [self dialRobotPhoneCall:eventData];
    }
    else if(eventData.type == EventGotApnsAudioCall)
    {
        [self HandleApnsCallReq:eventData];
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
    id<IACMCallBack> callBack = self.actionMgr.icmCallBack;
    if(callBack != nil)
    {
        [callBack onCallReceived:call.channelId fromPeer:call.callerId];
        self.channelID = call.channelId;
    }
}

-(void) HandleApnsCallReq: (EventData) eventData{
    
    
    //EventData eventData = {EventGotRtmAudioCall, 0,0,0,dic[@"channel"],peerId,acmCallBack};
    id<IACMCallBack> callBack = self.actionMgr.icmCallBack;
    Call *call = eventData.param4;
    
    if(callBack != nil)
    {
        [callBack onCallReceived:call.channelId fromPeer:call.callerId];
        self.channelID = call.channelId;
    }
}

- (void) HandleAnswerCall: (EventData) eventData{
    [AudioCallManager startAudioCall:eventData.param4 user:eventData.param5 channel:eventData.param6 rtcToken:nil rtcCallback:eventData.param7];
}

- (void) HandleRejectCall: (EventData) eventData{
    [RunTimeMsgManager rejectPhoneCall:eventData.param4  userAccount:self.actionMgr.userId  channelID:eventData.param5];
    self.channelID = nil;
}

- (void) HandleRemoteRejectcall: (EventData) eventData{
    id<IACMCallBack> callBack = eventData.param6;
    self.channelID = nil;
    if(callBack != nil)
    {
        [callBack onRemoteRejectCall:eventData.param4 fromPeer:eventData.param5];
        self.channelID = eventData.param4;
    }
    
}

- (void) leaveCall: (EventData) eventData{
    [RunTimeMsgManager leaveCall:eventData.param4  userAccount:self.actionMgr.userId  channelID:eventData.param5];
    [AudioCallManager endAudioCall];
    self.channelID = nil;
}

- (void) remoteLeaveCall: (EventData) eventData{
    id<IACMCallBack> callBack = eventData.param6;
    self.channelID = nil;
    if(callBack != nil)
    {
        [callBack onRemoteLeaveCall:eventData.param4 fromPeer:eventData.param5];
    }
    
    [AudioCallManager endAudioCall];
}

-(void) dialPhoneCall:(EventData) eventData{
    //(nonnull ActionManager *) mgr userAcount:(nonnull NSString *)userId remoteAcount:(nonnull NSString *)peerId{
    ACMAction* dialAction = [[DialAction alloc]init:self.actionMgr userAcount:self.actionMgr.userId];
    
    [self.actionMgr actionChange:self destAction:dialAction];
    
    [self.actionMgr HandleEvent:eventData];
    
}

-(void) dialRobotPhoneCall:(EventData) eventData{
    //(nonnull ActionManager *) mgr userAcount:(nonnull NSString *)userId remoteAcount:(nonnull NSString *)peerId{
    ACMAction* dialAction = [[DialAction alloc]init:self.actionMgr userAcount:self.actionMgr.userId];
    
    [self.actionMgr actionChange:self destAction:dialAction];
    
    [self.actionMgr HandleEvent:eventData];
    
}
@end
