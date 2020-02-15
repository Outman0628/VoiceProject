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
    EventGotRtmCall = 6,
    
    // 接听电话
    EventAgreeCall = 7,
    
    // 拒绝电话
    EventRejectAudioCall = 8,
    
    // RTM拒绝电话消息
    EventRtmRejectAudioCall = 9,
    
    // RTM同意电话消息
    EventRtmAgreeAudioCall = 10,
    
    // 结束通话
    EventLeaveCall = 11,
    
    // 没有成员结束通话
    EventNoMemberEndCall = 12,
    
    // 语音拨号
    EventAudioDial = 13,
    
    // 拨号方结束拨号
    EventCancelCall = 14,
    
    // 拨号方结束拨号(接收方处理)
    EventRTMCancelCall = 15,
    
    // 获取到Apns 电话推送消息
    EventGotApnsCall = 16,
    
    // RTM 拨号消息失败
    EventRtmDialFailed = 17,
    
    // 自己进入RTC 成功
    EventSelfInChannelSucceed = 18,
    
    // 用户进入RTC 成功
    EventDidJoinedOfUid = 19,
    
    // RTC warning
    EventDidRtcOccurWarning = 20,
    
    // RTC Error
    EventDidRtcOccurError = 21,
    
    // 机器人代接
    EventRobotAnswerCall = 22,
    
    // 机器人已经代接
    EventRobotAnsweredCall = 23,
    
    // 后台同意接听电话
    EventBackendAgreeAudioCall = 24,
    
    // 机器人代接
    EventUpdateMuteState = 25,
    
    // 拨号方进入onphon state
    EventOnPhoneCallFromDial = 26,
    
    // ASR 最终数据
    EventASRFinalResult = 27,
    
    // ASR 实时数据
    EventASRRealTimeResult = 28,
    
    // ASR 远端数据
    EventRemoteAsrResult = 29,
    
    // 获取话语权
    EventGetAuthority = 30,
    
    // 拨号或接听超时
    EventDialingTimeout = 31,
    
    // 接听方机器人应答
    EventRTMRobotAnswer = 32,
    
    // 接听方机器人应答
    EventUpdateDialingTimer = 33,
    
    // RTM 状态变更
    EventRTMConnectionStateChange = 34,
    
    // 账号登录检查
    EventLoggedinCheck = 35,
    
    // 远程用户离开频道
    EventRTCUserLeaveChannel = 36,
    
    // 向后台拨号请求成功
    EventBackendRequestDialSucceed = 37,
    
    // 加入事件同步通道成功
    EventJoinEventSyncChannelSucceed = 38,
    
    // 向后台接通电话请求成功
    EventBackendRequestAcceptDialSucceed = 39,
    
    // 事件同步通道成员数量变更
    EventEventChannelMemberCountUpdated = 39,
    
    // 人员离开通话
    EventRtmLeaveCall = 40,
    
    // 拨号方结束通话
    EventCallerEndDial = 41,
    
    // 视频拨号
    EventVideoDial = 42,
    
    // 视频会议远端用户第一帧视频数据已经到达
    EventFirstRemoteVideoDecodedOfUid = 43,
    
    // 获取到RTM 后台配置信息
    EventGotRtmConfig = 44,

    
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
