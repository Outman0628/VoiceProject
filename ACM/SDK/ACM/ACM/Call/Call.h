//
//  Call.h
//  ACM
//
//  Created by David on 2020/1/9.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef Call_h
#define Call_h

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
    
    // 通话阶段
    OnPhone = 2,
    
    // 通话结束
    Finished = 3,
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
@property CallStage stage;
// 本机在电话中的角色
@property RoleType  role;
// 发起者uid
@property NSString * _Nonnull callerId;
// 接听者列表
@property NSArray *  _Nonnull subscriberList;
// 本机uid
@property NSString * _Nonnull selfId;
// 通话频道
@property NSString * _Nullable channelId;

@end

#endif /* Call_h */
