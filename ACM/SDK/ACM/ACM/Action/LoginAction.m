//
//  SDKInitAction.m
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginAction.h"
#import "../RTM/RunTimeMsgManager.h"
#import "ActionManager.h"
#import "../RTM/IACMCallBack.h"

@interface LoginAction()

@property ActionManager* actionMgr;
@property NSString* userId;

@end

@implementation LoginAction



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
    
    if(eventData.type == EventLogin)
    {
        [self RTMLogin:eventData];
    }
    if(eventData.type == EventRTMLoginResult)
    {
        [self onRTMLoginResult:eventData];
    }
     
}

// RTM Login
- (void) RTMLogin: (EventData) eventData
{
    self.userId = eventData.param4;
    [RunTimeMsgManager loginACM:eventData.param4 completion:eventData.param5];
}

-(void) onRTMLoginResult:(EventData) eventData
{
    AgoraRtmLoginErrorCode errorCode = eventData.param1;
    IACMLoginBlock  completionBlock = eventData.param4;
    
    
     if (errorCode != AgoraRtmLoginErrorOk) {
     
         
         NSLog(@"ACM Login failed:%ld", errorCode);
         if(completionBlock != nil)
         {
             completionBlock(errorCode);
         }
     }
     else{
         NSLog(@"ACM Login succeeed!");
         [self.actionMgr setUserId:self.userId];
         [self.actionMgr actionDone:self];
         if(completionBlock != nil)
         {
         completionBlock(errorCode);
         }
     }
    
}
@end

