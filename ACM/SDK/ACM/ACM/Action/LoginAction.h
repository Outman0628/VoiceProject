//
//  RegAction.h
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef LoginAction_h
#define LoginAction_h

#import "ACMAction.h"

@class ActionManager;

@interface LoginAction : ACMAction

/*
 初始化
 */
-(id _Nullable )init: (nonnull ActionManager *) mgr apnsToken:(nonnull NSString *)token;

/**
 Action 事件处理
 */
- (void) HandleEvent: (EventData) eventData;

@end

#endif /* RegAction_h */
