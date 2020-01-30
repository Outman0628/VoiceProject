//
//  CallManager.h
//  ACM
//
//  Created by David on 2020/1/9.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef CallManager_h
#define CallManager_h
#import "AcmCall.h"
#import "../IRTCCallBack.h"

@interface CallManager : NSObject

// 正在进行中的电话，注意刚结束不久的电话也在这个队列
// 防止频繁的拨号，挂断使得状态不通不及时，造成拨打方和接听方进入已结束的通话
@property NSMutableArray * _Nullable activeCallList;

/*
  生成新的拨打通话记录
  @param peerId 通话 对象
  @delegate 通话状态回调
  */
//+( nonnull Call * )prepareDialCall: (nonnull NSString *)peerId ircmCallback:(id <IRTCCallBack> _Nullable)delegate;

/*
 生成新的拨打通话记录
 @param peerList 通话 对象
 @type 通话类型
 @delegate 通话状态回调
 */
+( nonnull AcmCall * )prepareDialCall: (nonnull NSArray *)peerList Type:(CallType)type ircmCallback:(id <IRTCCallBack> _Nullable)delegate;

/*
 初始化
 */
-(id _Nullable )init;

/*
 检测通话是否已经存在
 
 @param channelId 通话 channel
 @return YES 通话已经存在，No 通话不存在
 */
-(BOOL )IsActiveCall: (nonnull NSString *)channelId;

/*
生成新的接听通话记录
 @param callReq 通话请求内容
 @param userId 本机用户id
 @return 通话记录
 */
-( nonnull AcmCall * )createReceveCall: (nonnull NSDictionary *)callReq userAccount:(nonnull NSString *)userId;

/*
 更新的拨打通话记录
 @param peerId 通话 对象
 @delegate 通话状态回调
 */
-( nonnull AcmCall * )updateDialCall: (nonnull NSDictionary *)callInfo selfUid:(nonnull NSString*)uid ircmCallback:(id <IRTCCallBack> _Nullable)delegate  preInstance:(nonnull AcmCall *)call;

/*
获取通话对象
 @param channelId 通话id
 @return 返回channelId 对应记录
 */
-( nullable AcmCall * )getCall: (nullable NSString*)channelId;

/*
 获取通话当前活跃的通话对象
 */
-( nullable AcmCall * )getActiveCall;

@end

#endif /* CallManager_h */
