//
//  AcmCall.h
//  ACM
//
//  Created by David on 2020/1/30.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef AcmCall_h
#define AcmCall_h

#import "Call.h"
#import <AgoraRtmKit/AgoraRtmKit.h>

@class AgoraRtmChannel;

@interface AcmCall : Call 

/*
 *生成通话内部同步信息通道
 */
-(BOOL)joinEventSyncChannel:(AgoraRtmJoinChannelBlock _Nullable)completionBlock;

/*
 *添加接听对象, 该函数实现在夫类中
 */
-(void)updateStage: (CallStage) stage;

/*
 *通话结束
 */
-(void)CallEnd;

/*
 *同步实时转写字幕
 */
- (void) broadcastAsrData: (nonnull NSString *)text timeStamp:(NSTimeInterval)startTime isFinished:(BOOL) finished;

- (void) broadcastLeaveCall;

@end

#endif /* AcmCall_h */
