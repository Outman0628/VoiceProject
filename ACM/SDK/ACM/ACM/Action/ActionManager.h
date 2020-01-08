//
//  ActionManager.h
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef ActionManager_h
#define ActionManager_h
#import "../ACMCommon.h"
#import "EventData.h"
#import "ACMAction.h"

@interface ActionManager : NSObject

@property (nonatomic) NSString * _Nullable userId;
@property NSString* _Nullable appId;

/*
 处理事件
  @param EventData 事件数据
 */
- (void) HandleEvent: (EventData) eventData;

/*
 处理Action 结束事件
 @param EventData 事件数据
 */
- (void)actionDone:(nullable ACMAction *)action;

/*
 处理Action 失败事件
 @param EventData 事件数据
 */
- (void)actionFailed:(nullable ACMAction *)action;

/*
 设置用户id
 */
- (void)setUserId:(nullable NSString *)uid;

@end

#endif /* ActionManager_h */
