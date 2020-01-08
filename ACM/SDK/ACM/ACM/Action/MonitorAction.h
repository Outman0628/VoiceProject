//
//  MonitorAction.h
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef MonitorAction_h
#define MonitorAction_h

#import "ACMAction.h"

@class ActionManager;

@interface MonitorAction : ACMAction

/*
 初始化
 */
-(id _Nullable )init: (nullable ActionManager *) mgr;

/**
 Action 事件处理
 */
- (void) HandleEvent: (EventData) eventData;

@end
#endif /* MonitorAction_h */
