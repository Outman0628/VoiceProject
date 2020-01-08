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
#import "../RTM/RunTimeMsgManager.h"

@interface ActionManager()
// 当前Action
@property  ACMAction *activeAction;
@property id<IACMCallBack>  icmCallBack;
@end

@implementation ActionManager

- (void) HandleEvent: (EventData) eventData{
    if(eventData.type == EventInitSDK && _activeAction == nil)
    {
        self.appId = eventData.param4;
        self.icmCallBack = eventData.param5;
        
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
    else
    {
        [self.activeAction HandleEvent:eventData];
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
        nextAction = [[LoginAction alloc]init:self];

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

- (void)actionFailed:(nullable ACMAction *)action
{
    
}
@end
