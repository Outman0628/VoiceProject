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
#import "../Call/CallManager.h"

@interface ActionManager : NSObject

@property (nonatomic) NSString * _Nullable userId;
@property NSString* _Nullable appId;
@property NSString* _Nullable host;
@property CallManager* _Nonnull  callMgr;
@property id<IACMCallBack> _Nullable  icmCallBack;


/*
 初始化
 */
-(id _Nullable )init;

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
 处理Action 跳转
 @param EventData 事件数据
 */
- (void)actionChange:(nullable ACMAction *)curAction destAction:(nullable ACMAction *)nextAction;

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
