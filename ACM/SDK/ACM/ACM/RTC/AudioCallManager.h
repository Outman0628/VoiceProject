//
//  AudioCallManager.h
//  ACM
//
//  Created by David on 2020/1/3.
//  Copyright © 2020 genetek. All rights reserved.
//

#import "IRTCCallBack.h"

@interface AudioCallManager : NSObject

+ (void) startAudioCall: ( nullable NSString *) appId  user:(nullable NSString *)userID  channel:(nullable NSString *)channelId rtcCallback:(id <IRTCCallBack> _Nullable)delegate;

+ (void) endAudioCall;

@end
