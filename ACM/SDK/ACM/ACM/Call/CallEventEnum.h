//
//  CallEventEnum.h
//  ACM
//
//  Created by David on 2020/2/14.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef CallEventEnum_h
#define CallEventEnum_h

/*
    通话过程上报给服务器事件
    1-100 与服务器约定的事件
    > 100 不需要服务器处理的事件
 */
typedef NS_ENUM(NSInteger, CallEventCode) {
    
    // 开始通话
    CallEventStartCall = 1,
    
    // 结束通话
    CallEventEndCall = 2,
    
    // 字幕信息
    SubTitleEvent = 3,
    
    
    /*
     *  拨号方拨号事件
     */
    
    // 通话方拨号错误
    CallEventCallerDialErr = 1000,
    
    // 通话方拨号
    CallEventCallerDial = 1001,
    
    // 通话方取消通话（通话方通话结束事件）
    CallEventSelfCancel_EndCall = 1002,
    
    // 通话方发起的通话无人接听，超时结束通话（通话方通话结束事件）
    CallEventNoResponse_EndCall = 1003,
    
    // 通话方发起的通话拨号被接听方拒接（通话方通话结束事件）
    CallEventSubsriberRejected_EndCall = 1004,
    
    
    /*
     *  接听方拨号事件
     */
    
    // 接听方接听错误
    CallEventReceverDialErr = 1300,
    
    // 接听方收到通话请求
    CallEventReceverDialReq = 1301,
    
    // 自己拒接电话（接听方通话结束事件）
    CallEventSelfReject_EndCall = 1303,
    
    // 接听方手动委托机器人接听
    CallEventRecieverAskRobtAnswer = 1304,
    
    // 接听方通话因为接听方自己超时未接听结束（接听方通话结束事件）
    CallEventSubscriberSlefTimeout_EndCall = 1306,
    
    // 通话方取消通话（通话方通话结束事件）
    CallEventCallerCancel_EndCall = 1307,
    
    
    // 通话失败 （结束通话）
    CallEventCallFailed_EndCall = 1007,
    
};

#endif /* CallEventEnum_h */
