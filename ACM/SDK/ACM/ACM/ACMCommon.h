//
//  ACMCommon.h
//  ACM
//
//  Created by David on 2020/1/7.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef ACMCommon_h
#define ACMCommon_h

#import "RTM/IACMCallBack.h"

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
};

typedef struct _AcmParam {
    NSString* appId;
    NSString *UserId;
    id<IACMCallBack>  icmCallBack;
} AcmParam;

#endif /* ACMCommon_h */
