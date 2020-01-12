//
//  InComeDialAction.m
//  ACM
//
//  Created by David on 2020/1/10.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InComeDialAction.h"
#import "../Call/Call.h"
#import "ActionManager.h"
#import "OnPhoneAction.h"
#import "../Message/RunTimeMsgManager.h"
#import "MonitorAction.h"

static NSString *RobotAnserApi = @"/dapi/invite/robot";
static NSString *AnswerApi = @"/dapi/call/recieve";

// 电话响铃Action
@interface InComeDialAction ()
@end

@implementation InComeDialAction

-(id _Nullable )init{
    if (self = [super init]) {
        self.type = ActionInComeDial;
    }
    return self;
}


- (void) HandleEvent: (EventData) eventData
{
    if(eventData.type == EventGotRtmAudioCall){
        [self HandleRtmCallReq:eventData];
    }
    else if(eventData.type == EventGotApnsAudioCall)
    {
        [self HandleApnsCallReq:eventData];
    }
    else if(eventData.type == EventAgreeAudioCall)
    {
        [self HandleAnswerCall:eventData];
    }
    else if(eventData.type == EventRejectAudioCall)
    {
        [self HandleRejectCall:eventData];
    }
    else if(eventData.type == EventRobotAnswerCall)
    {
        [self HandleRobotAnswerCall:eventData];
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
    id<IACMCallBack> callBack =  [ActionManager instance].icmCallBack;
    if(callBack != nil)
    {
        [callBack onCallReceived:call];
    }
}
-(void) HandleApnsCallReq: (EventData) eventData{
    id<IACMCallBack> callBack =  [ActionManager instance].icmCallBack;
    Call *call = eventData.param4;
    
    if(callBack != nil)
    {
        [callBack onCallReceived:call];
    }
}
- (void) HandleAnswerCall: (EventData) eventData{
   /*
    OnPhoneAction* onPhone = [[OnPhoneAction alloc]init];
    
    [[ActionManager instance] actionChange:self destAction:onPhone];
    
   [[ActionManager instance] HandleEvent:eventData];
    */
    Call *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    if(call == nil && call.role != Subscriber)
    {
        // todo callback return error
        return;
    }
    
    call.callback = eventData.param5;
    
    // 请求后台应答参数
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, AnswerApi];
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.timeoutInterval = 5.0;
    
    request.HTTPMethod = @"POST";
    
    NSString *bodyString = [NSString stringWithFormat:@"uid=%@&channel=%@",call.selfId,call.channelId];
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //NSLog(@"response code:%@d", [(NSHTTPURLResponse *)response statusCode]);
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            BOOL ret = dic[@"success"];
            
            NSLog(@"Response:%@", dic);
            
            if(ret == YES)
            {
                NSDictionary *data = dic[@"data"];
                if(data != nil)
                {
                    call.appId = data[@"appID"];
                    call.channelId = data[@"channel"];
                    call.token = data[@"token"];
                }
                
                EventData nextData = { EventBackendAgreeAudioCall,0,0,0,call };
                OnPhoneAction* onPhone = [[OnPhoneAction alloc]init];
                
                [[ActionManager instance] actionChange:self destAction:onPhone];
                
                [[ActionManager instance] HandleEvent:nextData];
            }
            else
            {
                // 通知错误发生
                [call updateStage:Finished];
                
                dispatch_async(dispatch_get_main_queue(),^{
                    [call.callback didPhoneDialResult: AcmDialErrorWrongApplyAnswerCallResponse];
                });
                
                // 跳转到Monitor 状态
                [self JumpBackToMonitorAction];
                
            }
        }else{
            // 通知错误发生
            [call updateStage:Finished];
            
            dispatch_async(dispatch_get_main_queue(),^{
                [call.callback didPhoneDialResult: AcmDialErrorApplyAnswerCall];
            });
            
            // 跳转到Monitor 状态
            [self JumpBackToMonitorAction];
        }
    }] resume];
}

- (void) HandleRobotAnswerCall: (EventData) eventData{
    Call *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    if(call == nil && call.role != Subscriber)
    {
        // todo callback return error
        return;
    }
    
    call.callback = eventData.param5;
    
    // 请求后台机器人应答
    
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, RobotAnserApi];
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.timeoutInterval = 5.0;
    
    request.HTTPMethod = @"POST";
    
    NSString *bodyString = [NSString stringWithFormat:@"uid=%@&channel=%@",call.selfId,call.channelId]; //带一个参数key传给服务器
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    //NSLog(@"response code:%@d", [(NSHTTPURLResponse *)response statusCode]);
    if([(NSHTTPURLResponse *)response statusCode] == 200){
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        
        BOOL ret = dic[@"success"];
        
        NSLog(@"Response:%@", dic);
        
        if(ret == YES)
        {
            NSDictionary *data = dic[@"data"];
            if(data != nil)
            {
                call.appId = data[@"appID"];
                call.channelId = data[@"channel"];
                call.token = data[@"token"];
            }
            
            EventData nextEventdata = {EventRobotAnsweredCall,0,0,0,call};
            
            dispatch_async(dispatch_get_main_queue(),^{
                
                [call.callback didPhoneDialResult: AcmDialRobotAnswered];
                
                OnPhoneAction* onPhone = [[OnPhoneAction alloc]init];
                
                [[ActionManager instance] actionChange:self destAction:onPhone];
                
                [[ActionManager instance] HandleEvent:nextEventdata];
            });
        }
        else
        {
            // 通知错误发生
            [call updateStage:Finished];
            
            dispatch_async(dispatch_get_main_queue(),^{
                [call.callback didPhoneDialResult: AcmDialErrorWrongApplyAnswerCallResponse];
            });
            
            // 跳转到Monitor 状态
            [self JumpBackToMonitorAction];
            
        }
    }else{
        // 通知错误发生
        [call updateStage:Finished];
        
        dispatch_async(dispatch_get_main_queue(),^{
            [call.callback didPhoneDialResult: AcmDialErrorApplyAnswerCall];
        });
        
        // 跳转到Monitor 状态
        [self JumpBackToMonitorAction];
    }        
    }] resume];
}

- (void) HandleRejectCall: (EventData) eventData{
       
    Call *call = [[ActionManager instance].callMgr getCall:eventData.param4];
    if(call != nil)
    {
        [call updateStage:Finished];
    }
    
    [RunTimeMsgManager rejectPhoneCall:call.callerId userAccount:call.selfId channelID:call.channelId];
    
    [self JumpBackToMonitorAction];
}

// 跳转回Monitor Action
- (void) JumpBackToMonitorAction{
    // 跳转到Monitor 状态
    MonitorAction * monitorAction = [[MonitorAction alloc]init:[ActionManager instance]];
    
    [[ActionManager instance] actionChange:self destAction:monitorAction];
    
}

@end
