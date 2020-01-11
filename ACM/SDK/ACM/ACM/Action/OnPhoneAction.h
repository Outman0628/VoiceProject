//
//  OnPhoneAction.h
//  ACM
//
//  Created by David on 2020/1/10.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef OnPhoneAction_h
#define OnPhoneAction_h
#import "ACMAction.h"

// 通话Action
@interface OnPhoneAction : ACMAction

/*
 初始化
 */
-(id _Nullable )init;


/**
 Action 事件处理
 */
- (void) HandleEvent: (EventData) eventData;

#endif /* OnPhoneAction_h */
@end
