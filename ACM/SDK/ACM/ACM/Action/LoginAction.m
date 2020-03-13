//
//  SDKInitAction.m
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginAction.h"
#import "../Message/RunTimeMsgManager.h"
#import "ActionManager.h"
#import "IACMCallBack.h"
#import "../Message/HttpUtil.h"

#import "../Log/AcmLog.h"
#define LoginTag  @"Login"

@interface LoginAction()

@property ActionManager* actionMgr;
@property NSString* userId;
@property NSString* apnsToken;
@property IACMLoginBlock  completionBlock;

@end

@implementation LoginAction



-(id _Nullable )init: (nonnull ActionManager *) mgr apnsToken:(nonnull NSString *)token{
    if (self = [super init]) {
        
        self.type = ActionLogin;
        self.actionMgr = mgr;
        self.apnsToken = token;
    }
    return self;
}

- (void) HandleEvent: (EventData) eventData
{
    DebugLog(LoginTag,@"HandleEvent:%ld",(long)eventData.type);
    
    if(eventData.type == EventLogin)
    {
        self.userId = eventData.param4;
        [self getRtmConfig:eventData];
    }
    else if(eventData.type == EventGotRtmConfig)
    {
        [self RTMLogin:eventData];
    }
    else if(eventData.type == EventRTMLoginResult)
    {
        [self onRTMLoginResult:eventData];
    }
    else
    {
        [super HandleEvent:eventData];
    }
     
}

// RTM Login
- (void) RTMLogin: (EventData) eventData
{
    //+ (void) loginACM: ( nullable NSString *) userId  AppId:( nullable NSString *) appId  Token:(nullable NSString *) token  completion:(IACMLoginBlock _Nullable)completionBlock;
    [RunTimeMsgManager loginACM:self.userId  AppId:eventData.param4  Token:eventData.param5 completion:eventData.param6 ];
}

- (void) BackendLogin{
    
   NSString *stringUrl = [NSString stringWithFormat:@"%@%@",self.actionMgr.host, BackLoginApi];
    
    NSDictionary * loginData =
    @{@"uid":self.userId,
      @"device": @"ios",
      @"apns_token":self.apnsToken == nil ? [NSNull null] : self.apnsToken,
      };
    
    NSError *error;
    NSData *data = [NSJSONSerialization dataWithJSONObject:loginData options:NSJSONWritingPrettyPrinted error:&error];
    NSString *param = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    [HttpUtil HttpPost:stringUrl Param:param Callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            BOOL ret = dic[@"success"];
            AcmLoginErrorCode errCode;
            
            if(ret == YES)
            {
                
                [self.actionMgr setUserId:self.userId];
                [self.actionMgr actionDone:self];
                
                errCode = AcmRtmLoginErrorOk;
            }
            else
            {
                self.userId = nil;
                [RunTimeMsgManager logoutRtm];
                errCode = AcmLoginBackendErrorUnknow;
                
            }
            
            if(self.completionBlock != nil)
            {
                
                dispatch_async(dispatch_get_main_queue(),^{
                    self.completionBlock(errCode);
                });
            }
            
        }
        else{
            ErrLog(LoginTag,@"Incorrect backend longin response code::%ld, error:%@",(long)[(NSHTTPURLResponse *)response statusCode],error);
            self.userId = nil;
            [RunTimeMsgManager logoutRtm];
            dispatch_async(dispatch_get_main_queue(),^{
                self.completionBlock(AcmLoginBackendErrorUnknow);
            });
        }
    }];
}


- (void) getRtmConfig: (EventData) eventData{
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",self.actionMgr.host, RTMConfigApi];
    
    NSString *bodyString = [NSString stringWithFormat:@"uid=%@", self.userId];
    
    [HttpUtil HttpPost:stringUrl Param:bodyString Callback:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if([(NSHTTPURLResponse *)response statusCode] == 200){
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            BOOL ret = dic[@"success"];
            AcmLoginErrorCode errCode = AcmRtmLoginErrorOk;
            
            if(ret == YES)
            {
                
                NSDictionary *data = dic[@"data"];
                
                if(data != nil){
                    NSString *rtmAppId = data[@"appID"];
                    NSString *rtmToken = data[@"token"];
                    
                    if(rtmAppId != nil && rtmAppId.length > 0 && rtmToken != nil && rtmToken.length > 0){
                       
                        
                        
                        dispatch_async(dispatch_get_main_queue(),^{
                             EventData nextEventData = {EventGotRtmConfig,0,0,0,rtmAppId,rtmToken,eventData.param5};
                            [[ActionManager instance] HandleEvent:nextEventData];
                        });
                    }else{
                        errCode = AcmLoginBackendErrorUnknow;
                    }
                
                }else{
                    errCode = AcmLoginBackendErrorUnknow;
                }
            }
            else
            {
                errCode = AcmLoginBackendErrorUnknow;
                
            }
            
            if(errCode != AcmRtmLoginErrorOk && self.completionBlock != nil)
            {
                
                dispatch_async(dispatch_get_main_queue(),^{
                    self.completionBlock(errCode);
                });
            }
            
        }
        else{
            ErrLog(LoginTag,@"Incorrect backend rtm config data response code::%ld, error:%@",(long)[(NSHTTPURLResponse *)response statusCode],error);
            self.userId = nil;
            if(self.completionBlock != nil){
                dispatch_async(dispatch_get_main_queue(),^{
                    self.completionBlock(AcmLoginBackendErrorUnknow);
                });
            }
        }
    }];
}

-(void) onRTMLoginResult:(EventData) eventData
{
    AcmLoginErrorCode errorCode = eventData.param1;
    self.completionBlock = eventData.param4;
    
    
     if (errorCode != AgoraRtmLoginErrorOk) {
     
         [self.actionMgr actionFailed:self];
         ErrLog(LoginTag,@"ACM Login failed:%ld", errorCode);
         if(self.completionBlock != nil)
         {
             self.completionBlock(errorCode);
         }
     }
     else{
         InfoLog(LoginTag,@"ACM Login succeeed!");
         
         [self BackendLogin];
     }
}
@end

