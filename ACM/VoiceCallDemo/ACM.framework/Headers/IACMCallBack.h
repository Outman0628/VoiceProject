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
 Occurs when the connection state between the SDK and the Agora RTM system changes.
 
 @param kit An [AgoraRtmKit](AgoraRtmKit) instance.
 @param state The new connection state. See AgoraRtmConnectionState.
 @param reason The reason for the connection state change. See AgoraRtmConnectionChangeReason.
 
 */
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit connectionStateChanged:(AgoraRtmConnectionState)state reason:(AgoraRtmConnectionChangeReason)reason;

/**
 Occurs when the local user receives a peer-to-peer message.
 
 @param kit An [AgoraRtmKit](AgoraRtmKit) instance.
 @param message The received message.
 
 **NOTE** Ensure that you check the `type` property when receiving the message instance: If the message type is `AgoraRtmMessageTypeRaw`, you need to downcast the received instance from AgoraRtmMessage to AgoraRtmRawMessage. See AgoraRtmMessageType.
 
 @param peerId The user ID of the sender.
 */
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit messageReceived:(AgoraRtmMessage * _Nonnull)message fromPeer:(NSString * _Nonnull)peerId;

/**
 Occurs when the online status of the peers, to whom you subscribe, changes.
 
 - When the subscription to the online status of specified peer(s) succeeds, the SDK returns this callback to report the online status of peers, to whom you subscribe.
 - When the online status of the peers, to whom you subscribe, changes, the SDK returns this callback to report whose online status has changed.
 - If the online status of the peers, to whom you subscribe, changes when the SDK is reconnecting to the server, the SDK returns this callback to report whose online status has changed when successfully reconnecting to the server.
 
 @param kit An [AgoraRtmKit](AgoraRtmKit) instance.
 @param onlineStatus An array of peers' online states. See AgoraRtmPeerOnlineStatus.
 */
- (void)rtmKit:(AgoraRtmKit * _Nonnull)kit PeersOnlineStatusChanged:(NSArray< AgoraRtmPeerOnlineStatus *> * _Nonnull)onlineStatus;

/**
 Occurs when the current RTM Token exceeds the 24-hour validity period.
 
 This callback occurs when the current RTM Token exceeds the 24-hour validity period and reminds the user to renew it. When receiving this callback, generate a new RTM Token on the server and call the [renewToken]([AgoraRtmKit renewToken:completion:]) method to pass the new Token on to the server.
 
 @param kit An AgoraRtmKit instance.
 */
- (void)rtmKitTokenDidExpire:(AgoraRtmKit * _Nonnull)kit;
@end
