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
@class Call;

@interface RunTimeMsgManager : NSObject

+ (BOOL) init: ( nullable NSString *) appId  acmCallback:(id <IACMCallBack> _Nullable)delegate actionMgr:(nonnull ActionManager *)mgr;

+ (void) loginACM: ( nullable NSString *) userId completion:(IACMLoginBlock _Nullable)completionBlock;

+ (void) loggedInCheck: ( nullable NSString *) userId completion:(LoginCheckBlock _Nullable)completionBlock;

+ (void) logoutACM;

+ (void)sendP2PMessage: (nullable NSString *)msg  userAccount:( nullable NSString *)userId remoteUid:( nullable NSString *)peerId completion:(IACMSendPeerMessageBlock _Nullable)completionBlock;

+ (void)invitePhoneCall: (nonnull Call*) call;

+ (void)rejectPhoneCall: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID;

+ (void)agreePhoneCall: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID;

+ (void)robotAnswerPhoneCall: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID;

+ (void) leaveCall: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID;

+ (void)syncAsrData: (nullable NSString *)remoteUid userAccount:(nullable NSString *)userID  channelID:(nullable NSString *)channelID asrData:(nonnull NSString *)text timeStamp:(NSTimeInterval)startTime isFinished:(BOOL) finished;

@end

#endif /* RunTimeMsgManager_h */
