//
//  MonitorAction.m
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MonitorAction.h"
#import "../RTM/RunTimeMsgManager.h"
#import "ActionManager.h"
#import "../RTM/IACMCallBack.h"
#import "../RTC/AudioCallManager.h"

@interface MonitorAction()

@property ActionManager* actionMgr;
@property NSString* channelID;
@end

@implementation MonitorAction



-(id _Nullable)init: (nullable ActionManager *) mgr{
    if (self = [super init]) {
        
        self.type = ActionLogin;
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
    
}

-(void) HandleRtmCallReq: (EventData) eventData{
    /*
     if(acmCallBack != nil){
     [acmCallBack onCallReceived:dic[@"channel"] fromPeer:peerId];
     }
     */
    
    //EventData eventData = {EventGotRtmAudioCall, 0,0,0,dic[@"channel"],peerId,acmCallBack};
    id<IACMCallBack> callBack = eventData.param6;
    if(callBack != nil)
    {
        [callBack onCallReceived:eventData.param4 fromPeer:eventData.param5];
        self.channelID = eventData.param4;
    }
}

- (void) HandleAnswerCall: (EventData) eventData{
    [AudioCallManager startAudioCall:eventData.param4 user:eventData.param5 channel:eventData.param6 rtcCallback:eventData.param7];
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
@end
