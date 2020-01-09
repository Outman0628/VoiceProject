//
//  IACMCallBack.h
//  ACM
//
//  Created by David on 2020/1/3.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <AgoraRtmKit/AgoraRtmKit.h>

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
 
 @param channel 通话渠道号
 
 @param peerId 发送者id.
 */
- (void)onCallReceived:(NSString * _Nonnull)channel fromPeer:(NSString * _Nonnull)peerId;

/**
 接收到对方挂断请求
 
 @param channel 通话渠道号
 
 @param peerId 发送者id.
 */
- (void)onRemoteRejectCall:(NSString * _Nonnull)channel fromPeer:(NSString * _Nonnull)peerId;

/**
 接收到对方结束通话
 
 @param channel 通话渠道号
 
 @param peerId 发送者id.
 */
- (void)onRemoteLeaveCall:(NSString * _Nonnull)channel fromPeer:(NSString * _Nonnull)peerId;

@end

typedef NS_ENUM(NSInteger, AcmLoginErrorCode) {
    
    /**
     0: Login succeeds. No error occurs.
     */
    AcmRtmLoginErrorOk = 0,
    
    /**
     1: Login fails for reasons unknown.
     */
    AcmRtmLoginErrorUnknown = 1,
    
    /**
     2: Login is rejected, possibly because the SDK is not initialized or is rejected by the server.
     */
    AcmRtmLoginErrorRejected = 2,
    
    /**
     3: Invalid login arguments.
     */
    AcmRtmLoginErrorInvalidArgument = 3,
    
    /**
     4: The App ID is invalid.
     */
    AcmRtmLoginErrorInvalidAppId = 4,
    
    /**
     5: The token is invalid.
     */
    AcmRtmLoginErrorInvalidToken = 5,
    
    /**
     6: The token has expired, and hence login is rejected.
     */
    AcmRtmLoginErrorTokenExpired = 6,
    
    /**
     7: Unauthorized login.
     */
    AcmRtmLoginErrorNotAuthorized = 7,
    
    /**
     8: The user has already logged in or is logging in the Agora RTM system, or the user has not called the [logoutWithCompletion]([AgoraRtmKit logoutWithCompletion:]) method to leave the `AgoraRtmConnectionStateAborted` state.
     */
    AcmRtmLoginErrorAlreadyLogin = 8,
    
    /**
     9: The login times out. The current timeout is set as six seconds.
     */
    AcmRtmLoginErrorTimeout = 9,
    
    /**
     10: The call frequency of the [loginByToken]([AgoraRtmKit loginByToken:user:completion:]) method exceeds the limit of two queries per second.
     */
    AcmRtmLoginErrorLoginTooOften = 10,
    
    /**
     101: The SDK is not initialized.
     */
    AcmRtmLoginErrorLoginNotInitialized = 101,
    
    /**
     1001: 后台登录未知错误.
     */
    AcmLoginBackendErrorUnknow = 1001,
};

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
