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
#import "InComeDialAction.h"
#import "LoginAction.h"

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
    /*
    else if(eventData.type == EventRtmRejectAudioCall)
    {
        [self HandleRemoteRejectcall:eventData];
    }
     */
/*
    else if(eventData.type == EventRtmLeaveCall)
    {
        [self remoteLeaveCall:eventData];
    }
 */
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
    else
    {
        [super HandleEvent:eventData];
    }
    
}

-(void) HandleRtmCallReq: (EventData) eventData{
    /*
    Call *call = eventData.param4;
    id<IACMCallBack> callBack = self.actionMgr.icmCallBack;
    if(callBack != nil)
    {
        [callBack onCallReceived:call.channelId fromPeer:call.callerId];
        self.channelID = call.channelId;
    }
     */
    
    InComeDialAction* inComeDialAction = [[InComeDialAction alloc]init];
    
    [self.actionMgr actionChange:self destAction:inComeDialAction];
    
    [self.actionMgr HandleEvent:eventData];
}
 

-(void) HandleApnsCallReq: (EventData) eventData{
    
    
    /*
    id<IACMCallBack> callBack = self.actionMgr.icmCallBack;
    Call *call = eventData.param4;
    
    if(callBack != nil)
    {
        [callBack onCallReceived:call.channelId fromPeer:call.callerId];
        self.channelID = call.channelId;
    }
     */
    InComeDialAction* inComeDialAction = [[InComeDialAction alloc]init];
    
    [self.actionMgr actionChange:self destAction:inComeDialAction];
    
    [self.actionMgr HandleEvent:eventData];
}
/*
- (void) HandleRemoteRejectcall: (EventData) eventData{
    id<IACMCallBack> callBack = eventData.param6;
    self.channelID = nil;
    if(callBack != nil)
    {
        [callBack onRemoteRejectCall:eventData.param4 fromPeer:eventData.param5];
        self.channelID = eventData.param4;
    }
    
}
 */

/*
- (void) remoteLeaveCall: (EventData) eventData{
    id<IACMCallBack> callBack = eventData.param6;
    self.channelID = nil;
    if(callBack != nil)
    {
        [callBack onRemoteLeaveCall:eventData.param4 fromPeer:eventData.param5];
    }
    
    [AudioCallManager endAudioCall];
}
 */

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
