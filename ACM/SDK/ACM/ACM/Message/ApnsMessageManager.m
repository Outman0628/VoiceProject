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

@interface ApnsMessageManager()
@end

@implementation ApnsMessageManager

+ (BOOL) handleApnsMessage:(nonnull NSDictionary *)message actionManager:(nonnull ActionManager *)actionMgr
{         
    BOOL ret = YES;
    
    if(message != nil && message[@"aps"] != nil && message[@"aps"][@"userInfo"] != nil)
    {
        
        //NSDictionary *userInfo = message[@"aps"][@"userInfo"];
        
        NSString *apnsMsg =  message[@"aps"][@"userInfo"];
        
        NSData *jsonData = [apnsMsg dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        
        if( [userInfo[@"title"] isEqualToString:@"audiocall"] )
        {
            //- (void)onCallReceived:(NSString * _Nonnull)channel fromPeer:(NSString * _Nonnull)peerId;
            NSLog(@"apns audio call from:%@", userInfo[@"accountCaller"] );
            
            
            if([actionMgr.callMgr IsActiveCall:userInfo[@"channel"]] == YES) // 通话已经在处理中，丢弃后到的通话
            {
                NSLog(@"phone call:%@ from APNS drop as same call already exist!", userInfo[@"channel"]);
                ret = NO;
            }
            else
            {
                AcmCall  *instance = [actionMgr.callMgr createReceveCall:userInfo userAccount:[ActionManager instance].userId];
                EventData eventData = {EventGotApnsAudioCall, 0,0,0,instance};
                [actionMgr HandleEvent:eventData];
            }
        }
    }
    
    return ret;
}

@end
