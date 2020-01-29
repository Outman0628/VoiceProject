//
//  Call.h
//  ACM
//
//  Created by David on 2020/1/9.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef Call_h
#define Call_h
#import "IRTCCallBack.h"
@class ActionManager;

// 电话类型
typedef NS_ENUM(NSInteger, CallType) {
    
    // 音频电话
    AudioCall = 1,
    
    // 视频电话
    VideoCall = 2,
};

// 电话阶段
typedef NS_ENUM(NSInteger, CallStage) {
    
    // 拨号阶段
    Dialing = 1,
    
    // 拨号收到首个应答回复，准备进入通话间断
    PrepareOnphone = 2,
    
    // 通话阶段
    OnPhone = 3,
    
    // 通话结束
    Finished = 4,
};

// 本机在电话中的角色
typedef NS_ENUM(NSInteger, RoleType) {
    
    // 发起者
    Originator = 1,
    
    // 接听者
    Subscriber = 2,
    
    // 观察者  (静音进入，不能讲话)
    Observer = 3,
};


@interface Call : NSObject

// 电话类型
@property CallType callType;
// 电话阶段
@property (readonly) CallStage stage;
// 本机在电话中的角色
@property RoleType  role;

// 本地静音状态
@property BOOL  localMuteState;

// 远程静音状态
@property BOOL  remoteMuteState;

// 发起者uid
@property NSString * _Nonnull callerId;
// 接听者列表
@property NSMutableArray *  _Nonnull subscriberList;

// 本机uid
@property NSString * _Nonnull selfId;
// 通话频道
@property NSString * _Nullable channelId;
// 通话token 只属于本机uid
@property NSString * _Nullable token;
// 本通话所使用的声网app id
@property NSString * _Nullable appId;
// 状态回调
@property id <IRTCCallBack> _Nullable callback;

/*
 *对象初始化
 */
-(id _Nullable )init;

/*
 *添加接听对象
 */
-(void)addSubscriber: (nonnull NSString *)subscriberId;

/*
 *添加接听对象
 */
-(void)updateStage: (CallStage) stage;

/*
 *结束Observer模式
 */
-(void)endObserverMode;

/*
 *更新在线人员信息
 */
-(void)updateOnlineMember: (nonnull NSString *)uid Online:(BOOL)isOnline;

/*
 * 获取在线人员名单
 */
- (NSArray *_Nonnull)getOnlineMembers;

@end

#endif /* Call_h */
