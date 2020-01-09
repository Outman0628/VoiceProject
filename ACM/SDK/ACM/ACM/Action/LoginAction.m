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

static NSString *BackLoginApi = @"/dapi/account/update";

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

- (void) BackendLogin{
    NSString *stringUrl = [NSString stringWithFormat:@"%@%@",self.actionMgr.host, BackLoginApi];
    
    NSURL *url = [NSURL URLWithString:stringUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    request.timeoutInterval = 5.0;
    
    request.HTTPMethod = @"POST";
    
    NSString *bodyString = [NSString stringWithFormat:@"uid=%@&device=%@&apns_token=%@", self.userId,@"ios",self.apnsToken]; //带一个参数key传给服务器
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
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
                [RunTimeMsgManager logoutACM];
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
            self.userId = nil;
            [RunTimeMsgManager logoutACM];
            dispatch_async(dispatch_get_main_queue(),^{
                self.completionBlock(AcmLoginBackendErrorUnknow);
            });
        }
    }] resume];
    

}

-(void) onRTMLoginResult:(EventData) eventData
{
    AcmLoginErrorCode errorCode = eventData.param1;
    self.completionBlock = eventData.param4;
    
    
     if (errorCode != AgoraRtmLoginErrorOk) {
     
         [self.actionMgr actionFailed:self];
         NSLog(@"ACM Login failed:%ld", errorCode);
         if(self.completionBlock != nil)
         {
             self.completionBlock(errorCode);
         }
     }
     else{
         NSLog(@"ACM Login succeeed!");
         
         /*
         [self.actionMgr setUserId:self.userId];
         [self.actionMgr actionDone:self];
         if(completionBlock != nil)
         {
             completionBlock(errorCode);
         }
          */
         // Continue backend login
         [self BackendLogin];
     }
}
@end

