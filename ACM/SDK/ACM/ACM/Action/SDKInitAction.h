//
//  SDKInitAction.h
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef SDKInitAction_h
#define SDKInitAction_h

#import "ACMAction.h"

@class ActionManager;

@interface SDKInitAction : ACMAction

/*
 初始化
 */
-(id _Nullable )init: (nullable ActionManager *) mgr;

/**
 Action 事件处理
 */
- (void) HandleEvent: (EventData) eventData;

@end

#endif /* SDKInitAction_h */
