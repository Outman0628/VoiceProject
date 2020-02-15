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
    
    
    // 通话方取消通话（通话方通话结束事件）
    CallEventSelfCancel_EndCall = 100,
    
    // 通话方发起的通话无人接听，超时结束通话（通话方通话结束事件）
    CallEventNoResponse_EndCall = 101,
    
    // 通话方发起的通话拨号被接听方拒接（通话方通话结束事件）
    CallEventSubsriberRejected_EndCall = 102,
    
    // 自己拒接电话（接听方通话结束事件）
    CallEventSelfReject_EndCall = 103,
    
    // 接听方通话因为接听方自己拒接结束（接听方通话结束事件）
    //CallEventSubscriberSlefCancel_EndCall = 104,
    
    // 接听方通话因为接听方自己超时未接听结束（接听方通话结束事件）
    CallEventSubscriberSlefTimeout_EndCall = 105,
    
    // 通话方取消通话（通话方通话结束事件）
    CallEventCallerCancel_EndCall = 106,
    
    
    // 通话失败 （结束通话）
    CallEventCallFailed_EndCall = 107,
    
};

#endif /* CallEventEnum_h */
