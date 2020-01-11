//
//  InComeDialAction.h
//  ACM
//
//  Created by David on 2020/1/10.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef InComeDialAction_h
#define InComeDialAction_h
#import "ACMAction.h"

// 电话响铃Action
@interface InComeDialAction : ACMAction

/*
 初始化
 */
-(id _Nullable )init;


/**
 Action 事件处理
 */
- (void) HandleEvent: (EventData) eventData;

@end

#endif /* InComeDialAction_h */
