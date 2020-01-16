//
//  ACMEnums.h
//  ACM
//
//  Created by David on 2020/1/10.
//  Copyright © 2020 genetek. All rights reserved.
//

#ifndef ACMEnums_h
#define ACMEnums_h

/*
 登录错误类型
 */

typedef NS_ENUM(NSInteger, AcmLoginErrorCode) {
    
    /**
     0: Login succeeds. No error occurs.
     */
    AcmRtmLoginErrorOk = 0,
    
    /**
     1: Login fails for reasons unknown.
     */
    AcmRtmLoginErrorUnknown = 1,
    
    /**
     2: Login is rejected, possibly because the SDK is not initialized or is rejected by the server.
     */
    AcmRtmLoginErrorRejected = 2,
    
    /**
     3: Invalid login arguments.
     */
    AcmRtmLoginErrorInvalidArgument = 3,
    
    /**
     4: The App ID is invalid.
     */
    AcmRtmLoginErrorInvalidAppId = 4,
    
    /**
     5: The token is invalid.
     */
    AcmRtmLoginErrorInvalidToken = 5,
    
    /**
     6: The token has expired, and hence login is rejected.
     */
    AcmRtmLoginErrorTokenExpired = 6,
    
    /**
     7: Unauthorized login.
     */
    AcmRtmLoginErrorNotAuthorized = 7,
    
    /**
     8: The user has already logged in or is logging in the Agora RTM system, or the user has not called the [logoutWithCompletion]([AgoraRtmKit logoutWithCompletion:]) method to leave the `AgoraRtmConnectionStateAborted` state.
     */
    AcmRtmLoginErrorAlreadyLogin = 8,
    
    /**
     9: The login times out. The current timeout is set as six seconds.
     */
    AcmRtmLoginErrorTimeout = 9,
    
    /**
     10: The call frequency of the [loginByToken]([AgoraRtmKit loginByToken:user:completion:]) method exceeds the limit of two queries per second.
     */
    AcmRtmLoginErrorLoginTooOften = 10,
    
    /**
     101: The SDK is not initialized.
     */
    AcmRtmLoginErrorLoginNotInitialized = 101,
    
    /**
     1001: 后台登录未知错误.
     */
    AcmLoginBackendErrorUnknow = 1001,
};

/*
 拨号错误类型
 */

typedef NS_ENUM(NSInteger, AcmDialCode) {
    /**
     拨号成功建立连接，进入通话状态.
     */
    AcmDialSucced = 1,
    
    /**
     超时未接听
     */
    AcmDialingTimeout = 2,
    
    /**
     对方拒绝接听
     */
    AcmDialRemoteReject = 3,
    
    /**
     机器人代接成功
     */
    AcmDialRobotAnswered = 4,
    
    /**
     即将开始通话
     */
    AcmPrepareOnphoneStage = 5,
    
    /**
     拨号方取消拨号
     */
    AcmCallerCancelDial= 6,
    
 
    
    /**
     拨号成功发送
     */
    AcmDialRequestSendSucceed = 1000,
    
    /**
     拨号申请失败(网络异常，服务器异常等)
     */
    AcmDialErrorApplyCall = -1,
    
    /**
     拨号申请回复错误(服务器回复内容不正确)
     */
    AcmDialErrorWrongApplyCallResponse = -2,
    
    
    /**
     拨号申请失败(网络异常，服务器异常等)
     */
    AcmDialErrorApplyAnswerCall = -3,
    
    /**
     电话应答申请错误(服务器回复内容不正确)
     */
    AcmDialErrorWrongApplyAnswerCallResponse = -4,
    

};

/*
 通话结束类型
 */

typedef NS_ENUM(NSInteger, AcmPhoneCallCode) {
    
    /*
     成功
     */
    AcmPhoneCallOK = 0,
    
    /**
     对方用户挂断.
     */
    AcmPhoneCallCodeRemoteEnd = 1,
    

    
    /*
     申请话语权失败，服务器异常，或是网络问题
     */
    AcmPhoneCallErrorApplyAuthority = -1,
    
    /*
     申请话语权失败，服务器回复内容异常
     */
    AcmPhoneCallErrorApplyAuthorityResponse = -2,
    
    /*
     申请话语权失败，该请求拥有话语权，或是通话已经结束
     */
    AcmPhoneCallErrorNoAuthority = -3,
};

/*
 登录错误类型
 */

typedef NS_ENUM(NSInteger, AcmError) {
    
    /**
     无错误
     */
    AcmErrorOk = 0,
    
    /**
     未初始化
     */
    AcmErrorNotInited = 1,
    
    /**
     未登录
     */
    AcmErrorNotLogin = 2,
};

#endif /* IACMEnums_h */
