//
//  ACMCommon.h
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef ACMCommon_h
#define ACMCommon_h

#import "IACMCallBack.h"

/**
 Connection states between the SDK and the Agora RTM system.
 */
typedef NS_ENUM(NSInteger, ACMEventType) {
    
    // 初始化SDK
    EventInitSDK = 1,
    
    // 登录
    EventLogin = 2,
    
    // RTM 登录结果
    EventRTMLoginResult = 3,
    
    // 发送消息
    EventSendMsg = 4,
    
    // 获取到RTM 文本消息
    EventGotRtmTextMsg = 5,
    
    // 获取到RTM 电话
    EventGotRtmAudioCall = 6,
    
    // 接听电话
    EventAgreeAudioCall = 7,
    
    // 拒绝电话
    EventRejectAudioCall = 8,
    
    // RTM拒绝电话消息
    EventRtmRejectAudioCall = 9,
    
    // 结束通话
    EventLeaveCall = 10,
    
    // 结束通话
    EventRtmLeaveCall = 11,
    
    // 拨号
    EventDial = 12,
    
    // 拨号方结束拨号
    EventCancelCall = 13,
    
    // 拨号方结束拨号(接收方处理)
    EventRTMCancelCall = 14,
    
    // 获取到Apns 电话推送消息
    EventGotApnsAudioCall = 15,
    
    // RTM 拨号消息失败
    EventRtmDialFailed = 16,
    
    // 自己进入RTC 成功
    EventSelfInChannelSucceed = 17,
    
    // 用户进入RTC 成功
    EventDidJoinedOfUid = 18,
    
    // RTC warning
    EventDidRtcOccurWarning = 19,
    
    // RTC Error
    EventDidRtcOccurError = 20,
    
    // 机器人代接
    EventRobotAnswerCall = 21,
    
    // 机器人已经代接
    EventRobotAnsweredCall = 22,
    
    // 后台同意接听电话
    EventBackendAgreeAudioCall = 23,
    
    // 机器人代接
    EventUpdateMuteState = 24,
    
    // 拨号方进入onphon state
    EventOnPhoneCallFromDial = 25,
    
    // ASR 最终数据
    EventASRFinalResult = 26,
    
    // ASR 实时数据
    EventASRRealTimeResult = 27,
    
    // ASR 远端数据
    EventRemoeAsrResult = 28,
    
    // 获取话语权
    EventGetAuthority = 29,
    

    
    // 拨号
    EventDialRobotDemo = 10000,
    
    // InputStream Test
    EventInputStreamTest = 10001,
};

typedef struct _AcmParam {
    NSString* appId;
    NSString *UserId;
    id<IACMCallBack>  icmCallBack;
} AcmParam;

#endif /* ACMCommon_h */
