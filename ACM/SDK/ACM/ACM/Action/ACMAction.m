//
//  ACMAction.m
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACMAction.h"
#import "../IRTCCallBack.h"

@implementation  ACMAction
/**
 进入Action 时处理事宜
 */
- (void) EnterEntry{
    
}

/**
 Action 退出
 */
- (void) ExitEntry{
    
}
/**
 Action 事件处理
 */
- (void) HandleEvent: (EventData) eventData{
    if(eventData.type == EventGetAuthority)
    {
        [self handleBaseEventGetAuthority:eventData];
    }
}

- (void) handleBaseEventGetAuthority: (EventData) eventData{
    IRTCAGetAuthorityBlock callback = eventData.param5;
    if( callback != nil )
    {
        callback(AcmPhoneCallErrorNoAuthority);
    }
}

@end
