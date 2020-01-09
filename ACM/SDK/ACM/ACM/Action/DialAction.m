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
#import "../RTC/AudioCallManager.h"
#import "MonitorAction.h"

static NSString *DialApi = @"/dapi/call/user";
static NSString *DialRobot = @"/dapi/call/robot";

@interface DialAction()

@property ActionManager* actionMgr;
@property NSString* userId;
@property NSString* peerId;
@property NSString* channelId;
@property NSString* rtcToken;
@property BOOL robotMode;
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
    if(eventData.type == EventDial)
    {
        self.peerId = eventData.param4;
        [self HanleDialWorkFlow:eventData];
    }
    else if(eventData.type == EventDialRobotDemo)
    {
        [self RequestRobotCall];
    }
    else if(eventData.type == EventLeaveCall)
    {
        [self leaveCall:eventData];
    }
    else if(eventData.type == EventRtmRejectAudioCall)
    {
        [self HandleRemoteRejectcall:eventData];
    }
    else if(eventData.type == EventRtmLeaveCall)
    {
        [self remoteLeaveCall:eventData];
    }
}

- (void) HanleDialWorkFlow: (EventData) eventData{
    [self RequestPhoneCallInfo];
}

- (void) RequestPhoneCallInfo{
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",self.actionMgr.host, DialApi];
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.timeoutInterval = 5.0;
    
    request.HTTPMethod = @"POST";
    
    NSString *bodyString = [NSString stringWithFormat:@"src_uid=%@&dst_uid=%@", self.userId,self.peerId]; //带一个参数key传给服务器
    
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
                   
                    [RunTimeMsgManager invitePhoneCall:self.peerId acountRemote:self.userId channelInfo:self.channelId];
                    
                    [AudioCallManager startAudioCall:self.actionMgr.appId user:self.userId channel:self.channelId   rtcToken:nil rtcCallback:nil];
                    
                }
                else
                {
                    // deal with err
                   
                }
            }
            else
            {
                self.userId = nil;
                
                // todo deal with failed
                
            }
            
            
            
        }
        else{
            // todo deal with failed
        }
    }] resume];
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
                    
                    NSLog(@"Join to Robot channel:%@", self.channelId);
                    
                    [AudioCallManager startAudioCall:data[@"appID"] user:self.userId channel:self.channelId   rtcToken:self.rtcToken rtcCallback:nil];                            
                    
                }
                else
                {
                    // deal with err
                    NSLog(@"ACM incorrect robot param");
                    
                }
            }
            else
            {
                self.userId = nil;
                
                // todo deal with failed
                 NSLog(@"ACM incorrect robot request response");
            }
            
            
            
        }
        else{
            // todo deal with failed
            NSLog(@"ACM robot request error. state:%ld",(long)[(NSHTTPURLResponse *)response statusCode]);
        }
    }] resume];
}

- (void) leaveCall: (EventData) eventData{
    [RunTimeMsgManager leaveCall:eventData.param4  userAccount:self.actionMgr.userId  channelID:eventData.param5];
    [AudioCallManager endAudioCall];
}

- (void) HandleRemoteRejectcall: (EventData) eventData{
    id<IACMCallBack> callBack = eventData.param6;
   
    if(callBack != nil)
    {
        [callBack onRemoteRejectCall:eventData.param4 fromPeer:eventData.param5];
        
        // 跳转到Monitor 状态
        MonitorAction * monitorAction = [[MonitorAction alloc]init:self.actionMgr];
        
        [self.actionMgr actionChange:self destAction:monitorAction];
        
        [self.actionMgr HandleEvent:eventData];
    }
    
}

- (void) remoteLeaveCall: (EventData) eventData{
    id<IACMCallBack> callBack = eventData.param6;
    if(callBack != nil)
    {
        [callBack onRemoteLeaveCall:eventData.param4 fromPeer:eventData.param5];
    }
    
    [AudioCallManager endAudioCall];
    // 跳转到Monitor 状态
    MonitorAction * monitorAction = [[MonitorAction alloc]init:self.actionMgr];
    
    [self.actionMgr actionChange:self destAction:monitorAction];
    
    [self.actionMgr HandleEvent:eventData];
}

@end
