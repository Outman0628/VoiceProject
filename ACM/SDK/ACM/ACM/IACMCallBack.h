//
//  IACMCallBack.h
//  ACM
//
//  Created by David on 2020/1/3.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <AgoraRtmKit/AgoraRtmKit.h>
#import "ACMEnums.h"
#import "Call.h"

/**
 The AgoraRtmDelegate protocol enables Agora RTM callback event notifications to your app.
 */
@protocol IACMCallBack <NSObject>
@optional

/**
连接状态改变
 
 @param state 连接状态，参见 AgoraRtmConnectionState.
 @param reason 原因参加 AgoraRtmConnectionChangeReason.
 
 */
- (void)connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason;

/**
 接收到对方消息
 
 @param message 消息
 
 @param peerId 发送者id.
 */
- (void)messageReceived:(NSString * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId;

/**
 接收到对方通话请求
 
 @param call 通话请求对象
 
 */
- (void)onCallReceived:(nonnull Call *)call;

/**
 接听方拨号响应结束
 
 @param call 通话请求对象
 
 */
- (void)onCallEnd:(nonnull Call *)call endCode:(AcmMsgType)dialCode;

@end



/**
 Subscription types.
 */

/**
 登录回调函， 返回值参见 AgoraRtmLoginErrorCode.
 */
typedef void (^IACMLoginBlock)(AcmLoginErrorCode errorCode);

/**
 发送点对点消息， 返回值参见 AgoraRtmLoginErrorCode.
 */
typedef void (^IACMSendPeerMessageBlock)(AgoraRtmSendPeerMessageErrorCode errorCode);

/**
 是否有他设备已经登录
 */
typedef void (^LoginCheckBlock)(BOOL alreadyLoggedin, AgoraRtmQueryPeersOnlineErrorCode errorCode);
