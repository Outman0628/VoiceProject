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
 实时语音转文字信息
 @param text 文本信息
 @param uid 文本对应人员ID
 @startTime 文本开始的时间戳
 */
- (void)onSubTitleReceived: (nonnull NSString *)text userId:(nonnull NSString*)uid timeStamp:(NSTimeInterval)startTime;

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

/**  通话中error 发生时回调
 @param errorCode 详见AgoraErrorCode
 */
- (void)didOccurError:(AgoraErrorCode)errorCode;

/**  通话中error 发生时回调
 @param channel 通话频道
 @param uid  用户ID
 @param elapsed 从申请加入频道开始到发生此事件过去的时间（ms)。
 */
- (void)didJoinChannel:(NSString * _Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed;

@end

