//
//  IRTCCallBack.h
//  ACM
//
//  Created by David on 2020/1/3.
//  Copyright © 2020 genetek. All rights reserved.
//

#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>
#import "ACMEnums.h"

@protocol IRTCCallBack <NSObject>
@optional

/*
 本地语音转文字信息
 @param text 文本信息
 @startTime 文本开始的时间戳
 @param finished false 翻译中的文字， true 翻译完成的文字
 */
- (void)onLocalText: (nonnull NSString *)text timeStamp:(NSTimeInterval)startTime isFinished:(BOOL) finished;


/*
 远端语音转文字信息
 @param text 文本信息
 @param remoteUid 远端uid
 @startTime 文本开始的时间戳, 同一句话的startTime 是相同的
 @msgStamp 远端发送消息时的时间戳
 @finished false 翻译中的文字， true 翻译完成的文字
 */
- (void)onRemoteText: (nonnull NSString *)text remoteAccount:(nonnull NSString *)remoteUid timeStamp:(NSTimeInterval)startTime msgStamp:(NSTimeInterval)msgTimestamp isFinished:(BOOL) finished;

/*
 拨号结果
 @param dialCode 详见AcmDialCode
 */
- (void)didPhoneDialResult:(AcmDialCode)dialCode;

/*
 通话结果
 @param endCode 详见AcmPhoneCallCode
 */
- (void)didPhoneCallResult:(AcmPhoneCallCode)endCode;

/*
 通话中warning 发生时回调
@param warningCode 详见AgoraWarningCode
*/
- (void)didPhonecallOccurWarning:(AgoraWarningCode)warningCode;

/*
 *  通话中error 发生时回调
 @param errorCode 详见AgoraErrorCode
 */
- (void)didOccurError:(AgoraErrorCode)errorCode;

/*
 *  通话频道人员变更，有人参与到Channel, 或是退出Channel 调用该回调更新在线人员
 */
- (void)onlineMemberUpdated:(NSArray *_Nonnull) onlineMemberList;

/*
 *  已完成远端视频首帧解码回调
 @param uid: 用户ID
        size: 视频流尺寸（宽度和高度）
        从本地用户调用 ringVideoCall 到发生此事件过去的时间（ms）
 @return 应用层返回远端视频流显示视图
 */
- (AgoraRtcVideoCanvas *_Nullable) firstRemoteVideoDecodedOfUid:(NSString *_Nonnull)uid size: (CGSize)size elapsed:(NSInteger)elapsed;

@end


/**
 Subscription types.
 */

/**
话语权切换回调函数.
 */
typedef void (^IRTCAGetAuthorityBlock)(AcmPhoneCallCode errorCode);

