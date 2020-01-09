//
//  DialAction.h
//  ACM
//
//  Created by David on 2020/1/8.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef DialAction_h
#define DialAction_h

#import "ACMAction.h"
@class ActionManager;

// 拨号
@interface DialAction : ACMAction

/*
 初始化
 */
-(id _Nullable )init: (nonnull ActionManager *) mgr userAcount:(nonnull NSString *)userId;


/**
 Action 事件处理
 */
- (void) HandleEvent: (EventData) eventData;

@end

#endif /* DialAction_h */
