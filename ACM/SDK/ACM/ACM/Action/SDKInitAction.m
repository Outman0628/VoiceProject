//
//  SDKInitAction.m
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SDKInitAction.h"
#import "../Message/RunTimeMsgManager.h"
#import "ActionManager.h"
#import "../ASR/AudioStreamMgr.h"
#import "../Message/HttpUtil.h"

@interface SDKInitAction()

@property ActionManager* actionMgr;

@end

@implementation SDKInitAction



-(id _Nullable)init: (nullable ActionManager *) mgr{
    if (self = [super init]) {
        
        self.type = ActionSDKInit;
        self.actionMgr = mgr;
    }
    return self;
}

- (void) HandleEvent: (EventData) eventData
{
    if(eventData.type == EventInitSDK)
    {
        [AudioStreamMgr initMgr];
        [self GetSystemConfig:eventData];
    }
    else{
        [super HandleEvent:eventData];
    }
}

- (void) InitRtm: (EventData) eventData{
    BOOL rtmResult = [RunTimeMsgManager init:[ActionManager instance].appId acmCallback:eventData.param4 actionMgr:self.actionMgr];
    
    if(rtmResult == YES)
    {
        [self.actionMgr actionDone:self];
        IACMInitBlock block = eventData.param7;
        if(block != nil){
            dispatch_async(dispatch_get_main_queue(),^{
                block(AcmInitOk);
            });
        }
    }
    else{
        IACMInitBlock block = eventData.param7;
        if(block != nil){
            dispatch_async(dispatch_get_main_queue(),^{
                block(AcmInitRTMError);
            });
        }
    }
}

- (void) GetSystemConfig : (EventData) eventData{
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",[ActionManager instance].host, SystemConfigApi];
    NSString *param = @"";
    
    [HttpUtil HttpPost:stringUrl Param:param Callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            BOOL ret = dic[@"success"];
            
            if(ret == YES)
            {
                NSDictionary *data = dic[@"data"];
                if(data != nil && data[@"channel_heartbeat"] != nil && data[@"agora_appid"] != nil)
                {
                   
                    [ActionManager instance].onPhoneHeartInterval = ((NSNumber *)data[@"channel_heartbeat"]).integerValue;
                    [ActionManager instance].appId = data[@"agora_appid"];
                    
                    dispatch_async(dispatch_get_main_queue(),^{
                        [self InitRtm:eventData];
                    });
                }
                else
                {
                    // 通知错误发生
                    IACMInitBlock block = eventData.param7;
                    if(block != nil){
                        dispatch_async(dispatch_get_main_queue(),^{
                            block(AcmInitBackendResponseError);
                        });
                    }
                    
                }
            }
            else
            {
                // 通知错误发生
                IACMInitBlock block = eventData.param7;
                if(block != nil){
                    dispatch_async(dispatch_get_main_queue(),^{
                        block(AcmInitBackendResponseError);
                    });
                }
                
            }
        }
        else{
            // 通知错误发生
            IACMInitBlock block = eventData.param7;
            if(block != nil){
                dispatch_async(dispatch_get_main_queue(),^{
                    block(AcmInitBackendError);
                });
            }
        }
    }];
}
@end
