//
//  RunTimeMsgManager.h
//  ACM
//
//  Created by David on 2020/1/3.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef RunTimeMsgManager_h
#define RunTimeMsgManager_h

#import <AgoraRtmKit/AgoraRtmKit.h>
#import "IACMCallBack.h"

@class ActionManager;
@class AcmCall;

@interface RunTimeMsgManager : NSObject

+ (BOOL) init: ( nullable NSString *) appId  acmCallback:(id <IACMCallBack> _Nullable)delegate actionMgr:(nonnull ActionManager *)mgr;

+ (void) loginACM: ( nullable NSString *) userId  AppId:( nullable NSString *) appId  Token:(nullable NSString *) token  completion:(IACMLoginBlock _Nullable)completionBlock;

+ (void) loggedInCheck: ( nullable NSString *) userId completion:(LoginCheckBlock _Nullable)completionBlock;

+ (void) logoutRtm;

+ (void)sendP2PMessage: (nullable NSString *)msg  userAccount:( nullable NSString *)userId remoteUid:( nullable NSString *)peerId completion:(IACMSendPeerMessageBlock _Nullable)completionBlock;

+ (void)invitePhoneCall: (nonnull AcmCall *) call;

//+ (void)rejectPhoneCall: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID;

//+ (void)agreePhoneCall: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID;

//+ (void)robotAnswerPhoneCall: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID;

//+ (void) leaveCall: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID;

+ (void) dispatchEndDial: (nullable NSArray *)uidList userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID;

//+ (void)syncAsrData: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID asrData:(nonnull NSString *)text timeStamp:(NSTimeInterval)startTime isFinished:(BOOL) finished;

+ (AgoraRtmChannel * _Nullable)createChannel:(NSString * _Nonnull)channelId
                                          Delegate:(id <AgoraRtmChannelDelegate> _Nullable)delegate;

+ (void) destroyChannelWithId:(NSString * _Nonnull) channelId;

@end

#endif /* RunTimeMsgManager_h */
