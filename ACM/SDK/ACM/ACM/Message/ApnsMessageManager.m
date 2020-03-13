//
//  ApnsMessageManager.m
//  ACM
//
//  Created by David on 2020/1/9.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ApnsMessageManager.h"
#import "../Action/EventData.h"
#import "../Action/ActionManager.h"

#import "../Log/AcmLog.h"
#define APNSTAG  @"APNS"

@interface ApnsMessageManager()
@end

@implementation ApnsMessageManager

+ (BOOL) handleApnsMessage:(nonnull NSDictionary *)message actionManager:(nonnull ActionManager *)actionMgr
{         
    BOOL ret = NO;
    
    if(message != nil && message[@"aps"] != nil && message[@"aps"][@"userInfo"] != nil)
    {
        
        //NSDictionary *userInfo = message[@"aps"][@"userInfo"];
        
        NSString *apnsMsg =  message[@"aps"][@"userInfo"];
        
        NSData *jsonData = [apnsMsg dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        
        if( [userInfo[@"title"] isEqualToString:@"audiocall"] )
        {
            
            //- (void)onCallReceived:(NSString * _Nonnull)channel fromPeer:(NSString * _Nonnull)peerId;
            InfoLog(APNSTAG,@"apns audio call from:%@", userInfo[@"accountCaller"] );
            
            
                       
            [actionMgr.callMgr ValidateIncomeCall:userInfo[@"channel"] IsApnsCall:YES];
            ret = YES;
        }
    }
    
    return ret;
}

@end
