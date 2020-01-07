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

@interface RunTimeMsgManager : NSObject

+ (void) init: ( nullable NSString *) appId  acmCallback:(id <IACMCallBack> _Nullable)delegate;

+ (void) loginACM: ( nullable NSString *) userId completion:(IACMLoginBlock _Nullable)completionBlock;

+ (void)sendP2PMessage: (nullable NSString *)msg remoteUid:( nullable NSString *)peerId completion:(IACMSendPeerMessageBlock _Nullable)completionBlock;

+ (nullable NSString *)invitePhoneCall: (nullable NSString *)remoteUid;

@end

#endif /* RunTimeMsgManager_h */
