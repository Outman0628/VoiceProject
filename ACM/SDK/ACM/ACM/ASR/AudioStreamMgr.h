//
//  AudioStreamMgr.h
//  ACM
//
//  Created by David on 2020/1/14.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef AudioStreamMgr_h
#define AudioStreamMgr_h
#import <Foundation/Foundation.h>

@protocol AudioStreamPushDelegate
@optional
- (void)didCaptureData:(unsigned char *_Nullable)data bytesLength:(int)bytesLength;
@end

@interface AudioStreamMgr : NSObject
+ (void)initMgr;
+ (void)startWork;
+ (void)stopWork;
+ (BOOL)subscribeAudioStream: (nonnull NSObject* ) delegate;
+ (void)unsubscribeAudioStream: (nonnull NSObject* ) delegate;
+ (void)didCaptureData:(unsigned char *_Nullable)data bytesLength:(int)bytesLength;
@end
#endif /* AudioStreamMgr_h */
