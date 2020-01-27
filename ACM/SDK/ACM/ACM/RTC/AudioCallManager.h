//
//  AudioCallManager.h
//  ACM
//
//  Created by David on 2020/1/3.
//  Copyright © 2020 genetek. All rights reserved.
//

#import "IRTCCallBack.h"

@class Call;

@interface AudioCallManager : NSObject

// todo 对接接听方请求有只保留call,appid参数
+ (void) startAudioCall: ( nullable NSString *) appId  user:(nullable NSString *)userID  channel:(nullable NSString *)channelId rtcToken:(nullable NSString *)token callInstance:(nonnull Call*) call;

//开关本地音频发送
+ (int)muteLocalAudioStream:(BOOL)mute;

//开关远程音频
+ (int)muteAllRemoteAudioStreams:(BOOL)mute;

//倒入音频流 todo drop

+ (BOOL)pushExternalAudioFrameRawData:(void * _Nonnull)data
                              samplenum:(NSUInteger)sampleNum
                            timestampnum:(NSTimeInterval)timeStamp;

+ (void) endAudioCall;


@end
