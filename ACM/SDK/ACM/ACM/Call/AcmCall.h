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

@property (readonly) NSMutableArray *  _Nonnull rejectDialSubscriberList;    // 拒接电话成员

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

/*
 * 广播离开通话 （暂时没有用，通过eventChanel memberLeft 事件实现）
 */
- (void) broadcastLeaveCall;

/*
 * 广播挂断来电
 */
- (void) broadcastRejectDial;

/*
 * 广播同意电话
 */
- (void) broadcastAgreePhoneCall;

/*
 * 广播委托机器人接听
 */
- (void) broadcastRobotAnswerPhoneCall;

/*
 * 生成成员列表Json
 * @param exceptP2PCall true 一对一时返回空
 */
- (NSArray *_Nullable) getMemberList:(BOOL) exceptP2PCall;


@end

#endif /* AcmCall_h */
