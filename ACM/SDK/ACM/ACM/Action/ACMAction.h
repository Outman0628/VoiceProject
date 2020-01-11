//
//  ACMAction.h
//  ACM
//  内部Action 驱动基类
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef ACMAction_h
#define ACMAction_h


#import "EventData.h"

typedef NS_ENUM(NSInteger, ActionType) {
    
    // 初始化SDK Action
    ActionSDKInit = 1,
    
    // 登录 Action
    ActionLogin = 2,
    
    // 监听 Action
    ActionMonitor = 3,
    
    // 拨号 Action
    ActionDial = 4,
    
    // 通话请求 Action
    ActionInComeDial = 5,
    
    // 通话 Action
    ActionOnPhone = 6,
};


@interface ACMAction : NSObject

@property ActionType type;

/**
 进入Action 时处理事宜
  */
- (void) EnterEntry;

/**
 Action 退出
 */
- (void) ExitEntry;

/**
 Action 事件处理
 */
- (void) HandleEvent: (EventData) eventData;

@end

#endif /* ACMAction_h */
