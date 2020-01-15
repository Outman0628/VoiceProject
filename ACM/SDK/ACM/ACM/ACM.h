//
//  ACM.h
//  ACM
//
//  Created by David on 2020/1/2.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for ACM.
FOUNDATION_EXPORT double ACMVersionNumber;

//! Project version string for ACM.
FOUNDATION_EXPORT const unsigned char ACMVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ACM/PublicHeader.h>
#import "IACMCallBack.h"
#import "IRTCCallBack.h"
#import "ACMEnums.h"

@interface ACM : NSObject
/**
 初始化通话监听服务
 
 @param appId 声网项目APP ID
 @param host  音视频通话后台服务地址
 @param token 苹果消息推送token
 @param delegate 通过后监听回调.
 */
+ (void) initManager: ( nullable NSString *) appId backendHost:(nullable NSString *)host apnsToken:(nullable NSString *)token acmCallback:(id <IACMCallBack> _Nullable)delegate;

/**
 在通过监听服务中登录注册本机用户
 
 @param userId 本机用户ID
 @param completionBlock 登录结果回调
 
 */
+ (void) loginACM: ( nullable NSString *) userId completion:(IACMLoginBlock _Nullable)completionBlock;


/**
 发送消息给指定用户
 
 @param msg 发送的消息
 @param peerId 接送方id
 
 */
+ (void) sendP2PMessage: ( nullable NSString *)msg peerId:( nullable NSString *)peerId completion:(IACMSendPeerMessageBlock _Nullable)completionBlock;

/**
 接听电话
 
 @param channelId 通话请求频道
 @param delegate 通话回调
 */
+ (void) agreeCall: ( nullable NSString *)channelId ircmCallback:(id <IRTCCallBack> _Nullable)delegate;

/**
 拒接电话
 
 @param channel 通话渠道号
 
 */
+ (void) rejectCall: ( nullable NSString *)channel;

/**
 结束电话
 
 @param call 通话信息
 
 */
+ (void) leaveCall: ( nullable Call *)call;

/**
 拨打电话
 
 @param peerId 对方ID
 @param delegate 通话回调
 @return 拨打对象
 
 */
+ (nullable Call *) ringAudioCall: (nullable NSString *)peerId ircmCallback:(id <IRTCCallBack> _Nullable)delegate;

/*
 处理APNS 推送消息
 
 @param message apns 推送消息
 @return YES 已处理，No 还未初始化，处理失败
 */

+ (BOOL) handleApnsMessage:(nonnull NSDictionary *)message;

/**
 拨打给语音助手  // 测试接口
 
 */
+ (void) ringRobotAudioCall;

/**
 请求语音助手代接
 
 @param channelId 通话请求频道
 @param delegate 通话回调
 @return YES 已处理，No 还未初始化，处理失败
 */
+ (BOOL) robotAnswerCall: ( nullable NSString *)channelId ircmCallback:(id <IRTCCallBack> _Nullable)delegate;


/**
 更新Mute Mute state
 
 @param call 通话对象
 @return FALSE 参数有问题，检查channel id 是否正确，是否call state 是finish 状态
 */
+ (BOOL) updateMuteState: ( nonnull Call *)call;

/**
 切换话语权
 
 @param channelId 通话频道
 @param completionBlock 请求结果回调
 */
+ (void) getPhoneAuthority: ( nullable NSString *)channelId completion:(IRTCAGetAuthorityBlock _Nullable)completionBlock;
@end
