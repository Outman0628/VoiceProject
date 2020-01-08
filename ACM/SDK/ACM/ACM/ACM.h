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

@interface ACM : NSObject
/**
 初始化通话监听服务
 
 @param appId 声网项目APP ID
 
 @param delegate 通过后监听回调.
 */
+ (void) initManager: ( nullable NSString *) appId  acmCallback:(id <IACMCallBack> _Nullable)delegate;

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
 
 */
+ (void) agreeCall: ( nullable NSString *)channelId;

/**
 拒接电话
 
 @param channel 通话渠道号
 
 @param peerId 通话id.
 
 */
+ (void) rejectCall: ( nullable NSString *)channel fromPeer:( nullable NSString * )peerId;

/**
 结束电话
 
 @param channel 通话渠道号
 
 @param peerId 通话id.
 
 */
+ (void) leaveCall: ( nullable NSString *)channel fromPeer:( nullable NSString * )peerId;

/**
 拨打电话
 
 @param peerId 对方ID
 
 */
+ (void) ringAudioCall: (nullable NSString *)peerId;

@end
