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
#import "../ASR/AsrManager.h"

@interface ActionManager : NSObject

@property (nonatomic) NSString * _Nullable userId;
@property NSString* _Nullable appId;
@property NSString* _Nullable host;
@property NSInteger dialingTimetout;  // 拨号超时，默认30秒
@property NSInteger onPhoneHeartInterval;  // 通话心跳
@property CallManager* _Nonnull  callMgr;
@property id<IACMCallBack> _Nullable  icmCallBack;
@property AsrManager * _Nullable asrMgr;
@property NSString * _Nullable apnsToken;
@property BOOL  isConnected;
@property BOOL  isSpeakerphoneEnabled;     // 外放设置
@property NSString * _Nullable baiduAppId;
@property NSString * _Nullable baiduApiKey;
@property NSString * _Nullable baiduSecrectKey;

+(ActionManager *_Nullable)instance;

/*
 初始化
 */
-(id _Nullable )init;

/*
 初始化百度方案
 */
-(void) initBaiduAI;

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
